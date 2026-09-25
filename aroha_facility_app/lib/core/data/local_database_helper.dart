// lib/core/data/local_database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aroha_tactical_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Inventory Cache Table (Added is_synced flag)
    await db.execute('''
      CREATE TABLE inventory (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        stock_available REAL NOT NULL,
        criticality_rate TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1 
      )
    ''');
    // Note: is_synced = 1 means it matches the server. 0 means it's a local offline edit.

    await db.execute('''
      CREATE TABLE shipments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        route TEXT,
        status TEXT,
        updated_at TEXT
      )
    ''');

    // NEW: Movement Module Tables
    await db.execute('''
      CREATE TABLE teams (
        teamid TEXT PRIMARY KEY,
        teamname TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE personnel (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        activity_status TEXT NOT NULL,
        teamid TEXT NOT NULL
      )
    ''');
  }

  // --- OFFLINE SYNC ARCHITECTURE ---

  Future<void> cacheInventory(List<dynamic> items, {bool isSynced = true}) async {
    final db = await instance.database;
    Batch batch = db.batch();
    
    for (var item in items) {
      batch.insert('inventory', {
        'id': item['id']?.toString() ?? item['name'],
        'name': item['name'],
        'category': item['category'] ?? 'General',
        'stock_available': (item['stock_available'] ?? 0).toDouble(),
        'criticality_rate': item['criticality_rate']?.toString() ?? 'N/A',
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': isSynced ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedInventory() async {
    final db = await instance.database;
    return await db.query('inventory', orderBy: 'stock_available ASC');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedInventory() async {
    final db = await instance.database;
    return await db.query('inventory', where: 'is_synced = ?', whereArgs: [0]);
  }

  // --- DEVELOPMENT DUMMY DATA SEEDER ---
  // Call this while the server is offline to populate your UI
  Future<void> seedDummyData() async {
    final db = await instance.database;
    
    // Check if we already have data to avoid duplicating dummy entries
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM inventory'));
    if (count != null && count > 0) return;

    final dummyItems = [
      {'id': 'itm-001', 'name': 'Thermal Blankets', 'category': 'Survivals', 'stock_available': 150.0, 'criticality_rate': 'LOW'},
      {'id': 'itm-002', 'name': 'Diesel Generator Fuel', 'category': 'Fuel', 'stock_available': 8.5, 'criticality_rate': 'CRITICAL'},
      {'id': 'itm-003', 'name': 'Broad-Spectrum Antibiotics', 'category': 'Medical', 'stock_available': 42.0, 'criticality_rate': 'WARNING'},
      {'id': 'itm-004', 'name': 'Ice-Core Drill Bits', 'category': 'Machineries', 'stock_available': 12.0, 'criticality_rate': 'LOW'},
      {'id': 'itm-005', 'name': 'Dehydrated Rations', 'category': 'Food', 'stock_available': 500.0, 'criticality_rate': 'LOW'},
      // Simulating an item logged while offline (isSynced = false)
    ];

    await cacheInventory(dummyItems, isSynced: true);
    
    // Seed one unsynced item to test the Sync Screen later
    await cacheInventory([
      {'id': 'itm-offline-01', 'name': 'Portable VHF Radio', 'category': 'Spares', 'stock_available': 4.0, 'criticality_rate': 'WARNING'}
    ], isSynced: false);
  }

  // --- CARGO OFFLINE DATA ---
  Future<void> seedCargoData() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM shipments'));
    if (count != null && count > 0) return;

    Batch batch = db.batch();
    batch.insert('shipments', {'id': 'SHP-8942', 'title': 'Ice-Class Vessel Resupply', 'route': 'Goa, IND → Bharati, ANT', 'status': 'AT PORT', 'updated_at': DateTime.now().toIso8601String()});
    batch.insert('shipments', {'id': 'AIR-1109', 'title': 'Emergency Airlift Alpha', 'route': 'Cape Town, SA → Maitri, ANT', 'status': 'DELIVERED', 'updated_at': DateTime.now().toIso8601String()});
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedShipments() async {
    final db = await instance.database;
    return await db.query('shipments');
  }

  // --- MOVEMENT OFFLINE DATA ---
  Future<void> seedMovementData() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM teams'));
    if (count != null && count > 0) return;

    Batch batch = db.batch();
    batch.insert('teams', {'teamid': 'ALL', 'teamname': 'All Members'});
    batch.insert('teams', {'teamid': 'T1', 'teamname': 'Alpha Team'});
    
    batch.insert('personnel', {'id': 'm1', 'name': 'Sarah Connor', 'role': 'Lead Geologist', 'activity_status': 'ON_STATION', 'teamid': 'T1'});
    batch.insert('personnel', {'id': 'm2', 'name': 'Marcus Wright', 'role': 'Field Medic', 'activity_status': 'FIELD_MISSION', 'teamid': 'T1'});
    batch.insert('personnel', {'id': 'm3', 'name': 'Dr. Aarav Sharma', 'role': 'Glaciologist', 'activity_status': 'ON_STATION', 'teamid': 'ALL'});
    
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedTeams() async {
    final db = await instance.database;
    return await db.query('teams');
  }

  Future<List<Map<String, dynamic>>> getCachedMembers(String teamId) async {
    final db = await instance.database;
    if (teamId == 'ALL') return await db.query('personnel');
    return await db.query('personnel', where: 'teamid = ?', whereArgs: [teamId]);
  }
}
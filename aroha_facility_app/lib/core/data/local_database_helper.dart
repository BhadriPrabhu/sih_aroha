// lib/core/data/local_database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aroha_tactical_v2.db'); // Changed name to force fresh DB
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
}
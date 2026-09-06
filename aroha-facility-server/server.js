const http = require('http');
const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

const PORT = 8080;
const dbPath = path.join(__dirname, 'aroha_facility.db');
const db = new DatabaseSync(dbPath);

// Enable foreign keys
db.exec("PRAGMA foreign_keys = ON;");

// Apply Migrations on Server Startup
const migrationsDir = path.join(__dirname, 'db', 'migrations');
if (fs.existsSync(migrationsDir)) {
  const files = fs.readdirSync(migrationsDir).filter(f => f.endsWith('.sql')).sort();
  for (const file of files) {
    try {
      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
      db.exec(sql);
      console.log(`[DB Migration] Successfully applied ${file}`);
    } catch (err) {
      console.error(`[DB Migration Error] ${file}:`, err.message);
    }
  }
}

function parseJsonBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
  });
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer(async (req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = parsedUrl.pathname;
  const searchParams = parsedUrl.searchParams;

  console.log(`[HTTP] ${req.method} ${req.url}`);

  try {
    // 1. GET /api/v1/stocks/categories
    if (req.method === 'GET' && pathname === '/api/v1/stocks/categories') {
      const stationId = searchParams.get('station_id');
      let sql = "SELECT DISTINCT category FROM stocks_master";
      let stmt;
      if (stationId) {
        sql += " WHERE station_id = ?";
        stmt = db.prepare(sql + " ORDER BY category ASC;");
        var rows = stmt.all(stationId);
      } else {
        stmt = db.prepare(sql + " ORDER BY category ASC;");
        var rows = stmt.all();
      }
      const categories = rows.map(r => r.category).filter(Boolean);
      return sendJson(res, 200, { success: true, count: categories.length, categories });
    }

    // 2. GET /api/v1/stocks/filter
    if (req.method === 'GET' && pathname === '/api/v1/stocks/filter') {
      const category = searchParams.get('category');
      const stationId = searchParams.get('station_id');
      let sql = "SELECT * FROM stocks_master WHERE 1=1";
      const params = [];
      if (category) {
        sql += " AND LOWER(category) = LOWER(?)";
        params.push(category);
      }
      if (stationId) {
        sql += " AND station_id = ?";
        params.push(stationId);
      }
      sql += " ORDER BY name ASC;";
      const stmt = db.prepare(sql);
      const stocks = stmt.all(...params);
      return sendJson(res, 200, { success: true, filter: { category, station_id: stationId }, count: stocks.length, stocks });
    }

    // 3. GET /api/v1/stocks/category/:category
    if (req.method === 'GET' && pathname.startsWith('/api/v1/stocks/category/')) {
      const category = decodeURIComponent(pathname.replace('/api/v1/stocks/category/', ''));
      const stmt = db.prepare("SELECT * FROM stocks_master WHERE LOWER(category) = LOWER(?) ORDER BY name ASC;");
      const stocks = stmt.all(category);
      return sendJson(res, 200, { success: true, filter: { category }, count: stocks.length, stocks });
    }

    // 4. GET /api/v1/stocks
    if (req.method === 'GET' && pathname === '/api/v1/stocks') {
      const stmt = db.prepare("SELECT * FROM stocks_master ORDER BY name ASC;");
      const stocks = stmt.all();
      return sendJson(res, 200, { success: true, count: stocks.length, stocks });
    }

    // 5. POST /api/v1/stocks (Create Stock Item)
    if (req.method === 'POST' && pathname === '/api/v1/stocks') {
      const body = await parseJsonBody(req);
      if (!body.name || !body.category) {
        return sendJson(res, 400, { error: "Fields 'name' and 'category' are required" });
      }
      const stockId = 'stk-' + Math.random().toString(36).substring(2, 10);
      const stationId = body.station_id || 'stn-maitri';
      const available = body.stock_available || 0.0;
      const consumed = 0.0;
      const present = available - consumed;
      const criticality = body.criticality_rate || 0.5;

      const stmt = db.prepare(`
        INSERT INTO stocks_master (id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
      `);
      stmt.run(stockId, stationId, body.category, body.name, available, consumed, present, criticality);

      const created = db.prepare("SELECT * FROM stocks_master WHERE id = ?;").get(stockId);
      return sendJson(res, 201, { success: true, message: "Stock record created successfully", stock: created });
    }

    // 6. POST /api/v1/stocks/log (Log ADDED or USED)
    if (req.method === 'POST' && pathname === '/api/v1/stocks/log') {
      const body = await parseJsonBody(req);
      if (!body.stock_id || !body.action || !body.quantity || body.quantity <= 0) {
        return sendJson(res, 400, { error: "Fields 'stock_id', 'action' ('ADDED'|'USED'), and positive 'quantity' are required" });
      }

      const current = db.prepare("SELECT * FROM stocks_master WHERE id = ?;").get(body.stock_id);
      if (!current) {
        return sendJson(res, 404, { error: "Stock item not found" });
      }

      let newAvailable = current.stock_available;
      let newConsumed = current.stock_consumed;

      if (body.action === 'ADDED') {
        newAvailable += body.quantity;
      } else if (body.action === 'USED') {
        newConsumed += body.quantity;
      } else {
        return sendJson(res, 400, { error: "Invalid action. Must be 'ADDED' or 'USED'" });
      }

      let newPresent = newAvailable - newConsumed;

      const updateStmt = db.prepare(`
        UPDATE stocks_master SET stock_available = ?, stock_consumed = ?, present_stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?;
      `);
      updateStmt.run(newAvailable, newConsumed, newPresent, body.stock_id);

      const logId = 'log-' + Math.random().toString(36).substring(2, 10);
      const logStmt = db.prepare(`
        INSERT INTO stock_logs (id, stock_id, action, quantity, notes) VALUES (?, ?, ?, ?, ?);
      `);
      logStmt.run(logId, body.stock_id, body.action, body.quantity, body.notes || '');

      const updated = db.prepare("SELECT * FROM stocks_master WHERE id = ?;").get(body.stock_id);
      return sendJson(res, 200, { success: true, message: `Stock logged successfully (${body.action})`, stock: updated });
    }

    // 7. GET /api/v1/stocks/:id
    if (req.method === 'GET' && pathname.startsWith('/api/v1/stocks/') && !pathname.includes('/filter') && !pathname.includes('/categories')) {
      const id = pathname.replace('/api/v1/stocks/', '');
      const stock = db.prepare("SELECT * FROM stocks_master WHERE id = ?;").get(id);
      if (!stock) {
        return sendJson(res, 404, { error: "Stock item not found" });
      }
      const logs = db.prepare("SELECT * FROM stock_logs WHERE stock_id = ? ORDER BY logged_at DESC;").all(id);
      return sendJson(res, 200, { success: true, stock, logs });
    }

    // 8. GET /api/v1/teams
    if (req.method === 'GET' && pathname === '/api/v1/teams') {
      const teams = db.prepare("SELECT * FROM team_details ORDER BY teamname ASC;").all();
      return sendJson(res, 200, { success: true, count: teams.length, teams });
    }

    // 9. POST /api/v1/teams
    if (req.method === 'POST' && pathname === '/api/v1/teams') {
      const body = await parseJsonBody(req);
      if (!body.teamid || !body.teamname) {
        return sendJson(res, 400, { error: "Fields 'teamid' and 'teamname' are required" });
      }
      const id = 'tm-' + Math.random().toString(36).substring(2, 10);
      const activeStatus = body.active_status || 'ACTIVE';
      const stmt = db.prepare("INSERT INTO team_details (id, teamid, teamname, active_status) VALUES (?, ?, ?, ?);");
      stmt.run(id, body.teamid, body.teamname, activeStatus);
      const team = db.prepare("SELECT * FROM team_details WHERE id = ?;").get(id);
      return sendJson(res, 201, { success: true, message: "Team created successfully", team });
    }

    // 10. GET /api/v1/teams/:teamid/members
    if (req.method === 'GET' && pathname.match(/\/api\/v1\/teams\/[^\/]+\/members$/)) {
      const teamid = pathname.split('/')[4];
      const members = db.prepare("SELECT * FROM member_details WHERE teamid = ? ORDER BY name ASC;").all(teamid);
      return sendJson(res, 200, { success: true, teamid, count: members.length, members });
    }

    // 11. POST /api/v1/teams/:teamid/members
    if (req.method === 'POST' && pathname.match(/\/api\/v1\/teams\/[^\/]+\/members$/)) {
      const teamid = pathname.split('/')[4];
      const body = await parseJsonBody(req);
      if (!body.name || !body.role) {
        return sendJson(res, 400, { error: "Fields 'name' and 'role' are required" });
      }
      const id = 'mem-' + Math.random().toString(36).substring(2, 10);
      const activityStatus = body.activity_status || 'ON_STATION';
      const stmt = db.prepare("INSERT INTO member_details (id, teamid, name, role, activity_status) VALUES (?, ?, ?, ?, ?);");
      stmt.run(id, teamid, body.name, body.role, activityStatus);
      const member = db.prepare("SELECT * FROM member_details WHERE id = ?;").get(id);
      return sendJson(res, 201, { success: true, message: "Member added to team successfully", member });
    }

    // 12. GET /api/v1/teams/:teamid
    if (req.method === 'GET' && pathname.startsWith('/api/v1/teams/')) {
      const teamid = pathname.replace('/api/v1/teams/', '');
      const team = db.prepare("SELECT * FROM team_details WHERE teamid = ?;").get(teamid);
      if (!team) {
        return sendJson(res, 404, { error: "Team not found" });
      }
      const members = db.prepare("SELECT * FROM member_details WHERE teamid = ? ORDER BY name ASC;").all(teamid);
      return sendJson(res, 200, { success: true, team, members });
    }

    // 13. GET /api/v1/members
    if (req.method === 'GET' && pathname === '/api/v1/members') {
      const activityStatus = searchParams.get('activity_status');
      let members;
      if (activityStatus) {
        members = db.prepare("SELECT * FROM member_details WHERE LOWER(activity_status) = LOWER(?) ORDER BY name ASC;").all(activityStatus);
      } else {
        members = db.prepare("SELECT * FROM member_details ORDER BY name ASC;").all();
      }
      return sendJson(res, 200, { success: true, count: members.length, members });
    }

    // Default 404
    return sendJson(res, 404, { error: "Endpoint not found" });

  } catch (err) {
    console.error("[HTTP Server Error]", err);
    return sendJson(res, 500, { error: err.message });
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n==================================================`);
  console.log(` AROHA Facility Server LIVE at http://localhost:${PORT}`);
  console.log(` Database: ${dbPath}`);
  console.log(` Registered Endpoints: /api/v1/stocks, /api/v1/teams, /api/v1/members`);
  console.log(`==================================================\n`);
});

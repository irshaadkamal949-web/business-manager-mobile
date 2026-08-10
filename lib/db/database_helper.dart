import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('business_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Add soft-delete support
      try { await db.execute("ALTER TABLE farm_sales ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE farm_purchases ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE farm_expenses ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE shop_daily ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE shop_credit ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE shop_expenses ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE farm_payments ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE supplier_payments ADD COLUMN deleted INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE shop_daily ADD COLUMN opening_meat REAL DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE shop_daily ADD COLUMN closing_meat REAL DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE shop_daily ADD COLUMN other_expense REAL DEFAULT 0"); } catch (_) {}
      // Audit trail
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deleted_at TEXT NOT NULL,
            table_name TEXT NOT NULL,
            record_id INTEGER NOT NULL,
            description TEXT DEFAULT '',
            deleted_by TEXT DEFAULT 'Owner'
          )
        ''');
      } catch (_) {}
    }
  }

  Future _createDB(Database db, int version) async {
    final schema = '''
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT);

CREATE TABLE IF NOT EXISTS suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE);
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE);
CREATE TABLE IF NOT EXISTS expense_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    pl_group TEXT NOT NULL DEFAULT 'OPEX');

CREATE TABLE IF NOT EXISTS farm_sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    buyer TEXT NOT NULL,
    pay_type TEXT NOT NULL DEFAULT 'CASH',
    goats INTEGER DEFAULT 0,
    amount REAL DEFAULT 0,
    discount REAL DEFAULT 0,
    advance REAL DEFAULT 0,
    adv_by TEXT DEFAULT '',
    received_later REAL DEFAULT 0,
    bill_no TEXT DEFAULT '',
    token TEXT DEFAULT '', weight TEXT DEFAULT '', remarks TEXT DEFAULT '',
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS farm_purchases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    goats INTEGER DEFAULT 0,
    cost REAL DEFAULT 0,
    paid REAL DEFAULT 0,
    remarks TEXT DEFAULT '',
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS inventory_sold (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    purchase_id INTEGER NOT NULL REFERENCES farm_purchases(id) ON DELETE CASCADE,
    goats_sold INTEGER DEFAULT 0,
    amount REAL DEFAULT 0,
    sale_id INTEGER,
    goat_id INTEGER);

CREATE TABLE IF NOT EXISTS farm_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    sale_id INTEGER REFERENCES farm_sales(id) ON DELETE SET NULL,
    bill_no TEXT DEFAULT '',
    amount REAL DEFAULT 0,
    partner TEXT DEFAULT 'KABEER',
    mode TEXT DEFAULT 'Cash',
    remarks TEXT DEFAULT '',
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS supplier_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id),
    amount REAL DEFAULT 0,
    mode TEXT DEFAULT 'CASH',
    remarks TEXT DEFAULT '',
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS farm_expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    category_id INTEGER NOT NULL REFERENCES expense_categories(id),
    description TEXT DEFAULT '',
    amount REAL DEFAULT 0,
    mode TEXT DEFAULT 'CASH',
    remarks TEXT DEFAULT '',
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS shop_daily (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    purchase_cost REAL DEFAULT 0, goats INTEGER DEFAULT 0,
    sales REAL DEFAULT 0, skin REAL DEFAULT 0, akeek REAL DEFAULT 0,
    extra_mutton REAL DEFAULT 0, salary REAL DEFAULT 0, misc REAL DEFAULT 0,
    cust_discount REAL DEFAULT 0,
    opening_meat REAL DEFAULT 0, closing_meat REAL DEFAULT 0, other_expense REAL DEFAULT 0,
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS shop_expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    category TEXT NOT NULL,
    amount REAL DEFAULT 0,
    remarks TEXT DEFAULT '',
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS shop_credit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    credit_given REAL DEFAULT 0,
    collected REAL DEFAULT 0,
    discount REAL DEFAULT 0,
    mode TEXT DEFAULT '',
    notes TEXT DEFAULT '',
    credit_ref TEXT DEFAULT '',
    is_opening INTEGER DEFAULT 0,
    deleted INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS farm_returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    sale_id INTEGER REFERENCES farm_sales(id) ON DELETE SET NULL,
    bill_no TEXT DEFAULT '',
    buyer TEXT DEFAULT '',
    goats INTEGER DEFAULT 0,
    amount REAL DEFAULT 0,
    refund_mode TEXT DEFAULT 'BALANCE',
    back_to_stock INTEGER DEFAULT 0,
    purchase_id INTEGER REFERENCES farm_purchases(id) ON DELETE SET NULL,
    stock_value REAL DEFAULT 0,
    inv_id INTEGER,
    goat_id INTEGER,
    remarks TEXT DEFAULT '');

CREATE TABLE IF NOT EXISTS goats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL REFERENCES farm_purchases(id) ON DELETE CASCADE,
    token TEXT DEFAULT '',
    rate REAL DEFAULT 0,
    remarks TEXT DEFAULT '');

CREATE TABLE IF NOT EXISTS drawings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    amount REAL DEFAULT 0,
    remarks TEXT DEFAULT '');

CREATE TABLE IF NOT EXISTS cash_adjust (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    amount REAL DEFAULT 0,
    remarks TEXT DEFAULT '');

CREATE TABLE IF NOT EXISTS purchase_returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    purchase_id INTEGER NOT NULL REFERENCES farm_purchases(id) ON DELETE CASCADE,
    goats INTEGER DEFAULT 0,
    amount REAL DEFAULT 0,
    mode TEXT DEFAULT 'KHATA',
    goat_id INTEGER,
    remarks TEXT DEFAULT '');

CREATE TABLE IF NOT EXISTS audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deleted_at TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id INTEGER NOT NULL,
    description TEXT DEFAULT '',
    deleted_by TEXT DEFAULT 'Owner');
''';

    final scripts = schema.split(';');
    Batch batch = db.batch();
    for (var script in scripts) {
      if (script.trim().isNotEmpty) {
        batch.execute(script.trim());
      }
    }
    await batch.commit();
    
    // Seed defaults
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('Worker Salary', 'OPEX')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('Shares', 'OPEX')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('CHT Hameeda', 'OPEX')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('CHT Kafoor', 'OPEX')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('Bolero EMI', 'OPEX')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('Goat Feed', 'COGS')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('Medicine / Vet', 'COGS')");
    await db.execute("INSERT OR IGNORE INTO expense_categories(name, pl_group) VALUES ('Other', 'OPEX')");
  }

  // ═══ HELPERS ═══════════════════════════════════════════
  String _monthStart(String? month) {
    if (month == null) {
      final now = DateTime.now();
      return DateFormat('yyyy-MM').format(now) + '-01';
    }
    return month;
  }
  String _monthEnd(String start) {
    final d = DateTime.parse(start);
    final last = DateTime(d.year, d.month + 1, 0);
    return DateFormat('yyyy-MM-dd').format(last);
  }

  // ═══ FARM SALES ════════════════════════════════════════
  Future<int> insertSale(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('farm_sales', row);
  }

  Future<List<Map<String, dynamic>>> getFarmSales({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    return await db.query('farm_sales',
      where: 'deleted = 0 AND date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date DESC, id DESC');
  }

  Future<Map<String, double>> getFarmSalesStats({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    final r = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(amount - discount), 0) as total_net,
        COALESCE(SUM(goats), 0) as total_goats,
        COUNT(*) as total_count,
        COALESCE(SUM(CASE WHEN pay_type = 'Credit' THEN amount - discount ELSE 0 END), 0) as credit_total,
        COALESCE(SUM(CASE WHEN pay_type = 'Credit' THEN goats ELSE 0 END), 0) as credit_goats
      FROM farm_sales WHERE deleted = 0 AND date >= ? AND date <= ?
    ''', [start, end]);
    final row = r.first;
    return {
      'totalNet': (row['total_net'] as num?)?.toDouble() ?? 0,
      'totalGoats': (row['total_goats'] as num?)?.toDouble() ?? 0,
      'totalCount': (row['total_count'] as num?)?.toDouble() ?? 0,
      'creditTotal': (row['credit_total'] as num?)?.toDouble() ?? 0,
      'creditGoats': (row['credit_goats'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<double> getFarmOutstanding() async {
    final db = await instance.database;
    final r = await db.rawQuery('''
      SELECT COALESCE(SUM(amount - discount - advance - received_later), 0) as outstanding
      FROM farm_sales WHERE deleted = 0 AND pay_type = 'Credit'
    ''');
    return (r.first['outstanding'] as num?)?.toDouble() ?? 0;
  }

  Future<void> softDeleteSale(int id) async {
    final db = await instance.database;
    await db.update('farm_sales', {'deleted': 1}, where: 'id = ?', whereArgs: [id]);
    await db.insert('audit_log', {
      'deleted_at': DateTime.now().toIso8601String(),
      'table_name': 'farm_sales',
      'record_id': id,
      'description': 'Farm Sale #$id',
    });
  }

  // ═══ FARM PURCHASES ════════════════════════════════════
  Future<int> insertPurchase(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('farm_purchases', row);
  }

  Future<List<Map<String, dynamic>>> getFarmPurchases({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    return await db.rawQuery('''
      SELECT fp.*, s.name as supplier_name
      FROM farm_purchases fp LEFT JOIN suppliers s ON fp.supplier_id = s.id
      WHERE fp.deleted = 0 AND fp.date >= ? AND fp.date <= ?
      ORDER BY fp.date DESC, fp.id DESC
    ''', [start, end]);
  }

  Future<double> getFarmPurchaseCostMonth({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(cost), 0) as t FROM farm_purchases WHERE deleted = 0 AND date >= ? AND date <= ?',
      [start, end]);
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  // ═══ SUPPLIERS ═════════════════════════════════════════
  Future<int> insertSupplier(String name) async {
    final db = await instance.database;
    return await db.insert('suppliers', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final db = await instance.database;
    return await db.query('suppliers', orderBy: 'name');
  }

  Future<List<Map<String, dynamic>>> getSupplierBalances() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT s.id, s.name,
        COALESCE(SUM(fp.cost), 0) as total_cost,
        COALESCE(SUM(fp.paid), 0) as total_paid,
        COALESCE((SELECT SUM(sp.amount) FROM supplier_payments sp WHERE sp.supplier_id = s.id AND sp.deleted = 0), 0) as payments,
        COALESCE(SUM(fp.cost), 0) - COALESCE(SUM(fp.paid), 0) - COALESCE((SELECT SUM(sp.amount) FROM supplier_payments sp WHERE sp.supplier_id = s.id AND sp.deleted = 0), 0) as balance
      FROM suppliers s
      LEFT JOIN farm_purchases fp ON fp.supplier_id = s.id AND fp.deleted = 0
      GROUP BY s.id, s.name
      HAVING balance > 0
      ORDER BY balance DESC
    ''');
  }

  Future<double> getTotalSupplierBalance() async {
    final bals = await getSupplierBalances();
    double total = 0;
    for (final b in bals) {
      total += (b['balance'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  // ═══ SUPPLIER PAYMENTS ═════════════════════════════════
  Future<int> insertSupplierPayment(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('supplier_payments', row);
  }

  // ═══ FARM EXPENSES ═════════════════════════════════════
  Future<int> insertFarmExpense(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('farm_expenses', row);
  }

  Future<List<Map<String, dynamic>>> getFarmExpenses({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    return await db.rawQuery('''
      SELECT fe.*, ec.name as category_name, ec.pl_group
      FROM farm_expenses fe LEFT JOIN expense_categories ec ON fe.category_id = ec.id
      WHERE fe.deleted = 0 AND fe.date >= ? AND fe.date <= ?
      ORDER BY fe.date DESC
    ''', [start, end]);
  }

  Future<double> getFarmExpensesTotal({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as t FROM farm_expenses WHERE deleted = 0 AND date >= ? AND date <= ?',
      [start, end]);
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    final db = await instance.database;
    return await db.query('expense_categories', orderBy: 'name');
  }

  // ═══ FARM PAYMENTS (credit collections) ════════════════
  Future<int> insertFarmPayment(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('farm_payments', row);
  }

  // ═══ INVENTORY ═════════════════════════════════════════
  Future<int> getGoatsInStock() async {
    final db = await instance.database;
    final purResult = await db.rawQuery("SELECT COALESCE(SUM(goats), 0) as t FROM farm_purchases WHERE deleted = 0");
    final soldResult = await db.rawQuery("SELECT COALESCE(SUM(goats_sold), 0) as t FROM inventory_sold");
    int pur = (purResult.first['t'] as num?)?.toInt() ?? 0;
    int sold = (soldResult.first['t'] as num?)?.toInt() ?? 0;
    return pur - sold;
  }

  Future<double> getStockValue() async {
    final db = await instance.database;
    final r = await db.rawQuery('''
      SELECT COALESCE(SUM(
        CASE WHEN fp.goats > 0 THEN (fp.cost / fp.goats) * (fp.goats - COALESCE(iv.sold, 0)) ELSE 0 END
      ), 0) as val
      FROM farm_purchases fp
      LEFT JOIN (SELECT purchase_id, SUM(goats_sold) as sold FROM inventory_sold GROUP BY purchase_id) iv
        ON iv.purchase_id = fp.id
      WHERE fp.deleted = 0 AND (fp.goats - COALESCE(iv.sold, 0)) > 0
    ''');
    return (r.first['val'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Map<String, dynamic>>> getCurrentBatches() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT fp.id, fp.date, fp.goats, fp.cost, s.name as supplier_name,
        COALESCE(iv.sold, 0) as sold,
        (fp.goats - COALESCE(iv.sold, 0)) as remaining,
        CASE WHEN fp.goats > 0 THEN ROUND(fp.cost / fp.goats) ELSE 0 END as per_goat
      FROM farm_purchases fp
      LEFT JOIN suppliers s ON fp.supplier_id = s.id
      LEFT JOIN (SELECT purchase_id, SUM(goats_sold) as sold FROM inventory_sold GROUP BY purchase_id) iv
        ON iv.purchase_id = fp.id
      WHERE fp.deleted = 0 AND (fp.goats - COALESCE(iv.sold, 0)) > 0
      ORDER BY fp.date DESC
    ''');
  }

  Future<int> insertStockOut(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('inventory_sold', row);
  }

  // ═══ SHOP DAILY LOG ════════════════════════════════════
  Future<int> insertShopDaily(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('shop_daily', row);
  }

  Future<List<Map<String, dynamic>>> getShopDailyLogs({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    return await db.query('shop_daily',
      where: 'deleted = 0 AND date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date DESC');
  }

  Future<Map<String, double>> getShopDailyStats({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    final r = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(sales), 0) as total_sales,
        COALESCE(SUM(skin), 0) as total_skin,
        COALESCE(SUM(akeek), 0) as total_akeek,
        COALESCE(SUM(extra_mutton), 0) as total_mutton,
        COALESCE(SUM(purchase_cost), 0) as total_purchase,
        COALESCE(SUM(salary), 0) as total_salary,
        COALESCE(SUM(misc), 0) as total_misc,
        COALESCE(SUM(cust_discount), 0) as total_discount,
        COALESCE(SUM(other_expense), 0) as total_other,
        COALESCE(SUM(sales + skin + akeek + extra_mutton - purchase_cost - salary - misc - cust_discount - other_expense), 0) as net_profit,
        COUNT(*) as days
      FROM shop_daily WHERE deleted = 0 AND date >= ? AND date <= ?
    ''', [start, end]);
    final row = r.first;
    return {
      'totalSales': (row['total_sales'] as num?)?.toDouble() ?? 0,
      'totalSkin': (row['total_skin'] as num?)?.toDouble() ?? 0,
      'totalAkeek': (row['total_akeek'] as num?)?.toDouble() ?? 0,
      'totalMutton': (row['total_mutton'] as num?)?.toDouble() ?? 0,
      'totalPurchase': (row['total_purchase'] as num?)?.toDouble() ?? 0,
      'totalSalary': (row['total_salary'] as num?)?.toDouble() ?? 0,
      'totalMisc': (row['total_misc'] as num?)?.toDouble() ?? 0,
      'totalDiscount': (row['total_discount'] as num?)?.toDouble() ?? 0,
      'totalOther': (row['total_other'] as num?)?.toDouble() ?? 0,
      'netProfit': (row['net_profit'] as num?)?.toDouble() ?? 0,
      'days': (row['days'] as num?)?.toDouble() ?? 0,
    };
  }

  // ═══ SHOP EXPENSES ═════════════════════════════════════
  Future<int> insertShopExpense(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('shop_expenses', row);
  }

  Future<List<Map<String, dynamic>>> getShopExpenses({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    return await db.query('shop_expenses',
      where: 'deleted = 0 AND date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date DESC');
  }

  Future<double> getShopExpensesTotal({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as t FROM shop_expenses WHERE deleted = 0 AND date >= ? AND date <= ?',
      [start, end]);
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  // ═══ SHOP CREDIT ═══════════════════════════════════════
  Future<int> insertShopCredit(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('shop_credit', row);
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await instance.database;
    return await db.query('customers', orderBy: 'name');
  }

  Future<int> insertCustomer(String name) async {
    final db = await instance.database;
    return await db.insert('customers', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getCustomerBalances() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT c.id, c.name,
        COALESCE(SUM(sc.credit_given), 0) as total_given,
        COALESCE(SUM(sc.collected), 0) as total_collected,
        COALESCE(SUM(sc.discount), 0) as total_discount,
        COALESCE(SUM(sc.credit_given), 0) - COALESCE(SUM(sc.collected), 0) - COALESCE(SUM(sc.discount), 0) as balance
      FROM customers c
      LEFT JOIN shop_credit sc ON sc.customer_id = c.id AND sc.deleted = 0
      GROUP BY c.id, c.name
      HAVING balance > 0 OR total_given > 0
      ORDER BY balance DESC
    ''');
  }

  Future<double> getTotalShopCredit() async {
    final db = await instance.database;
    final r = await db.rawQuery('''
      SELECT COALESCE(SUM(credit_given - collected - discount), 0) as t
      FROM shop_credit WHERE deleted = 0
    ''');
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<Map<String, double>> getShopCreditStats({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);
    final r = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(credit_given), 0) as given,
        COALESCE(SUM(collected), 0) as collected,
        COALESCE(SUM(discount), 0) as discount
      FROM shop_credit WHERE deleted = 0 AND date >= ? AND date <= ?
    ''', [start, end]);
    final row = r.first;
    return {
      'given': (row['given'] as num?)?.toDouble() ?? 0,
      'collected': (row['collected'] as num?)?.toDouble() ?? 0,
      'discount': (row['discount'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getCustomerLedger(int customerId) async {
    final db = await instance.database;
    return await db.query('shop_credit',
      where: 'deleted = 0 AND customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC');
  }

  // ═══ PURCHASE RETURNS ══════════════════════════════════
  Future<int> insertPurchaseReturn(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('purchase_returns', row);
  }

  // ═══ CASH FLOW ═════════════════════════════════════════
  Future<int> insertCashAdjust(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('cash_adjust', row);
  }

  Future<Map<String, double>> getCashFlow({String? monthStart}) async {
    final db = await instance.database;
    final start = _monthStart(monthStart);
    final end = _monthEnd(start);

    double _sum(List<Map<String, dynamic>> r) => (r.first.values.first as num?)?.toDouble() ?? 0;

    final salesCash = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(advance), 0) FROM farm_sales WHERE deleted=0 AND pay_type!='Credit' AND date>=? AND date<=?", [start, end]));
    final shopCounter = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(sales), 0) FROM shop_daily WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final shopCreditColl = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(collected), 0) FROM shop_credit WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final farmCreditColl = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) FROM farm_payments WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final purchasePaid = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(paid), 0) FROM farm_purchases WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final supplierPay = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) FROM supplier_payments WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final farmExp = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) FROM farm_expenses WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final shopDailyCost = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(purchase_cost+salary+misc+cust_discount+other_expense), 0) FROM shop_daily WHERE deleted=0 AND date>=? AND date<=?", [start, end]));
    final shopMonthlyExp = _sum(await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) FROM shop_expenses WHERE deleted=0 AND date>=? AND date<=?", [start, end]));

    final totalIn = salesCash + shopCounter + shopCreditColl + farmCreditColl;
    final totalOut = purchasePaid + supplierPay + farmExp + shopDailyCost + shopMonthlyExp;

    return {
      'salesCash': salesCash,
      'shopCounter': shopCounter,
      'shopCreditColl': shopCreditColl,
      'farmCreditColl': farmCreditColl,
      'purchasePaid': purchasePaid,
      'supplierPay': supplierPay,
      'farmExp': farmExp,
      'shopDailyCost': shopDailyCost,
      'shopMonthlyExp': shopMonthlyExp,
      'totalIn': totalIn,
      'totalOut': totalOut,
      'net': totalIn - totalOut,
    };
  }

  // ═══ DASHBOARD / MONTHLY TRENDS ════════════════════════
  Future<List<Map<String, dynamic>>> getMonthlyProfitTrend(int months) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = [];
    final now = DateTime.now();
    for (int i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final start = DateFormat('yyyy-MM-dd').format(d);
      final end = DateFormat('yyyy-MM-dd').format(DateTime(d.year, d.month + 1, 0));
      final label = DateFormat('MMM').format(d);

      // Farm profit = sales - purchases - expenses
      final farmSales = await db.rawQuery(
        "SELECT COALESCE(SUM(amount-discount), 0) as t FROM farm_sales WHERE deleted=0 AND date>=? AND date<=?", [start, end]);
      final farmPur = await db.rawQuery(
        "SELECT COALESCE(SUM(cost), 0) as t FROM farm_purchases WHERE deleted=0 AND date>=? AND date<=?", [start, end]);
      final farmExp = await db.rawQuery(
        "SELECT COALESCE(SUM(amount), 0) as t FROM farm_expenses WHERE deleted=0 AND date>=? AND date<=?", [start, end]);
      final shopStats = await db.rawQuery('''
        SELECT COALESCE(SUM(sales+skin+akeek+extra_mutton-purchase_cost-salary-misc-cust_discount-other_expense), 0) as t
        FROM shop_daily WHERE deleted=0 AND date>=? AND date<=?
      ''', [start, end]);
      final shopExp = await db.rawQuery(
        "SELECT COALESCE(SUM(amount), 0) as t FROM shop_expenses WHERE deleted=0 AND date>=? AND date<=?", [start, end]);

      double fs = (farmSales.first['t'] as num?)?.toDouble() ?? 0;
      double fp = (farmPur.first['t'] as num?)?.toDouble() ?? 0;
      double fe = (farmExp.first['t'] as num?)?.toDouble() ?? 0;
      double ss = (shopStats.first['t'] as num?)?.toDouble() ?? 0;
      double se = (shopExp.first['t'] as num?)?.toDouble() ?? 0;

      result.add({
        'label': label,
        'farmProfit': fs - fp - fe,
        'shopProfit': ss - se,
        'totalProfit': (fs - fp - fe) + (ss - se),
        'farmSales': fs,
        'farmPurchases': fp,
      });
    }
    return result;
  }

  // ═══ AUDIT LOG ═════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getAuditLog() async {
    final db = await instance.database;
    return await db.query('audit_log', orderBy: 'id DESC', limit: 50);
  }

  Future<void> restoreEntry(int auditId, String tableName, int recordId) async {
    final db = await instance.database;
    await db.update(tableName, {'deleted': 0}, where: 'id = ?', whereArgs: [recordId]);
    await db.delete('audit_log', where: 'id = ?', whereArgs: [auditId]);
  }

  // ═══ GENERIC SOFT DELETE ═══════════════════════════════
  Future<void> softDelete(String table, int id, String desc) async {
    final db = await instance.database;
    await db.update(table, {'deleted': 1}, where: 'id = ?', whereArgs: [id]);
    await db.insert('audit_log', {
      'deleted_at': DateTime.now().toIso8601String(),
      'table_name': table,
      'record_id': id,
      'description': desc,
    });
  }

  // ═══ SETTINGS ══════════════════════════════════════════
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final r = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (r.isEmpty) return null;
    return r.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('settings', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, double>> getDashboardStats() async {
    final db = await instance.database;
    final salesResult = await db.rawQuery("SELECT COALESCE(SUM(amount), 0) as total FROM farm_sales WHERE deleted=0");
    final totalSales = (salesResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final batchResult = await db.rawQuery("SELECT COUNT(*) as count FROM farm_purchases WHERE deleted=0");
    final totalBatches = (batchResult.first['count'] as num?)?.toDouble() ?? 0.0;
    return {
      'totalSales': totalSales,
      'activeBatches': totalBatches,
    };
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.execute("DELETE FROM audit_log");
    await db.execute("DELETE FROM purchase_returns");
    await db.execute("DELETE FROM cash_adjust");
    await db.execute("DELETE FROM drawings");
    await db.execute("DELETE FROM goats");
    await db.execute("DELETE FROM farm_returns");
    await db.execute("DELETE FROM shop_credit");
    await db.execute("DELETE FROM shop_expenses");
    await db.execute("DELETE FROM shop_daily");
    await db.execute("DELETE FROM farm_expenses");
    await db.execute("DELETE FROM supplier_payments");
    await db.execute("DELETE FROM farm_payments");
    await db.execute("DELETE FROM inventory_sold");
    await db.execute("DELETE FROM farm_purchases");
    await db.execute("DELETE FROM farm_sales");
    await db.execute("DELETE FROM expense_categories");
    await db.execute("DELETE FROM customers");
    await db.execute("DELETE FROM suppliers");
    await db.execute("DELETE FROM settings");
    await _createDB(db, 3);
  }

  Future<void> resetAndSeedDemoData() async {
    await clearAllData();
    final db = await instance.database;
    await db.insert('suppliers', {'name': 'KABEER HI-TECH'});
    await db.insert('customers', {'name': 'Retailer 1'});
  }
}

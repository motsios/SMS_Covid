import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'User.dart';

class DatabaseHelper {
  static final _databaseName = "user_database.db";
  static final _databaseVersion = 3;

  static final table = 'user';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE user(name TEXT  KEY, surname TEXT, address TEXT, city TEXT)");
  }

  Future<void> insert(User user) async {
    Database db = await instance.database;
    var res = await db.insert(table, user.toMap());
    print(res);
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table);
    return res;
  }
}

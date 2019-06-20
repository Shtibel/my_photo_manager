import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static DbHelper _dbHelper;
  static Database _database;

  String tableName = 'photos';
  String colId = 'id';
  String colLibrary = 'library';
  String colDirectory = 'directory';
  String colThumb = 'thumb';
  String colImage = 'image';
  String colWidth = 'width';
  String colHeight = 'height';

  DbHelper.createInstance();

  factory DbHelper() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper.createInstance();
    }
    return _dbHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'photos.db');

    var photoDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return photoDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableName ('+
          '$colId INTEGER PRIMARY KEY, '+
          '$colLibrary TEXT, '+
          '$colDirectory TEXT, '+
          '$colThumb TEXT, '+
          '$colImage TEXT, '+
          '$colWidth INTEGER, '+
          '$colHeight INTEGER'+
        ')');
  }

  Future<void> deleteDb() async {
    var databasesPath = await getDatabasesPath();
    await deleteDatabase(databasesPath);
  }

  Future<void> deleteRow(int rowId) async {
    final Database db = await this.database;
    await db.rawDelete('DELETE FROM $tableName WHERE $colId = ?', [rowId]);
  }

  Future<void> deleteSql(String sql, {dynamic params}) async {
    final Database db = await this.database;
    await db.rawDelete(sql, params);
  }
  
  Future<List<Map<String, dynamic>>> readList(String library) async {
    final Database db = await this.database;

    var result =
        await db.rawQuery('select * from $tableName where $colLibrary=?',[library]);
    return result;
  }

  Future<List<Map<String, dynamic>>> selectFromDb(String sql, dynamic params) async {
    final Database db = await this.database;

    var result = await db.rawQuery(sql, params);
    return result;
  }

  Future<int> insertList(Map<String, dynamic> rowData) async {
    final Database db = await this.database;

    int result = await db.rawInsert(
        'INSERT INTO $tableName('+
          '$colLibrary, '+
          '$colDirectory, '+
          '$colThumb, '+
          '$colImage, '+
          '$colWidth, '+
          '$colHeight'+
        ') VALUES(?, ?, ?, ?, ?, ?)',
        [
          rowData['$colLibrary'], 
          rowData['$colDirectory'], 
          rowData['$colThumb'],
          rowData['$colImage'],
          rowData['$colWidth'],
          rowData['$colHeight']
        ]
      );

    return result;
  }

  Future<void> insertToDb(
      String library, String directory, List<Map<String, dynamic>> photos) async {
    //try insert
    photos.forEach((photo) async {
      await insertList({
        'library': photo['library'],
        'directory': photo['directory'],
        'thumb': photo['thumb'],
        'image': photo['image'],
        'width': photo['width'],
        'height': photo['height']
      });
    });
  }
}

import 'dart:async';
import 'dart:io';
import 'package:bookshelf/model/Book.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BookDatabase {
  static final BookDatabase _bookDatabase = new BookDatabase._internal();

  final String tableName = "Books";

  Database db;
  bool didInit = false;

  static BookDatabase get() {
    return _bookDatabase;
  }

  BookDatabase._internal();

  Future<Database> _getDb() async {
    if (!didInit) await _init();
    return db;
  }

  Future _init() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "book_db.db");

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $tableName("
          "${Book.db_id} STRING PRIMARY KEY,"
          "${Book.db_url} TEXT,"
          "${Book.db_title} TEXT,"
          "${Book.db_star} BIT,"
          "${Book.db_notes} TEXT"
          ")");
    });
    didInit = true;
  }

  Future<Book> getBook(String id) async {
    var db = await _getDb();
    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE ${Book.db_id} = "$id"');
    if (result.length == 0) return null;

    return new Book.fromMap(result[0]);
  }

  Future updateBook(Book book) async {
    var db = await _getDb();
    final String sql = 'INSERT OR REPLACE INTO '
        '$tableName(${Book.db_id}, ${Book.db_title}, ${Book.db_url}, ${Book.db_star}, ${Book.db_notes})'
        '  VALUES("${book.id}", "${book.title}", "${book.url}", ${book.starred? 1:0}, "${book.notes}")';

    await db.transaction((txn) async {
      var res = await txn.rawInsert(sql);
      print(res);
    });
  }

  Future close() async {
    var db = await _getDb();
    return db.close();
  }

  Future<List<Book>> getBooks(List<String> ids) async {
    var db = await _getDb();
    var idsString = ids.map((it) => '"$it"').join(',');
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE ${Book.db_id} IN ($idsString)');
    var books = [];

    for (Map<String, dynamic> item in result) {
      books.add(new Book.fromMap(item));
    }
    return books;
  }

  Future<List<Book>> getFavoriteBooks() async {
    var db = await _getDb();
    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE ${Book.db_star} = "1"');
    if (result.length == 0) return [];
    var books = [];
    for (Map<String, dynamic> map in result) {
      books.add(new Book.fromMap(map));
    }
    return books;
  }
}

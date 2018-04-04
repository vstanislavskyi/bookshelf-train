import 'dart:async';
import 'package:bookshelf/data/database.dart';
import 'package:bookshelf/model/Book.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ParsedResponse<T> {
  final T body;

  final int statusCode;

  ParsedResponse(this.statusCode, this.body);

  bool isOk() {
    return statusCode >= 200 && statusCode < 300;
  }
}

final int NO_INTERNET = 404;

class Repository {
  static final Repository _repo = new Repository._internal();

  BookDatabase database;

  static Repository get() {
    return _repo;
  }

  Repository._internal() {
    database = BookDatabase.get();
  }

  Future<ParsedResponse<List<Book>>> getBooks(String input) async {
    http.Response response = await http
        .get("https://www.googleapis.com/books/v1/volumes?q=$input")
        .catchError((resp) {});

    if (response == null) {
      return new ParsedResponse(NO_INTERNET, []);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, []);
    }

    List<dynamic> list = JSON.decode(response.body)['items'];

    Map<String, Book> networkBooks = {};

    for (dynamic jsonBook in list) {
      var imageLinks = jsonBook["volumeInfo"]["imageLinks"];
      Book book = new Book(
          title: jsonBook["volumeInfo"]["title"],
          url: imageLinks != null ? imageLinks["smallThumbnail"] : null,
          id: jsonBook["id"]);
      networkBooks[book.id] = book;
    }

    List<Book> databaseBook =
        await database.getBooks([]..addAll(networkBooks.keys));

    for (Book book in databaseBook) {
      networkBooks[book.id] = book;
    }

    return new ParsedResponse(
        response.statusCode, []..addAll(networkBooks.values));
  }

  Future update(Book book) async {
    database.updateBook(book);
  }

  Future close() async {
    return database.close();
  }
}

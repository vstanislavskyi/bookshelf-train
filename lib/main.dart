import 'package:bookshelf/pages/book_search_page.dart';
import 'package:bookshelf/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Books search',
        //home: new BooksSearchPage(title: 'Books search'),
        routes: {
          '/': (BuildContext context) => new HomePage(),
          '/search': (BuildContext context) =>
              new BooksSearchPage(title: 'Book search'),
          //'/collection': (BuildContext context) => new CollectionPage(),
        });
  }
}

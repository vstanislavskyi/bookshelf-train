import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Books search',
      home: new BooksSearchPage(title: 'Books search'),
    );
  }
}

class Book {
  String title, url;
  Book({this.title, this.url});
}

class BooksSearchPage extends StatefulWidget {
  final String title;

  BooksSearchPage({Key key, this.title}) : super(key: key);

  @override
  _BooksSearchPageState createState() => new _BooksSearchPageState();
}

class _BooksSearchPageState extends State<BooksSearchPage> {
  List<Book> _items = new List();
  final subject = new PublishSubject<String>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    subject.stream
        .debounce(new Duration(milliseconds: 600))
        .listen(_textChanged);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        margin: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: 'Choose a book',
              ),
              onChanged: (string) => (subject.add(string)),
            ),
            _isLoading ? new CircularProgressIndicator() : new Container(),
            new Expanded(
                child: new ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return new Card(
                        child: new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Row(
                            children: <Widget>[
                              item.url != null
                                  ? new Image.network(item.url)
                                  : new Container(),
                              new Flexible(child: new Text(item.title)),
                            ],
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }

  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  void _onError(dynamic d) {
    setState(() {
      _isLoading = false;
    });
  }

  void _addBook(dynamic book) {
    setState(() {
      _items.add(new Book(
          title: book["volumeInfo"]["title"],
          url: book["volumeInfo"]["imageLinks"]["smallThumbnail"]));
    });
  }

  void _textChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearList();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _clearList();

    http
        .get("https://www.googleapis.com/books/v1/volumes?q=$text")
        .then((response) => response.body)
        .then(JSON.decode)
        .then((map) => map["items"])
        .then((list) {
          list.forEach(_addBook);
        })
        .catchError(_onError)
        .then((e) {
          setState(() {
            _isLoading = false;
          });
        });
  }
}

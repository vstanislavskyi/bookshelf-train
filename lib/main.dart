import 'package:bookshelf/book_notes_page.dart';
import 'package:bookshelf/model/Book.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Books search',
        //home: new BooksSearchPage(title: 'Books search'),
        routes: {
          '/': (BuildContext context) => new BooksSearchPage(
                title: 'Book search',
              ),
        });
  }
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
    //BookDatabase.get().init();
  }

  @override
  void dispose() {
    super.dispose();
    subject.close();
    //BookDatabase.get().close();
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
                      return new BookCard(
                        book: _items[index],
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
          id: book["id"],
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

class BookCard extends StatefulWidget {
  final Book book;

  BookCard({this.book});

  @override
  State<StatefulWidget> createState() => new BookCardState();
}

class BookCardState extends State<BookCard> {
  Book bookState;

  @override
  void initState() {
    super.initState();
    bookState = widget.book;
//    BookDatabase.get().getBook(widget.book.id).then((book) {
//      if (book == null) return;
//      setState(() {
//        bookState = book;
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        print('BookCardState.onTap');
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new BookNotesPage(book: bookState)),
        );
//        Navigator.of(context).push(new FadeRouter(
//              builder: (BuildContext context) => new BookNotesPage(bookState),
//              settings:
//                  new RouteSettings(name: '/notes', isInitialRoute: false),
//            ));
      },
      child: new Card(
        child: new Container(
          height: 200.0,
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                widget.book.url != null
                    ? new Hero(
                        tag: bookState.id,
                        child: new Image.network(bookState.url))
                    : new Container(),
                new Expanded(
                    child: new Stack(
                  children: <Widget>[
                    new Align(
                      child: new Padding(
                        child: new Text(
                          bookState.title,
                          maxLines: 10,
                        ),
                        padding: new EdgeInsets.all(8.0),
                      ),
                      alignment: Alignment.center,
                    ),
                    new Align(
                      child: new IconButton(
                          icon: bookState.starred
                              ? new Icon(Icons.star)
                              : new Icon(Icons.star_border),
                          color: Colors.black,
                          onPressed: () {
                            setState(() {
                              bookState.starred = !bookState.starred;
                            });
                            //BookDatabase.get().updateBook(bookState);
                          }),
                      alignment: Alignment.topRight,
                    )
                  ],
                )),
                //new Flexible(child: new Text(bookState.title)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:bookshelf/data/repository.dart';
import 'package:bookshelf/model/Book.dart';
import 'package:bookshelf/pages/book_notes_page.dart';
import 'package:bookshelf/utils/utils.dart';
import 'package:bookshelf/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    subject.stream
        .debounce(new Duration(milliseconds: 600))
        .listen(_textChanged);
  }

  @override
  void dispose() {
    super.dispose();
    subject.close();
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
                          onStarClick: () {
                            setState(() {
                              _items[index].starred = !_items[index].starred;
                            });
                            Repository.get().update(_items[index]);
                          },
                          onCardClick: () {
                            Navigator.of(context).push(new FadeRoute(
                                builder: (BuildContext context) =>
                                    new BookNotesPage(
                                      book: _items[index],
                                    ),
                                settings: new RouteSettings(
                                    name: '/names', isInitialRoute: false)));
                          });
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

    Repository.get().getBooks(text).then((books) {
      setState(() {
        _isLoading = false;
        if (books.isOk()) {
          _items = books.body;
        } else {
          scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text(
                  "Something went wrong, check your internet connection")));
        }
      });
    });
  }
}

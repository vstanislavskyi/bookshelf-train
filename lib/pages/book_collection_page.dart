import 'package:bookshelf/data/repository.dart';
import 'package:bookshelf/model/Book.dart';
import 'package:bookshelf/pages/book_notes_page.dart';
import 'package:bookshelf/utils/utils.dart';
import 'package:bookshelf/widgets/book_card.dart';
import 'package:flutter/material.dart';

class BookCollectionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _BookCollectionPageState();
}

class _BookCollectionPageState extends State<BookCollectionPage> {
  List<Book> _items = new List();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Repository.get().getFavoriteBooks().then((books) {
      setState(() {
        _items = books;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Collection")),
      body: new Stack(
        children: <Widget>[
          _isLoading ? new CircularProgressIndicator() : new Container(),
          new ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return new BookCard(
                  book: _items[index],
                  onCardClick: () {
                    Navigator.of(context).push(new FadeRoute(
                          builder: (BuildContext context) =>
                              new BookNotesPage(book: _items[index]),
                          settings: new RouteSettings(
                              name: '/notes', isInitialRoute: false),
                        ));
                  },
                  onStarClick: () {
                    setState(() {
                      _items[index].starred = !_items[index].starred;
                    });
                    Repository.get().update(_items[index]);
                  },
                );
              })
        ],
      ),
    );
  }
}

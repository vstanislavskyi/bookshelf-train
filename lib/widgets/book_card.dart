import 'package:bookshelf/model/Book.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookCard extends StatefulWidget {
  final Book book;

  final VoidCallback onCardClick;
  final VoidCallback onStarClick;

  BookCard({
    this.book,
    @required this.onCardClick,
    @required this.onStarClick,
  });

  @override
  State<StatefulWidget> createState() => new BookCardState();
}

class BookCardState extends State<BookCard> {

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: widget.onCardClick,
      child: new Card(
        child: new Container(
          height: 200.0,
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              children: <Widget>[
                widget.book.url != null
                    ? new Hero(
                        tag: widget.book.id,
                        child: new Image.network(widget.book.url))
                    : new Container(),
                new Expanded(
                    child: new Stack(
                  children: <Widget>[
                    new Align(
                      child: new Padding(
                        child: new Text(
                          widget.book.title,
                          maxLines: 10,
                        ),
                        padding: new EdgeInsets.all(8.0),
                      ),
                      alignment: Alignment.center,
                    ),
                    new Align(
                      child: new IconButton(
                        icon: widget.book.starred
                            ? new Icon(Icons.star)
                            : new Icon(Icons.star_border),
                        color: Colors.black,
                        onPressed: widget.onStarClick,
                      ),
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

import 'package:bookshelf/data/repository.dart';
import 'package:bookshelf/model/Book.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BookNotesPage extends StatefulWidget {
  final Book book;

  BookNotesPage({this.book});

  @override
  State<StatefulWidget> createState() => new _BookNotesPageState();
}

class _BookNotesPageState extends State<BookNotesPage> {
  TextEditingController _textController;

  final subject = new PublishSubject<String>();

  @override
  void dispose() {
    super.dispose();
    subject.close();
  }

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: widget.book.notes);
    subject.stream.debounce(new Duration(milliseconds: 600)).listen((text) {
      widget.book.notes = text;
      Repository.get().update(widget.book);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.book.title),
      ),
      body: new Container(
        child: new Padding(
          padding: new EdgeInsets.all(10.0),
          child: new Column(
            children: <Widget>[
              new Hero(
                  tag: widget.book.id,
                  child: new Image.network(widget.book.url)),
              new Expanded(
                  child: new Card(
                child: new Padding(
                  padding: new EdgeInsets.all(10.0),
                  child: new TextField(
                    style: new TextStyle(fontSize: 18.0, color: Colors.black),
                    maxLines: null,
                    controller: _textController,
                    onChanged: (text) => subject.add(text),
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:item_tracker/Models/Category.dart';

class addCategory extends StatefulWidget {
  @override
  AddCategoryState createState() => new AddCategoryState();
}

class AddCategoryState extends State<addCategory>{
  TextEditingController _textController;
  String name;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('New Item'),
          actions: [
            new FlatButton(
                onPressed: () {
                  Navigator
                      .of(context)
                      .pop(new Category(name));
                },
                child: new Icon(Icons.create)),
          ],
        ),
        body: new Column(
          children: <Widget>[
            new ListTile(
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: 'Category name',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                controller: _textController,
                onChanged: (value) => name = value,
              ),
            ),
          ],
        )
    );
  }
}
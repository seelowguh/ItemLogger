import 'package:flutter/material.dart';
import 'package:item_tracker/Models/Item.dart';

class AddNewItem extends StatefulWidget {
  @override
  AddNewItemState createState() => new AddNewItemState();
}

class AddNewItemState extends State<AddNewItem> {
  TextEditingController _textController;
  String name;
  String category;
  int count;

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
                    .pop(new Item(name, 0, category));
              },
              child: new Text('Save',
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Name of Item',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              controller: _textController,
                onChanged: (value) => name = value,
            ),
          ),
          new ListTile(
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Category',
              ),
            textCapitalization: TextCapitalization.words,
            controller: _textController,
              onChanged: (value) => category = value,
            ),
          ),
          new ListTile(
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Initial Count',
              ),
            keyboardType: TextInputType.numberWithOptions(),
            controller: _textController,
            onChanged: (value) => count = int.parse(value),
            ),
            )
        ],
      ),
    );
  }

  @override
  void initState() {
    _textController = new TextEditingController(text: name);
    super.initState();
  }

}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'addNewItem.dart';
import 'Item.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: AppHome(title: 'Stored Items'),
    );
  }
}

class AppHome extends StatefulWidget {
  AppHome({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;



  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  var buttonActions = [ 'Delete' ];
  var collectionName = 'trackeditems';
  var key = 'name';
  var value = 'count';

  void _addNewItem(Item item){
    setState(() {
      var uuid = new Uuid();
      var id = uuid.v1();
      var ds = Firestore.instance.collection(collectionName).document(id);
      Map<String, dynamic> mapped = {
        key: item.name,
        value: 0
      };
      ds.setData(mapped);
    });
  }

  void _incrementItemCount(DocumentSnapshot doc){
    setState(() {
      Firestore.instance.runTransaction((tran) async {
        DocumentSnapshot freshSnap = await tran.get(doc.reference);
        await tran.update(freshSnap.reference, {
          value: freshSnap[value] + 1,
        });
      });
    });
  }

  void _decrementItemCount(DocumentSnapshot doc){
    setState(() {
      Firestore.instance.runTransaction((tran) async {
        DocumentSnapshot freshSnap = await tran.get(doc.reference);
        if(freshSnap[value] > 0) {
          await tran.update(freshSnap.reference, {
            value: freshSnap[value] - 1,
          });
        }
      });
    });
  }

  void _deleteItem(DocumentSnapshot doc){
    setState(() {
      Firestore.instance.runTransaction((tran) async {
        DocumentSnapshot freshSnap = await tran.get(doc.reference);
        await tran.delete(freshSnap.reference);
      });
    });
  }

  Future _openAddEntryDialog() async {
    Item save = await Navigator.of(context).push(new MaterialPageRoute<Item>(
        builder: (BuildContext context) {
          return new AddNewItem();
        },
        fullscreenDialog: true
    ));
    if(save != null){
      // Actualy save it
      _addNewItem(save);
    }
  }

  Widget _buildInternalListItem(BuildContext context, DocumentSnapshot document){
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              document[key],
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffddddff),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              document[value].toString(),
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document)
  {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: _buildInternalListItem(context, document),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete_forever,
          onTap: () => _deleteItem(document),
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Minus',

          color: Colors.blueGrey,
          icon: Icons.exposure_neg_1,
          onTap: () => _decrementItemCount(document),
        ),
        IconSlideAction(
          caption: 'Add',
          color: Colors.lightGreen,
          icon: Icons.exposure_plus_1,
          onTap: () => _incrementItemCount(document),
        )
      ],
    );

  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot)
        {
          if(!snapshot.hasData)
          {
            return const Text('Loading...');
          }

          return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntryDialog,
        tooltip: 'New Item',
        child: Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

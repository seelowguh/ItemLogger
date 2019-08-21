import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:item_tracker/Models/Category.dart';
import 'package:uuid/uuid.dart';
import 'package:item_tracker/Categories/addCategory.dart';

class listCategories extends StatefulWidget{
  @override
  listCategoriesState createState() => new listCategoriesState();
}

class listCategoriesState extends State<listCategories>{
String categoryName;
String f_CategoryName = 'categories';
String f_CategoryFieldName = 'category';

  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Categories'),
        actions: <Widget>[
          new FlatButton(onPressed: (){
            Navigator.of(context).pop(() => addCategory());
          },
              child: new Icon(Icons.add),
              ),
          ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection(f_CategoryName).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }

            return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildCategoryList(context, snapshot.data.documents[index]),
            );
          }
      )
    );
  }


  Widget _buildCategoryList(BuildContext context, DocumentSnapshot document){
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: _buildCategoryChildren(context, document),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
            icon: Icons.delete_forever,
            onTap: () => _deleteCategory(document),
        )
      ],
    );
  }

  Widget _buildCategoryChildren(BuildContext context, DocumentSnapshot document){
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              document[f_CategoryName],
              style: Theme.of(context).textTheme.headline,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(DocumentSnapshot document){
    setState(() {
      Firestore.instance.runTransaction((tran) async {
        DocumentSnapshot freshSnap = await tran.get(document.reference);
        await tran.delete(freshSnap.reference);
      });
    });
  }

  void _createCategory(Category category){
    setState(() {
      var uuid = new Uuid();
      var id = uuid.v1();
      var ds = Firestore.instance.collection(f_CategoryName).document(id);
      Map<String, dynamic> mapped = {
        f_CategoryFieldName: category.name,
      };
      ds.setData(mapped);
    });
  }

  Future _openAddCategoryDialog() async {
    Category save = await Navigator.of(context).push(new MaterialPageRoute<Category>(
        builder: (BuildContext context) {
          return new addCategory();
        },
        fullscreenDialog: true
    ));
    if(save != null){
      _createCategory(save);
    }
  }
}
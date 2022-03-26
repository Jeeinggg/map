import 'package:app_accident/screens/page_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class Accidentlist extends StatefulWidget {
  const Accidentlist({Key? key}) : super(key: key);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}


class _CameraWidgetState extends State<Accidentlist> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CollectionReference details =
  FirebaseFirestore.instance.collection('details');


  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _titleController.text = documentSnapshot['title'];
      _descriptionController.text = documentSnapshot['description'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery
                    .of(ctx)
                    .viewInsets
                    .bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'description'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'create' : 'Update'),
                  onPressed: () async {
                    final String? title = _titleController.text;
                    final String? description = _descriptionController.text;

                    if (title != null && description != null) {
                      if (action == 'create') {
                        await details.add(
                            {"title": title, "description": description});
                      }
                      if (action == 'update') {
                        await details
                            .doc(documentSnapshot!.id)
                            .update(
                            {"title": title, "description": description});
                      }
                      _titleController.text = '';
                      _descriptionController.text = '';

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _deleteProduct(String productID) async {
    await details.doc(productID).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ทำการลบเรียบร้อย!')));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: Text('ACCIDENT LISTS'),
        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: details.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
                  DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(documentSnapshot['time']);
                  String datetime = tsdate.year.toString() + "/" + tsdate.month.toString() + "/" + tsdate.day.toString();
                  print(datetime);
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                          documentSnapshot['title'].toString()),
                      subtitle: Text(
                          datetime),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [

                            IconButton(onPressed: () =>
                                _createOrUpdate(documentSnapshot),
                                icon: const Icon(Icons.edit)),
                            IconButton(onPressed: () =>
                                _deleteProduct(documentSnapshot.id),
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                      onTap: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(documentSnapshot['title'].toString()),
                          content: Text(documentSnapshot['description'].toString()),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}










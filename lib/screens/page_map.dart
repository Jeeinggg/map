import 'package:app_accident/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_accident/screens/page_accidentlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';



class pagemap extends StatefulWidget {
  const pagemap({Key? key}) : super(key: key);

  @override
  _pagehomeState createState() => _pagehomeState();
}

class _pagehomeState extends State<pagemap> {
  Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int timestamp = DateTime
      .now()
      .millisecondsSinceEpoch;

  Future<Widget> myMap() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    return GoogleMap(
      markers: Set.from(markers),
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoom: 16,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }


  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("ผู้ใช้งานไม่อนุญาตให้เข้าถึงตำแหน่งที่ตั้ง");
      }
      return null;
    }
  }

  Future _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 16,
            )
        )
    );
  }

  Future _goToHome() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(
        CameraUpdate.newLatLng(
            LatLng(13.124533111161947, 100.91619845478205
            )));
  }

  void _openOnGoogleMapApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (!await launch(googleUrl)) throw"ไม่สามารถเปิดแอพได้";
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CollectionReference details =
  FirebaseFirestore.instance.collection('details');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
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
                            {
                              "title": title,
                              "description": description,
                              "lat": currentLocation!.latitude,
                              "lng": currentLocation!.longitude,
                              "time": timestamp
                            });
                      }
                      if (action == 'update') {
                        await details
                            .doc(documentSnapshot!.id)
                            .update(
                            {"title": title, "description": description});
                      }
                      _titleController.text = '';
                      _descriptionController.text = '';

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
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


  List<Marker> markers = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: details.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              var i = 0;

              if (i < streamSnapshot.data!.docs.length)
                for (i = 0; i < streamSnapshot.data!.docs.length; i++) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[i];


                  DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(
                      documentSnapshot['time']);
                  String datetime = tsdate.year.toString() + "/" +
                      tsdate.month.toString() + "/" + tsdate.day.toString();
                  print(datetime); //output: 2021/12/4

                  markers.add(Marker(
                    markerId: MarkerId(i.toString()),
                    position: LatLng(
                        documentSnapshot['lat'], documentSnapshot['lng']),
                    infoWindow: InfoWindow(
                      title: (documentSnapshot['title'].toString()),
                      snippet: (datetime),
                      onTap: () => _createOrUpdate(documentSnapshot),
                    ),
                  ),
                  );
                }
            }
            return GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set.from(markers),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(13.113688, 100.929925),
                zoom: 16,
              ),
              onTap: _handleTap,

              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            );
            return const Center(
              child: CircularProgressIndicator(),);
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createOrUpdate,
        label: Text("add"),
        icon: Icon(Icons.create),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,


    );
  }

  _handleTap(LatLng tappedPoint) {
    setState(() {

    Future<void> _createOrUpdate2([DocumentSnapshot? documentSnapshot]) async {
      final GoogleMapController controller = await _controller.future;
      currentLocation = await getCurrentLocation();
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
                              {
                                "title": title,
                                "description": description,
                                "lat": tappedPoint.latitude,
                                "lng": tappedPoint.longitude,
                                "time": timestamp
                              });
                        }
                        if (action == 'update') {
                          await details
                              .doc(documentSnapshot!.id)
                              .update(
                              {"title": title, "description": description});
                        }
                        _titleController.text = '';
                        _descriptionController.text = '';

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      }
                    },
                  ),
                ],
              ),
            );
          });
    }

    markers = [];
    markers.add(
      Marker(
        markerId: MarkerId(tappedPoint.toString()),
        position: tappedPoint,
        infoWindow: InfoWindow(
          title: 'Location',
          onTap: () => _createOrUpdate2(),
        ),
      ),
    );
    });
  }
}






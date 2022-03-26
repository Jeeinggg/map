
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_accident/model/user_model.dart';
import 'package:app_accident/screens/page_accidentlist.dart';
import 'package:app_accident/screens/page_map.dart';
import 'package:app_accident/screens/page_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:app_accident/src/titled_navigation_bar.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  Widget appBars = AppBar(
    elevation: 0,
    backgroundColor: Colors.blueAccent,
    title: Text('Accident App'),
    centerTitle: true,
  );

  int currentIndex = 1;
  List<Widget> pages = [pagemap(), Accidentlist(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: TitledBottomNavigationBar(
            currentIndex: currentIndex, // Use this to update the Bar giving a position
            onTap: (int index){
              setState(() {
                currentIndex = index;
              });
            },
            items: [
              TitledNavigationBarItem(title: Text('Map'), icon: Icon(Icons.map)),
              TitledNavigationBarItem(title: Text('List'), icon: Icon(Icons.list)),
              TitledNavigationBarItem(title: Text('Profile'), icon: Icon(Icons.people_alt_outlined)),
            ]
        ),
      body: pages[currentIndex],
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_accident/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'package:app_accident/components/background1.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PROFILE"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Divider(),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('${loggedInUser.firstName} ${loggedInUser.secondName}',style: TextStyle(fontSize:15.0 ),),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text(
              'User Information',
              style: TextStyle(fontSize: 15.0),
            ),
            subtitle: Text('User Information'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () =>showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('User Information'),
                content: Text('Name:\n${loggedInUser.firstName} ${loggedInUser.secondName}\n\nEmail:\n${loggedInUser.email}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Log out',style: TextStyle(fontSize:15.0 ),),
            onTap: () {
              logout(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.bungalow_sharp),
            title: const Text('Exit',style: TextStyle(fontSize:15.0 ),),
            onTap: () {
              if (Platform.isAndroid){
                SystemNavigator.pop();
              }else if (Platform.isIOS){
                exit(0);
              }

              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()));
}


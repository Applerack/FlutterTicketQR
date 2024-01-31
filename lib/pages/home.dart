import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nibm_qr_ticket/pages/mainscreen.dart';
import 'package:native_id/native_id.dart';
import 'package:nibm_qr_ticket/widgets/custom_button.dart';
import 'package:clipboard/clipboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = "";
  String password = "";
  String nativeId = 'Unknown';
  final _nativeIdPlugin = NativeId();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getNativeId();
  }

  _getNativeId() async {
    String? nativeId;
    try {
      nativeId = await _nativeIdPlugin.getId() ?? 'Unknown NATIVE_ID';
    } catch (e) {
      nativeId = 'Failed to get native id.';
    }
    setState(() {
      this.nativeId = nativeId!;
    });
  }

  _copyNativeIdToClipboard() {
    FlutterClipboard.copy(nativeId)
        .then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Native ID copied to clipboard"),
        ),
      );
    });
  }

  _performLogin(List<QueryDocumentSnapshot> docs) {
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final firebaseUsername = data['username'];
      final firebasePassword = data['password'];
      final firebaseNativeId = data['nativeId'];

      if (username == firebaseUsername && password == firebasePassword) {
        if (nativeId == firebaseNativeId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login successful"),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login failed: Device Not Authorized"),
            ),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Login failed: Invalid username or password"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2,0,121 ,1.0),
        title: Text("Access Denied"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/lock.png'),
                radius: 80,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color.fromRGBO(2,0,121,1.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(2,0,121,1.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(2,0,121,1.0)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromRGBO(2,0,121,1.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(2,0,121,1.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(2,0,121,1.0)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              height: 50,
              width: 300,
              child: CustomButton(
                text: "Login",
                onPressed: () async {
                  final snapshot = await _firestore.collection('login').get();
                  if (snapshot.docs.isNotEmpty) {
                    _performLogin(snapshot.docs);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Login failed: Invalid username or password"),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: 300,
              child: CustomButton(
                text: "Copy Native ID",
                onPressed: () {
                  _copyNativeIdToClipboard();
                },
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              height: 20,
              child: Text(
                "CREATED BY MAHDSE23.2 STUDENTS",
                style: TextStyle(
                  color: Color.fromRGBO(2,0,121 ,0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nibm_qr_ticket/AESEncryption/AES.dart';
import 'package:nibm_qr_ticket/widgets/custom_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nibm_qr_ticket/pages/uploadqr.dart';

class QRGenerator extends StatefulWidget {
  @override
  _QRGeneratorState createState() => _QRGeneratorState();
}

bool isUploading = false;
String qrData = "";
String name = "";

class _QRGeneratorState extends State<QRGenerator> {
  FirebaseService servicex = new FirebaseService();
  AESEncryption encryption = new AESEncryption();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void generateQRData() async {
    final String enteredName = nameController.text;
    final String phoneNumber = phoneController.text;
    final String emailAddress = emailController.text;
    final String rawData = "$enteredName|$phoneNumber|$emailAddress";
    final ecd = encryption.encryptMsg(rawData).base16;

    try {
      setState(() {
        isUploading = true;
      });

      await servicex.addQRData(enteredName, phoneNumber, emailAddress, ecd);
      showSnackBar("Successfully created QR CODE");
      qrData = ecd;
      name = enteredName;

      setState(() {
        isUploading = false;
      });
    } catch (e) {
      print(e);
      showSnackBar(e.toString());

      setState(() {
        isUploading = false;
      });
    }
  }

  void clearScreen() {
    setState(() {
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      qrData = "";
      name = "";
    });
  }

  void showSnackBar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 0, 121, 1.0),
        title: Text("Generate Invitation QR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (qrData.isEmpty)
              SingleChildScrollView( 
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(2, 0, 121, 1.0),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: const Color.fromRGBO(2, 0, 121, 1.0),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: const Color.fromRGBO(2, 0, 121, 1.0),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(2, 0, 121, 1.0),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(2, 0, 121, 1.0),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(2, 0, 121, 1.0),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: CustomButton(
                        text: "Generate encoded QR",
                        onPressed: () {
                          if (nameController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              emailController.text.isEmpty) {
                            showSnackBar("All fields are required");
                          } else {
                            generateQRData();
                          }
                        },
                      ),
                      
                    ),
                    SizedBox(height: 10,),

                              SizedBox(
                      height: 50,
                      width: 300,
                      child: CustomButton(
                        text: "Load non attended Emails",
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              emailController.text.isEmpty) {
                            showSnackBar("All fields are required");
                          } else {
                            await servicex.printNonAttendedQRInfo();
                          }
                        },
                      ),
                      
                    ),
                    SizedBox(height: 10,),
                     SizedBox(
                      height: 50,
                      width: 300,
                      child: CustomButton(
                        text: "Print Last 5 qr data",
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              emailController.text.isEmpty) {
                            showSnackBar("All fields are required");
                          } else {
                            await servicex.printLast3QRCodes();
                          }
                        },
                      ),
                      
                    ),
                  ],
                ),
              ),
            if (isUploading)
              CircularProgressIndicator(),
            if (qrData.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 100,
                    width: 320,
                    child: Text(
                      "Dear $name, here is your ticket for the 'Snowy soiree' event @NIBM. We are waiting for your participation. Thanks!!!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(5, 1, 74, 1.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: QrImageView(data: qrData),
                  ),
                  Text(emailController.text),
                  SizedBox(height: 10),
                  Text("e-Ticket Generated By MAHDSE23.2F Students"),
                  Text("Date: 19th December"),
                  Text("Time: 10.00AM"),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: clearScreen,
                    icon: Icon(
                      Icons.clear,
                      color: const Color.fromARGB(255, 255, 252, 252),
                    ),
                    label: Text(
                      "CLEAR",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color.fromRGBO(5, 1, 74, 1.0)),
                      side: MaterialStateProperty.all(BorderSide.none),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

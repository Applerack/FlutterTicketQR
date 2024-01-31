import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:nibm_qr_ticket/AESEncryption/AES.dart';
import 'package:nibm_qr_ticket/pages/uploadqr.dart';
import 'package:nibm_qr_ticket/widgets/custom_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  AESEncryption encryption = AESEncryption();
  String _scanQRCodeResult = 'Scan a QR code';
  String finalres = '';
  bool _isScanned = false;
  bool isAttended = false;
  bool isLunchAttended = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    scanQR();
  }

  Future<void> scanQR() async {
    setState(() {
      _isLoading = true;
    });

    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to scan QR code.';
    }

    if (!mounted) return;

    if (barcodeScanRes != '-1') {
      final data = await FirebaseService().getQRDataByQRCode(barcodeScanRes);

      if (data != null) {
        finalres =
            'Name: ${data['name']}\nEmail: ${data['email']}\nPhone Number: ${data['phoneNumber']}';
        isAttended = await FirebaseService().isAttended(barcodeScanRes);
        isLunchAttended = await FirebaseService().isLunchAttended(barcodeScanRes);
        _isScanned = true;
      } else {
        finalres = 'QR code not found in the database.';
        _isScanned = true;
      }
    } else {
      finalres = 'Scan a QR code';
      _isScanned = false;
    }

    setState(() {
      _scanQRCodeResult = barcodeScanRes;
      _isLoading = false;
    });
  }

Future<void> markAsAttended() async {
  if (_scanQRCodeResult != '-1') {
    setState(() {
      _isLoading = true;
    });

    try {
      final isAlreadyAttended = await FirebaseService().isAttended(_scanQRCodeResult);

      if (isAlreadyAttended) {
        isAttended = true; 
        isLunchAttended = await FirebaseService().isLunchAttended(_scanQRCodeResult);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance already marked!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await FirebaseService().markAttendance(
          finalres.split('\n')[0].split(': ')[1],
          finalres.split('\n')[1].split(': ')[1],
          finalres.split('\n')[2].split(': ')[1],
          _scanQRCodeResult,
        );

        setState(() {
          isAttended = true; 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully marked attendance!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Unable to mark attendance!'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


Future<void> markAsLunchAttend() async {
  if (_scanQRCodeResult != '-1') {
    setState(() {
      _isLoading = true;
    });

    try {
      final isAlreadyLunchAttended = await FirebaseService().isLunchAttended(_scanQRCodeResult);

      if (isAlreadyLunchAttended) {
        isLunchAttended = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lunch attendance already marked!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await FirebaseService().markLunchAttendance(
          finalres.split('\n')[0].split(': ')[1],
          finalres.split('\n')[1].split(': ')[1],
          finalres.split('\n')[2].split(': ')[1],
          _scanQRCodeResult,
        );

        setState(() {
          isLunchAttended = true;
        
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully marked lunch attendance!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Unable to mark lunch attendance!'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
        backgroundColor: Color.fromRGBO(2,0,121 ,1.0),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isScanned)
              Container(
                height: 200,
                width: 200,
                child: QrImageView(data: _scanQRCodeResult),
              ),
            Text(finalres , style: TextStyle(fontSize: 15),),
            SizedBox(height: 15 ),
           Text(
  'Attended           : ${isAttended ? 'Yes' : 'No'}',
  style: TextStyle(
    fontSize: 17,
    color: isAttended ? Colors.red : Colors.green,
  ),
),
Text(
  'Lunch Attended: ${isLunchAttended ? 'Yes' : 'No'}',
  style: TextStyle(
    fontSize: 17,
    color: isLunchAttended ? Colors.red : Colors.green,
  ),
),

            if (_isLoading)
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              )
            else
              Column(
                children: <Widget>[
                  SizedBox(height: 20,),
                  SizedBox(
                    height :40,width:230 , child  :CustomButton(
                    text: "ReScan",
                    onPressed: () {
                      scanQR(); 
                      setState(() {
                        _isScanned = false;
                        isAttended = false;
                        isLunchAttended = false;
                      });
                    },
                  ),),
                  SizedBox(height: 10,),
                  SizedBox(
                    height :40,width:230 , child  :CustomButton(
                    text: "Mark Attendance",
                    onPressed: () {
                      markAsAttended(); 
                   
                    },
                  ),),
                  SizedBox(height: 10,),
                   SizedBox(
                    height :40,width:230 , child  :CustomButton(
                    text: "Mark Lunch Attendance",
                    onPressed: () {
                      markAsLunchAttend(); 
                    
                    },
                  ),),
                ],
              ),
          ],
        ),
      ),
    );
  }
}





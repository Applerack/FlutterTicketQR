import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addQRData(String name, String phoneNumber, String email, String qrCode) async {
    try {
     
      final QuerySnapshot existingDocuments = await _firestore.collection('qr_data').where('email', isEqualTo: email).get();

      if (existingDocuments.docs.isNotEmpty) {

        throw 'QR code already exists for this email';
      }

     
      await _firestore.collection('qr_data').add({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'qrCode': qrCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> getQRDataByQRCode(String qrCode) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('qr_data')
          .where('qrCode', isEqualTo: qrCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final document = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return document;
      } else {
        return null; // QR code not found
      }
    } catch (e) {
      throw e.toString();
    }
  }

Future<void> markAttendance(String name, String email, String phoneNumber, String qrCode) async {
    try {
      await _firestore.collection('attended_qr').add({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'qrCode': qrCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> markLunchAttendance(String name, String email, String phoneNumber, String qrCode) async {
    try {
      await _firestore.collection('lunchattend_qr').add({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'qrCode': qrCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<int> calculateTotalQR() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('qr_data').get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<int> calculateAttendedQR() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('attended_qr').get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<int> calculateLunchAttendQR() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('lunchattend_qr').get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> isAttended(String qrCode) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('attended_qr')
          .where('qrCode', isEqualTo: qrCode)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> isLunchAttended(String qrCode) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('lunchattend_qr')
          .where('qrCode', isEqualTo: qrCode)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw e.toString();
    }
  }

 Future<void> printLast3QRCodes() async {
    try {
     
      final QuerySnapshot querySnapshot = await _firestore
          .collection('qr_data')
          .orderBy('timestamp', descending: true)
          .limit(5
          )
          .get();

      final List<Map<String, dynamic>> last3QRCodes =
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Print the information
      for (Map<String, dynamic> qrCode in last3QRCodes) {
        print('Name: ${qrCode['name']}');
        print('Phone Number: ${qrCode['phoneNumber']}');
        print('Email: ${qrCode['email']}');
        print('Native ID: ${qrCode['nativeid']}');
        print('Timestamp: ${qrCode['timestamp']}');
        print('-----------------------------');
      }
    } catch (e) {
      throw e.toString();
    }
  }
  
Future<void> printNonAttendedQRInfo() async {
  try {
    final QuerySnapshot allQRCodesSnapshot = await _firestore.collection('qr_data').get();
    final List<String> allQRCodes = allQRCodesSnapshot.docs.map((doc) => doc['qrCode'] as String).toList();

    final QuerySnapshot attendedQRCodesSnapshot = await _firestore.collection('attended_qr').get();
    final List<String> attendedQRCodes = attendedQRCodesSnapshot.docs.map((doc) => doc['qrCode'] as String).toList();

    final List<String> nonAttendedQRCodes = allQRCodes.where((qrCode) => !attendedQRCodes.contains(qrCode)).toList();

    for (String qrCode in nonAttendedQRCodes) {
      final qrData = await getQRDataByQRCode(qrCode);
      if (qrData != null) {
        final name = qrData['name'] as String;
        final phoneNumber = qrData['phoneNumber'] as String;
        final email = qrData['email'] as String;
        final id = qrData['nativeid'] as String;
     
        print('Name: $name');
        print('Phone Number: $phoneNumber');
        print('Email: $email');
        print('Native ID: $id');
        print('----------------');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}


  

  

}


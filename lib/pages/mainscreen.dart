import 'package:flutter/material.dart';
import 'package:nibm_qr_ticket/pages/home.dart';
import 'package:nibm_qr_ticket/pages/qr_generator.dart';
import 'package:nibm_qr_ticket/pages/scanqr.dart';
import 'package:nibm_qr_ticket/widgets/custom_button.dart';
import 'package:nibm_qr_ticket/pages/uploadqr.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int totalTicketsGenerated = 0;
  int totalEntranceScanned = 0;
  int totalLunchScanned = 0;

  FirebaseService firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });

    final generated = await firebaseService.calculateTotalQR();
    final entranceScanned = await firebaseService.calculateAttendedQR();
    final lunchScanned = await firebaseService.calculateLunchAttendQR();

    setState(() {
      totalTicketsGenerated = generated;
      totalEntranceScanned = entranceScanned;
      totalLunchScanned = lunchScanned;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            leading: PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.white ,size: 30,),
              onSelected: (choice) {
                switch (choice) {
                  case 'generate_ticket':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRGenerator()),
                    );
                    break;
                  case 'scan_entrance':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRScanner()),
                    );
                    break;

                  case 'logout':
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'generate_ticket',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.qr_code, color: Color.fromRGBO(2, 0, 121, 1.0)),
                        SizedBox(width: 8.0),
                        Text('Generate Ticket', style: TextStyle(color: Color.fromRGBO(2, 0, 121, 1.0)),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'scan_entrance',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.qr_code, color: Color.fromRGBO(2, 0, 121, 1.0)),
                        SizedBox(width: 8.0),
                        Text('Scan Entrance', style: TextStyle(color: Color.fromRGBO(2, 0, 121, 1.0)),
                        ),
                    ],
                  )),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.logout, color: Color.fromRGBO(2, 0, 121, 1.0)),
                        SizedBox(width: 8.0),
                        Text('Logout', style: TextStyle(color: Color.fromRGBO(2, 0, 121, 1.0)),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
       
              background: Image.asset('assets/cristmas.jpg', fit: BoxFit.cover),
            ),
           
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (_isLoading)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading...'),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40,),
                      InfoBox(
                        label: 'Total Tickets Generated',
                        count: totalTicketsGenerated,
                      ),
                      InfoBox(
                        label: 'Total Entrance Scanned',
                        count: totalEntranceScanned,
                      ),
                      InfoBox(
                        label: 'Total Lunch Scanned',
                        count: totalLunchScanned,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: 300,
                        child: CustomButton(
                          onPressed: () {
                            loadData();
                          },
                          text: "REFRESH",
                        ),
                      ),
                      SizedBox(height: 45),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String label;
  final int count;

  InfoBox({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      width: 350,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(25, 25, 112, 8.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

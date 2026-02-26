import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase/FlutterProject/CurrentFacilityUsing.dart';
import 'package:flutter_firebase/FlutterProject/Email_Signin_Otp.dart';
import 'package:rxdart/rxdart.dart';

import 'Admin_otp_verification.dart';

class AdminTodayBookingsPage extends StatefulWidget {
  const AdminTodayBookingsPage({super.key});

  @override
  State<AdminTodayBookingsPage> createState() =>
      _AdminTodayBookingsPageState();
}

class _AdminTodayBookingsPageState
    extends State<AdminTodayBookingsPage> {

  String searchQuery = "";

  DateTime get todayOnly {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Stream<List<Map<String, dynamic>>> _todayBookings() {
    final today = todayOnly;

    final facilityStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('date',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(today))
        .where('date',
        isLessThan:
        Timestamp.fromDate(
            today.add(const Duration(days: 1))))
        .snapshots();

    final pcStream = FirebaseFirestore.instance
        .collection('PcRoom')
        .where('date',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(today))
        .where('date',
        isLessThan:
        Timestamp.fromDate(
            today.add(const Duration(days: 1))))
        .snapshots();

    return Rx.combineLatest2(
      facilityStream,
      pcStream,
          (facilitySnap, pcSnap) {

        final List<Map<String, dynamic>> merged = [];

        /// Facility bookings
        for (var d in facilitySnap.docs) {
          final data = d.data();

          merged.add({
            'id': d.id,
            'collection': 'bookings',
            'title': data['facilityId']?.toString().toUpperCase() ?? '',
            'name': data['userName'] ?? '',
            'email': data['user_email'] ?? '',   // ✅ ADD THIS
            'date': (data['date'] as Timestamp).toDate(),
            'time': "${data['startMin']} - ${data['endMin']}",
            'status': data['status'] ?? 'active',
          });
        }

        /// PC bookings
        for (var d in pcSnap.docs) {
          final data = d.data();

          List members = [];

          if (data['Members_Info'] is Map) {
            members = (data['Members_Info'] as Map).values.toList();
          } else if (data['Members_Info'] is List) {
            members = data['Members_Info'];
          }

          String memberDetails = members.map((m) {
            String name = m['name'] ?? '';
            String sid = m['studentId'] ?? '';
            return "$name ($sid)";
          }).join(', ');

          merged.add({
            'id': d.id,
            'collection': 'PcRoom',
            'title': "PC ${data['pcnumber']}",
            'name': memberDetails.isEmpty ? "No Members" : memberDetails,
            'email': data['user_email'] ?? '',   // ✅ ADD THIS
            'date': (data['date'] as Timestamp).toDate(),
            'time': "${data['startTime']} - ${data['endTime']}",
            'status': data['status'] ?? 'active',
          });
        }

        return merged;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Today's Bookings",
          style: TextStyle(fontFamily: "Mono", color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00796B),
        centerTitle: true,
      ),
      body: Column(
        children: [

          /// 🔍 Search Field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by name or booking ID",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15,right: 15),
          child: ElevatedButton(style:ButtonStyle(
            backgroundColor: WidgetStatePropertyAll( Color(0xFF00796B)),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
          ),onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return Currentfacilityusing();
            }));
          }, child: Row(
            children: [
              Text("Current Facility users"),
              SizedBox(width: 3,),
              Icon(Icons.login_outlined)
            ],
          ))),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _todayBookings(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                var bookings = snapshot.data!;

                /// Apply search filter
                if (searchQuery.isNotEmpty) {
                  bookings = bookings.where((b) {
                    return b['id']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery) ||
                        b['name']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery);
                  }).toList();
                }

                if (bookings.isEmpty) {
                  return const Center(
                      child: Text("No bookings for today"));
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [

                    /// Same Section Title Style
                    _sectionTitle("Today's Bookings"),

                    ...bookings.map(
                          (b) => _bookingCard(context, b),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Same Section Title Style
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Same Booking Card Style as User Page
  Widget _bookingCard(
      BuildContext context,
      Map<String, dynamic> b,
      ) {
    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(b['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Date: ${b['date'].day}-${b['date'].month}-${b['date'].year}"),
            Text("Name: ${b['name']}"),
            Text("Email: ${b['email']}"),
            Text("Time: ${b['time']}"),
            Text(
              "Status: ${b['status']}",
              style: TextStyle(
                color: b['status'] == 'cancelled'
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return AdminOtpVerification(booking: b);
          }));
          // Next step → OTP Check-in page
        },
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Currentfacilityusing extends StatefulWidget {
  const Currentfacilityusing({super.key});

  @override
  State<Currentfacilityusing> createState() => _CurrentfacilityusingState();
}

class _CurrentfacilityusingState extends State<Currentfacilityusing> {

  DateTime combineDateAndTime(Timestamp date, String time) {
    final dateOnly = date.toDate();

    final parts = time.split(" ");
    final hm = parts[0].split(":");
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (parts[1] == "PM" && hour != 12) hour += 12;
    if (parts[1] == "AM" && hour == 12) hour = 0;

    return DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      hour,
      minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currently Using Facilities"),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("PcRoom")
            .where("status", isEqualTo: "active")
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Active Users"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final Timestamp date = data['date'];
              final String endTime = data['endTime'];

              // 🔥 AUTO REMOVE WHEN TIME ENDS
              final DateTime endDateTime =
              combineDateAndTime(date, endTime);

              if (DateTime.now().isAfter(endDateTime)) {
                doc.reference.delete();
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("PC ${data['pcnumber']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User: ${data['user_email']}"),
                      Text("Date: ${date.toDate()}"),
                      Text("Time: ${data['startTime']} - ${data['endTime']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
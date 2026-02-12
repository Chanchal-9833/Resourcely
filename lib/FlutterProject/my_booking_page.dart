import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './resourcely_colors.dart';
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  /// ⏱ Convert minutes → TimeOfDay
  TimeOfDay minToTime(int min) {
    return TimeOfDay(hour: min ~/ 60, minute: min % 60);
  }

  /// ⏱ Build booking END DateTime
  DateTime buildEndDateTime(
      DateTime date,
      dynamic endTime,
      ) {
    // PC booking → already string time (e.g. 2:20 PM)
    if (endTime is String) {
      final tod = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]) % 12 +
            (endTime.contains("PM") ? 12 : 0),
        minute: int.parse(endTime.split(':')[1].split(' ')[0]),
      );
      return DateTime(
          date.year, date.month, date.day, tod.hour, tod.minute);
    }

    // Facility booking → minutes
    final tod = minToTime(endTime);
    return DateTime(
        date.year, date.month, date.day, tod.hour, tod.minute);
  }

  /// ❌ Cancel booking
  Future<void> cancelBooking(String collection, String id) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .update({'status': 'cancelled'});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Bookings",

          style: TextStyle(fontFamily: "Mono"),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _mergedBookings(uid, context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();

          final upcoming = snapshot.data!
              .where((b) => b['endDateTime'].isAfter(now))
              .toList();

          final past = snapshot.data!
              .where((b) => b['endDateTime'].isBefore(now))
              .toList();

          if (upcoming.isEmpty && past.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (upcoming.isNotEmpty) ...[
                _sectionTitle("Upcoming"),
                ...upcoming.map((b) =>
                    _bookingCard(context, b, isUpcoming: true)),
              ],
              if (past.isNotEmpty) ...[
                _sectionTitle("Past"),
                ...past.map((b) =>
                    _bookingCard(context, b, isUpcoming: false)),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 🔁 Merge Facility + PC bookings
  Stream<List<Map<String, dynamic>>> _mergedBookings(
      String uid, BuildContext context) async* {
    final facilitySnap = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .snapshots();

    final pcSnap = FirebaseFirestore.instance
        .collection('PcRoom')
        .where('userId', isEqualTo: uid)
        .snapshots();

    await for (final _ in facilitySnap) {
      final f = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();

      final p = await FirebaseFirestore.instance
          .collection('PcRoom')
          .where('userId', isEqualTo: uid)
          .get();

      final List<Map<String, dynamic>> merged = [];

      /// 🏟 Facility bookings
      for (var d in f.docs) {
        final data = d.data();
        final date = (data['date'] as Timestamp).toDate();
        final endDT = buildEndDateTime(date, data['endMin']);

        merged.add({
          'id': d.id,
          'collection': 'bookings',
          'title': data['facilityId'].toString().toUpperCase(),
          'date': date,
          'time':
          "${minToTime(data['startMin']).format(context)} - ${minToTime(data['endMin']).format(context)}",
          'status': data['status'],
          'endDateTime': endDT,
        });
      }

      /// 💻 PC bookings
      for (var d in p.docs) {
        final data = d.data();
        final date = (data['date'] as Timestamp).toDate();
        final endDT = buildEndDateTime(date, data['endTime']);

        merged.add({
          'id': d.id,
          'collection': 'PcRoom',
          'title': "PC ${data['pcnumber']}",
          'date': date,
          'time': "${data['startTime']} - ${data['endTime']}",
          'status': data['status'],
          'endDateTime': endDT,
        });
      }

      merged.sort(
              (a, b) => b['endDateTime'].compareTo(a['endDateTime']));
      yield merged;
    }
  }

  /// 🧱 Section title
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

  /// 🎫 Booking Card
  Widget _bookingCard(
      BuildContext context,
      Map<String, dynamic> b, {
        required bool isUpcoming,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(b['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Date: ${b['date'].day}-${b['date'].month}-${b['date'].year}"),
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
        trailing: isUpcoming && b['status'] != 'cancelled'
            ? IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () =>
              cancelBooking(b['collection'], b['id']),
        )
            : null,
      ),
    );
  }
}

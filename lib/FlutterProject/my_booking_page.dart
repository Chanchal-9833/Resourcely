import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './resourcely_colors.dart';
// import 'package:rxdart/rxdart.dart';


class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  /// Convert minutes → TimeOfDay
  TimeOfDay minToTime(int min) {
    return TimeOfDay(hour: min ~/ 60, minute: min % 60);
  }

  /// Parse "2:30 PM" safely
  DateTime parseStringTime(DateTime date, String timeString) {
    final parts = timeString.split(' ');
    final hm = parts[0].split(':');

    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (parts[1] == "PM" && hour != 12) {
      hour += 12;
    }
    if (parts[1] == "AM" && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Build booking END DateTime safely
  DateTime buildEndDateTime(DateTime date, dynamic endTime) {
    if (endTime == null) return date;

    if (endTime is String) {
      return parseStringTime(date, endTime);
    }

    if (endTime is int) {
      final tod = minToTime(endTime);
      return DateTime(date.year, date.month, date.day, tod.hour, tod.minute);
    }

    return date;
  }

  /// Cancel booking
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
          style: TextStyle(fontFamily: "Mono", color: Colors.white),
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
              .where((b) =>
          b['status'] != 'cancelled' &&
              b['endDateTime'].isAfter(now))
              .toList();

          final past = snapshot.data!
              .where((b) =>
          b['status'] == 'cancelled' ||
              b['endDateTime'].isBefore(now))
              .toList();

          if (upcoming.isEmpty && past.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (upcoming.isNotEmpty) ...[
                _sectionTitle("Upcoming"),
                ...upcoming
                    .map((b) => _bookingCard(context, b, isUpcoming: true)),
              ],
              if (past.isNotEmpty) ...[
                _sectionTitle("Past"),
                ...past
                    .map((b) => _bookingCard(context, b, isUpcoming: false)),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Properly merge Facility + PC bookings streams
  Stream<List<Map<String, dynamic>>> _mergedBookings(
      String uid, BuildContext context) {
    final facilityStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .snapshots();

    final pcStream = FirebaseFirestore.instance
        .collection('PcRoom')
        .where('userId', isEqualTo: uid)
        .snapshots();

    return facilityStream.asyncMap((facilitySnap) async {
      final pcSnap = await FirebaseFirestore.instance
          .collection('PcRoom')
          .where('userId', isEqualTo: uid)
          .get();

      final List<Map<String, dynamic>> merged = [];

      /// Facility bookings
      for (var d in facilitySnap.docs) {
        final data = d.data();

        if (data['date'] == null) continue;

        final date = (data['date'] as Timestamp).toDate();
        final endDT = buildEndDateTime(date, data['endMin']);

        merged.add({
          'id': d.id,
          'collection': 'bookings',
          'title': data['facilityId']?.toString().toUpperCase() ?? '',
          'date': date,
          'time':
          "${minToTime(data['startMin']).format(context)} - ${minToTime(data['endMin']).format(context)}",
          'status': data['status'] ?? 'active',
          'endDateTime': endDT,
        });
      }

      /// PC bookings
      for (var d in pcSnap.docs) {
        final data = d.data();

        if (data['date'] == null) continue;

        final date = (data['date'] as Timestamp).toDate();
        final endDT = buildEndDateTime(date, data['endTime']);

        merged.add({
          'id': d.id,
          'collection': 'PcRoom',
          'title': "PC ${data['pcnumber'] ?? ''}",
          'date': date,
          'time': "${data['startTime']} - ${data['endTime']}",
          'status': data['status'] ?? 'active',
          'endDateTime': endDT,
        });
      }

      merged.sort(
              (a, b) => b['endDateTime'].compareTo(a['endDateTime']));

      return merged;
    });
  }

  /// Section title
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

  /// Booking Card
  Widget _bookingCard(
      BuildContext context,
      Map<String, dynamic> b, {
        required bool isUpcoming,
      }) {
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
        trailing: isUpcoming
            ? IconButton(
          icon:
          const Icon(Icons.cancel, color: Colors.red),
          onPressed: () =>
              cancelBooking(b['collection'], b['id']),
        )
            : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './resourcely_colors.dart';

class Booking extends StatefulWidget {
  final String facilityId;

  const Booking({super.key, required this.facilityId});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isLoading = false;

  /// 🔹 Date stored as midnight timestamp
  Timestamp get selectedDateTs {
    final d = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return Timestamp.fromDate(d);
  }

  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text("Select Time"),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dateCard(),
            _startTimeCard(),
            _endTimeCard(),
            const SizedBox(height: 10),
            _bookButton(),
            const SizedBox(height: 12),
            _unavailableTimes(),
          ],
        ),
      ),
    );
  }

  /// 📅 DATE
  Widget _dateCard() => _buildCard(
    icon: Icons.calendar_today,
    title: "Date",
    value:
    "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
          startTime = null;
          endTime = null;
        });
      }
    },
  );

  /// ⏰ START
  Widget _startTimeCard() => _buildCard(
    icon: Icons.schedule,
    title: "Start Time",
    value: startTime?.format(context) ?? "Select",
    onTap: () async {
      final picked =
      await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (picked != null) {
        setState(() {
          startTime = picked;
          endTime = null;
        });
      }
    },
  );

  /// ⏱ END
  Widget _endTimeCard() => _buildCard(
    icon: Icons.timelapse,
    title: "End Time (max 2 hrs)",
    value: endTime?.format(context) ?? "Select",
    onTap: startTime == null
        ? null
        : () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: startTime!,
      );
      if (picked != null) {
        final diff =
            toMinutes(picked) - toMinutes(startTime!);
        if (diff <= 0 || diff > 120) {
          _showMsg("Booking must be within 2 hours");
          return;
        }
        setState(() => endTime = picked);
      }
    },
  );

  /// 🔘 BOOK BUTTON
  Widget _bookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: isLoading ? null : _bookFacility,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Confirm Booking",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// 🔥 CORE BOOKING LOGIC
  Future<void> _bookFacility() async {
    if (startTime == null || endTime == null) {
      _showMsg("Select start & end time");
      return;
    }

    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser!;
    final newStart = toMinutes(startTime!);
    final newEnd = toMinutes(endTime!);

    final bookingsRef = FirebaseFirestore.instance.collection('bookings');

    /// 1️⃣ CHECK: USER CAN BOOK ONLY ONCE PER DAY
    final userBookingSnap = await bookingsRef
        .where('facilityId', isEqualTo: widget.facilityId)
        .where('userId', isEqualTo: user.uid)
        .where('date', isEqualTo: selectedDateTs)
        .get();

    if (userBookingSnap.docs.isNotEmpty) {
      setState(() => isLoading = false);
      _showMsg("You already have a booking for this day");
      return;
    }

    /// 2️⃣ CHECK: TIME OVERLAP
    final facilitySnap = await bookingsRef
        .where('facilityId', isEqualTo: widget.facilityId)
        .where('date', isEqualTo: selectedDateTs)
        .get();

    for (var doc in facilitySnap.docs) {
      final existStart = doc['startMin'];
      final existEnd = doc['endMin'];


      if (newStart < existEnd && newEnd > existStart) {
        setState(() => isLoading = false);
        _showMsg("Selected time overlaps with another booking");
        return;
      }
    }
    /// 🚫 PREVENT PAST TIME BOOKING
    final now = DateTime.now();

// If selected date is today
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final today = DateTime(now.year, now.month, now.day);

    if (selected == today) {
      final nowMinutes = now.hour * 60 + now.minute;

      if (newStart <= nowMinutes) {
        setState(() => isLoading = false);
        _showMsg("You cannot book a past time");
        return;
      }
    }


    /// 3️⃣ AUTO-CONFIRM BOOKING
    await bookingsRef.add({
      'facilityId': widget.facilityId,
      'userId': user.uid,
      'date': selectedDateTs,
      'startMin': newStart,
      'endMin': newEnd,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);
    _showMsg("Booking confirmed 🎉");
    Navigator.pop(context);
  }

  /// 🚫 UNAVAILABLE TIMES
  Widget _unavailableTimes() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('facilityId', isEqualTo: widget.facilityId)
            .where('date', isEqualTo: selectedDateTs)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                color: Colors.red.shade100,
                child: ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: Text(
                      "${_fmt(doc['startMin'])} - ${_fmt(doc['endMin'])}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final t = TimeOfDay(hour: h, minute: m);
    return t.format(context);
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(value),
        onTap: onTap,
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}


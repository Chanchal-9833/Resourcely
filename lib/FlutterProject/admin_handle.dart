import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'resourcely_colors.dart';

class AdminHandle extends StatefulWidget {
  const AdminHandle({super.key});

  @override
  State<AdminHandle> createState() => _AdminHandleState();
}

class _AdminHandleState extends State<AdminHandle> {
  String selectedFacility = "turf";
  String? selectedPc;
  DateTime? selectedDate;
  final reasonController = TextEditingController();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> blockDay() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    if (selectedFacility == "pc" && selectedPc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select PC Number")),
      );
      return;
    }

    final normalizedDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    // if (selectedFacility == "pc") {
    //   await pc_blocking();
    // }

    await FirebaseFirestore.instance.collection("BlockedDays").add({
      "facilityId": selectedFacility == "pc" ? selectedPc : selectedFacility,
      "date": Timestamp.fromDate(normalizedDate), // ✅ FIXED
      "reason": reasonController.text.trim().isEmpty
          ? "Unavailable"
          : reasonController.text.trim(),
      "blockedBy": FirebaseAuth.instance.currentUser!.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Facility Blocked Successfully"),
        backgroundColor: Colors.green,
      ),
    );


    setState(() {
      selectedDate = null;
      selectedPc = null;
      reasonController.clear();
    });
  }
  // Future<void> pc_blocking() async {
  //   if (selectedDate == null || selectedPc == null) {
  //     print("Cannot save. Date or PC missing.");
  //     return;
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final pcBlocking = {
  //     "date": selectedDate!.toIso8601String(),
  //     "pcnumber": selectedPc!,
  //     "reason": reasonController.text.trim()
  //   };
  //
  //   String jsonData = jsonEncode(pcBlocking);
  //
  //   await prefs.setString("pc-blocking", jsonData);
  //
  //   print("Saved: $jsonData");
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Facilities",
            style: TextStyle(fontFamily: "Mono",color: Colors.white)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Facility Dropdown
            DropdownButtonFormField(
              value: selectedFacility,
              items: const [
                DropdownMenuItem(value: "turf", child: Text("Turf")),
                DropdownMenuItem(value: "badminton", child: Text("Badminton")),
                DropdownMenuItem(value: "pc", child: Text("PC Room")),
              ],
              onChanged: (val) {
                setState(() {
                  selectedFacility = val!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Facility",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// PC Dropdown (only if PC selected)
            if (selectedFacility == "pc")
              DropdownButtonFormField(
                value: selectedPc,
                items: List.generate(
                  4,
                      (index) => DropdownMenuItem(
                    value: "pc_${index + 1}",
                    child: Text("PC ${index + 1}"),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    selectedPc = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Select PC",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 20),

            /// Date Picker
            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedDate == null
                      ? "Select Date"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Reason
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /// Block Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: blockDay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text(
                  "Block Full Day",
                  style: TextStyle(
                    fontFamily: "Mono",
                    fontSize: 18,
                    color:Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


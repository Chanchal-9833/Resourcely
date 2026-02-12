import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_booking_page.dart';
import 'resourcely_colors.dart';
import 'facility_details_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title:Row( children: [CircleAvatar(
        backgroundImage:AssetImage("Images/Resourcely_logo1.png"),
        radius: 20,
      ),const Text(
          "Resourcely",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
]
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search facilities",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // 🔥 Firestore Facility List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('facilities')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final facilities = snapshot.data!.docs.where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    return name.contains(searchText.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: facilities.length,
                    itemBuilder: (context, index) {
                      final facility = facilities[index];
                      final isAvailable = facility['isAvailable'];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isAvailable
                                ? AppColors.primary
                                : Colors.grey,
                            child: const Icon(
                              Icons.apartment,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            facility['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            isAvailable ? "Available" : "Unavailable",
                            style: TextStyle(
                              color: isAvailable
                                  ? AppColors.primary
                                  : Colors.red,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                          Navigator.push(
                            context,
                              MaterialPageRoute(
                                builder: (_) => FacilityDetailsPage(
                                  facilityId: facility.id, // Firestore document ID
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),


    );
  }
}

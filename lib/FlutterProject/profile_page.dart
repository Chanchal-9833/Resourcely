import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/FlutterProject/SignInPage.dart';
import 'package:flutter_firebase/FlutterProject/SplashPage.dart';
import 'package:intl/intl.dart';
import 'resourcely_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId  = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",style:TextStyle(color: Colors.white,fontFamily: "Mono")),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Profile not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['fullname'] ?? "User";
          final String email = data['email'] ?? "-";
          final Timestamp createdAt = data['SignedUpAt'];

          final String joinedDate =
          DateFormat('dd MM yyyy').format(createdAt.toDate());

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // 👤 Profile Avatar
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF00796B),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 👤 Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // 📧 Email
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 20),

                // 📄 Info Cards
                _infoTile(
                  icon: Icons.calendar_today,
                  title: "Joined On",
                  value: joinedDate,
                ),

                const SizedBox(height: 12),

                _infoTile(
                  icon: Icons.verified_user,
                  title: "Account Type",
                  value: "Student",
                ),

                const Spacer(),

                // 🚪 Logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const Signinpage()),
                            (route) => false,
                      );
                    },

                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00796B)),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter_firebase/FlutterProject/navigationBar.dart";
  

import "SignInPage.dart";
//import "HomePage.dart";

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("Users")
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnap) {

              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnap.hasData || !userSnap.data!.exists) {
                return Signinpage();
              }

              // ✅ SAFE ROLE FETCH
              String role =
                  userSnap.data!.get("role") ?? "Student";

              return BottomNavigation(role: role);
            },
          );
        }

        return  Signinpage();
      },
    );
  }
}


import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_firebase/FlutterProject/HomePage.dart";
import "SignInPage.dart";
import "student_home_page.dart";

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const Homepage(); // student dashboard
        }

        return const Signinpage(); // login screen
      },
    );
  }
}

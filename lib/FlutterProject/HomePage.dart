import "package:flutter/material.dart";

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resourcely",style:TextStyle(fontSize: 20,fontFamily: "Mono",fontWeight: FontWeight.w500),),
        backgroundColor: Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),body: Text("Hello"),
    );
  }
}

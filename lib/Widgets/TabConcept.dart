import "package:flutter/material.dart";

class Tabconcept extends StatefulWidget {
  const Tabconcept({super.key});

  @override
  State<Tabconcept> createState() => _TabconceptState();
}

class _TabconceptState extends State<Tabconcept> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text("Tab Bar"),
          bottom: TabBar(tabs: [
            Tab(child: Text("Turf Booking"),),
            Tab(child: Text("Badminton Court"),),
            Tab(child: Text("Pc Room"),)
          ]),),
        body:TabBarView(children: [
          Center(child: Text("Turf Booking"),),
          Center(child: Text("Badminton Booking"),),
          Center(child: Text("Pc Room Booking"),)
        ])

      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_firebase/FlutterProject/resourcely_colors.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {

  int selectedDays = 7;
  bool isLoading = false;

  int totalBookings = 0;
  int turfBookings = 0;
  int badmintonBookings = 0;
  int pcBookings = 0;

  @override
  void initState() {
    super.initState();
    runArchiveCleanup();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);

    int total = 0;
    int turf = 0;
    int badminton = 0;
    int pc = 0;

    /// 🔹 LIVE Turf & Badminton (main collection only)
    QuerySnapshot bookingSnapshot =
    await FirebaseFirestore.instance.collection("bookings").get();

    for (var doc in bookingSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      total++;

      if (data["facilityId"] == "turf") turf++;
      if (data["facilityId"] == "badminton") badminton++;
    }

    /// 🔹 LIVE PC
    QuerySnapshot pcSnapshot =
    await FirebaseFirestore.instance.collection("PcRoom").get();

    pc = pcSnapshot.docs.length;
    total += pc;

    setState(() {
      totalBookings = total;
      turfBookings = turf;
      badmintonBookings = badminton;
      pcBookings = pc;
      isLoading = false;
    });
  }

  Future<void> runArchiveCleanup() async {
    try {
      /// 🔥 Calculate 3 days ago from today (00:00)
      DateTime now = DateTime.now();

      DateTime threeDaysAgo = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 3));

      Timestamp threeDaysAgoTimestamp =
      Timestamp.fromDate(threeDaysAgo);

      /// 🔹 Archive Facility Bookings
      QuerySnapshot<Map<String, dynamic>> oldBookings =
      await FirebaseFirestore.instance
          .collection("bookings")
          .where("date", isLessThanOrEqualTo: threeDaysAgoTimestamp)
          .get();

      for (var doc in oldBookings.docs) {
        await FirebaseFirestore.instance
            .collection("archive_bookings")
            .doc(doc.id)
            .set(doc.data());

        await doc.reference.delete();
      }

      /// 🔹 Archive PC Room Bookings
      QuerySnapshot<Map<String, dynamic>> oldPc =
      await FirebaseFirestore.instance
          .collection("PcRoom")
          .where("date", isLessThanOrEqualTo: threeDaysAgoTimestamp)
          .get();

      for (var doc in oldPc.docs) {
        await FirebaseFirestore.instance
            .collection("archive_pcroom")
            .doc(doc.id)
            .set(doc.data());

        await doc.reference.delete();
      }

      print("Archive Cleanup Completed (3 day rule using date)");
    } catch (e) {
      print("Archive Error: $e");
    }
  }



  Widget statsCard(
      {required String title,
        required int count,
        required IconData icon}) {

    return LayoutBuilder(
      builder: (context, constraints) {

        double cardWidth = constraints.maxWidth;

        double titleFontSize = cardWidth * 0.08;
        double countFontSize = cardWidth * 0.08;
        double iconSize = cardWidth * 0.20;

        return Card(
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// Icon
                Container(
                  padding: EdgeInsets.all(cardWidth * 0.05),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00796B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: Colors.white,
                      size: iconSize),
                ),

                const SizedBox(height: 10),

                /// Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Mono",
                  ),
                ),

                const SizedBox(height: 6),

                /// Count
                TweenAnimationBuilder(
                  tween: IntTween(begin: 0, end: count),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: countFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00796B),
                        fontFamily: "Mono",
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget buildPieChart() {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: turfBookings.toDouble(),
              color: Colors.green,
              title: "Turf",
            ),
            PieChartSectionData(
              value: badmintonBookings.toDouble(),
              color: Colors.orange,
              title: "Badminton",
            ),
            PieChartSectionData(
              value: pcBookings.toDouble(),
              color: const Color(0xFF00796B),
              title: "PC",
            ),
          ],
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Admin Dashboard",style: TextStyle(fontFamily:"Mono",color: Colors.white),),
        backgroundColor: AppColors.primary,
          centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [




            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,   // max width per card
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {

                final items = [
                  {
                    "title": "Total Bookings",
                    "count": totalBookings,
                    "icon": Icons.analytics,
                  },
                  {
                    "title": "Turf",
                    "count": turfBookings,
                    "icon": Icons.sports_cricket,
                  },
                  {
                    "title": "Badminton",
                    "count": badmintonBookings,
                    "icon": Icons.sports_tennis,
                  },
                  {
                    "title": "PC Room",
                    "count": pcBookings,
                    "icon": Icons.computer,
                  },
                ];

                final item = items[index];

                return statsCard(
                  title: item["title"] as String,
                  count: item["count"] as int,
                  icon: item["icon"] as IconData,
                );
              },
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Booking Distribution",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Mono"),
              ),
            ),

            const SizedBox(height: 10),

            buildPieChart(),


          ],
        ),
      ),
    );
  }
}

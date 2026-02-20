import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_firebase/FlutterProject/resourcely_colors.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  int selectedDays = 7;
  bool isLoading = true;

  Map<String, int> dailyCount = {
    "Mon": 0,
    "Tue": 0,
    "Wed": 0,
    "Thu": 0,
    "Fri": 0,
    "Sat": 0,
    "Sun": 0,
  };

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: selectedDays));

    Map<String, int> weekData = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    // Fetch archive_bookings
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection("archive_bookings")
        .where("date", isGreaterThanOrEqualTo: startDate)
        .get();

    // Fetch archive_pcroom
    QuerySnapshot pcSnapshot = await FirebaseFirestore.instance
        .collection("archive_pcroom")
        .where("date", isGreaterThanOrEqualTo: startDate)
        .get();

    List<QueryDocumentSnapshot> allDocs = [
      ...bookingSnapshot.docs,
      ...pcSnapshot.docs
    ];

    for (var doc in allDocs) {
      var data = doc.data() as Map<String, dynamic>;

      if (data["date"] != null) {
        DateTime date = (data["date"] as Timestamp).toDate();

        String weekday;
        switch (date.weekday) {
          case 1:
            weekday = "Mon";
            break;
          case 2:
            weekday = "Tue";
            break;
          case 3:
            weekday = "Wed";
            break;
          case 4:
            weekday = "Thu";
            break;
          case 5:
            weekday = "Fri";
            break;
          case 6:
            weekday = "Sat";
            break;
          default:
            weekday = "Sun";
        }

        weekData[weekday] = weekData[weekday]! + 1;
      }
    }

    setState(() {
      dailyCount = weekData;
      isLoading = false;
    });
  }

  Widget buildBarChart() {
    final days = dailyCount.keys.toList();
    final values = dailyCount.values.toList();

    double maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxValue < 5) maxValue = 5;

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue + 2,

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= days.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),

          barGroups: List.generate(days.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF26A69A),
                      Color(0xFF004D40),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildFilterButton(int days) {
    return ChoiceChip(
      label: Text("$days Days"),
      selected: selectedDays == days,
      onSelected: (value) {
        setState(() {
          selectedDays = days;
        });
        fetchReports();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalBookings =
    dailyCount.values.fold(0, (previous, current) => previous + current);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports & Analytics",style:TextStyle(color:Colors.white)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
        thumbVisibility: true,
        radius: const Radius.circular(10),
        thickness: 6,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Booking Analytics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildFilterButton(7),
                  buildFilterButton(15),
                  buildFilterButton(30),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF009688), // teal
                      Color(0xFF00BCD4), // cyan
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Bookings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      totalBookings.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              buildBarChart(),

              const SizedBox(height: 40), // extra space for smooth scroll
            ],
          ),
        ),
      ),

    );
  }
}

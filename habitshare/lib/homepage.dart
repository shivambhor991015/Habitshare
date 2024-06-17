import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitshare/datetime.dart' as date_util;
import 'package:habitshare/habits.dart';
import 'colors.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CollectionReference _habitCollection =
      FirebaseFirestore.instance.collection('habits');

  Map<String, int> habitCounts = {};
  Map<String, int> habitTimes = {};

  late ScrollController scrollController;
  List<DateTime> currentMonthList = [];
  DateTime currentDateTime = DateTime.now();
  TextEditingController controller = TextEditingController();

  List<List<String>> habits = [];

  @override
  void initState() {
    super.initState();
    print("Initializing Homepage");
    currentMonthList = date_util.DateUtils.daysInMonth(currentDateTime);
    currentMonthList.sort((a, b) => a.day.compareTo(b.day));
    currentMonthList = currentMonthList.toSet().toList();
    scrollController =
        ScrollController(initialScrollOffset: 70.0 * currentDateTime.day);

    _habitCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((habit) {
        final data = habit.data() as Map<String, dynamic>;
        String habitName =
            data['habitname'] ?? ''; // Get habitname from document
        print("Habit Name: $habitName");
        habitCounts[habitName] = 0; // Use habitname as key in habitCounts
        habitTimes[habitName] = 0; // Use habitname as key in habitTimes
      });
    }).catchError((error) {
      print("Error fetching habits: $error");
    });
  }

  Widget hrizontalCapsuleListView() {
    return Container(
      width: double.infinity,
      height: 120,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: currentMonthList.length,
        itemBuilder: (BuildContext context, int index) {
          return capsuleView(index);
        },
      ),
    );
  }

  Widget capsuleView(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentDateTime = currentMonthList[index];
          });
        },
        child: Container(
          width: 80,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (currentMonthList[index].day != currentDateTime.day)
                  ? [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.6)
                    ]
                  : [
                      HexColor("ED6184"),
                      HexColor("EF315B"),
                      HexColor("E2042D")
                    ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: const [0.0, 0.5, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                offset: Offset(4, 4),
                blurRadius: 4,
                spreadRadius: 2,
                color: Colors.black12,
              )
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentMonthList[index].day.toString(),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: (currentMonthList[index].day != currentDateTime.day)
                        ? HexColor("465876")
                        : Colors.white,
                  ),
                ),
                Text(
                  date_util
                      .DateUtils.weekdays[currentMonthList[index].weekday - 1],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: (currentMonthList[index].day != currentDateTime.day)
                        ? HexColor("465876")
                        : Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building Homepage");
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 35, 126, 136),
        title: const Text(
          "My Habits",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _habitCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // Transform Firestore documents into a list of lists of strings
              List<List<String>> habits = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                // Extract 'habitname' and other data values
                final habitName = data['habitname']?.toString() ?? '';
                final otherData = data.entries
                    .where((entry) => entry.key != 'habitname')
                    .map((entry) => entry.value?.toString() ?? '')
                    .toList();

                // Return a list containing habitName and otherData
                return [habitName, ...otherData];
              }).toList();

              print("Fetched habits: $habits");
              print(habitCounts);
              print(habitTimes);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      hrizontalCapsuleListView(),
                      SizedBox(height: 10),
                      Divider(
                        height: 5,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          String habitId = habits[index][0];
                          return Habittile(
                            index: index,
                            habitCounts: habitCounts[habitId]!,
                            habitTimes: habitTimes[habitId]!,
                            habits: habits,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Text("No data available"),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

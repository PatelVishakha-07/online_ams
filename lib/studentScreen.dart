import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.redAccent[100],
      ),
      drawer: Drawer(
        backgroundColor: Colors.pink[100],
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent[100]),
                child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ CircleAvatar(backgroundColor: Colors.white,radius: 30,),
                SizedBox(height: 10,),
                Text("Student",style: TextStyle(color: Colors.white),),
                Text("Vishakha",style: TextStyle(color: Colors.white),),],))
          ]
        ),
      ),
      backgroundColor: Colors.pink[100],
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: EdgeInsets.all(16),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCard("Percentage", "70", Icons.percent),
                    buildCard("No of Days Present", "110", Icons.check_circle),
                    buildCard("No of Days Absent", "50", Icons.cancel),
                  ],
                ),
                SizedBox(height: 20,),
                buildTodayDate(),
                SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(width: 10,),
                    Expanded(child: buildCalendar(),flex: 1,),
                  ],
                ),
              ],
            )
        ),
      ),
    );
  }

  Widget buildTodayDate(){
    int year=DateTime.now().year;
    var date=DateTime.now();
    String monthName=DateFormat.MMMM().format(date);
    int day=date.day;
    return SizedBox(
      width: 185,
      height: 120,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
              children: [
                Icon(Icons.sunny), SizedBox(width: 10,),
            ],),
              SizedBox(height: 10,),
              Text("Today:\n" + day.toString() + " " + monthName + "\n" + year.toString() )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(String text, String number, IconData icon){
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(number,style: TextStyle(fontSize: 20,),),
                SizedBox(width: 10,), Icon(icon)
              ],
            ),
            SizedBox(height: 10,), Text(text,)
          ],
        ),
      ),
    );
  }

  Widget buildCalendar(){
    int year=DateTime.now().year;
    int month=DateTime.now().month;
    int day=DateTime.now().day;
    return SizedBox(
      width: 400,
      height: 469,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Calendar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(year,month,day), // Use a valid past date
                lastDay: DateTime.utc(2030),
                calendarFormat: CalendarFormat.month,
              )
            ],
          ),
        ),
      ),
    );
  }

}

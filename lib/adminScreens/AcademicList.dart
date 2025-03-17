import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/AcademicSetup.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/adminScreens/adminScreen.dart';

class AcademicYearListScreen extends StatefulWidget {
  const AcademicYearListScreen({super.key});

  @override
  State<AcademicYearListScreen> createState() => _AcademicYearListScreenState();
}

class _AcademicYearListScreenState extends State<AcademicYearListScreen> {

  Future<dynamic>? academicList;

  Future<void> FetchAcademic() async{
      academicList =await Modules.FetchAcademicYearList();
  }

  @override
  void initState() {
    super.initState();
    //FetchAcademic();
    academicList = Modules.FetchAcademicYearList();
  }

  void showAcademicAddDialog() {
    String academicYear = "";
    final TextEditingController academicYearController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> addAcademicYear() async {
      var response = await http.post(
        Uri.parse("$URL/addAcademicYear"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"academic_year": academicYearController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Academic Year Added!")));
        FetchAcademic(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add academic year")));
      }
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Academic Year:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 30,),
              TextFormField(
                controller: academicYearController,
                decoration: InputDecoration(
                  hintText: "2024-2025",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: Icon(Icons.date_range_outlined)
                ),
                validator: (value){
                  if(value!.isEmpty || value == null){
                    return "Enter Academic Year";
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: (){ Navigator.pop(context); }, child: Text("Cancel")),
            TextButton(onPressed: addAcademicYear, child: Text("Add")),
          ],
        )
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Academic Year List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(height: 30,),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            showAcademicAddDialog();
          },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.pink.shade50,
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
                future: academicList,
                builder:(context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                  else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
                  else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No data Found"),);

                  return ListView.builder(
                      itemCount:snapshot.data!.length,
                      itemBuilder: (context,index) {
                        var item=snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Card(
                            color: Colors.blue.shade100,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Icon(Icons.date_range_outlined,color: Colors.redAccent),
                              title: Text(item["academic_year"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                SemesterListScreen(academic_year_id: item["academic_year_id"].toString(),
                                    academic_year: item["academic_year"].toString())));
                              },
                            ),
                          ),
                        );
                      }
                  );
                }
              )
          )
        ],
      ),
    );
  }
}

class SemesterListScreen extends StatefulWidget {
  final String academic_year_id, academic_year;
  const SemesterListScreen({super.key, required this.academic_year_id, required this.academic_year});

  @override
  State<SemesterListScreen> createState() => _SemesterListScreenState();
}

class _SemesterListScreenState extends State<SemesterListScreen> {

  Future<dynamic>? semList;
  void FetchSmester() async{
    semList = await Modules.FetchSemesterList(academicYearId: widget.academic_year.toString());
  }

  @override
  void initState() {
    super.initState();
    FetchSmester();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester List\n    ${widget.academic_year}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(height: 50,),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                AcademicSetupScreen(academic_year: widget.academic_year, academic_year_id: widget.academic_year_id,)));
          },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.pink.shade50,
      body: FutureBuilder(
          future: semList,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
            else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
            else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No data Found"),);

            return ListView.builder(
              itemCount: snapshot.data!.length,
                itemBuilder: (context, index){
                var item = snapshot.data![index];
                  return Padding(
                      padding: EdgeInsets.all(12),
                    child: Card(
                      color: Colors.blue.shade100,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(Icons.date_range_outlined,color: Colors.redAccent),
                        title: Text(item["semester_no"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                      ),
                    ),
                  );
                }
            );
          }
      )
    );
  }
}


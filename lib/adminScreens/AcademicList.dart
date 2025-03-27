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

  @override
  void initState() {
    super.initState();
    academicList = Modules.FetchAcademicYearList();
  }

  void validateAndShowAcademicDialog() {
    int current_month = DateTime.now().month;
    int current_year = DateTime.now().year;
    String expected_year = "$current_year-${current_year + 1}";

    if (current_month == 6) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Academic Year can only be added in June"),
          icon: Icon(Icons.cancel_outlined),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("OK"))
          ],
        ),
      );
      return;
    }
    showAcademicAddDialog(expected_year);
  }

  void showAcademicAddDialog(String expected_year) async{

    bool isAcademicYearAdded = false;
    final TextEditingController academicYearController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> addAcademicYear() async {
      setState(() {
        isAcademicYearAdded = true;
      });
      var response = await http.post(
        Uri.parse("$URL/addAcademicYear"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"academic_year": academicYearController.text}),
      );

      String msg = "";
      var data = jsonDecode(response.body);
      msg = data["message"].toString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        setState(() {
          isAcademicYearAdded = false;
          academicList = Modules.FetchAcademicYearList();
        });
        Navigator.pop(context);
      } else {
        setState(() {
          isAcademicYearAdded = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Form(
            key: formKey,
            child: Column(
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
                    }else if (value != expected_year) {
                      return "Only $expected_year can be added.";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: (){ Navigator.pop(context); }, child: Text("Cancel")),
            TextButton(onPressed:() async{
              setState(() {
                isAcademicYearAdded = true;
              });
              if(formKey.currentState!.validate()){
                await addAcademicYear();
              }
              setState(() {});
            } , child: isAcademicYearAdded ? CircularProgressIndicator() : Text("Add")),
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
            validateAndShowAcademicDialog();
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

  Future<List<dynamic>>? semList;
  void FetchSmester() async{
    semList = Modules.FetchSemesterList(academicYearId: widget.academic_year_id.toString());
    setState(() {});
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
        notchMargin: 8.0,color: Colors.pink.shade50,
        child: Container(height: 50,color: Colors.pink.shade50,),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                AcademicSetupScreen(academic_year: widget.academic_year, academic_year_id: widget.academic_year_id,)));
            setState(() {
              FetchSmester();
            });
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
                        title: Text("Semester: " + item["semester_number"].toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
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


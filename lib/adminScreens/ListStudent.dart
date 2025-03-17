import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/StudentDetails.dart';
import 'package:online_ams/adminScreens/UpdateStudent.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class ListStudentScreen extends StatefulWidget {
  final String stdDepartment, stdYear, stdDivision ;
  const ListStudentScreen({super.key,required this.stdDepartment, required this.stdYear, required this.stdDivision});

  @override
  State<ListStudentScreen> createState() => _ListStudentScreenState();
}

class _ListStudentScreenState extends State<ListStudentScreen> {

  late Future<List<dynamic>> studentList;
  List<dynamic> filteredStudents = [];
  List<dynamic> allStudents = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "", currentAcademicYearId = "";
  Set<int> selectedIndexes={};
  int totalIndex=0;
  
  @override
  void initState() {
    super.initState();
    fetchStudents();
    searchController.addListener((){
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        FilterStudents();
      });
    });
  }

  void fetchStudents() async{
    List<dynamic> students = await Modules.FetchData("Student",dept: widget.stdDepartment,year: widget.stdYear, division: widget.stdDivision);
    setState(() {
      allStudents = students;
      filteredStudents = students;
      totalIndex = students.length;
    });
  }

  void FilterStudents(){
    if(searchQuery.isEmpty){
      filteredStudents = allStudents;
    }else{
      filteredStudents = allStudents.where((student){
        return student["name"].toLowerCase().contains(searchQuery);
      }).toList();
    }
    setState(() {
      totalIndex = filteredStudents.length;
    });
  }

  Future<void> fetchCurentAcademicYear() async{
    final uri = Uri.parse(URL+"/getCurrentAcademicYear");
    final response = await http.post(
        uri,
      headers: {"Content-Type":"application/json"}
    );
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      currentAcademicYearId = data["academic_year_id"].toString() ?? "";
    }
  }

  Future<void> PromoteStudents() async {

    bool isPromote = await showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Promote Students"),
          content: Text("Are you sure you want to promote all the students to the next year?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Promote", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        )
    );

    if (!isPromote) return;

    if (isPromote) {
      final uri = Uri.parse(URL+"/promoteStudents");
      final response = await http.post(
          uri,
          headers: {"Content-Type":"application/json"},
          body: jsonEncode({"department":widget.stdDepartment})
      );
      var msg = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg["message"])));
      fetchCurentAcademicYear();
    }
  }

  String getNextAcademicYear(String currentYear) {
    if (currentYear.contains("-")) {
      List<String> years = currentYear.split("-");
      int startYear = int.parse(years[0]);
      int endYear = int.parse(years[1]);
      return "${startYear + 1}-${endYear + 1}";
    }
    return currentYear;
  }

  String GetNewYear(String currentYear){
    switch(currentYear.toUpperCase()){
      case "FY":
        return "SY";
      case "SY":
        return "TY";
      case "TY":
        return "Passed out";
      default:
        return currentYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("             "+widget.stdYear+widget.stdDepartment+"\nDivision " + widget.stdDivision +" Student List",
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
        actions: selectedIndexes.isNotEmpty?[
          IconButton(
              onPressed: (){
                setState(() {
                  if(selectedIndexes.length == totalIndex){
                    selectedIndexes.clear();
                  }else{
                    selectedIndexes=Set<int>.from(List.generate(totalIndex, (i) => i));
                  }
                });
              },
              icon: Icon(Icons.select_all)
          ),

          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async{
                bool confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Remove Selected Students"),
                        content: Text("Are You Sure You want to remove all Selected students?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context,false),
                              child: Text("Cancel")
                          ),
                          TextButton(
                              onPressed: () => Navigator.pop(context,true),
                              child: Text("Remove",style: TextStyle(color: Colors.red))
                          ),
                        ],
                    )
                );
                if(confirmDelete){
                  for(int index in selectedIndexes){
                    var item = filteredStudents[index];
                    await Modules.DeleteData(context, option: "Student", student_id: item["student_id"].toString());
                  }
                  setState(() {
                    selectedIndexes.clear();
                    fetchStudents();
                  });
                }
              },
          ),
        ]:[
          IconButton(
              onPressed: (){
                PromoteStudents();
              },
              icon: Icon(Icons.upgrade),
            tooltip: "Promote Students",

          )
        ],
      ),
      backgroundColor: Colors.pink.shade50,
      body:Column(
        children: [
          Padding(
              padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Students...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
              child: filteredStudents.isEmpty ? Center(child: Text("No students found")) :
              ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context,index){
                    var item=filteredStudents[index];
                    bool isSelected=selectedIndexes.contains(index);
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: isSelected ? Colors.redAccent.shade100 :Colors.blue.shade100,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.person,color: Colors.redAccent),
                          title: Text(item["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text("Update"),
                                      value: "update",
                                    ),
                                    PopupMenuItem(
                                      child: Text("Remove"),
                                      value: "remove",
                                    )
                                  ],
                                  icon: Icon(Icons.more_vert),
                                  onSelected: (value)async {
                                    if (value == "update") {
                                      Navigator.push(context, MaterialPageRoute(builder:
                                          (context) => UpdateStudentScreen(student_id: item["student_id"])));
                                      }
                                    else if (value == "remove") {
                                      bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                title: Text("Remove Selected Student"),
                                                content: Text("Are You Sure You want to Remove Selected Student?"),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                                                  TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: Text("Remove", style: TextStyle(color: Colors.red))
                                                  ),
                                                ],
                                              )
                                      );
                                      if (confirmDelete) {
                                        await Modules.DeleteData(context, option: "Student", student_id: item["student_id"].toString());
                                        setState(() {
                                          fetchStudents();
                                        });
                                      }
                                    }
                                  })
                            ],
                          ),
                          onTap: (){
                            if(selectedIndexes.isNotEmpty) {
                              setState(() {
                                if(isSelected){
                                  selectedIndexes.remove(index);
                                }else{
                                  selectedIndexes.add(index);
                                }
                              });
                            }else{
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => StudentDetailScreen(student_id: item["student_id"]),),);
                            }},
                          onLongPress: (){
                            setState(() {
                              selectedIndexes.add(index);
                            });},
                        ),
                      ),
                    );
                  })
          )
        ],
      )
    );
  }
}



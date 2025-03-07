import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/ListFaculty.dart';
import 'package:online_ams/adminScreens/ListStudent.dart';
import 'package:online_ams/adminScreens/ListSubject.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'ListStudent.dart' as lstd;

class ListScreen extends StatefulWidget {
  final String option;
  const ListScreen({super.key, required this.option});

  @override
  State<ListScreen> createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Department List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        backgroundColor: Colors.pink.shade50,
        centerTitle: true,
      ),
      backgroundColor: Colors.pink.shade50,
      body: DepartmentListScreen(option: widget.option,)
    );
  }
}

class DepartmentListScreen extends StatefulWidget {
  final String option;
  const DepartmentListScreen({super.key, required this.option});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  final List<String> dept =["BCA","BBA","BCOM","BSC"];

  @override
  Widget build(BuildContext context) {
    print("Building DepartmentListScreen");
    return ListView.builder(
      itemBuilder: (context,index){
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            color: Colors.blue.shade100,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(Icons.school,color: Colors.redAccent,),
              title: Text(dept[index],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: (){
                if(widget.option == "Faculty"){
                  Navigator.push(context,MaterialPageRoute(
                      builder: (context) => FacultyListScreen(facultyDepartment: dept[index])));
                }
                else if(widget.option == "Subject"){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>
                      YearScreen(department: dept[index])));
                } else{
                  Navigator.push(context,MaterialPageRoute(
                      builder: (context) => Class_DivisionListScreen(department: dept[index],option: widget.option,deptList: dept,)));
                }
              },
            ),
          ),
        );
      },
      itemCount: dept.length,
    );
  }
}

class Class_DivisionListScreen extends StatefulWidget {
  final String department,option;
  final List<String> deptList;
  Class_DivisionListScreen({ required this.department, required this.option, required this.deptList});
  @override
  State<Class_DivisionListScreen> createState() => _Class_DivisionListScreenState();
}
class _Class_DivisionListScreenState extends State<Class_DivisionListScreen> {

  late Future<List<dynamic>> classData;
  int totalSelected=0;
  Set<int> selectedIndexes={};

  @override
  void initState() {
    super.initState();
    classData = Modules.FetchData("Class", dept: widget.department);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedIndexes.isNotEmpty ? Text("${selectedIndexes.length} Selected"):
        Text("${widget.department} Department",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),

        centerTitle: true,
        backgroundColor: Colors.pink.shade50,
        actions: selectedIndexes.isNotEmpty ? [
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: (){
              setState(() {
                if(selectedIndexes.length == totalSelected){
                  selectedIndexes.clear();
                }else{
                  selectedIndexes=Set<int>.from(List.generate(totalSelected, (i) => i));
                }
              });
            },
          )
        ]:[],
      ),
      backgroundColor: Colors.pink.shade50,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: classData,
              builder: (context, snapshot){

                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }else if(snapshot.hasError){
                  return Center(child: Text("Error: ${snapshot.error}"),);
                }else if(!snapshot.hasData || snapshot.data!.isEmpty){
                  return Center(child: Text("No data Found"),);
                }
                totalSelected=snapshot.data!.length;

                return ListView.builder(
                  itemBuilder: (context,index){
                    var item = snapshot.data![index];
                    bool isSelected=selectedIndexes.contains(index);
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: isSelected ? Colors.redAccent.shade100 :Colors.blue.shade100,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.school,color: Colors.redAccent,),
                          title: Text(item["year"] + widget.department,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                          subtitle: Text("Division "+item["division"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if(widget.option == "Class")...[
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: "update",
                                        child: Text("Update"),
                                      ),
                                      PopupMenuItem(
                                        value: "delete",
                                        child: Text("Delete"),
                                      ),
                                    ],
                                    onSelected: (value){
                                      if(value == "update"){
                                        showClassAlertDialog(context, widget.department, "Update Class", "Update",
                                            oldYear: item["year"],oldDiv: item["division"]);
                                      }
                                      else if(value == "delete"){
                                        Modules.DeleteData(context, option: "Class", class_id: item["class_id"].toString(), division_id: item["division_id"].toString());
                                        setState(() {});
                                      }
                                    },
                                  )
                                ] else ... [
                                  Icon(Icons.arrow_forward_ios)
                                ]
                              ]
                          ),
                          onTap: (){
                            if(selectedIndexes.isNotEmpty){
                              setState(() {
                                if(isSelected){
                                  selectedIndexes.remove(index);
                                }else{
                                  selectedIndexes.add(index);
                                }
                              });
                            }
                            else if(widget.option == "Student") {
                             Navigator.push(context, MaterialPageRoute(builder: (context)=>
                             ListStudentScreen(stdDepartment: widget.department, stdYear: item["year"], stdDivision: item["division"])));
                            }
                          },
                          onLongPress: (){
                            if(widget.option == "Class"){
                              setState(() {
                                selectedIndexes.add(index);
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: totalSelected,
                );
              }
            ),
          ),
        ],
      ),
        floatingActionButton: widget.option == "Class" ?
        Padding(
          padding: const EdgeInsets.only(left: 320,bottom: 25),
          child: FloatingActionButton(
            onPressed: (){
              showClassAlertDialog(context,widget.department,"Create Class","Create");
              setState(() {
                classData = Modules.FetchData("Class", dept: widget.department);
              });
            },
            child: Icon(Icons.add,size: 40,),
            elevation: 3,
            backgroundColor: Colors.blue[100],
            tooltip: "Click to Create Class",
          ),
        ) : null,
    );
  }
}

void showClassAlertDialog(BuildContext context, String dept, String titleText, String actionText, {String oldYear="",String oldDiv=""}) {
  String? selectedClass;
  String? selectedDivision;
  List<String> year=["FY","SY","TY"];
  List<String> division=["1","2","3"];

  if(titleText == "Update Class"){
    selectedClass=oldYear;
    selectedDivision=oldDiv;
  }

  Future<void> sendDataToAPI(String choice) async{
    if(selectedClass == null ||  selectedDivision == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Select all fields")));
      return;
    }
    String api="";
    if(choice == "Update Class"){
      api="/updateClassDivision";
    }
    else if(choice == "Create Class"){
      api="/addClassDivision";
    }
    final uri= Uri.parse("$URL$api");
    final response=await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "department": dept,
        "year":selectedClass,
        "division":selectedDivision
      }),
    );

    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Class Created Successfully")));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Create Class")));
    }
  }

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState){
              return AlertDialog(
                backgroundColor: Colors.blue.shade50,
                elevation: 4,
                icon: Icon(Icons.create),
                title: Text(titleText,),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text("Department: "+dept),
                    SizedBox(height: 20,),

                    DropdownButtonFormField(
                      value: selectedClass,
                      decoration: InputDecoration(labelText: "Select Year"),
                      items: year.toSet().map((classNames) {
                        return DropdownMenuItem(
                          child: Text(classNames),
                          value: classNames,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value;
                        });
                      },
                    ),
                    SizedBox(height: 20,),

                    DropdownButtonFormField(
                        decoration: InputDecoration(labelText: "Select Division"),
                        value: selectedDivision,
                        items: division.toSet().map((divisionValue) {
                          return DropdownMenuItem(
                            child: Text(divisionValue),
                            value: divisionValue,);
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDivision = value;
                          });
                        }
                    ),
                  ],
                ),

                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if(titleText == "Create Class"){
                          sendDataToAPI(titleText);
                          Navigator.pop(context);
                        }else if( titleText == "Update Class"){
                          UpdateClassDivsion(context, dept, selectedClass, selectedDivision, oldYear, oldDiv);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(actionText)
                  )
                ],
              );
            }
        );
      }
  );
}

Future<void> UpdateClassDivsion(BuildContext context, String dept,String? year, String? division, String oldYear, String oldDiv) async{
  final uri=Uri.parse(URL+"/updateClassData");
  final response=await http.post(
    uri,
    headers: {"Content-Type":"application/json"},
    body: jsonEncode({
        "year":year,
        "division":division,
        "department":dept,
        "old_year":oldYear,
        "old_division":oldDiv
      })
  );
  if (!context.mounted) return;
  if(response.statusCode == 200){
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record Updated Successfully")));
  }else{
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to Update Record")));
  }
}



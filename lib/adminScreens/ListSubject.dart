import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class SubjectListScreen extends StatefulWidget {
  final String subjectDepartment, subjectYear, role;
  final int faculty_id;
  const SubjectListScreen({super.key, required this.subjectDepartment, required this.subjectYear, required this.faculty_id,
  required this.role});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {

  late Future<List<dynamic>> subjectList;
  Set<int> selectedIndexes={};
  int totalIndex=0;

  @override
  void initState() {
    super.initState();
    subjectList=Modules.FetchSubjectList(role: widget.role, dept: widget.subjectDepartment,year: widget.subjectYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectYear+widget.subjectDepartment + " Subject List",
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
          )
        ]:[],
      ),
        backgroundColor: Colors.pink.shade50,
        body:Column(
          children: [
            Expanded(
                child: FutureBuilder(
                    future: subjectList,
                    builder: (context,snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                      else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
                      else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No data Found"),);

                      totalIndex=snapshot.data!.length;
                      return ListView.builder(
                          itemCount: totalIndex,
                          itemBuilder: (context,index){
                            var item=snapshot.data![index];
                            bool isSelected=selectedIndexes.contains(index);
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Card(
                                color: Colors.blue.shade100,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  leading: Icon(Icons.subject_outlined,color: Colors.redAccent),
                                  title: Text(item["sub_name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
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
                                            child: Text("Delete"),
                                            value: "delete",
                                          )
                                        ],
                                        icon: Icon(Icons.more_vert),
                                        onSelected: (value)=>{
                                          if(value == "update"){}
                                          else if(value == "Delete"){}
                                        },
                                      )
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
                                    }
                                  },
                                  onLongPress: (){
                                    selectedIndexes.add(index);
                                  },
                                ),
                              ),
                            );
                          });
                    }
                )
            )
          ],
        )

    );
  }
}

class YearScreen extends StatefulWidget {
  final String department;
  const YearScreen({super.key, required this.department});

  @override
  State<YearScreen> createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {

  Future<List<dynamic>>? yearList;

  Future<void> FetchYearList() async {
    final uri = Uri.parse(URL + "/fetchYearNameId");
    final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"department": widget.department})
    );
    if (response.statusCode == 200) {
      setState(() {
        yearList = Future.value(jsonDecode(response.body));
      });
    } else {
      setState(() {
        yearList = [] as Future<List>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch faculty list")),);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    yearList = Modules.FetchYear(widget.department);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Year List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        backgroundColor: Colors.pink.shade50,
        centerTitle: true,
      ),
      backgroundColor: Colors.pink.shade50,
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
                  future: yearList,
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                    else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
                    else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No data Found"),);

                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context,index){
                          var item=snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Card(
                              color: Colors.blue.shade100,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: Icon(Icons.person,color: Colors.redAccent),
                                title: Text(item["year"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  SubjectListScreen(subjectDepartment: widget.department, subjectYear: item["year"],
                                    faculty_id: 0 , role: "Admin",)));
                                },
                              ),
                            ),
                          );
                        });
                  }
              )
          )
        ],
      ),
    );
  }
}


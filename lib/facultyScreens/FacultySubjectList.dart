import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;
import 'package:online_ams/facultyScreens/SubjectDetails.dart';

class FacultySubjectList extends StatefulWidget {
  final int faculty_id;
  const FacultySubjectList({super.key, required this.faculty_id});

  @override
  State<FacultySubjectList> createState() => _FacultySubjectListState();
}

class _FacultySubjectListState extends State<FacultySubjectList> {
  
  late Future<List<dynamic>> facultySubjectList;
  
  Future<List<dynamic>> FetchSubjectList() async{
    final uri = Uri.parse(URL + "/fetchSubject");
    final response = await http.post(
        uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "faculty_id": widget.faculty_id,
        "role": "Faculty"
      })
    );
    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      throw Exception("Failed to load subjects");
    }
  }
  
  @override
  void initState() {
    super.initState();
    facultySubjectList = FetchSubjectList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subjects You Teach",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25, color: Colors.black87)),
        centerTitle: true, 
        backgroundColor: Colors.pink.shade50,
        actions: [
          IconButton(
              onPressed: (){
                facultySubjectList = FetchSubjectList();
                setState(() {});
                },
              icon: Icon(Icons.refresh_outlined, color: Colors.black87))
        ],
      ), 
      backgroundColor: Colors.pink.shade50,
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
                  future: facultySubjectList, 
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                    else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
                    else if(snapshot.data!.isEmpty || !snapshot.hasData) return Center(child: Text("No Subject Found"),);
                    
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                        itemBuilder:(context, index) {
                          var subjects = snapshot.data![index];
                          return Padding(
                              padding: EdgeInsets.all(16),
                            child: Card(
                              color: Colors.blue.shade100,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Text(subjects["sub_name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                                leading: Icon(Icons.subject_outlined, color: Colors.redAccent,),
                                subtitle: Text("Code: ${subjects["sub_code"].toString()}"),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  SubjectDetailScreen(sub_id: subjects["subject_id"].toString(), subName: subjects["sub_name"])));
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
      )
    );
  }
}

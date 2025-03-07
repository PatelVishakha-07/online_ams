import 'package:flutter/material.dart';
import 'package:online_ams/Modules.dart';
import 'package:online_ams/adminScreens/FacultyDetails.dart';
import 'package:online_ams/adminScreens/UpdateFaculty.dart';
import 'ListStudent.dart' as lstd;

class FacultyListScreen extends StatefulWidget {
  final String facultyDepartment;
  const FacultyListScreen({super.key, required this.facultyDepartment});

  @override
  State<FacultyListScreen> createState() => _FacultyListScreenState();
}

class _FacultyListScreenState extends State<FacultyListScreen> {

  late Future<List<dynamic>> facultyList;
  List<dynamic> filteredFaculty = [], allFaculty = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  Set<int> selectedIndexes={};
  int totalIndex=0;

 @override
  void initState() {
    super.initState();
    FetchFaculty();
    searchController.addListener((){
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        FilterFaculty();
      });
    });
  }

  void FetchFaculty() async{
    List<dynamic> faculty = await Modules.FetchData("Faculty", dept: widget.facultyDepartment);
    setState(() {
      allFaculty = faculty;
      filteredFaculty = faculty;
      totalIndex = faculty.length;
    });
  }

  void FilterFaculty(){
    if(searchQuery.isEmpty){
      filteredFaculty = allFaculty;
    }else{
      filteredFaculty = allFaculty.where((faculty){
        return faculty["faculty_name"].toLowerCase().contains(searchQuery);
      }).toList();
    }
    setState(() {
      totalIndex = filteredFaculty.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facultyDepartment+" Department \n    Faculty List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
            centerTitle: true,
            backgroundColor: Colors.pink.shade50,
        actions: selectedIndexes.isNotEmpty ? [
          IconButton(
              icon: Icon(Icons.delete,color: Colors.red,),
              onPressed: () async{
                bool confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete Selected Items"),
                      content: Text("Are You Sure You want to delete all Selected Items?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context,false),
                            child: Text("Cancel")
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context,true),
                            child: Text("Delete",style: TextStyle(color: Colors.red))
                        ),
                      ],
                    )
                );
                if(confirmDelete){
                  for(int index in selectedIndexes){
                    var item = filteredFaculty[index];
                    await Modules.DeleteData(context,option: "Faculty", faculty_id: item["faculty_id"]);
                  }
                  setState(() {
                    selectedIndexes.clear();
                    FetchFaculty();
                  });
                }
              },
          ),
          IconButton(
            icon: Icon(Icons.select_all_outlined, color: Colors.blue,),
            onPressed: () async{
              List<dynamic> facultyData = await facultyList;
              setState((){
                if (selectedIndexes.length == facultyData.length) {
                  selectedIndexes.clear(); // Deselect all
                } else {
                  selectedIndexes = Set<int>.from(List.generate(facultyData.length, (i) => i)); // Select all
                }
              });
            },
          )
        ]:[],
      ),
      backgroundColor: Colors.pink.shade50,
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Faculty...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
              child: filteredFaculty.isEmpty ? Center(child: Text("No students found")) :
              ListView.builder(
                  itemCount: filteredFaculty.length,
                  itemBuilder: (context,index){
                    var item=filteredFaculty[index];
                    bool isSelected=selectedIndexes.contains(index);
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: isSelected ? Colors.redAccent.shade100 :Colors.blue.shade100,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.person,color: Colors.redAccent),
                          title: Text(item["faculty_name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Text("Update"),
                                    value: "update",
                                  ),
                                  PopupMenuItem(
                                    child: Text("Delete"),
                                    value: "delete",
                                  ),
                                ],
                                onSelected: (value) async{
                                  if(value == "update"){
                                    if(!context.mounted) return;
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        UpdateFacultyScreen(faculty_id: item["faculty_id"],)));

                                    setState(() {
                                      facultyList = Modules.FetchData("Faculty", dept: widget.facultyDepartment);
                                    });
                                  }
                                  else if(value == "delete"){
                                    bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AlertDialog(
                                              title: Text("Delete Selected Faculty"),
                                              content: Text("Are You Sure You want to delete the Selected Faculty?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text("Cancel")
                                                ),
                                                TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: Text("Delete", style: TextStyle(color: Colors.red))
                                                ),
                                              ],
                                            )
                                    );
                                    if (confirmDelete) {
                                      List<dynamic> facultyData = await facultyList;
                                      for (int index in selectedIndexes) {
                                        var item = facultyData[index];
                                        await Modules.DeleteData(context, option: "Faculty", faculty_id: item["faculty_id"].toString());
                                      }
                                      setState(() {
                                        selectedIndexes.clear();
                                        FetchFaculty();
                                      });
                                    }
                                  }},
                              )
                            ],
                          ),
                          onTap: (){
                            if(selectedIndexes.isNotEmpty){
                              setState(() {
                                if(isSelected){
                                  selectedIndexes.remove(index);
                                  return;
                                }else{
                                  selectedIndexes.add(index);
                                  return;
                                }
                              });
                            }
                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  FacultyDetailScreen(faculty_id: item["faculty_id"])));
                            }
                            },
                          onLongPress: (){
                            setState(() {
                              selectedIndexes.add(index);
                            });
                            },
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

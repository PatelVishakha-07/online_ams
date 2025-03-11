import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_ams/adminScreens/adminScreen.dart';
import 'package:http/http.dart' as http;

class PasswordListScreen extends StatefulWidget {
  final String role;
  const PasswordListScreen({super.key, required this.role});

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {

  late Future<dynamic> passList;
  List<dynamic> filteredUsername = [], allUsername = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  int totalIndex=0;
  bool isLoading = true;

  Future<List<dynamic>> FetchPasswordList() async{
    final uri = Uri.parse(URL+"/fetchPassword");
    final response = await http.post(
      uri,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({"role":widget.role})
    );
    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        allUsername = data;
        filteredUsername = allUsername;
        isLoading = false;
      });
      return data;
    }else{
      setState(() {
        isLoading = false; // Stop loading if there's an error
      });
      return throw Exception("Failed to Load Password List");
    }
  }

  void FilterUsername(){
    if(searchQuery.isEmpty){
      filteredUsername = allUsername;
    }else{
      filteredUsername = allUsername.where((username){
        return username["username"].toLowerCase().contains(searchQuery);
      }).toList();
    }
    setState(() {
      totalIndex = filteredUsername.length;
    });
  }


  @override
  void initState() {
    super.initState();
    passList = FetchPasswordList();
    searchController.addListener((){
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        FilterUsername();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
      ),
        backgroundColor: Colors.pink[50],
      body:  isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Username...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: filteredUsername.isEmpty ? Center(child: Text("No students found")) :
            FutureBuilder(
              future: passList,
              builder: (context,snapshot){

                if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
                else if(snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"),);
                else if(!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No data Found"),);

                return ListView.builder(
                    itemCount: filteredUsername.length,
                    itemBuilder: (context,index){
                      var item = filteredUsername[index];
                      return Padding(
                        padding: EdgeInsets.all(12),
                        child: Card(
                          color: Colors.blue.shade100,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text("Username: " + item["username"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                            subtitle:  Text("Password: " + item["password"].toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                          ),
                        ),
                      );
                    }
                );
              }
            ),
          ),
        ],
      )
    );
  }
}

class UsernameRoleScreen extends StatefulWidget {
  const UsernameRoleScreen({super.key});

  @override
  State<UsernameRoleScreen> createState() => _UsernameRoleScreenState();
}

class _UsernameRoleScreenState extends State<UsernameRoleScreen> {
  
  List<String> roleList = ["Admin", "Faculty", "Student"];
  String? selectedRole;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Password List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),), 
          centerTitle: true, 
          backgroundColor: Colors.pink[50],
        ),
      backgroundColor: Colors.pink[50],
      body: ListView.builder(
        itemCount: roleList.length,
          itemBuilder: (context,index){
          return Padding(
              padding: EdgeInsets.all(12),
            child: Card(
              color: Colors.blue.shade100,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined),
                title: Text(roleList[index],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordListScreen(role: roleList[index])));
                },
              ),
            ),
          );
      }),
    );
  }
}


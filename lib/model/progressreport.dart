import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressReport extends StatefulWidget {
  String id;

  ProgressReport(this.id, {super.key});

  @override
  State<ProgressReport> createState() => _ProgressReportState();
}

class _ProgressReportState extends State<ProgressReport> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green.shade600,
      ),
      home: MyApp(widget.id),
    );
  }
}

class MyApp extends StatefulWidget {
  String id;
  MyApp(this.id);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> expenselist = [];
  final db = FirebaseFirestore.instance;
  String inbuget = "In Budget";
  String outbuget = "Out Of Budget";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: db.collection('budget').doc(widget.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("");
          }
          var userDetails = snapshot.data;
          expenselist = userDetails?['expenses'];

          return Scaffold(
            appBar: AppBar(
              title: Text("Your BUDGET GOAL - RS.${userDetails?['budgetgoal'].toString()}"),
              backgroundColor: Colors.green.shade800,
              centerTitle: true,
            ),
            body: ListView.builder(
                itemCount: userDetails?['currbudget'].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.green.shade100,
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      tileColor: userDetails!['currbudget'][index] >= 0 ? Colors.green.shade100 : Colors.red.shade200,
                      title: Row(
                        children: [
                          Text(
                            "-Rs. ${userDetails!['expenses'][index].toString()}",
                            style: TextStyle(
                              color: userDetails!['currbudget'][index] >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        userDetails!['currbudget'][index] >= 0 ? inbuget:outbuget,
                        style: TextStyle(
                          color: userDetails!['currbudget'][index] >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // subtitle: Text(
                      //
                      // ),
                    ),
                  );
                }
            ),
          );
        }
    );
  }


}

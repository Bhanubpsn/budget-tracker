import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetHistory extends StatefulWidget {
  String id;

  BudgetHistory(this.id, {super.key});

  @override
  State<BudgetHistory> createState() => _BudgetHistoryState();
}

class _BudgetHistoryState extends State<BudgetHistory> {
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
  // List historylist = [];

  double input = 0;
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: db.collection('budget').doc(widget.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("");
          }
          var userDetails = snapshot.data;
          // historylist = userDetails?['history'];

          return Scaffold(
            appBar: AppBar(
              title: const Text("Your History"),
              backgroundColor: Colors.green.shade800,
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.red,
              splashColor: Colors.blue,
              child: const Icon(Icons.delete),
              onPressed: (){
                setState(() {
                  db.collection('budget').doc(widget.id).update({'history' : []});
                });
              },
            ),
            body: ListView.builder(
                itemCount: userDetails?['history'].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.green.shade100,
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      tileColor: userDetails!['history'][index][0] == '+'? Colors.green.shade100 : Colors.red.shade200,
                      title: Row(
                        children: [
                          Text(
                            userDetails!['history'][index],
                            style: TextStyle(
                              color: userDetails!['history'][index][0] == '+'? Colors.green.shade700 : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // subtitle: Text(
                      //     DateFormat('yyyy-MM-dd – kk:mm').format(userDetails?['dateaddedincome'][index]).toString(),
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

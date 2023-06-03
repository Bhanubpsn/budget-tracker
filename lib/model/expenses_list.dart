// import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../util/notification_service.dart';

class ExpensesList extends StatefulWidget {
  String id;

  ExpensesList(this.id, {super.key});

  @override
  State<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
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
  List historylist = [];
  List currbugetgoallist = [];
  List datelist = [];
  double input = 0;
  final db = FirebaseFirestore.instance;
  String formatteddate = "";

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
          historylist = userDetails?['history'];
          currbugetgoallist = userDetails?['currbudget'];
          datelist = userDetails?['dateaddedexpense'];

          return Scaffold(
            appBar: AppBar(
              title: const Text("Your Expenses"),
              backgroundColor: Colors.green.shade800,
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.lightGreen,
              splashColor: Colors.blue,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        title: const Text("Add an Expense"),
                        content: TextField(
                          keyboardType:const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.green.shade400),
                          decoration:InputDecoration(
                            prefixText: "Rs. ",
                            prefixIcon: Icon(Icons.wallet, color: Colors.green.shade400,),
                          ),
                          onChanged: (String value){
                            try{
                              setState(() {
                                input = double.parse(value);
                                print(input);
                              });
                            }catch(exception){
                              const snackBar = SnackBar(content: Text("Please enter valid expense"),
                                backgroundColor: Colors.red,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              DateTime now = DateTime.now();
                              setState(() {
                                formatteddate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
                                expenselist.add(input);
                                datelist.add(DateTime.now());
                                historylist.add("-Rs ${input.toString()}");
                                if(currbugetgoallist.isEmpty){
                                  currbugetgoallist.add(userDetails?['budgetgoal'] - input);
                                }
                                else{
                                  currbugetgoallist.add(currbugetgoallist[currbugetgoallist.length - 1] - input);
                                }
                                db.collection('budget').doc(widget.id).update({
                                  'expenses' : expenselist,
                                  'history' : historylist,
                                  'currbudget' : currbugetgoallist,
                                  'dateaddedexpense' : datelist,
                                });

                                input = 0;
                              });
                              if(userDetails?['budgetreminder'] == true){
                                double temp= 0;
                                for(int i =0; i<expenselist.length; i++){
                                  temp += expenselist[i];
                                }
                                if(temp > userDetails?['budgetgoal']){
                                  NotificationService().showNotificationWater(0, 'Reminder!', 'Out of BUDGET');
                                }
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text("Add"),
                          )
                        ],

                      );
                    }
                );
              },
              child: Icon(Icons.add, color: Colors.green.shade900,),
            ),
            body: ListView.builder(
                itemCount: userDetails?['expenses'].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.green.shade100,
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            "-Rs. ${userDetails!['expenses'][index].toString()}",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: ()async{
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        contentPadding:const EdgeInsets.all(10),
                                        title: const Text("Update Expense"),
                                        content: TextField(
                                          keyboardType:const TextInputType.numberWithOptions(decimal: true),
                                          style: TextStyle(color: Colors.green.shade400),
                                          decoration:InputDecoration(
                                            prefixText: "Rs. ",
                                            prefixIcon: Icon(Icons.wallet, color: Colors.green.shade400,),
                                          ),
                                          onChanged: (String value){
                                            try{
                                              setState(() {
                                                input = double.parse(value);
                                              });
                                            }catch(exception){
                                              const snackBar = SnackBar(content: Text("Please enter valid expense"),
                                                backgroundColor: Colors.red,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          },
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if(input != 0){
                                                setState(() {
                                                  expenselist[index] = input;
                                                  historylist[index] = "-Rs ${input.toString()}";
                                                  if(index == 0){
                                                    currbugetgoallist[0] = userDetails?['budgetgoal'] - input;
                                                  }
                                                  else{
                                                    currbugetgoallist[index] = currbugetgoallist[index-1] - input;
                                                  }
                                                  db.collection('budget').doc(widget.id).update({
                                                    'expenses' : expenselist,
                                                    'history' : historylist,
                                                    'currbudget' : currbugetgoallist,
                                                  });
                                                  input = 0;

                                                });
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green
                                            ),
                                            child: const Text("Update"),

                                          )
                                        ],
                                      );
                                    }
                                );
                              },
                              icon: Icon(Icons.edit,color: Colors.green.shade700,)
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.green.shade700,),
                            onPressed: () {
                              double temp = expenselist[index];
                              setState(() {
                                expenselist.removeAt(index);
                                historylist.removeAt(index);
                                currbugetgoallist.removeAt(index);
                                datelist.removeAt(index);
                                for(int i = index; i < currbugetgoallist.length; i++){
                                  currbugetgoallist[i] += temp;
                                }
                                db.collection('budget').doc(widget.id).update({
                                  'expenses' : expenselist,
                                  'history' : historylist,
                                  'currbudget' : currbugetgoallist,
                                  'dateaddedexpense' : datelist,
                                });
                              });
                            },
                          ),
                        ],
                      ),
                      subtitle: Text(
                        formatteddate,
                      ),
                    ),
                  );
                }
            ),
          );
        }
    );
  }


}

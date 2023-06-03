import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class IncomeList extends StatefulWidget {
  String id;

  IncomeList(this.id, {super.key});

  @override
  State<IncomeList> createState() => _IncomeListState();
}

class _IncomeListState extends State<IncomeList> {
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
  List<dynamic> incomelist = [];
  List historylist = [];
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
          incomelist = userDetails?['income'];
          historylist = userDetails?['history'];
          datelist = userDetails?['dateaddedincome'];

          return Scaffold(
            appBar: AppBar(
              title: const Text("Your Income"),
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
                        title: const Text("Add an Income"),
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
                              const snackBar = SnackBar(content: Text("Please enter valid income"),
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
                                incomelist.add(input);
                                historylist.add("+Rs ${input.toString()}");
                                datelist.add(DateTime.now());
                                db.collection('budget').doc(widget.id).update({
                                  'income' : incomelist,
                                  'history' : historylist,
                                  'dateaddedincome' : datelist,
                                });
                                input = 0;
                              });
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
                itemCount: userDetails?['income'].length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(key: Key(incomelist[index].toString()), child: Card(
                    color: Colors.green.shade100,
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            "+Rs. ${userDetails!['income'][index].toString()}",
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
                                        title: const Text("Update Income"),
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
                                              const snackBar = SnackBar(content: Text("Please enter valid income"),
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
                                                  incomelist[index] = input;
                                                  historylist[index] = "+Rs ${input.toString()}";
                                                  db.collection('budget').doc(widget.id).update({
                                                    'income' : incomelist,
                                                    'history' : historylist,
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
                              setState(() {
                                incomelist.removeAt(index);
                                historylist.removeAt(index);
                                datelist.removeAt(index);
                                db.collection('budget').doc(widget.id).update({
                                  'income' : incomelist,
                                  'history' : historylist,
                                  'dateaddedincome' : datelist,
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
                  ),
                    onDismissed: (direction){
                      incomelist.removeAt(index);
                      datelist.removeAt(index);
                      setState(() {
                        db.collection('budget').doc(widget.id).update({
                          'income' : incomelist,
                          'dateaddedincome' : datelist,
                        });
                      });
                    },
                  );
                }
            ),
          );
        }
    );
  }


}

import 'package:budget_tracker/model/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/budgethistory.dart';
import '../model/progressreport.dart';
import '../model/expenses_list.dart';
import '../model/income_list.dart';
import '../splash screen/register_new_user.dart';
import '../util/hexcolor.dart';
import '../util/notification_service.dart';

class homepage extends StatefulWidget {
  String photoUrl;
  String id;
  String name;
  String email;

  homepage(this.photoUrl,this.name,this.id,this.email);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  final db = FirebaseFirestore.instance;
  double budget_goal = 0;
  bool reminder = false;
  List expenseslist = [];

  @override
  Widget build(BuildContext context) {

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return HexColor("#8B1874");
    }
    
    
    

    return StreamBuilder(
        stream: db.collection('budget').doc(widget.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("");
          }
          var userDetails = snapshot.data;
          budget_goal = userDetails?['budgetgoal'];
          reminder = userDetails?['budgetreminder'];
          expenseslist = userDetails?['expenses'];

          return Scaffold(
            resizeToAvoidBottomInset : false,
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      image: DecorationImage(
                        image: AssetImage('images/icon-512.png',),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(50.0)),
                      image: DecorationImage(
                        image: NetworkImage(widget.photoUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      print("Pressed");
                      logout();
                      Future.delayed(const Duration(seconds: 1), () {
                        googleLogin();
                      });
                    },
                    icon: Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: HexColor("#8B1874"),
                    ),

                  ),
                ],
              ),
              backgroundColor: Colors.white70,
            ),
            body: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 15, left: 8, right: 8, bottom: 15),
                  height: 160,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  decoration: BoxDecoration(
                    color: HexColor("#8B1874"),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.1, 1.0),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Hi         ",
                              style: TextStyle(
                                color : Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color : Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8, right: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          ExpensesList(widget.id)));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent.withOpacity(0.4),
                                ),
                                child: const Text("EXPENSES")
                            ),
                            const SizedBox(height: 15,),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          IncomeList(widget.id)));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent.withOpacity(0.4),
                                ),
                                child: const Text("INCOMES")
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      height: 200,
                      width: (MediaQuery.of(context).size.width / 2 - 12),
                      decoration: BoxDecoration(
                        color: HexColor("#B71375"),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Current Goal - ",
                            style: TextStyle(
                              color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            "Rs. ${budget_goal.toString()}",
                            style: const TextStyle(
                              color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 25
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8)),
                                        title: const Text("Add a BUDGET GOAL"),
                                        content: TextField(
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          style: TextStyle(
                                              color: Colors.green.shade400),
                                          decoration: InputDecoration(
                                            prefixText: "Rs. ",
                                            prefixIcon: Icon(Icons.wallet,
                                              color: Colors.green.shade400,),
                                          ),
                                          onChanged: (String value) {
                                            try {
                                              setState(() {
                                                budget_goal = double.parse(value);
                                                db.collection('budget').doc(widget.id).update({
                                                  'budgetgoal' : budget_goal,
                                                });
                                              });
                                            } catch (exception) {
                                              const snackBar = SnackBar(
                                                content: Text("Please enter valid value"),
                                                backgroundColor: Colors.red,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          },
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              double temp = userDetails?['budgetgoal'];
                                              List currbugetgoal = userDetails?['currbudget'];
                                              for(int i = 0; i<currbugetgoal.length; i++){
                                                currbugetgoal[i] += (budget_goal - temp);
                                              }
                                              setState(() {
                                                db.collection('budget').doc(widget.id).update({
                                                  'budgetgoal': budget_goal,
                                                  'currbudget' : currbugetgoal,
                                                });


                                              });
                                              if(userDetails?['budgetreminder'] == true){
                                                double temp= 0;
                                                expenseslist = userDetails?['expenses'];
                                                for(int i =0; i<expenseslist.length; i++){
                                                  temp += expenseslist[i];
                                                }
                                                if(temp > budget_goal){
                                                  NotificationService().showNotificationWater(0, 'Reminder!', 'Out of BUDGET');
                                                }
                                              }
                                              budget_goal = 0;
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#B71375").withOpacity(0.1),
                              ),
                              child: const Text("SET BUDGET GOAL")
                          ),

                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      height: 200,
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2 - 12),
                      decoration: BoxDecoration(
                        color: HexColor("#FC4F00"),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                              "SEE YOUR",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        ProgressReport(widget.id)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#FC4F00").withOpacity(0.1),
                              ),
                              child: Text("PROGRESS")),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          top: 8, left: 8, right: 8, bottom: 8),
                      height: 200,
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2 - 12),
                      decoration: BoxDecoration(
                        color: HexColor("F79540"),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "Your History",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18
                                  ),
                              ),
                              SizedBox(width: 10,),
                              Icon(Icons.access_time, size: 25,color: Colors.white,)
                            ],
                          ),
                          const SizedBox(height: 20,),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        BudgetHistory(widget.id)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#F79540").withOpacity(0.2),
                              ),
                              child: const Text("SHOW")
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 8, right: 8, bottom: 8),
                      height: 200,
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2 - 12),
                      decoration: BoxDecoration(
                        color: HexColor("#E49393"),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "Get Budget\nReminder",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600
                                  ),
                              ),
                              Icon(Icons.doorbell_outlined),
                            ],
                          ),
                          Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                                fillColor: MaterialStateProperty.resolveWith(getColor),
                                shape: OvalBorder(),
                                value: reminder,
                                onChanged:(bool? value)
                                {
                                  NotificationService().initializeNotification();
                                  reminder = value!;
                                  db.collection('budget').doc(widget.id).update({'budgetreminder' : reminder});
                                  double temp = 0;
                                  for(int i =0; i<expenseslist.length; i++){
                                    temp += expenseslist[i];
                                  }
                                  if(temp > userDetails?['budgetgoal']){
                                    NotificationService().showNotificationWater(0, 'Reminder!', 'Out of BUDGET');
                                  }
                                }
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: const Row(
                          children: [
                            Text(
                                "for queries contact - bhanunegi420@gmail.com "),
                            Icon(Icons.email, size: 18,)
                          ],
                        )
                    )
                  ],
                )
              ],
            ),
          );
        }
        );

  }







  Future<void> logout() async {
    await GoogleSignIn().disconnect();
    FirebaseAuth.instance.signOut();
  }


  googleLogin() async {
    print("googleLogin method Called");
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      var user = await _googleSignIn.signIn();
      if (user == null) {
        return;
      }

      final userData = await user.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: userData.accessToken, idToken: userData.idToken);
      var finalResult = await FirebaseAuth.instance.signInWithCredential(credential);
      print("Result $user");
      print(user.displayName);
      print(user.email);
      print(user.photoUrl);
      setState(() {
        widget.photoUrl = user.photoUrl!;
        widget.id = user.id!;
        widget.email = user.email;
        List<String> fullname = user.displayName!.split(" ");
        widget.name = fullname[0];
        if(widget.name.length > 5){
          widget.name = "${widget.name.substring(0,5)}\n${widget.name.substring(5,widget.name.length)}";
        }
        print(widget.name);
      });

      bool docExists = await checkIfDocExists(user.id);
      print("${docExists}user");
      if(!docExists)
      {
        await db.collection('budget').doc(user.id).set({
          "income" : [],
          "expenses" : [],
          "name" : widget.name,
          "photourl" : widget.photoUrl,
          "id" : widget.id,
          "email" : widget.email,
          "budgetgoal" : 0.0,
          "history" : [],
          "currbudget" : [],
          "dateaddedincome" : [],
          "dateaddedexpense" : [],
          "budgetreminder" : false,
        });
        print("LogIn success");

        Get.offAll(() => NewUserRegister(widget.photoUrl,widget.name,widget.id,widget.email));
      }

      else
      {
        Get.offAll(() => homepage(widget.photoUrl,widget.name,widget.id,widget.email));
      }


    } catch (error) {
      print(error);
    }
  }


  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = db.collection('budget');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }






}

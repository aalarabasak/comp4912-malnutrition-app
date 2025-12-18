import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login-related-screens/welcome_screen.dart';
import 'distribution_list.dart';
import 'stock_list_screen.dart';

class CampManagerHome extends StatefulWidget{

  const CampManagerHome({super.key});

  @override
  State<CampManagerHome> createState() => CampManagerHomeState();
}

class CampManagerHomeState extends State<CampManagerHome>{

  int currentindex = 0;
  final List<Widget> pages=[
    const StockListScreen(), //[0] stock list screen
    const DistributionList(),//[1] distribution list screen
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:const Color(0xFFF5F7FB) ,
      appBar: AppBar(
        title: const Icon(Icons.monitor_heart_outlined, color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding:  const EdgeInsets.only(right: 13.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:  const Color.fromARGB(255, 203, 202, 202),
                foregroundColor: Colors.black87,
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              onPressed:() async{//it means it is a method needs waiting -> async
                await FirebaseAuth.instance.signOut(); //log out using firebase auth

                if(context.mounted){
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(context) => const WelcomeScreen()), 
                  (route)=> false); //Erases ALL history
                }
              }, 
              label: const Text('Log Out'),
              icon: Icon(Icons.logout, size: 14,),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: pages[currentindex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentindex,
        onTap: (index) {
          setState(() {
            currentindex = index;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 229, 142, 171),//app general color
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Stocks"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: "Distributions"
          ),
        ]
      ),
    );
  }
}
//children list whose treatment plan is active and connected to field worker home screen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'child_profile_screen.dart';
import 'package:malnutrition_app/widgets/cards/treatment_details_bottomsheet.dart';
import 'package:malnutrition_app/services/treatment_service.dart';
import 'package:malnutrition_app/widgets/info_display_widgets.dart';


class TreatmentListScreen extends StatefulWidget{
  const TreatmentListScreen({super.key});

  @override
  State<TreatmentListScreen> createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State <TreatmentListScreen> {

    final TreatmentService treatmentservice = TreatmentService();//call treatment service for getting latest measurement

  final searchcontroller = TextEditingController(); //A controller to read and manage the text in the search textfield

  String searchquery ="";//A  variable to store the current search query entered by the user.

  @override
  void dispose(){
    searchcontroller.dispose();
    super.dispose();

  }

  bool showonlytoday = false;//for filter: today only
 

  @override
  Widget build(BuildContext context){
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                //title
                const Text('Treatment List', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),

                const SizedBox(height: 20),

                Row(
                  
                  children: [
                    //search bar
                    Expanded(
                      child: TextFormField(
                      controller: searchcontroller,
                      decoration: InputDecoration(
                        labelText: 'Search Child ',
                        labelStyle: TextStyle(fontSize: 15 ),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      
                      onChanged: (value) { //tells Flutter to rebuild the screen because our search query changed.
                        setState(() {
                          searchquery = value.toLowerCase();// Store the query in lowercase for easier matching
                        });
                      },

                    ),

                    ),
                    SizedBox(width: 5,),
                    //today filter
                    FilterChip(
                      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 6),
                      label: Text("Filter Today Only", style: TextStyle(color: const Color.fromARGB(255, 86, 86, 86), fontSize: 14),),
                      selected: showonlytoday,

                      onSelected: (bool value) {
                        setState(() {
                          showonlytoday = value; //if it is true, make it false, if it is othervise make it true
                        });
                      },
                      showCheckmark: false,
                      selectedColor: const Color.fromARGB(255, 229, 142, 171).withOpacity(0.5),
                      backgroundColor: const Color(0xFFF5F7FB),
                      
                      
                      side: BorderSide(
                        color: Colors.black38
                      ),
                    )
                  ],
                ),
                

                const SizedBox(height: 20),//space between title row and search bar



                //list titles (or name of the columns)
                const Row(
                  children: [ //expanded-> it takes up the remaininng horizontal space
                  //flex-> shows how the space can be shared
                    Expanded( flex: 1 ,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                    Expanded( flex: 1 ,child: Text('Next Visit', style: TextStyle(fontWeight: FontWeight.bold),)),

                  ],
                ),

                 const Divider(thickness: 1, color: Colors.black87,), //horizontal line that separates titles from datas

                //child list datas
                Expanded(//It takes up all the remaining vertical space.
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('children').where('treatmentStatus', isEqualTo: 'Active').snapshots(),

                    builder:(context, snapshot) {
                      
                      if (snapshot.hasError) return const Center(child: Text('Error loading data.'));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      var allActiveTreChildren = snapshot.data!.docs;

                      allActiveTreChildren.sort((a, b) {
                        var dataA = a.data();
                        var dataB = b.data();

                        String datestringA = dataA['nextvisitdate'];
                        String datestringB = dataB['nextvisitdate'];

                        DateTime dateA = DateTime.parse(datestringA);
                        DateTime dateB = DateTime.parse(datestringB);

                        return dateA.compareTo(dateB);
                      },);

                       List<DocumentSnapshot> filteredlist; //prepare a empty list for now
                       if(searchquery.isEmpty){
                        filteredlist = allActiveTreChildren;
                       }
                       else{
                          filteredlist = allActiveTreChildren.where((doc){
                          Map<String, dynamic> childdata = doc.data();

                          String fullName = childdata['fullName'];//get fullname 

                          // Check if name  starts with the search query
                          bool namematches = fullName.toLowerCase().startsWith(searchquery); //case-sensitive logic

                          return namematches;//Add to list if it is matched
                        }).toList(); //convert  filtered results as a list
                       }

                       

                      if(showonlytoday){
                        List<DocumentSnapshot> listduetoday = [];
                        

                        for(var doc in filteredlist){
                          var data = doc.data() as Map<String, dynamic>;;

                          if(data['nextvisitdate'] != null){
                            DateTime nextvisitdate = DateTime.parse(data['nextvisitdate']);
                            DateTime today = DateTime.now();

                            if(nextvisitdate.year == today.year && nextvisitdate.month == today.month && nextvisitdate.day == today.day){
                              listduetoday.add(doc);
                            }
                          }
                        }

                        filteredlist = listduetoday;
                      }

                      if (filteredlist.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available, size: 50, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              //Text(showonlytoday ? "No visits scheduled for today." : "No active treatments.",style: TextStyle(color: Colors.grey.shade500),
                              Text("No active treatments pending.",style: TextStyle(color: Colors.grey.shade500),)
                              
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        
                        separatorBuilder:(context, index) => Divider(height: 1, color: Colors.grey.shade200),
                        itemCount: filteredlist.length,
                        itemBuilder: (context, index) {
                          var childdoc = filteredlist[index];////get child from list

                          Map<String, dynamic> childData = childdoc.data() as Map<String, dynamic>;
                          String name = childData['fullName'];


                          String datestring = "-";
                          bool istoday = false;

                          if(childData['nextvisitdate'] != null){
                            DateTime date = DateTime.parse(childData['nextvisitdate']);
                            datestring = "${date.day}/${date.month}/${date.year}";

                            DateTime now= DateTime.now();
                            if(date.year == now.year && date.month == now.month && date.day == now.day){
                              istoday = true;
                            }
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title:  Row(
                              children: [
                                //name
                                Expanded( flex: 1,child:Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),

                                //next visit 

                                Expanded(flex: 1, child:Text(datestring, style: TextStyle(
                                        color: istoday ? Colors.red : Colors.black87,
                                        fontWeight: istoday ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 14,
                                ),)),
                                

                                
                              ],

                            ),
                            onTap: () {
                              showTreatmentdetails(context, childdoc.id); //the related function is below of this codeee
                            },
                          );
                        },


                      );
                    },

                  )
                )
              ],
            
          
        ),
    );
  }

  void showTreatmentdetails(BuildContext context, String childid){
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, //prevents overflow
      backgroundColor: Colors.transparent,
      builder:(context) {
        return StreamBuilder(
          stream: treatmentservice.getlatestTreatmentPlan(childid),
          builder:(context, snapshot) {
            if (snapshot.hasError) return const SizedBox(); //if there s error no showing
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {//if there is no data
            return  buildCards("Treatment Plan", "No available data.");
            }

            var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;//parse the data

            var rutfmap = data['prescribed_RUTF'] as Map<String, dynamic>?;
            String? productname = rutfmap?['productName'];
            int? dailyquantity = rutfmap?['dailyQuantity'];

            // Supplements – mirror the structure used in `treatment_plan_card.dart`
            List<String> supplements = [];
            int? supplementquantity; // quantity per item
            int? supplementduration; // duration in weeks

            var supplementmap = data['supplements'] as Map<String, dynamic>?;
            if (supplementmap != null) {
              if (supplementmap['selecteditems'] != null) {
                supplements = List<String>.from(supplementmap['selecteditems']);
              }
              supplementquantity = supplementmap['dailyQuantity'];
              supplementduration = supplementmap['durationWeeks'];
            }
            //String -> DateTime
            DateTime nextVisitDate = DateTime.parse(data['nextvisitdate']);

            int? durationweeks = rutfmap?['durationWeeks'];
            int? totaltarget =rutfmap?['totalTarget'];
            String diagnosis = data['diagnosis'];

            return TreatmentDetailsSheet(
              diagnosis: diagnosis, 
              productname: productname,
              dailyquantity: dailyquantity,
              durationweeks: durationweeks,
              supplements: supplements,
              suppquantity: supplementquantity,
              suppduration: supplementduration,
              nextvisitdate: nextVisitDate,
              totaltarget: totaltarget,

              //special button for field worker
              footeraction: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 229, 142, 171),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed:() {
                    Navigator.pop(context); //close the bottom sheet

                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChildProfileScreen(childId: childid)));
                    //then, go to the full profile for the specific child
                  }, 
                  child: const Text("Go to Full Profile", style: TextStyle(fontSize: 14)),
                ),
              ),

            );
          },
        );
      },
    );
  }
}
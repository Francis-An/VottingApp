import 'package:Electchain/config/styles.dart';
import 'package:Electchain/controllers/controllers.dart';
import 'package:Electchain/models/models.dart';
import 'package:Electchain/screens/screens.dart';
import 'package:Electchain/screens/user_elections.dart';
import 'package:Electchain/services/database.dart';
import 'package:Electchain/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectChain extends StatefulWidget {
  @override
  _ElectChainState createState() => _ElectChainState();
}

class _ElectChainState extends State<ElectChain> {
  final GlobalKey _scafflofKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    //Color variables
    const primary_color = Color(0xff1E4B7F);
    const secondary_color = Color(0xffD3AF35);

    return Scaffold(
      backgroundColor: Colors.indigo[100],
      key: _scafflofKey,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {
              // Scaffold.of(context).openDrawer();
            }),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.indigo, Colors.blue])),
        ),
        elevation: 0.0,
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'ATU ',
                style: GoogleFonts.gugi(
                    color: secondary_color,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold)),
            TextSpan(
                text: 'VOTTING SYSTEM',
                style: GoogleFonts.gugi(
                    fontSize: 18.0, fontWeight: FontWeight.bold))
          ]),
        ),
        actions: [
          // ignore: missing_required_param

          IconButton(
              color: Colors.white,
              icon: Icon(Icons.how_to_vote_rounded),
              onPressed: () {}),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.info_outline_rounded),
                onPressed: () {
                  showAboutDialog(
                      context: context,
                      applicationVersion: '^1.0.0',
                      applicationIcon: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage('assets/icons/logo.png'),
                      ),
                      applicationName: 'ATU Voting System',
                      applicationLegalese: 'Group 12');
                }),
          ),
        ],
      ),
      body: HomeScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(NewVote()),
        child: Container(
          decoration: BoxStyles.gradientBox,
          child: IconButton(
              icon: Icon(Icons.how_to_vote_rounded),
              onPressed: () => print('How to vote')),
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _electionAccessCodeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    const primary_color = Color(0xff1E4B7F);
    const secondary_color = Color(0xffD3AF35);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: 30.0),
            Text(
              "ENTER A VOTE CODE",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: primary_color),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    height: 50.0,
                    margin: const EdgeInsets.only(top: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(18.0)),
                    child: Form(
                      key: GlobalKey<FormState>(),
                      child: TextFormField(
                        controller: _electionAccessCodeController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                          hintText: "Enter the election code",
                          hintStyle: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.normal),
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                        ),
                      ),
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 20.0, left: 5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.indigo, Colors.blue])),
                  child: TextButton.icon(
                      // height: 40.0,
                      onPressed: () async {
                        FirebaseFirestore _firestore =
                            FirebaseFirestore.instance;
                        List<UserModel> allUsers = <UserModel>[];
                        List<ElectionModel> allElections = <ElectionModel>[];
                        var usersQuerySnap =
                            _firestore.collection("users").get();
                        usersQuerySnap.then((usersQuery) {
                          var _allUsers = usersQuery.docs
                              .map((_user) => Get.find<UserController>()
                                  .fromDocumentSnapshot(_user))
                              .toList();

                          _allUsers.forEach((user) {
                            print(user.email);
                            _firestore
                                .collection("users")
                                .doc(user.id)
                                .collection("elections")
                                .get()
                                .then((_userElectionsSnap) {
                              var userElections = _userElectionsSnap.docs
                                  .map((_election) =>
                                      Get.find<ElectionController>()
                                          .fromDocumentSnapshot(_election))
                                  .toList();
                              userElections.forEach((element) {
                                allElections.add(element);
                              });
                              allElections.forEach((election) {
                                if (election.accessCode ==
                                    _electionAccessCodeController.text) {
                                  print(
                                      "Election found ${election.accessCode}");
                                  Get.to(CastVote(), arguments: election);
                                }
                              });
                            });
                          });
                          print("All elections $allElections");
                        });
                      },
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Validate",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      )),
                )
              ],
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => NewVote());
                  },
                  child: ActionBox(
                    action: "Create Election",
                    description: "Create a new vote",
                    image: Icons.how_to_vote,
                  ),
                ),
                ActionBox(
                    action: "Poll",
                    description: "Create a new poll",
                    image: Icons.poll),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => Get.to(UserElections()),
                  child: ActionBox(
                    action: "My Elections",
                    description: "Create a new vote",
                    image: Icons.ballot,
                  ),
                ),
                ActionBox(
                    action: "FAQ",
                    description: "Create a new poll",
                    image: Icons.description),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

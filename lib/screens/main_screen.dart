import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temirdaftar/main.dart';
import 'package:temirdaftar/screens/new_card.dart';
import 'package:temirdaftar/screens/new_communal.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum SortingType { increase, decrease, alphabetical }

class _MainScreenState extends State<MainScreen> {
  var isOffline = false;
  String? id;
  Future checkConnectivity() async {
    final url = Uri.parse("https://www.google.com");
    await http.get(url).then((value) {
      isOffline = false;
    }).catchError((e) {
      isOffline = true;
    });
  }

  SortingType type = SortingType.alphabetical;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString("id");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 300)),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            checkConnectivity();
            return Scaffold(
              body: Center(
                child: Image.asset(
                  'assets/images/pencil.png',
                  width: 40,
                  height: 40,
                ),
              ),
            );
          }
          return StreamBuilder<QuerySnapshot>(
              stream: isOffline
                  ? null
                  : FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && !isOffline) {
                  bool addable = true;
                  Map<String, dynamic>? dataOne = {};
                  if (id != null) {
                    final data = snapshot.data!.docs.firstWhere((element) {
                      Map<String, dynamic> v =
                          element.data() as Map<String, dynamic>;
                      return v["data"]["id"] == id;
                    });
                    dataOne = (data.data() as Map<String, dynamic>)["data"]
                        as Map<String, dynamic>;

                    addable = !dataOne.containsKey('water') ||
                        !dataOne.containsKey('gas') ||
                        !dataOne.containsKey('electricity');

                    if ((data.data() as Map<String, dynamic>).isEmpty) {
                      addable = true;
                    }
                  }
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: SizedBox(
                      width: width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            SizedBox(
                              width: width * 312 / 360,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      'Information',
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: textColorLigth, fontSize: 25),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: InkWell(
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.white),
                                      onTap: () {
                                        Navigator.of(context).pushNamed("/");
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 10, 62, 0.05),
                                                blurRadius: 20,
                                                offset: Offset(0, 10))
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.refresh,
                                          color: secondColorLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (addable) const SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.white),
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            NewCommunal.routeName,
                                            arguments: id);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 10, 62, 0.05),
                                                blurRadius: 20,
                                                offset: Offset(0, 10))
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: secondColorLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: width * 312 / 360,
                              height: 200,
                              decoration: BoxDecoration(
                                color: secondColorLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color.fromRGBO(240, 241, 249, 1),
                                ),
                              ),
                              child: id == null
                                  ? Center(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                                NewCardScreen.routeName,
                                                arguments: id);
                                          },
                                          child: const Text("Add a card")),
                                    )
                                  : !dataOne.containsKey("card")
                                      ? Center(
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    NewCardScreen.routeName,
                                                    arguments: id);
                                              },
                                              child: const Text("Add a card")),
                                        )
                                      : Column(children: [
                                          const SizedBox(height: 50),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors
                                                          .yellow.shade600,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Image.asset(
                                                    'assets/images/credit-card-chip.png',
                                                    width: 50,
                                                    height: 50,
                                                    color:
                                                        Colors.amber.shade900,
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      dataOne["card"]["value"],
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const Text("sum",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: width * 312 / 360 - 40,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              dataOne["card"]["number"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: width * 312 / 360 - 40,
                                            alignment: Alignment.center,
                                            child: Text(
                                              dataOne["card"]["exp"],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Container(
                                            width: width * 312 / 360 - 40,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              dataOne["card"]["name"],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ]),
                            ),
                            const SizedBox(height: 20),
                            if (id != null) ...{
                              if (dataOne.containsKey('water'))
                                getWidget(width, dataOne["water"], "water", "m\u00B3"),
                              const SizedBox(height: 20),
                              if (dataOne.containsKey('gas'))
                                getWidget(width, dataOne["gas"], "gas", "m\u00B3"),
                              const SizedBox(height: 19.9),
                              if (dataOne.containsKey('electricity'))
                                getWidget(width, dataOne["electricity"],
                                    "electricity" , "kW"),
                            }
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Scaffold(
                    body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7 -
                                          10,
                                  child: Text(
                                    'Qarzdorlar Ro\'yxati',
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: textColorLigth, fontSize: 25),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3 -
                                    10,
                                child: InkWell(
                                  overlayColor:
                                      MaterialStateProperty.all(Colors.white),
                                  onTap: refresh,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 10, 62, 0.05),
                                            blurRadius: 20,
                                            offset: Offset(0, 10))
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.refresh,
                                      color: secondColorLight,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 33,
                          child: Center(
                              child: Text(
                            'No Information',
                            style: TextStyle(
                                color: textColorLigth,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )))
                    ],
                  ),
                ));
              });
        },
      ),
    );
  }

  void refresh() async {
    final url = Uri.parse('https://google.com');
    await http.get(url).then((value) {
      setState(() {
        isOffline = false;
      });
    }).catchError((e) {
      setState(() {
        isOffline = true;
      });
    });
  }

  Widget getWidget(double width, Map<String, dynamic> data, name,String birlik) {
    return Container(
      height: 120,
      width: width * 312 / 360,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 10, 62, 0.05),
              blurRadius: 20,
              offset: Offset(0, 10))
        ],
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromRGBO(250, 250, 255, 1),
        border: Border.all(
          color: const Color.fromRGBO(240, 241, 249, 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          ListTile(
            title: Text(
              data["value"]+" $birlik",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle:  Text("Stan. Limit: 120 $birlik"),
            trailing: const Text("0.0 Sum",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(data["number"]),
            ],
          )
        ],
      ),
    );
  }
}

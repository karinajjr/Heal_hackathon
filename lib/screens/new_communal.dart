import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temirdaftar/main.dart';

class NewCommunal extends StatefulWidget {
  static const routeName = '/new-qarz';
  const NewCommunal({Key? key}) : super(key: key);

  @override
  State<NewCommunal> createState() => _NewCommunalState();
}

enum KomunnalType { water, electricity, gas }

class _NewCommunalState extends State<NewCommunal> {
  final nameController = TextEditingController();
  final _key = GlobalKey<FormState>();

  KomunnalType? type = KomunnalType.water;

  String? dropdownValueForRegion;
  String? dropdownValueForCity;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  String? id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    id = ModalRoute.of(context)!.settings.arguments as String?;
    print(id);
  }

  bool isLoading = false;
  List<String> list = ["Tashkent", "Samarqand", "Buxoro", "Andijon"];
  List<String> sublist = ["Tashkent", "Samarqand", "Buxoro", "Andijon"];

  void saveQarz() async {
    if (!_key.currentState!.validate()) {
      return;
    }
    print(id);

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    final allData = await collectionRef.get();
    final data = allData.docs.any((element) {
      Map<String, dynamic> v = element.data() as Map<String, dynamic>;
      print(v);
      return v["data"]["id"] == id.toString();
    });

    String name = type == KomunnalType.water
        ? "water"
        : type == KomunnalType.electricity
            ? "electricity"
            : "gas";

    setState(() {
      isLoading = true;
    });

    if (!data) {
      await collectionRef.add({
        "data": {
          "id": "${allData.docs.length + 1}",
          name: {
            "number": type == KomunnalType.water
                ? nameController.text
                : "$dropdownValueForCity ${nameController.text}",
            "value": "0"
          }
        }
      }).then((value) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('id', "${allData.docs.length + 1}").then((value) {
          print(value);
          Navigator.of(context).pop();
        });
      });
      return;
    }

    final dataOne = allData.docs.firstWhere((element) {
      Map<String, dynamic> v = element.data() as Map<String, dynamic>;
      return v["data"]["id"] == id.toString();
    });

    Map<String, dynamic> value = (dataOne.data()
        as Map<String, dynamic>)["data"] as Map<String, dynamic>;

    if (value.containsKey(name)) {
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
        elevation: 0,
        padding: const EdgeInsets.all(0),
        content: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            height: 50,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            child: const Text('Bu nomli komunal mavjud')),
        backgroundColor: Colors.transparent,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    value.putIfAbsent(
        name,
        () => {
              "number": type == KomunnalType.water
                  ? nameController.text
                  : "$dropdownValueForCity ${nameController.text}",
              "value": "0"
            });

    collectionRef.doc(dataOne.id).update({"data": value}).then((value) async {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              SizedBox(
                width: width * 312 / 360,
                child: Row(
                  children: [
                    Expanded(
                        child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                      color: secondColorLight,
                    )),
                    Expanded(
                      flex: 6,
                      child: Text(
                        textAlign: TextAlign.center,
                        'Communal',
                        style: TextStyle(color: textColorLigth, fontSize: 20),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: KomunnalType.values.map((type) {
                  return RadioListTile<KomunnalType>(
                    title: Text(
                      type.toString().split('.').last,
                      style: TextStyle(
                        color: textColorLigth,
                      ),
                    ),
                    value: type,
                    groupValue: this.type,
                    onChanged: (KomunnalType? value) {
                      setState(() {
                        this.type = value;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (type != KomunnalType.water)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(240, 241, 249, 1),
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromRGBO(250, 250, 255, 1),
                  ),
                  width: width * 312 / 360,
                  child: DropdownButton<String>(
                    focusColor: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(10),
                    underline: const SizedBox(
                      height: 0,
                    ),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.deepPurple.shade300,
                    ),
                    value: dropdownValueForRegion,
                    hint: Text(
                      "Choose Region",
                      style: TextStyle(color: Colors.deepPurple.shade400),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValueForRegion = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          onTap: () {},
                          value: value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value,
                                style: TextStyle(
                                    color: Colors.deepPurple.shade400),
                              ),
                            ],
                          ));
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 20),
              if (type != KomunnalType.water)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(240, 241, 249, 1),
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromRGBO(250, 250, 255, 1),
                  ),
                  width: width * 312 / 360,
                  child: DropdownButton<String>(
                    focusColor: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(10),
                    underline: const SizedBox(
                      height: 0,
                    ),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.deepPurple.shade300,
                    ),
                    value: dropdownValueForCity,
                    hint: Text(
                      "Choose Regional electrical networks",
                      style: TextStyle(color: Colors.deepPurple.shade400),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValueForCity = value!;
                      });
                    },
                    items:
                        sublist.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          onTap: () {},
                          value: value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value,
                                style: TextStyle(
                                    color: Colors.deepPurple.shade400),
                              ),
                            ],
                          ));
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: 312 / 360 * width,
                child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: ((value) {
                          if (value!.isEmpty) {
                            return 'Iltimos to\'ldiring';
                          }
                          return null;
                        }),
                        decoration: InputDecoration(
                          fillColor: const Color.fromRGBO(250, 250, 255, 1),
                          filled: true,
                          hintText: 'Personal number',
                          hintStyle: TextStyle(
                            color: textColorLigth,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(240, 241, 249, 1),
                              ),
                              borderRadius: BorderRadius.circular(14)),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromRGBO(240, 241, 249, 1),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: width * 312 / 360,
                height: 60,
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStateProperty.all(secondColorLight),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)))),
                  onPressed: isLoading ? null : saveQarz,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Saqlash',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

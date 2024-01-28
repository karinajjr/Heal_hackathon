import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewCardScreen extends StatefulWidget {
  static const routeName = '/new-card';

  const NewCardScreen({super.key});
  @override
  State<NewCardScreen> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends State<NewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expirationDateController = TextEditingController();
  String _selectedCardType = 'UzCard';
  String? id;

  @override
  void dispose() {
    super.dispose();
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expirationDateController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    id = ModalRoute.of(context)!.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: id == null
          ? const Center(
              child: Text("Firstly add new Communal"),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Type',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'UzCard',
                          groupValue: _selectedCardType,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedCardType = value!;
                            });
                          },
                        ),
                        const Text('UzCard'),
                        const SizedBox(width: 16.0),
                        Radio<String>(
                          value: 'Xumo',
                          groupValue: _selectedCardType,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedCardType = value!;
                            });
                          },
                        ),
                        const Text('Xumo'),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Card Number',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: const InputDecoration(
                              hintText: 'Enter card number',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Card Holder Name',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _cardHolderNameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter card holder name',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter card holder name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Expiration Date',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _expirationDateController,
                            decoration: const InputDecoration(
                              hintText: 'Enter expiration date',
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter expiration date'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        Map<String, String> data = {
                          'cardNumber': _cardNumberController.text,
                          'cardHolderName': _cardHolderNameController.text,
                          'expirationDate': _expirationDateController.text,
                        };
                        showDialogForOTP(data);
                      },
                      child: const Text('Add Card'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void showDialogForOTP(Map<String, String> data) {
    final key = GlobalKey<FormState>();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Form(key: key, child: const Text('Enter code')),
          content: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter Code',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter code';
              }
              return null;
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (!key.currentState!.validate()) {
                  return;
                }
                if (controller.text != "8421") {
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
                        child: const Text('Code does not match')),
                    backgroundColor: Colors.transparent,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.of(context).pop();
                  return;
                }
                addData(data);
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  Future addData(Map<String, String> data) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    final allData = await collectionRef.get();

    final dataOne = allData.docs.firstWhere((element) {
      Map<String, dynamic> v = element.data() as Map<String, dynamic>;
      return v["data"]["id"] == id.toString();
    });

    Map<String, dynamic> value = (dataOne.data()
        as Map<String, dynamic>)["data"] as Map<String, dynamic>;

    value.putIfAbsent(
        "card",
        () => {
              "number": data["cardNumber"],
              "name": data["cardHolderName"],
              "exp": data["expirationDate"],
              "value": "8 435 000"
            });

    collectionRef.doc(dataOne.id).update({"data": value}).then((value) async {
      Navigator.of(context).pushNamed("/");
    });
  }
}

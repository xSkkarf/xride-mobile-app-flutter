import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: CarControl(),
        ),
      ),
    );
  }
}

class CarControl extends StatefulWidget {
  const CarControl({super.key});

  @override
  _CarControlState createState() => _CarControlState();
}

class _CarControlState extends State<CarControl> {
  bool isOn = false;
  String carId = '';
  String errorMessage = 'No Error';

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  void getStatus() async {
    var url = Uri.parse('http://localhost:3000/getstatus');
    var response = await http.get(url);

    final data = convert.json.decode(response.body);
    setState(() {
      errorMessage = "Successfully got status";
      isOn = data;
    });
  }

  void toggleStatus() async {
    var url = Uri.parse('http://localhost:3000/toggle');
    var response = await http.get(url);

    final data = convert.json.decode(response.body);
    setState(() {
      errorMessage = "Successfully toggled status";
      isOn = data;
    });
  }

  void requestOpenCarDoor(String carId) async {
    var url = Uri.parse('http://localhost:3000/request_access');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: convert.json.encode({
        "car_id": carId,
        "user_id": "USER123"
      }), // Replace with actual user ID
    );

    if (response.statusCode == 200) {
      // Handle success
      setState(() {
        errorMessage = response.body;
      });
      print('Access request sent');
    } else {
      // Handle error
      throw Exception('Failed to open car door');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          errorMessage,
          style: const TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: 400,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Enter Car ID',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                carId = value;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => requestOpenCarDoor(carId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Request to Open Car Door',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: toggleStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOn ? Colors.green : Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isOn ? 'On' : 'Off',
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

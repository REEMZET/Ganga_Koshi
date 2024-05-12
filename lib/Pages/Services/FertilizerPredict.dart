import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class FertilizerForm extends StatefulWidget {
  @override
  _FertilizerFormState createState() => _FertilizerFormState();
}

class _FertilizerFormState extends State<FertilizerForm> {
  TextEditingController nitrogenController = TextEditingController();
  TextEditingController phosphorousController = TextEditingController();
  TextEditingController potassiumController = TextEditingController();
  TextEditingController resultController = TextEditingController();
  TextEditingController cropController = TextEditingController();
  bool isLoading = false; // Add a boolean to track loading state

  // Function to validate if any field is empty
  bool _validateFields() {
    if (nitrogenController.text.isEmpty ||
        phosphorousController.text.isEmpty ||
        potassiumController.text.isEmpty ||
        cropController.text.isEmpty) {
      // Show error snack bar if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('कृपया सभी स्थानों को भरें।'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> predictFertilizer() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      isLoading = true; // Set loading state to true when prediction starts
    });

    var headers = {
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "cropname": cropController.text,
      "nitrogen": int.parse(nitrogenController.text),
      "phosphorous": int.parse(phosphorousController.text),
      "pottasium": int.parse(potassiumController.text),
    });

    try {
      var dio = Dio();
      var response = await dio.post(
        'https://ml-api-0rbc.onrender.com/fertilizer-predict',
        options: Options(
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = response.data;
        if (responseData != null && responseData.containsKey('recommendation')) {
          setState(() {
            resultController.text = responseData['recommendation'];
            isLoading = false; // Set loading state to false when prediction is received
          });
        } else {
          throw Exception('Failed to get result from response');
        }
      } else {
        throw Exception('Failed to load data. Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Set loading state to false in case of error
      });
      // Show error snack bar if response fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get recommendation. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('खाद सुझाव'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/fertiliser.png',width: 100,height: 120,),
              SizedBox(height: 10,),
              Align(alignment:Alignment.center,child: Text('खाद सुझाव के लिए 👇 मात्रा दर्ज करे',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: nitrogenController,
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'नाइट्रोजन की मात्रा',
                          labelStyle: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: phosphorousController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'फॉस्फोरस की मात्रा',
                          labelStyle: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: potassiumController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'पोटैशियम की मात्रा',
                          labelStyle: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.balance,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: cropController,
                        keyboardType: TextInputType.text,
                        maxLength: 30,
                        decoration: InputDecoration(
                          labelText: 'फसल का नाम',
                          labelStyle: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Icon(
                            Icons.local_florist,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    predictFertilizer();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Change the background color to green
                  ),
                  child: isLoading
                      ? CircularProgressIndicator() // Show CircularProgressIndicator if loading
                      : Text(
                    'सलाह प्राप्त करे',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              resultController.text.isNotEmpty
                  ? HtmlWidget(resultController.text)
                  : Container(), // Show HtmlWidget only if result is not empty
            ],
          ),
        ),
      ),
    );
  }
}

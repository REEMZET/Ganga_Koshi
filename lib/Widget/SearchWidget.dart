import 'dart:async';
import 'package:flutter/material.dart';
import '../Pages/SearchPage.dart';
import '../Utils/AppColors.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final List<String> searchHints = [
    "Organic Fertilizer 🌿",
    "Pesticide Spray 🐞",
    "Tractor 🚜",
    "Irrigation System 💧",
    "Compost 🌱",
    "Herbicide 🌾",
    "Insecticide 🐜",
    "Greenhouse Equipment 🌼",
    "Crop Seeds 🌻",
    "Drip Irrigation Kit 💧",
    "Soil Conditioner 🌍",
    "Fungicide 🌾",
    "Agriculture Drones 🚁",
    "Bio Fertilizer 🌱",
    "Harvesting Machine 🌾",
    "Crop Protection Netting 🛡️",
    "Organic Pesticide 🐝",
    "Animal Feed 🐄",
    "Mulching Film 🌿",
    "Plant Growth Promoter 🌱",
  ];

  int hintIndex = 0;
  Timer? hintTimer;
  String currentHint = "";

  @override
  void initState() {
    super.initState();
    // Start the timer to change the hint text
    hintTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        hintIndex = (hintIndex + 1) % searchHints.length;
        _updateHintText();
      });
    });
  }

  @override
  void dispose() {
    hintTimer?.cancel();
    super.dispose();
  }

  void _updateHintText() {
    setState(() {
      currentHint = "";
    });

    String hint = searchHints[hintIndex];
    int length = hint.length;

    for (int i = 0; i < length; i++) {
      Timer(Duration(milliseconds: (i + 1) * 150), () {
        setState(() {
          currentHint = hint.substring(0, i + 1);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Searchpage()
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 40, top: 18, bottom: 10),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(
              color: Colors.grey,
              width: 1, // Adjust border width as needed
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Colors.black54,
                  size: 19,
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TweenAnimationBuilder(
                    duration: Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'Search for $currentHint',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
                Icon(Icons.arrow_circle_right_outlined, size: 18, color: Colors.black87),
                SizedBox(width: 2,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

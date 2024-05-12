import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ganga Kosi'),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('NAme'),        Text('phone'),
          ],
        ),
      ),
    );
  }
}

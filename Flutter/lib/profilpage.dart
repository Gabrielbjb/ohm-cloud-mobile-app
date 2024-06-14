import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectflutter1/home.dart';
import 'package:projectflutter1/login.dart';
import 'package:projectflutter1/main.dart';

import 'auth.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    // Access user data from the AuthenticationController
    final AuthenticationController authController = Get.find();
    final userData = authController.userData;

    final String username = userData["nama_member"] ?? "No Username";
    final String email = userData["email"] ?? "No Email";
    final String phoneNumber = userData["no_hp"] ?? "No Phone Number";
    final String alamat = userData["detail_alamat"] ?? "No Alamat";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Add padding at the top
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Icon
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
              Text("Username: $username", style: TextStyle(fontSize: 18)),
              Divider(height: 32, thickness: 1),
              Text("Email: $email", style: TextStyle(fontSize: 18)),
              Divider(height: 32, thickness: 1),
              Text("Phone Number: $phoneNumber", style: TextStyle(fontSize: 18)),
              Divider(height: 32, thickness: 1),
              Align(
                alignment: Alignment.center,
                child: Text("Alamat: $alamat", style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle logout logic here
                  // authController.logout();
                         // Navigate to login page after logout
                  Get.to(() => MainPage());
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black, // Background color
                ),
                child: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

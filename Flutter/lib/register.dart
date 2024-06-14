import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectflutter1/auth.dart';
import 'package:projectflutter1/input_widget.dart';
import 'package:projectflutter1/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _kabupatenController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _detailAlamatController = TextEditingController();
  final TextEditingController _PhoneNumberController = TextEditingController();
  final TextEditingController _KonfirmasipasswordController = TextEditingController();
  final AuthenticationController _authenticationController = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height-50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text("Register",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),),
                  const SizedBox(height: 20,),
                  Text("Create an Account",style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700
                  ),),
                ],
              ),
              Column(
                children: <Widget>[
                  InputWidget(
                      hintText: "Username",
                      controller: _usernameController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Provinsi",
                      controller: _provinsiController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Kabupaten / Kota",
                      controller: _kabupatenController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Kecamatan",
                      controller: _kecamatanController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Detail_Alamat",
                      controller: _detailAlamatController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Phone Number",
                      controller: _PhoneNumberController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Email",
                      controller: _emailController,
                      obscureText: false),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Password",
                      controller: _passwordController,
                      obscureText: true),
                  const SizedBox(
                    height: 10,
                  ),
                  InputWidget(
                      hintText: "Konfirmasi Password",
                      controller: _KonfirmasipasswordController,
                      obscureText: true)
                ],
              ),
              Obx(() {
                if(_authenticationController.errorMessage.value == "Register SUCCESS"){
                  return Text(
                  _authenticationController.errorMessage.value,
                  style: const TextStyle(
                    color: Colors.black, // Set color to red for error messages
                  ),
                  );
                }else if(_authenticationController.errorEmail.value == "Error: [The email field must be a valid email address.]") {
                  return Text(
                    _authenticationController.errorEmail.value,
                    style: const TextStyle(
                      color: Colors.red, // Set color to red for error messages
                    ),
                  );
                }else if(_authenticationController.errorPassword == "Error: [The password field must match konfirmasi password.]"){
                  return Text(
                    _authenticationController.errorPassword.value,
                    style: const TextStyle(
                      color: Colors.red, // Set color to red for error messages
                    ),
                  );
                }else{
                  return Text(
                    _authenticationController.errorMessage.value,
                    style: const TextStyle(
                      color: Colors.red, // Set color to red for error messages
                    ),
                  );
                }
              }),
              Container(
                padding: const EdgeInsets.only(top: 2,left: 3),
                decoration:
                BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    )
                ),
                child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async{
                          await _authenticationController.Register(
                              Username: _usernameController.text.trim(),
                              Provinsi: _provinsiController.text.trim(),
                              Kabupaten: _kabupatenController.text.trim(),
                              Kecamatan: _kecamatanController.text.trim(),
                              Detail_alamat: _detailAlamatController.text.trim(),
                              Phone_number: _PhoneNumberController.text.trim(),
                              Email: _emailController.text.trim(),
                              Password: _passwordController.text.trim(),
                              Konfirmasi_Password: _KonfirmasipasswordController.text.trim());
                        },
                        color: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Obx(() {
                          return _authenticationController.isLoading.value
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              ):
                          const Text("Register",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,)
                          );
                        }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(onPressed: (){
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> const LoginPage(),
                      ),
                    );
                  },
                    child: const Text("Login",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}



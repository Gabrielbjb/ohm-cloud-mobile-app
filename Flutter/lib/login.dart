import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectflutter1/auth.dart';
import 'package:projectflutter1/input_widget.dart';
import 'package:projectflutter1/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationController _authenticationController = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const Text("Login",
                      style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 20),
                    Text("Login to Your Account",style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700
                    ),),
                  ],
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: <Widget>[
                      InputWidget(
                          hintText: "Email",
                          controller: _emailController,
                          obscureText: false),
                      const SizedBox(
                        height: 20,
                      ),
                      InputWidget(
                          hintText: "Password",
                          controller: _passwordController,
                          obscureText: true)
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: const Border(
                        top : BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                      ),
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () async{
                        await _authenticationController.Login(
                            Email: _emailController.text.trim(),
                            Password: _passwordController.text.trim());
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
                        ): const Text("Login",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,)
                        );
                      }),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Dont have an account"),
                    TextButton(onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context)=> RegisterPage(),
                          ),
                      );
                    },
                      child: Text("Register",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        color: Colors.black
                      ),
                      ),
                      )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top:100),
                  height: 200,
                  decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage("assets/ohm.png"),
                          fit: BoxFit.fitHeight
                      )
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}


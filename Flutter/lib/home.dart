import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:projectflutter1/cart.dart';
import 'package:projectflutter1/order.dart';
import 'package:projectflutter1/product.dart';
import 'package:projectflutter1/productdetail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'network.dart';
import 'profilpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  int _selectedIndex = 0;

  Future<Map<String, dynamic>> fetchData() async {
    var response = await http.get(Uri.parse("$baseUrl/api/products"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString());
      throw Exception("Failed to get data");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Get.to(() => OrderPage());
    } else if (index == 1) {
      Get.to(() => ProductPage());
    } else if (index == 2) {
      Get.to(() => CartPage());
    } else if (index == 3) {
      Get.to(() => ProfilPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 45, 0, 0),
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/top_image.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/ohm.png', height: 250),
                ),
                SizedBox(height: 65,),
                Text("Welcome to our Store",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
                Text("This is Our New Product",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                SizedBox(height: 30,),
                FutureBuilder(
                  future: fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      var data = snapshot.data as Map<String, dynamic>;
                      var products = data["data"] as List<dynamic>;
                      products = products.take(2).toList();
                      return Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var product = products[index];
                            var image = product["gambar"];
                            // Uint8List imageBytes;
                            // try {
                            //   imageBytes = base64Decode(image);
                            // } catch (e) {
                            //   print("Error decoding Base64 image: $e");
                            //   return const Center(child: Text("Failed to load image"));
                            // }
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => ProductDetailPage(productId: product["id"]));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.network(product["gambar"],height: 175,width: 175,),
                                    SizedBox(height: 5),
                                    Text(
                                      product["nama_barang"] ?? "No Name",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Rp. "+product["harga"].toString(),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(child: Text("Failed to load data"));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.reorder),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 187, 0),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

}

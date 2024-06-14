import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:projectflutter1/checkout.dart';
import 'dart:convert';
import 'auth.dart';
import 'network.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final AuthenticationController authController = Get.put(AuthenticationController());

  Future<List<dynamic>> fetchData() async {
    var response = await http.get(Uri.parse("$baseUrl/api/cart"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData["data"];
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      throw Exception("Failed to get data");
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    var response = await http.get(Uri.parse("$baseUrl/api/products/$productId"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData["data"];
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      throw Exception("Failed to get product details");
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    var response = await http.delete(Uri.parse("$baseUrl/api/cart/$cartItemId"));
    if (response.statusCode == 200) {
      Get.snackbar("Success", "Item deleted from cart");
      setState(() {});
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", "Can't Delete Item from cart",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Map<String, dynamic>.from(authController.userData);
    final int userId = userData["id"] ?? -1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            var cartItems = snapshot.data!;
            var filteredItems = cartItems.where((item) => item["id_member"] == userId && item["is_checkout"] == 0).toList();

            if (filteredItems.isEmpty) {
              return Center(child: Text("No items in cart"));
            }

            int totalAmount = filteredItems.fold<int>(0, (sum, item) => sum + (item["total"] as int));

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      var item = filteredItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey),
                        ),
                        child: ListTile(
                          title: FutureBuilder<Map<String, dynamic>>(
                            future: fetchProductDetails(item["id_barang"]),
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (productSnapshot.hasData) {
                                var product = productSnapshot.data!;
                                return Text(product["nama_barang"] ?? "No Name");
                              } else {
                                return Text("Failed to load product details");
                              }
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Map<String, dynamic>>(
                                future: fetchProductDetails(item["id_barang"]),
                                builder: (context, productSnapshot) {
                                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  if (productSnapshot.hasData) {
                                    var product = productSnapshot.data!;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Description: ${product["deskripsi"] ?? "No Description"}"),
                                        Text("Quantity: ${item["jumlah"]}"),
                                        Text("Color: ${item["color"]}"),
                                        Text("Total: Rp. ${item["total"]}"),
                                      ],
                                    );
                                  } else {
                                    return Text("Failed to load product details");
                                  }
                                },
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteCartItem(item["id"]); // Call delete function with cart item ID
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Cart Total: Rp. $totalAmount",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => CheckoutPage(totalAmount: totalAmount, cartItems: filteredItems));
                  },
                  child: Text("Checkout"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                ),
                SizedBox(height: 50),
              ],
            );
          } else {
            return Center(child: Text("Failed to load data"));
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth.dart';
import 'network.dart';
import 'payment.dart';

class CheckoutPage extends StatefulWidget {
  final int totalAmount;
  final List<dynamic> cartItems;

  const CheckoutPage({Key? key, required this.totalAmount, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController addressController = TextEditingController();
  final AuthenticationController _authenticationController = Get.find();

  Future<Map<String, dynamic>> fetchProductData(int productId) async {
    var response = await http.get(Uri.parse("$baseUrl/api/products/$productId"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString());
      throw Exception("Failed to get product data");
    }
  }

  String generateInvoice() {
    DateTime now = DateTime.now();
    String formattedDate = "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  void placeOrder() async {
    var userdata = _authenticationController.userData;
    int id_user = userdata["id"];
    String invoice = generateInvoice();
    int grandTotal = widget.totalAmount;
    String status = "pending";
    List<String> productNames = [];

    // Iterate through cart items to extract product names
    for (var item in widget.cartItems) {
      var productData = await fetchProductData(item["id_barang"]);
      var productName = productData["data"]["nama_barang"];
      productNames.add(productName);
    }

    var data = {
      "id_member": id_user,
      "invoice": invoice,
      "grand_total": grandTotal,
      "status": "Baru",
      "product" : "$productNames",
    };

    var response = await http.post(
      Uri.parse("$baseUrl/api/ordersmobile"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData["message"] == "success") {
        int orderId = responseData["data"]["id"];
        Get.snackbar("Success", "Order placed successfully");
        await updateCartItems(id_user);
        Get.to(() => PaymentPage(totalAmount: grandTotal, orderId: orderId));
      } else {
        var responseData = jsonDecode(response.body);
        Get.snackbar("Error", "Failed to place order",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        debugPrint('Error: $responseData');
      }
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", "Failed to place order",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      debugPrint('Error: $responseData');
    }
  }

  Future<void> updateCartItems(int userId) async {
    var cartItems = widget.cartItems;
    for (var cartItem in cartItems) {
      var itemId = cartItem['id'];
      await updateCartItem(userId, itemId);
    }
  }

  Future<void> updateCartItem(int userId, int cartItemId) async {
    var response = await http.put(
      Uri.parse("$baseUrl/api/cart/$cartItemId?_method=PUT"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"is_checkout": 1}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update cart item: $cartItemId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "This Is The Product You Will Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  var item = widget.cartItems[index];
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchProductData(item["id_barang"]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        var product = snapshot.data!["data"];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.network(
                                  product["gambar"],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["nama_barang"] ?? "No Name",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text("Description: ${product["deskripsi"] ?? "No Description"}"),
                                      Text("Quantity: ${item["jumlah"]}"),
                                      Text("Price: Rp. ${item["total"]}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(child: Text("Failed to load product data"));
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Total Amount: Rp. ${widget.totalAmount}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: placeOrder,
              child: Text("Place Order", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

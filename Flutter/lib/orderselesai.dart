import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import 'auth.dart';
import 'network.dart';

class CompleteOrderPage extends StatefulWidget {
  const CompleteOrderPage({Key? key}) : super(key: key);

  @override
  State<CompleteOrderPage> createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {
  final AuthenticationController authController = Get.put(AuthenticationController());
  late Future<List<dynamic>> ordersFuture;

  @override
  void initState() {
    super.initState();
    ordersFuture = fetchOrders();
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl/api/ordersmobile"));
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var allOrders = responseData["data"];

        // Get the user id from authController
        final userData = Map<String, dynamic>.from(authController.userData);
        final int userId = userData["id"] ?? -1;

        // Filter orders based on id_member and status
        var completedOrders = allOrders.where((order) => order["status"] == "Selesai" && order["id_member"] == userId).toList();
        return completedOrders;
      } else {
        var responseData = jsonDecode(response.body);
        print("Error response data: $responseData"); // Log error response data
        Get.snackbar("Error", responseData.toString());
        throw Exception("Failed to load completed orders: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e"); // Log the exception
      Get.snackbar("Error", e.toString());
      throw Exception("Failed to load completed orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Orders"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            var orders = snapshot.data!;

            if (orders.isEmpty) {
              return Center(child: Text("No completed orders found"));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var status = order["status"];
                var updatedAt = DateTime.parse(order["updated_at"] ?? order["created_at"]);
                var productList;

                try {
                  productList = jsonDecode(order["product"]);
                } catch (e) {
                  productList = [order["product"]]; // Handle as simple string
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: ListTile(
                    title: Text("Order ID: ${order["id"]}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status: $status"),
                        Text("Invoice: ${order["invoice"]}"),
                        Text("Grand Total: Rp. ${order["grand_total"]}"),
                        Text("Created At: ${order["created_at"]}"),
                        if (productList.isNotEmpty) ...[
                          Text("Products: ${productList.join(', ')}"),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("Failed to load completed orders"));
          }
        },
      ),
    );
  }
}

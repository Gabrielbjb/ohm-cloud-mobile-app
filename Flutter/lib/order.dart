import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import 'package:projectflutter1/auth.dart';
import 'package:projectflutter1/network.dart';

import 'data_pembayaran.dart';
import 'orderselesai.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
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
        return responseData["data"];
      } else {
        var responseData = jsonDecode(response.body);
        print("Error response data: $responseData"); // Log error response data
        Get.snackbar("Error", responseData.toString());
        throw Exception("Failed to load orders: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e"); // Log the exception
      Get.snackbar("Error", e.toString());
      throw Exception("Failed to load orders: $e");
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api/pesanan/ubah_statusMobile/$orderId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": newStatus}),
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Refresh the order list
        if (responseData["message"] == "success") {
          debugPrint(responseData.toString());
          Get.snackbar("Success", "Order status updated to '$newStatus'");
          setState(() {
            ordersFuture = fetchOrders();
          });
        }
      } else {
        var responseData = jsonDecode(response.body);
        debugPrint(responseData.toString());
        print("Error updating status: ${response.body}");
        Get.snackbar("Error", "Failed to update order status");
      }
    } catch (e) {
      print("Exception: $e");
      Get.snackbar("Error", "Failed to update order status: $e");
    }
  }

  Future<void> markOrderAsCompleted(int orderId) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/api/pesanan/ubah_statusMobile/$orderId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": "Selesai"}),
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Refresh the order list
        if (responseData["message"] == "success") {
          debugPrint(responseData.toString());
          Get.snackbar("Success", "Order marked as completed");
          setState(() {
            ordersFuture = fetchOrders();
          });
        }
      } else {
        var responseData = jsonDecode(response.body);
        debugPrint(responseData.toString());
        print("Error updating status: ${response.body}");
        Get.snackbar("Error", "Failed to mark order as completed");
      }
    } catch (e) {
      print("Exception: $e");
      Get.snackbar("Error", "Failed to mark order as completed: $e");
    }
  }

  bool isOrderCompletedWithinThirtyDays(DateTime updatedAt) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(updatedAt);
    return difference.inDays <= 30;
  }

  Future<void> _refreshOrders() async {
    setState(() {
      ordersFuture = fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Map<String, dynamic>.from(authController.userData);
    final int userId = userData["id"] ?? -1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => CompleteOrderPage());
            },
            child: Text("Complete Orders"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(() => DataPembayaran());
            },
            child: Text("Payment Data"),
          ),
        ],
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
            var filteredOrders = orders.where((order) => order["id_member"] == userId && order["status"] != "Selesai").toList();

            if (filteredOrders.isEmpty) {
              return Center(child: Text("No pending orders found"));
            }

            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  var order = filteredOrders[index];
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
                      trailing: status == "Dikirim"
                          ? ElevatedButton(
                        onPressed: () async {
                          await updateOrderStatus(order["id"], "Diterima");
                          setState(() {
                            order["status"] = "Diterima";
                          });
                        },
                        child: Text("Diterima"),
                      )
                          : status == "Diterima"
                          ? ElevatedButton(
                        onPressed: () async {
                          await markOrderAsCompleted(order["id"]);
                          setState(() {
                            filteredOrders.removeAt(index);
                          });
                        },
                        child: Text("Selesai"),
                      )
                          : null,
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(child: Text("Failed to load orders"));
          }
        },
      ),

    );
  }
}

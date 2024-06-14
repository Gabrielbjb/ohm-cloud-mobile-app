import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'network.dart';

class DataPembayaran extends StatefulWidget {
  const DataPembayaran({super.key});

  @override
  State<DataPembayaran> createState() => _DataPembayaranState();
}

class _DataPembayaranState extends State<DataPembayaran> {
  final AuthenticationController authController = Get.put(AuthenticationController());

  Future<List<dynamic>> fetchData() async {
    var response = await http.get(Uri.parse("$baseUrl/api/paymentsmobile"));
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var allPayments = responseData["data"] as List<dynamic>;

      // Filter payments based on id_member
      final userData = Map<String, dynamic>.from(authController.userData);
      final int userId = userData["id"] ?? -1;
      var filteredPayments = allPayments.where((payment) => payment["id_member"] == userId).toList();

      return filteredPayments;
    } else {
      var responseData = jsonDecode(response.body);
      Get.snackbar("Error", responseData.toString());
      throw Exception("Failed to get data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Data"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            var payments = snapshot.data!;
            if (payments.isEmpty) {
              return Center(child: Text("No payment data available"));
            }

            return ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                var payment = payments[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: ListTile(
                    title: Text("Payment ID: ${payment["id"]}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Amount: Rp. ${payment["jumlah"]}"),
                        Text("Provinsi: ${payment["provinsi"]}"),
                        Text("Kota: ${payment["kabupaten"]}"),
                        Text("Kecamatan: ${payment["kecamatan"]}"),
                        Text("Alamat: ${payment["detail_alamat"]}"),
                        Text("Status: ${payment["status"]}"),
                        Text("Rekening Number: ${payment["no_rekening"]}"),
                        Text("Rekening Name: ${payment["atas_nama"]}"),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("Failed to load payment data"));
          }
        },
      ),
    );
  }
}

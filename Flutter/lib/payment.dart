import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'auth.dart';
import 'input_widget.dart';
import 'home.dart';
import 'network.dart';

class PaymentPage extends StatefulWidget {
  final int totalAmount;
  final int orderId;

  const PaymentPage({Key? key, required this.totalAmount, required this.orderId}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController provinsiController = TextEditingController();
  final TextEditingController kabupatenController = TextEditingController();
  final TextEditingController kecamatanController = TextEditingController();
  final TextEditingController detailAlamatController = TextEditingController();
  final TextEditingController noRekeningController = TextEditingController();
  final TextEditingController atasNamaController = TextEditingController();
  final AuthenticationController _authenticationController = Get.find();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void payment() async {
    if (_selectedImage == null) {
      Get.snackbar("Error", "Please select an image first");
      return;
    }
    var userdata = _authenticationController.userData;
    int id_user = userdata["id"];
    int grandTotal = widget.totalAmount;

    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/api/paymentsmobile"));
    request.headers.addAll({
      "Accept": "application/json",
    });

    request.fields['id_order'] = widget.orderId.toString();
    request.fields['jumlah'] = grandTotal.toString();
    request.fields['provinsi'] = provinsiController.text;
    request.fields['kabupaten'] = kabupatenController.text;
    request.fields['kecamatan'] = kecamatanController.text;
    request.fields['detail_alamat'] = detailAlamatController.text;
    request.fields['status'] = "pending";
    request.fields['no_rekening'] = noRekeningController.text;
    request.fields['atas_nama'] = atasNamaController.text;
    request.fields['id_member'] = id_user.toString();

    request.files.add(await http.MultipartFile.fromPath('bukti_pembayaran', _selectedImage!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      if (jsonResponse["success"] == true) {
        Get.snackbar("Success", "Payment information submitted successfully");
      } else {
        Get.snackbar("Error", "Failed to submit payment information",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        debugPrint('Error: $jsonResponse');
      }
    } else {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      Get.snackbar("Error", "Failed to submit payment information",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      debugPrint('Error: $jsonResponse');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50,),
              const Text(
                "Enter the Shipping address and Payment Data",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 20,),
              InputWidget(
                  hintText: "Provinsi",
                  controller: provinsiController,
                  obscureText: false),
              const SizedBox(height: 10,),
              InputWidget(
                  hintText: "Kota/Kabupaten",
                  controller: kabupatenController,
                  obscureText: false),
              const SizedBox(height: 10,),
              InputWidget(
                  hintText: "Kecamatan",
                  controller: kecamatanController,
                  obscureText: false),
              const SizedBox(height: 10,),
              InputWidget(
                  hintText: "Detail Alamat",
                  controller: detailAlamatController,
                  obscureText: false),
              const SizedBox(height: 10,),
              InputWidget(
                  hintText: "No Rekening",
                  controller: noRekeningController,
                  obscureText: false),
              const SizedBox(height: 10,),
              InputWidget(
                  hintText: "Atas Nama",
                  controller: atasNamaController,
                  obscureText: false),
              const SizedBox(height: 8,),
              Text(
                "Total Amount: Rp. ${widget.totalAmount}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "This is Our Rekening Number from BCA Bank 1234567890",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text(
                  "Add Image For Proof of Payment",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_selectedImage!),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => HomePage());
              },
              child: const Text(
                "Go to Homepage",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: payment,
              child: const Text(
                "Submit Payment",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

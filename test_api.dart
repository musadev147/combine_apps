import 'package:dio/dio.dart';
import 'dart:developer';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.post(
      'https://server-livesession8002-feusec-269c36-62-84-177-235.sslip.io/invoice/',
      data: {
        "total_price": "25.00",
        "address": "test address",
        "phone_number": "01700000000",
        "price_per_piece": "25.00",
        "quantity": 1,
        "delivery_charge": "0.0",
        "service_charge": "0.0",
        "packing_charge": "0.0",
        "product_name": "Test Item",
        "is_confirm": true,
        "status": "pending",
        "buyer": null,
        "tag": null,
        "short_note": null
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          // Need auth token if it's protected
        }
      )
    );
    print("Success: ${response.statusCode}");
  } on DioException catch (e) {
    print("Error: ${e.response?.statusCode} - ${e.response?.data}");
  }
}

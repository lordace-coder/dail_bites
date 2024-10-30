import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';

class PaystackPaymentService {
  final String publicKey = 'YOUR_PAYSTACK_PUBLIC_KEY';
  final PocketBase pb;
  final Dio dio = Dio();

  PaystackPaymentService(this.pb);

  Future<void> makePayment({
    required String email,
    required double amount,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      // Convert amount to kobo (multiply by 100)
      final amountInKobo = (amount * 100).toInt();

      // Generate reference
      final reference = 'TR${DateTime.now().millisecondsSinceEpoch}';

      // Initialize payment
      await FlutterPaystackPlus.openPaystackPopup(
        context: context,
        publicKey: publicKey,
        amount: amountInKobo.toString(),
        customerEmail: email,
        reference: reference,
        currency: "NGN",
        metadata: {
          "custom_fields": [
            {
              "display_name": "Payment for",
              "variable_name": "payment_for",
              "value": "Order"
            }
          ]
        },
        onClosed: () {},
        onSuccess: () async {
          await _savePaymentRecord(
            email: email,
            amount: amount,
            reference: reference,
            status: 'success',
          );
          onSuccess.call();
        },
      );
    } catch (e) {
      throw Exception('Payment error: $e');
    }
  }

  Future<void> _savePaymentRecord({
    required String email,
    required double amount,
    required String reference,
    required String status,
  }) async {
    try {
      final body = {
        "email": email,
        "amount": amount,
        "reference": reference,
        "status": status,
        "date": DateTime.now().toIso8601String(),
      };

      await pb.collection('payments').create(body: body);
    } catch (e) {
      throw Exception('Failed to save payment record: $e');
    }
  }
}

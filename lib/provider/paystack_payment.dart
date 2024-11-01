import 'package:dail_bites/ui/pages/completed_transaction_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';

class PaystackPaymentService {
  final String publicKey = 'pk_test_14e8e01f8cbb1d3eb5dac7c17572364a42509fec';
  final PocketBase pb;
  final Dio dio = Dio();

  PaystackPaymentService(this.pb);

  Future<void> makePayment({
    required String email,
    required double amount,
    required BuildContext context,
    required String orderId,
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
        secretKey: 'sk_test_e40eecaa87be78830c7e8fa3f9b8b4ef900afe33',
        amount: amountInKobo.toString(),
        customerEmail: email,
        reference: reference,
        currency: "NGN",
        metadata: {
          "custom_fields": [
            {
              "email": email,
              "amount": amount,
              "reference": reference,
              "status": 'success',
              "order": orderId,
              'currency': "NGN",
              "date": DateTime.now().toIso8601String(),
              'user': pb.authStore.model.id,
            }
          ],
          'order_data': {
            "email": email,
            "amount": amount,
            "reference": reference,
            "status": 'success',
            "order": orderId,
            'currency': "NGN",
            "date": DateTime.now().toIso8601String(),
            'user': pb.authStore.model.id,
          }
        },
        onClosed: () {},
        onSuccess: () async {
          AppRouter().navigateTo(CompletedTransactionPage(
            orderId: orderId,
          ));
        },
      );
    } catch (e) {
      throw Exception('Payment error: $e');
    }
  }

//TODO change this to webhook

// 2 set order to paid
}

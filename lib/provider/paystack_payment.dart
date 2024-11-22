import 'package:dail_bites/bloc/cart/cubit.dart';
import 'package:dail_bites/provider/app_provider.dart';
import 'package:dail_bites/ui/pages/completed_transaction_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'paystack_interlop.dart' as paystack;

class PaystackPaymentService {
  final PocketBase pb;
  final Dio dio = Dio();
  final appData = AppDataProvider();
  PaystackPaymentService(this.pb);

  Future<void> makePayment({
    required String email,
    required double amount,
    required BuildContext context,
    required String orderId,
    required VoidCallback onSuccess,
  }) async {
    final amountInKobo = (amount * 100).toInt();
    final reference = 'TR${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
// handle paystack using web solution
      print('handling for web');
      js.context.callMethod(
        paystack.paystackPopUp(
          appData.publicKey,
          email,
          amountInKobo.toString(),
          reference,
          js.allowInterop(() {
            onSuccess.call();
          }),
          js.allowInterop(() {
            Navigator.of(context).pop();
            AppRouter().navigateTo(OrderReceipt(orderId: orderId));
            onSuccess.call();
          }),
        ),
      );
    } else {
      try {
        // Convert amount to kobo (multiply by 100)

        // Generate reference
        final reference = 'TR${DateTime.now().millisecondsSinceEpoch}';

        // Initialize payment
        await FlutterPaystackPlus.openPaystackPopup(
          context: context,
          publicKey: appData.publicKey,
          secretKey: appData.secretKey,
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
          onClosed: () {
            print('cloesed');
            onSuccess.call();
          },
          onSuccess: () {
            print('success');
            Navigator.of(context).pop();
            AppRouter().navigateTo(OrderReceipt(orderId: orderId));
            onSuccess.call();
          },
        );
      } catch (e) {
        throw Exception('Payment error: $e');
      }
    }
  }
}

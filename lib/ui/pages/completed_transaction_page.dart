import 'package:cached_network_image/cached_network_image.dart';
import 'package:dail_bites/bloc/pocketbase/pocketbase_service_cubit.dart';
import 'package:dail_bites/bloc/products/product_cubit.dart';
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/provider/customer_support.dart';
import 'package:dail_bites/provider/paystack_payment.dart';
import 'package:dail_bites/ui/theme.dart';
import 'package:dail_bites/ui/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class OrderReceipt extends StatefulWidget {
  final String orderId;

  const OrderReceipt({super.key, required this.orderId});

  @override
  State<OrderReceipt> createState() => _OrderReceiptState();
}

class _OrderReceiptState extends State<OrderReceipt> {
  bool isLoading = true;
  String? error;
  RecordModel? orderData;
  List<RecordModel> orderItems = [];
  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    final pb = context.read<PocketbaseServiceCubit>().pb;
    try {
      final order = await pb.collection('order').getOne(
            widget.orderId,
            expand: 'orderitem,orderitem.product,owner',
          );

      setState(() {
        orderData = order;
        if (order.expand['orderitem'] != null) {
          orderItems = (order.expand['orderitem'] as List).cast<RecordModel>();
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load receipt details';
        isLoading = false;
      });
    }
  }

  Future<void> retryPayment() async {
    showDialog(
      context: context,
      builder: (context) => PaymentRetryDialog(
        address: orderData?.data['location'] ?? 'N/A',
        contact: orderData?.data['contact'],
        amount: calculateTotal(),
        onConfirm: () async {
          final pb = context.read<PocketbaseServiceCubit>().pb;
          Navigator.of(context).pop();
          // Implement your payment logic here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to payment...')),
          );
          await PaystackPaymentService(pb).makePayment(
            email: (pb.authStore.model as RecordModel).getStringValue('email'),
            amount: calculateTotal(),
            context: context,
            onSuccess: () {},
            orderId: orderData!.id.toString(),
          );
        },
        onEdit: () {
          Navigator.of(context).pop(); // Close the dialog
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => EditDetailsSheet(
              currentAddress: orderData?.data['location'] ?? 'N/A',
              currentContact: orderData?.data['contact'],
              onSubmit: (newAddress, newContact) async {
                // Update the delivery details in your database
                try {
                  final pb = context.read<PocketbaseServiceCubit>().pb;
                  await pb.collection('order').update(
                    orderData!.id,
                    body: {
                      'location': newAddress,
                      'contact': newContact,
                    },
                  );

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Delivery details updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh the order details
                    fetchOrderData();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update delivery details'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> contactSupport() async {
    // Implement your customer support contact logic here
    openWhatsAppSupport();
  }

  double calculateTotal() {
    double total = 0;
    for (var item in orderItems) {
      final products = (item.expand['product'] as List?)?.cast<RecordModel>();
      if (products?.isNotEmpty ?? false) {
        final product = products!.first;
        final count = item.data['count'] ?? 1;
        final price = product.data['price'] ?? 0;
        total += price * count;
      }
    }
    return total;
  }

  Widget _buildOrderItem(RecordModel item) {
    List<RecordModel> products = [];
    if (item.expand['product'] != null) {
      products = (item.expand['product'] as List).cast<RecordModel>();
    }
    final pocketBase = context.read<PocketbaseServiceCubit>().pb;

    if (products.isEmpty) return const SizedBox();

    final product = products.first;
    final count = item.data['count'] ?? 1;
    final price = product.data['price'] ?? 0;
    final title = product.data['title'] ?? 'Unknown Product';
    final productCubit = context.read<ProductCubit>().state;

    for (var element in (productCubit as ProductLoaded).products) {
      print(element.id == product.id);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                  Colors.black
                      .withOpacity(0.5), // Adjust opacity between 0.0 and 1.0
                  BlendMode.darken,
                ),
                image: CachedNetworkImageProvider(pocketBase
                    .getFileUrl(product, product.data['image'])
                    .toString()),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${count}x',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unit Price: ${currencyFormatter.format(price)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormatter.format(price * count),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Order Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!))
                  : RefreshIndicator.adaptive(
                      onRefresh: fetchOrderData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Status Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: orderData?.data['paid'] == true
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: orderData?.data['paid'] == true
                                      ? Colors.green[200]!
                                      : Colors.red[200]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    orderData?.data['paid'] == true
                                        ? Icons.check_circle
                                        : Icons.error_outline,
                                    color: orderData?.data['paid'] == true
                                        ? Colors.green
                                        : Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    orderData?.data['paid'] == true
                                        ? 'Payment Successful'
                                        : 'Payment Failed',
                                    style: TextStyle(
                                      color: orderData?.data['paid'] == true
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (orderData?.data['paid'] != true) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: retryPayment,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Retry Payment'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: contactSupport,
                                          icon: const Icon(Icons.support_agent),
                                          label: const Text('Contact Support'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Order Items
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order Items',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...orderItems.map(_buildOrderItem),
                                        const Divider(height: 32),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Amount',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              currencyFormatter
                                                  .format(calculateTotal()),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme().secondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Delivery Details
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivery Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          orderData?.data['location'] ?? 'N/A',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (orderData?.data['contact'] != null) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined,
                                            color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          orderData?.data['contact'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}

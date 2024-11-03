import 'package:dail_bites/bloc/pocketbase/pocketbase_service_cubit.dart';
import 'package:dail_bites/ui/pages/completed_transaction_page.dart';
import 'package:dail_bites/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  bool isLoading = true;
  List<RecordModel> orders = [];
  String filterStatus = 'all'; // 'all', 'paid', 'unpaid'
  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final pb = context.read<PocketbaseServiceCubit>().pb;
    setState(() => isLoading = true);
    try {
      final String userId = pb.authStore.model.id;
      String filter = 'owner = "$userId"';

      if (filterStatus == 'paid') {
        filter += ' && paid = true';
      } else if (filterStatus == 'unpaid') {
        filter += ' && paid = false';
      }

      final result = await pb.collection('order').getList(
            filter: filter,
            sort: '-created',
            expand: 'orderitem,orderitem.product,payments(order)',
          );

      setState(() {
        orders = result.items;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load orders')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Orders'),
                    selected: filterStatus == 'all',
                    onSelected: (bool selected) {
                      setState(() => filterStatus = 'all');
                      fetchOrders();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Paid'),
                    selected: filterStatus == 'paid',
                    onSelected: (bool selected) {
                      setState(() => filterStatus = 'paid');
                      fetchOrders();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Unpaid'),
                    selected: filterStatus == 'unpaid',
                    onSelected: (bool selected) {
                      setState(() => filterStatus = 'unpaid');
                      fetchOrders();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Order List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64,
                                color: AppTheme().secondary.withOpacity(.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                  color: AppTheme().secondary.withOpacity(.5)),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final payment =
                                order.expand['payments(order)']?[0].data;
                            final amount = payment?['amount'] ?? 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderReceipt(
                                      orderId: order.id.toString(),
                                    ),
                                  ),
                                ),
                                child: Container(
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Order Status Icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: order.data['paid'] == true
                                                ? Colors.green[50]
                                                : Colors.red[50],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            order.data['paid'] == true
                                                ? Icons.check_circle
                                                : Icons.pending,
                                            color: order.data['paid'] == true
                                                ? Colors.green
                                                : Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Order Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Order #${order.id}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat.yMMMd()
                                                    .add_jm()
                                                    .format(
                                                      DateTime.parse(
                                                          order.created),
                                                    ),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Amount
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              currencyFormatter.format(amount),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    order.data['paid'] == true
                                                        ? Colors.green[50]
                                                        : Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                order.data['paid'] == true
                                                    ? 'Paid'
                                                    : 'Unpaid',
                                                style: TextStyle(
                                                  color:
                                                      order.data['paid'] == true
                                                          ? Colors.green
                                                          : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

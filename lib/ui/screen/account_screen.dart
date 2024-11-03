import 'package:dail_bites/bloc/pocketbase/pocketbase_service_cubit.dart';
import 'package:dail_bites/provider/app_provider.dart';
import 'package:dail_bites/provider/customer_support.dart';
import 'package:dail_bites/ui/pages/order_list_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:dail_bites/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class Orders {
  int count = 0;
  int completed = 0;
  int uncompleted = 0;
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = false;
  double profileCompletion = 0.85; // Profile completion percentage
  final Orders order = Orders();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchOrders();
    });
  }

  void _logout() {
    context.read<PocketbaseServiceCubit>().state.clearAuthStore();
  }

  Future<void> fetchOrders() async {
    final pb = context.read<PocketbaseServiceCubit>().pb;
    try {
      final String userId = pb.authStore.model.id;
      String filter = 'owner = "$userId"';

      filter += ' && paid = true';
      // } else if (filterStatus == 'unpaid') {
      //   filter += ' && paid = false';
      // }

      final result = await pb.collection('order').getList(
            filter: filter,
            sort: '-created',
            expand: 'orderitem,orderitem.product,payments(order)',
          );

      setState(() {
        order.count = result.totalItems;
        order.completed = result.items.map((item) {
          // get orders that are completed
          if (item.getBoolValue('paid')) {
            return item;
          }
        }).length;
        order.uncompleted = order.count - order.completed;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _buildProfileAction(
    IconData icon,
    String title,
    String subtitle, {
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: iconColor ?? Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final user =
        context.read<PocketbaseServiceCubit>().state.pb.authStore.model.data;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '${user['username']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user['email']}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Profile completion indicator
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(order.count.toString(), 'Orders'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatColumn(order.uncompleted.toString(), 'Pending'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatColumn(order.completed.toString(), 'Completed'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<PocketbaseServiceCubit>().pb.authStore.model;
    final bool isStaff = (user as RecordModel).getBoolValue('staff');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            leading: Container(),
          ),

          // Profile Header
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),

          // Account Actions
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileAction(
                  Icons.shopping_bag_outlined,
                  'My Orders',
                  'View order history and track current orders',
                  iconColor: Colors.blue,
                  onTap: () {
                    // Navigate to orders screen
                    AppRouter().navigateTo(const OrderListPage());
                  },
                ),
                _buildProfileAction(
                  Icons.info,
                  'Terms and Policies',
                  'View terms of service and privacy policies of our app',
                  iconColor: Colors.teal,
                  onTap: () {
                    launchLink('${AppDataProvider().baseUrl}/terms.html');
                  },
                ),
                if (isStaff)
                  _buildProfileAction(
                    Icons.dashboard,
                    'View Orders',
                    'Checkout customers order\'s',
                    iconColor: Colors.amber,
                    onTap: () {
                      launchLink("${AppDataProvider().baseUrl}/_/");
                    },
                  ),
                _buildProfileAction(
                  Icons.info,
                  'Licenses',
                  'View app licences',
                  iconColor: Colors.teal,
                  onTap: () {
                    showLicensePage(context: context);
                  },
                ),
                _buildProfileAction(
                  Icons.help_outline,
                  'Help & Support',
                  'Get help with your orders and products',
                  iconColor: Colors.teal,
                  onTap: () {
                    openWhatsAppSupport();
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme().secondary,
                    padding: const EdgeInsets.all(16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

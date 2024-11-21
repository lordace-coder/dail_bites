import 'package:dail_bites/bloc/cart/cubit.dart';
import 'package:dail_bites/ui/pages/cart_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:dail_bites/ui/screen/account_screen.dart';
import 'package:dail_bites/ui/screen/categories_screen.dart';
import 'package:dail_bites/ui/screen/home_screen.dart';
import 'package:dail_bites/ui/screen/wishlist_screen.dart';
import 'package:dail_bites/ui/theme.dart';
import 'package:dail_bites/ui/widgets/appbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwa_install/pwa_install.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.query});

  final String? query;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    try {
      PWAInstall().promptInstall_();
    } catch (e) {}
    final List<Widget> pages = [
      HomeScreen(
        query: widget.query,
      ),
      CategoriesScreen(),
      const WishlistScreen(),
      const AccountScreen()
    ];
    final primary = AppTheme().primary;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _selectedIndex == 0 ? const GenericAppBar() : null,
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          AppRouter().navigateTo(const CartPage());
        },
        child: Builder(builder: (context) {
          final cartCount = context.watch<CartCubit>().getItemCount();
          return GestureDetector(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

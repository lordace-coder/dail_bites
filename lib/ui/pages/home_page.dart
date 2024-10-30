import 'package:dail_bites/ui/screen/account_screen.dart';
import 'package:dail_bites/ui/screen/categories_screen.dart';
import 'package:dail_bites/ui/screen/home_screen.dart';
import 'package:dail_bites/ui/screen/wishlist_screen.dart';
import 'package:dail_bites/ui/widgets/appbars.dart';
import 'package:flutter/material.dart';

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
    final List<Widget> pages = [
      HomeScreen(
        query: widget.query,
      ),
      CategoriesScreen(),
      const WishlistScreen(),
      const AccountScreen()
    ];
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _selectedIndex == 0 ? const GenericAppBar() : null,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[900],
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
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

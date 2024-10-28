import 'package:flutter/material.dart';
import 'dart:math';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({super.key});

  // List of predefined colors for random selection
  final List<Color> _colors = [
    Colors.blue[400] ?? Colors.blue,
    Colors.purple[400] ?? Colors.purple,
    Colors.orange[400] ?? Colors.orange,
    Colors.green[400] ?? Colors.green,
    Colors.pink[400] ?? Colors.pink,
    Colors.teal[400] ?? Colors.teal,
    Colors.indigo[400] ?? Colors.indigo,
    Colors.red[400] ?? Colors.red,
  ];

  // Get random color from the colors list
  Color _getRandomColor() {
    return _colors[Random().nextInt(_colors.length)];
  }

  final List<Map<String, dynamic>> categories = [
    {'name': 'Electronics', 'icon': Icons.devices, 'items': '2,543 items'},
    {
      'name': 'Phone Accessories',
      'icon': Icons.phone_android,
      'items': '1,234 items'
    },
    {'name': 'Fish BBQ', 'icon': Icons.set_meal, 'items': '867 items'},
    {'name': 'Fish Feed', 'icon': Icons.pets, 'items': '654 items'},
    {
      'name': 'Pet Supplies',
      'icon': Icons.pets_outlined,
      'items': '1,432 items'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Categories',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.grey[800],
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300] ?? Colors.grey,
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search categories',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Featured Categories Header
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore our wide range of products',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final Color randomColor = _getRandomColor();

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Add navigation
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background Icon
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Icon(
                                  category['icon'] as IconData,
                                  size: 100,
                                  color: randomColor.withOpacity(0.1),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: randomColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        category['icon'] as IconData,
                                        color: randomColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      category['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category['items'] as String,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }
}

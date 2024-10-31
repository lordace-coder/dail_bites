import 'package:dail_bites/bloc/category_bloc.dart';
import 'package:dail_bites/bloc/category_state.dart';
import 'package:dail_bites/ui/pages/product_category_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({super.key});

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

  // List of category icons
  final List<IconData> _categoryIcons = [
    Icons.lunch_dining,
    Icons.local_pizza,
    Icons.breakfast_dining,
    Icons.restaurant,
    Icons.coffee,
    Icons.fastfood,
    Icons.cake,
    Icons.local_bar,
  ];

  Color _getRandomColor() {
    return _colors[Random().nextInt(_colors.length)];
  }

  IconData _getRandomIcon() {
    return _categoryIcons[Random().nextInt(_categoryIcons.length)];
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        (context.watch<CategoryCubit>().state as CategoryLoaded).categories;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Export Different Categories',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
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
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    final Color randomColor = _getRandomColor();
                    final IconData randomIcon = _getRandomIcon();

                    return Hero(
                      tag: 'category_${category.category}',
                      child: Material(
                        color: Colors.transparent,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: InkWell(
                            onTap: () {
                              // Add navigation with scale animation
                              AppRouter().navigateTo(CategoryProductsScreen(
                                  categoryId: category.id,
                                  categoryName: category.category));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    randomColor.withOpacity(0.7),
                                    randomColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: randomColor.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Background pattern
                                  Positioned(
                                    right: -20,
                                    top: -20,
                                    child: Icon(
                                      randomIcon,
                                      size: 100,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  // Content
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          randomIcon,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          category.category,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Explore →',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }
}

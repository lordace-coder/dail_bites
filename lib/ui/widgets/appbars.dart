import 'package:dail_bites/bloc/cart/cubit.dart';
import 'package:dail_bites/bloc/products/product_cubit.dart';
import 'package:dail_bites/ui/pages/cart_page.dart';
import 'package:dail_bites/ui/pages/home_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:dail_bites/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenericAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GenericAppBar({super.key, this.currentPage = false});

  final bool currentPage;
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<GenericAppBar> createState() => _GenericAppBarState();
}

class _GenericAppBarState extends State<GenericAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _animationController.forward();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    _animationController.reverse();
  }

  void _handleSearch() {
    final String searchQuery = _searchController.text;
    print('Performing search for: $searchQuery');
    if (!widget.currentPage) {
      AppRouter().navigateAndRemoveUntil(HomePage(
        query: searchQuery,
      ));
    } else {
      context.read<ProductCubit>().searchProducts(searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.white,
      elevation: 0,
      backgroundColor: AppTheme().primary,
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _stopSearch,
            )
          : null,
      title: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center, // Center align the stack contents
            children: [
              Opacity(
                opacity: 1 - _animation.value,
                child: const Text(
                  'ScreenSteaks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Opacity(
                opacity: _animation.value,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    // Center the TextField
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical:
                          TextAlignVertical.center, // Center text vertically
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search products...',
                        hintStyle: const TextStyle(
                          height:
                              1.1, // Adjust this value to fine-tune vertical alignment
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(
                              top: 2), // Fine-tune icon alignment
                          child: Icon(Icons.search),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              top: 2), // Fine-tune icon alignment
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _handleSearch,
                          ),
                        ),
                        isDense: true, // Makes the TextField more compact
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0, // Reduce vertical padding
                        ),
                      ),
                      onSubmitted: (_) => _handleSearch(),
                      enabled: _isSearching,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        Builder(builder: (context) {
          final cartCount = context.watch<CartCubit>().getItemCount();
          return GestureDetector(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    AppRouter().navigateTo(const CartPage());
                  },
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
      ],
    );
  }
}

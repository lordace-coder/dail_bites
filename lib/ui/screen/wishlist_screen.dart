import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dail_bites/bloc/cart/cubit.dart';
import 'package:dail_bites/bloc/category_bloc.dart';
import 'package:dail_bites/bloc/category_state.dart';
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/bloc/wishlist/state.dart';
import 'package:dail_bites/ui/pages/home_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:dail_bites/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double _scrollOffset = 0;
  bool _showDeleteDialog = false;
  String? _itemToDelete;
  Product? _productToDelete;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(String id) {
    setState(() {
      _showDeleteDialog = true;
      _itemToDelete = id;
    });
  }

  List get items {
    try {
      final wishlistCubit = context.read<WishlistCubit>();
      wishlistCubit.fetchWishlist();
      final items = wishlistCubit.state.products;
      return items;
    } catch (e) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Enhanced App Bar
                // App Bar
                SliverAppBar(
                  floating: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Text(
                    'WishList',
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

                // Empty State
                if (items.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(theme),
                  ),

                // Wishlist Items
                if (items.isNotEmpty) ...[
                  _buildWishlistItems(theme),
                ],
              ],
            ),

            // Delete Confirmation Dialog
            if (_showDeleteDialog) _buildDeleteDialog(theme, _productToDelete),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline_rounded,
            size: 80,
            color: AppTheme().secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Wishlist is Empty',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding items you love to your wishlist',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to products or categories
              AppRouter().navigateAndRemoveUntil(const HomePage());
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme().secondary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPattern() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: PatternPainter(
            animation: _controller,
            scrollOffset: _scrollOffset,
          ),
        );
      },
    );
  }

  Widget _buildAppBarContent(ThemeData theme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            // Enhanced Stats Row
            const SizedBox(height: 24),
            // Enhanced Title Section
            _buildTitleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Wishlist',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.favorite_rounded,
              color: Colors.red[400],
              size: 32,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your curated collection of desired items',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip('All', true),
            _buildFilterChip('Electronics', false),
            _buildFilterChip('Furniture', false),
            _buildFilterChip('Fashion', false),
            _buildFilterChip('Books', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool selected) {
          // Implement filter logic
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        elevation: 2,
        pressElevation: 4,
      ),
    );
  }

  Widget _buildWishlistItems(ThemeData theme) {
    final items = context.read<WishlistCubit>().state.products;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _buildEnhancedWishlistItem(item, theme);
          },
          childCount: items.length,
        ),
      ),
    );
  }

// String getImageUrl(){}
  Widget _buildEnhancedWishlistItem(Product item, ThemeData theme) {
    final discountPriceedPrice = item.discountPrice != null
        ? item.price * (1 - item.discountPrice! / 100)
        : item.price;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (direction) async {
          // remove item from wishlist
          await context.read<WishlistCubit>().removeFromWishlist(item);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Hero(
                        tag: 'wishlist_${item.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                          ),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl.toString(),
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Enhanced Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E1E1E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      //fetch category from cubit using the id
                                      (context.read<CategoryCubit>().state
                                              as CategoryLoaded)
                                          .categories
                                          .firstWhere((cat) =>
                                              cat.id == item.categoryId)
                                          .category,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₦${item.discountPrice?.ceil().toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            if (item.discountPrice != null)
                              Text(
                                '₦${item.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Availability and Date Added

                    const SizedBox(height: 20),
                    // Enhanced Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrimaryButton(
                            onPressed: () {
                              // Add to cart logic
                              context.read<CartCubit>().addToCart(item);
                            },
                            icon: Icons.shopping_cart_outlined,
                            label: 'Add to Cart',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          onPressed: () {
                            _productToDelete = item;
                            _showDeleteConfirmation(item.id);
                          },
                          icon: Icons.delete_outline_rounded,
                          backgroundColor: Colors.red[50]!,
                          iconColor: Colors.red[700]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildSuggestedItemCard(ThemeData theme) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey[100],
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Item',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₦199.99',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _scrollOffset > 100 ? 10 : 0,
            sigmaY: _scrollOffset > 100 ? 10 : 0,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Navigate to products
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteDialog(ThemeData theme, Product? product) {
    if (product == null) {
      setState(() {
        _showDeleteDialog = false;
        _itemToDelete = null;
      });
    }
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.red[400],
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Remove from Wishlist?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This item will be removed from your wishlist.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showDeleteDialog = false;
                          _itemToDelete = null;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_productToDelete != null) {
// remove item
                          context
                              .read<WishlistCubit>()
                              .removeFromWishlist(product!);
                          setState(() {
                            _showDeleteDialog = false;
                            _itemToDelete = null;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _calculateTotalValue() {
    final items = context.read<WishlistCubit>().state.products;

    final total = items.fold<double>(
      0,
      (sum, item) {
        final price = item.discountPrice != null
            ? item.price * (1 - item.discountPrice! / 100)
            : item.price;
        return sum + price;
      },
    );
    return total.toStringAsFixed(2);
  }

  String _calculateTotalSavings() {
    final items = context.read<WishlistCubit>().state.products;

    final savings = items.fold<double>(
      0,
      (sum, item) {
        if (item.discountPrice != null) {
          return sum + (item.price * item.discountPrice! / 100);
        }
        return sum;
      },
    );
    return savings.toStringAsFixed(2);
  }
}

class PatternPainter extends CustomPainter {
  final Animation<double> animation;
  final double scrollOffset;

  PatternPainter({
    required this.animation,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pattern = Path();
    for (var i = 0; i < 5; i++) {
      final offset = (animation.value + i / 5) * 2 * pi;
      pattern.addOval(
        Rect.fromCenter(
          center: Offset(
            size.width * (0.5 + 0.3 * cos(offset)),
            size.height * (0.5 + 0.3 * sin(offset)),
          ),
          width: size.width * 0.4,
          height: size.height * 0.4,
        ),
      );
    }

    canvas.drawPath(pattern, paint);
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        scrollOffset != oldDelegate.scrollOffset;
  }
}

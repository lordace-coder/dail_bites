import 'package:dail_bites/bloc/cart/cubit.dart';
import 'package:dail_bites/bloc/cart/state.dart';
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/ui/widgets/appbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDisplay extends StatefulWidget {
  final Product product;

  const ProductDisplay({super.key, required this.product});

  @override
  State<ProductDisplay> createState() => _ProductDisplayState();
}

class _ProductDisplayState extends State<ProductDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool isFavorite = false;
  int count = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  double _calculateDiscount() {
    if (widget.product.discountPrice != null) {
      return ((widget.product.price - widget.product.discountPrice!) /
              widget.product.price) *
          100;
    }
    return 0;
  }

  void _incrementCount() {
    if (widget.product.count != null && count < widget.product.count!) {
      setState(() {
        count++;
      });
    }
  }

  void _decrementCount() {
    if (count > 1) {
      setState(() {
        count--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'product-${widget.product.id}',
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          child: Image.network(
                            widget.product.imageUrl.toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isFavorite
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                _formatPrice(widget.product.discountPrice ??
                                    widget.product.price.toDouble()),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: widget.product.discountPrice != null
                                      ? Colors.red.shade600
                                      : Colors.black,
                                ),
                              ),
                              if (widget.product.discountPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  _formatPrice(widget.product.price.toDouble()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (widget.product.description != null) ...[
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.description!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (widget.product.count != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.product.count! > 0
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: widget.product.count?.toInt() != 0
                                  ? Text(
                                      widget.product.count! > 0
                                          ? 'In Stock ${widget.product.count?.toInt()}'
                                          : 'Out of Stock',
                                      style: TextStyle(
                                        color: widget.product.count! > 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    )
                                  : Container(),
                            ),
                          const SizedBox(height: 16),
                          // Quantity Counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCounterButton(
                                icon: Icons.remove,
                                onPressed: _decrementCount,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade100,
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildCounterButton(
                                icon: Icons.add,
                                onPressed: _incrementCount,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              onTap: () {
                context
                    .read<CartCubit>()
                    .addToCart(widget.product, quantity: count);
              },
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).primaryColor,
        iconSize: 18,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
}

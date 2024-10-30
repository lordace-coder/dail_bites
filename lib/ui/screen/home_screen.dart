import 'package:dail_bites/bloc/category_bloc.dart';
import 'package:dail_bites/bloc/category_state.dart';
import 'package:dail_bites/bloc/products/product_cubit.dart';
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:dail_bites/ui/pages/product_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.query});
  final String? query;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  bool loading = false;
  final ScrollController _scrollController = ScrollController();

  void handleSelectedCategory(String selection, String id) {
    final productCubit = context.read<ProductCubit>();
    print([selectedCategory == selection]);
    // reset if previously selected
    if (selectedCategory == selection) {
      setState(() {
        selectedCategory = 'all';
      });
      productCubit.fetchAllProducts();
      print([selectedCategory == selection]);
      return;
    }

    final catState = context.read<CategoryCubit>().state;
    setState(() {
      selectedCategory = selection;
    });
    if (catState is CategoryLoaded) {
      productCubit.fetchProductsByCategory(id);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<CategoryCubit>();
      final productCubit = context.read<ProductCubit>();
      // if widget.query then perform search
      if (widget.query != null) {
        print('searching for ${widget.query}');
        setState(() {
          loading = true;
        });
        productCubit.searchProducts(widget.query!).then((x) {
          setState(() {
            loading = false;
          });
        });
        return;
      }

      if (state.state is CategoryLoaded && productCubit.state is ProductLoaded)
        return;
      setState(() {
        loading = true;
      });
      state.fetchCategories();
      // fetch products
      final products = productCubit.fetchAllProducts().then((_) {
        final data = context.read<ProductCubit>().state;
        if (data is ProductLoaded) {
          print(data.products[0]);
        }
        setState(() {
          loading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await context.read<CategoryCubit>().fetchCategories();
        await context.read<ProductCubit>().fetchAllProducts();
      },
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Categories FilterChip Row
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocConsumer<CategoryCubit, CategoryState>(
                      listener: (context, state) {
                        // TODO: implement listener
                        if (state is CategoryError) {
                          showError(context,
                              title: 'Error Occured',
                              description: 'Error occured loading categories');
                        }
                      },
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return Container();
                        } else if (state is CategoryLoaded) {
                          return Row(
                            children: state.categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected:
                                      selectedCategory == category.category,
                                  label: Text(category.category),
                                  onSelected: (selected) {
                                    handleSelectedCategory(
                                        category.category, category.id);
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: Colors.blue[100],
                                  checkmarkColor: Colors.blue[900],
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ),
              // Promotional Banner
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: index == 0
                                ? [Colors.blue[700]!, Colors.blue[900]!]
                                : index == 1
                                    ? [Colors.orange[700]!, Colors.orange[900]!]
                                    : [Colors.green[700]!, Colors.green[900]!],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    index == 0
                                        ? 'New Arrivals'
                                        : index == 1
                                            ? 'Special Deals'
                                            : 'Flash Sale',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Up to 50% off',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue[900],
                                    ),
                                    child: const Text('Shop Now'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Products Grid
              BlocConsumer<ProductCubit, ProductState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  if (state is ProductLoaded) {
                    // show empty for search cases
                    if (state.products.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            children: [
                              Lottie.network(
                                  'https://lottie.host/31751360-9047-45f8-8da6-05e38e8cd3f9/TAcbqsv4mT.json',
                                  height: 200),
                              const Text('No Results '),
                              const Text('Try Refreshing Instead'),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildProductCard(product: state.products[index]),
                          childCount: state.products.length,
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter();
                },
              ),
            ],
          ),
          if (loading)
            Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  child: Lottie.asset('assets/lottie/anim1.json'),
                ))
        ],
      ),
    );
  }

  Widget _buildQuickLink(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({required Product product}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: DecorationImage(
                    image: Image.network(product.imageUrl.toString()).image),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '₦${product.price}',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₦${product.discountPrice}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        product.count!.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            AppRouter().navigateTo(ProductDisplay(
                              product: product,
                            ));
                          },
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

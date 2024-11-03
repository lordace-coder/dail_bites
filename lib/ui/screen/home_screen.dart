import 'dart:async';

import 'package:dail_bites/bloc/ads/cubit.dart';
import 'package:dail_bites/bloc/ads/state.dart';
import 'package:dail_bites/bloc/category_bloc.dart';
import 'package:dail_bites/bloc/category_state.dart';
import 'package:dail_bites/bloc/products/product_cubit.dart';
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/provider/customer_support.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';
import 'package:dail_bites/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  PageController pageController = PageController();
  void handleSelectedCategory(String selection, String id) {
    final productCubit = context.read<ProductCubit>();
    // reset if previously selected
    if (selectedCategory == selection) {
      setState(() {
        selectedCategory = 'all';
      });
      productCubit.fetchAllProducts();
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

  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<CategoryCubit>();
      final productCubit = context.read<ProductCubit>();
      // check if ad hasnt been loaded then load ad
      final adCubit = context.read<AdsCubit>();
      if (adCubit.state is! AdsLoaded) {
        adCubit.fetchRandomAds();
      }
      // if widget.query then perform search
      if (widget.query != null) {
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

      if (state.state is CategoryLoaded &&
          productCubit.state is ProductLoaded) {
        return;
      }
      setState(() {
        loading = true;
      });
      state.fetchCategories();
      // fetch products
      productCubit.fetchAllProducts().then((_) {
        setState(() {
          loading = false;
        });
      });
    });
  }

  int get getAdsLength {
    try {
      return (context.read<AdsCubit>().state as AdsLoaded).ads.length;
    } catch (e) {}
    return 0;
  }

  void startAutoSlide(PageController pageController, int itemCount) {
    // Cancel any existing timer to avoid duplicates
    print(itemCount);
    void createTimer() {
      timer?.cancel();

      // Only create timer if we have more than one page
      if (itemCount > 1) {
        timer = Timer.periodic(const Duration(seconds: 7), (Timer t) {
          // Check if controller is still active
          if (pageController.hasClients) {
            final currentPage = pageController.page?.round() ?? 0;

            // Calculate next page, going back to 0 if at end
            final nextPage = currentPage + 1 >= itemCount ? 0 : currentPage + 1;

            try {
              pageController.animateToPage(
                nextPage,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              // Handle any animation errors
              timer?.cancel();
            }
          }
        });
      }
    }

    createTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
              BlocConsumer<AdsCubit, AdsState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  if (state is AdsLoaded && state.ads.isNotEmpty) {
                    // increment ad view
                    startAutoSlide(pageController, getAdsLength);

                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: state.ads.length,
                          itemBuilder: (context, index) {
                            final adData = context
                                .read<AdsCubit>()
                                .getAdData(state.ads[index]);
                            return Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(
                                          0.5), // Adjust opacity between 0.0 and 1.0
                                      BlendMode.darken,
                                    ),
                                    image:
                                        Image.network(adData!['image']).image,
                                    fit: BoxFit.cover),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 20,
                                    top: 40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          adData['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.86,
                                          child: Text(
                                            adData['description'],
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await launchLink(
                                                adData['location']);
                                            context
                                                .read<AdsCubit>()
                                                .incrementClicks(adData['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.blue[900],
                                          ),
                                          child: Text(adData['call_to_action']
                                                  .toString()
                                                  .isEmpty
                                              ? 'Discover More'
                                              : adData['call_to_action']
                                                  .toString()),
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
                    );
                  }
                  return const SliverToBoxAdapter();
                },
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
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childCount: state.products
                            .length, // Replace with actual product count
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: state.products[index],
                          );
                        },
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

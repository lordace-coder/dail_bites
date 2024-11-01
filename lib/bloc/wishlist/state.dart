// Wishlist Cubit
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/bloc/wishlist/cubit.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final PocketBase pb;

  WishlistCubit({required this.pb}) : super(WishlistInitial());

  // Fetch user's wishlist
  Future<void> fetchWishlist() async {
    final userId = (pb.authStore.model as RecordModel).id;
    try {
      emit(WishlistLoading(products: state.products));

      final records = await pb.collection('wishlist').getFullList(
            filter: 'user = "$userId"',
            expand: 'product',
          );

      final products = records
          .map((record) {
            final productData = record.expand['product']?[0];
            if (productData == null) return null;

            return Product.fromJson({
              'id': productData.id,
              'title': productData.data['title'],
              'description': productData.data['description'],
              'category': productData.data['category'],
              'price': productData.data['price'],
              'discount_price': productData.data['discount_price'],
              'count': productData.data['count'],
              'image': Uri.parse(productData.data['image']),
            });
          })
          .whereType<Product>() // Remove null values
          .toList();

      emit(WishlistLoaded(products: products));
    } catch (e) {
      print('error fetching wishlist $e');

      emit(WishlistError(
        error: 'Failed to fetch wishlist}',
        products: state.products,
      ));
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(Product product) async {
    final userId = (pb.authStore.model as RecordModel).id;

    try {
      emit(WishlistLoading(products: state.products));

      await pb.collection('wishlist').create(body: {
        'user': userId,
        'product': product.id,
      });

      final updatedProducts = [...state.products, product];
      emit(WishlistLoaded(products: updatedProducts));
      showSucces(
          title: 'Added Succesfully',
          description: 'Product has been succesfully added to your wishlist');
    } catch (e) {
      emit(WishlistError(
        error: 'Failed to add to wishlist: ${e.toString()}',
        products: state.products,
      ));
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(Product product) async {
    final userId = (pb.authStore.model as RecordModel).id;
    print('user = "$userId" && product = "${product.id}"');
    try {
      emit(WishlistLoading(products: state.products));

      // Find and delete the wishlist record
      final record = await pb.collection('wishlist').getFirstListItem(
            'user = "$userId" && product.id = "${product.id}"',
          );
      await pb.collection('wishlist').delete(record.id);

      final updatedProducts =
          state.products.where((p) => p.id != product.id).toList();

      emit(WishlistLoaded(products: updatedProducts));
    } catch (e) {
      print(e);
      emit(WishlistError(
        error: 'Failed to remove from wishlist: ${e.toString()}',
        products: state.products,
      ));
    }
  }

  // Check if product is in wishlist
  bool isInWishlist(Product product) {
    return state.products.any((p) => p.id == product.id);
  }
}

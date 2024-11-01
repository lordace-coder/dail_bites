// Wishlist State
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';

abstract class WishlistState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  WishlistState({
    required this.products,
    this.isLoading = false,
    this.error,
  });
}

class WishlistInitial extends WishlistState {
  WishlistInitial() : super(products: []);
}

class WishlistLoading extends WishlistState {
  WishlistLoading({required super.products}) : super(isLoading: true);
}

class WishlistLoaded extends WishlistState {
  WishlistLoaded({required super.products});
}

class WishlistError extends WishlistState {
  WishlistError({required String super.error, required super.products}) {
    showError(null,
        title: 'Sorry Error Occured',
        description: 'Server error while fetching wishlist');
  }
}

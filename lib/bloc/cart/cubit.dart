import 'package:dail_bites/bloc/cart/state.dart';
import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/provider/paystack_payment.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required this.pb}) : super(CartInitial());
  final PocketBase pb;
  final List<CartItem> items = [];

  void addToCart(Product product, {int quantity = 1}) {
    final cartItem = CartItem(
      id: product.id,
      name: product.title,
      price: product.price.toDouble(),
      quantity: quantity,
      image: product.imageUrl.toString(),
      discountPrice: product.discountPrice!.toInt(),
    );

    final existingItemIndex = items.indexWhere((i) => i.id == cartItem.id);

    if (existingItemIndex != -1) {
      // Item exists, update quantity
      items[existingItemIndex] = items[existingItemIndex].copyWith(
        quantity: items[existingItemIndex].quantity + quantity,
      );
    } else {
      // New item, add to cart
      items.add(cartItem);
    }
    showSucces(
        title: 'Succesfull',
        description: 'Product has been added to your cart');
    _emitLoadedState();
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    items.removeWhere((item) => item.id == itemId);
    _emitLoadedState();
  }

  // Update item quantity
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      items[index] = items[index].copyWith(quantity: newQuantity);
      _emitLoadedState();
    }
  }

  // Clear cart
  void clearCart() {
    items.clear();
    _emitLoadedState();
  }

  // Get cart total
  double getTotal() {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Get item count
  int getItemCount() {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Check if cart has specific item
  bool hasItem(String itemId) {
    return items.any((item) => item.id == itemId);
  }

  // Get specific item quantity
  int getItemQuantity(String itemId) {
    final item = items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => CartItem(
          id: itemId, name: '', price: 0, quantity: 0, discountPrice: 0),
    );
    return item.quantity;
  }

  // Modified complete order method
  Future<void> completeOrder(BuildContext context,
      {required String location,
      required String contact,
      required double amount}) async {
    try {
      emit(CartLoading()); // Add this state to your CartState

      // Get current authenticated user
      final currentUser = pb.authStore.model?.id;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Prepare product IDs from cart items
      final productIds = items.map((item) => item.id).toList();

      // Create the order in PocketBase
      final body = {
        "owner": currentUser,
        "products": productIds,
        "location": location,
        "contact": contact,
        'paid': false,
      };

      final createdData = await pb.collection('order').create(body: body);

      // Clear the cart after successful order

      // Show success message
      showSucces(
        title: 'Order Placed',
        description: 'Your order has been successfully placed!',
      );
      // COLLECT PAYMENT HERE
      await PaystackPaymentService(pb).makePayment(
          email: (pb.authStore.model as RecordModel).getStringValue('email'),
          amount: amount,
          context: context,
          onSuccess: () {
            clearCart();
          },
          orderId: createdData.id);
      emit(CartOrderSuccess()); // Add this state to your CartState
    } catch (e) {
      emit(
          CartError(message: e.toString())); // Add this state to your CartState
      showError(
        null,
        title: 'Order Failed',
        description: 'Failed to place order: ${e.toString()}',
      );
    }
  }

  // Helper method to emit loaded state
  void _emitLoadedState() {
    emit(CartLoaded(
      items: List.from(items),
      total: getTotal(),
    ));
  }
}

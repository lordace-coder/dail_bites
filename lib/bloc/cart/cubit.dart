import 'package:dail_bites/bloc/cart/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  final List<CartItem> _items = [];

  // Add item to cart
  void addToCart(CartItem item) {
    final existingItemIndex = _items.indexWhere((i) => i.id == item.id);

    if (existingItemIndex != -1) {
      // Item exists, update quantity
      _items[existingItemIndex] = _items[existingItemIndex].copyWith(
        quantity: _items[existingItemIndex].quantity + item.quantity,
      );
    } else {
      // New item, add to cart
      _items.add(item);
    }

    _emitLoadedState();
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _emitLoadedState();
  }

  // Update item quantity
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      _emitLoadedState();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _emitLoadedState();
  }

  // Get cart total
  double getTotal() {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Get item count
  int getItemCount() {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Check if cart has specific item
  bool hasItem(String itemId) {
    return _items.any((item) => item.id == itemId);
  }

  // Get specific item quantity
  int getItemQuantity(String itemId) {
    final item = _items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => CartItem(id: itemId, name: '', price: 0, quantity: 0),
    );
    return item.quantity;
  }

  // Complete order (placeholder)
  Future<void> completeOrder() async {
    // TODO: Implement order completion logic
    // This could include:
    // - Validating cart items
    // - Processing payment
    // - Creating order in backend
    // - Clearing cart after successful order
  }

  // Helper method to emit loaded state
  void _emitLoadedState() {
    emit(CartLoaded(
      items: List.from(_items),
      total: getTotal(),
    ));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? image,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
    );
  }
}

// State
abstract class CartState {
  const CartState();
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  const CartLoaded({
    required this.items,
    required this.total,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartLoaded && 
           other.items == items &&
           other.total == total;
  }

  @override
  int get hashCode => items.hashCode ^ total.hashCode;
}

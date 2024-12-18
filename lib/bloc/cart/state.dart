// ignore_for_file: public_member_api_docs, sort_constructors_first

// Cart Item Model
import 'dart:convert';

import 'package:dail_bites/ui/pages/completed_transaction_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:flutter/widgets.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final int discountPrice;
  final String? image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.discountPrice,
    this.image,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    int? discountPrice,
    String? image,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discountPrice: discountPrice ?? this.discountPrice,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'discountPrice': discountPrice,
      'image': image,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      discountPrice: map['discountPrice'] as int,
      image: map['image'] != null ? map['image'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItem.fromJson(String source) =>
      CartItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CartItem(id: $id, name: $name, price: $price, quantity: $quantity, discountPrice: $discountPrice, image: $image)';
  }

  @override
  bool operator ==(covariant CartItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.discountPrice == discountPrice &&
        other.image == image;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        discountPrice.hashCode ^
        image.hashCode;
  }
}

// State

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  CartLoaded({
    required this.items,
    required this.total,
  });
}

class CartOrderSuccess extends CartState {
  final String orderId;
  CartOrderSuccess({
    required this.orderId,
  }) {
    AppRouter().navigateTo(OrderReceipt(
      orderId: orderId,
    ));
  }
}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}

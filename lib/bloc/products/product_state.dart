// ignore_for_file: public_member_api_docs, sort_constructors_first

// product_state.dart
import 'dart:convert';

class Product {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final int price;
  final double? discountPrice;
  final double? count;
  final Uri imageUrl;

  const Product({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.price,
    this.discountPrice,
    this.count,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['category'] as String,
      price: json['price'] as int,
      discountPrice: json['discount_price']?.toDouble(),
      count: json['count']?.toDouble(),
      imageUrl: json['image'] as Uri,
    );
  }

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.price == price &&
        other.discountPrice == discountPrice &&
        other.count == count &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        categoryId.hashCode ^
        price.hashCode ^
        discountPrice.hashCode ^
        count.hashCode ^
        imageUrl.hashCode;
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    int? price,
    double? discountPrice,
    double? count,
    Uri? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      count: count ?? this.count,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'discountPrice': discountPrice,
      'count': count,
      'imageUrl': imageUrl.toString(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      categoryId: map['categoryId'] as String,
      price: map['price'] as int,
      discountPrice:
          map['discountPrice'] != null ? map['discountPrice'] as double : null,
      count: map['count'] != null ? map['count'] as double : null,
      imageUrl: Uri.parse(map['imageUrl'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Product(id: $id, title: $title, description: $description, categoryId: $categoryId, price: $price, discountPrice: $discountPrice, count: $count, imageUrl: $imageUrl)';
  }
}

abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductLoaded &&
          runtimeType == other.runtimeType &&
          products == other.products;

  @override
  int get hashCode => products.hashCode;
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

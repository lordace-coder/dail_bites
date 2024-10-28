// product_state.dart
class Product {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final int price;
  final double? discountPrice;
  final double? count;
  final String imageUrl;

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
      imageUrl: json['image'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          categoryId == other.categoryId &&
          price == other.price &&
          discountPrice == other.discountPrice &&
          count == count &&
          imageUrl == imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      categoryId.hashCode ^
      price.hashCode ^
      discountPrice.hashCode ^
      count.hashCode ^
      imageUrl.hashCode;
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

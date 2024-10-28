// category_state.dart
class Category {
  final String id;
  final String category;

  const Category({
    required this.id,
    required this.category,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      category: json['category'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category;

  @override
  int get hashCode => id.hashCode ^ category.hashCode;
}

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded(this.categories);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryLoaded &&
          runtimeType == other.runtimeType &&
          categories == other.categories;

  @override
  int get hashCode => categories.hashCode;
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
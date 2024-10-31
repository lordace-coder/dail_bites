import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:dail_bites/ui/widgets/toasts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class ProductCubit extends Cubit<ProductState> {
  final PocketBase pocketBase;
  ProductCubit({required this.pocketBase}) : super(ProductInitial());

  Future<void> fetchAllProducts() async {
    try {
      emit(ProductLoading());
      final records = await pocketBase.collection('products').getFullList();
      final products = records
          .map((record) => Product.fromJson({
                'id': record.id,
                'title': record.data['title'],
                'description': record.data['description'],
                'category': record.data['category'],
                'price': record.data['price'],
                'discount_price': record.data['discount_price'],
                'count': record.data['count'],
                'image': pocketBase.files.getUrl(record, record.data['image']),
              }))
          .toList();
      print(products[0]);
      emit(ProductLoaded(products));
    } catch (e) {
      showError(null,
          title: 'Error Occured', description: 'Connection or server error');
      emit(const ProductLoaded([]));
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      emit(ProductLoading());
      final records = await pocketBase.collection('products').getFullList(
            filter: 'category = "$categoryId"',
          );
      final products = records
          .map((record) => Product.fromJson({
                'id': record.id,
                'title': record.data['title'],
                'description': record.data['description'],
                'category': record.data['category'],
                'price': record.data['price'],
                'discount_price': record.data['discount_price'],
                'count': record.data['count'],
                'image': pocketBase.files.getUrl(record, record.data['image']),
              }))
          .toList();
      emit(ProductLoaded(products));
    } catch (e) {
      print(e);
      emit(ProductError(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      emit(ProductLoading());

      // Trim and sanitize the search query
      final sanitizedQuery = query.trim();

      if (sanitizedQuery.isEmpty) {
        // If search query is empty, fetch all products
        await fetchAllProducts();
        return;
      }

      // Create a filter using PocketBase's case-insensitive search
      final filter =
          'title ~ "$sanitizedQuery" || description ~ "$sanitizedQuery"';

      final records = await pocketBase.collection('products').getFullList(
            filter: filter,
            sort: '-created', // Optional: sort by creation date, newest first
          );

      final products = records
          .map((record) => Product.fromJson({
                'id': record.id,
                'title': record.data['title'],
                'description': record.data['description'],
                'category': record.data['category'],
                'price': record.data['price'],
                'discount_price': record.data['discount_price'],
                'count': record.data['count'],
                'image': pocketBase.files.getUrl(record, record.data['image']),
              }))
          .toList();

      emit(ProductLoaded(products));
    } catch (e) {
      print('Search error: $e');
      emit(ProductError(e.toString()));
    }
  }

  // Optional: Paginated search with correct filter syntax
  Future<void> searchProductsWithPagination(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      emit(ProductLoading());

      final sanitizedQuery = query.trim();

      if (sanitizedQuery.isEmpty) {
        await fetchAllProducts();
        return;
      }

      // Updated filter syntax for PocketBase
      final filter =
          'title ~ "$sanitizedQuery" || description ~ "$sanitizedQuery"';

      final resultList = await pocketBase.collection('products').getList(
            page: page,
            perPage: perPage,
            filter: filter,
            sort: '-created',
          );

      final products = resultList.items
          .map((record) => Product.fromJson({
                'id': record.id,
                'title': record.data['title'],
                'description': record.data['description'],
                'category': record.data['category'],
                'price': record.data['price'],
                'discount_price': record.data['discount_price'],
                'count': record.data['count'],
                'image': pocketBase.files.getUrl(record, record.data['image']),
              }))
          .toList();

      emit(ProductLoaded(products));
    } catch (e) {
      print('Paginated search error: $e');
      emit(ProductError(e.toString()));
    }
  }
}

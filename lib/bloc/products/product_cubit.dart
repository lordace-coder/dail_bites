import 'package:dail_bites/bloc/products/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class ProductCubit extends Cubit<ProductState> {
  final PocketBase pocketBase;

  ProductCubit({required this.pocketBase}) : super(ProductInitial());

  Future<void> fetchAllProducts() async {
    try {
      emit(ProductLoading());

      final records = await pocketBase
          .collection('products')
          .getFullList();

      final products = records.map((record) => Product.fromJson({
            'id': record.id,
            'title': record.data['title'],
            'description': record.data['description'],
            'category': record.data['category'],
            'price': record.data['price'],
            'discount_price': record.data['discount_price'],
            'count': record.data['count'],
            'image': pocketBase.files.getUrl(record, record.data['image']),
          })).toList();

      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      emit(ProductLoading());

      final records = await pocketBase
          .collection('products')
          .getFullList(
            filter: 'category = "$categoryId"',
          );

      final products = records.map((record) => Product.fromJson({
            'id': record.id,
            'title': record.data['title'],
            'description': record.data['description'],
            'category': record.data['category'],
            'price': record.data['price'],
            'discount_price': record.data['discount_price'],
            'count': record.data['count'],
            'image': pocketBase.files.getUrl(record, record.data['image']),
          })).toList();

      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
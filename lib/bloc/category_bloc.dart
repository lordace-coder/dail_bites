import 'package:dail_bites/bloc/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final PocketBase pocketBase;

  CategoryCubit({required this.pocketBase}) : super(CategoryInitial());

  Future<void> fetchCategories() async {
    if (state is CategoryLoaded) {
      return;
    }
    try {
      emit(CategoryLoading());

      final records = await pocketBase.collection('categories').getFullList();
      final categories = records
          .map((record) => Category.fromJson({
                'id': record.id,
                'category': record.data['category'],
              }))
          .toList();

      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}

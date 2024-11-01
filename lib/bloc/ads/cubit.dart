// Cubit
import 'package:dail_bites/bloc/ads/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class AdsCubit extends Cubit<AdsState> {
  final PocketBase pb;

  AdsCubit({required this.pb}) : super(AdsInitial());

  Future<void> fetchRandomAds() async {
    if (state is AdsLoaded) {
      return;
    }
    try {
      emit(AdsLoading());

      final records = await pb.collection('ads').getList(
            page: 1,
            perPage: 3,
          );
      // for (var element in records.items) {
      //   incrementViews(element.data['id']);
      // }

      emit(AdsLoaded(records.items));

      for (var i = 0; i < records.items.length; i++) {
        incrementViews(records.items[i].id);
      }
    } catch (e) {
      emit(AdsError(e.toString()));
    }
  }

  // Helper method to get ad data
  Map<String, dynamic>? getAdData(RecordModel record) {
    try {
      return {
        'id': record.id,
        'title': record.getStringValue('title'),
        'description': record.getStringValue('description'),
        'location': record.getStringValue('location'),
        'clicks': record.getDoubleValue('clicks'),
        'views': record.getDoubleValue('views'),
        'image': pb.files.getUrl(record, record.data['image']).toString(),
      };
    } catch (e) {
      return null;
    }
  }

  // Method to increment views
  Future<void> incrementViews(String adId) async {
    try {
      final record = await pb.collection('ads').getOne(adId);
      final currentViews = record.getDoubleValue('views');
      await pb.collection('ads').update(adId, body: {
        'views': currentViews + 1,
      });
    } catch (e) {
      // Handle error silently or emit a specific state if needed
    }
  }

  // Method to increment clicks
  Future<void> incrementClicks(String adId) async {
    try {
      final record = await pb.collection('ads').getOne(adId);
      final currentClicks = record.getDoubleValue('clicks');

      await pb.collection('ads').update(adId, body: {
        'clicks': currentClicks + 1,
      });
    } catch (e) {
      // Handle error silently or emit a specific state if needed
    }
  }
}

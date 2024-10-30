// Cubit
import 'package:dail_bites/bloc/ads/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class AdsCubit extends Cubit<AdsState> {
  final PocketBase pb;

  AdsCubit({required this.pb}) : super(AdsInitial());

  Future<void> fetchRandomAds() async {
    try {
      emit(AdsLoading());

      final records = await pb.collection('ads').getList(
            page: 1,
            perPage: 3,
            sort: 'random()', // Random sorting
            filter: '', // No filter
          );

      emit(AdsLoaded(records.items));
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
        'image': record.getStringValue('image'),
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

import 'package:bloc/bloc.dart';
import 'package:dail_bites/bloc/pocketbase/pocketbase_service_state.dart';
import 'package:meta/meta.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PocketbaseServiceCubit extends Cubit<BackendService> {
  PocketbaseServiceCubit({required this.pb, required this.prefs})
      : super(BackendService(pb: pb, prefs: prefs));

  final PocketBase pb;
  final SharedPreferences prefs;
  Future<void> initialize() async {
    state.initializeAuthStore();
  }

  Future<void> logout() async {
    state.clearAuthStore();
  }
}

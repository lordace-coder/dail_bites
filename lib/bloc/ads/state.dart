import 'package:pocketbase/pocketbase.dart';

// State
abstract class AdsState {
  const AdsState();
}

class AdsInitial extends AdsState {}

class AdsLoading extends AdsState {}

class AdsLoaded extends AdsState {
  final List<RecordModel> ads;

  const AdsLoaded(this.ads);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdsLoaded && 
           other.ads == ads;
  }

  @override
  int get hashCode => ads.hashCode;
}

class AdsError extends AdsState {
  final String message;

  const AdsError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdsError && 
           other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}


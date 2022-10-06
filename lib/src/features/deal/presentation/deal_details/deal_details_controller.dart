import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase_storage_service.dart';
import '../../../../core/hotdeals_api.dart';
import '../../../../core/hotdeals_repository.dart';
import '../../domain/deal.dart';

final dealDetailsControllerProvider = StateNotifierProvider.family
    .autoDispose<DealDetailsController, AsyncValue<Deal?>, String>(
        DealDetailsController.new,
        name: 'DealDetailsControllerProvider');

class DealDetailsController extends StateNotifier<AsyncValue<Deal?>> {
  DealDetailsController(Ref ref, this.dealId)
      : _firebaseStorageService = ref.read(firebaseStorageServiceProvider),
        _hotdealsApi = ref.read(hotdealsRepositoryProvider),
        super(const AsyncValue.loading()) {
    _fetchDeal();
  }

  final String dealId;
  final FirebaseStorageService _firebaseStorageService;
  final HotdealsApi _hotdealsApi;

  void _fetchDeal() async {
    try {
      final deal = await _hotdealsApi.getDealById(dealId: dealId);
      state = AsyncValue.data(deal);
    } catch (err, stack) {
      state = AsyncValue.error(err, stackTrace: stack);
    }
  }

  void deleteDeal({
    required void Function() onFailure,
    required void Function() onSuccess,
  }) async {
    final result =
        await AsyncValue.guard(() => _hotdealsApi.deleteDeal(dealId: dealId));
    result.maybeWhen(
      data: (data) async {
        // Deletes the deal images.
        await _firebaseStorageService.deleteImagesFromUrl(
            [state.value!.coverPhoto, ...state.value!.photos ?? []]);
        onSuccess();
      },
      orElse: onFailure,
    );
  }

  void onFavoriteButtonPressed({
    required bool isFavorited,
    required void Function() onSuccess,
  }) async {
    if (isFavorited) {
      final result = await AsyncValue.guard(
          () => _hotdealsApi.unfavoriteDeal(dealId: dealId));
      result.maybeWhen(data: (_) => onSuccess, orElse: () {});
    } else {
      final result = await AsyncValue.guard(
          () => _hotdealsApi.favoriteDeal(dealId: dealId));
      result.maybeWhen(
        data: (_) {
          _fetchDeal();
          onSuccess();
        },
        orElse: () {},
      );
    }
  }

  void updateDealStatus(
    DealStatus status, {
    required void Function() onFailure,
    required void Function() onSuccess,
  }) async {
    try {
      final deal =
          await _hotdealsApi.updateDealStatus(dealId: dealId, status: status);
      state = AsyncValue.data(deal);
      onSuccess();
    } on Exception {
      onFailure();
    }
  }

  void voteDeal(
    DealVoteType voteType, {
    required void Function() onFailure,
    required void Function() onSuccess,
  }) async {
    final result = await AsyncValue.guard(
        () => _hotdealsApi.voteDeal(dealId: dealId, voteType: voteType));
    result.maybeWhen(
      data: (_) {
        _fetchDeal();
        onSuccess();
      },
      orElse: onFailure,
    );
  }
}

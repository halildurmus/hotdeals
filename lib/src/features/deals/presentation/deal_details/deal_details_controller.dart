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
    final isDeleted = await _hotdealsApi.deleteDeal(dealId: dealId);
    if (isDeleted) {
      // Deletes the deal images.
      await _firebaseStorageService.deleteImagesFromUrl(
          [state.value!.coverPhoto, ...state.value!.photos ?? []]);
      onSuccess();
    } else {
      onFailure();
    }
  }

  void onFavoriteButtonPressed({
    required bool isFavorited,
    required void Function() onSuccess,
  }) async {
    if (isFavorited) {
      final result = await _hotdealsApi.unfavoriteDeal(dealId: dealId);
      if (result) {
        onSuccess();
      }
    } else {
      final result = await _hotdealsApi.favoriteDeal(dealId: dealId);
      if (result) {
        _fetchDeal();
        onSuccess();
      }
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
    final result =
        await _hotdealsApi.voteDeal(dealId: dealId, voteType: voteType);
    if (result != null) {
      _fetchDeal();
      onSuccess();
    } else {
      onFailure();
    }
  }
}

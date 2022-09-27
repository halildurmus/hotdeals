import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hotdeals_api.dart';
import '../../../core/hotdeals_repository.dart';

final blockedUsersScreenControllerProvider =
    Provider.autoDispose<BlockedUsersScreenController>(
  (ref) => BlockedUsersScreenController(ref.read),
  name: 'BlockedUsersScreenControllerProvider',
);

class BlockedUsersScreenController {
  BlockedUsersScreenController(Reader read)
      : _hotdealsRepository = read(hotdealsRepositoryProvider);

  final HotdealsApi _hotdealsRepository;

  Future<void> unblockUser({
    required String userId,
    required VoidCallback onFailure,
    required VoidCallback onSuccess,
  }) async {
    final result = await _hotdealsRepository.unblockUser(userId: userId);
    result ? onSuccess() : onFailure();
  }
}

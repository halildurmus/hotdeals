import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/domain/my_user.dart';
import '../features/auth/domain/user_report.dart';
import '../features/browse/domain/category.dart';
import '../features/browse/domain/store.dart';
import '../features/deals/domain/comment.dart';
import '../features/deals/domain/comment_report.dart';
import '../features/deals/domain/deal.dart';
import '../features/deals/domain/deal_report.dart';
import '../features/notifications/domain/push_notification.dart';
import '../features/search/domain/search_params.dart';
import '../features/search/domain/search_response.dart';
import '../features/search/domain/search_suggestion.dart';

abstract class HotdealsApi {
  Future<bool> blockUser({required String userId});

  Future<bool> unblockUser({required String userId});

  Future<bool> favoriteDeal({required String dealId});

  Future<bool> unfavoriteDeal({required String dealId});

  Future<Deal?> postDeal({required Deal deal});

  Future<Deal?> updateDeal({required Deal deal});

  Future<bool> deleteDeal({required String dealId});

  Future<bool> sendPushNotification({required PushNotification notification});

  Future<bool> reportComment({
    required String dealId,
    required CommentReport report,
  });

  Future<bool> reportDeal({required DealReport report});

  Future<bool> reportUser({required UserReport report});

  Future<Comments?> getDealComments({
    required String dealId,
    int? page,
    int? size,
  });

  Future<int?> getDealCommentCount({required String dealId});

  Future<Comment?> postComment({
    required String dealId,
    required Comment comment,
  });

  Future<List<Category>> getCategories();

  Future<List<Store>> getStores();

  Future<MyUser> createMongoUser(User user);

  Future<MyUser?> getMongoUser();

  Future<List<MyUser>?> getBlockedUsers();

  Future<MyUser> getUserExtendedById({required String id});

  Future<MyUser> getUserById({required String id});

  Future<MyUser> getUserByUid({required String uid});

  Future<bool> addFCMToken({required String deviceId, required String token});

  Future<bool> deleteFCMToken({required String token});

  Future<Deal> updateDealStatus({
    required String dealId,
    required DealStatus status,
  });

  Future<MyUser> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  });

  Future<MyUser> updateUserNickname({
    required String userId,
    required String nickname,
  });

  Future<List<Deal>> getUserFavorites({int? page, int? size});

  Future<SearchSuggestion> getDealSuggestions({required String query});

  Future<List<Deal>> getUserDeals({int? page, int? size});

  Future<List<Deal>> getDealsByCategory({
    required String category,
    int? page,
    int? size,
  });

  Future<SearchResponse> searchDeals({required SearchParams searchParams});

  Future<List<Deal>> getDealsByStoreId({
    required String storeId,
    int? page,
    int? size,
  });

  Future<List<Deal>> getLatestDeals({int? page, int? size});

  Future<List<Deal>> getMostLikedDeals({int? page, int? size});

  Future<int?> getNumberOfCommentsPostedByUser({required String userId});

  Future<int?> getNumberOfDealsByStoreId({required String storeId});

  Future<int?> getNumberOfDealsPostedByUser({required String userId});

  Future<Deal?> getDealById({required String dealId});

  Future<Deal?> voteDeal({
    required String dealId,
    required DealVoteType voteType,
  });
}

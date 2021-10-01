import 'package:firebase_auth/firebase_auth.dart';

import '../models/category.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/deal_report.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/search_hit.dart';
import '../models/store.dart';
import '../models/user_report.dart';
import '../models/vote_type.dart';

/// An abstract class that used for communicating with the backend.
abstract class SpringService {
  Future<bool> blockUser({required String userId});

  Future<bool> unblockUser({required String userUid});

  Future<bool> favoriteDeal({required String dealId});

  Future<bool> unfavoriteDeal({required String dealId});

  Future<Deal?> postDeal({required Deal deal});

  Future<void> removeDeal({required String dealId});

  Future<bool> sendPushNotification({
    required PushNotification notification,
    required List<String> tokens,
  });

  Future<DealReport?> sendDealReport({required DealReport report});

  Future<UserReport?> sendUserReport({required UserReport report});

  Future<List<Comment>?> getComments(String dealId);

  Future<Comment?> postComment({required Comment comment});

  Future<List<Category>> getCategories();

  Future<Category?> createCategory({required Category category});

  Future<Store?> getStore({required String storeId});

  Future<List<Store>> getStores();

  Future<MyUser> createMongoUser(User user);

  Future<MyUser?> getMongoUser();

  Future<List<MyUser>?> getBlockedUsers({required List<String> userUids});

  Future<MyUser> getUserById({required String id});

  Future<MyUser> getUserByUid({required String uid});

  Future<bool> addFcmToken({
    required String userId,
    required String fcmToken,
  });

  Future<void> logout({required String fcmToken});

  Future<MyUser> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  });

  Future<MyUser> updateUserNickname({
    required String userId,
    required String nickname,
  });

  Future<List<Deal>?> getUserFavorites({int? page, int? size});

  Future<List<SearchHit>> searchDeals({required String keyword});

  Future<List<Deal>?> getUserDeals({int? page, int? size});

  Future<List<Deal>?> getDealsByCategory({
    required String category,
    int? page,
    int? size,
  });

  Future<List<Deal>> getDealsByKeyword({
    required String keyword,
    int? page,
    int? size,
  });

  Future<List<Deal>?> getDealsByStore({
    required String storeId,
    int? page,
    int? size,
  });

  Future<List<Deal>?> getDealsSortedBy({
    required String sortType,
    int? page,
    int? size,
  });

  Future<int?> getNumberOfCommentsPostedByUser({required String userId});

  Future<int?> getNumberOfDealsByStore({required String storeId});

  Future<int?> getNumberOfDealsPostedByUser({required String userId});

  Future<Deal?> incrementViewsCounter({required String dealId});

  Future<Deal?> voteDeal({required String dealId, required VoteType voteType});
}

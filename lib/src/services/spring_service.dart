import 'package:firebase_auth/firebase_auth.dart';

import '../models/category.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/report.dart';
import '../models/search_hit.dart';
import '../models/store.dart';
import '../models/vote_type.dart';

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

  Future<Report?> sendReport({required Report report});

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

  Future<MyUser> addFcmToken({
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

  Future<List<Deal>?> getUserFavorites();

  Future<List<SearchHit>> searchDeals({required String keyword});

  Future<List<Deal>?> getDealsByPostedBy({required String postedBy});

  Future<List<Deal>?> getDealsByCategory({required String category});

  Future<List<Deal>> getDealsByKeyword({required String keyword});

  Future<List<Deal>?> getDealsByStore({required String storeId});

  Future<List<Deal>?> getDealsSortedByCreatedAt();

  Future<List<Deal>?> getDealsSortedByDealScore();

  Future<int?> getNumberOfCommentsPostedByUser({required String userId});

  Future<int?> getNumberOfDealsByStore({required String storeId});

  Future<int?> getNumberOfDealsPostedByUser({required String userId});

  Future<List<Deal>?> getDealsSortedByPrice();

  Future<Deal?> incrementViewsCounter({required String dealId});

  Future<Deal?> voteDeal({required String dealId, required VoteType voteType});
}

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../config/environment.dart';
import '../models/category.dart';
import '../models/comment.dart';
import '../models/deal.dart';
import '../models/deal_report.dart';
import '../models/deal_sortby.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/search_hit.dart';
import '../models/store.dart';
import '../models/user_report.dart';
import '../models/vote_type.dart';
import 'http_service.dart';

typedef Json = Map<String, dynamic>;

// Retrieves the base URL from environment config.
final String _baseUrl = GetIt.I.get<Environment>().config.apiBaseUrl;

/// An implementation of the [SpringService] that used for communicating with
/// the backend.
class SpringService with NetworkLoggy {
  /// Creates an instance of [SpringService] with given [httpService].
  /// If no [httpService] is given, automatically creates a new [httpService].
  factory SpringService({HttpService? httpService}) {
    if (httpService == null) {
      return SpringService._privateConstructor(HttpService());
    }

    return SpringService._privateConstructor(httpService);
  }

  SpringService._privateConstructor(HttpService httpService) {
    _httpService = httpService;
  }

  late HttpService _httpService;

  Future<bool> blockUser({required String userId}) async {
    final String url = '$_baseUrl/users/block/$userId';

    try {
      final Response response = await _httpService.post(url, null);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> unblockUser({required String userUid}) async {
    final String url = '$_baseUrl/users/unblock/$userUid';

    try {
      final Response response = await _httpService.post(url, null);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> favoriteDeal({required String dealId}) async {
    final String url = '$_baseUrl/users/favorite/$dealId';

    try {
      final Response response = await _httpService.post(url, null);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> unfavoriteDeal({required String dealId}) async {
    final String url = '$_baseUrl/users/unfavorite/$dealId';

    try {
      final Response response = await _httpService.post(url, null);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<Deal?> postDeal({required Deal deal}) async {
    final String url = '$_baseUrl/deals';

    try {
      final Response response = await _httpService.post(url, deal.toJson());
      if (response.statusCode == 201) {
        final Deal _deal = Deal.fromJson(jsonDecode(response.body) as Json);

        return _deal;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<bool> removeDeal({required String dealId}) async {
    final String url = '$_baseUrl/deals/$dealId';

    try {
      final Response response = await _httpService.delete(url);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> sendPushNotification({
    required PushNotification notification,
    required List<String> tokens,
  }) async {
    if (tokens.isEmpty) {
      return false;
    }

    final String url = '$_baseUrl/notifications?tokens=${tokens.join(',')}';

    try {
      final Response response =
          await _httpService.post(url, notification.toJson());

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<DealReport?> sendDealReport({required DealReport report}) async {
    final String url = '$_baseUrl/deal-reports';

    try {
      final Response response = await _httpService.post(url, report.toJson());
      if (response.statusCode == 201) {
        final DealReport _report =
            DealReport.fromJson(jsonDecode(response.body) as Json);

        return _report;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<UserReport?> sendUserReport({required UserReport report}) async {
    final String url = '$_baseUrl/user-reports';

    try {
      final Response response = await _httpService.post(url, report.toJson());
      if (response.statusCode == 201) {
        final UserReport _report =
            UserReport.fromJson(jsonDecode(response.body) as Json);

        return _report;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Comment>?> getComments({
    required String dealId,
    int? page,
    int? size,
  }) async {
    final String url =
        '$_baseUrl/comments/search/findByDealId?dealId=$dealId&page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Comment> _comments = commentFromJson(response.body);

        return _comments;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Comment?> postComment({required Comment comment}) async {
    final String url = '$_baseUrl/comments';

    try {
      final Response response = await _httpService.post(url, comment.toJson());
      if (response.statusCode == 201) {
        final Comment _comment =
            Comment.fromJson(jsonDecode(response.body) as Json);

        return _comment;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Category>> getCategories() async {
    final String url = '$_baseUrl/categories';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Category> _categories = categoryFromJson(response.body);

        return _categories;
      }

      throw Exception('Failed to fetch categories!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to fetch categories!');
    }
  }

  Future<Category?> createCategory({required Category category}) async {
    final String url = '$_baseUrl/categories';

    try {
      final Response response = await _httpService.post(url, category.toJson());
      if (response.statusCode == 201) {
        final Category _category =
            Category.fromJson(jsonDecode(response.body) as Json);

        return _category;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Store?> getStore({required String storeId}) async {
    final String url = '$_baseUrl/stores/$storeId';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final Store _store = Store.fromJson(jsonDecode(response.body) as Json);

        return _store;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Store>> getStores() async {
    final String url = '$_baseUrl/stores';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Store> _stores = storeFromJson(response.body);

        return _stores;
      }

      throw Exception('Failed to fetch stores!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to fetch stores!');
    }
  }

  Future<MyUser> createMongoUser(User user) async {
    final String url = '$_baseUrl/users';
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    final Json _data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'avatar': user.photoURL ??
          'https://ui-avatars.com/api/?length=1&background=008080&rounded=true&name=',
      'fcmTokens': [fcmToken],
    };

    try {
      final Response response =
          await _httpService.post(url, _data, auth: false);
      if (response.statusCode == 201) {
        final MyUser _myUser =
            MyUser.fromJson(jsonDecode(response.body) as Json);

        return _myUser;
      }

      throw Exception('Failed to create the user!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to create the user!');
    }
  }

  Future<MyUser?> getMongoUser() async {
    final String url = '$_baseUrl/users/me';

    try {
      final Response response = await _httpService.get(url);
      if (response.statusCode == 200) {
        final MyUser _myUser =
            MyUser.fromJson(jsonDecode(response.body) as Json);

        return _myUser;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<MyUser>?> getBlockedUsers({
    required List<String> userUids,
  }) async {
    final String url =
        '$_baseUrl/users/search/findAllByUidIn?userUids=${userUids.join(',')}';
    try {
      final Response response = await _httpService.get(url);
      if (response.statusCode == 200) {
        final List<MyUser> blockedUsers = userFromJson(response.body);

        return blockedUsers;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<MyUser> getUserById({required String id}) async {
    final String url = '$_baseUrl/users/$id';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final MyUser _myUser =
            MyUser.fromJson(jsonDecode(response.body) as Json);

        return _myUser;
      }

      throw Exception('User not found!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('User not found!');
    }
  }

  Future<MyUser> getUserByUid({required String uid}) async {
    final String url = '$_baseUrl/users/search/findByUid?uid=$uid';

    try {
      final Response response = await _httpService.get(url);
      if (response.statusCode == 200) {
        final MyUser _myUser =
            MyUser.fromJson(jsonDecode(response.body) as Json);

        return _myUser;
      }

      throw Exception('User not found!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('User not found!');
    }
  }

  Future<bool> addFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    final String url = '$_baseUrl/users/add-fcm-token';
    final Json data = <String, dynamic>{'fcmToken': fcmToken};

    try {
      final Response response = await _httpService.post(url, data);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e);
      throw Exception('An error occurred while adding fcm token!');
    }
  }

  Future<bool> logout({required String fcmToken}) async {
    final String url = '$_baseUrl/users/logout';
    final Json data = <String, dynamic>{'fcmToken': fcmToken};

    try {
      final Response response = await _httpService.post(url, data);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('An error occurred while logging out!');
    }
  }

  Future<MyUser> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    final String url = '$_baseUrl/users/$userId';
    final List<Json> data = [
      <String, dynamic>{'op': 'replace', 'path': '/avatar', 'value': avatarUrl}
    ];

    try {
      final Response response = await _httpService.patch(url, data);
      if (response.statusCode == 200) {
        final MyUser _myUser =
            MyUser.fromJson(jsonDecode(response.body) as Json);

        return _myUser;
      }

      throw Exception("Failed to update the user's avatar!");
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception("Failed to update the user's avatar!");
    }
  }

  Future<MyUser> updateUserNickname({
    required String userId,
    required String nickname,
  }) async {
    final String url = '$_baseUrl/users/$userId';
    final List<Json> data = [
      <String, dynamic>{'op': 'replace', 'path': '/nickname', 'value': nickname}
    ];

    try {
      final Response response = await _httpService.patch(url, data);
      if (response.statusCode == 200) {
        final MyUser _myUser =
            MyUser.fromJson(jsonDecode(response.body) as Json);

        return _myUser;
      } else if (response.body.contains('E11000')) {
        throw Exception('This nickname already being used by another user!');
      }

      throw Exception("Failed to update the user's nickname!");
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception("Failed to update the user's nickname!");
    }
  }

  Future<List<Deal>?> getUserFavorites({int? page, int? size}) async {
    final String url = '$_baseUrl/users/favorites?page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url);
      if (response.statusCode == 200) {
        final List<Deal> _deals = userDealsFromJson(response.body);
        return _deals;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<SearchHit>> searchDeals({required String keyword}) async {
    final String url = '$_baseUrl/deals/elastic-search?keyword=$keyword';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<SearchHit> _searchHits =
            searchResultsFromJson(response.body);

        return _searchHits;
      }

      throw Exception('An error occurred while searching deals!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('An error occurred while searching deals!');
    }
  }

  Future<List<Deal>?> getUserDeals({int? page, int? size}) async {
    final String url = '$_baseUrl/users/deals?page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url);
      if (response.statusCode == 200) {
        final List<Deal> _deals = userDealsFromJson(response.body);

        return _deals;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Deal>?> getDealsByCategory({
    required String category,
    int? page,
    int? size,
  }) async {
    final String url =
        '$_baseUrl/deals/search/findAllByCategoryStartsWith?category=$category&page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Deal> _deals = dealFromJson(response.body);

        return _deals;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Deal>> getDealsByKeyword(
      {required String keyword, int? page, int? size}) async {
    final String url =
        '$_baseUrl/deals/search/queryDeals?keyword=$keyword&page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Deal> _deals = dealFromJson(response.body);

        return _deals;
      }

      throw Exception('Could not get deals by keyword!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get deals by keyword!');
    }
  }

  Future<List<Deal>?> getDealsByStore({
    required String storeId,
    int? page,
    int? size,
  }) async {
    final String url =
        '$_baseUrl/deals/search/findAllByStore?storeId=$storeId&page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Deal> _deals = dealFromJson(response.body);

        return _deals;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Deal>?> getDealsSortedBy({
    required DealSortBy dealSortBy,
    int? page,
    int? size,
  }) async {
    late String url;
    if (dealSortBy == DealSortBy.createdAt) {
      url = '$_baseUrl/deals/search/findAllByOrderByCreatedAtDesc';
    } else if (dealSortBy == DealSortBy.dealScore) {
      url = '$_baseUrl/deals/search/findAllByOrderByDealScoreDesc';
    } else if (dealSortBy == DealSortBy.price) {
      url = '$_baseUrl/deals/search/findAllByOrderByDiscountPrice';
    }
    url += '?page=$page&size=$size';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        final List<Deal> _deals = dealFromJson(response.body);

        return _deals;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<int?> getNumberOfCommentsPostedByUser({required String userId}) async {
    final String url =
        '$_baseUrl/comments/search/countCommentsByPostedBy?postedBy=$userId';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<int?> getNumberOfDealsByStore({required String storeId}) async {
    final String url =
        '$_baseUrl/deals/search/countDealsByStore?storeId=$storeId';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<int?> getNumberOfDealsPostedByUser({required String userId}) async {
    final String url =
        '$_baseUrl/deals/search/countDealsByPostedBy?postedBy=$userId';

    try {
      final Response response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Deal?> incrementViewsCounter({required String dealId}) async {
    final String url = '$_baseUrl/deals/$dealId/increment-views-counter';

    try {
      final Response response =
          await _httpService.post(url, <String, dynamic>{});
      if (response.statusCode == 200) {
        final Deal deal = Deal.fromJson(jsonDecode(response.body) as Json);

        return deal;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Deal?> voteDeal({
    required String dealId,
    required VoteType voteType,
  }) async {
    final String url = '$_baseUrl/deals/vote';
    final Json data = <String, dynamic>{
      'dealId': dealId,
      'voteType': voteType.asString,
    };

    try {
      final Response response = await _httpService.post(url, data);
      if (response.statusCode == 200) {
        final Deal deal = Deal.fromJson(jsonDecode(response.body) as Json);

        return deal;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }
}

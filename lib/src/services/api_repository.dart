import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../config/environment.dart';
import '../deal/deal_status.dart';
import '../models/category.dart';
import '../models/comment.dart';
import '../models/comments.dart';
import '../models/deal.dart';
import '../models/deal_report.dart';
import '../models/deal_vote_type.dart';
import '../models/my_user.dart';
import '../models/push_notification.dart';
import '../models/store.dart';
import '../models/user_report.dart';
import '../search/search_params.dart';
import '../search/search_response.dart';
import '../search/suggestion_response.dart';
import 'http_service.dart';

typedef Json = Map<String, dynamic>;

/// Thrown when an error occurs while decoding the response body.
class JsonDecodeException implements Exception {}

/// Thrown when an error occurs while deserializing the response body.
class JsonDeserializationException implements Exception {}

// The API base URL read from environment config.
final String _baseUrl = GetIt.I.get<Environment>().config.apiBaseUrl;

/// A class used for communicating with the Backend.
class APIRepository with NetworkLoggy {
  /// Creates an instance of [APIRepository] with given [httpService].
  /// If no [httpService] is given, creates a default one.
  factory APIRepository({HttpService? httpService}) =>
      APIRepository._privateConstructor(httpService ?? HttpService());

  APIRepository._privateConstructor(HttpService httpService) {
    _httpService = httpService;
  }

  late final HttpService _httpService;

  Json _parseJsonObject(String response) {
    try {
      return jsonDecode(response) as Json;
    } on Exception {
      throw JsonDecodeException();
    }
  }

  List<dynamic> _parseJsonArray(String response) {
    try {
      return jsonDecode(response) as List<dynamic>;
    } on Exception {
      throw JsonDecodeException();
    }
  }

  Future<bool> blockUser({required String userId}) async {
    final url = '$_baseUrl/users/me/blocks/$userId';
    try {
      final response = await _httpService.put(url);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> unblockUser({required String userId}) async {
    final url = '$_baseUrl/users/me/blocks/$userId';
    try {
      final response = await _httpService.delete(url);

      return response.statusCode == 204;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> favoriteDeal({required String dealId}) async {
    final url = '$_baseUrl/users/me/favorites/$dealId';
    try {
      final response = await _httpService.put(url);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> unfavoriteDeal({required String dealId}) async {
    final url = '$_baseUrl/users/me/favorites/$dealId';
    try {
      final response = await _httpService.delete(url);

      return response.statusCode == 204;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<Deal?> postDeal({required Deal deal}) async {
    final url = '$_baseUrl/deals';
    try {
      final response = await _httpService.post(url, deal.toJson());
      if (response.statusCode == 201) {
        return Deal.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Deal?> updateDeal({required Deal deal}) async {
    final url = '$_baseUrl/deals/${deal.id!}';
    try {
      final response = await _httpService.put(url, deal.toJson());
      if (response.statusCode == 200) {
        return Deal.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<bool> deleteDeal({required String dealId}) async {
    final url = '$_baseUrl/deals/$dealId';
    try {
      final response = await _httpService.delete(url);

      return response.statusCode == 204;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> sendPushNotification({
    required PushNotification notification,
  }) async {
    if (notification.tokens.isEmpty) {
      return false;
    }
    final url = '$_baseUrl/notifications';
    try {
      final response = await _httpService.post(url, notification.toJson());

      return response.statusCode == 201;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> reportDeal({required DealReport report}) async {
    final url = '$_baseUrl/deals/${report.reportedDeal}/reports';
    try {
      final response = await _httpService.post(url, report.toJson());

      return response.statusCode == 201;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<bool> reportUser({required UserReport report}) async {
    final url = '$_baseUrl/users/${report.reportedUser}/reports';
    try {
      final response = await _httpService.post(url, report.toJson());
      return response.statusCode == 201;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  Future<Comments?> getDealComments({
    required String dealId,
    int? page,
    int? size,
  }) async {
    final url = '$_baseUrl/deals/$dealId/comments?page=$page&size=$size';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return Comments.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<int?> getDealCommentCount({required String dealId}) async {
    final url = '$_baseUrl/deals/$dealId/comment-count';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return int.tryParse(response.body) ?? 0;
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Comment?> postComment({
    required String dealId,
    required Comment comment,
  }) async {
    final url = '$_baseUrl/deals/$dealId/comments';
    try {
      final response = await _httpService.post(url, comment.toJson());
      if (response.statusCode == 201) {
        return Comment.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<Category>> getCategories() async {
    final url = '$_baseUrl/categories';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return categoriesFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Failed to fetch categories!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to fetch categories!');
    }
  }

  Future<List<Store>> getStores() async {
    final url = '$_baseUrl/stores';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return storesFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Failed to fetch stores!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to fetch stores!');
    }
  }

  Future<MyUser> createMongoUser(User user) async {
    final url = '$_baseUrl/users';
    const defaultAvatar =
        'https://ui-avatars.com/api/?length=1&background=008080&rounded=true&name=';
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'avatar': user.photoURL ?? defaultAvatar,
    };
    try {
      final response = await _httpService.post(url, data, auth: false);
      if (response.statusCode == 201) {
        return MyUser.fromJsonBasicDTO(_parseJsonObject(response.body));
      }

      throw Exception('Failed to create the user!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to create the user!');
    }
  }

  Future<MyUser?> getMongoUser() async {
    final url = '$_baseUrl/users/me';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200) {
        return MyUser.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<List<MyUser>?> getBlockedUsers() async {
    final url = '$_baseUrl/users/me/blocks';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200) {
        return usersFromJson(_parseJsonArray(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<MyUser> getUserExtendedById({required String id}) async {
    final url = '$_baseUrl/users/$id/extended';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200) {
        return MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body));
      }

      throw Exception('User not found!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('User not found!');
    }
  }

  Future<MyUser> getUserById({required String id}) async {
    final url = '$_baseUrl/users/$id';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return MyUser.fromJsonBasicDTO(_parseJsonObject(response.body));
      }

      throw Exception('User not found!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('User not found!');
    }
  }

  Future<MyUser> getUserByUid({required String uid}) async {
    final url = '$_baseUrl/users/search/findByUid?uid=$uid';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200) {
        return MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body));
      }

      throw Exception('User not found!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('User not found!');
    }
  }

  Future<bool> addFCMToken({
    required String deviceId,
    required String token,
  }) async {
    final url = '$_baseUrl/users/me/fcm-tokens';
    final data = <String, dynamic>{'deviceId': deviceId, 'token': token};
    try {
      final response = await _httpService.put(url, data);

      return response.statusCode == 200;
    } on Exception catch (e) {
      loggy.error(e);
      throw Exception('An error occurred while adding FCM token!');
    }
  }

  Future<bool> deleteFCMToken({required String token}) async {
    final url = '$_baseUrl/users/me/fcm-tokens';
    final data = <String, dynamic>{'token': token};
    try {
      final response = await _httpService.delete(url, data);

      return response.statusCode == 204;
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('An error occurred while deleting FCM token!');
    }
  }

  Future<Deal> updateDealStatus({
    required String dealId,
    required DealStatus status,
  }) async {
    final url = '$_baseUrl/deals/$dealId';
    final data = <Json>[
      <String, dynamic>{
        'op': 'replace',
        'path': '/status',
        'value': status.name.toUpperCase(),
      }
    ];
    try {
      final response = await _httpService.patch(url, data);
      if (response.statusCode == 200) {
        return Deal.fromJson(_parseJsonObject(response.body));
      }

      throw Exception('Failed to update the deal status!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Failed to update the deal status!');
    }
  }

  Future<MyUser> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    final url = '$_baseUrl/users/me';
    final data = <Json>[
      <String, dynamic>{'op': 'replace', 'path': '/avatar', 'value': avatarUrl}
    ];
    try {
      final response = await _httpService.patch(url, data);
      if (response.statusCode == 200) {
        return MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body));
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
    final url = '$_baseUrl/users/me';
    final data = <Json>[
      <String, dynamic>{'op': 'replace', 'path': '/nickname', 'value': nickname}
    ];
    try {
      final response = await _httpService.patch(url, data);
      if (response.statusCode == 200) {
        return MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body));
      } else if (response.body.contains('E11000')) {
        throw Exception('This nickname already being used by another user!');
      }

      throw Exception("Failed to update the user's nickname!");
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception("Failed to update the user's nickname!");
    }
  }

  Future<List<Deal>> getUserFavorites({int? page, int? size}) async {
    final url = '$_baseUrl/users/me/favorites?page=$page&size=$size';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200) {
        return dealsFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Could not get the user favorites!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get the user favorites!');
    }
  }

  Future<SuggestionResponse> getDealSuggestions({required String query}) async {
    final url = '$_baseUrl/deals/suggestions?query=$query';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return SuggestionResponse.fromJson(jsonDecode(response.body));
      }

      throw Exception('An error occurred while searching deals!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('An error occurred while searching deals!');
    }
  }

  Future<List<Deal>> getUserDeals({int? page, int? size}) async {
    final url = '$_baseUrl/users/me/deals?page=$page&size=$size';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200) {
        return dealsFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Could not get the user deals!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get the user deals!');
    }
  }

  Future<List<Deal>> getDealsByCategory({
    required String category,
    int? page,
    int? size,
  }) async {
    final url =
        '$_baseUrl/deals/search/byCategory?category=$category&page=$page&size=$size';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return dealsFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Could not get deals by category!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get deals by category!');
    }
  }

  Future<SearchResponse> searchDeals({
    required SearchParams searchParams,
  }) async {
    final pattern = RegExp(r'(http[s]?://)');
    final url = Uri.http(
      _baseUrl.replaceFirst(pattern, ''),
      '/deals/searches',
      searchParams.queryParameters,
    ).toString();
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return SearchResponse.fromJson(jsonDecode(response.body));
      }

      throw Exception('Could not get the search results!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get the search results!');
    }
  }

  Future<List<Deal>> getDealsByStore({
    required String storeId,
    int? page,
    int? size,
  }) async {
    final url =
        '$_baseUrl/deals/search/byStoreId?storeId=$storeId&page=$page&size=$size';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return dealsFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Could not get deals by store!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get deals by store!');
    }
  }

  Future<List<Deal>> getLatestDeals({int? page, int? size}) async {
    final url = '$_baseUrl/deals/search/latestActive?page=$page&size=$size';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return dealsFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Could not get the latest deals!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get the latest deals!');
    }
  }

  Future<List<Deal>> getMostLikedDeals({int? page, int? size}) async {
    final url = '$_baseUrl/deals/search/mostLikedActive?page=$page&size=$size';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return dealsFromJson(_parseJsonArray(response.body));
      }

      throw Exception('Could not get the most liked deals!');
    } on Exception catch (e) {
      loggy.error(e, e);
      throw Exception('Could not get the most liked deals!');
    }
  }

  Future<int?> getNumberOfCommentsPostedByUser({required String userId}) async {
    final url = '$_baseUrl/users/$userId/comment-count';
    try {
      final response = await _httpService.get(url, auth: false);
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
    final url = '$_baseUrl/deals/count/byStore?storeId=$storeId';
    try {
      final response = await _httpService.get(url, auth: false);
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
    final url = '$_baseUrl/deals/count/byPostedBy?postedBy=$userId';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Deal?> getDeal({required String dealId}) async {
    final url = '$_baseUrl/deals/$dealId';
    try {
      final response = await _httpService.get(url, auth: false);
      if (response.statusCode == 200) {
        return Deal.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }

  Future<Deal?> voteDeal({
    required String dealId,
    required DealVoteType voteType,
  }) async {
    final url = '$_baseUrl/deals/$dealId/votes';
    final data = {'voteType': voteType.name.toUpperCase()};
    try {
      late final Response response;
      if (voteType == DealVoteType.unvote) {
        response = await _httpService.delete(url);
      } else {
        response = await _httpService.put(url, data);
      }
      if (response.statusCode == 200) {
        return Deal.fromJson(_parseJsonObject(response.body));
      }

      return null;
    } on Exception catch (e) {
      loggy.error(e, e);
      return null;
    }
  }
}

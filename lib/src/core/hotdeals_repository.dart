import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;

import '../config/environment.dart';
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
import '../helpers/enum_helper.dart';
import 'hotdeals_api.dart';
import 'http_service.dart';

final dealByIdFutureProvider =
    FutureProvider.family.autoDispose<Deal?, String>((ref, id) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  final result = await hotdealsRepository.getDealById(dealId: id);
  ref.keepAlive();
  return result;
}, name: 'DealByIdFutureProvider');

final dealCommentsByIdFutureProvider =
    FutureProvider.family.autoDispose<Comments?, String>((ref, id) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  return await hotdealsRepository.getDealComments(dealId: id);
}, name: 'DealCommentsByIdFutureProvider');

final userByIdFutureProvider =
    FutureProvider.family.autoDispose<MyUser, String>((ref, id) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  final result = await hotdealsRepository.getUserById(id: id);
  ref.keepAlive();
  return result;
}, name: 'UserByIdFutureProvider');

final userByUidFutureProvider =
    FutureProvider.family.autoDispose<MyUser, String>((ref, uid) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  final result = await hotdealsRepository.getUserByUid(uid: uid);
  ref.keepAlive();
  return result;
}, name: 'UserByUidFutureProvider');

final hotdealsRepositoryProvider = Provider<HotdealsRepository>((ref) {
  final baseUrl = ref.watch(environmentConfigProvider).apiBaseUrl;
  final httpService = ref.watch(httpServiceProvider);
  return HotdealsRepository(baseUrl: baseUrl, httpService: httpService);
}, name: 'HotdealsRepositoryProvider');

typedef Json = Map<String, dynamic>;

/// Thrown when an error occurs while decoding the response body.
class JsonDecodeException implements Exception {
  JsonDecodeException([this.message]);

  final dynamic message;

  @override
  String toString() {
    final Object? message = this.message;
    if (message == null) return 'JsonDecodeException';

    return 'JsonDecodeException: $message';
  }
}

/// Thrown when an error occurs while deserializing the response body.
class JsonDeserializationException implements Exception {
  JsonDeserializationException([this.message]);

  final dynamic message;

  @override
  String toString() {
    final Object? message = this.message;
    if (message == null) return 'JsonDeserializationException';

    return 'JsonDeserializationException: $message';
  }
}

/// An implementation of [HotdealsApi] used for communicating with the Backend.
class HotdealsRepository with NetworkLoggy implements HotdealsApi {
  HotdealsRepository({
    required String baseUrl,
    required HttpService httpService,
  })  : _baseUrl = baseUrl,
        _httpService = httpService;

  final HttpService _httpService;
  final String _baseUrl;

  Json _parseJsonObject(String response) {
    try {
      return jsonDecode(response) as Json;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      throw JsonDecodeException(e);
    }
  }

  List<dynamic> _parseJsonArray(String response) {
    try {
      return jsonDecode(response) as List<dynamic>;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      throw JsonDecodeException(e);
    }
  }

  // Wrapper function for deserializing that uses try-catch block to reduce
  // boilerplate.
  T _deserialize<T>(T Function() fn) {
    try {
      return fn();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      throw JsonDeserializationException(e);
    }
  }

  // Logs and then throws an `Exception` with given `errorMessage`.
  void _throwException(String errorMessage) {
    loggy.error(errorMessage);
    throw Exception(errorMessage);
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<bool> reportComment({
    required String dealId,
    required CommentReport report,
  }) async {
    final url =
        '$_baseUrl/deals/$dealId/comments/${report.reportedComment}/reports';
    try {
      final response = await _httpService.post(url, report.toJson());

      return response.statusCode == 201;
    } on Exception catch (e) {
      loggy.error(e, e);
      return false;
    }
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<List<Category>> getCategories() async {
    final url = '$_baseUrl/categories';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Failed to fetch categories!');
    }

    return _deserialize<List<Category>>(
        () => categoriesFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<List<Store>> getStores() async {
    final url = '$_baseUrl/stores';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Failed to fetch stores!');
    }

    return _deserialize<List<Store>>(
        () => storesFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<MyUser> createMongoUser(User user) async {
    final url = '$_baseUrl/users';
    const defaultAvatar =
        'https://ui-avatars.com/api/?length=1&background=008080&rounded=true&name=';
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'avatar': user.photoURL ?? defaultAvatar,
    };
    final response = await _httpService.post(url, data, auth: false);
    if (response.statusCode != 201) {
      _throwException('Failed to create the user!');
    }

    return _deserialize<MyUser>(
        () => MyUser.fromJsonBasicDTO(_parseJsonObject(response.body)));
  }

  @override
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

  @override
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

  @override
  Future<MyUser> getUserExtendedById({required String id}) async {
    final url = '$_baseUrl/users/$id/extended';
    final response = await _httpService.get(url);
    if (response.statusCode != 200) {
      _throwException('User not found!');
    }

    return _deserialize<MyUser>(
        () => MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body)));
  }

  @override
  Future<MyUser> getUserById({required String id}) async {
    loggy.warning('getUserById: $id');
    final url = '$_baseUrl/users/$id';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('User not found!');
    }

    return _deserialize<MyUser>(
        () => MyUser.fromJsonBasicDTO(_parseJsonObject(response.body)));
  }

  @override
  Future<MyUser> getUserByUid({required String uid}) async {
    final url = '$_baseUrl/users/search/findByUid?uid=$uid';
    final response = await _httpService.get(url);
    if (response.statusCode != 200) {
      _throwException('User not found!');
    }

    return _deserialize<MyUser>(
        () => MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body)));
  }

  @override
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

  @override
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

  @override
  Future<Deal> updateDealStatus({
    required String dealId,
    required DealStatus status,
  }) async {
    final url = '$_baseUrl/deals/$dealId';
    final data = <Json>[
      <String, dynamic>{
        'op': 'replace',
        'path': '/status',
        'value': status.javaName,
      }
    ];
    final response = await _httpService.patch(url, data);
    if (response.statusCode != 200) {
      _throwException('Failed to update the deal status!');
    }

    return _deserialize<Deal>(
        () => Deal.fromJson(_parseJsonObject(response.body)));
  }

  @override
  Future<MyUser> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    final url = '$_baseUrl/users/me';
    final data = <Json>[
      <String, dynamic>{'op': 'replace', 'path': '/avatar', 'value': avatarUrl}
    ];
    final response = await _httpService.patch(url, data);
    if (response.statusCode != 200) {
      _throwException("Failed to update the user's avatar!");
    }

    return _deserialize<MyUser>(
        () => MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body)));
  }

  @override
  Future<MyUser> updateUserNickname({
    required String userId,
    required String nickname,
  }) async {
    final url = '$_baseUrl/users/me';
    final data = <Json>[
      <String, dynamic>{'op': 'replace', 'path': '/nickname', 'value': nickname}
    ];
    final response = await _httpService.patch(url, data);
    if (response.statusCode != 200) {
      _throwException("Failed to update the user's nickname!");
    } else if (response.body.contains('E11000')) {
      _throwException('This nickname already being used by another user!');
    }

    return _deserialize<MyUser>(
        () => MyUser.fromJsonExtendedDTO(_parseJsonObject(response.body)));
  }

  @override
  Future<List<Deal>> getUserFavorites({int? page, int? size}) async {
    final url = '$_baseUrl/users/me/favorites?page=$page&size=$size';
    final response = await _httpService.get(url);
    if (response.statusCode != 200) {
      _throwException('Could not get the user favorites!');
    }

    return _deserialize<List<Deal>>(
        () => dealsFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<SearchSuggestion> getDealSuggestions({required String query}) async {
    final url = '$_baseUrl/deals/suggestions?query=$query';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('An error occurred while searching deals!');
    }

    return _deserialize<SearchSuggestion>(
        () => SearchSuggestion.fromJson(jsonDecode(response.body)));
  }

  @override
  Future<List<Deal>> getUserDeals({int? page, int? size}) async {
    final url = '$_baseUrl/users/me/deals?page=$page&size=$size';
    final response = await _httpService.get(url);
    if (response.statusCode != 200) {
      _throwException('Could not get the user deals!');
    }

    return _deserialize<List<Deal>>(
        () => dealsFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<List<Deal>> getDealsByCategory({
    required String category,
    int? page,
    int? size,
  }) async {
    final url =
        '$_baseUrl/deals/search/byCategory?category=$category&page=$page&size=$size';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Could not get deals by category!');
    }

    return _deserialize<List<Deal>>(
        () => dealsFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<SearchResponse> searchDeals({
    required SearchParams searchParams,
  }) async {
    final pattern = RegExp(r'(http[s]?://)');
    final url = Uri.http(
      _baseUrl.replaceFirst(pattern, ''),
      '/deals/searches',
      searchParams.queryParameters,
    ).toString();
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Could not get the search results!');
    }

    return _deserialize<SearchResponse>(
        () => SearchResponse.fromJson(jsonDecode(response.body)));
  }

  @override
  Future<List<Deal>> getDealsByStoreId({
    required String storeId,
    int? page,
    int? size,
  }) async {
    final url =
        '$_baseUrl/deals/search/byStoreId?storeId=$storeId&page=$page&size=$size';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Could not get deals by store!');
    }

    return _deserialize<List<Deal>>(
        () => dealsFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<List<Deal>> getLatestDeals({int? page, int? size}) async {
    final url = '$_baseUrl/deals/search/latestActive?page=$page&size=$size';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Could not get the latest deals!');
    }

    return _deserialize<List<Deal>>(
        () => dealsFromJson(_parseJsonArray(response.body)));
  }

  @override
  Future<List<Deal>> getMostLikedDeals({int? page, int? size}) async {
    final url = '$_baseUrl/deals/search/mostLikedActive?page=$page&size=$size';
    final response = await _httpService.get(url, auth: false);
    if (response.statusCode != 200) {
      _throwException('Could not get the most liked deals!');
    }

    return _deserialize<List<Deal>>(
        () => dealsFromJson(_parseJsonArray(response.body)));
  }

  @override
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

  @override
  Future<int?> getNumberOfDealsByStoreId({required String storeId}) async {
    final url = '$_baseUrl/deals/count/byStoreId?storeId=$storeId';
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

  @override
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

  @override
  Future<Deal?> getDealById({required String dealId}) async {
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

  @override
  Future<Deal?> voteDeal({
    required String dealId,
    required DealVoteType voteType,
  }) async {
    final url = '$_baseUrl/deals/$dealId/votes';
    final data = {'voteType': voteType.javaName};
    try {
      final response = voteType == DealVoteType.unvote
          ? await _httpService.delete(url)
          : await _httpService.put(url, data);
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

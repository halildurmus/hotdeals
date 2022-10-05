import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../exceptions/network_exceptions.dart';
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
import 'dio_client.dart';
import 'hotdeals_api.dart';

typedef Json = Map<String, Object?>;

final dealByIdFutureProvider =
    FutureProvider.family.autoDispose<Deal, String>((ref, id) async {
  final hotdealsRepository = ref.watch(hotdealsRepositoryProvider);
  final result = await hotdealsRepository.getDealById(dealId: id);
  ref.keepAlive();
  return result;
}, name: 'DealByIdFutureProvider');

final dealCommentsByIdFutureProvider =
    FutureProvider.family.autoDispose<Comments, String>((ref, id) async {
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
  final dioClient = ref.watch(dioProvider);
  return HotdealsRepository(dioClient);
}, name: 'HotdealsRepositoryProvider');

/// An implementation of [HotdealsApi] used for communicating with the Backend.
class HotdealsRepository with NetworkLoggy implements HotdealsApi {
  HotdealsRepository(this._dioClient);

  final DioClient _dioClient;

  /// Wrapper function for `HTTP` requests that uses try-catch block to reduce
  /// boilerplate.
  Future<T> _wrap<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FormatException catch (e) {
      loggy.error(e);
      rethrow;
    } on DioError catch (e) {
      loggy.error(e);
      rethrow;
    } catch (e) {
      loggy.error(e);
      rethrow;
    }
  }

  @override
  Future<void> blockUser({required String userId}) => _wrap(() async {
        final url = '/users/me/blocks/$userId';
        final response = await _dioClient.put(url);
        if (response.statusCode != 200) {
          throw Exception('Failed to block user with id: $userId');
        }
      });

  @override
  Future<void> unblockUser({required String userId}) => _wrap(() async {
        final url = '/users/me/blocks/$userId';
        final response = await _dioClient.delete(url);
        if (response.statusCode != 204) {
          throw Exception('Failed to unblock user with id: $userId');
        }
      });

  @override
  Future<void> favoriteDeal({required String dealId}) => _wrap(() async {
        final url = '/users/me/favorites/$dealId';
        final response = await _dioClient.put(url);
        if (response.statusCode != 200) {
          throw Exception('Failed to favorite deal with id: $dealId');
        }
      });

  @override
  Future<void> unfavoriteDeal({required String dealId}) => _wrap(() async {
        final url = '/users/me/favorites/$dealId';
        final response = await _dioClient.delete(url);
        if (response.statusCode != 204) {
          throw Exception('Failed to unfavorite deal with id: $dealId');
        }
      });

  @override
  Future<Deal> postDeal({required Deal deal}) => _wrap(() async {
        const url = '/deals';
        final response = await _dioClient.post<Json>(url, data: deal.toJson());
        if (response.statusCode == 201) return Deal.fromJson(response.data!);
        throw Exception('Failed to post deal');
      });

  @override
  Future<Deal> updateDeal({required Deal deal}) => _wrap(() async {
        final url = '/deals/${deal.id!}';
        final response = await _dioClient.put<Json>(url, data: deal.toJson());
        if (response.statusCode == 200) return Deal.fromJson(response.data!);
        throw Exception('Failed to update deal');
      });

  @override
  Future<void> deleteDeal({required String dealId}) => _wrap(() async {
        final url = '/deals/$dealId';
        final response = await _dioClient.delete(url);
        if (response.statusCode != 204) {
          throw Exception('Failed to delete deal with id: $dealId');
        }
      });

  @override
  Future<void> sendPushNotification({
    required PushNotification notification,
  }) =>
      _wrap(() async {
        if (notification.tokens.isEmpty) throw Exception('No tokens');
        const url = '/notifications';
        final response =
            await _dioClient.post(url, data: notification.toJson());
        if (response.statusCode != 201) {
          throw Exception('Failed to send push notification');
        }
      });

  @override
  Future<void> reportComment({
    required String dealId,
    required CommentReport report,
  }) =>
      _wrap(() async {
        final url = '/deals/$dealId/comments/${report.reportedComment}/reports';
        final response = await _dioClient.post(url, data: report.toJson());
        if (response.statusCode != 201) {
          throw Exception('Failed to report comment');
        }
      });

  @override
  Future<void> reportDeal({required DealReport report}) => _wrap(() async {
        final url = '/deals/${report.reportedDeal}/reports';
        final response = await _dioClient.post(url, data: report.toJson());
        if (response.statusCode != 201) {
          throw Exception('Failed to report deal');
        }
      });

  @override
  Future<void> reportUser({required UserReport report}) => _wrap(() async {
        final url = '/users/${report.reportedUser}/reports';
        final response = await _dioClient.post(url, data: report.toJson());
        if (response.statusCode != 201) {
          throw Exception('Failed to report user');
        }
      });

  @override
  Future<Comments> getDealComments({
    required String dealId,
    int? page,
    int? size,
  }) =>
      _wrap(() async {
        final url = '/deals/$dealId/comments?page=$page&size=$size';
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) {
          return Comments.fromJson(response.data!);
        }
        throw Exception('Failed to get deal comments');
      });

  @override
  Future<int> getDealCommentCount({required String dealId}) => _wrap(() async {
        final url = '/deals/$dealId/comment-count';
        final response = await _dioClient.get<String>(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        if (response.statusCode == 200) {
          return int.tryParse(response.data!) ?? 0;
        }
        throw Exception('Failed to get deal comment count');
      });

  @override
  Future<Comment> postComment({
    required String dealId,
    required Comment comment,
  }) =>
      _wrap(() async {
        final url = '/deals/$dealId/comments';
        final response =
            await _dioClient.post<Json>(url, data: comment.toJson());
        if (response.statusCode == 201) return Comment.fromJson(response.data!);
        throw Exception('Failed to post the comment');
      });

  @override
  Future<List<Category>> getCategories() => _wrap(() async {
        const url = '/categories';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) {
          return categoriesFromJson(response.data!);
        }
        throw Exception('Failed to fetch categories!');
      });

  @override
  Future<List<Store>> getStores() => _wrap(() async {
        const url = '/stores';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return storesFromJson(response.data!);
        throw Exception('Failed to fetch stores!');
      });

  @override
  Future<MyUser> createMongoUser(User user) => _wrap(() async {
        const url = '/users';
        const defaultAvatar =
            'https://ui-avatars.com/api/?length=1&background=008080&rounded=true&name=';
        final data = {
          'uid': user.uid,
          'email': user.email,
          'avatar': user.photoURL ?? defaultAvatar,
        };
        final response = await _dioClient.post<Json>(url, data: data);
        if (response.statusCode == 201) {
          return MyUser.fromJsonBasicDTO(response.data!);
        }
        throw Exception('Failed to create user!');
      });

  @override
  Future<MyUser> getMongoUser() => _wrap(() async {
        const url = '/users/me';
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) return MyUser.fromJson(response.data!);
        throw Exception('Failed to get the user!');
      });

  @override
  Future<List<MyUser>> getBlockedUsers() => _wrap(() async {
        const url = '/users/me/blocks';
        final response = await _dioClient.get<List<dynamic>>(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        if (response.statusCode == 200) return usersFromJson(response.data!);
        throw Exception('Failed to get blocked users!');
      });

  @override
  Future<MyUser> getUserExtendedById({required String id}) => _wrap(() async {
        final url = '/users/$id/extended';
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) {
          return MyUser.fromJsonExtendedDTO(response.data!);
        }
        throw Exception('Failed to get the user!');
      });

  @override
  Future<MyUser> getUserById({required String id}) => _wrap(() async {
        final url = '/users/$id';
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) {
          return MyUser.fromJsonBasicDTO(response.data!);
        }
        throw Exception('Failed to get the user!');
      });

  @override
  Future<MyUser> getUserByUid({required String uid}) => _wrap(() async {
        final url = '/users/search/findByUid?uid=$uid';
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) {
          return MyUser.fromJsonExtendedDTO(response.data!);
        }
        throw Exception('Failed to get the user!');
      });

  @override
  Future<void> addFCMToken({
    required String deviceId,
    required String token,
  }) =>
      _wrap(() async {
        const url = '/users/me/fcm-tokens';
        final data = {'deviceId': deviceId, 'token': token};
        final response = await _dioClient.put(url, data: data);
        if (response.statusCode != 200) {
          throw Exception('Failed to add the FCM token!');
        }
      });

  @override
  Future<void> deleteFCMToken({required String token}) => _wrap(() async {
        const url = '/users/me/fcm-tokens';
        final data = {'token': token};
        final response = await _dioClient.delete(url, data: data);
        if (response.statusCode != 204) {
          throw Exception('Failed to delete the token!');
        }
      });

  @override
  Future<Deal> updateDealStatus({
    required String dealId,
    required DealStatus status,
  }) =>
      _wrap(() async {
        final url = '/deals/$dealId';
        final data = <Json>[
          {'op': 'replace', 'path': '/status', 'value': status.javaName}
        ];
        final response = await _dioClient.patch<Json>(url, data: data);
        if (response.statusCode == 200) return Deal.fromJson(response.data!);
        throw Exception('Failed to update the deal status!');
      });

  @override
  Future<MyUser> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) =>
      _wrap(() async {
        const url = '/users/me';
        final data = <Json>[
          {'op': 'replace', 'path': '/avatar', 'value': avatarUrl}
        ];
        final response = await _dioClient.patch<Json>(url, data: data);
        if (response.statusCode == 200) {
          return MyUser.fromJsonExtendedDTO(response.data!);
        }
        throw Exception('Failed to update the user avatar!');
      });

  @override
  Future<MyUser> updateUserNickname({
    required String userId,
    required String nickname,
  }) =>
      _wrap(() async {
        const url = '/users/me';
        final data = <Json>[
          {'op': 'replace', 'path': '/nickname', 'value': nickname}
        ];
        final response = await _dioClient.patch<Json>(url, data: data);
        if (response.statusCode == 200) {
          return MyUser.fromJsonExtendedDTO(response.data!);
        }
        throw Exception("Failed to update the user's nickname!");
      });

  @override
  Future<List<Deal>> getUserFavorites({int? page, int? size}) =>
      _wrap(() async {
        final url = '/users/me/favorites?page=$page&size=$size';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return dealsFromJson(response.data!);
        throw Exception('Failed to get the user favorites!');
      });

  @override
  Future<SearchSuggestion> getDealSuggestions({required String query}) =>
      _wrap(() async {
        final url = '/deals/suggestions?query=$query';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) {
          return SearchSuggestion.fromJson(response.data!);
        }
        throw Exception('Failed to get the deal suggestions!');
      });

  @override
  Future<List<Deal>> getUserDeals({int? page, int? size}) => _wrap(() async {
        final url = '/users/me/deals?page=$page&size=$size';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return dealsFromJson(response.data!);
        throw Exception('Failed to get the user deals!');
      });

  @override
  Future<List<Deal>> getDealsByCategory({
    required String category,
    int? page,
    int? size,
  }) =>
      _wrap(() async {
        final url =
            '/deals/search/byCategory?category=$category&page=$page&size=$size';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return dealsFromJson(response.data!);
        throw Exception('Failed to get the deals by category!');
      });

  @override
  Future<SearchResponse> searchDeals({
    required SearchParams searchParams,
  }) =>
      _wrap(() async {
        final pattern = RegExp(r'(http[s]?://)');
        final url = Uri.http(
          _dioClient.baseUrl.replaceFirst(pattern, ''),
          '/deals/searches',
          searchParams.queryParameters,
        ).toString();
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) {
          return SearchResponse.fromJson(response.data!);
        }
        throw Exception('Could not get the search results!');
      });

  @override
  Future<List<Deal>> getDealsByStoreId({
    required String storeId,
    int? page,
    int? size,
  }) =>
      _wrap(() async {
        final url =
            '/deals/search/byStoreId?storeId=$storeId&page=$page&size=$size';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return dealsFromJson(response.data!);
        throw Exception('Could not get the deals by store!');
      });

  @override
  Future<List<Deal>> getLatestDeals({int? page, int? size}) => _wrap(() async {
        final url = '/deals/search/latestActive?page=$page&size=$size';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return dealsFromJson(response.data!);
        throw Exception('Could not get the latest deals!');
      });

  @override
  Future<List<Deal>> getMostLikedDeals({
    int? page,
    int? size,
  }) =>
      _wrap(() async {
        final url = '/deals/search/mostLikedActive?page=$page&size=$size';
        final response = await _dioClient.get<List<dynamic>>(url);
        if (response.statusCode == 200) return dealsFromJson(response.data!);
        throw Exception('Could not get the most liked deals!');
      });

  @override
  Future<int> getNumberOfCommentsPostedByUser({
    required String userId,
  }) =>
      _wrap(() async {
        final url = '/users/$userId/comment-count';
        final response = await _dioClient.get<String>(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        if (response.statusCode == 200) {
          return int.tryParse(response.data!) ?? 0;
        }
        throw Exception(
            'Could not get the number of comments posted by the user!');
      });

  @override
  Future<int> getNumberOfDealsByStoreId({
    required String storeId,
  }) =>
      _wrap(() async {
        final url = '/deals/count/byStoreId?storeId=$storeId';
        final response = await _dioClient.get<String>(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        if (response.statusCode == 200) {
          return int.tryParse(response.data!) ?? 0;
        }
        throw Exception('Could not get the number of deals by store!');
      });

  @override
  Future<int> getNumberOfDealsPostedByUser({
    required String userId,
  }) =>
      _wrap(() async {
        final url = '/deals/count/byPostedBy?postedBy=$userId';
        final response = await _dioClient.get<String>(
          url,
          options: Options(responseType: ResponseType.plain),
        );
        if (response.statusCode == 200) {
          return int.tryParse(response.data!) ?? 0;
        }
        throw Exception('Could not get the number of deals posted by user!');
      });

  @override
  Future<Deal> getDealById({required String dealId}) => _wrap(() async {
        final url = '/deals/$dealId';
        final response = await _dioClient.get<Json>(url);
        if (response.statusCode == 200) return Deal.fromJson(response.data!);
        throw Exception('Could not get the deal!');
      });

  @override
  Future<Deal> voteDeal({
    required String dealId,
    required DealVoteType voteType,
  }) =>
      _wrap(() async {
        final url = '/deals/$dealId/votes';
        final data = {'voteType': voteType.javaName};
        final response = voteType == DealVoteType.unvote
            ? await _dioClient.delete<Json>(url)
            : await _dioClient.put<Json>(url, data: data);
        if (response.statusCode == 200) return Deal.fromJson(response.data!);
        throw Exception('Could not vote the deal!');
      });
}

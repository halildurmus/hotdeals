import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// This file was generated in two steps, using the Dart intl tools. With the
// app's root directory (the one that contains pubspec.yaml) as the current
// directory:
//
// flutter pub get
// flutter pub run intl_generator:extract_to_arb --output-dir=lib/src/l10n lib/src/app_localizations.dart
// flutter pub run intl_generator:generate_from_arb --output-dir=lib/src/l10n --no-use-deferred-loading lib/src/app_localizations.dart lib/src/l10n/intl_en.arb lib/src/l10n/intl_tr.arb
//
// The second command generates intl_messages.arb and the third generates
// messages_all.dart. There's more about this process in
// https://pub.dev/packages/intl.
import 'l10n/messages_all.dart';

class AppLocalizations {
  AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode!.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return AppLocalizations(localeName);
    });
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  final String localeName;

  String get appTitle {
    return Intl.message(
      'hotdeals',
      name: 'appTitle',
      desc: 'Title for the app',
      locale: localeName,
    );
  }

  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      locale: localeName,
    );
  }

  String get turkish {
    return Intl.message(
      'Turkish',
      name: 'turkish',
      desc: '',
      locale: localeName,
    );
  }

  String get online {
    return Intl.message(
      'ONLINE',
      name: 'online',
      desc: '',
      locale: localeName,
    );
  }

  String get offline {
    return Intl.message(
      'OFFLINE',
      name: 'offline',
      desc: '',
      locale: localeName,
    );
  }

  String get checkYourInternet {
    return Intl.message(
      'Please check your internet connection',
      name: 'checkYourInternet',
      desc: '',
      locale: localeName,
    );
  }

  String get anErrorOccurred {
    return Intl.message(
      'An error occurred.',
      name: 'anErrorOccurred',
      desc: '',
      locale: localeName,
    );
  }

  String get anErrorOccurredWhile {
    return Intl.message(
      'An error occurred while fetching some data.',
      name: 'anErrorOccurredWhile',
      desc: '',
      locale: localeName,
    );
  }

  String get tryAgain {
    return Intl.message(
      'Try again',
      name: 'tryAgain',
      desc: '',
      locale: localeName,
    );
  }

  String atCategory(String category) => Intl.message(
        'at $category',
        name: 'atCategory',
        args: [category],
        desc: '',
        locale: localeName,
        examples: const <String, String>{'category': 'Electronics'},
      );

  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      locale: localeName,
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      locale: localeName,
    );
  }

  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      locale: localeName,
    );
  }

  String get commentedOnYourPost {
    return Intl.message(
      ' commented on your post',
      name: 'commentedOnYourPost',
      desc: '',
      locale: localeName,
    );
  }

  String dealCount(int count) => Intl.plural(
        count,
        zero: 'No deal',
        one: '$count deals',
        two: '$count deals',
        few: '$count deals',
        many: '$count deals',
        other: '$count deals',
        args: [count],
        name: 'dealCount',
        desc: '',
        locale: localeName,
      );

  String get signIn => Intl.message(
        'Sign In',
        name: 'signIn',
        desc: '',
        locale: localeName,
      );

  String get continueWithFacebook => Intl.message(
        'Continue with Facebook',
        name: 'continueWithFacebook',
        desc: '',
        locale: localeName,
      );

  String get continueWithGoogle => Intl.message(
        'Continue with Google',
        name: 'continueWithGoogle',
        desc: '',
        locale: localeName,
      );

  String get signInFailed => Intl.message(
        'Sign in failed',
        name: 'signInFailed',
        desc: '',
        locale: localeName,
      );

  String get logout => Intl.message(
        'Logout',
        name: 'logout',
        desc: '',
        locale: localeName,
      );

  String get newMark => Intl.message(
        'New',
        name: 'newMark',
        desc: '',
        locale: localeName,
      );

  String get today => Intl.message(
        'TODAY',
        name: 'today',
        desc: '',
        locale: localeName,
      );

  String get yesterday => Intl.message(
        'YESTERDAY',
        name: 'yesterday',
        desc: '',
        locale: localeName,
      );

  String get logoutConfirm => Intl.message(
        'Are you sure you want to log out?',
        name: 'logoutConfirm',
        desc: '',
        locale: localeName,
      );

  String get logoutFailed => Intl.message(
        'Logout failed',
        name: 'logoutFailed',
        desc: '',
        locale: localeName,
      );

  String get system => Intl.message(
        'System',
        name: 'system',
        desc: '',
        locale: localeName,
      );

  String get light => Intl.message(
        'Light',
        name: 'light',
        desc: '',
        locale: localeName,
      );

  String get dark => Intl.message(
        'Dark',
        name: 'dark',
        desc: '',
        locale: localeName,
      );

  String get settings => Intl.message(
        'Settings',
        name: 'settings',
        desc: '',
        locale: localeName,
      );

  String get theme => Intl.message(
        'Theme',
        name: 'theme',
        desc: '',
        locale: localeName,
      );

  String get language => Intl.message(
        'Language',
        name: 'language',
        desc: '',
        locale: localeName,
      );

  String get youHaveNotPostedAnyDeal => Intl.message(
        "You haven't posted any deal yet!",
        name: 'youHaveNotPostedAnyDeal',
        desc: '',
        locale: localeName,
      );

  String get youHaveNotFavoritedAnyDeal => Intl.message(
        "You haven't favorited any deal yet!",
        name: 'youHaveNotFavoritedAnyDeal',
        desc: '',
        locale: localeName,
      );

  String get noNotifications => Intl.message(
        'No notifications yet!',
        name: 'noNotifications',
        desc: '',
        locale: localeName,
      );

  String get updateProfile => Intl.message(
        'Update Profile',
        name: 'updateProfile',
        desc: '',
        locale: localeName,
      );

  String get notifications => Intl.message(
        'Notifications',
        name: 'notifications',
        desc: '',
        locale: localeName,
      );

  String get posts => Intl.message(
        'Posts',
        name: 'posts',
        desc: '',
        locale: localeName,
      );

  String get favorites => Intl.message(
        'Favorites',
        name: 'favorites',
        desc: '',
        locale: localeName,
      );

  String get profile => Intl.message(
        'Profile',
        name: 'profile',
        desc: '',
        locale: localeName,
      );

  String get selectSource => Intl.message(
        'Select source',
        name: 'selectSource',
        desc: '',
        locale: localeName,
      );

  String get camera => Intl.message(
        'Camera',
        name: 'camera',
        desc: '',
        locale: localeName,
      );

  String get gallery => Intl.message(
        'Gallery',
        name: 'gallery',
        desc: '',
        locale: localeName,
      );

  String get avatar => Intl.message(
        'Avatar',
        name: 'avatar',
        desc: '',
        locale: localeName,
      );

  String get nickname => Intl.message(
        'Nickname',
        name: 'nickname',
        desc: '',
        locale: localeName,
      );

  String get updateNickname => Intl.message(
        'Update nickname',
        name: 'updateNickname',
        desc: '',
        locale: localeName,
      );

  String get generalSettings => Intl.message(
        'General Settings',
        name: 'generalSettings',
        desc: '',
        locale: localeName,
      );

  String get deals => Intl.message(
        'Deals',
        name: 'deals',
        desc: '',
        locale: localeName,
      );

  String get browse => Intl.message(
        'Browse',
        name: 'browse',
        desc: '',
        locale: localeName,
      );

  String get chats => Intl.message(
        'Chats',
        name: 'chats',
        desc: '',
        locale: localeName,
      );

  String get categories => Intl.message(
        'Categories',
        name: 'categories',
        desc: '',
        locale: localeName,
      );

  String get stores => Intl.message(
        'Stores',
        name: 'stores',
        desc: '',
        locale: localeName,
      );

  String get couldNotFindAnyDeal => Intl.message(
        "Couldn't found any deal",
        name: 'couldNotFindAnyDeal',
        desc: '',
        locale: localeName,
      );

  String get unblock => Intl.message(
        'UNBLOCK',
        name: 'unblock',
        desc: '',
        locale: localeName,
      );

  String get blockedUsers => Intl.message(
        'Blocked Users',
        name: 'blockedUsers',
        desc: '',
        locale: localeName,
      );

  String get noBlockedUsers => Intl.message(
        'No blocked users yet!',
        name: 'noBlockedUsers',
        desc: '',
        locale: localeName,
      );

  String get anErrorOccurredWhileBlocking => Intl.message(
        'An error occurred while blocking this user!',
        name: 'anErrorOccurredWhileBlocking',
        desc: '',
        locale: localeName,
      );

  String get anErrorOccurredWhileUnblocking => Intl.message(
        'An error occurred while unblocking this user!',
        name: 'anErrorOccurredWhileUnblocking',
        desc: '',
        locale: localeName,
      );

  String get successfullyUnblocked => Intl.message(
        'Successfully unblocked this user!',
        name: 'successfullyUnblocked',
        desc: '',
        locale: localeName,
      );

  String get unblockUser => Intl.message(
        'Unblock User',
        name: 'unblockUser',
        desc: '',
        locale: localeName,
      );

  String get sendMessage => Intl.message(
        'Send Message',
        name: 'sendMessage',
        desc: '',
        locale: localeName,
      );

  String joined(String date) => Intl.message(
        'Joined $date',
        name: 'joined',
        args: [date],
        desc: '',
        locale: localeName,
        examples: const <String, String>{'date': 'Jun 2021'},
      );

  String couldNotFindAnyResultFor(String keyword) => Intl.message(
        "Couldn't find any result for $keyword",
        name: 'couldNotFindAnyResultFor',
        args: [keyword],
        desc: '',
        locale: localeName,
        examples: const <String, String>{'keyword': 'iphone'},
      );

  String get dealsPosted => Intl.message(
        ' Deals Posted',
        name: 'dealsPosted',
        desc: '',
        locale: localeName,
      );

  String get commentsPosted => Intl.message(
        ' Comments Posted',
        name: 'commentsPosted',
        desc: '',
        locale: localeName,
      );

  String get aboutUser => Intl.message(
        'About User',
        name: 'aboutUser',
        desc: '',
        locale: localeName,
      );

  String get sentYouMessage => Intl.message(
        ' sent you a message',
        name: 'sentYouMessage',
        desc: '',
        locale: localeName,
      );

  String get blockConfirm => Intl.message(
        'Are you sure you want to block this user?',
        name: 'blockConfirm',
        desc: '',
        locale: localeName,
      );

  String get unblockConfirm => Intl.message(
        'Are you sure you want to unblock this user?',
        name: 'unblockConfirm',
        desc: '',
        locale: localeName,
      );

  String get successfullyBlocked => Intl.message(
        'Successfully blocked this user.',
        name: 'successfullyBlocked',
        desc: '',
        locale: localeName,
      );

  String get youNeedToSignIn => Intl.message(
        'You need to sign in',
        name: 'youNeedToSignIn',
        desc: '',
        locale: localeName,
      );

  String get youNeedToSignInToSee => Intl.message(
        'You need to sign in to see active conversations',
        name: 'youNeedToSignInToSee',
        desc: '',
        locale: localeName,
      );

  String get noChats => Intl.message(
        'No chats yet',
        name: 'noChats',
        desc: '',
        locale: localeName,
      );

  String get noActiveConversations => Intl.message(
        'No active conversations',
        name: 'noActiveConversations',
        desc: '',
        locale: localeName,
      );

  String get youHaveBeenBlockedByThisUser => Intl.message(
        "You've been blocked by this user",
        name: 'youHaveBeenBlockedByThisUser',
        desc: '',
        locale: localeName,
      );

  String get youHaveBlockedThisUser => Intl.message(
        "You've blocked this user",
        name: 'youHaveBlockedThisUser',
        desc: '',
        locale: localeName,
      );

  String get file => Intl.message(
        'File',
        name: 'file',
        desc: '',
        locale: localeName,
      );

  String get image => Intl.message(
        'Image',
        name: 'image',
        desc: '',
        locale: localeName,
      );

  String get enterYourMessage => Intl.message(
        'Enter your message',
        name: 'enterYourMessage',
        desc: '',
        locale: localeName,
      );

  String get reportUser => Intl.message(
        'Report User',
        name: 'reportUser',
        desc: '',
        locale: localeName,
      );

  String get blockUser => Intl.message(
        'Block User',
        name: 'blockUser',
        desc: '',
        locale: localeName,
      );

  String get spam => Intl.message(
        'Spam',
        name: 'spam',
        desc: '',
        locale: localeName,
      );

  String get post => Intl.message(
        'Post',
        name: 'post',
        desc: '',
        locale: localeName,
      );

  String get newest => Intl.message(
        'Newest',
        name: 'newest',
        desc: '',
        locale: localeName,
      );

  String get mostLiked => Intl.message(
        'Most Liked',
        name: 'mostLiked',
        desc: '',
        locale: localeName,
      );

  String get cheapest => Intl.message(
        'Cheapest',
        name: 'cheapest',
        desc: '',
        locale: localeName,
      );

  String get noResults => Intl.message(
        'No results',
        name: 'noResults',
        desc: '',
        locale: localeName,
      );

  String get search => Intl.message(
        'Search',
        name: 'search',
        desc: '',
        locale: localeName,
      );

  String get successfullyReportedDeal => Intl.message(
        'Successfully reported deal',
        name: 'successfullyReportedDeal',
        desc: '',
        locale: localeName,
      );

  String get successfullyReportedUser => Intl.message(
        'Successfully reported user',
        name: 'successfullyReportedUser',
        desc: '',
        locale: localeName,
      );

  String get harassing => Intl.message(
        'Harassing',
        name: 'harassing',
        desc: '',
        locale: localeName,
      );

  String get other => Intl.message(
        'Other',
        name: 'other',
        desc: '',
        locale: localeName,
      );

  String get enterSomeDetailsAboutReport => Intl.message(
        'Enter some details about your report',
        name: 'enterSomeDetailsAboutReport',
        desc: '',
        locale: localeName,
      );

  String get enterYourComment => Intl.message(
        'Enter your comment',
        name: 'enterYourComment',
        desc: '',
        locale: localeName,
      );

  String get postComment => Intl.message(
        'Post comment',
        name: 'postComment',
        desc: '',
        locale: localeName,
      );

  String get postAComment => Intl.message(
        'Post a Comment',
        name: 'postAComment',
        desc: '',
        locale: localeName,
      );

  String get originalPrice => Intl.message(
        'Original Price',
        name: 'originalPrice',
        desc: '',
        locale: localeName,
      );

  String get pleaseEnterTheOriginalPrice => Intl.message(
        "Please enter the deal's original price.",
        name: 'pleaseEnterTheOriginalPrice',
        desc: '',
        locale: localeName,
      );

  String get discountPrice => Intl.message(
        'Discount Price',
        name: 'discountPrice',
        desc: '',
        locale: localeName,
      );

  String get title => Intl.message(
        'Title',
        name: 'title',
        desc: '',
        locale: localeName,
      );

  String get enterDealUrl => Intl.message(
        'Enter deal URL',
        name: 'enterDealUrl',
        desc: '',
        locale: localeName,
      );

  String get uploadImage => Intl.message(
        'Upload Image',
        name: 'uploadImage',
        desc: '',
        locale: localeName,
      );

  String get category => Intl.message(
        'Category',
        name: 'category',
        desc: '',
        locale: localeName,
      );

  String get store => Intl.message(
        'Store',
        name: 'store',
        desc: '',
        locale: localeName,
      );

  String get pleaseEnterTheDealUrl => Intl.message(
        'Please enter the deal URL.',
        name: 'pleaseEnterTheDealUrl',
        desc: '',
        locale: localeName,
      );

  String get pleaseUploadAtLeastOneImage => Intl.message(
        'Please upload at least one image.',
        name: 'pleaseUploadAtLeastOneImage',
        desc: '',
        locale: localeName,
      );

  String get postDeal => Intl.message(
        'Post Deal',
        name: 'postDeal',
        desc: '',
        locale: localeName,
      );

  String get successfullyPostedYourDeal => Intl.message(
        'Successfully posted your deal',
        name: 'successfullyPostedYourDeal',
        desc: '',
        locale: localeName,
      );

  String get pleaseEnterValidUrl => Intl.message(
        'Please enter a valid URL.',
        name: 'pleaseEnterValidUrl',
        desc: '',
        locale: localeName,
      );

  String get pleaseEnterTheDealTitle => Intl.message(
        'Please enter the deal title.',
        name: 'pleaseEnterTheDealTitle',
        desc: '',
        locale: localeName,
      );

  String get pleaseEnterTheDiscountPrice => Intl.message(
        'Please enter the deal discount price.',
        name: 'pleaseEnterTheDiscountPrice',
        desc: '',
        locale: localeName,
      );

  String get originalPriceCannotBeLower => Intl.message(
        'The original price cannot be lower than the discount price.',
        name: 'originalPriceCannotBeLower',
        desc: '',
        locale: localeName,
      );

  String get discountPriceCannotBeGreater => Intl.message(
        'The discount price cannot be greater than the original price.',
        name: 'discountPriceCannotBeGreater',
        desc: '',
        locale: localeName,
      );

  String get enterSomeDetailsAboutDeal => Intl.message(
        'Enter here some details about this deal',
        name: 'enterSomeDetailsAboutDeal',
        desc: '',
        locale: localeName,
      );

  String get postedYourComment => Intl.message(
        'Successfully posted your comment',
        name: 'postedYourComment',
        desc: '',
        locale: localeName,
      );

  String get postADeal => Intl.message(
        'Post a Deal',
        name: 'postADeal',
        desc: '',
        locale: localeName,
      );

  String get seeDeal => Intl.message(
        'See Deal',
        name: 'seeDeal',
        desc: '',
        locale: localeName,
      );

  String get noComments => Intl.message(
        'No comments yet',
        name: 'noComments',
        desc: '',
        locale: localeName,
      );

  String get startTheConversation => Intl.message(
        'Start the conversation',
        name: 'startTheConversation',
        desc: '',
        locale: localeName,
      );

  String get didYouLikeTheDeal => Intl.message(
        'Did you like the deal?',
        name: 'didYouLikeTheDeal',
        desc: '',
        locale: localeName,
      );

  String get originalPoster => Intl.message(
        'ORIGINAL POSTER',
        name: 'originalPoster',
        desc: '',
        locale: localeName,
      );

  String get dealScore => Intl.message(
        'Deal Score',
        name: 'dealScore',
        desc: '',
        locale: localeName,
      );

  String get reportDeal => Intl.message(
        'Report Deal',
        name: 'reportDeal',
        desc: '',
        locale: localeName,
      );

  String get repost => Intl.message(
        'Repost',
        name: 'repost',
        desc: '',
        locale: localeName,
      );

  String commentCount(int count) => Intl.plural(
        count,
        zero: 'No comment',
        one: '$count comments',
        two: '$count comments',
        few: '$count comments',
        many: '$count comments',
        other: '$count comments',
        args: [count],
        name: 'commentCount',
        desc: '',
        locale: localeName,
      );
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

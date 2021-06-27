// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, always_declare_return_types

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(category) => "at ${category}";

  static m1(count) =>
      "${Intl.plural(count, zero: 'No comment', one: '${count} comments', two: '${count} comments', few: '${count} comments', many: '${count} comments', other: '${count} comments')}";

  static m2(keyword) => "Couldn\'t find any result for ${keyword}";

  static m3(count) =>
      "${Intl.plural(count, zero: 'No deal', one: '${count} deals', two: '${count} deals', few: '${count} deals', many: '${count} deals', other: '${count} deals')}";

  static m4(date) => "Joined ${date}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutUser": MessageLookupByLibrary.simpleMessage("About User"),
        "anErrorOccurred":
            MessageLookupByLibrary.simpleMessage("An error occurred."),
        "anErrorOccurredWhile": MessageLookupByLibrary.simpleMessage(
            "An error occurred while fetching some data."),
        "anErrorOccurredWhileBlocking": MessageLookupByLibrary.simpleMessage(
            "An error occurred while blocking this user!"),
        "anErrorOccurredWhileUnblocking": MessageLookupByLibrary.simpleMessage(
            "An error occurred while unblocking this user!"),
        "appTitle": MessageLookupByLibrary.simpleMessage("hotdeals"),
        "atCategory": m0,
        "avatar": MessageLookupByLibrary.simpleMessage("Avatar"),
        "blockConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to block this user?"),
        "blockUser": MessageLookupByLibrary.simpleMessage("Block User"),
        "blockedUsers": MessageLookupByLibrary.simpleMessage("Blocked Users"),
        "browse": MessageLookupByLibrary.simpleMessage("Browse"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "categories": MessageLookupByLibrary.simpleMessage("Categories"),
        "category": MessageLookupByLibrary.simpleMessage("Category"),
        "chats": MessageLookupByLibrary.simpleMessage("Chats"),
        "cheapest": MessageLookupByLibrary.simpleMessage("Cheapest"),
        "checkYourInternet": MessageLookupByLibrary.simpleMessage(
            "Please check your internet connection"),
        "commentCount": m1,
        "commentedOnYourPost":
            MessageLookupByLibrary.simpleMessage(" commented on your post"),
        "commentsPosted":
            MessageLookupByLibrary.simpleMessage(" comments posted"),
        "continueWithFacebook":
            MessageLookupByLibrary.simpleMessage("Continue with Facebook"),
        "continueWithGoogle":
            MessageLookupByLibrary.simpleMessage("Continue with Google"),
        "couldNotFindAnyDeal":
            MessageLookupByLibrary.simpleMessage("Couldn\'t found any deal"),
        "couldNotFindAnyResultFor": m2,
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "dealCount": m3,
        "dealScore": MessageLookupByLibrary.simpleMessage("Deal Score"),
        "deals": MessageLookupByLibrary.simpleMessage("Deals"),
        "dealsPosted": MessageLookupByLibrary.simpleMessage(" deals posted"),
        "didYouLikeTheDeal":
            MessageLookupByLibrary.simpleMessage("Did you like the deal?"),
        "discountPrice": MessageLookupByLibrary.simpleMessage("Discount Price"),
        "discountPriceCannotBeGreater": MessageLookupByLibrary.simpleMessage(
            "The discount price cannot be greater than the original price."),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enterDealUrl": MessageLookupByLibrary.simpleMessage("Enter deal URL"),
        "enterSomeDetailsAboutDeal": MessageLookupByLibrary.simpleMessage(
            "Enter here some details about this deal"),
        "enterSomeDetailsAboutReport": MessageLookupByLibrary.simpleMessage(
            "Enter some details about your report"),
        "enterYourComment":
            MessageLookupByLibrary.simpleMessage("Enter your comment"),
        "enterYourMessage":
            MessageLookupByLibrary.simpleMessage("Enter your message"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favorites"),
        "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "generalSettings":
            MessageLookupByLibrary.simpleMessage("General Settings"),
        "harassing": MessageLookupByLibrary.simpleMessage("Harassing"),
        "image": MessageLookupByLibrary.simpleMessage("Image"),
        "joined": m4,
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to log out?"),
        "logoutFailed": MessageLookupByLibrary.simpleMessage("Logout failed"),
        "mostLiked": MessageLookupByLibrary.simpleMessage("Most Liked"),
        "newest": MessageLookupByLibrary.simpleMessage("Newest"),
        "nickname": MessageLookupByLibrary.simpleMessage("Nickname"),
        "noActiveConversations":
            MessageLookupByLibrary.simpleMessage("No active conversations"),
        "noBlockedUsers":
            MessageLookupByLibrary.simpleMessage("No blocked users yet!"),
        "noChats": MessageLookupByLibrary.simpleMessage("No chats yet"),
        "noComments": MessageLookupByLibrary.simpleMessage("No comments yet"),
        "noNotifications":
            MessageLookupByLibrary.simpleMessage("No notifications yet!"),
        "noResults": MessageLookupByLibrary.simpleMessage("No results"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "offline": MessageLookupByLibrary.simpleMessage("OFFLINE"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "online": MessageLookupByLibrary.simpleMessage("ONLINE"),
        "originalPoster":
            MessageLookupByLibrary.simpleMessage("ORIGINAL POSTER"),
        "originalPrice": MessageLookupByLibrary.simpleMessage("Original Price"),
        "originalPriceCannotBeLower": MessageLookupByLibrary.simpleMessage(
            "The original price cannot be lower than the discount price."),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "pleaseEnterTheDealTitle": MessageLookupByLibrary.simpleMessage(
            "Please enter the deal title."),
        "pleaseEnterTheDealUrl":
            MessageLookupByLibrary.simpleMessage("Please enter the deal URL."),
        "pleaseEnterTheDiscountPrice": MessageLookupByLibrary.simpleMessage(
            "Please enter the deal discount price."),
        "pleaseEnterTheOriginalPrice": MessageLookupByLibrary.simpleMessage(
            "Please enter the deal\'s original price."),
        "pleaseEnterValidUrl":
            MessageLookupByLibrary.simpleMessage("Please enter a valid URL."),
        "pleaseUploadAtLeastOneImage": MessageLookupByLibrary.simpleMessage(
            "Please upload at least one image."),
        "post": MessageLookupByLibrary.simpleMessage("Post"),
        "postAComment": MessageLookupByLibrary.simpleMessage("Post a Comment"),
        "postADeal": MessageLookupByLibrary.simpleMessage("Post a Deal"),
        "postComment": MessageLookupByLibrary.simpleMessage("Post comment"),
        "postDeal": MessageLookupByLibrary.simpleMessage("Post Deal"),
        "postedYourComment": MessageLookupByLibrary.simpleMessage(
            "Successfully posted your comment"),
        "posts": MessageLookupByLibrary.simpleMessage("Posts"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "reportDeal": MessageLookupByLibrary.simpleMessage("Report Deal"),
        "reportUser": MessageLookupByLibrary.simpleMessage("Report User"),
        "repost": MessageLookupByLibrary.simpleMessage("Repost"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "seeDeal": MessageLookupByLibrary.simpleMessage("See Deal"),
        "selectSource": MessageLookupByLibrary.simpleMessage("Select source"),
        "sendMessage": MessageLookupByLibrary.simpleMessage("Send Message"),
        "sentYouMessage":
            MessageLookupByLibrary.simpleMessage(" sent you a message"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "signInFailed": MessageLookupByLibrary.simpleMessage("Sign in failed"),
        "spam": MessageLookupByLibrary.simpleMessage("Spam"),
        "startTheConversation":
            MessageLookupByLibrary.simpleMessage("Start the conversation"),
        "store": MessageLookupByLibrary.simpleMessage("Store"),
        "stores": MessageLookupByLibrary.simpleMessage("Stores"),
        "successfullyBlocked": MessageLookupByLibrary.simpleMessage(
            "Successfully blocked this user."),
        "successfullyPostedYourDeal": MessageLookupByLibrary.simpleMessage(
            "Successfully posted your deal"),
        "successfullyReportedDeal":
            MessageLookupByLibrary.simpleMessage("Successfully reported deal"),
        "successfullyReportedUser":
            MessageLookupByLibrary.simpleMessage("Successfully reported user"),
        "successfullyUnblocked": MessageLookupByLibrary.simpleMessage(
            "Successfully unblocked this user!"),
        "system": MessageLookupByLibrary.simpleMessage("System"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "title": MessageLookupByLibrary.simpleMessage("Title"),
        "today": MessageLookupByLibrary.simpleMessage("TODAY"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Try again"),
        "turkish": MessageLookupByLibrary.simpleMessage("Turkish"),
        "unblock": MessageLookupByLibrary.simpleMessage("UNBLOCK"),
        "unblockConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to unblock this user?"),
        "unblockUser": MessageLookupByLibrary.simpleMessage("Unblock User"),
        "updateNickname":
            MessageLookupByLibrary.simpleMessage("Update nickname"),
        "updateProfile": MessageLookupByLibrary.simpleMessage("Update Profile"),
        "uploadImage": MessageLookupByLibrary.simpleMessage("Upload Image"),
        "yesterday": MessageLookupByLibrary.simpleMessage("YESTERDAY"),
        "youHaveBlockedThisUser":
            MessageLookupByLibrary.simpleMessage("You\'ve blocked this user"),
        "youHaveNotFavoritedAnyDeal": MessageLookupByLibrary.simpleMessage(
            "You haven\'t favorited any deal yet!"),
        "youHaveNotPostedAnyDeal": MessageLookupByLibrary.simpleMessage(
            "You haven\'t posted any deal yet!"),
        "youNeedToSignIn":
            MessageLookupByLibrary.simpleMessage("You need to sign in"),
        "youNeedToSignInToSee": MessageLookupByLibrary.simpleMessage(
            "You need to sign in to see active conversations")
      };
}

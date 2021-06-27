// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
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
  String get localeName => 'tr';

  static m0(category) => "${category} kategorisinde";

  static m1(count) =>
      "${Intl.plural(count, zero: 'Yorum yok', one: '${count} yorum', two: '${count} yorum', few: '${count} yorum', many: '${count} yorum', other: '${count} yorum')}";

  static m2(keyword) => "${keyword} için herhangi bir sonuç bulunamadı";

  static m3(count) =>
      "${Intl.plural(count, zero: 'Fırsat yok', one: '${count} fırsat', two: '${count} fırsat', few: '${count} fırsat', many: '${count} fırsat', other: '${count} fırsat')}";

  static m4(date) => "${date} tarihinde katıldı";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutUser": MessageLookupByLibrary.simpleMessage("Kullanıcı Hakkında"),
        "anErrorOccurred":
            MessageLookupByLibrary.simpleMessage("Bir hata oluştu."),
        "anErrorOccurredWhile": MessageLookupByLibrary.simpleMessage(
            "Bazı veriler çekilirken bir hata oluştu."),
        "anErrorOccurredWhileBlocking": MessageLookupByLibrary.simpleMessage(
            "Kullanıcıyı engellerken bir hata oluştu!"),
        "anErrorOccurredWhileUnblocking": MessageLookupByLibrary.simpleMessage(
            "Kullanıcının engeli kaldırılırken bir hata oluştu!"),
        "appTitle": MessageLookupByLibrary.simpleMessage("hotdeals"),
        "atCategory": m0,
        "avatar": MessageLookupByLibrary.simpleMessage("Avatar"),
        "blockConfirm": MessageLookupByLibrary.simpleMessage(
            "Kullanıcıyı engellemek istediğiniziden emin misiniz?"),
        "blockUser":
            MessageLookupByLibrary.simpleMessage("Kullanıcıyı Engelle"),
        "blockedUsers":
            MessageLookupByLibrary.simpleMessage("Engelli Kullanıcılar"),
        "browse": MessageLookupByLibrary.simpleMessage("Gözat"),
        "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Vazgeç"),
        "categories": MessageLookupByLibrary.simpleMessage("Kategoriler"),
        "category": MessageLookupByLibrary.simpleMessage("Kategori"),
        "chats": MessageLookupByLibrary.simpleMessage("Sohbetler"),
        "cheapest": MessageLookupByLibrary.simpleMessage("En Ucuz"),
        "checkYourInternet": MessageLookupByLibrary.simpleMessage(
            "Lütfen internet bağlantınızı kontrol edin"),
        "commentCount": m1,
        "commentedOnYourPost":
            MessageLookupByLibrary.simpleMessage(" gönderine yorum yaptı"),
        "commentsPosted": MessageLookupByLibrary.simpleMessage(" yorum yaptı"),
        "continueWithFacebook":
            MessageLookupByLibrary.simpleMessage("Facebook ile devam et"),
        "continueWithGoogle":
            MessageLookupByLibrary.simpleMessage("Google ile devam et"),
        "couldNotFindAnyDeal":
            MessageLookupByLibrary.simpleMessage("Hiçbir fırsat bulunamadı"),
        "couldNotFindAnyResultFor": m2,
        "dark": MessageLookupByLibrary.simpleMessage("Koyu"),
        "dealCount": m3,
        "dealScore": MessageLookupByLibrary.simpleMessage("Fırsat Puanı"),
        "deals": MessageLookupByLibrary.simpleMessage("Fırsatlar"),
        "dealsPosted": MessageLookupByLibrary.simpleMessage(" fırsat paylaştı"),
        "didYouLikeTheDeal":
            MessageLookupByLibrary.simpleMessage("Fırsatı beğendiniz mi?"),
        "discountPrice":
            MessageLookupByLibrary.simpleMessage("İndirimli Fiyat"),
        "discountPriceCannotBeGreater": MessageLookupByLibrary.simpleMessage(
            "İndirimli fiyat, orijinal fiyattan büyük olamaz."),
        "english": MessageLookupByLibrary.simpleMessage("İngilizce"),
        "enterDealUrl":
            MessageLookupByLibrary.simpleMessage("Fırsat URL\'ini girin"),
        "enterSomeDetailsAboutDeal": MessageLookupByLibrary.simpleMessage(
            "Bu fırsatla ilgili bazı ayrıntıları girin "),
        "enterSomeDetailsAboutReport": MessageLookupByLibrary.simpleMessage(
            "Şikayetinizle alakalı bazı bilgiler girin"),
        "enterYourComment":
            MessageLookupByLibrary.simpleMessage("Yorumunuzu girin"),
        "enterYourMessage":
            MessageLookupByLibrary.simpleMessage("Mesajınızı girin"),
        "favorites": MessageLookupByLibrary.simpleMessage("Favoriler"),
        "gallery": MessageLookupByLibrary.simpleMessage("Galeri"),
        "generalSettings":
            MessageLookupByLibrary.simpleMessage("Genel Ayarlar"),
        "harassing": MessageLookupByLibrary.simpleMessage("Taciz"),
        "image": MessageLookupByLibrary.simpleMessage("Resim"),
        "joined": m4,
        "language": MessageLookupByLibrary.simpleMessage("Dil"),
        "light": MessageLookupByLibrary.simpleMessage("Açık"),
        "loading": MessageLookupByLibrary.simpleMessage("Yükleniyor..."),
        "logout": MessageLookupByLibrary.simpleMessage("Çıkış"),
        "logoutConfirm": MessageLookupByLibrary.simpleMessage(
            "Çıkış yapmak istediğinizden emin misiniz?"),
        "logoutFailed": MessageLookupByLibrary.simpleMessage("Çıkış başarısız"),
        "mostLiked": MessageLookupByLibrary.simpleMessage("En Beğenilen"),
        "newest": MessageLookupByLibrary.simpleMessage("En Yeni"),
        "nickname": MessageLookupByLibrary.simpleMessage("Takma ad"),
        "noActiveConversations":
            MessageLookupByLibrary.simpleMessage("Aktif görüşme yok "),
        "noBlockedUsers": MessageLookupByLibrary.simpleMessage(
            "Henüz bloklanmış bir kullanıcı yok!"),
        "noChats": MessageLookupByLibrary.simpleMessage("Henüz sohbet yok"),
        "noComments": MessageLookupByLibrary.simpleMessage("Henüz yorum yok"),
        "noNotifications":
            MessageLookupByLibrary.simpleMessage("Henüz bildirim yok!"),
        "noResults": MessageLookupByLibrary.simpleMessage("Sonuç yok"),
        "notifications": MessageLookupByLibrary.simpleMessage("Bildirimler"),
        "offline": MessageLookupByLibrary.simpleMessage("ÇEVRİMDIŞI"),
        "ok": MessageLookupByLibrary.simpleMessage("Tamam"),
        "online": MessageLookupByLibrary.simpleMessage("ÇEVRİMİÇİ"),
        "originalPoster":
            MessageLookupByLibrary.simpleMessage("PAYLAŞAN KULLANICI"),
        "originalPrice": MessageLookupByLibrary.simpleMessage("Orijinal Fiyat"),
        "originalPriceCannotBeLower": MessageLookupByLibrary.simpleMessage(
            "Orijinal fiyat, indirimli fiyattan küçük olamaz."),
        "other": MessageLookupByLibrary.simpleMessage("Diğer"),
        "pleaseEnterTheDealTitle": MessageLookupByLibrary.simpleMessage(
            "Lütfen fırsat başlığını girin."),
        "pleaseEnterTheDealUrl": MessageLookupByLibrary.simpleMessage(
            "Lütfen fırsat URL\'ini girin."),
        "pleaseEnterTheDiscountPrice": MessageLookupByLibrary.simpleMessage(
            "Lütfen fırsatın indirimli fiyatını girin."),
        "pleaseEnterTheOriginalPrice": MessageLookupByLibrary.simpleMessage(
            "Lütfen fırsatın orijinal fiyatını girin."),
        "pleaseEnterValidUrl": MessageLookupByLibrary.simpleMessage(
            "Lütfen geçerli bir URL girin."),
        "pleaseUploadAtLeastOneImage": MessageLookupByLibrary.simpleMessage(
            "Lütfen en az bir resim yükleyin."),
        "post": MessageLookupByLibrary.simpleMessage("Paylaş"),
        "postAComment":
            MessageLookupByLibrary.simpleMessage("Bir Yorum Paylaş"),
        "postADeal": MessageLookupByLibrary.simpleMessage("Bir Fırsat Paylaş"),
        "postComment": MessageLookupByLibrary.simpleMessage("Yorum paylaş"),
        "postDeal": MessageLookupByLibrary.simpleMessage("Fırsat Paylaş"),
        "postedYourComment": MessageLookupByLibrary.simpleMessage(
            "Yorumunuz başarıyla gönderildi"),
        "posts": MessageLookupByLibrary.simpleMessage("Paylaşımlar"),
        "profile": MessageLookupByLibrary.simpleMessage("Profil"),
        "reportDeal":
            MessageLookupByLibrary.simpleMessage("Fırsatı Şikayet Et"),
        "reportUser":
            MessageLookupByLibrary.simpleMessage("Kullanıcıyı Şikayet Et"),
        "repost": MessageLookupByLibrary.simpleMessage("Kopya"),
        "search": MessageLookupByLibrary.simpleMessage("Ara"),
        "seeDeal": MessageLookupByLibrary.simpleMessage("Fırsatı Gör"),
        "selectSource": MessageLookupByLibrary.simpleMessage("Kaynağı seçin"),
        "sendMessage": MessageLookupByLibrary.simpleMessage("Mesaj Gönder"),
        "sentYouMessage":
            MessageLookupByLibrary.simpleMessage(" sana bir mesaj gönderdi"),
        "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
        "signIn": MessageLookupByLibrary.simpleMessage("Giriş Yap"),
        "signInFailed": MessageLookupByLibrary.simpleMessage("Giriş başarısız"),
        "spam": MessageLookupByLibrary.simpleMessage("Spam"),
        "startTheConversation":
            MessageLookupByLibrary.simpleMessage("Konuşmayı başlat"),
        "store": MessageLookupByLibrary.simpleMessage("Mağaza"),
        "stores": MessageLookupByLibrary.simpleMessage("Mağazalar"),
        "successfullyBlocked": MessageLookupByLibrary.simpleMessage(
            "Kullanıcı, başarıyla engellendi."),
        "successfullyPostedYourDeal": MessageLookupByLibrary.simpleMessage(
            "Fırsat, başarıyla paylaşıldı"),
        "successfullyReportedDeal": MessageLookupByLibrary.simpleMessage(
            "Fırsat, başarıyla şikayet edildi"),
        "successfullyReportedUser": MessageLookupByLibrary.simpleMessage(
            "Kullanıcı, başarıyla şikayet edildi"),
        "successfullyUnblocked": MessageLookupByLibrary.simpleMessage(
            "Kullanıcının engeli başarıyla kaldırıldı!"),
        "system": MessageLookupByLibrary.simpleMessage("Sistem"),
        "theme": MessageLookupByLibrary.simpleMessage("Tema"),
        "title": MessageLookupByLibrary.simpleMessage("Başlık"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Tekrar dene"),
        "turkish": MessageLookupByLibrary.simpleMessage("Türkçe"),
        "unblock": MessageLookupByLibrary.simpleMessage("ENGELİ KALDIR"),
        "unblockConfirm": MessageLookupByLibrary.simpleMessage(
            "Kullanıcının engelini kaldırmak istediğinizden emin misiniz?"),
        "unblockUser": MessageLookupByLibrary.simpleMessage(
            "Kullanıcının Engelini Kaldır"),
        "updateNickname":
            MessageLookupByLibrary.simpleMessage("Takma adı güncelle"),
        "updateProfile":
            MessageLookupByLibrary.simpleMessage("Profili Güncelle"),
        "uploadImage": MessageLookupByLibrary.simpleMessage("Resim Yükle"),
        "youHaveBlockedThisUser": MessageLookupByLibrary.simpleMessage(
            "Bu kullanıcıyı engellediniz "),
        "youHaveNotFavoritedAnyDeal": MessageLookupByLibrary.simpleMessage(
            "Henüz herhangi bir fırsatı favorilerinize eklemediniz!"),
        "youHaveNotPostedAnyDeal": MessageLookupByLibrary.simpleMessage(
            "Henüz herhangi bir fırsat paylaşmadınız!"),
        "youNeedToSignIn":
            MessageLookupByLibrary.simpleMessage("Giriş yapmalısınız"),
        "youNeedToSignInToSee": MessageLookupByLibrary.simpleMessage(
            "Aktif konuşmaları görmek için giriş yapmanız gerekiyor")
      };
}

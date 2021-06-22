import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<Deal> favoritedDealsFromJson(String str) =>
    List<Deal>.from((json.decode(str) as List<dynamic>)
        .map<dynamic>((dynamic e) => Deal.fromJson(e as Json)));

List<Deal> dealFromJson(String str) =>
    List<Deal>.from((json.decode(str)['_embedded']['deals'] as List<dynamic>)
        .map<dynamic>((dynamic e) => Deal.fromJson(e as Json)));

class Deal {
  const Deal({
    this.id,
    this.postedBy,
    required this.coverPhoto,
    required this.dealUrl,
    this.photos,
    this.upVoters,
    this.downVoters,
    required this.title,
    required this.description,
    this.dealScore,
    this.views,
    required this.category,
    required this.store,
    required this.price,
    required this.discountPrice,
    this.specialMark,
    this.createdAt,
    this.updatedAt,
  });

  factory Deal.fromJson(Json json) => Deal(
        id: json['id'] as String,
        postedBy: json['postedBy'] as String,
        coverPhoto: json['coverPhoto'] as String,
        dealUrl: json['dealUrl'] as String,
        photos: List<String>.from(json['photos'] as List<dynamic>),
        upVoters: List<String>.from(json['upVoters'] as List<dynamic>),
        downVoters: List<String>.from(json['downVoters'] as List<dynamic>),
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        store: json['store'] as String,
        price: json['price'] as double,
        discountPrice: json['discountPrice'] as double,
        dealScore: json['dealScore'] as int,
        views: json['views'] as int,
        specialMark: DateTime.now()
                    .difference(DateTime.parse(json['createdAt'] as String)) <=
                const Duration(days: 1)
            ? 'Yeni'
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String? postedBy;
  final String coverPhoto;
  final String dealUrl;
  final List<String>? photos;
  final List<String>? upVoters;
  final List<String>? downVoters;
  final String title;
  final String description;
  final int? dealScore;
  final int? views;
  final String category;
  final String store;
  final double price;
  final double discountPrice;
  final String? specialMark;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      if (postedBy != null) 'postedBy': postedBy,
      if (coverPhoto != null) 'coverPhoto': coverPhoto,
      if (dealUrl != null) 'dealUrl': dealUrl,
      if (photos != null) 'photos': photos,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (store != null) 'store': store,
      if (price != null) 'price': price,
      if (discountPrice != null) 'discountPrice': discountPrice,
    };
  }

  @override
  String toString() {
    return 'Deal{id: $id, postedBy: $postedBy, coverPhoto: $coverPhoto, photos: $photos, title: $title, description: $description, dealScore: $dealScore, views: $views, category: $category, price: $price, discountPrice: $discountPrice, specialMark: $specialMark, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

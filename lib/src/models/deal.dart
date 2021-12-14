import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<Deal> userDealsFromJson(String str) =>
    List<Deal>.from((json.decode(str) as List<dynamic>)
        .map<dynamic>((dynamic e) => Deal.fromJson(e as Json)));

List<Deal> dealsFromJson(String str) =>
    List<Deal>.from((json.decode(str)['_embedded']['deals'] as List<dynamic>)
        .map<dynamic>((dynamic e) => Deal.fromJson(e as Json)));

class Deal {
  const Deal({
    this.id,
    this.postedBy,
    required this.coverPhoto,
    required this.dealUrl,
    this.photos,
    this.upvoters,
    this.downvoters,
    required this.title,
    required this.description,
    this.dealScore,
    this.views,
    required this.category,
    required this.store,
    required this.originalPrice,
    required this.price,
    this.isNew,
    this.createdAt,
    this.updatedAt,
  });

  factory Deal.fromJson(Json json) => Deal(
        id: json['id'] as String,
        postedBy: json['postedBy'] as String,
        coverPhoto: json['coverPhoto'] as String,
        dealUrl: json['dealUrl'] as String,
        photos: List<String>.from(json['photos'] as List<dynamic>),
        upvoters: List<String>.from(json['upvoters'] as List<dynamic>),
        downvoters: List<String>.from(json['downvoters'] as List<dynamic>),
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        store: json['store'] as String,
        originalPrice: json['originalPrice'] as double,
        price: json['price'] as double,
        dealScore: json['dealScore'] as int,
        views: json['views'] as int,
        isNew: DateTime.now()
                .difference(DateTime.parse(json['createdAt'] as String)) <=
            const Duration(days: 1),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  factory Deal.fromJsonES(Json json) => Deal(
    dealUrl: '',
        id: json['id'] as String,
        coverPhoto: json['coverPhoto'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: (json['stringFacets'] as List<dynamic>).singleWhere(
                (e) => (e['facetName'] as String) == 'category')['facetValue']
            as String,
        store: (json['stringFacets'] as List<dynamic>).singleWhere(
                (e) => (e['facetName'] as String) == 'store')['facetValue']
            as String,
        originalPrice: json['originalPrice'] as double,
        price: (json['numberFacets'] as List<dynamic>).singleWhere(
                (e) => (e['facetName'] as String) == 'price')['facetValue']
            as double,
        isNew: DateTime.now()
                .difference(DateTime.parse(json['createdAt'] as String)) <=
            const Duration(days: 1),
      );

  final String? id;
  final String? postedBy;
  final String coverPhoto;
  final String dealUrl;
  final List<String>? photos;
  final List<String>? upvoters;
  final List<String>? downvoters;
  final String title;
  final String description;
  final int? dealScore;
  final int? views;
  final String category;
  final String store;
  final double originalPrice;
  final double price;
  final bool? isNew;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      if (postedBy != null) 'postedBy': postedBy,
      'coverPhoto': coverPhoto,
      'dealUrl': dealUrl,
      if (photos != null) 'photos': photos,
      'title': title,
      'description': description,
      'category': category,
      'store': store,
      'originalPrice': originalPrice,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'Deal{id: $id, postedBy: $postedBy, coverPhoto: $coverPhoto, photos: $photos, title: $title, description: $description, dealScore: $dealScore, views: $views, category: $category, originalPrice: $originalPrice, price: $price, specialMark: $isNew, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

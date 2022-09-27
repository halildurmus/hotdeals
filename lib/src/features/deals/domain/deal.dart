enum DealStatus { active, expired }

enum DealVoteType { up, down, unvote }

typedef Json = Map<String, dynamic>;

List<Deal> dealsFromJson(List<dynamic> jsonArray) => List<Deal>.from(
    jsonArray.map<dynamic>((dynamic e) => Deal.fromJson(e as Json)));

class Deal {
  const Deal({
    required this.coverPhoto,
    required this.title,
    required this.description,
    required this.category,
    required this.store,
    required this.originalPrice,
    required this.price,
    this.id,
    this.status = DealStatus.active,
    this.postedBy,
    this.dealUrl,
    this.photos,
    this.upvoters,
    this.downvoters,
    this.dealScore,
    this.views,
    this.isNew,
    this.createdAt,
    this.updatedAt,
  });

  factory Deal.fromJson(Json json) => Deal(
        id: json['id'] as String,
        status: _getStatus(json['status'] as String),
        postedBy: json['postedBy'] as String,
        coverPhoto: json['coverPhoto'] as String,
        dealUrl: json['dealUrl'] as String,
        photos: List<String>.from(json['photos'] as List<dynamic>),
        upvoters: Set<String>.from(json['upvoters'] as List<dynamic>),
        downvoters: Set<String>.from(json['downvoters'] as List<dynamic>),
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        store: json['store'] as String,
        originalPrice: json['originalPrice'] as double,
        price: json['price'] as double,
        dealScore: json['dealScore'] as int,
        views: json['views'] as int,
        isNew: _calculateIsNew(DateTime.parse(json['createdAt'] as String)),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  factory Deal.fromJsonES(Json json) => Deal(
        id: json['id'] as String,
        status: _getStatus(json['status'] as String),
        postedBy: json['postedBy'] as String,
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
        isNew: _calculateIsNew(DateTime.parse(json['createdAt'] as String)),
      );

  final String? id;
  final DealStatus status;
  final String? postedBy;
  final String coverPhoto;
  final String? dealUrl;
  final List<String>? photos;
  final Set<String>? upvoters;
  final Set<String>? downvoters;
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

  Json toJson() => <String, dynamic>{
        'coverPhoto': coverPhoto,
        'dealUrl': dealUrl,
        'photos': photos ?? const [],
        'title': title,
        'description': description,
        'category': category,
        'store': store,
        'originalPrice': originalPrice,
        'price': price,
      };

  @override
  String toString() =>
      'Deal{id: $id, status: $status, postedBy: $postedBy, coverPhoto: $coverPhoto, photos: $photos, title: $title, description: $description, dealScore: $dealScore, views: $views, category: $category, originalPrice: $originalPrice, price: $price, specialMark: $isNew, createdAt: $createdAt, updatedAt: $updatedAt}';
}

DealStatus _getStatus(String status) =>
    DealStatus.values.byName(status.toLowerCase());

bool _calculateIsNew(DateTime createdAt) =>
    DateTime.now().difference(createdAt) <= const Duration(days: 1);

import 'dart:convert';

typedef Json = Map<String, dynamic>;

List<Store> storeFromJson(String str) =>
    List<Store>.from((json.decode(str)['_embedded']['stores'] as List<dynamic>)
        .map<dynamic>((dynamic e) => Store.fromJson(e as Json)));

class Store {
  const Store({
    this.id,
    required this.name,
    required this.logo,
    this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Json json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        logo: json['logo'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String? id;
  final String name;
  final String logo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Json toJson() {
    return <String, dynamic>{
      'name': name,
      'logo': logo,
    };
  }

  @override
  String toString() {
    return 'Store{id: $id, name: $name, logo: $logo, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

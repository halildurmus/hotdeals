typedef Json = Map<String, dynamic>;

List<Store> storesFromJson(List<dynamic> jsonArray) => List<Store>.from(
    jsonArray.map<dynamic>((dynamic e) => Store.fromJson(e as Json)));

class Store {
  const Store({this.id, required this.name, required this.logo});

  factory Store.fromJson(Json json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        logo: json['logo'] as String,
      );

  final String? id;
  final String name;
  final String logo;

  Json toJson() => <String, dynamic>{
        'name': name,
        'logo': logo,
      };

  @override
  String toString() => 'Store{id: $id, name: $name, logo: $logo}';
}

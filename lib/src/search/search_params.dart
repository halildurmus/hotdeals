enum DealSortBy { createdAt, price }

enum Order { asc, desc }

typedef Json = Map<String, dynamic>;

class PriceRange {
  PriceRange({this.from, this.to});

  double? from;
  double? to;

  PriceRange copyWith({double? from, double? to}) =>
      PriceRange(from: from ?? this.from, to: to ?? this.to);

  factory PriceRange.fromString(String str) {
    final list = str.split('-');
    final from = double.parse(list[0]);
    double? to;
    if (list[1] != '*') {
      to = double.parse(list[1]);
    }

    return PriceRange(from: from, to: to);
  }

  String get formattedString =>
      r'$' +
      from!.toStringAsFixed(0) +
      ' - ' +
      r'$' +
      (to?.toStringAsFixed(0) ?? '*');

  @override
  String toString() => '$from:$to';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PriceRange && other.from == from && other.to == to;
  }

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

class SearchParams {
  SearchParams({
    String? query,
    List<String>? categories,
    List<PriceRange>? prices,
    List<String>? stores,
    this.hideExpired = false,
    this.sortBy,
    this.order,
    this.page = 0,
    this.size = 10,
  }) {
    this.query = query ?? '';
    this.categories = categories ?? List.empty(growable: true);
    this.prices = prices ?? List.empty(growable: true);
    this.stores = stores ?? List.empty(growable: true);
  }

  late String query;
  late List<String> categories;
  late List<PriceRange> prices;
  late List<String> stores;
  bool hideExpired;
  DealSortBy? sortBy;
  Order? order;
  int page;
  int size;

  SearchParams copyWith({
    String? query,
    List<String>? categories,
    List<PriceRange>? prices,
    List<String>? stores,
    bool? hideExpired,
    DealSortBy? sortBy,
    Order? order,
    int? page,
    int? size,
  }) {
    return SearchParams(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      prices: prices ?? this.prices,
      stores: stores ?? this.stores,
      hideExpired: hideExpired ?? this.hideExpired,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  /// Returns the applied filter count.
  int get filterCount =>
      (categories.isNotEmpty ? 1 : 0) +
      (prices.isNotEmpty ? 1 : 0) +
      (stores.isNotEmpty ? 1 : 0) +
      (hideExpired ? 1 : 0) +
      (sortBy != null ? 1 : 0);

  /// Resets the applied filters.
  void reset() {
    categories.clear();
    prices.clear();
    stores.clear();
    hideExpired = false;
    sortBy = null;
    order = null;
  }

  /// Returns a `Map` with the query parameters.
  Json get queryParameters {
    final queryParameters = <String, dynamic>{};
    if (query.isNotEmpty) {
      queryParameters.putIfAbsent('query', () => query);
    }
    if (categories.isNotEmpty) {
      queryParameters.putIfAbsent('categories', () => categories.join(','));
    }
    if (prices.isNotEmpty) {
      queryParameters.putIfAbsent('prices', () => prices.join(','));
    }
    if (stores.isNotEmpty) {
      queryParameters.putIfAbsent('stores', () => stores.join(','));
    }
    if (hideExpired) {
      queryParameters.putIfAbsent('hideExpired', () => 'true');
    }
    if (sortBy != null) {
      queryParameters.putIfAbsent('sortBy', () => sortBy!.name);
    }
    if (order != null) {
      queryParameters.putIfAbsent('order', () => order!.name);
    }
    queryParameters.putIfAbsent('page', () => '$page');
    queryParameters.putIfAbsent('size', () => '$size');

    return queryParameters;
  }
}

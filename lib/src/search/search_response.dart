import '../models/deal.dart';

typedef Json = Map<String, dynamic>;

class Hits {
  const Hits({required this.docCount, required this.hits});

  final int docCount;
  final List<Deal> hits;

  factory Hits.fromJson(Json json) => Hits(
        docCount: json['total']['value'] as int,
        hits: (json['hits'] as List<dynamic>).isNotEmpty
            ? List<Deal>.from(
                json['hits'].map((x) => Deal.fromJsonES(x['_source'])),
              )
            : [],
      );

  @override
  String toString() => 'Hits(docCount: $docCount, hits: $hits)';
}

class SearchResponse {
  const SearchResponse({
    required this.aggAllFilters,
    required this.aggCategory,
    required this.aggPrice,
    required this.aggStore,
    required this.hits,
  });

  final AggregationAllFilters? aggAllFilters;
  final Aggregation? aggCategory;
  final Aggregation? aggPrice;
  final Aggregation? aggStore;
  final Hits hits;

  factory SearchResponse.fromJson(Json json) {
    return SearchResponse(
      aggAllFilters:
          AggregationAllFilters.fromJson(json['aggregations']['aggAllFilters']),
      aggCategory: (json['aggregations']['aggCategory']['stringFacets']
                  ['aggSpecial']['names']['buckets'] as List<dynamic>)
              .isNotEmpty
          ? Aggregation.fromJson(json['aggregations']['aggCategory']
              ['stringFacets']['aggSpecial']['names']['buckets'][0])
          : null,
      aggPrice: (json['aggregations']['aggPrice']['numberFacets']['aggSpecial']
                  ['names']['buckets'] as List<dynamic>)
              .isNotEmpty
          ? Aggregation.fromJson(json['aggregations']['aggPrice']
              ['numberFacets']['aggSpecial']['names']['buckets'][0])
          : null,
      aggStore: (json['aggregations']['aggStore']['stringFacets']['aggSpecial']
                  ['names']['buckets'] as List<dynamic>)
              .isNotEmpty
          ? Aggregation.fromJson(json['aggregations']['aggStore']
              ['stringFacets']['aggSpecial']['names']['buckets'][0])
          : null,
      hits: Hits.fromJson(json['hits']),
    );
  }

  @override
  String toString() {
    return 'SearchResponse(aggAllFilters: $aggAllFilters, aggCategory: $aggCategory, aggPrice: $aggPrice, aggStore: $aggStore, hits: $hits)';
  }
}

class AggregationAllFilters {
  const AggregationAllFilters({
    required this.docCount,
    required this.numberFacets,
    required this.stringFacets,
  });

  final int docCount;
  final List<Aggregation>? numberFacets;
  final List<Aggregation>? stringFacets;

  factory AggregationAllFilters.fromJson(Json json) => AggregationAllFilters(
        docCount: json['doc_count'] as int,
        numberFacets:
            (json['numberFacets']['names']['buckets'] as List<dynamic>)
                    .isNotEmpty
                ? List<Aggregation>.from(
                    json['numberFacets']['names']['buckets']
                        .map((x) => Aggregation.fromJson(x)),
                  )
                : null,
        stringFacets:
            (json['stringFacets']['names']['buckets'] as List<dynamic>)
                    .isNotEmpty
                ? List<Aggregation>.from(
                    json['stringFacets']['names']['buckets']
                        .map((x) => Aggregation.fromJson(x)),
                  )
                : null,
      );

  @override
  String toString() =>
      'AggregationAllFilters(docCount: $docCount, numberFacets: $numberFacets, stringFacets: $stringFacets)';
}

class Bucket {
  const Bucket({required this.docCount, required this.key});

  final int docCount;
  final String key;

  factory Bucket.fromJson(Json json) => Bucket(
        docCount: json['doc_count'] as int,
        key: json['key'].toString(),
      );

  @override
  String toString() => 'Bucket(docCount: $docCount, key: $key)';
}

class Aggregation {
  const Aggregation({
    required this.buckets,
    required this.docCount,
    required this.facetName,
  });

  final List<Bucket> buckets;
  final int docCount;
  final String facetName;

  factory Aggregation.fromJson(Json json) {
    return Aggregation(
      buckets: List<Bucket>.from(
        json['values']['buckets'].map((x) => Bucket.fromJson(x)),
      )..sort((a, b) => a.key.compareTo(b.key)),
      docCount: json['doc_count'] as int,
      facetName: json['key'] as String,
    );
  }

  @override
  String toString() =>
      'Aggregation(buckets: $buckets, docCount: $docCount, facetName: $facetName)';
}

import '../models/deal.dart';

typedef Json = Map<String, dynamic>;

class Hits {
  const Hits({required this.docCount, required this.hits});

  factory Hits.fromJson(Json json) => Hits(
        docCount: json['total']['value'] as int,
        hits: (json['hits'] as List<dynamic>).isNotEmpty
            ? List<Deal>.from(
                json['hits'].map((x) => Deal.fromJsonES(x['_source'])),
              )
            : [],
      );

  final int docCount;
  final List<Deal> hits;

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

  factory SearchResponse.fromJson(Json json) => SearchResponse(
        aggAllFilters: AggregationAllFilters.fromJson(
            json['aggregations']['aggAllFilters']),
        aggCategory: (json['aggregations']['aggCategory']['stringFacets']
                    ['aggSpecial']['names']['buckets'] as List<dynamic>)
                .isNotEmpty
            ? Aggregation.fromJson(json['aggregations']['aggCategory']
                ['stringFacets']['aggSpecial']['names']['buckets'][0])
            : null,
        aggPrice: (json['aggregations']['aggPrice']['numberFacets']
                    ['aggSpecial']['names']['buckets'] as List<dynamic>)
                .isNotEmpty
            ? Aggregation.fromJson(json['aggregations']['aggPrice']
                ['numberFacets']['aggSpecial']['names']['buckets'][0])
            : null,
        aggStore: (json['aggregations']['aggStore']['stringFacets']
                    ['aggSpecial']['names']['buckets'] as List<dynamic>)
                .isNotEmpty
            ? Aggregation.fromJson(json['aggregations']['aggStore']
                ['stringFacets']['aggSpecial']['names']['buckets'][0])
            : null,
        hits: Hits.fromJson(json['hits']),
      );

  final AggregationAllFilters? aggAllFilters;
  final Aggregation? aggCategory;
  final Aggregation? aggPrice;
  final Aggregation? aggStore;
  final Hits hits;

  @override
  String toString() =>
      'SearchResponse(aggAllFilters: $aggAllFilters, aggCategory: $aggCategory, aggPrice: $aggPrice, aggStore: $aggStore, hits: $hits)';
}

class AggregationAllFilters {
  const AggregationAllFilters({
    required this.docCount,
    required this.numberFacets,
    required this.stringFacets,
  });

  factory AggregationAllFilters.fromJson(Json json) => AggregationAllFilters(
        docCount: json['doc_count'] as int,
        numberFacets:
            (json['numberFacets']['names']['buckets'] as List<dynamic>)
                    .isNotEmpty
                ? List<Aggregation>.from(
                    json['numberFacets']['names']['buckets']
                        .map(Aggregation.fromJson),
                  )
                : null,
        stringFacets:
            (json['stringFacets']['names']['buckets'] as List<dynamic>)
                    .isNotEmpty
                ? List<Aggregation>.from(
                    json['stringFacets']['names']['buckets']
                        .map(Aggregation.fromJson),
                  )
                : null,
      );

  final int docCount;
  final List<Aggregation>? numberFacets;
  final List<Aggregation>? stringFacets;

  @override
  String toString() =>
      'AggregationAllFilters(docCount: $docCount, numberFacets: $numberFacets, stringFacets: $stringFacets)';
}

class Bucket {
  const Bucket({required this.docCount, required this.key});

  factory Bucket.fromJson(dynamic json) => Bucket(
        docCount: json['doc_count'] as int,
        key: json['key'].toString(),
      );

  final int docCount;
  final String key;

  @override
  String toString() => 'Bucket(docCount: $docCount, key: $key)';
}

class Aggregation {
  const Aggregation({
    required this.buckets,
    required this.docCount,
    required this.facetName,
  });

  factory Aggregation.fromJson(dynamic json) => Aggregation(
        buckets: List<Bucket>.from(
          json['values']['buckets'].map(Bucket.fromJson),
        )..sort((a, b) => a.key.compareTo(b.key)),
        docCount: json['doc_count'] as int,
        facetName: json['key'] as String,
      );

  final List<Bucket> buckets;
  final int docCount;
  final String facetName;

  @override
  String toString() =>
      'Aggregation(buckets: $buckets, docCount: $docCount, facetName: $facetName)';
}

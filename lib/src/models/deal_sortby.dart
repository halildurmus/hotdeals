enum DealSortBy { createdAt, dealScore, price }

extension AsString on DealSortBy {
  String get asString => toString().split('.').last;
}

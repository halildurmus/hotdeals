enum DealVoteType { up, down, unvote }

extension AsString on DealVoteType {
  String get asString => toString().toUpperCase().split('.').last;
}

enum VoteType { upVote, downVote }

extension AsString on VoteType {
  String get asString => toString().split('.').last;
}

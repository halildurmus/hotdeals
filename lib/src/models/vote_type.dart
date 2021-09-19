enum VoteType { upvote, downvote }

extension AsString on VoteType {
  String get asString => toString().split('.').last;
}

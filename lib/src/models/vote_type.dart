import 'package:flutter/foundation.dart';

enum VoteType { upVote, downVote }

extension AsString on VoteType {
  String get asString => describeEnum(this);
}

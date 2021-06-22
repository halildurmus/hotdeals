library dash_chat;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:line_icons/line_icons.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

export 'package:flutter_parsed_text/flutter_parsed_text.dart';
export 'package:intl/intl.dart' hide TextDirection;

part 'src/chat_input_toolbar.dart';
part 'src/chat_view.dart';
part 'src/message_listview.dart';
part 'src/models/chat_message.dart';
part 'src/models/quick_replies.dart';
part 'src/models/reply.dart';
part 'src/models/scroll_to_bottom_style.dart';
part 'src/widgets/avatar_container.dart';
part 'src/widgets/custom_scroll_behaviour.dart';
part 'src/widgets/date_builder.dart';
part 'src/widgets/image_fullscreen.dart';
part 'src/widgets/load_earlier.dart';
part 'src/widgets/message_container.dart';
part 'src/widgets/quick_reply.dart';
part 'src/widgets/scroll_to_bottom.dart';

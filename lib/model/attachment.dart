import 'dart:io';

import 'package:simple_chat/model/message.dart';

class Attachment {
  const Attachment({
    this.file,
    required this.type,
    this.url,
  });

  final MessageType type;
  final File? file;
  final String? url;
}

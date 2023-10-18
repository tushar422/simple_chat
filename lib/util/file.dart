//identify file type.

import 'package:simple_chat/model/message.dart';
import 'package:mime/mime.dart';

MessageType getMessageType(String fileName) {

  final type = lookupMimeType(fileName);
  if (type != null) {
    if (type.startsWith('image')) return MessageType.image;
    if (type.startsWith('video')) return MessageType.video;
  }
  return MessageType.fileUrl;
}

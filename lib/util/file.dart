//identify file type.

import 'package:simple_chat/model/message.dart';
import 'package:mime/mime.dart';

MessageType getMessageType(String fileName) {
  // image/png
// 2
// I/flutter (25244): image/jpeg
// I/flutter (25244): image/gif
// I/flutter (25244): audio/mpeg
// I/flutter (25244): audio/x-wav
// I/flutter (25244): audio/ogg
// I/flutter (25244): video/mp4
// I/flutter (25244): video/x-matroska
  final type = lookupMimeType(fileName);
  if (type != null) {
    if (type.startsWith('image')) return MessageType.image;
    if (type.startsWith('video')) return MessageType.video;
  }
  return MessageType.fileUrl;
}

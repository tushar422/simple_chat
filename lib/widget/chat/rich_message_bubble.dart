import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:simple_chat/model/message.dart';
import 'package:simple_chat/theme/custom.dart';
import 'package:simple_chat/widget/common/loading_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class RichMessageBubble extends StatelessWidget {
  const RichMessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.type,
    required this.url,
  }) : isFirstInSequence = true;

  const RichMessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.type,
    required this.url,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final MessageType type;
  final String url;

  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                userImage!,
              ),
              backgroundColor: colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // First messages in the sequence provide a visual buffer at
                  // the top.
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        username!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                  // The "speech" box surrounding the message.
                  Container(
                    decoration: BoxDecoration(
                      color: (isMe)
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant,
                      // Only show the message bubble's "speaking edge" if first in
                      // the chain.
                      // Whether the "speaking edge" is on the left or right depends
                      // on whether or not the message bubble is the current user.
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    // Set some reasonable constraints on the width of the
                    // message bubble so it can adjust to the amount of text
                    // it should show.
                    constraints: const BoxConstraints(maxWidth: 250),
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 5,
                    ),
                    // Margin around the bubble.
                    margin: const EdgeInsets.symmetric(
                      vertical: 1.5,
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                          child: Text(
                            message,
                            style: TextStyle(
                              // Add a little line spacing to make the text look nicer
                              // when multilined.
                              height: 1.3,
                              color: (isMe)
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            softWrap: true,
                          ),
                        ),
                        // const SizedBox(height: 2),
                        if (type == MessageType.image)
                          Stack(children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 4),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black,
                              ),
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                minHeight: 100,
                                minWidth: 150,
                                maxWidth: 500,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (ctx, url) =>
                                    // Text('Image is loading'),
                                    const Center(
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),

                                // placeholder: (context, url) ,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                              // child: Image.network(
                              //   url,
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            Positioned(
                              right: 5,
                              bottom: 8,
                              // alignment: Alignment.topRight,
                              child: SizedBox.square(
                                dimension: 30,
                                child: IconButton.filledTonal(
                                  onPressed: _launch,
                                  icon: Icon(
                                    Icons.open_in_new,
                                    size: 14,
                                  ),
                                ),
                              ),
                            )
                          ]),
                        if (type == MessageType.video)
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            clipBehavior: Clip.hardEdge,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black,
                            ),
                            constraints: BoxConstraints(
                              maxHeight: 250,
                              minHeight: 100,
                              minWidth: 150,
                              maxWidth: 500,
                            ),
                            child: Stack(children: [
                              FutureBuilder(
                                future: VideoThumbnail.thumbnailData(
                                  video: url,
                                  imageFormat: ImageFormat.JPEG,
                                  maxWidth:
                                      300, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                  quality: 100,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasData) {
                                    if (snapshot.data != null)
                                      return Center(
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    else
                                      return const Center(
                                        child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Icon(Icons.error),
                                        ),
                                      );
                                  }
                                  return const Center(
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: IconButton.filledTonal(
                                  onPressed: _launch,
                                  icon: Icon(Icons.play_arrow_rounded),
                                ),
                              ),
                            ]),
                            // child: CachedNetworkImage(

                            //   imageUrl: url,
                            //   placeholder: (ctx, url) =>
                            //       // Text('Image is loading'),
                            //       const Center(
                            //     child: SizedBox(
                            //       height: 30,
                            //       width: 30,
                            //       child: CircularProgressIndicator(
                            //         strokeWidth: 2,
                            //       ),
                            //     ),

                            //   ),

                            //   // placeholder: (context, url) ,
                            //   errorWidget: (context, url, error) =>
                            //       const Icon(Icons.error),
                            //   fit: BoxFit.cover,
                            // ),
                            // child: Image.network(
                            //   url,
                            //   fit: BoxFit.cover,
                            // ),
                          ),
                        if (type == MessageType.fileUrl)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: ElevatedButton(
                              onPressed: _launch,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(0)),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: 100,
                                  minHeight: 75,
                                  minWidth: 150,
                                  maxWidth: 500,
                                ),
                                decoration: BoxDecoration(
                                    // color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [
                                  Expanded(
                                      child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'File Attachment',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style:
                                              textTheme.titleMedium!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          'Tap to open',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: textTheme.bodySmall!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
                                    padding: EdgeInsets.all(8),
                                    decoration: ShapeDecoration(
                                      shape: CircleBorder(
                                          side: BorderSide(
                                        width: 1,
                                        color: fileAttachmentThemeColor,
                                      )),
                                      color: fileAttachmentThemeColor
                                          .withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      Icons.attach_file,
                                      size: 25,
                                      color: fileAttachmentThemeColor,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        if (type == MessageType.location)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: ElevatedButton(
                              onPressed: _launch,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(0)),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: 100,
                                  minHeight: 75,
                                  minWidth: 150,
                                  maxWidth: 500,
                                ),
                                decoration: BoxDecoration(
                                    // color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [
                                  Expanded(
                                      child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Location URL',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style:
                                              textTheme.titleMedium!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          'Tap to open',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: textTheme.bodySmall!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
                                    padding: EdgeInsets.all(8),
                                    decoration: ShapeDecoration(
                                      shape: CircleBorder(
                                          side: BorderSide(
                                        width: 1,
                                        color: locationAttachmentThemeColor,
                                      )),
                                      color: locationAttachmentThemeColor
                                          .withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      Icons.pin_drop_rounded,
                                      size: 25,
                                      color: locationAttachmentThemeColor,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        if (type == MessageType.link)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: ElevatedButton(
                              onPressed: _launch,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(0)),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: 100,
                                  minHeight: 75,
                                  minWidth: 150,
                                  maxWidth: 500,
                                ),
                                decoration: BoxDecoration(
                                    // color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [
                                  Expanded(
                                      child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Link',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style:
                                              textTheme.titleMedium!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          'Tap to open',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: textTheme.bodySmall!.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
                                    padding: EdgeInsets.all(8),
                                    decoration: ShapeDecoration(
                                      shape: CircleBorder(
                                          side: BorderSide(
                                        width: 1,
                                        color: linkAttachmentThemeColor,
                                      )),
                                      color: linkAttachmentThemeColor
                                          .withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      Icons.link,
                                      size: 25,
                                      color: linkAttachmentThemeColor,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _launch() {
    launchUrl(Uri.parse(url));
  }
}

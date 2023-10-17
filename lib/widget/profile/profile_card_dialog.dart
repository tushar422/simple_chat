import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_chat/model/user.dart';
import 'package:simple_chat/util/fetch.dart';
import 'package:simple_chat/widget/common/toast.dart';
import 'package:simple_chat/widget/profile/profile_shimmer.dart';
import 'package:simple_chat/widget/profile/qr_card_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCardDialog extends StatefulWidget {
  const ProfileCardDialog({
    super.key,
    this.profile,
  }) : uid = null;

  const ProfileCardDialog.fromUID({
    super.key,
    required this.uid,
  }) : profile = null;
  final String? uid;
  final User? profile;

  @override
  State<ProfileCardDialog> createState() => _ProfileCardDialogState();
}

class _ProfileCardDialogState extends State<ProfileCardDialog> {
  late final User userProfile;
  bool _loading = true;
  @override
  void initState() {
    if (widget.profile == null && widget.uid == null) {
      throw Exception(
          'Profile Card: Specify either the User object or the UID to create profile card.');
    }
    if (widget.profile != null) {
      userProfile = widget.profile!;
      _loading = false;
    }
    if (widget.uid != null) {
      _setProfile(widget.uid!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 10,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      content: (_loading)
          ? const ProfileCardShimmer()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Image.network(
                    userProfile.imgUrl ?? dummyProfileImageUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    // height: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 5),
                  child: Text(
                    userProfile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  leading: Text('Email'),
                  title: Text(userProfile.email),
                  trailing: SizedBox(
                    height: 35,
                    width: 35,
                    child: IconButton.filledTonal(
                        icon: Icon(Icons.outgoing_mail),
                        iconSize: 16,
                        onPressed: () {
                          launchUrl(
                            Uri.parse(
                                'mailto:${userProfile.email}?subject=Simple_Chat!'),
                          );
                        }),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                ),
                ListTile(
                  leading: Text('UID'),
                  title: Text(userProfile.uid),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: userProfile.uid));
                    showToast('UID copied to clipboard');
                  },
                  trailing: SizedBox(
                    height: 35,
                    width: 35,
                    child: IconButton.filledTonal(
                        icon: Icon(Icons.qr_code_rounded),
                        iconSize: 16,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return QRCardDialog(
                                  content: userProfile.uid,
                                  name: userProfile.name,
                                );
                              });
                        }),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                ),
              ],
            ),
      actions: [
        if (myUserId() == userProfile.uid)
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.edit),
            label: Text('Edit'),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Okay'),
        ),
      ],
    );
  }

  void _setProfile(String uid) async {
    setState(() {
      _loading = true;
    });
    final user = await fetchUserData(uid);
    userProfile = user;
    setState(() {
      _loading = false;
    });
  }
}

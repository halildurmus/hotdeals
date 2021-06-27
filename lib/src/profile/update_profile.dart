import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/spring_service.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/settings_list_item.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late TextEditingController nicknameController;
  late void Function() showLoadingDialog;

  Future<MyUser> updateUserAvatar(String userId, String avatarUrl) async {
    return GetIt.I
        .get<SpringService>()
        .updateUserAvatar(userId: userId, avatarUrl: avatarUrl)
        .catchError((dynamic error) {
      print(error);
    });
  }

  Future<MyUser> updateNickname(String userId, String nickname) async {
    return GetIt.I
        .get<SpringService>()
        .updateUserNickname(userId: userId, nickname: nickname)
        .catchError((dynamic error) {
      print(error);
    });
  }

  Future<void> getImg(String userId, ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final PickedFile? pickedFile =
        await picker.getImage(source: imageSource, maxWidth: 1000);

    showLoadingDialog();

    if (pickedFile != null) {
      final File image = File(pickedFile.path);

      final Reference storageRef =
          FirebaseStorage.instance.ref().child('avatars').child(userId);

      final UploadTask uploadTask = storageRef.putFile(
        image,
        SettableMetadata(
          contentType: 'image/jpg',
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String avatarUrl = await snapshot.ref.getDownloadURL();

      if (avatarUrl != null) {
        await updateUserAvatar(userId, avatarUrl);
        Provider.of<UserControllerImpl>(context, listen: false).getUser();
        Navigator.of(context).pop();
      }
    } else {
      print('No image selected.');
    }
  }

  void showImagePicker(String userId) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      builder: (BuildContext ctx) {
        final TextTheme textTheme = Theme.of(ctx).textTheme;

        return Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      FontAwesomeIcons.times,
                      color: Color.fromRGBO(148, 148, 148, 1),
                      size: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      AppLocalizations.of(context)!.selectSource,
                      textAlign: TextAlign.center,
                      style: textTheme.subtitle1!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.photo_camera),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () async {
                await getImg(userId, ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () async {
                await getImg(userId, ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    showLoadingDialog =
        () => GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
    final MyUser user = context.read<UserControllerImpl>().user!;
    nicknameController = TextEditingController(text: user.nickname);
    super.initState();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final MyUser user = Provider.of<UserControllerImpl>(context).user!;

    void nicknameOnTap() {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nicknameController,
                        onChanged: (String? text) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.nickname,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: theme.colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: nicknameController.text.isEmpty ||
                                  nicknameController.text == user.nickname
                              ? null
                              : () async {
                                  showLoadingDialog();
                                  await updateNickname(
                                      user.id!, nicknameController.text);
                                  Navigator.of(context).pop();
                                  Provider.of<UserControllerImpl>(context,
                                          listen: false)
                                      .getUser();
                                  Navigator.of(context).pop();
                                },
                          child: Text(
                            AppLocalizations.of(context)!.updateNickname,
                            style: textTheme.bodyText1!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updateProfile),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              AppLocalizations.of(context)!.generalSettings,
              style: textTheme.subtitle1,
            ),
          ),
          SettingsListItem(
            image: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar!),
            ),
            title: AppLocalizations.of(context)!.avatar,
            onTap: () => showImagePicker(user.id!),
          ),
          SettingsListItem(
            icon: Icons.edit,
            title: AppLocalizations.of(context)!.nickname,
            subtitle: user.nickname,
            onTap: nicknameOnTap,
          ),
        ],
      ),
    );
  }
}

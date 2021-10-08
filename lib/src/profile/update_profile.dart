import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller_impl.dart';
import '../services/firebase_storage_service.dart';
import '../services/image_picker_service.dart';
import '../services/spring_service.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/settings_list_item.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> with UiLoggy {
  late TextEditingController nicknameController;
  late VoidCallback showLoadingDialog;
  late MyUser user;

  Future<MyUser> updateUserAvatar(String userId, String avatarUrl) async {
    return GetIt.I
        .get<SpringService>()
        .updateUserAvatar(userId: userId, avatarUrl: avatarUrl)
        .catchError((dynamic error) {});
  }

  Future<MyUser> updateNickname(String userId, String nickname) async {
    return GetIt.I
        .get<SpringService>()
        .updateUserNickname(userId: userId, nickname: nickname)
        .catchError((dynamic error) {});
  }

  Future<void> getImg(String userID, ImageSource imageSource) async {
    final XFile? pickedFile = await GetIt.I
        .get<ImagePickerService>()
        .pickImage(source: imageSource, maxWidth: 1000);

    showLoadingDialog();

    if (pickedFile != null) {
      final String mimeType = lookupMimeType(pickedFile.name) ?? '';
      final String avatarURL =
          await GetIt.I.get<FirebaseStorageService>().uploadUserAvatar(
                filePath: pickedFile.path,
                fileName: pickedFile.name,
                mimeType: mimeType,
                userID: userID,
              );
      await updateUserAvatar(userID, avatarURL);
      Provider.of<UserControllerImpl>(context, listen: false).getUser();
      Navigator.of(context).pop();
    } else {
      loggy.info('No image selected.');
    }
  }

  Future<void> showImagePicker(String userID) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext ctx) {
        final textTheme = Theme.of(ctx).textTheme;

        return Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      FontAwesomeIcons.times,
                      color: Color.fromRGBO(148, 148, 148, 1),
                      size: 20,
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
                await getImg(userID, ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () async {
                await getImg(userID, ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> nicknameOnTap() {
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.nickname,
                      ),
                      onChanged: (String? text) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          primary: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.updateNickname,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    user = Provider.of<UserControllerImpl>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.updateProfile)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              AppLocalizations.of(context)!.generalSettings,
              style: textTheme.subtitle1,
            ),
          ),
          SettingsListItem(
            onTap: () => showImagePicker(user.id!),
            image: CachedNetworkImage(
              imageUrl: user.avatar!,
              imageBuilder:
                  (BuildContext ctx, ImageProvider<Object> imageProvider) =>
                      CircleAvatar(backgroundImage: imageProvider),
              placeholder: (BuildContext context, String url) =>
                  const CircleAvatar(),
            ),
            title: AppLocalizations.of(context)!.avatar,
          ),
          SettingsListItem(
            onTap: nicknameOnTap,
            icon: Icons.edit,
            title: AppLocalizations.of(context)!.nickname,
            subtitle: user.nickname,
          ),
        ],
      ),
    );
  }
}

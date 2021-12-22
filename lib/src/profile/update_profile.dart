import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart' show UiLoggy;
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../models/my_user.dart';
import '../models/user_controller.dart';
import '../services/auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/image_picker_service.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/exception_alert_dialog.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/settings_list_item.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> with UiLoggy {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nicknameController;
  late VoidCallback showLoadingDialog;
  late MyUser user;

  Future<void> updateAvatar(String userID, String avatarURL) async {
    try {
      await GetIt.I
          .get<SpringService>()
          .updateUserAvatar(userId: userID, avatarUrl: avatarURL);
      Provider.of<UserController>(context, listen: false).getUser();
      // Pops the LoadingDialog.
      Navigator.of(context).pop();
    } on Exception catch (e) {
      loggy.error(e);
      // Pops the LoadingDialog.
      Navigator.of(context).pop();
      final snackBar = CustomSnackBar(
        icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
        text: l(context).anErrorOccurred,
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> updateNickname(String userId, String nickname) async {
    showLoadingDialog();
    try {
      await GetIt.I
          .get<SpringService>()
          .updateUserNickname(userId: userId, nickname: nickname);
      // Pops the LoadingDialog.
      Navigator.of(context).pop();
      // Fetches the updated user data.
      Provider.of<UserController>(context, listen: false).getUser();
      // Pops the update nickname Dialog.
      Navigator.of(context).pop();
    } on Exception catch (e) {
      loggy.error(e);
      // Pops the LoadingDialog.
      Navigator.of(context).pop();
      // Pops the update nickname Dialog.
      Navigator.of(context).pop();
      final snackBar = CustomSnackBar(
        icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
        text: l(context).anErrorOccurred,
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> getImg(String userID, ImageSource imageSource) async {
    final XFile? pickedFile = await GetIt.I
        .get<ImagePickerService>()
        .pickImage(source: imageSource, maxWidth: 1000);

    showLoadingDialog();

    if (pickedFile != null) {
      final mimeType = lookupMimeType(pickedFile.name) ?? '';
      final avatarURL =
          await GetIt.I.get<FirebaseStorageService>().uploadUserAvatar(
                filePath: pickedFile.path,
                fileName: pickedFile.name,
                mimeType: mimeType,
                userID: userID,
              );
      await updateAvatar(userID, avatarURL);
    } else {
      loggy.info('No image selected.');
      Navigator.of(context).pop();
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
      builder: (ctx) {
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
                      l(context).selectSource,
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
              title: Text(l(context).camera),
              onTap: () async {
                await getImg(userID, ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.photo_library),
              title: Text(l(context).gallery),
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
    final deviceWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: nicknameController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          errorMaxLines: 2,
                          labelText: l(context).nickname,
                        ),
                        maxLength: 25,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: (text) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.length < 5) {
                            return l(context).nicknameMustBe;
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: nicknameController.text != user.nickname &&
                              (_formKey.currentState?.validate() ?? false)
                          ? () =>
                              updateNickname(user.id!, nicknameController.text)
                          : null,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(deviceWidth, 45),
                        primary: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        l(context).updateNickname,
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
    final MyUser user = context.read<UserController>().user!;
    nicknameController = TextEditingController(text: user.nickname);
    super.initState();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool _didRequestSignOut = await CustomAlertDialog(
          title: l(context).logoutConfirm,
          cancelActionText: l(context).cancel,
          defaultActionText: l(context).logout,
        ).show(context) ??
        false;

    if (_didRequestSignOut) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await GetIt.I.get<SpringService>().removeFCMToken(token: fcmToken!);
      await _signOut(context);
      Provider.of<UserController>(context, listen: false).logout();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signOut();
    } on PlatformException catch (e) {
      await ExceptionAlertDialog(
        title: l(context).logoutFailed,
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<UserController>(context, listen: false).user == null) {
      return const SizedBox();
    }
    user = Provider.of<UserController>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text(l(context).updateProfile)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsListItem(
            onTap: () => showImagePicker(user.id!),
            leading: CachedNetworkImage(
              imageUrl: user.avatar!,
              imageBuilder: (ctx, imageProvider) =>
                  CircleAvatar(backgroundImage: imageProvider),
              placeholder: (context, url) => const CircleAvatar(),
            ),
            title: l(context).avatar,
          ),
          SettingsListItem(
            onTap: nicknameOnTap,
            leading: const Icon(Icons.edit),
            title: l(context).nickname,
            subtitle: user.nickname,
          ),
          SettingsListItem(
            onTap: () => _confirmSignOut(context),
            hasNavigation: false,
            leading: const Icon(Icons.logout),
            title: l(context).logout,
          ),
        ],
      ),
    );
  }
}

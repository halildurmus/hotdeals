import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_picture_upload_controller.dart';

/// Defines the source for image selection
enum ImageSourceExtended {
  /// user will be asked if camera or gallery shall be used
  askUser,

  /// camera will be opened for image selection
  camera,

  /// gallery will be opened for image selection
  gallery,
}

class PictureUploadLocalization {
  /// Localization for PictureUploadWidget
  PictureUploadLocalization({
    this.abort = 'Abort',
    this.camera = 'Camera',
    this.gallery = 'Gallery',
    this.selectSource = 'Select source',
  });

  /// Abort text for image input selection
  final String abort;

  /// Camera text for image input selection
  final String camera;

  /// Gallery text for image input selection
  final String gallery;

  /// Select source text for image input selection
  final String selectSource;
}

class PictureUploadSettings {
  /// Basic settings for PictureUploadWidget
  PictureUploadSettings({
    this.customDeleteFunction,
    this.customUploadFunction,
    this.imageManipulationSettings = const ImageManipulationSettings(),
    this.imageSource = ImageSourceExtended.askUser,
    this.maxImageCount = 5,
    this.minImageCount = 0,
    this.onErrorFunction,
    this.uploadDirectory = '/Uploads/',
  });

  /// The function which shall be called to delete the image, if you don't want to use the default one
  final Function(Reference reference)? customDeleteFunction;

  /// The function which shall be called to upload the image, if you don't want to use the default one
  final Function(File image, int id)? customUploadFunction;

  /// The settings how the image shall be modified before upload
  final ImageManipulationSettings imageManipulationSettings;

  /// Defines which image source shall be used if user clicks button (options: ask_user, gallery, camera)
  final ImageSourceExtended imageSource;

  /// The maximum images which can be uploaded
  final int maxImageCount;

  /// The minimum images which shall be uploaded (controls the delete button)
  final int minImageCount;

  /// The function which shall be called if an error occurs
  final Function? onErrorFunction;

  /// The directory where you want to upload to
  final String uploadDirectory;
}

class ImageManipulationSettings {
  /// The settings how the image shall be modified before upload
  const ImageManipulationSettings({
    this.aspectRatio = const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    this.compressQuality = 75,
    this.enableCropping = false,
    this.maxHeight = 800,
    this.maxWidth = 800,
  });

  /// The requested aspect ratio for the image
  final CropAspectRatio aspectRatio;

  /// The requested compressQuality of the image [0..100]
  final int compressQuality;

  /// If true, a cropping screen will appear after image selection (with maxWidth, maxHeight & aspectRatio setting applied)
  final bool enableCropping;

  /// The requested maxHeight of the image
  final int maxHeight;

  /// The requested maxWidth of the image
  final int maxWidth;
}

class PictureUploadButtonStyle {
  /// Style options for PictureUploadWidget
  PictureUploadButtonStyle({
    this.backgroundColor = Colors.blueAccent,
    this.closeIconBackgroundColor = const Color(0xFFE5E5EA),
    this.closeIconColor = Colors.blueAccent,
    this.fontColor = Colors.white,
    this.fontSize = 14.0,
    this.iconData = Icons.add_a_photo,
    this.iconSize = 40.0,
    this.height = 100,
    this.width = 80,
  });

  /// The background color of the upload button
  final Color backgroundColor;

  /// The background color of the close icon box
  final Color closeIconBackgroundColor;

  /// The color of the close icon
  final Color closeIconColor;

  /// The font color of the text within the upload button
  final Color fontColor;

  /// The font size of the text within the upload button
  final double fontSize;

  /// The icon which shall be displayed within the upload button
  final IconData iconData;

  /// The icon size of the icon
  final double iconSize;

  /// The height of the button
  final double height;

  /// The width of the button
  final double width;
}

class PictureUploadWidget extends StatefulWidget {
  /// PictureUploadWidget displays a customizable button which opens a specified image source (see settings)
  /// which is used to select an image. The selected image can be manipulated and is uploaded afterwards.
  PictureUploadWidget({
    PictureUploadButtonStyle? buttonStyle,
    PictureUploadLocalization? localization,
    PictureUploadSettings? settings,
    FirebaseStorage? storageInstance,
    this.buttonText = 'Upload Picture',
    this.enabled = true,
    this.initialImages,
    required this.onPicturesChange,
  })  : buttonStyle = buttonStyle ?? PictureUploadButtonStyle(),
        localization = localization ?? PictureUploadLocalization(),
        settings = settings ?? PictureUploadSettings(),
        storageInstance = storageInstance ?? FirebaseStorage.instance;

  /// All ui customization settings for the upload button
  final PictureUploadButtonStyle buttonStyle;

  /// Localization for widget texts
  final PictureUploadLocalization localization;

  /// All configuration settings for the upload
  final PictureUploadSettings settings;

  /// The firebase storage instance to be used by the plugin
  final FirebaseStorage storageInstance;

  /// The text displayed within the upload button
  final String buttonText;

  /// If false, the widget won't react if clicked
  final bool enabled;

  /// The images which shall be displayed initial
  final List<UploadJob>? initialImages;

  /// Function is called after an image is uploaded, the the UploadJob as parameter
  final Function onPicturesChange;

  @override
  _PictureUploadWidgetState createState() => _PictureUploadWidgetState();
}

/// State of the widget
class _PictureUploadWidgetState extends State<PictureUploadWidget> {
  List<UploadJob> _activeUploadedFiles = [];
  late FirebasePictureUploadController _pictureUploadController;
  int _uploadsProcessing = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialImages != null) {
      _activeUploadedFiles = widget.initialImages!;
    }

    _pictureUploadController =
        FirebasePictureUploadController(widget.storageInstance);

    if (_activeUploadedFiles.length < widget.settings.maxImageCount &&
        !activeJobsContainUploadWidget()) {
      _activeUploadedFiles.add(UploadJob());
    }
  }

  bool activeJobsContainUploadWidget() {
    for (var job in _activeUploadedFiles) {
      if (job.storageReference == null &&
          job.image == null &&
          job.imageProvider == null &&
          job.oldImage == null &&
          job.oldStorageReference == null) {
        return true;
      }
    }
    return false;
  }

  void onImageChange(UploadJob uploadJob) {
    // update UploadJobs list
    for (int i = _activeUploadedFiles.length - 1; i >= 0; i--) {
      if (_activeUploadedFiles[i].id == uploadJob.id) {
        _activeUploadedFiles[i] = uploadJob;
        break;
      }
    }

    // add / remove from processing list
    if (uploadJob.uploadProcessing) {
      _uploadsProcessing++;

      // add most recent object
      if (uploadJob.action == UploadAction.actionUpload &&
          _activeUploadedFiles.length < widget.settings.maxImageCount &&
          !activeJobsContainUploadWidget()) {
        _activeUploadedFiles.add(UploadJob());
      }
    } else {
      _uploadsProcessing--;

      if (uploadJob.action == UploadAction.actionUpload) {
        // issue occurred? => remove
        if (uploadJob.storageReference == null) {
          // remove from active uploaded files
          for (int i = _activeUploadedFiles.length - 1; i >= 0; i--) {
            if (_activeUploadedFiles[i].id == uploadJob.id) {
              _activeUploadedFiles.removeAt(i);
              break;
            }
          }

          if (_activeUploadedFiles.length ==
                  widget.settings.maxImageCount - 1 &&
              !activeJobsContainUploadWidget()) {
            _activeUploadedFiles.add(UploadJob());
          }
        }
      } else if (uploadJob.action == UploadAction.actionDelete &&
          uploadJob.image == null) {
        // remove from active uploaded files
        for (int i = _activeUploadedFiles.length - 1; i >= 0; i--) {
          if (_activeUploadedFiles[i].id == uploadJob.id) {
            _activeUploadedFiles.removeAt(i);
            break;
          }
        }

        if (_activeUploadedFiles.length == widget.settings.maxImageCount - 1 &&
            !activeJobsContainUploadWidget()) {
          _activeUploadedFiles.add(UploadJob());
        }
      }
    }

    widget.onPicturesChange(
        uploadJobs: _activeUploadedFiles,
        pictureUploadProcessing: _uploadsProcessing != 0);
    setState(() {
      _activeUploadedFiles = _activeUploadedFiles;
    });
  }

  List<SingleProfilePictureUploadWidget> getCurrentlyUploadedFilesWidgets() {
    final List<SingleProfilePictureUploadWidget> uploadedImages = [];

    int cnt = 0;

    for (UploadJob uploadJob in _activeUploadedFiles) {
      int displayedImagesCount = _activeUploadedFiles.length;
      if (activeJobsContainUploadWidget())
        displayedImagesCount = displayedImagesCount - 1;

      uploadedImages.add(SingleProfilePictureUploadWidget(
        initialValue: uploadJob,
        onPictureChange: onImageChange,
        position: cnt,
        enableDelete: displayedImagesCount > widget.settings.minImageCount,
        pictureUploadWidget: widget,
        pictureUploadController: _pictureUploadController,
      ));
      cnt++;
    }

    return uploadedImages;
  }

  @override
  Widget build(BuildContext context) {
    if (_activeUploadedFiles.isEmpty) {
      _activeUploadedFiles.add(UploadJob());
    }

    final List<SingleProfilePictureUploadWidget> pictureUploadWidgets =
        getCurrentlyUploadedFilesWidgets();

    return Wrap(
        spacing: 5.0,
        // gap between adjacent chips
        runSpacing: 0.0,
        // gap between lines
        direction: Axis.horizontal,
        // main axis (rows or columns)
        runAlignment: WrapAlignment.start,
        children: pictureUploadWidgets);
  }
}

class SingleProfilePictureUploadWidget extends StatefulWidget {
  SingleProfilePictureUploadWidget({
    required this.initialValue,
    required this.onPictureChange,
    required this.position,
    this.enableDelete = false,
    required this.pictureUploadWidget,
    required this.pictureUploadController,
  }) : super(key: Key(initialValue.id.toString()));

  final Function onPictureChange;
  final UploadJob initialValue;
  final bool enableDelete;
  final int position;
  final PictureUploadWidget pictureUploadWidget;
  final FirebasePictureUploadController pictureUploadController;

  @override
  _SingleProfilePictureUploadWidgetState createState() =>
      _SingleProfilePictureUploadWidgetState();
}

/// State of the widget
class _SingleProfilePictureUploadWidgetState
    extends State<SingleProfilePictureUploadWidget> {
  late UploadJob _uploadJob;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _uploadJob = widget.initialValue;

    if (_uploadJob.image == null && _uploadJob.storageReference != null) {
      _uploadJob.uploadProcessing = true;
      widget.pictureUploadController
          .receiveURL(_uploadJob.storageReference!.fullPath)
          .then(onProfileImageURLReceived);
    }
  }

  void onProfileImageURLReceived(String? downloadURL) {
    if (downloadURL != null) {
      setState(() {
        _uploadJob.imageProvider = CachedNetworkImageProvider(downloadURL);
        _uploadJob.uploadProcessing = false;
      });
    }
  }

  Future<ImageSource?> _askUserForImageSource() async {
    if (Platform.isIOS) {
      return await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text(widget.pictureUploadWidget.localization.abort),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(widget.pictureUploadWidget.localization.camera),
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: Text(widget.pictureUploadWidget.localization.gallery),
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    }

    return await showModalBottomSheet(
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
                    onTap: () => Navigator.of(context).pop(null),
                    child: const Icon(
                      Icons.close,
                      color: Color.fromRGBO(148, 148, 148, 1),
                      size: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.pictureUploadWidget.localization.selectSource,
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
              title: Text(widget.pictureUploadWidget.localization.camera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              horizontalTitleGap: 0,
              leading: const Icon(Icons.photo_library),
              title: Text(widget.pictureUploadWidget.localization.gallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        );
      },
    );
  }

  Future _uploadImage() async {
    _uploadJob.action = UploadAction.actionUpload;

    ImageSource? imageSource;
    switch (widget.pictureUploadWidget.settings.imageSource) {
      case ImageSourceExtended.camera:
        imageSource = ImageSource.camera;
        break;
      case ImageSourceExtended.gallery:
        imageSource = ImageSource.gallery;
        break;
      case ImageSourceExtended.askUser:
        imageSource = await _askUserForImageSource();
        break;
    }

    if (imageSource == null) {
      return;
    }

    // manipulate image as requested
    final image = await _imagePicker.pickImage(
        source: imageSource,
        imageQuality: widget.pictureUploadWidget.settings
            .imageManipulationSettings.compressQuality);
    if (image == null) {
      return;
    }

    // crop image if requested
    File? finalImage = File(image.path);
    if (widget.pictureUploadWidget.settings.imageManipulationSettings
        .enableCropping) {
      finalImage = await widget.pictureUploadController.cropImage(
          File(image.path),
          widget.pictureUploadWidget.settings.imageManipulationSettings);
    }

    // update display state
    setState(() {
      _uploadJob.image = finalImage;
      _uploadJob.uploadProcessing = true;
    });
    widget.onPictureChange(_uploadJob);

    // upload image
    try {
      // in case of custom upload function, use it
      if (widget.pictureUploadWidget.settings.customUploadFunction != null) {
        _uploadJob.storageReference = await widget.pictureUploadWidget.settings
            .customUploadFunction!(finalImage, _uploadJob.id);
      } else {
        // else use default one
        _uploadJob.storageReference = await widget.pictureUploadController
            .uploadProfilePicture(
                finalImage,
                widget.pictureUploadWidget.settings.uploadDirectory,
                _uploadJob.id);
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      _uploadJob.image = null;
      _uploadJob.storageReference = null;

      if (widget.pictureUploadWidget.settings.onErrorFunction != null) {
        widget.pictureUploadWidget.settings.onErrorFunction!(error, stackTrace);
      } else {
        print(error);
        print(stackTrace);
      }
    }

    setState(() {
      _uploadJob.uploadProcessing = false;
    });
    widget.onPictureChange(_uploadJob);
  }

  Future _deleteImage() async {
    _uploadJob.action = UploadAction.actionDelete;

    setState(() {
      _uploadJob.uploadProcessing = true;
    });

    widget.onPictureChange(_uploadJob);

    final imgBackup = _uploadJob.image;
    setState(() {
      _uploadJob.image = null;
    });

    // delete image
    try {
      // in case of custom delete function, use it
      if (widget.pictureUploadWidget.settings.customDeleteFunction != null) {
        await widget.pictureUploadWidget.settings
            .customDeleteFunction!(_uploadJob.storageReference!);
      } else {
        // else use default one
        await widget.pictureUploadController
            .deleteProfilePicture(_uploadJob.storageReference!);
      }
    } on Exception catch (error, stackTrace) {
      setState(() {
        _uploadJob.image = imgBackup;
      });

      if (widget.pictureUploadWidget.settings.onErrorFunction != null) {
        widget.pictureUploadWidget.settings.onErrorFunction!(error, stackTrace);
      } else {
        print(error);
        print(stackTrace);
      }
    }

    setState(() {
      _uploadJob.uploadProcessing = false;
    });
    widget.onPictureChange(_uploadJob);
  }

  Widget getNewImageButton() {
    final Widget buttonContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.pictureUploadWidget.buttonStyle.iconData,
          color: widget.pictureUploadWidget.buttonStyle.fontColor,
          size: widget.pictureUploadWidget.buttonStyle.iconSize,
        ),
        const SizedBox(height: 5.0),
        Text(
          widget.pictureUploadWidget.buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: widget.pictureUploadWidget.buttonStyle.fontColor,
              fontSize: widget.pictureUploadWidget.buttonStyle.fontSize),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: !widget.pictureUploadWidget.enabled ? null : _uploadImage,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(
            widget.pictureUploadWidget.buttonStyle.width,
            widget.pictureUploadWidget.buttonStyle.height,
          ),
          padding: EdgeInsets.zero,
          primary: widget.pictureUploadWidget.buttonStyle.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: buttonContent,
      ),
    );
  }

  Widget getExistingImageWidget() {
    final Container existingImageWidget = Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: _uploadJob.imageProvider != null
            ? Image(
                image: _uploadJob.imageProvider!,
                width: widget.pictureUploadWidget.buttonStyle.width,
                height: widget.pictureUploadWidget.buttonStyle.height,
                fit: BoxFit.fitHeight,
              )
            : _uploadJob.image != null
                ? Image.file(
                    _uploadJob.image!,
                    width: widget.pictureUploadWidget.buttonStyle.width,
                    height: widget.pictureUploadWidget.buttonStyle.height,
                    fit: BoxFit.fitHeight,
                  )
                : const SizedBox(),
      ),
    );

    final Widget processingIndicator = Container(
      width: widget.pictureUploadWidget.buttonStyle.width,
      height: widget.pictureUploadWidget.buttonStyle.height + 10,
      child: const Center(child: const CircularProgressIndicator()),
    );

    final Widget deleteButton = SizedBox(
      height: widget.pictureUploadWidget.buttonStyle.height,
      width: widget.pictureUploadWidget.buttonStyle.width + 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: !widget.pictureUploadWidget.enabled ? null : _deleteImage,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget
                    .pictureUploadWidget.buttonStyle.closeIconBackgroundColor,
                border: Border.all(
                    color:
                        widget.pictureUploadWidget.buttonStyle.closeIconColor,
                    width: 1.0),
              ),
              height: 28.0, // height of the button
              width: 28.0, // width of the button
              child: Icon(
                Icons.close,
                color: widget.pictureUploadWidget.buttonStyle.closeIconColor,
                size: 17.0,
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        existingImageWidget,
        _uploadJob.uploadProcessing
            ? processingIndicator
            : widget.enableDelete
                ? deleteButton
                : const SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadJob.image == null &&
        _uploadJob.imageProvider == null &&
        _uploadJob.storageReference == null) {
      return getNewImageButton();
    } else {
      return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        getExistingImageWidget(),
      ]);
    }
  }
}

enum UploadAction { actionDelete, actionUpload, actionChange }

class UploadJob {
  UploadJob({this.action});

  UploadAction? action;
  int id = DateTime.now().millisecondsSinceEpoch;
  bool uploadProcessing = false;
  File? image;
  File? oldImage;
  Reference? oldStorageReference;
  ImageProvider? imageProvider; // for existing images

  Reference? _storageReference;

  Reference? get storageReference => _storageReference;

  set storageReference(Reference? storageReference) {
    _storageReference = storageReference;
    if (_storageReference != null && _storageReference!.fullPath != '') {
      final String fileName = _storageReference!.fullPath.split('/').last;

      // The filename mist be like custom1_..._custom_x_id_customy.(jpg|png|...)
      final List<String> fileParts = fileName.split('_');
      final String id = fileParts[fileParts.length - 2];
      this.id = int.parse(id);
    }
  }

  bool compareTo(UploadJob other) {
    if (storageReference != null && other.storageReference != null)
      return storageReference!.fullPath == other.storageReference!.fullPath;
    else if (image != null && other.image != null)
      return image!.path == other.image!.path;
    else
      return false;
  }

  @override
  bool operator ==(Object other) {
    if (other is! UploadJob) {
      return false;
    }

    final UploadJob otherUploadJob = other;

    return id == otherUploadJob.id;
  }

  late int? _hashCode;

  @override
  int get hashCode {
    return _hashCode ??= id.hashCode;
  }

  @override
  String toString() {
    return 'UploadJob{action: $action, id: $id, uploadProcessing: $uploadProcessing, image: $image, oldImage: $oldImage, oldStorageReference: $oldStorageReference, imageProvider: $imageProvider, _storageReference: $_storageReference}';
  }
}

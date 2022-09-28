import 'package:firebase_picture_uploader/firebase_picture_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validators/validators.dart';

import '../../../../common_widgets/custom_snack_bar.dart';
import '../../../../helpers/context_extensions.dart';
import '../../domain/deal.dart';
import '../../domain/deal_form_data.dart';
import '../deal_form_controller.dart';
import '../deal_util.dart';
import 'category_dropdown.dart';
import 'store_dropdown.dart';

class DealForm extends ConsumerStatefulWidget {
  const DealForm({
    required this.buttonTitle,
    this.deal,
    required this.onPressed,
    super.key,
  });

  final String buttonTitle;

  final Deal? deal;

  final void Function(Deal) onPressed;

  @override
  ConsumerState<DealForm> createState() => _DealFormState();
}

class _DealFormState extends ConsumerState<DealForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController dealUrlController;
  late TextEditingController titleController;
  late TextEditingController originalPriceController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late List<UploadJob> _dealImages;

  @override
  void initState() {
    _dealImages = widget.deal != null
        ? DealUtil.loadInitialImages(ref,
            photoUrls: [widget.deal!.coverPhoto, ...widget.deal!.photos!])
        : [];
    dealUrlController = TextEditingController(text: widget.deal?.dealUrl);
    titleController = TextEditingController(text: widget.deal?.title);
    originalPriceController =
        TextEditingController(text: widget.deal?.originalPrice.toString());
    priceController =
        TextEditingController(text: widget.deal?.price.toString());
    descriptionController =
        TextEditingController(text: widget.deal?.description);
    super.initState();
  }

  @override
  void dispose() {
    dealUrlController.dispose();
    titleController.dispose();
    originalPriceController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _onPressed(DealFormData controller) async {
    if (_formKey.currentState?.validate() == false) return;

    if (_dealImages.length == 1) {
      CustomSnackBar.error(text: context.l.pleaseUploadAtLeastOneImage)
          .showSnackBar(context);
      return;
    }

    if (DealUtil.isUploadInProgress(_dealImages)) {
      CustomSnackBar.error(text: context.l.pleaseWaitForImageUploads)
          .showSnackBar(context);
      return;
    }

    context.showLoadingDialog();
    final photos = await DealUtil.getDownloadUrls(_dealImages);
    final deal = Deal(
      id: widget.deal?.id,
      category: controller.selectedCategory.category,
      coverPhoto: photos.first,
      dealUrl: dealUrlController.text,
      description: descriptionController.text,
      originalPrice: double.parse(originalPriceController.text),
      photos: photos.skip(1).toList(),
      price: double.parse(priceController.text),
      store: controller.selectedStore.id!,
      title: titleController.text,
    );

    widget.onPressed(deal);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(dealFormControllerProvider);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Wrap(
        runSpacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PictureUploadWidget(
              buttonText: context.l.uploadImage,
              buttonStyle: PictureUploadButtonStyle(
                backgroundColor: context.t.primaryColor,
                closeIconBackgroundColor: context.isDarkMode
                    ? context.t.primaryColorLight
                    : Colors.white,
                closeIconColor: context.isDarkMode
                    ? context.t.primaryColorDark
                    : context.t.primaryColorLight,
              ),
              initialImages: _dealImages,
              localization: PictureUploadLocalization(
                abort: context.l.cancel,
                camera: context.l.camera,
                gallery: context.l.gallery,
                selectSource: context.l.selectSource,
              ),
              onPicturesChange: ({
                required List<UploadJob> uploadJobs,
                required bool pictureUploadProcessing,
              }) {
                _dealImages = uploadJobs;
              },
              settings: PictureUploadSettings(uploadDirectory: '/deal_images/'),
            ),
          ),
          TextFormField(
            controller: dealUrlController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: context.l.enterDealUrl,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l.pleaseEnterTheDealUrl;
              } else if (!isURL(value)) {
                return context.l.pleaseEnterValidUrl;
              }

              return null;
            },
          ),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorMaxLines: 2,
              labelText: context.l.title,
            ),
            textInputAction: TextInputAction.next,
            maxLength: 100,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l.pleaseEnterTheDealTitle;
              } else if (value.length < 10) {
                return context.l.titleMustBe;
              }

              return null;
            },
          ),
          TextFormField(
            controller: originalPriceController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: context.l.originalPrice,
              prefixIcon: const Icon(Icons.attach_money, size: 20),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l.pleaseEnterTheOriginalPrice;
              } else if (priceController.text.isNotEmpty &&
                  (double.parse(value) < double.parse(priceController.text))) {
                return context.l.originalPriceCannotBeLower;
              }

              return null;
            },
          ),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: context.l.price,
              prefixIcon: const Icon(Icons.attach_money, size: 20),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l.pleaseEnterThePrice;
              } else if (originalPriceController.text.isNotEmpty &&
                  (double.parse(value) >
                      double.parse(originalPriceController.text))) {
                return context.l.priceCannotBeGreater;
              }

              return null;
            },
          ),
          CategoryDropdown(selectedCategoryPath: widget.deal?.category),
          StoreDropdown(selectedStoreId: widget.deal?.store),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorMaxLines: 2,
              hintStyle: context.textTheme.bodyText2!.copyWith(
                  color: context.isLightMode ? Colors.black54 : Colors.grey),
              hintText: context.l.enterSomeDetailsAboutDeal,
            ),
            minLines: 4,
            maxLines: 30,
            maxLength: 3000,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l.pleaseEnterTheDealDescription;
              } else if (value.length < 10) {
                return context.l.descriptionMustBe;
              }

              return null;
            },
          ),
          ElevatedButton(
            onPressed: () => _onPressed(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              fixedSize: Size(context.mq.size.width, 50),
            ),
            child: Text(widget.buttonTitle),
          ),
        ],
      ),
    );
  }
}

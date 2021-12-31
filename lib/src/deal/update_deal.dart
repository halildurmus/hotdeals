import 'package:firebase_picture_uploader/firebase_picture_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:validators/validators.dart';

import '../models/categories.dart';
import '../models/category.dart';
import '../models/deal.dart';
import '../models/store.dart';
import '../models/stores.dart';
import '../services/spring_service.dart';
import '../utils/localization_util.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/loading_dialog.dart';
import 'deal_details.dart';
import 'deal_util.dart';

class UpdateDeal extends StatefulWidget {
  const UpdateDeal({Key? key, required this.deal}) : super(key: key);

  final Deal deal;

  @override
  _UpdateDealState createState() => _UpdateDealState();
}

class _UpdateDealState extends State<UpdateDeal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final List<Category> categories;
  late final List<Store> stores;
  late Category selectedCategory;
  late Store selectedStore;
  late TextEditingController dealUrlController;
  late TextEditingController titleController;
  late TextEditingController originalPriceController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  List<UploadJob> dealImages = [];

  void dealImageCallback({
    required List<UploadJob> uploadJobs,
    required bool pictureUploadProcessing,
  }) {
    dealImages = uploadJobs;
  }

  @override
  void initState() {
    final deal = widget.deal;
    dealImages =
        DealUtil.loadInitialImages(photos: [deal.coverPhoto, ...deal.photos!]);
    categories = GetIt.I.get<Categories>().mainCategories;
    selectedCategory =
        categories.singleWhere((e) => e.category == deal.category);
    stores = GetIt.I.get<Stores>().stores!;
    selectedStore = stores.singleWhere((e) => e.id == deal.store);
    dealUrlController = TextEditingController(text: deal.dealUrl);
    titleController = TextEditingController(text: deal.title);
    originalPriceController =
        TextEditingController(text: deal.originalPrice.toString());
    priceController = TextEditingController(text: deal.price.toString());
    descriptionController = TextEditingController(text: deal.description);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;

    Future<void> onPressed() async {
      if (dealImages.first.storageReference == null) {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).pleaseUploadAtLeastOneImage,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else if (DealUtil.isUploadInProgress(dealImages)) {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).pleaseWaitForImageUploads,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);
      final photos = await DealUtil.getDownloadUrls(dealImages);
      final deal = Deal(
        id: widget.deal.id!,
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory.category,
        store: selectedStore.id!,
        coverPhoto: photos.first,
        photos: photos.skip(1).toList(),
        dealUrl: dealUrlController.text,
        originalPrice: double.parse(originalPriceController.text),
        price: double.parse(priceController.text),
      );
      final updatedDeal =
          await GetIt.I.get<SpringService>().updateDeal(deal: deal);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (updatedDeal != null) {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.checkCircle, size: 20),
          text: l(context).successfullyUpdatedYourDeal,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DealDetails(dealId: updatedDeal.id!),
          ),
        );
      } else {
        final snackBar = CustomSnackBar(
          icon: const Icon(FontAwesomeIcons.exclamationCircle, size: 20),
          text: l(context).anErrorOccurred,
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    Widget buildPictureUploadWidget() => PictureUploadWidget(
          buttonText: l(context).uploadImage,
          buttonStyle: PictureUploadButtonStyle(
            backgroundColor: theme.primaryColor,
            closeIconBackgroundColor: theme.brightness == Brightness.dark
                ? theme.primaryColorLight
                : Colors.white,
            closeIconColor: theme.brightness == Brightness.dark
                ? theme.primaryColorDark
                : theme.primaryColorLight,
          ),
          initialImages: dealImages,
          localization: PictureUploadLocalization(
            abort: l(context).cancel,
            camera: l(context).camera,
            gallery: l(context).gallery,
            selectSource: l(context).selectSource,
          ),
          onPicturesChange: dealImageCallback,
          settings: PictureUploadSettings(
            customDeleteFunction: (_) {},
            uploadDirectory: '/deal_images/',
          ),
        );

    Widget buildUrlFormField() => TextFormField(
          controller: dealUrlController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l(context).enterDealUrl,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l(context).pleaseEnterTheDealUrl;
            } else if (!isURL(value)) {
              return l(context).pleaseEnterValidUrl;
            }

            return null;
          },
        );

    Widget buildTitleFormField() => TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorMaxLines: 2,
            labelText: l(context).title,
          ),
          textInputAction: TextInputAction.next,
          maxLength: 100,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l(context).pleaseEnterTheDealTitle;
            } else if (value.length < 10) {
              return l(context).titleMustBe;
            }

            return null;
          },
        );

    Widget buildOriginalPriceFormField() => TextFormField(
          controller: originalPriceController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l(context).originalPrice,
            prefixIcon: const Icon(Icons.attach_money, size: 20),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l(context).pleaseEnterTheOriginalPrice;
            } else if (priceController.text.isNotEmpty &&
                (double.parse(value) < double.parse(priceController.text))) {
              return l(context).originalPriceCannotBeLower;
            }

            return null;
          },
        );

    Widget buildPriceFormField() => TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l(context).price,
            prefixIcon: const Icon(Icons.attach_money, size: 20),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l(context).pleaseEnterThePrice;
            } else if (originalPriceController.text.isNotEmpty &&
                (double.parse(value) >
                    double.parse(originalPriceController.text))) {
              return l(context).priceCannotBeGreater;
            }

            return null;
          },
        );

    Widget buildCategoryDropdown() => DropdownButtonFormField<Category>(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l(context).category,
          ),
          value: selectedCategory,
          onChanged: (newValue) => setState(() => selectedCategory = newValue!),
          selectedItemBuilder: (context) => categories
              .map<Widget>((item) =>
                  Text(item.localizedName(Localizations.localeOf(context))))
              .toList(),
          items: categories
              .map((value) => DropdownMenuItem<Category>(
                    value: value,
                    child: Row(
                      children: [
                        if (selectedCategory == value)
                          Icon(Icons.check, color: theme.primaryColor)
                        else
                          const SizedBox(width: 24),
                        const SizedBox(width: 10),
                        Text(value
                            .localizedName(Localizations.localeOf(context))),
                      ],
                    ),
                  ))
              .toList(),
        );

    Widget buildStoreDropdown() => DropdownButtonFormField<Store>(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: l(context).store,
          ),
          value: selectedStore,
          onChanged: (newValue) => setState(() => selectedStore = newValue!),
          selectedItemBuilder: (context) =>
              stores.map<Widget>((store) => Text(store.name)).toList(),
          items: stores
              .map((value) => DropdownMenuItem<Store>(
                    value: value,
                    child: Row(
                      children: [
                        if (selectedStore == value)
                          Icon(Icons.check, color: theme.primaryColor)
                        else
                          const SizedBox(width: 24),
                        const SizedBox(width: 10),
                        Text(value.name),
                      ],
                    ),
                  ))
              .toList(),
        );

    Widget buildDescriptionFormField() => TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorMaxLines: 2,
            hintStyle: textTheme.bodyText2!.copyWith(
                color: theme.brightness == Brightness.light
                    ? Colors.black54
                    : Colors.grey),
            hintText: l(context).enterSomeDetailsAboutDeal,
          ),
          minLines: 4,
          maxLines: 30,
          maxLength: 3000,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l(context).pleaseEnterTheDealDescription;
            } else if (value.length < 10) {
              return l(context).descriptionMustBe;
            }

            return null;
          },
        );

    Widget buildUpdateDealButton() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ElevatedButton(
            // TODO(halildurmus): Make sure at least one of the fields is
            // changed before enabling the button.
            onPressed:
                (_formKey.currentState?.validate() ?? false) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              fixedSize: Size(deviceWidth, 50),
              primary: theme.colorScheme.secondary,
            ),
            child: Text(l(context).updateDeal),
          ),
        );

    Widget buildForm() => Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              buildPictureUploadWidget(),
              const SizedBox(height: 20),
              buildUrlFormField(),
              const SizedBox(height: 10),
              buildTitleFormField(),
              const SizedBox(height: 10),
              buildOriginalPriceFormField(),
              const SizedBox(height: 10),
              buildPriceFormField(),
              const SizedBox(height: 10),
              buildCategoryDropdown(),
              const SizedBox(height: 10),
              buildStoreDropdown(),
              const SizedBox(height: 10),
              buildDescriptionFormField(),
              const SizedBox(height: 10),
            ],
          ),
        );

    Widget buildBody() => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buildForm(),
                ),
              ),
            ),
            buildUpdateDealButton(),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).updateDeal),
      ),
      body: buildBody(),
    );
  }
}

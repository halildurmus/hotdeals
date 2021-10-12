import 'package:firebase_picture_uploader/firebase_picture_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:validators/validators.dart';

import '../models/categories.dart';
import '../models/category.dart';
import '../models/deal.dart';
import '../models/store.dart';
import '../models/stores.dart';
import '../services/spring_service.dart';
import '../widgets/loading_dialog.dart';

class PostDeal extends StatefulWidget {
  const PostDeal({Key? key}) : super(key: key);

  @override
  _PostDealState createState() => _PostDealState();
}

class _PostDealState extends State<PostDeal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Category> categories;
  late List<Store> stores;
  late Category selectedCategory;
  late Store selectedStore;
  late TextEditingController dealUrlController;
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController discountPriceController;
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
    categories = GetIt.I.get<Categories>().mainCategories!;
    selectedCategory = categories.first;
    stores = GetIt.I.get<Stores>().stores!;
    selectedStore = stores.first;
    dealUrlController = TextEditingController();
    titleController = TextEditingController();
    priceController = TextEditingController();
    discountPriceController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    dealUrlController.dispose();
    titleController.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceWidth = MediaQuery.of(context).size.width;

    Widget buildPictureUpload() {
      return PictureUploadWidget(
        buttonText: AppLocalizations.of(context)!.uploadImage,
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
          abort: AppLocalizations.of(context)!.cancel,
          camera: AppLocalizations.of(context)!.camera,
          gallery: AppLocalizations.of(context)!.gallery,
          selectSource: AppLocalizations.of(context)!.selectSource,
        ),
        onPicturesChange: dealImageCallback,
        settings: PictureUploadSettings(
          uploadDirectory: '/deal_images/',
          minImageCount: 0,
          maxImageCount: 5,
        ),
      );
    }

    Widget buildCategoriesDropdown() {
      return DropdownButtonFormField<Category>(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.category,
        ),
        value: selectedCategory,
        onChanged: (Category? newValue) {
          setState(() {
            selectedCategory = newValue!;
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return categories.map<Widget>((Category item) {
            return Text(item.localizedName(Localizations.localeOf(context)));
          }).toList();
        },
        items: categories.map((Category value) {
          return DropdownMenuItem<Category>(
            value: value,
            child: Row(
              children: [
                if (selectedCategory == value)
                  Icon(Icons.check, color: theme.primaryColor)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 10),
                Text(value.localizedName(Localizations.localeOf(context))),
              ],
            ),
          );
        }).toList(),
      );
    }

    Widget buildStoresDropdown() {
      return DropdownButtonFormField<Store>(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.store,
        ),
        value: selectedStore,
        onChanged: (Store? newValue) {
          setState(() {
            selectedStore = newValue!;
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return stores.map<Widget>((Store item) {
            return Text(item.name);
          }).toList();
        },
        items: stores.map((Store value) {
          return DropdownMenuItem<Store>(
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
          );
        }).toList(),
      );
    }

    bool areImagesReady() {
      bool value = false;

      if (dealImages.first.storageReference == null) {
        return value;
      }

      for (int i = 0; i < dealImages.length; i++) {
        if (dealImages[i].uploadProcessing) {
          value = false;
          break;
        } else {
          value = true;
        }
      }

      return value;
    }

    Future<void> onPressed() async {
      if (!areImagesReady()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseUploadAtLeastOneImage),
          ),
        );
        return;
      }
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final String coverPhoto =
          await dealImages.first.storageReference!.getDownloadURL();
      final List<String> photos = [];
      for (int i = 1; i < dealImages.length - 1; i++) {
        photos.add(await dealImages[i].storageReference!.getDownloadURL());
      }

      final Deal deal = Deal(
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory.category,
        store: selectedStore.id!,
        coverPhoto: coverPhoto,
        photos: photos,
        dealUrl: dealUrlController.text,
        price: double.parse(priceController.text),
        discountPrice: double.parse(discountPriceController.text),
      );

      final Deal? postedDeal =
          await GetIt.I.get<SpringService>().postDeal(deal: deal);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (postedDeal != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.successfullyPostedYourDeal),
          ),
        );
        Navigator.of(context).popUntil((Route<void> route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.anErrorOccurred),
          ),
        );
      }
    }

    Widget buildPostButton() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ElevatedButton(
          onPressed: _formKey.currentState == null
              ? null
              : _formKey.currentState!.validate()
                  ? onPressed
                  : null,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(deviceWidth, 50),
            primary: theme.colorScheme.secondary,
          ),
          child: Text(AppLocalizations.of(context)!.postDeal),
        ),
      );
    }

    Widget buildForm() {
      return Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            buildPictureUpload(),
            const SizedBox(height: 20),
            TextFormField(
              controller: dealUrlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.enterDealUrl,
              ),
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterTheDealUrl;
                } else if (!isURL(value)) {
                  return AppLocalizations.of(context)!.pleaseEnterValidUrl;
                }

                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.title,
              ),
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterTheDealTitle;
                }

                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.originalPrice,
                prefixIcon: const Icon(Icons.attach_money, size: 20),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .pleaseEnterTheOriginalPrice;
                } else if (discountPriceController.text.isNotEmpty &&
                    (int.parse(value) <
                        int.parse(discountPriceController.text))) {
                  return AppLocalizations.of(context)!
                      .originalPriceCannotBeLower;
                }

                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: discountPriceController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.discountPrice,
                prefixIcon: const Icon(Icons.attach_money, size: 20),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!
                      .pleaseEnterTheDiscountPrice;
                } else if (priceController.text.isNotEmpty &&
                    (int.parse(value) > int.parse(priceController.text))) {
                  return AppLocalizations.of(context)!
                      .discountPriceCannotBeGreater;
                }

                return null;
              },
            ),
            const SizedBox(height: 10),
            buildCategoriesDropdown(),
            const SizedBox(height: 10),
            buildStoresDropdown(),
            const SizedBox(height: 10),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintStyle: textTheme.bodyText2!.copyWith(
                    color: theme.brightness == Brightness.light
                        ? Colors.black54
                        : Colors.grey),
                hintText:
                    AppLocalizations.of(context)!.enterSomeDetailsAboutDeal,
              ),
              minLines: 4,
              maxLines: 30,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the deal description.';
                }

                return null;
              },
            ),
            const SizedBox(height: 10),
            buildPostButton(),
          ],
        ),
      );
    }

    Widget buildBody() {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: buildForm(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.postADeal),
      ),
      body: buildBody(),
    );
  }
}

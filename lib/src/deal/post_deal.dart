import 'package:firebase_picture_uploader/firebase_picture_uploader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:line_icons/line_icons.dart';
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
  List<UploadJob> dealImages = <UploadJob>[];

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
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final double deviceWidth = MediaQuery.of(context).size.width;

    Widget buildPictureUpload() {
      return PictureUploadWidget(
        initialImages: dealImages,
        onPicturesChange: dealImageCallback,
        buttonStyle: PictureUploadButtonStyle(),
        buttonText: 'Upload Picture',
        localization: PictureUploadLocalization(),
        settings: PictureUploadSettings(
          uploadDirectory: '/deal_images/',
          imageSource: ImageSourceExtended.askUser,
          minImageCount: 1,
          maxImageCount: 5,
          imageManipulationSettings: const ImageManipulationSettings(
            enableCropping: false,
            compressQuality: 75,
          ),
        ),
      );
    }

    Widget buildCategoriesDropdown() {
      return DropdownButtonFormField<Category>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Kategori',
        ),
        value: selectedCategory,
        onChanged: (Category? newValue) {
          setState(() {
            selectedCategory = newValue!;
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return categories.map<Widget>((Category item) {
            return Text(item.name);
          }).toList();
        },
        items: categories.map((Category value) {
          return DropdownMenuItem<Category>(
            value: value,
            child: Row(
              children: <Widget>[
                if (selectedCategory == value)
                  Icon(LineIcons.check, color: theme.primaryColor)
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

    Widget buildStoresDropdown() {
      return DropdownButtonFormField<Store>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Store',
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
              children: <Widget>[
                if (selectedStore == value)
                  Icon(LineIcons.check, color: theme.primaryColor)
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
          const SnackBar(
            content: Text('Please upload at least one picture!'),
          ),
        );
        return;
      }
      GetIt.I.get<LoadingDialog>().showLoadingDialog(context);

      final String coverPhoto =
          await dealImages.first.storageReference!.getDownloadURL();
      final List<String> photos = <String>[];
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
      print(postedDeal);

      // Pops the loading dialog.
      Navigator.of(context).pop();
      if (postedDeal != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your deal posted'),
          ),
        );
        Navigator.of(context).popUntil((Route<void> route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred!'),
          ),
        );
      }
    }

    Widget buildPostButton() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: deviceWidth,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _formKey.currentState == null
                ? null
                : _formKey.currentState!.validate()
                    ? onPressed
                    : null,
            style: ElevatedButton.styleFrom(
              primary: theme.colorScheme.secondary,
            ),
            child: const Text('Fırsatı Paylaş'),
          ),
        ),
      );
    }

    Widget buildForm() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildPictureUpload(),
              const SizedBox(height: 20),
              TextFormField(
                controller: dealUrlController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Fırsat linkini girin',
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the deal URL.';
                  } else if (!isURL(value)) {
                    return 'Please enter a valid URL.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Başlık',
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the deal title.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'İndirimsiz Fiyat',
                  prefixIcon: Icon(LineIcons.dollarSign, size: 20),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the deal price.';
                  } else if (discountPriceController.text.isNotEmpty &&
                      (int.parse(value) <
                          int.parse(discountPriceController.text))) {
                    return 'The price cannot be lower than the discount price.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: discountPriceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'İndirimli Fiyat',
                  prefixIcon: Icon(LineIcons.dollarSign, size: 20),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the deal discount price.';
                  } else if (priceController.text.isNotEmpty &&
                      (int.parse(value) > int.parse(priceController.text))) {
                    return 'The discount price cannot be greater than the price.';
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
                    hintText: 'Fırsatla alakalı detaylı bilgileri buraya girin'
                    //hintText: 'Type at least 5 words of additional information here! What else should the community know? (Include the important stuff: product details, coupon code, expiration date, etc.)',
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
        ),
      );
    }

    Widget buildBody() {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildForm(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Bir Fırsat Paylaş')),
      body: buildBody(),
    );
  }
}

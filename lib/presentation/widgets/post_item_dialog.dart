// ignore_for_file: use_build_context_synchronously

import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/data/gemini_repository.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class PostItemDialog extends ConsumerStatefulWidget {
  const PostItemDialog({super.key});

  @override
  ConsumerState<PostItemDialog> createState() => _PostItemDialogState();
}

class _PostItemDialogState extends ConsumerState<PostItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _usedForMonthsController;
  late TextEditingController _contactInformationController;
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _isLoadingImage = false;
  UploadTask? uploadTask;
  String? downloadURL;
  bool _isLoadingPrice = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _usedForMonthsController = TextEditingController();
    _contactInformationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _usedForMonthsController.dispose();
    _contactInformationController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadImage() async {
    // Pick an image file
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _isLoadingImage = true;
      });

      try {
        UploadTask uploadTask;

        final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path},
        );

        final ref =
            FirebaseStorage.instance.ref().child('uploads/$uniqueFileName');

        debugPrint('starting upload');
        if (kIsWeb) {
          uploadTask = ref.putData(await file.readAsBytes(), metadata);
        } else {
          uploadTask = ref.putFile(io.File(file.path), metadata);
        }

        final snapshot = await uploadTask;
        final downloadURL = await snapshot.ref.getDownloadURL();
        debugPrint('uploaded successfully');

        _imageBytes = await file.readAsBytes();
        setState(() {
          _isLoadingImage = false;
          _imageUrl = downloadURL;
        });
      } catch (e) {
        setState(() {
          _isLoadingImage = false;
        });
        showToast(
          ref,
          'Failed to upload image: $e',
          type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> generatePrice() async {
    setState(() {
      _isLoadingPrice = true;
    });

    final itemTitle = _nameController.text;
    final itemDescription = _descriptionController.text;
    final usedForMonths = _usedForMonthsController.text;

    if (_imageBytes == null) {
      setState(() {
        _isLoadingPrice = false;
      });
      showToast(ref, 'No image selected for price estimation.');
      return;
    }

    try {
      final itemPrice = await ref.read(geminiRepositoryProvider).generatePrice(
            itemTitle,
            itemDescription,
            usedForMonths,
            _imageBytes!,
          );

      setState(() {
        _priceController.text = itemPrice;
        _isLoadingPrice = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrice = false;
      });
      showToast(
        ref,
        'Failed to generate price: $e',
        type: ToastificationType.error,
      );
    }
  }

  Future<void> _postItem() async {
    if (_formKey.currentState!.validate() && _imageUrl != null) {
      final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final DocumentReference sellingUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserUid);
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection('marketplaceItems').doc();

      await docRef.set({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': _priceController.text.replaceAll(',', ''),
        'location': _locationController.text,
        'usedForMonths': int.parse(_usedForMonthsController.text),
        'imageUrl': _imageUrl,
        'hasSold': false,
        'docid': docRef.id,
        'sellingUser': sellingUserRef,
        'uploadedAt': FieldValue.serverTimestamp(),
        'contactInfo': _contactInformationController.text,
      });

      Navigator.of(context).pop();

      showToast(
        ref,
        'Item added to the Marketplace Sucessfully!',
        type: ToastificationType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
      ),
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // border: Border.all(
            //   color: AppColors.primaryColor,
            //   width: 2,
            // ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _isLoadingImage
                          ? const CircularProgressIndicator()
                          : _imageBytes != null
                              ? Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        _imageBytes!,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // const SizedBox(height: 10),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: pickAndUploadImage,
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Upload Image',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Post an Item',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: generatePrice,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: _isLoadingPrice
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Gemini AI Price',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            enabled: false,
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.blueGrey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please generate the price';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usedForMonthsController,
                      decoration: const InputDecoration(
                        labelText: 'Used for months',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the used months';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactInformationController,
                      decoration: const InputDecoration(
                        labelText: 'Contact information',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact information!';
                        }
                        final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');

                        if (!emailRegExp.hasMatch(value) &&
                            !phoneRegExp.hasMatch(value)) {
                          return '''Please enter a valid email address or phone number!''';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _postItem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Post Item',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

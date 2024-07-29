import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:html' as html;

import 'package:google_generative_ai/google_generative_ai.dart';

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
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _isLoadingImage = false;
  UploadTask? uploadTask;
  String? downloadURL;
  bool _isLoadingPrice = false;

  late final GenerativeModel model;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _usedForMonthsController = TextEditingController();

    final apiKey = dotenv.env['gemini_api_key']!;
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _usedForMonthsController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _isLoadingImage = true;
      });

      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;

      if (fileBytes != null) {
        final uniqueFileName =
            DateTime.now().millisecondsSinceEpoch.toString() + fileName;
        final metadata =
            SettableMetadata(contentType: 'image/${fileName.split('.').last}');

        try {
          final ref =
              FirebaseStorage.instance.ref().child('uploads/$uniqueFileName');
          uploadTask = ref.putData(fileBytes, metadata);

          uploadTask?.snapshotEvents.listen((event) {
            setState(() {});
          });

          final snapshot = await uploadTask?.whenComplete(() {});
          downloadURL = await snapshot?.ref.getDownloadURL();

          setState(() {
            _isLoadingImage = false;
            _imageBytes = fileBytes;
            _imageUrl = downloadURL;
          });
        } catch (e) {
          setState(() {
            _isLoadingImage = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
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

    const promptTemplate =
        r'Give a price estimation in rupees for a used item, whose description is as follows: $itemTitle, $itemDescription, which has been used for $usedForMonths. Return the output in json using the following structure: { "itemPrice" : "$itemPrice"}';

    final prompt = promptTemplate
        .replaceAll(r'$itemTitle', itemTitle)
        .replaceAll(r'$itemDescription', itemDescription)
        .replaceAll(r'$usedForMonths', usedForMonths);

    print(prompt);

    try {
      final output = await model.generateContent([Content.text(prompt)]);
      final jsonResponse = jsonDecode(output.text!) as Map<String, dynamic>;
      final itemPrice = jsonResponse['itemPrice'];

      setState(() {
        _priceController.text = itemPrice as String;
        _isLoadingPrice = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrice = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate price: $e')),
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
        'price': _priceController.text,
        'location': _locationController.text,
        'usedForMonths': int.parse(_usedForMonthsController.text),
        'imageUrl': _imageUrl,
        'hasSold': false,
        'docid': docRef.id,
        'sellingUser': sellingUserRef,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                                    color: AppColors.primaryColor,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Upload Image',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    // : ElevatedButton(
                    //     onPressed: pickAndUploadImage,
                    //     style: ElevatedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 40,
                    //         vertical: 15,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //       backgroundColor: AppColors.primaryColor,
                    //     ),
                    //     child: const Text(
                    //       'Upload Image',
                    //       style: TextStyle(
                    //         fontSize: 18,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
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
                                'Generate Price',
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
    );
  }
}

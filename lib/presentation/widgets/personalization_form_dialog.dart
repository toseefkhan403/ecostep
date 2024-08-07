import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class PersonalizationFormDialog extends ConsumerStatefulWidget {
  const PersonalizationFormDialog({super.key});

  @override
  ConsumerState<PersonalizationFormDialog> createState() =>
      _PersonalizationFormDialogState();
}

class _PersonalizationFormDialogState
    extends ConsumerState<PersonalizationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;
  late TextEditingController _occupationController;
  late TextEditingController _sustainabilityController;
  late TextEditingController _cityController;
  late TextEditingController _environmentActionController;
  late TextEditingController _transportController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _occupationController = TextEditingController();
    _sustainabilityController = TextEditingController();
    _cityController = TextEditingController();
    _environmentActionController = TextEditingController();
    _transportController = TextEditingController();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _occupationController.dispose();
    _sustainabilityController.dispose();
    _cityController.dispose();
    _environmentActionController.dispose();
    _transportController.dispose();
    super.dispose();
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
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Personalization Form',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Where do you live?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: 'What do you do for a living?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your occupation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sustainabilityController,
                      decoration: const InputDecoration(
                        labelText:
                            '''What would you rate yourself on sustainability? (on a scale of 5)''',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please rate your sustainability';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Do you live in a city?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please specify if you live in a city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _environmentActionController,
                      decoration: const InputDecoration(
                        labelText:
                            '''Have you taken any action to save the environment recently?''',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '''Please specify your recent environmental actions''';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _transportController,
                      decoration: const InputDecoration(
                        labelText: 'Do you use public transport or a car?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please specify your mode of transport';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
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
                          'Submit',
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Handle form submission
      final personalizationString =
          '''The user lives in ${_locationController.text}, works as a ${_occupationController.text}, considers himself ${_sustainabilityController.text} sustainable out of 5, lives in a city: ${_cityController.text}, his recent environmental actions include ${_environmentActionController.text}, uses public transport or a car: ${_transportController.text}''';
      ref
          .read(userRepositoryProvider)
          .updatePersonalization(personalizationString);
      Navigator.pop(context);
      showToast(
        ref,
        '''Personalization info added successfully! You will get personalized actions from now on!''',
        type: ToastificationType.success,
      );
    }
  }
}

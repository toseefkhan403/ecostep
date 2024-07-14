import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/domain/action.dart' as ac;
import 'package:ecostep/presentation/controllers/selected_date_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/date_utils.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/week_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart';
import 'package:neopop/neopop.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final GenerativeModel model;
  List<ac.Action> actions = [];
  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    setupmodel();
  }

  Future<void> setupmodel() async {
    final apiKey = 'AIzaSyBFkQgBWLAAh2X_zmhDFgwnwkRSBwX04D0';

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    await checkandfetchactions();
  }

  Future<void> checkandfetchactions() async {
    final collectionRef = FirebaseFirestore.instance.collection('actions');
    final querySnapshot = await collectionRef.get();

    if (querySnapshot.docs.isEmpty) {
      await generateactions();
    } else {
      await fetchactions();
    }
  }

  Future<void> generateactions() async {
    const prompt = '''
    Give one actionable task per day for a person for 7 days which is good for the environment, wildlife, nature, humanity, etc. Some examples include: feeding a stray animal, keeping a water bowl for birds, recycling a plastic bottle, etc. Give the difficulty as well based on the effort required to complete that task as easy, moderate, hard. Progressively increase the difficulty of the tasks. These actions should be verifiable by analyzing an image provided by the user. Return the output in json using the following structure: {[ "action" : "\$action", "description" : "\$description", "difficulty" : "\$difficulty", "impact" : "\$impact", "impactIfNotDone" : "\$impactIfNotDone", "verifiable_image" : "\$verifiable_image",]}
    ''';

    final output = await model.generateContent([Content.text(prompt)]);

    final List<dynamic> jsonResponse =
        jsonDecode(output.text!) as List<dynamic>;
    List<ac.Action> generatedActions = jsonResponse
        .map((e) => ac.Action.fromJson(e as Map<String, dynamic>))
        .toList();

    await storeactions(generatedActions);

    await fetchactions();
  }

  Future<void> storeactions(List<ac.Action> actions) async {
    final collectionRef = FirebaseFirestore.instance.collection('actions');
    final batch = FirebaseFirestore.instance.batch();

    for (var action in actions) {
      final docRef = collectionRef.doc();
      batch.set(docRef, action.toJson());
    }

    await batch.commit();
  }

  Future<void> fetchactions() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('actions').get();
    final List<ac.Action> fetchedActions = querySnapshot.docs
        .map((doc) => ac.Action.fromJson(doc.data()))
        .toList();

    setState(() {
      actions = fetchedActions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateControllerProvider);
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: actions.isEmpty
          ? Container(
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator()))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dateHeading(),
                            const Spacer(),
                            _iconButton(),
                            SizedBox(width: 8.w),
                            _iconButton(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: CircularElevatedButton(
                          onPressed: () {},
                          width: double.infinity,
                          color: AppColors.backgroundColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.w),
                            child: Text(
                              '''Your AI generated sustainable actions are not currently personalized. Click here to fill more information about your lifestyle to enable personalized actions.''',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      WeekWidget(today),
                      actionWidget(selectedDate: selectedDate),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _iconButton() {
    return Consumer(
      builder: (context, ref, child) {
        return InkWell(
          onTap: () {
            ref.read(firebaseAuthServiceProvider).signOut();
          },
          child: Row(
            children: [
              Icon(
                Icons.fire_extinguisher,
                color: AppColors.primaryColor,
                size: 32.w,
              ),
              Text(
                '4',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dateHeading() => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Today',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 26.sp,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: '\n${getFormattedDate(today)}',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget actionWidget({required DateTime selectedDate}) => Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(22.r)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.r),
                  topRight: Radius.circular(22.r),
                ),
              ),
              child: NeoPopShimmer(
                shimmerColor: Colors.white54,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    'Action of the day'.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Text(
                "${actions[selectedDate.weekday].action}",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            levelBar(selectedDate: selectedDate),
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                '02 hr 33 min left',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.h),
              child: Text(
                '''Description: ${actions[selectedDate.weekday].description}''',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22.r),
                  bottomRight: Radius.circular(22.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            width: 1.2.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {});
                        },
                        child: Text(
                          'Verify',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        'Impact',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 1.2.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Modify',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget levelBar({required DateTime selectedDate}) => Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(18.r)),
        ),
        child: Row(
          children: [
            Text(
              '${actions[selectedDate.weekday].difficulty}',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Lottie.asset(
              'assets/images/leaf.json',
              repeat: false,
              height: 35.h,
            ),
            Text(
              '4',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

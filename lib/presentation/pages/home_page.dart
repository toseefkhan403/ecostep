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

  Uint8List? imagebytes;
  bool isloadingimage = false;
  int? verifiedscore;
  bool isshowdialogbox = false;

  Future<void> pickimage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        isloadingimage = true;
        if (kIsWeb) {
          imagebytes = result.files.single.bytes;
        } else {
          imagebytes = File(result.files.single.path!).readAsBytesSync();
        }
      });
      await verifyimage(imagebytes!);
    } else {
      setState(() {
        isloadingimage = false;
      });
    }
  }

  Future<void> verifyimage(Uint8List imageBytes) async {
    final generativeModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: 'AIzaSyBFkQgBWLAAh2X_zmhDFgwnwkRSBwX04D0',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final prompt = TextPart('''
    Give a percentage score for this image on how much it matches this description: Image showing the user participating in a volunteer activity for an environmental organization (planting trees, cleaning a beach, etc.). Return the output in json using the following structure: { "verifiedScore" : "\$verifiedScore"}
    ''');

    final imagePart = DataPart('image/jpeg', imageBytes);

    final output = await generativeModel.generateContent([
      Content.multi([prompt, imagePart])
    ]);

    final jsonResponse = jsonDecode(output.text!) as Map<String, dynamic>;
    setState(() {
      print(jsonResponse);
      verifiedscore = int.parse(jsonResponse['verifiedScore'] as String);
      isloadingimage = false;
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
        child: isshowdialogbox
            ? Container(
                width: 541.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [BoxShadow()]),
                child: isloadingimage
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Loading...'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Image Verification",
                            style: TextStyle(
                              color: Color.fromRGBO(113, 55, 73, 1),
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Container(
                            width: 352.w,
                            child: Text(
                              "Verify your action image with AI ✨ to receive your reward",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(113, 55, 73, 1),
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 19.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: verifiedscore != null
                                ? Column(
                                    children: [
                                      Text(
                                        'Verified successfully!  score:  ${verifiedscore}',
                                        style: TextStyle(
                                          color: Color.fromRGBO(113, 55, 73, 1),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Text(
                                        'Reward added to your account :)',
                                        style: TextStyle(
                                          color: Color.fromRGBO(113, 55, 73, 1),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Image description: ',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  113, 55, 73, 1),
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '''Image showing the user participating in a volunteer activity for an environmental organization (planting trees, cleaning a beach, etc.).''',
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  113, 55, 73, 1),
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 20),
                          verifiedscore != null
                              ? ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      verifiedscore = null;
                                      isshowdialogbox = false;
                                    });
                                  },
                                  child: Text('Exit'),
                                )
                              : ElevatedButton(
                                  onPressed: pickimage,
                                  child: Text('Select Image'),
                                ),
                          SizedBox(height: 20),
                        ],
                      ),
              )
            : Column(
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
                                setState(() {
                                  isshowdialogbox = true;
                                });
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

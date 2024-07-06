import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../utils/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/week_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
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
                  SizedBox(
                    width: 8.w,
                  ),
                  _iconButton(),
                ],
              ),
            ),
            WeekWidget(today),
            actionWidget(),
          ],
        ),
      ),
    );
  }

  _iconButton() {
    return Consumer(builder: (context, ref, child) {
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
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    });
  }

  _dateHeading() => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "Today",
              style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 26.sp,
                  height: 1,
                  fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: "\n${getFormattedDate(today)}",
              style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

  Widget actionWidget() => Container(
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
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                "Action of the day".toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Text(
                "Borrow or rent instead of buying a tool or appliance you'll only use once",
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            levelBar(),
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                "02 hr 33 min left",
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.h),
              child: Text(
                """Description: Extend the life of existing items and reduce unnecessary consumption""",
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
                                  width: 1.2.w, color: Colors.white))),
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          "Verify",
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
                        "Impact",
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
                                  width: 1.2.w, color: Colors.white))),
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          "Modify",
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

  levelBar() => Container(
        height: 40.h,
        margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(18.r)),
        ),
        child: Row(
          children: [
            Text(
              "Medium",
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Lottie.asset(
              'assets/images/leaf.json',
              repeat: false,
            ),
            Text(
              "4",
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

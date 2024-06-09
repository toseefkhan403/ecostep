import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Column(
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
    );
  }

  _iconButton() {
    return InkWell(
      onTap: () {},
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
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(22.r)),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.r),
                  topRight: Radius.circular(22.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
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
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Text(
                "Borrow or rent instead of buying a tool or appliance you'll only use once",
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
}

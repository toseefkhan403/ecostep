import 'package:auto_size_text/auto_size_text.dart';
import 'package:ecostep/presentation/controllers/selected_date_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_colors.dart';
import '../utils/date_utils.dart';

class WeekWidget extends ConsumerStatefulWidget {
  final DateTime today;

  const WeekWidget(this.today, {super.key});

  @override
  ConsumerState<WeekWidget> createState() => _WeekWidgetState();
}

class _WeekWidgetState extends ConsumerState<WeekWidget> {
  List<DateTime> currentWeek = [];

  @override
  void initState() {
    currentWeek = getCurrentWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedDateControllerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Icon(
              CupertinoIcons.left_chevron,
              color: AppColors.primaryColor,
              size: 16.w,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: currentWeek.map((date) => _dateItem(date)).toList(),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.w),
          child: InkWell(
            onTap: () {},
            child: Icon(
              CupertinoIcons.right_chevron,
              color: AppColors.primaryColor,
              size: 16.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateItem(DateTime date) {
    final provider = ref.read(selectedDateControllerProvider.notifier);
    final weekday = getWeekday(date);
    bool isSelected = provider.isSelected(date);
    double textOpacity = date.day <= widget.today.day ? 1 : 0.5;
    if(isSelected) {
      textOpacity = 1;
    }
    return Expanded(
      child: InkWell(
        onTap: () {
          provider.setSelectedDate(date);
        },
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8.r),
            ),
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.2)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                weekday[0],
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(textOpacity),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              AutoSizeText(
                weekday[1],
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(textOpacity),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

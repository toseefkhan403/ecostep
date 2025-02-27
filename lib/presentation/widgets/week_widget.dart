import 'package:auto_size_text/auto_size_text.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/presentation/controllers/week_state_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeekWidget extends ConsumerStatefulWidget {
  const WeekWidget(this.today, {super.key});
  final Date today;

  @override
  ConsumerState<WeekWidget> createState() => _WeekWidgetState();
}

class _WeekWidgetState extends ConsumerState<WeekWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekState = ref.watch(weekStateControllerProvider);
    final controller = ref.read(weekStateControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {});
            _animationController.forward().then((_) {
              controller.changeWeek(goBack: true);
              _animationController.reverse();
            });
          },
          icon: const Icon(
            CupertinoIcons.left_chevron,
            color: AppColors.primaryColor,
            size: 16,
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: weekState.selectedWeek.map(_dateItem).toList(),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {});
            _animationController.forward().then((_) {
              controller.changeWeek(goBack: false);
              _animationController.reverse();
            });
          },
          icon: const Icon(
            CupertinoIcons.right_chevron,
            color: AppColors.primaryColor,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _dateItem(Date date) {
    final provider = ref.read(weekStateControllerProvider.notifier);
    final weekday = date.getWeekday();
    final isSelected = provider.isSelected(date);
    var textOpacity = date.isBefore(widget.today) ? 1.0 : 0.5;
    if (isSelected) {
      textOpacity = 1.0;
    }
    return Expanded(
      child: Semantics(
        label: 'Select date',
        child: InkWell(
          onTap: () {
            provider.setSelectedDate(date);
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
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
                  softWrap: false,
                  style: TextStyle(
                    color: AppColors.textColor.withOpacity(textOpacity),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  minFontSize: 10,
                ),
                AutoSizeText(
                  weekday[1],
                  softWrap: false,
                  style: TextStyle(
                    color: AppColors.textColor.withOpacity(textOpacity),
                    fontWeight: FontWeight.w700,
                  ),
                  minFontSize: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

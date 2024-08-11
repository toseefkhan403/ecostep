import 'package:ecostep/data/config_repository.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayButtonWidget extends ConsumerWidget {
  const PlayButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPlayButtonValue = ref.watch(showPlayButtonProvider);
    return AsyncValueWidget(
      value: showPlayButtonValue,
      loading: SizedBox.shrink,
      data: (showPlayButton) => !showPlayButton
          ? const SizedBox.shrink()
          : Semantics(
              label: 'Install from Play Store',
              child: CircularElevatedButton(
                color: AppColors.secondaryColor,
                height: 60,
                width: 190,
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.ecostep.greenloop',
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/google-play-icon.png',
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Get it on Google Play',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

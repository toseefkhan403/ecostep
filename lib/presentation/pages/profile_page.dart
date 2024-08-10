import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/presentation/pages/request_section.dart';
import 'package:ecostep/presentation/pages/user_profile_section.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userValue = ref.watch(firestoreUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isMobileScreen(context)
          ? null
          : Padding(
              padding:
                  EdgeInsets.only(bottom: isMobileScreen(context) ? 55.0 : 0),
              child: CircularElevatedButton(
                color: AppColors.secondaryColor,
                height: isMobileScreen(context) ? 45 : 60,
                width: isMobileScreen(context) ? 130 : 150,
                onPressed: () =>
                    ref.read(firebaseAuthServiceProvider).signOut(),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
      body: CenterContentPadding(
        child: Column(
          children: [
            Expanded(
              child: AsyncValueWidget(
                value: userValue,
                data: (user) => PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    UserProfileSection(
                      pageController: _pageController,
                      user: user,
                    ),
                    RequestSection(
                      profilePageController: _pageController,
                      user: user,
                    ),
                  ],
                ),
              ),
            ),
            if (isMobileScreen(context)) const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

import 'package:ecostep/application/firebase_auth_service.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/pages/request_section.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
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
  Widget build(BuildContext context) {
    final userValue = ref.watch(firestoreUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: CircularElevatedButton(
        color: AppColors.secondaryColor,
        height: 60,
        onPressed: () {
          ref.read(firebaseAuthServiceProvider).signOut();
        },
        child: const Text(
          'Logout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: CenterContentPadding(
        child: AsyncValueWidget(
          value: userValue,
          data: (user) => Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
              // _buttonRow(),
              Expanded(
                child: PageView(
                  controller: _pageController,
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
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({
    required this.user,
    required this.pageController,
    super.key,
  });
  final PageController pageController;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: user.profilePicture != null
                  ? CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(user.profilePicture!),
                    )
                  : Image.asset(
                      'assets/images/eco-earth.png',
                      height: 100 * 2,
                    ),
            ),
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CircularElevatedButton(
                  onPressed: () {},
                  color: AppColors.secondaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LottieIconWidget(
                        iconName: 'coin',
                      ),
                      Text(
                        '${user.ecoBucksBalance}',
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Text(
            user.name ?? 'Guest User',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _cityCountryRankRow(pagecontroller: pageController),
        Container(
          // width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: roundedContainerDecoration(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _heading('Your actions'),
                const LottieIconWidget(
                  iconName: 'not-found',
                  autoPlay: true,
                  height: 100,
                ),
                // SizedBox(
                //   height: 150,
                //   child: ListView.builder(
                //     itemCount: 10,
                //     scrollDirection: Axis.horizontal,
                //     itemBuilder: (context, index) => _actionCard(),
                //   ),
                // ),
                _heading('Your recycles'),
                const LottieIconWidget(
                  iconName: 'not-found',
                  autoPlay: true,
                  height: 100,
                ),
                // SizedBox(
                //   height: 150,
                //   child: ListView.builder(
                //     itemCount: 20,
                //     scrollDirection: Axis.horizontal,
                //     itemBuilder: (context, index) => _actionCard(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _heading(String title) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );

Widget _actionCard() => Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: roundedContainerDecoration(),
      child: const Text('hi'),
    );

Widget _cityCountryRankRow({required PageController pagecontroller}) => Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: CircularElevatedButton(
              color: AppColors.secondaryColor,
              blurRadius: 1,
              darkShadow: true,
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '#1 in New Delhi',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            child: CircularElevatedButton(
              color: AppColors.secondaryColor,
              blurRadius: 1,
              darkShadow: true,
              onPressed: () {
                pagecontroller.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'See Pending Requests',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

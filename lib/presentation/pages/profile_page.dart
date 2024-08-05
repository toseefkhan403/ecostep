import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/pages/request_section.dart';
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
  Widget build(BuildContext context) {
    final userValue = ref.watch(firestoreUserProvider);

    return CenterContentPadding(
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
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: CircleAvatar(
                radius: 120,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CircularElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: aboutLevelDialog,
                    );
                  },
                  color: AppColors.secondaryColor,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Level',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        '33',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black,
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
            '${user.name}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _cityCountryRankRow(pagecontroller: pageController),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: roundedContainerDecoration(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _heading('Impact'),
                  const Text('show with icons'),
                  _heading('Your actions'),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _actionCard(),
                    ),
                  ),
                  _heading('Your recycles'),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: 20,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _actionCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget aboutLevelDialog(BuildContext context) => AlertDialog(
      title: const Text('Level Information'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Explain levels here'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Exit'),
        ),
      ],
    );

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

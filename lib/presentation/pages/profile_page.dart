import 'package:ecostep/application/constants.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODOreplace with firestore user
    final userValue = AsyncValue.data(dummyUser);

    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: !isMobileScreen(context) ? width * 0.25 : 10,
      ),
      child: AsyncValueWidget(
        value: userValue,
        data: (user) => Column(
          children: [
            const SizedBox(height: 40),
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
              padding:const EdgeInsets.only(top: 10, bottom: 15),
              child: Text(
                '${user.name}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _cityCountryRankRow(),
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
        ),
      ),
    );
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

  Widget _actionCard() =>  Container(
        padding:const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: roundedContainerDecoration(),
        child: const Text('hi'),
      );

  Widget _cityCountryRankRow() =>  Padding(
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
                  child:  Text(
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
                onPressed: () {},
                child:  const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child:  Text(
                    '#1 in India',
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
}

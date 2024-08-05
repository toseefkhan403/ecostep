import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CenterContentPadding(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Leaderboard',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 26,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buttonRow(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('joinedOn', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final users = snapshot.data!.docs
                          .map(
                            (doc) => User.fromJson(
                              doc.data()! as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                      return _buildUserList(users);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('ecoBucksBalance', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data!.docs
                          .map(
                            (doc) => User.fromJson(
                              doc.data()! as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                      return _buildUserList(users);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => userCard(users[index], index),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buttonRow() => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CircularElevatedButton(
                color: _selectedIndex == 0
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                blurRadius: _selectedIndex == 0 ? 1 : 5,
                darkShadow: _selectedIndex == 0,
                onPressed: () => _onItemTapped(0),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Most Recent',
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
                color: _selectedIndex == 1
                    ? AppColors.secondaryColor
                    : AppColors.backgroundColor,
                onPressed: () => _onItemTapped(1),
                blurRadius: _selectedIndex == 1 ? 1 : 5,
                darkShadow: _selectedIndex == 1,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Most Impact',
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

  Widget userCard(User user, int index) => Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: roundedContainerDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: user.profilePicture != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(user.profilePicture!),
                        )
                      : Image.asset(
                          'assets/images/eco-earth.png',
                          height: 25 * 2,
                        ),
                ),
                Text(
                  user.name ?? 'Guest User',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const LottieIconWidget(
                  iconName: 'coin',
                ),
                Text(
                  ' ${user.ecoBucksBalance}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Joined On: ${user.joinedOn}',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
}

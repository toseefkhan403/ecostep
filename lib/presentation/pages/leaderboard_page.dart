import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecostep/domain/date.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/pages/user_profile_section.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/center_content_padding.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    isMobileScreen(context) ? 50 : 20,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LottieIconWidget(
                            iconName: 'recycle',
                            autoPlay: true,
                            repeat: true,
                            height: 100,
                          ),
                        );
                      }

                      final users = snapshot.data!.docs
                          .map(
                            (doc) {
                              final json = doc.data()! as Map<String, dynamic>;
                              if (json['id'] != null &&
                                  json['ecoBucksBalance'] != null &&
                                  json['joinedOn'] != null) {
                                return User.fromJson(json);
                              }
                              return null;
                            },
                          )
                          .whereType<User>()
                          .toList();

                      final formatter = DateFormat('dd-MM-yyyy');

                      users.sort((a, b) {
                        final aJoinedOn = formatter.parse(a.joinedOn);
                        final bJoinedOn = formatter.parse(b.joinedOn);
                        return bJoinedOn.compareTo(aJoinedOn);
                      });

                      return _buildUserList(users, 'Most Recent');
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    isMobileScreen(context) ? 50 : 20,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('ecoBucksBalance', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LottieIconWidget(
                            iconName: 'recycle',
                            autoPlay: true,
                            repeat: true,
                            height: 100,
                          ),
                        );
                      }

                      final users = snapshot.data!.docs
                          .map(
                            (doc) => User.fromJson(
                              doc.data()! as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                      return _buildUserList(users, 'Most Impact');
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

  Widget _buildUserList(List<User> users, String category) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => userCard(users[index], index, category),
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
              child: Semantics(
                label: 'Most recent',
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
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: Semantics(
                label: 'Most impact',
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
            ),
          ],
        ),
      );

  Widget userCard(User user, int index, String category) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        return GestureDetector(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (c) => CenterContentPadding(
                child: AlertDialog(
                  insetPadding: isMobileScreen(c)
                      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 20)
                      : const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                  content: SizedBox(
                    width: constraints.maxWidth,
                    child: UserProfileSection(
                      user: user,
                      rank: '#${index + 1} in $category',
                    ),
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(20, isSmallScreen ? 10 : 20, 20, 20),
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: roundedContainerDecoration(),
            child: isSmallScreen
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
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
                                          backgroundImage: NetworkImage(
                                            user.profilePicture!,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/eco-earth.png',
                                          height: 50,
                                          semanticLabel: 'Profile picture',
                                        ),
                                ),
                                Expanded(
                                  child: AutoSizeText(
                                    user.name ?? 'Guest User',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const LottieIconWidget(
                                iconName: 'coin',
                              ),
                              Text(
                                '${user.ecoBucksBalance}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Joined On',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        Date.formatDateString(user.joinedOn),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
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
                                      backgroundImage:
                                          NetworkImage(user.profilePicture!),
                                    )
                                  : Image.asset(
                                      'assets/images/eco-earth.png',
                                      height: 50,
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
                      ),
                      Expanded(
                        child: Row(
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
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: [
                              const Text(
                                'Joined On',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                Date.formatDateString(user.joinedOn),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

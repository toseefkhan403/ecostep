import 'package:auto_size_text/auto_size_text.dart';
import 'package:ecostep/data/user_repository.dart';
import 'package:ecostep/domain/user.dart';
import 'package:ecostep/presentation/controllers/market_place_controller.dart';
import 'package:ecostep/presentation/utils/app_colors.dart';
import 'package:ecostep/presentation/utils/utils.dart';
import 'package:ecostep/presentation/widgets/async_value_widget.dart';
import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:ecostep/presentation/widgets/lottie_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileSection extends ConsumerWidget {
  const UserProfileSection({
    required this.user,
    required this.pageController,
    super.key,
  });
  final PageController pageController;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlesValue = ref.watch(userCompletedActionTitlesProvider(user));
    final marketplaceItemsValue = ref.watch(marketplaceControllerProvider);

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
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: roundedContainerDecoration(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _heading('Your actions'),
                    SizedBox(
                      height: 160,
                      child: AsyncValueWidget(
                        value: titlesValue,
                        data: (titles) => titles.isEmpty
                            ? const LottieIconWidget(
                                iconName: 'not-found',
                                autoPlay: true,
                                height: 100,
                              )
                            : ListView.builder(
                                itemCount: titles.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) =>
                                    _actionCard(titles[index]),
                              ),
                      ),
                    ),
                    _heading('Your recycles'),
                    SizedBox(
                      height: 160,
                      child: AsyncValueWidget(
                        value: marketplaceItemsValue,
                        data: (marketplaceItems) {
                          final filteredItems = getUserSellerItems(
                            marketplaceItems,
                            user.id,
                          );
                          return filteredItems.isEmpty
                              ? const LottieIconWidget(
                                  iconName: 'not-found',
                                  autoPlay: true,
                                  height: 100,
                                )
                              : ListView.builder(
                                  itemCount: filteredItems.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => _recycleCard(
                                    filteredItems[index].imageUrl,
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

  Widget _cityCountryRankRow({required PageController pagecontroller}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final rankValue = ref.watch(rankUserProvider);
                return CircularElevatedButton(
                  color: AppColors.secondaryColor,
                  blurRadius: 1,
                  darkShadow: true,
                  onPressed: () {
                    showToast(
                      ref,
                      'Your rank in the leaderboards based on your EcoBucks',
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: AsyncValueWidget(
                      value: rankValue,
                      data: (rank) => Text(
                        '#$rank in Leaderboards',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const Center(
                        child: Text(
                          '. . .',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
  }

  Widget _actionCard(String title) => Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: roundedContainerDecoration(color: AppColors.primaryColor),
        child: Expanded(
          child: Center(
            child: AutoSizeText(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  Widget _recycleCard(String imageUrl) => Container(
        width: 150,
        margin: const EdgeInsets.all(10),
        decoration: roundedContainerDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.black12,
                Colors.black87,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            blendMode: BlendMode.srcATop,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
}

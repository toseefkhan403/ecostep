import 'package:auto_size_text/auto_size_text.dart';
import 'package:ecostep/application/firebase_auth_service.dart';
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
    this.pageController,
    this.rank,
    super.key,
  });
  final User user;
  final PageController? pageController;
  // if rank is present, the user is not the currently logged in user
  final String? rank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlesValue = ref.watch(userCompletedActionTitlesProvider(user));
    final marketplaceItemsValue = ref.watch(marketplaceControllerProvider);
    final isSelf = rank == null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: user.profilePicture != null
                      ? CircleAvatar(
                          radius: isMobileScreen(context) ? 60 : 100,
                          backgroundImage: NetworkImage(user.profilePicture!),
                        )
                      : Image.asset(
                          'assets/images/eco-earth.png',
                          height: (isMobileScreen(context) ? 60 : 100) * 2,
                          semanticLabel: 'Profile picture',
                        ),
                ),
              ),
              Positioned(
                bottom: isMobileScreen(context) ? 20 : 30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: roundedContainerDecoration(
                      color: AppColors.secondaryColor,
                    ),
                    width: 150,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LottieIconWidget(
                          iconName: 'coin',
                          height: 40,
                        ),
                        Text(
                          '${user.ecoBucksBalance}',
                          style: const TextStyle(
                            color: AppColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isMobileScreen(context) && isSelf)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Semantics(
                    label: 'Logout',
                    child: IconButton.filled(
                      onPressed: () =>
                          ref.read(firebaseAuthServiceProvider).signOut(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            user.name ?? 'Guest User',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (isSelf)
          _buttonsRow(pagecontroller: pageController)
        else
          Semantics(
            label: 'Leaderboard rank',
            child: CircularElevatedButton(
              width: double.infinity,
              color: AppColors.secondaryColor,
              blurRadius: 1,
              darkShadow: true,
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(
              isSelf ? 8 : 0,
              20,
              isSelf ? 8 : 0,
              isSelf ? 20 : 10,
            ),
            decoration: roundedContainerDecoration(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _heading(isSelf ? 'Your actions' : 'Actions'),
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
                    _heading(isSelf ? 'Your recycles' : 'Recycles'),
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

  Widget _buttonsRow({PageController? pagecontroller}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final rankValue = ref.watch(rankUserProvider);
                return Semantics(
                  label: 'Leaderboard rank',
                  child: CircularElevatedButton(
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            child: Semantics(
              label: 'See pending requests',
              child: CircularElevatedButton(
                color: AppColors.secondaryColor,
                blurRadius: 1,
                darkShadow: true,
                onPressed: () {
                  if (pagecontroller == null) return;

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
              semanticLabel: 'Your recycled item image',
            ),
          ),
        ),
      );
}

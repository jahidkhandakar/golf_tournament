import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_state.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/nearby_golfer.dart';
import '../../domain/repositories/golfers_repository.dart';
import '../widgets/golfer_tile.dart';

/// Rendered as the Profile tab's body inside [MainShell] — browsing nearby
/// golfers, not the current user's own profile. That lives at "My Profile",
/// reached from the drawer header.
class NearbyGolfersPage extends StatefulWidget {
  const NearbyGolfersPage({super.key});

  @override
  State<NearbyGolfersPage> createState() => _NearbyGolfersPageState();
}

class _NearbyGolfersPageState extends State<NearbyGolfersPage> {
  late final Future<List<NearbyGolfer>> _future =
      GetIt.instance<GolfersRepository>().getNearbyGolfers();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final radiusMiles = GetIt.instance<LocationState>().radiusMiles.value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.groups_outlined, size: 16, color: secondaryText),
              const SizedBox(width: 4),
              Text('Golfers within $radiusMiles mi', style: AppTextStyles.caption(secondaryText)),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<NearbyGolfer>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final golfers = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: golfers.length,
                itemBuilder: (context, index) {
                  final golfer = golfers[index];
                  return GolferTile(
                    golfer: golfer,
                    onTap: () => context.push(AppRoutes.golferProfile(golfer.id), extra: golfer),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

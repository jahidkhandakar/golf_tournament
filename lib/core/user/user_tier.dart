import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Placeholder for the current user's subscription tier. This will come
/// from the authenticated user/session once auth + backend are wired up.
enum UserTier { free, paid, superuser }

extension UserTierPresentation on UserTier {
  String get label {
    switch (this) {
      case UserTier.free:
        return 'Free';
      case UserTier.paid:
        return 'Paid';
      case UserTier.superuser:
        return 'Superuser';
    }
  }

  Color get color {
    switch (this) {
      case UserTier.free:
        return AppColors.grey;
      case UserTier.paid:
        return AppColors.gold;
      case UserTier.superuser:
        return AppColors.black;
    }
  }
}

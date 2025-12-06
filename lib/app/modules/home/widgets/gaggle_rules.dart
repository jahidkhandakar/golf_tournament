import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:golf_game_play/common/app_color/app_colors.dart';
import 'package:golf_game_play/common/app_string/app_string.dart';
import 'package:golf_game_play/common/app_text_style/style.dart';
import 'package:golf_game_play/common/widgets/custom_card.dart';

class GaggleRules extends StatelessWidget {
  const GaggleRules({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      // To shrink the bottom sheet to fit content
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Close Icon at the Top-right Corner
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
          ],
        ),
        Align(
            alignment: Alignment.center,
            child: Text(AppString.gaggleRulesText, style: AppStyles.h1())),
        // Content of Bottom Sheet
        SizedBox(height: 20.h),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomCard(
            borderSideColor: AppColors.primaryColor.withOpacity(0.5),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppString.gaggleRulesText, style: AppStyles.h2()),
                  Text(AppString.tournamentRulesDesText, style: AppStyles.h6()),
                  SizedBox(height: 10.h),
                  Text(
                    AppString.formatOfPlayText,
                    style: AppStyles.h2(),
                  ),
                  Text(AppString.formatPlayDesText, style: AppStyles.h6()),
                  SizedBox(height: 10.h),
                  Text(
                    AppString.tournamentSpecificsText,
                    style: AppStyles.h2(),
                  ),
                  Text(AppString.tournamentSpecificDesText, style: AppStyles.h6()),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
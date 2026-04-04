import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:golf_game_play/app/modules/sign_in/controllers/login_controller.dart';
import 'package:golf_game_play/app/routes/app_pages.dart';
import 'package:golf_game_play/common/app_color/app_colors.dart';
import 'package:golf_game_play/common/app_string/app_string.dart';
import 'package:golf_game_play/common/app_text_style/style.dart';
import 'package:golf_game_play/common/prefs_helper/prefs_helpers.dart';
import 'package:golf_game_play/common/widgets/background_image.dart';
import 'package:golf_game_play/common/widgets/custom_button.dart';
import 'package:golf_game_play/common/widgets/custom_text_field.dart';
import 'package:golf_game_play/common/widgets/golf_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SignInController _signInController = Get.put(SignInController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        children: [
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),
                const Align(
                  alignment: Alignment.center,
                  child: GolfLogo(imageSize: 230),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppString.signInText,
                      style: AppStyles.h1(color: Colors.white),
                    )),

                SizedBox(height: 50.h),
                CustomTextField(
                  suffixIcon: Icon(
                    Icons.mail,
                    color: AppColors.appGreyColor,
                    size: 20,
                  ),
                  filColor: AppColors.textFieldFillColor,
                  isEmail: true,
                  contentPaddingVertical: 20.h,
                  hintText: "Enter Email",
                  labelText: 'Email',
                  labelTextStyle: TextStyle(color: AppColors.primaryColor),
                  controller: _signInController.emailCtrl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  filColor: AppColors.textFieldFillColor,
                  suffixIconColor: AppColors.appGreyColor,
                  contentPaddingVertical: 20.h,
                  hintText: "Enter Password",
                  labelText: 'Password',
                  labelTextStyle: TextStyle(color: AppColors.primaryColor),
                  isObscureText: true,
                  obscure: '*',
                  isPassword: true,
                  controller: _signInController.passCtrl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                /// remember password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  /*  Wrap(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Remember',
                          style: AppStyles.h4(color: Colors.white),
                        )
                      ],
                    ),*/
                    /// Forgot password
                    InkWell(
                      onTap: () async {
                        Get.toNamed(Routes.VERIFY_EMAIL);
                      },
                      child: Text(
                        "Forgot Password?",
                        style: AppStyles.customSize(
                            size: 14,
                            family: "Schuyler",
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),

                /// Login Button

                SizedBox(height: 20.h),
                Obx(() {
                  return CustomButton(
                      loading: _signInController.isLoading.value,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          await _signInController.login();
                        }
                      },
                      textStyle: AppStyles.h1(color: Colors.black, fontWeight: FontWeight.w700),
                      text: AppString.loginText);
                }),

                /// Route to SignUpScreen through location selector screen
                SizedBox(height: 100.h),
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.LOCATION_SELECTOR,arguments: {'from':'login'});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account? ",
                        style: AppStyles.customSize(
                            size: 14,
                            family: "Schuyler",
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      Text(
                        "Register",
                        style: AppStyles.customSize(
                            size: 15,
                            family: "Schuyler",
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      )
    ]);
  }
  @override
  void dispose() {
    _signInController.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:golf_game_play/app/routes/app_pages.dart';
import 'package:golf_game_play/common/app_images/app_images.dart';
import 'package:golf_game_play/common/prefs_helper/prefs_helpers.dart';
import 'package:golf_game_play/common/widgets/background_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int activeIndex=0;
  late final Timer periodicTimer;
  late final Timer navigationTimer;
  @override
  void initState() {
    loadingPeriodic();
    super.initState();
  }

  loadingPeriodic(){
    periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer){
       setState(() {
         activeIndex = (activeIndex+1) % 6;
       });
    });
    navigationTimer= Timer(const Duration(seconds: 5), ()async{
      periodicTimer.cancel();
     await authenticationRoute();
    });
  }

   authenticationRoute()async {
   String token = await PrefsHelper.getString('token');
   setState(() {});
    if (token.isNotEmpty) {
       Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.SIGN_IN);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width =MediaQuery.of(context).size.width;
    double height  =MediaQuery.of(context).size.height;
    return BackgroundImage(
      children: [
        Positioned(
          top: height * 0.28,
          left: width * 0.03,
          right: width * 0.03,
          child: Image.asset(AppImage.golfLogoLayerImg,height: 370.h,width: 370.h,)
        ),
          Positioned(
            top: 650.h,
              left: width * 0.33,
              right: width * 0.33,
              child: Row(
                children: List.generate(5, (index){
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: AnimatedContainer(
                      height: 18.h,
                        width: 18.h,
                        duration: const Duration(microseconds: 300),
                      decoration:  BoxDecoration(
                        color: index < activeIndex? Colors.orange:Colors.white,
                        shape: BoxShape.circle
                      ),
                    )
                  );
                }),)
          ),


      /*  Positioned(
          top: 242.h,
          left: 12.w,
          child: ClipOval(
            child: Container(
              width: 370.h, // Match width and height
              height: 370.h,
              color: Colors.white.withOpacity(0.2), // Background color
            ),
          ),
        ),

        Positioned(
          top: 265.h,
          left: 37.w,
          child: ClipOval(
            child: Container(
              width: 320.h, // Match width and height
              height: 320.h,
              color: Colors.white.withOpacity(0.2), // Background color
            ),
          ),
        ),

        Positioned(
          top: 290.h,
          left: 66.w,
          child:const GolfLogo(containerSize: 266, imageSize: 250,),
        ),*/

      ],
    );
  }
@override
  void dispose() {
    periodicTimer.cancel();
    navigationTimer.cancel();
    super.dispose();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:golf_game_play/app/data/api_constants.dart';
import 'package:golf_game_play/common/prefs_helper/prefs_helpers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:image_picker/image_picker.dart';

class SponsorSignupController extends GetxController {
  final TextEditingController nameCtrl=TextEditingController();
  final TextEditingController locationCtrl=TextEditingController();
  final TextEditingController linkCtrl=TextEditingController();
  File? selectedIFile;
  var filePath=''.obs;

  RxBool isLoading = false.obs;

  pickImageFromGallery(ImageSource imageSource) async {
    final returnImage = await ImagePicker().pickImage(source: imageSource);
    if (returnImage == null) return;
    selectedIFile = File(returnImage.path);
    filePath.value=selectedIFile!.path;
    print('ImagesPath:$filePath');
    if(filePath.value.isNotEmpty){
      Get.snackbar('File selected', '');
    }
  }

  LatLng? latLng;

  Future<void> goToSearchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        var latLngLocation = LatLng(location.latitude, location.longitude);
        latLng = latLngLocation;
        update();
        print(latLng);
      }
    } catch (e) {
      print('Error occurred while searching: $e');
    }
  }


  createSponsorContent({Function(String?)? callBack}) async {
    isLoading.value = true;
    try {
      String token = await PrefsHelper.getString('token');
      String userId = await PrefsHelper.getString('userId');

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data'
      };

      Map<String, String> body = {
        "link": linkCtrl.text,
        "name": nameCtrl.text ,
        "longitude": latLng?.longitude.toString()??'0',
        "latitude": latLng?.latitude.toString()??'0',
      };

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.createSponsorTournamentUrl));

      request.headers.addAll(headers);

      if (selectedIFile != null && selectedIFile!.path.isNotEmpty) {
        await _addFileToRequest(request, selectedIFile!, 'sponserImage');
      }
      request.fields.assignAll(body);

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);
      print('Response Body: ${responseBody.body}');
      var decodedBody = jsonDecode(responseBody.body);
      https://kgc-bd.com/

      if (response.statusCode == 200) {
        Get.snackbar('Success', decodedBody['message']);
      } else {
        print('Error: ${response.statusCode}');
        Get.snackbar('Failed', decodedBody['message']);
      }
    } on SocketException catch (_) {
      Get.snackbar(
        'Error',
        'No internet connection. Please check your network and try again.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again later.',
        snackPosition: SnackPosition.TOP,
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to add file based on its type
// Helper method to add file based on its type
  Future<void> _addFileToRequest(http.MultipartRequest request, File file, String imageKey) async {
    String fileName = file.path.split('/').last;
    String fileType = fileName.split('.').last.toLowerCase();

    if (fileType == "png") {
      request.files.add(http.MultipartFile.fromBytes(
        imageKey,
        await file.readAsBytes(),
        filename: fileName,
        contentType: MediaType('image', 'png'),
      ));
      debugPrint("Media type png ==== $fileName");
    } else if (fileType == "jpg" || fileType == "jpeg") {
      request.files.add(http.MultipartFile.fromBytes(
        imageKey,
        await file.readAsBytes(),
        filename: fileName,
        contentType: MediaType('image', fileType),
      ));
      debugPrint("Media type $fileType ==== $fileName");
    } else {
      debugPrint("Unsupported media type: $fileName");
      throw Exception('Unsupported file type: $fileType');
    }
  }

}


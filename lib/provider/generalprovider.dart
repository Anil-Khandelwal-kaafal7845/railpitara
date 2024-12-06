import 'dart:io';

import 'package:dtlive/model/generalsettingmodel.dart';
import 'package:dtlive/model/loginregistermodel.dart';
import 'package:dtlive/model/pagesmodel.dart';
import 'package:dtlive/model/sociallinkmodel.dart';
import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GeneralProvider extends ChangeNotifier {
  GeneralSettingModel generalSettingModel = GeneralSettingModel();
  PagesModel pagesModel = PagesModel();
  SocialLinkModel socialLinkModel = SocialLinkModel();
  LoginRegisterModel loginSocialModel = LoginRegisterModel();
  LoginRegisterModel loginOTPModel = LoginRegisterModel();
  LoginRegisterModel loginTVModel = LoginRegisterModel();

  bool loading = false;
  String? appDescription;
   String? isEmail;
   String? isGoogleLogin;
   String? isFbLogin;
   String ? isMobileLogin;
   dynamic isAdsCoin;
   


  SharedPre sharedPre = SharedPre();

  Future<void> getGeneralsetting(BuildContext context) async {
    loading = true;
    generalSettingModel = await ApiService().genaralSetting();
    debugPrint('generalSettingData status ==> ${generalSettingModel.status}');
    if (generalSettingModel.status == 200) {
      if (generalSettingModel.result != null) {
        for (var i = 0; i < (generalSettingModel.result?.length ?? 0); i++) {
          await sharedPre.save(
            generalSettingModel.result?[i].key.toString() ?? "",
            generalSettingModel.result?[i].value.toString() ?? "",
          );
          debugPrint(
              '${generalSettingModel.result?[i].key.toString()} ==> ${generalSettingModel.result?[i].value.toString()}');
        }

        appDescription = await sharedPre.read("app_desripation") ?? "";

         isEmail = await sharedPre.read("is_email") ?? "0"; // Read the is_email value here
        isGoogleLogin = await sharedPre.read("is_google") ?? "0";  
        isFbLogin = await sharedPre.read("is_facebook") ?? "0";  
        isMobileLogin = await sharedPre.read("is_mobile") ?? "0";
        isAdsCoin = await sharedPre.read("no_of_coin_watch_ad") ?? "0";

        
      
      
      debugPrint("isEmail ===========> $isEmail");
      debugPrint("isGoogleLogin ===========> $isGoogleLogin");
      debugPrint("isFbLogin ===========> $isFbLogin");
      debugPrint("isMobileLogin ===========> $isMobileLogin");
            debugPrint("isAdsCoin ===========> $isAdsCoin");

        debugPrint("appDescription ===========> $appDescription");
        /* Get Ads Init */
        if (context.mounted && !kIsWeb) {
          AdHelper.getAds(context);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getPages() async {
    loading = true;
    pagesModel = await ApiService().getPages();
    debugPrint("getPages status :==> ${pagesModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> getSocialLinks() async {
    loading = true;
    socialLinkModel = await ApiService().getSocialLink();
    debugPrint("getSocialLinks status :==> ${socialLinkModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithSocial(email, name, type, File? profileImg) async {
    debugPrint("loginWithSocial email :==> $email");
    debugPrint("loginWithSocial name :==> $name");
    debugPrint("loginWithSocial type :==> $type");
    debugPrint("loginWithSocial profileImg :==> ${profileImg?.path}");

    loading = true;
    loginSocialModel =
        await ApiService().loginWithSocial(email, name, type, profileImg);
    debugPrint("loginWithSocial status :==> ${loginSocialModel.status}");
    debugPrint("loginWithSocial message :==> ${loginSocialModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithOTP(mobile ,email) async {
    debugPrint("getLoginOTP mobile :==> $mobile");
     debugPrint("getLoginOTP email :==> $email");

    loading = true;
    loginOTPModel = await ApiService().loginWithOTP(mobile ,email);
    debugPrint("login status :==> ${loginOTPModel.status}");
    debugPrint("login message :==> ${loginOTPModel.message}");
    loading = false;
    notifyListeners();
  }


  Future<void> loginWithTV(strOTP) async {
    debugPrint("loginWithTV strOTP :==> $strOTP");

    loading = true;
    loginTVModel = await ApiService().tvLogin(strOTP);
    debugPrint("loginWithTV status :===> ${loginTVModel.status}");
    debugPrint("loginWithTV message :==> ${loginTVModel.message}");
    loading = false;
    notifyListeners();
  }
}

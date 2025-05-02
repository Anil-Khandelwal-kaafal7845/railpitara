import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dtlive/model/auditionmodel.dart';
import 'package:dtlive/model/avatarmodel.dart';
import 'package:dtlive/model/browsebyartistmodel.dart';
import 'package:dtlive/model/castdetailmodel.dart';
import 'package:dtlive/model/coinpackagesmodel.dart';
import 'package:dtlive/model/coinrentmodel.dart';
import 'package:dtlive/model/couponmodel.dart';
import 'package:dtlive/model/force_update_model.dart';
import 'package:dtlive/model/historymodel.dart';
import 'package:dtlive/model/pagesmodel.dart';
import 'package:dtlive/model/paymentoptionmodel.dart';
import 'package:dtlive/model/paytmmodel.dart';
import 'package:dtlive/model/sociallinkmodel.dart';
import 'package:dtlive/model/subscriptionmodel.dart';
import 'package:dtlive/model/channelsectionmodel.dart';
import 'package:dtlive/model/episodebyseasonmodel.dart';
import 'package:dtlive/model/generalsettingmodel.dart';
import 'package:dtlive/model/genresmodel.dart';
import 'package:dtlive/model/langaugemodel.dart';
import 'package:dtlive/model/loginregistermodel.dart';
import 'package:dtlive/model/profilemodel.dart';
import 'package:dtlive/model/rentmodel.dart';
import 'package:dtlive/model/searchmodel.dart';
import 'package:dtlive/model/sectionbannermodel.dart';
import 'package:dtlive/model/sectiondetailmodel.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/sectiontypemodel.dart';
import 'package:dtlive/model/successmodel.dart';
import 'package:dtlive/model/userwalletmodel.dart';
import 'package:dtlive/model/videobyidmodel.dart';
import 'package:dtlive/model/viewallmodel.dart';
import 'package:dtlive/model/wallettransction.dart';
import 'package:dtlive/model/watchlistmodel.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singular_flutter_sdk/singular.dart';

class API {
  final Dio _dio = Dio();
  API() {
    _dio.options.baseUrl = Constant.baseurl;
    _dio.interceptors.add(PrettyDioLogger());
  }
  Dio get sendRequest => _dio;
}

Options optHeaders = Options(headers: <String, dynamic>{
  'Content-Type': 'application/json',
});

class HomeScreenRepo {
  API api = API();

  // ignore: body_might_complete_normally_nullable
  Future<ForceUpdatemodel?> forceUpdateApi(BuildContext context) async {
    try {
      Response response =
          await api.sendRequest.get("/force_update", options: optHeaders);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ForceUpdatemodel featuredData =
            ForceUpdatemodel.fromJson(response.data);
        return featuredData;
      } else {
        Fluttertoast.showToast(msg: "serverError");
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("SOME ISSUES IN force update API");
      throw (e.toString());
    }
  }
}

class ApiService {
  String baseUrl = Constant.baseurl;
  // String StagebaseUrl = "https://stage.ottsnap.com/api/";

  late Dio dio;

  Options optHeaders = Options(headers: <String, dynamic>{
    'Content-Type': 'application/json',
  });

  ApiService() {
    dio = Dio();
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ),
    );
  }

  // Helper method to get the token and set it in headers
  Future<Options> _getAuthHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      throw Exception("Auth token not found. Please log in again.");
    }

    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  // general_setting API
  Future<GeneralSettingModel> genaralSetting() async {
    GeneralSettingModel generalSettingModel;
    String generalsetting = "general_setting";
    Response response = await dio.post(
      '$baseUrl$generalsetting',
      options: optHeaders,
    );
    generalSettingModel = GeneralSettingModel.fromJson(response.data);
    return generalSettingModel;
  }

  // get_pages API
  Future<PagesModel> getPages() async {
    PagesModel pagesModel;
    String getPagesAPI = "get_pages";
    Response response = await dio.post(
      '$baseUrl$getPagesAPI',
      options: optHeaders,
    );
    pagesModel = PagesModel.fromJson(response.data);
    return pagesModel;
  }

  // get_social_link API
  Future<SocialLinkModel> getSocialLink() async {
    SocialLinkModel socialLinkModel;
    String socialLinkAPI = "get_social_link";
    Response response = await dio.post(
      '$baseUrl$socialLinkAPI',
      options: optHeaders,
    );
    socialLinkModel = SocialLinkModel.fromJson(response.data);
    return socialLinkModel;
  }

  /* type => 1-Facebook, 2-Google, 4-Google */
  // login API
  Future<LoginRegisterModel> loginWithSocial(
      email, name, type, File? profileImg) async {
    debugPrint("email :==> $email");
    debugPrint("name :==> $name");
    debugPrint("type :==> $type");
    debugPrint("profileImg :==> $profileImg");

    LoginRegisterModel loginModel;
    String gmailLogin = "login";
    Response response = await dio.post(
      '$baseUrl$gmailLogin',
      options: optHeaders,
      data: FormData.fromMap({
        'type': type,
        'email': email,
        'name': name,
        'image': (profileImg?.path ?? "").isNotEmpty
            ? await MultipartFile.fromFile(
                profileImg?.path ?? "",
                filename: (profileImg?.path ?? "").split('/').last,
              )
            : "",
      }),
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  /* type => 3-OTP */
  // login API
  Future<LoginRegisterModel> loginWithOTP(mobile, email) async {
    debugPrint("mobile :==> $mobile");
    debugPrint("mobile :==> $email");

    LoginRegisterModel loginModel;
    String doctorLogin = "login";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {'type': '3', 'mobile': mobile, 'email': email},
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Login Success',
      'user_id': Constant.userID.toString(),
      'mobile': mobile,
      'email': email
    };
    Singular.eventWithArgs('Login Success', screenViewEvent);
    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // whatsapp login API
  Future<bool> loginWithWhatsapp(mobile, type, email) async {
    debugPrint("mobile :==> $mobile");
    debugPrint("email :==> $email");
    debugPrint("type :==> $type");

    String doctorLogin = "sendotp";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'mobile': mobile,
        'login_type': type,
        'email': email,
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      Map<String, Object> screenViewEvent = {
        'screen_name': 'Login Failed',
        'user_id': Constant.userID.toString(),
        'mobile': mobile,
        'email': email
      };
      Singular.eventWithArgs('Login Failed', screenViewEvent);
      return false;
    }
  }

  // verify whatsapp login API
  // Future<bool> verifyLoginWithWhatsapp(
  //     String mobile, String otp, String email) async {
  //   debugPrint("mobile :==> $mobile");
  //   debugPrint("email :==> $email");

  //   String doctorLogin = "verifyotp?mobile=$mobile&email=$email&token=$otp";
  //   try {
  //     Response response = await dio.post(
  //       '$baseUrl$doctorLogin',
  //       options: optHeaders,
  //       data: {'mobile': mobile, 'token': otp, 'email': email},
  //     );

  //     if (response.statusCode == 200) {
  //       return true; // Authentication successful
  //     } else {
  //       return false; // Authentication failed for some other reason
  //     }
  //   } catch (e) {
  //     // Handle DioException or other exceptions here
  //     print("Error: $e");
  //     return false; // Authentication failed due to an error
  //   }
  // }

  Future<bool> verifyLoginWithWhatsapp(
      String mobile, String otp, String email) async {
    debugPrint("mobile :==> $mobile");
    debugPrint("email :==> $email");

    String doctorLogin = "verifyotp?mobile=$mobile&email=$email&token=$otp";
    try {
      Response response = await dio.post(
        '$baseUrl$doctorLogin',
        options: optHeaders,
        data: {'mobile': mobile, 'token': otp, 'email': email},
      );

      if (response.statusCode == 200 && response.data['status'] == 200) {
        // Extract the API token from the response
        final token = response.data['result']['api_token'];

        // Save the token to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        debugPrint("API Token saved: $token");
        return true; // Authentication successful
      } else {
        debugPrint("Authentication failed: ${response.data['message']}");
        return false; // Authentication failed
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false; // Authentication failed due to an error
    }
  }

  // forgot_password API
  Future<SuccessModel> forgotPassword(email) async {
    debugPrint("email :==> $email");

    SuccessModel successModel;
    String doctorLogin = "forgot_password";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'email': email,
      },
    );

    successModel = successModelFromJson(response.data.toString());
    return successModel;
  }

  // tv_login API
  Future<LoginRegisterModel> tvLogin(uniqueCode) async {
    debugPrint("tvLogin userID :======> ${Constant.userID}");
    debugPrint("tvLogin uniqueCode :==> $uniqueCode");

    LoginRegisterModel loginModel;
    String tvLoginAPI = "tv_login";
    Response response = await dio.post(
      '$baseUrl$tvLoginAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'unique_code': uniqueCode,
      },
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // get_profile API
  Future<ProfileModel> profile() async {
    debugPrint("profile userID :==> ${Constant.userID}");

    ProfileModel profileModel;
    String doctorLogin = "get_profile";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'id': Constant.userID,
      },
    );

    profileModel = ProfileModel.fromJson(response.data);
    return profileModel;
  }

  // update_profile API
  Future<SuccessModel> updateProfile(name) async {
    debugPrint("updateProfile userID :==> ${Constant.userID}");
    debugPrint("updateProfile name :==> $name");

    SuccessModel successModel;
    String doctorLogin = "update_profile";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'id': Constant.userID,
        'name': name,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Profile Update',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('Profile Update', screenViewEvent);
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // image_upload API
  Future<SuccessModel> imageUpload(File? profileImg) async {
    debugPrint("ProfileImg Filename :==> ${profileImg?.path.split('/').last}");
    debugPrint(
        "profileImg Extension :==> ${profileImg?.path.split('/').last.split(".").last}");
    SuccessModel uploadImgModel;
    String uploadImage = "image_upload";
    debugPrint("imageUpload API :==> $baseUrl$uploadImage");
    Response response = await dio.post(
      '$baseUrl$uploadImage',
      data: FormData.fromMap({
        'id': Constant.userID,
        // 'image': (profileImg?.path ?? "").isNotEmpty
        //     ? await MultipartFile.fromFile(profileImg!.path,
        //     filename: profileImg.path.split('/').last)
        //     : "",

        'image': (profileImg?.path ?? "").isNotEmpty
            ? await MultipartFile.fromFile(
                profileImg?.path ?? "",
                filename: (profileImg?.path ?? "").split('/').last,
              )
            : "",
      }),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    uploadImgModel = SuccessModel.fromJson(response.data);
    return uploadImgModel;
  }

  // get_avatar API
  Future<AvatarModel> getAvatar() async {
    AvatarModel avatarModel;
    String getAvatar = "get_avatar";
    Response response = await dio.post(
      '$baseUrl$getAvatar',
      options: optHeaders,
      data: {},
    );
    avatarModel = AvatarModel.fromJson(response.data);
    return avatarModel;
  }

  /* type => 1-movies, 2-news, 3-sport, 4-tv show */
  // get_type API
  Future<SectionTypeModel> sectionType() async {
    SectionTypeModel sectionTypeModel;
    String sectionType = "get_type";
    Response response = await dio.post(
      '$baseUrl$sectionType',
      options: optHeaders,
    );
    sectionTypeModel = SectionTypeModel.fromJson(response.data);
    return sectionTypeModel;
  }

  // get_banner API
  Future<SectionBannerModel> sectionBanner(typeId, isHomePage) async {
    debugPrint('sectionBanner typeId ==>>> $typeId');
    debugPrint('sectionBanner isHomePage ==>>> $isHomePage');
    SectionBannerModel sectionBannerModel;
    String sectionBanner = "get_banner";
    Object appVersion = Platform.isAndroid
        ? Constant.curentAppVersion
        : Constant.curentiosAppVersion;
    Response response = await dio.post(
      '$baseUrl$sectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'type_id': typeId,
        'is_home_page': isHomePage,
        'version': appVersion,
        'device': Constant.deviceType
      },
    );
    sectionBannerModel = SectionBannerModel.fromJson(response.data);
    return sectionBannerModel;
  }

  // section_list API
  Future<SectionListModel> sectionList(typeId, isHomePage, languageId) async {
    SectionListModel sectionListModel;
    String sectionList = "section_list";
    Object appVersion = Platform.isAndroid
        ? Constant.curentAppVersion
        : Constant.curentiosAppVersion;

    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'type_id': typeId,
        'is_home_page': isHomePage,
        'language_id': languageId,
        'version': appVersion,
        'device': Constant.deviceType
      },
    );
    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  //viewall api ---

  Future<List<VideoData>> viewAll(String sectionId) async {
    String viewAllEndpoint = "view-all";
    Object appVersion = Platform.isAndroid
        ? Constant.curentAppVersion
        : Constant.curentiosAppVersion;
    Response response = await dio.post(
      '$baseUrl$viewAllEndpoint',
      options: optHeaders,
      data: {
        'section_id': sectionId,
        'version': appVersion,
        'device': Constant.deviceType
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['result'][0]['data'];
      return data.map((json) => VideoData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  // section_detail API
  Future<SectionDetailModel> sectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    SectionDetailModel sectionDetailModel;
    String sectionList = "section_detail";
    Object appVersion = Platform.isAndroid
        ? Constant.curentAppVersion
        : Constant.curentiosAppVersion;
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'type_id': typeId,
        'video_type': videoType,
        'video_id': videoId,
        'upcoming_type': upcomingType,
        'version': appVersion,
        'device': Constant.deviceType
      },
    );
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  // video_view API
  Future<SuccessModel> videoView(videoId, videoType, otherId) async {
    debugPrint('videoView videoId ====>>> $videoId');
    debugPrint('videoView videoType ==>>> $videoType');
    debugPrint('videoView otherId ====>>> $otherId');
    SuccessModel successModel;
    String sectionList = "video_view";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'other_id': otherId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_remove_bookmark API
  Future<SuccessModel> addRemoveBookmark(typeId, videoType, videoId) async {
    SuccessModel successModel;
    String sectionList = "add_remove_bookmark";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'type_id': typeId,
        'video_type': videoType,
        'video_id': videoId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_continue_watching API
  Future<SuccessModel> addContinueWatching(videoId, videoType, stopTime) async {
    SuccessModel successModel;
    String continueWatching = "add_continue_watching";
    Response response = await dio.post(
      '$baseUrl$continueWatching',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'stop_time': stopTime,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // remove_continue_watching API
  /* user_id, video_id, video_type
     * Show :=> ("video_id" = Episode's ID)  AND  ("video_type" = "2")
     * Video :=> ("video_id" = Video's ID) */
  Future<SuccessModel> removeContinueWatching(videoId, videoType) async {
    SuccessModel successModel;
    String removeContinueWatching = "remove_continue_watching";
    Response response = await dio.post(
      '$baseUrl$removeContinueWatching',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_type': videoType,
        'video_id': videoId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_remove_download API
  /* user_id, video_id, video_type, type_id, other_id
     * Show :=> ("video_id" = Session's ID)  AND  ("other_id" = Show's ID)
     * Video :=> ("other_id" = "0") */
  Future<SuccessModel> addRemoveDownload(
      videoId, videoType, typeId, otherId) async {
    SuccessModel successModel;
    String addRemoveDownload = "add_remove_download";
    Response response = await dio.post(
      '$baseUrl$addRemoveDownload',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'type_id': typeId,
        'other_id': otherId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_video_by_session_id API
  Future<EpisodeBySeasonModel> episodeBySeason(seasonId, showId) async {
    EpisodeBySeasonModel episodeBySeasonModel;
    String episodeBySeasonList = "get_video_by_session_id";
    Response response = await dio.post(
      '$baseUrl$episodeBySeasonList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'session_id': seasonId,
        'show_id': showId,
      },
    );
    episodeBySeasonModel = EpisodeBySeasonModel.fromJson(response.data);
    return episodeBySeasonModel;
  }

  // cast_detail API
  Future<CastDetailModel> getCastDetails(castId) async {
    CastDetailModel castDetailModel;
    String castDetails = "cast_detail";
    Response response = await dio.post(
      '$baseUrl$castDetails',
      options: optHeaders,
      data: {
        'cast_id': castId,
      },
    );
    castDetailModel = CastDetailModel.fromJson(response.data);
    return castDetailModel;
  }

  // get_category API
  Future<GenresModel> genres() async {
    GenresModel genresModel;
    String genres = "get_category";
    Response response = await dio.post(
      '$baseUrl$genres',
      options: optHeaders,
    );
    genresModel = GenresModel.fromJson(response.data);
    return genresModel;
  }

  // get_language API
  Future<LangaugeModel> language() async {
    LangaugeModel langaugeModel;
    String language = "get_language";
    Response response = await dio.post(
      '$baseUrl$language',
      options: optHeaders,
    );
    langaugeModel = LangaugeModel.fromJson(response.data);
    return langaugeModel;
  }

  // search_video API
  Future<SearchModel> searchVideo(searchText) async {
    debugPrint('searchVideo searchText ==>>> $searchText');
    SearchModel searchModel;
    String search = "search_video";
    Object appVersion = Platform.isAndroid
        ? Constant.curentAppVersion
        : Constant.curentiosAppVersion;
    Response response = await dio.post(
      '$baseUrl$search',
      options: optHeaders,
      data: {
        'name': searchText,
        'user_id': Constant.userID,
        'version': appVersion,
        'device': Constant.deviceType
      },
    );
    searchModel = SearchModel.fromJson(response.data);
    return searchModel;
  }

  // channel_section_list API
  Future<ChannelSectionModel> channelSectionList() async {
    ChannelSectionModel channelSectionModel;
    String channelSection = "channel_section_list";
    Response response = await dio.post(
      '$baseUrl$channelSection',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    channelSectionModel = ChannelSectionModel.fromJson(response.data);
    return channelSectionModel;
  }

  // rent_video_list API
  Future<RentModel> rentVideoList() async {
    RentModel rentModel;
    String rentList = "rent_video_list";
    Object appVersion = Platform.isAndroid
        ? Constant.curentAppVersion
        : Constant.curentiosAppVersion;
    Response response = await dio.post(
      '$baseUrl$rentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'version': appVersion,
        'device': Constant.deviceType
      },
    );
    rentModel = RentModel.fromJson(response.data);
    return rentModel;
  }

  // user_rent_video_list API
  Future<RentModel> userRentVideoList() async {
    RentModel rentModel;
    String rentList = "user_rent_video_list";
    Response response = await dio.post(
      '$baseUrl$rentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    rentModel = RentModel.fromJson(response.data);
    return rentModel;
  }

  // video_by_category API
  Future<VideoByIdModel> videoByCategory(categoryID, typeId) async {
    debugPrint('videoByCategory categoryID ==>>> $categoryID');
    debugPrint('videoByCategory typeId ====>>>>> $typeId');
    VideoByIdModel videoByIdModel;
    String byCategory = "video_by_category";
    Response response = await dio.post(
      '$baseUrl$byCategory',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'category_id': categoryID,
        'type_id': typeId,
      },
    );
    videoByIdModel = VideoByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // video_by_language API
  Future<VideoByIdModel> videoByLanguage(languageID, typeId) async {
    debugPrint('videoByLanguage languageID ==>>> $languageID');
    debugPrint('videoByLanguage typeId ====>>>>> $typeId');
    VideoByIdModel videoByIdModel;
    String byLanguage = "video_by_language";
    Response response = await dio.post(
      '$baseUrl$byLanguage',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'language_id': languageID,
        'type_id': typeId,
      },
    );
    videoByIdModel = VideoByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // ignore: body_might_complete_normally_nullable
  Future<VideoByartist?> videoByArtistApi(
      BuildContext context, castId, typeId) async {
    try {
      Response response = await dio
          .post("${baseUrl}video_by_artist", options: optHeaders, data: {
        'user_id': Constant.userID,
        'cast_id': castId,
        'type_id': typeId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        VideoByartist subscribeData = VideoByartist.fromJson(response.data);
        return subscribeData;
      } else {
        Fluttertoast.showToast(msg: "Server Error");
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("SOME ISSUES IN artist API");
      throw (e.toString());
    }
  }

  // get_package API
  Future<SubscriptionModel> subscriptionPackage() async {
    debugPrint('subscriptionPackage userID ==>>> ${Constant.userID}');
    SubscriptionModel subscriptionModel;
    String getPackage = "get_package";
    Response response = await dio.post(
      '$baseUrl$getPackage',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    subscriptionModel = SubscriptionModel.fromJson(response.data);
    return subscriptionModel;
  }

  // get_bookmark_video API
  Future<WatchlistModel> watchlist() async {
    debugPrint("watchlist userID :==> ${Constant.userID}");

    WatchlistModel watchlistModel;
    String getBookmarkVideo = "get_bookmark_video";
    debugPrint("getBookmarkVideo API :==> $baseUrl$getBookmarkVideo");
    Response response = await dio.post(
      '$baseUrl$getBookmarkVideo',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );

    watchlistModel = WatchlistModel.fromJson(response.data);
    return watchlistModel;
  }

  // get_payment_option API
  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String paymentOption = "get_payment_option";
    debugPrint("paymentOption API :==> $baseUrl$paymentOption");
    Response response = await dio.post(
      '$baseUrl$paymentOption',
      options: optHeaders,
    );

    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  // apply_coupon API
  Future<CouponModel> applyPackageCoupon(couponCode, packageId) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    debugPrint("applyPackageCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'apply_coupon_type': "1",
        'unique_id': couponCode,
        'package_id': packageId,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // apply_coupon API
  Future<CouponModel> applyRentCoupon(
      couponCode, videoId, typeId, videoType, price) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    debugPrint("applyRentCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'apply_coupon_type': "2",
        'unique_id': couponCode,
        'video_id': videoId,
        'type_id': typeId,
        'video_type': videoType,
        'price': price,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // get_payment_token API
  Future<PayTmModel> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    PayTmModel payTmModel;
    String paytmToken = "get_payment_token";
    debugPrint("paytmToken API :==> $baseUrl$paytmToken");
    Response response = await dio.post(
      '$baseUrl$paytmToken',
      options: optHeaders,
      data: {
        'MID': merchantID,
        'order_id': orderId,
        'CUST_ID': custmoreID,
        'CHANNEL_ID': channelID,
        'TXN_AMOUNT': txnAmount,
        'WEBSITE': website,
        'CALLBACK_URL': callbackURL,
        'INDUSTRY_TYPE_ID': industryTypeID,
      },
    );

    payTmModel = PayTmModel.fromJson(response.data);
    return payTmModel;
  }

  // add_transaction API
  Future<SuccessModel> addTransaction(packageId, description, amount, paymentId,
      currencyCode, couponCode, orderStatus, orderId, purchesVia) async {
    debugPrint('addTransaction userID ==>>> ${Constant.userID}');
    debugPrint('addTransaction packageId ==>>> $packageId');
    debugPrint('addTransaction description ==>>> $description');
    debugPrint('addTransaction amount ==>>> $amount');
    debugPrint('addTransaction paymentId ==>>> $paymentId');
    debugPrint('addTransaction currencyCode ==>>> $currencyCode');
    debugPrint('addTransaction couponCode ==>>> $couponCode');
    debugPrint('addTransaction order_status ==>>> $orderStatus');
    debugPrint('addTransaction orderId ==>>> $orderId');
    debugPrint('addTransaction purchesVia ==>>> $purchesVia');

    SuccessModel successModel;
    String transaction = "add_transaction";
    Response response = await dio.post(
      '$baseUrl$transaction',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'package_id': packageId,
        'description': description,
        'amount': amount,
        'payment_id': paymentId,
        'currency_code': currencyCode,
        'unique_id': couponCode,
        'order_status': orderStatus,
        'order_id': orderId,
        'purchase_from': purchesVia
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_rent_transaction API
  Future<SuccessModel> addRentTransaction(videoId, price, typeId, videoType,
      couponCode, orderStatus, orderId) async {
    debugPrint('addRentTransaction userID ==>>> ${Constant.userID}');
    debugPrint('addRentTransaction video_id ==>>> $videoId');
    debugPrint('addRentTransaction price ==>>> $price');
    debugPrint('addRentTransaction typeId ==>>> $typeId');
    debugPrint('addRentTransaction videoType ==>>> $videoType');
    debugPrint('addTransaction couponCode ==>>> $couponCode');
    debugPrint('addTransaction order_status ==>>> $orderStatus');
    debugPrint('addTransaction orderId ==>>> $orderId');

    SuccessModel successModel;
    String rentTransaction = "add_rent_transaction";
    Response response = await dio.post(
      '$baseUrl$rentTransaction',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'price': price,
        'type_id': typeId,
        'video_type': videoType,
        'unique_id': couponCode,
        'order_status': orderStatus,
        'order_id': orderId
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<AuditionModel> auditionDetaiApi(email) async {
    AuditionModel auditonData;
    Response response = await dio.post(
      'https://admin.aaryaadigital.com/api/get-audition-user-data',
      options: optHeaders,
      data: {"email": email},
    );
    auditonData = AuditionModel.fromJson(response.data);
    return auditonData;
  }

  // subscription_list API
  Future<HistoryModel> subscriptionList() async {
    HistoryModel historyModel;
    String subscriptionListAPI = "subscription_list";
    Response response = await dio.post(
      '$baseUrl$subscriptionListAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    historyModel = HistoryModel.fromJson(response.data);
    return historyModel;
  }

//coin system ----

// Future<UserWalletBalanceModel> getUserWalletBalance(String userId) async {
//   String endpoint = "get-user-wallet-balance";

//   try {
//     Response response = await dio.post(
//       '$StagebaseUrl$endpoint',
//       data: {
//         'user_id': userId,
//       },
//     );

//     // Print the full response data
//     print("Response Data: ${response.data}");

//     if (response.statusCode == 200) {
//       // Assuming UserWalletBalanceModel has a 'balance' field
//       var walletBalance = UserWalletBalanceModel.fromJson(response.data);

//       // Print the wallet balance
//       print("Wallet Balance: ${walletBalance.balance}");

//       return walletBalance;
//     } else {
//       throw Exception("Failed to fetch wallet balance");
//     }
//   } catch (e) {
//     print("Error fetching wallet balance: $e");
//     rethrow; // Re-throw the error after logging
//   }
// }

// Get User Wallet Balance API
  Future<UserWalletBalanceModel> getUserWalletBalance(String userId) async {
    String endpoint = "get-user-wallet-balance";

    try {
      final headers = await _getAuthHeaders();
      Response response = await dio.post(
        '$baseUrl$endpoint',
        options: headers,
        data: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        return UserWalletBalanceModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch wallet balance");
      }
    } catch (e) {
      print("Error fetching wallet balance: $e");
      rethrow;
    }
  }

// Add Coins After Watching Ad
  Future<UserWalletBalanceModel> addCoinsAfterWatchAd(
    String userId,
    dynamic videoId,
    dynamic showId,
    dynamic tokenValue,
  ) async {
    String endpoint = "add-coin-on-watch-ads";

    try {
      final headers = await _getAuthHeaders();
      Response response = await dio.post(
        '$baseUrl$endpoint',
        options: headers,
        data: {
          'user_id': userId,
          'video_id': videoId,
          'show_id': showId,
          'token_from': 'watch_ads',
          'ad_url': 'test.com',
          'no_of_token': tokenValue,
        },
      );

      if (response.statusCode == 200) {
        var walletBalance = UserWalletBalanceModel.fromJson(response.data);
        print("New Wallet Balance: ${walletBalance.balance}");
        return walletBalance;
      } else {
        throw Exception("Failed to add coins after watching ad");
      }
    } catch (e) {
      print("Error adding coins after watching ad: $e");
      rethrow;
    }
  }

// Get Coin Packages
  Future<List<CoinPackage>> getCoinPackages() async {
    String endpoint = "get-coin-package";

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        '$baseUrl$endpoint',
        options: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'];
        return data.map((coin) => CoinPackage.fromJson(coin)).toList();
      } else {
        throw Exception("Failed to load coin packages");
      }
    } catch (e) {
      print("Error fetching coin packages: $e");
      rethrow;
    }
  }

// Get Wallet History
  Future<List<WalletTransaction>> getWalletHistory(String userId) async {
    String endpoint = "user-wallet-history";

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        '$baseUrl$endpoint',
        options: headers,
        data: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'];
        return data
            .map((transaction) => WalletTransaction.fromJson(transaction))
            .toList();
      } else {
        throw Exception("Failed to load wallet history");
      }
    } catch (e) {
      print("Error fetching wallet history: $e");
      rethrow;
    }
  }

// Add Coin Transaction
  Future<bool> addCoinTransaction({
    required String userId,
    required int coinPackageId,
    required dynamic amount,
    required String paymentId,
    required String currencyCode,
    required String orderStatus,
    required String orderId,
    required String paymentMethod,
  }) async {
    String endpoint = "add-coin-transaction";

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        '$baseUrl$endpoint',
        options: headers,
        data: {
          "user_id": userId,
          "coin_package_id": coinPackageId,
          "amount": amount,
          "payment_id": paymentId,
          "currency_code": currencyCode,
          "unique_id": "",
          "order_status": orderStatus,
          "order_id": orderId,
          "payment_method": paymentMethod,
        },
      );

      if (response.statusCode == 200) {
        print("Coin transaction added successfully: ${response.data}");
        return true;
      } else {
        print("Failed to add coin transaction: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error in addCoinTransaction: $e");
      return false;
    }
  }

// Rent via Coin API
  Future<PurchaseFromCoinResponse> purchaseFromCoin({
    required String userId,
    required String videoId,
    required String showId,
    required String tokenFrom,
    required String noOfToken,
  }) async {
    String endpoint = "purchase-from-coin";

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        '$baseUrl$endpoint',
        options: headers,
        data: {
          "user_id": userId,
          "video_id": videoId,
          "show_id": showId,
          "token_from": tokenFrom,
          "no_of_token": noOfToken,
        },
      );

      if (response.statusCode == 200) {
        return PurchaseFromCoinResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to purchase via coin");
      }
    } catch (e) {
      print("Error in purchaseFromCoin API: $e");
      rethrow;
    }
  }
}

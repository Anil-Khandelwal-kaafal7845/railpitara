// To parse this JSON data, do
// final sectionListModel = sectionListModelFromJson(jsonString);

import 'dart:convert';

SectionListModel sectionListModelFromJson(String str) =>
    SectionListModel.fromJson(json.decode(str));

String sectionListModelToJson(SectionListModel data) =>
    json.encode(data.toJson());

class SectionListModel {
  SectionListModel({
    this.status,
    this.message,
    this.result,
    this.continueWatching,
  });

  int? status;
  String? message;
  List<Result>? result;
  List<ContinueWatching>? continueWatching;

  factory SectionListModel.fromJson(Map<String, dynamic> json) =>
      SectionListModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
        continueWatching: List<ContinueWatching>.from(json["continue_watching"]
                ?.map((x) => ContinueWatching.fromJson(x)) ??
            []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result != null
            ? List<dynamic>.from(result?.map((x) => x.toJson()) ?? [])
            : [],
        "continue_watching": continueWatching != null
            ? List<dynamic>.from(continueWatching?.map((x) => x.toJson()) ?? [])
            : [],
      };
}

class ContinueWatching {
  int? id;
  int? showId;
  int? sessionId;
  int? videoType;
  String? name;
  String? thumbnail;
  String? landscape;
  String? description;
  int? isPremium;
  String? isTitle;
  int? download;
  String? videoUploadType;
  String? video320;
  String? video480;
  String? video720;
  String? video1080;
  String? videoExtension;
  int? videoDuration;
  String? subtitleType;
  String? subtitleLang1;
  String? subtitle1;
  String? subtitleLang2;
  String? subtitle2;
  String? subtitle3;
  String? subtitleLang3;
  int? view;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? stopTime;
  int? isBuy;
  int? isDownloaded;
  int? isBookmark;
  int? rentBuy;
  int? isRent;
  int? rentPrice;
  String? languageId;
  int? channelId;
  String? categoryId;
  String? categoryName;
  int? typeId;
  String? castId;
  String? trailerType;
  String? trailerUrl;
  String? releaseDate;
  String? releaseYear;
  dynamic imdbRating;
  String? directorId;
  String? starringId;
  String? supportingCastId;
  String? networks;
  String? maturityRating;
  String? ageRestriction;
  String? maxVideoQuality;
  String? releaseTag;
  int? videoSize;
  int? upcomingType;

  ContinueWatching({
    this.id,
    this.showId,
    this.sessionId,
    this.videoType,
    this.name,
    this.thumbnail,
    this.landscape,
    this.description,
    this.isPremium,
    this.isTitle,
    this.download,
    this.videoUploadType,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.videoExtension,
    this.videoDuration,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitle1,
    this.subtitleLang2,
    this.subtitle2,
    this.subtitle3,
    this.subtitleLang3,
    this.view,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.stopTime,
    this.isBuy,
    this.isDownloaded,
    this.isBookmark,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.languageId,
    this.channelId,
    this.categoryId,
    this.categoryName,
    this.typeId,
    this.castId,
    this.trailerType,
    this.trailerUrl,
    this.releaseDate,
    this.releaseYear,
    this.imdbRating,
    this.directorId,
    this.starringId,
    this.supportingCastId,
    this.networks,
    this.maturityRating,
    this.ageRestriction,
    this.maxVideoQuality,
    this.releaseTag,
    this.videoSize,
    this.upcomingType,
  });

  factory ContinueWatching.fromJson(Map<String, dynamic> json) =>
      ContinueWatching(
        id: json["id"],
        showId: json["show_id"],
        sessionId: json["session_id"],
        videoType: json["video_type"],
        name: json["name"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        description: json["description"],
        isPremium: json["is_premium"],
        isTitle: json["is_title"],
        download: json["download"],
        videoUploadType: json["video_upload_type"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        videoExtension: json["video_extension"],
        videoDuration: json["video_duration"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitle1: json["subtitle_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitle2: json["subtitle_2"],
        subtitle3: json["subtitle_3"],
        subtitleLang3: json["subtitle_lang_3"],
        view: json["view"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        stopTime: json["stop_time"],
        isBuy: json["is_buy"],
        isDownloaded: json["is_downloaded"],
        isBookmark: json["is_bookmark"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        languageId: json["language_id"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        categoryName: json["category_name"],
        typeId: json["type_id"],
        castId: json["cast_id"],
        trailerType: json["trailer_type"],
        trailerUrl: json["trailer_url"],
        releaseDate: json["release_date"],
        releaseYear: json["release_year"],
        imdbRating: json["imdb_rating"],
        directorId: json["director_id"],
        starringId: json["starring_id"],
        supportingCastId: json["supporting_cast_id"],
        networks: json["networks"],
        maturityRating: json["maturity_rating"],
        ageRestriction: json["age_restriction"],
        maxVideoQuality: json["max_video_quality"],
        releaseTag: json["release_tag"],
        videoSize: json["video_size"],
        upcomingType: json["upcoming_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "show_id": showId,
        "session_id": sessionId,
        "video_type": videoType,
        "name": name,
        "thumbnail": thumbnail,
        "landscape": landscape,
        "description": description,
        "is_premium": isPremium,
        "is_title": isTitle,
        "download": download,
        "video_upload_type": videoUploadType,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "video_extension": videoExtension,
        "video_duration": videoDuration,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_1": subtitle1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_2": subtitle2,
        "subtitle_3": subtitle3,
        "subtitle_lang_3": subtitleLang3,
        "view": view,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "stop_time": stopTime,
        "is_buy": isBuy,
        "is_downloaded": isDownloaded,
        "is_bookmark": isBookmark,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "language_id": languageId,
        "channel_id": channelId,
        "category_id": categoryId,
        "category_name": categoryName,
        "type_id": typeId,
        "cast_id": castId,
        "trailer_type": trailerType,
        "trailer_url": trailerUrl,
        "release_date": releaseDate,
        "release_year": releaseYear,
        "imdb_rating": imdbRating,
        "director_id": directorId,
        "starring_id": starringId,
        "supporting_cast_id": supportingCastId,
        "networks": networks,
        "maturity_rating": maturityRating,
        "age_restriction": ageRestriction,
        "max_video_quality": maxVideoQuality,
        "release_tag": releaseTag,
        "video_size": videoSize,
        "upcoming_type": upcomingType,
      };
}

class Result {
  int? id;
  int? isHomeScreen;
  int? typeId;
  int? videoType;
  int? upcomingType;
  String? title;
  String? videoId;
  String? screenLayout;
  int? status;
  int? sectionOrder;
  String? createdAt;
  String? updatedAt;
  String? nameVisible;
  List<Datum>? data;
  dynamic bannerOrder;
   String? bannerBacklink;
   int?bannerLinkType;
  dynamic bannerVisible;
  dynamic bannerImage;
  dynamic bannerId;
   int? isTop10;
  Result({
    this.id,
    this.isHomeScreen,
    this.typeId,
    this.videoType,
    this.upcomingType,
    this.title,
    this.videoId,
    this.screenLayout,
    this.status,
    this.bannerLinkType ,
    this.sectionOrder,
    this.createdAt,
    this.updatedAt,
    this.nameVisible,
    this.data,
    this.bannerId,
    this.bannerOrder,
      this.bannerBacklink,
    this.bannerImage,
    this.bannerVisible,
    this.isTop10
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        isHomeScreen: json["is_home_screen"],
        typeId: json["type_id"],
        videoType: json["video_type"],
        upcomingType: json["upcoming_type"],
        title: json["title"],
        videoId: json["video_id"],
        screenLayout: json["screen_layout"],
        status: json["status"],
        sectionOrder: json["section_order"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        bannerLinkType: json["banner_link_type"],
        nameVisible: json["name_visible"],
        data:
            List<Datum>.from(json["data"]?.map((x) => Datum.fromJson(x)) ?? []),
        bannerId: json["banner_id"],
        bannerImage: json["banner_image"],
        bannerVisible: json["banner_visible"],
        bannerOrder: json["banner_order"],
          bannerBacklink: json["banner_backlink"],
             isTop10: json["is_top_10"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_home_screen": isHomeScreen,
        "type_id": typeId,
        "video_type": videoType,
        "upcoming_type": upcomingType,
        "title": title,
        "video_id": videoId,
        "screen_layout": screenLayout,
        "banner_link_type":bannerLinkType ,
        "status": status,
        "section_order": sectionOrder,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "name_visible": nameVisible,
        "data": data == null
            ? []
            : List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
        "banner_image": bannerImage,
        "banner_visible": bannerVisible,
        "banner_order": bannerOrder,
        "banner_backlink": bannerBacklink,
        "banner_id": bannerId,
         "is_top_10": isTop10
      };
}

class Datum {
  int? id;
  String? name;
  String? image;
  int? status;
  int?isLiveUrl;
  String? createdAt;
  String? updatedAt;
  int? channelId;
  String? categoryId;
  String? languageId;
  String? castId;
  int? typeId;
  String? fullWidth;
  int? videoType;
  String? thumbnail;
  String? landscape;
  String? thumbnail1;
  String? landscape1;
  String? trailerType;
  String? trailerUrl;
  String? description;
  int? isPremium;
  String? isTitle;
  String? releaseDate;
  dynamic imdbRating;
  int? view;
  String? directorId;
  String? starringId;
  String? supportingCastId;
  String? networks;
  String? maturityRating;
  String? studios;
  String? contentAdvisory;
  String? viewingRights;
  int? stopTime;
  int? isDownloaded;
  int? isBookmark;
  int? rentBuy;
  int? isRent;
  int? rentPrice;
  int? isBuy;
  String? categoryName;
  String? sessionId;
  int? upcomingType;
  int? download;
  String? videoUploadType;
  String? video320;
  String? video480;
  String? video720;
  String? video1080;
  String? videoExtension;
  int? videoDuration;
  String? nameVisible;
  String? subtitleType;
  String? subtitleLang1;
  String? subtitle1;
  String? subtitleLang2;
  String? subtitle2;
  String? subtitleLang3;
  String? subtitle3;
  String? releaseYear;
  String? ageRestriction;
  String? maxVideoQuality;
  String? releaseTag;
  int? videoSize;

  Datum({
    this.id,
    this.name,
    this.fullWidth,
    this.image,
    this.status,
    this.isLiveUrl ,
    this.createdAt,
    this.updatedAt,
    this.channelId,
    this.categoryId,
    this.languageId,
    this.castId,
    this.typeId,
    this.videoType,
    this.thumbnail,
    this.landscape,
    this.thumbnail1,
    this.landscape1,
    this.trailerType,
    this.trailerUrl,
    this.description,
    this.isPremium,
    this.isTitle,
    this.releaseDate,
    this.view,
    this.imdbRating,
    this.directorId,
    this.starringId,
    this.supportingCastId,
    this.networks,
    this.maturityRating,
    this.studios,
    this.contentAdvisory,
    this.viewingRights,
    this.stopTime,
    this.isDownloaded,
    this.isBookmark,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.isBuy,
    this.categoryName,
    this.sessionId,
    this.upcomingType,
    this.download,
    this.videoUploadType,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.videoExtension,
    this.videoDuration,
    this.nameVisible,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitle1,
    this.subtitleLang2,
    this.subtitle2,
    this.subtitleLang3,
    this.subtitle3,
    this.releaseYear,
    this.ageRestriction,
    this.maxVideoQuality,
    this.releaseTag,
    this.videoSize,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        fullWidth: json["full_width"],
        image: json["image"],
        status: json["status"],
        isLiveUrl: json["is_live_url"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        castId: json["cast_id"],
        typeId: json["type_id"],
        videoType: json["video_type"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        thumbnail1: json["thumbnail_1"],
        landscape1: json["landscape_1"],
        trailerType: json["trailer_type"],
        trailerUrl: json["trailer_url"],
        description: json["description"],
        isPremium: json["is_premium"],
        isTitle: json["is_title"],
        releaseDate: json["release_date"],
        view: json["view"],
        imdbRating: json["imdb_rating"],
        directorId: json["director_id"],
        starringId: json["starring_id"],
        supportingCastId: json["supporting_cast_id"],
        networks: json["networks"],
        maturityRating: json["maturity_rating"],
        studios: json["studios"],
        contentAdvisory: json["content_advisory"],
        viewingRights: json["viewing_rights"],
        stopTime: json["stop_time"],
        isDownloaded: json["is_downloaded"],
        isBookmark: json["is_bookmark"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
        categoryName: json["category_name"],
        sessionId: json["session_id"],
        upcomingType: json["upcoming_type"],
        download: json["download"],
        videoUploadType: json["video_upload_type"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        videoExtension: json["video_extension"],
        videoDuration: json["video_duration"],
        nameVisible: json["name_visible"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitle1: json["subtitle_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitle2: json["subtitle_2"],
        subtitleLang3: json["subtitle_lang_3"],
        subtitle3: json["subtitle_3"],
        releaseYear: json["release_year"],
        ageRestriction: json["age_restriction"],
        maxVideoQuality: json["max_video_quality"],
        releaseTag: json["release_tag"],
        videoSize: json["video_size"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "full_width": fullWidth,
        "is_live_url":isLiveUrl,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_id": channelId,
        "category_id": categoryId,
        "language_id": languageId,
        "cast_id": castId,
        "type_id": typeId,
        "video_type": videoType,
        "thumbnail": thumbnail,
        "landscape": landscape,
         "thumbnail_1": thumbnail1,
        "landscape_1": landscape1,
        "trailer_type": trailerType,
        "trailer_url": trailerUrl,
        "description": description,
        "is_premium": isPremium,
        "is_title": isTitle,
        "release_date": releaseDate,
        "view": view,
        "imdb_rating": imdbRating,
        "director_id": directorId,
        "starring_id": starringId,
        "supporting_cast_id": supportingCastId,
        "networks": networks,
        "maturity_rating": maturityRating,
        "studios": studios,
        "content_advisory": contentAdvisory,
        "viewing_rights": viewingRights,
        "stop_time": stopTime,
        "is_downloaded": isDownloaded,
        "is_bookmark": isBookmark,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
        "category_name": categoryName,
        "session_id": sessionId,
        "upcoming_type": upcomingType,
        "download": download,
        "video_upload_type": videoUploadType,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "video_extension": videoExtension,
        "video_duration": videoDuration,
        "name_visible": nameVisible,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_1": subtitle1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_2": subtitle2,
        "subtitle_lang_3": subtitleLang3,
        "subtitle_3": subtitle3,
        "release_year": releaseYear,
        "age_restriction": ageRestriction,
        "max_video_quality": maxVideoQuality,
        "release_tag": releaseTag,
        "video_size": videoSize,
      };
}
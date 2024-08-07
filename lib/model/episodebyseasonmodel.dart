// To parse this JSON data, do
//
//     final episodeBySeasonModel = episodeBySeasonModelFromJson(jsonString);

import 'dart:convert';

EpisodeBySeasonModel episodeBySeasonModelFromJson(String str) => EpisodeBySeasonModel.fromJson(json.decode(str));

String episodeBySeasonModelToJson(EpisodeBySeasonModel data) => json.encode(data.toJson());

class EpisodeBySeasonModel {
    int? status;
    String? message;
    List<Result>? result;

    EpisodeBySeasonModel({
        this.status,
        this.message,
        this.result,
    });

    factory EpisodeBySeasonModel.fromJson(Map<String, dynamic> json) => EpisodeBySeasonModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    int? id;
    int? showId;
    int? sessionId;
    String? videoType;
    String? name;
    String? thumbnail;
    String? landscape;
    dynamic fullWidth;
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
    String? subtitleLang3;
    String? subtitle3;
    int? view;
    int? status;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? episode;
    dynamic videoLibraryId;
    dynamic urlVideoId;
    int? stopTime;
    int? isDownloaded;
    int? isBookmark;
    int? rentBuy;
    int? isRent;
    int? rentPrice;
    int? isBuy;
    String? categoryName;
    int? upcomingType;

    Result({
        this.id,
        this.showId,
        this.sessionId,
        this.videoType,
        this.name,
        this.thumbnail,
        this.landscape,
        this.fullWidth,
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
        this.subtitleLang3,
        this.subtitle3,
        this.view,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.episode,
        this.videoLibraryId,
        this.urlVideoId,
        this.stopTime,
        this.isDownloaded,
        this.isBookmark,
        this.rentBuy,
        this.isRent,
        this.rentPrice,
        this.isBuy,
        this.categoryName,
        this.upcomingType,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        showId: json["show_id"],
        sessionId: json["session_id"],
        videoType: json["video_type"],
        name: json["name"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        fullWidth: json["full_width"],
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
        subtitleLang3: json["subtitle_lang_3"],
        subtitle3: json["subtitle_3"],
        view: json["view"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        episode: json["episode"],
        videoLibraryId: json["video_library_id"],
        urlVideoId: json["url_video_id"],
        stopTime: json["stop_time"],
        isDownloaded: json["is_downloaded"],
        isBookmark: json["is_bookmark"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
        categoryName: json["category_name"],
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
        "full_width": fullWidth,
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
        "subtitle_lang_3": subtitleLang3,
        "subtitle_3": subtitle3,
        "view": view,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "episode": episode,
        "video_library_id": videoLibraryId,
        "url_video_id": urlVideoId,
        "stop_time": stopTime,
        "is_downloaded": isDownloaded,
        "is_bookmark": isBookmark,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
        "category_name": categoryName,
        "upcoming_type": upcomingType,
    };
}
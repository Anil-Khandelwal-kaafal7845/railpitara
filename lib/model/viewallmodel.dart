import 'package:flutter/cupertino.dart';
class ViewAllModelClass {
  int? status;
  String? message;
  List<Result>? result;
  int? currentPage;
  String? nextPageUrl;
  int? total;

  ViewAllModelClass(
      {this.status,
        this.message,
        this.result,
        this.currentPage,
        this.nextPageUrl,
        this.total});

  ViewAllModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
    currentPage = json['current_page'];
    nextPageUrl = json['next_page_url'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    data['current_page'] = this.currentPage;
    data['next_page_url'] = this.nextPageUrl;
    data['total'] = this.total;
    return data;
  }
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
  int? bannerId;
  int? isTop10;
  Null? ipAddress;
  String? createdAt;
  String? updatedAt;
  String? metaTag;
  String? metaDescription;
  String? nameVisible;
  List<VideoData>? data;

  Result(
      {this.id,
        this.isHomeScreen,
        this.typeId,
        this.videoType,
        this.upcomingType,
        this.title,
        this.videoId,
        this.screenLayout,
        this.status,
        this.sectionOrder,
        this.bannerId,
        this.isTop10,
        this.ipAddress,
        this.createdAt,
        this.updatedAt,
        this.metaTag,
        this.metaDescription,
        this.nameVisible,
        this.data});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isHomeScreen = json['is_home_screen'];
    typeId = json['type_id'];
    videoType = json['video_type'];
    upcomingType = json['upcoming_type'];
    title = json['title'];
    videoId = json['video_id'];
    screenLayout = json['screen_layout'];
    status = json['status'];
    sectionOrder = json['section_order'];
    bannerId = json['banner_id'];
    isTop10 = json['is_top_10'];
    ipAddress = json['ip_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    metaTag = json['meta_tag'];
    metaDescription = json['meta_description'];
    nameVisible = json['name_visible'];
    if (json['data'] != null) {
      data = <VideoData>[];
      json['data'].forEach((v) {
        data!.add(new VideoData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['is_home_screen'] = this.isHomeScreen;
    data['type_id'] = this.typeId;
    data['video_type'] = this.videoType;
    data['upcoming_type'] = this.upcomingType;
    data['title'] = this.title;
    data['video_id'] = this.videoId;
    data['screen_layout'] = this.screenLayout;
    data['status'] = this.status;
    data['section_order'] = this.sectionOrder;
    data['banner_id'] = this.bannerId;
    data['is_top_10'] = this.isTop10;
    data['ip_address'] = this.ipAddress;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['meta_tag'] = this.metaTag;
    data['meta_description'] = this.metaDescription;
    data['name_visible'] = this.nameVisible;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



class VideoData {
  final dynamic id;
  final dynamic channelId;
  final dynamic categoryId;
  final dynamic languageId;
  final dynamic castId;
  final dynamic typeId;
  final dynamic videoType;
  final dynamic name;
  final dynamic thumbnail;
  final dynamic landscape;
  final dynamic fullWidth;
  final dynamic thumbnail1;
  final dynamic landscape1;
  final dynamic trailerType;
  final dynamic trailerUrl;
  final dynamic description;
  final dynamic isPremium;
  final dynamic isTitle;
  final dynamic releaseDate;
  final dynamic view;
  final dynamic imdbRating;
  final dynamic status;
  final dynamic createdAt;
  final dynamic updatedAt;
  final dynamic directorId;
  final dynamic starringId;
  final dynamic supportingCastId;
  final dynamic networks;
  final dynamic maturityRating;
  final dynamic studios;
  final dynamic contentAdvisory;
  final dynamic viewingRights;
  final dynamic nameVisible;
  final dynamic stopTime;
  final dynamic isDownloaded;
  final dynamic isBookmark;
  final dynamic rentBuy;
  final dynamic isRent;
  final dynamic rentPrice;
  final dynamic isBuy;
  final dynamic categoryName;
  final dynamic sessionId;
  final dynamic upcomingType;

  VideoData({
    required this.id,
    required this.channelId,
    required this.categoryId,
    required this.languageId,
    required this.castId,
    required this.typeId,
    required this.videoType,
    required this.name,
    required this.thumbnail,
    required this.landscape,
    required this.fullWidth,
    required this.thumbnail1,
    required this.landscape1,
    required this.trailerType,
    required this.trailerUrl,
    required this.description,
    required this.isPremium,
    required this.isTitle,
    required this.releaseDate,
    required this.view,
    required this.imdbRating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.directorId,
    required this.starringId,
    required this.supportingCastId,
    required this.networks,
    required this.maturityRating,
    required this.studios,
    required this.contentAdvisory,
    required this.viewingRights,
    required this.nameVisible,
    required this.stopTime,
    required this.isDownloaded,
    required this.isBookmark,
    required this.rentBuy,
    required this.isRent,
    required this.rentPrice,
    required this.isBuy,
    required this.categoryName,
    required this.sessionId,
    required this.upcomingType,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'],
      channelId: json['channel_id'],
      categoryId: json['category_id'],
      languageId: json['language_id'],
      castId: json['cast_id'],
      typeId: json['type_id'],
      videoType: json['video_type'],
      name: json['name'],
      thumbnail: json['thumbnail'],
      landscape: json['landscape'],
      fullWidth: json['full_width'],
      thumbnail1: json['thumbnail_1'],
      landscape1: json['landscape_1'],
      trailerType: json['trailer_type'],
      trailerUrl: json['trailer_url'],
      description: json['description'],
      isPremium: json['is_premium'],
      isTitle: json['is_title'],
      releaseDate: json['release_date'],
      view: json['view'],
      imdbRating: json['imdb_rating'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      directorId: json['director_id'],
      starringId: json['starring_id'],
      supportingCastId: json['supporting_cast_id'],
      networks: json['networks'],
      maturityRating: json['maturity_rating'],
      studios: json['studios'],
      contentAdvisory: json['content_advisory'],
      viewingRights: json['viewing_rights'],
      nameVisible: json['name_visible'],
      stopTime: json['stop_time'],
      isDownloaded: json['is_downloaded'],
      isBookmark: json['is_bookmark'],
      rentBuy: json['rent_buy'],
      isRent: json['is_rent'],
      rentPrice: json['rent_price'],
      isBuy: json['is_buy'],
      categoryName: json['category_name'],
      sessionId: json['session_id'],
      upcomingType: json['upcoming_type'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'category_id': categoryId,
      'language_id': languageId,
      'cast_id': castId,
      'type_id': typeId,
      'video_type': videoType,
      'name': name,
      'thumbnail': thumbnail,
      'landscape': landscape,
      'full_width': fullWidth,
      'thumbnail_1': thumbnail1,
      'landscape_1': landscape1,
      'trailer_type': trailerType,
      'trailer_url': trailerUrl,
      'description': description,
      'is_premium': isPremium,
      'is_title': isTitle,
      'release_date': releaseDate,
      'view': view,
      'imdb_rating': imdbRating,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'director_id': directorId,
      'starring_id': starringId,
      'supporting_cast_id': supportingCastId,
      'networks': networks,
      'maturity_rating': maturityRating,
      'studios': studios,
      'content_advisory': contentAdvisory,
      'viewing_rights': viewingRights,
      'name_visible': nameVisible,
      'stop_time': stopTime,
      'is_downloaded': isDownloaded,
      'is_bookmark': isBookmark,
      'rent_buy': rentBuy,
      'is_rent': isRent,
      'rent_price': rentPrice,
      'is_buy': isBuy,
      'category_name': categoryName,
      'session_id': sessionId,
      'upcoming_type': upcomingType,
    };
  }

}
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
}

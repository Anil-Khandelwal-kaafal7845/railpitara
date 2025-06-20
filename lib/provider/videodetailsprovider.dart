import 'package:dtlive/model/sectiondetailmodel.dart';
import 'package:dtlive/model/successmodel.dart';
import 'package:dtlive/provider/watchlistprovider.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

class VideoDetailsProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SectionDetailModel sectionDetailModel = SectionDetailModel();
  String? _lastFetchedVideoId;
  String? _lastFetchedVideoType;
  String? _lastFetchedTypeId;
  String? _lastFetchedUpcomingType;
  bool loading = false;
  String tabClickedOn = "related";

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getSectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    debugPrint("getSectionDetails typeId :========> $typeId");
    debugPrint("getSectionDetails videoType :=====> $videoType");
    debugPrint("getSectionDetails videoId :=======> $videoId");
    debugPrint("getSectionDetails upcomingType :==> $upcomingType");
    // Skip fetch if all identifiers match
    if (_lastFetchedVideoId == videoId.toString() &&
        _lastFetchedVideoType == videoType.toString() &&
        _lastFetchedTypeId == typeId.toString() &&
        _lastFetchedUpcomingType == upcomingType.toString()) {
      debugPrint("Skipped fetching: Already fetched data for this video + upcomingType.");
      return;
    }

    loading = true;
    notifyListeners();
    sectionDetailModel = await ApiService()
        .sectionDetails(typeId, videoType, videoId, upcomingType);
    debugPrint("section_detail status :==> ${sectionDetailModel.status}");
    debugPrint("section_detail message :==> ${sectionDetailModel.message}");
    _lastFetchedVideoId = videoId.toString();
    _lastFetchedVideoType = videoType.toString();
    _lastFetchedTypeId = typeId.toString();
    _lastFetchedUpcomingType = upcomingType.toString();
    loading = false;
    notifyListeners();
  }

  Future<void> setBookMark(
      BuildContext context, typeId, videoType, videoId,WatchlistProvider watchlistProvider,) async {
    if ((sectionDetailModel.result?.isBookmark ?? 0) == 0) {
      sectionDetailModel.result?.isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      sectionDetailModel.result?.isBookmark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    notifyListeners();
    await getAddBookMark(context, typeId, videoType, videoId, watchlistProvider);
    // getAddBookMark(typeId, videoType, videoId,context,watchlistProvider);
  }

  Future<void> getAddBookMark(BuildContext context,typeId, videoType, videoId,WatchlistProvider watchlistProvider) async {
    debugPrint("getAddBookMark typeId :==> $typeId");
    debugPrint("getAddBookMark videoType :==> $videoType");
    debugPrint("getAddBookMark videoId :==> $videoId");
    debugPrint("add bookmark");
    successModel = await ApiService().addRemoveBookmark(typeId, videoType, videoId);
    debugPrint("add_remove_bookmark status :==> ${successModel.status}");
    debugPrint("add_remove_bookmark message :==> ${successModel.message}");
    debugPrint("add remove bookmark");
    if (successModel.status == 200) {
      // Trigger watchlist update after bookmark is added or removed
      // final watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
      await watchlistProvider.getWatchlist(); // refresh the list
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(successModel.message ?? "Bookmark updated")),
      // );
    }

  }

  Future<void> removeFromContinue(videoId, videoType) async {
    sectionDetailModel.result?.stopTime = 0;
    notifyListeners();

    debugPrint("removeFromContinue videoType :==> $videoType");
    debugPrint("removeFromContinue videoId :==> $videoId");
    successModel =
        await ApiService().removeContinueWatching(videoId, videoType);
    debugPrint("removeFromContinue message :==> ${successModel.message}");
  }

  setDownloadComplete(BuildContext context, videoId, videoType, typeId) {
    if ((sectionDetailModel.result?.isDownloaded ?? 0) == 0) {
      sectionDetailModel.result?.isDownloaded = 1;
      Utils.showSnackbar(context, "success", "download_success", true);
    } else {
      sectionDetailModel.result?.isDownloaded = 0;
      Utils.showSnackbar(context, "success", "download_remove_success", true);
    }
    notifyListeners();
    addToDownload(videoId, videoType, typeId);
  }

  Future<void> addToDownload(videoId, videoType, typeId) async {
    debugPrint("addRemoveDownload typeId :==> $typeId");
    debugPrint("addRemoveDownload videoType :==> $videoType");
    debugPrint("addRemoveDownload videoId :==> $videoId");
    await FlutterDownloader.remove(
      taskId: videoId.toString(),
      shouldDeleteContent: true,
    );
    successModel =
        await ApiService().addRemoveDownload(videoId, videoType, typeId, "0");
    debugPrint("addRemoveDownload status :==> ${successModel.status}");
    debugPrint("addRemoveDownload message :==> ${successModel.message}");
  }

  updateRentPurchase() {
    if (sectionDetailModel.result != null) {
      sectionDetailModel.result?.rentBuy = 1;
    }
  }

  updatePrimiumPurchase() {
    if (sectionDetailModel.result != null) {
      sectionDetailModel.result?.isBuy = 1;
    }
  }

  setTabClick(clickedOn) {
    debugPrint("clickedOn ===> $clickedOn");
    tabClickedOn = clickedOn;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("<================ clearProvider ================>");
    sectionDetailModel = SectionDetailModel();
    successModel = SuccessModel();
    tabClickedOn = "related";
    _lastFetchedVideoId = null;
    _lastFetchedVideoType = null;
    _lastFetchedTypeId = null;
    _lastFetchedUpcomingType = null;
  }
}

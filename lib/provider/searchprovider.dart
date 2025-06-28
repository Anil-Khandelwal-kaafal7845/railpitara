

import 'package:dtlive/model/searchmodel.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  SearchModel searchModel = SearchModel();
  // List<Video> searchResults = [];
  List<Video> searchVideoList = [];
  List<Tvshow> searchShowList = [];
  String? searchNextPageUrl;
  bool isFetchingMore = false;
  bool hasMoreData = true;
  String? nextPageUrl;
  bool loading = false, isVideoClick = true, isShowClick = false;
  bool loadingMore = false;

  List<Video> allVideos = [];
  int currentPage = 1;



    Future<void> getSearchVideopagination( searchText, String value, {bool loadMore = false}) async {
      if (isFetchingMore || (!hasMoreData && loadMore)) return;

      isFetchingMore = true;

      if (!loadMore) {
        hasMoreData = true;
        nextPageUrl = null;
        searchVideoList.clear(); // Fresh search
        searchShowList.clear();
        loading = true;
        notifyListeners();
      } else {
        loadingMore = true;
        notifyListeners();
      }

      // notifyListeners();

      try {
        final response = await ApiService().searchVideo(
          searchText,
          nextPageUrl: loadMore ? nextPageUrl : null,
        );

        final newVideos = response.video ?? [];
        final newShow = response.tvshow ?? [];

        // Deduplication based on id
        for (var video in newVideos) {
          if (video.id != null && !searchVideoList.any((v) => v.id == video.id)) {
            searchVideoList.add(video);
          }
        }

        // Deduplication based on id
        for (var tvshow in newShow) {
          if (tvshow.id != null && !searchShowList.any((v) => v.id == tvshow.id)) {
            searchShowList.add(tvshow);
          }
        }

        nextPageUrl = response.nextPageUrl;
        hasMoreData = nextPageUrl != null;

        //  Sync searchModel with updated list
        searchModel = SearchModel(
          status: response.status,
          message: response.message,
          currentPage: response.currentPage,
          nextPageUrl: response.nextPageUrl,
          video: List.from(searchVideoList),
          tvshow: List.from(searchShowList),
          result: [], // Optional
        );
      } catch (e) {
        debugPrint("Pagination error: $e");
      } finally {
        isFetchingMore = false;
        loadingMore = false;
        loading = false;
        notifyListeners();
      }
    }

  // Future<void> getSearchVideopagination(searchText, String value, {bool loadMore = false}) async {
  //   // Avoid multiple simultaneous fetches
  //   if (loadMore && isFetchingMore) return;
  //
  //   if (!loadMore) {
  //     currentPage = 1;
  //     loading = true;
  //     searchVideoList.clear();
  //     searchShowList.clear();
  //     nextPageUrl = null;
  //     hasMoreData = true;
  //   }
  //
  //   isFetchingMore = loadMore;
  //   notifyListeners();
  //
  //   try {
  //     SearchModel  response= await ApiService().searchVideo(searchText,nextPageUrl: loadMore ? nextPageUrl : null);
  //
  //      // ✅ Avoid duplicate video entries by checking IDs
  //      final newVideos = response.video ?? [];
  //      for (var video in newVideos) {
  //        if (!searchVideoList.any((existing) => existing.id == video.id)) {
  //          searchVideoList.add(video);
  //        }
  //      }
  //
  //      // ✅ Similarly, avoid duplicate TV show entries
  //      final newShows = response.tvshow ?? [];
  //      for (var show in newShows) {
  //        if (!searchShowList.any((existing) => existing.id == show.id)) {
  //          searchShowList.add(show);
  //        }
  //      }
  //
  //     nextPageUrl = searchModel.nextPageUrl;
  //     hasMoreData = nextPageUrl != null;
  //   } catch (e) {
  //     debugPrint("Pagination error: $e");
  //     hasMoreData = false;
  //   }
  //
  //   loading = false;
  //   isFetchingMore = false;
  //   notifyListeners();
  // }

  Future<void> getSearchVideo(searchText, String value) async {
    debugPrint("getSearchVideos searchText :==> $searchText");
    loading = true;
    searchModel = await ApiService().searchVideo(searchText);
    debugPrint("search_video status :==> ${searchModel.status}");
    debugPrint("search_video message :==> ${searchModel.message}");
    loading = false;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    debugPrint("setDataVisibility isLoading :==> $isLoading");
    loading = isLoading;
    notifyListeners();
  }

  void setDataVisibility(bool isVideoVisible, bool isShowVisible) {
    debugPrint("setDataVisibility isVideoVisible :==> $isVideoVisible");
    debugPrint("setDataVisibility isShowVisible :==> $isShowVisible");
    isVideoClick = isVideoVisible;
    isShowClick = isShowVisible;
    hasMoreData = true;
    nextPageUrl = null;
    isFetchingMore = false;
    loadingMore = false;
    notifyListeners();
  }

  notifyProvider() {
    notifyListeners();
  }

  clearProvider() {
    debugPrint("============ clearSearchProvider ============");
    searchVideoList.clear();
    searchShowList.clear();
    searchModel = SearchModel();
    nextPageUrl = null;
    isVideoClick = true;
    isShowClick = false;
    hasMoreData = true;
    isFetchingMore = false;
    loading = false;
    loadingMore = false;
  }
}

import 'package:dtlive/model/sectionbannermodel.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/viewallmodel.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:dtlive/model/sectionlistmodel.dart' as listModel;
import 'package:dtlive/model/viewallmodel.dart' as viewall;
class SectionDataProvider extends ChangeNotifier {
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  SectionListModel sectionListModel = SectionListModel();
  ViewAllModelClass viewAllModelClass=ViewAllModelClass();

  List<VideoData> sectionDataList = [];
  // List<VideoData> sectionDataListviewall = [];
  bool loadingBanner = false, loadingSection = false, loadingViewAll = false;
  int? cBannerIndex = 0, lastTabPosition;
  // Pagination state
  int currentPage = 1;
  bool hasMoreData = true;
  bool isFetching = false;
  bool loadingMore = false;

  bool isFetchingviewall = false;
  bool hasMoreDataviewall = true;
  int currentPageviewall = 1;

  List<listModel.Result> allSectionResults = [];
  List<viewall.Result> sectionDataListviewall = [];

  Future<void> getSectionBanner(typeId, isHomePage) async {
    debugPrint("getSectionBanner typeId :==> $typeId");
    debugPrint("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel = await ApiService().sectionBanner(typeId, isHomePage);
    loadingBanner = false;
    notifyListeners();
  }

  setLoading(bool flagLoading) {
    loadingBanner = flagLoading;
    loadingSection = flagLoading;
    loadingViewAll = flagLoading;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  Future<void> getSectionList(typeId, isHomePage, languageId) async {
    debugPrint("getSectionList typeId :==> $typeId");
    debugPrint("getSectionList isHomePage :==> $isHomePage");
    loadingSection = true;
    sectionListModel = await ApiService().sectionList(typeId, isHomePage, languageId);
    loadingSection = false;
    notifyListeners();
  }

  //======================= Section List API with Pagination =====================//
  Future<void> getSectionListpagination(typeId, isHomePage, languageId, {bool loadMore = false}) async {
    debugPrint("getSectionList typeId :==> $typeId");
    debugPrint("getSectionList isHomePage :==> $isHomePage");

    if (isFetching || (!hasMoreData && loadMore)) return;

    isFetching = true;

    if (!loadMore) {
      currentPage = 1;
      hasMoreData = true;
      allSectionResults.clear();
      loadingSection = true;
    }else {
      loadingMore = true;
    }

    // if (!loadMore) loadingSection = true;
    notifyListeners();

    try {
      SectionListModel response = await ApiService().sectionList(typeId, isHomePage, languageId, page: currentPage,);

      if (response.result != null && response.result!.isNotEmpty) {
        allSectionResults.addAll(response.result!);
        currentPage++;
        hasMoreData = response.nextPageUrl != null;
      } else {
        hasMoreData = false;
      }

      sectionListModel = SectionListModel(
        status: response.status,
        message: response.message,
        result: allSectionResults,
        continueWatching: response.continueWatching,
        currentPage: response.currentPage,
        nextPageUrl: response.nextPageUrl,
        total: response.total,
      );
    } catch (e) {
      debugPrint("Pagination error in getSectionList: $e");
    } finally {
      isFetching = false;
      if (loadMore) {
        loadingMore = false;
      } else {
        loadingSection = false;
      }
      notifyListeners();
    }
  }

  // Future<void> getViewAll(String sectionId, {bool loadMore = false}) async {
  //   if (isFetchingviewall || (!hasMoreDataviewall && loadMore)) {
  //     debugPrint("Skipping fetch: isFetching=$isFetchingviewall, hasMore=$hasMoreDataviewall, loadMore=$loadMore");
  //     return;
  //   }
  //   debugPrint("===> getViewAll called with sectionId: $sectionId");
  //
  //   isFetchingviewall = true;
  //   // loadingViewAll = true;
  //
  //   if (!loadMore) {
  //     loadingViewAll = true;
  //     currentPageviewall;
  //     sectionDataListviewall.clear();
  //     debugPrint("Clearing sectionDataList and setting currentPage to 1");
  //   }
  //
  //   try {
  //     debugPrint("Calling ApiService().viewAll...");
  //     final ViewAllModelClass response = await ApiService().viewAll(sectionId, currentPageviewall);
  //     debugPrint("Received response: currentPage=${response.currentPage}, ");
  //     for (final result in response.result ?? []) {
  //       sectionDataListviewall.addAll(result.data ?? []);
  //     }
  //     currentPageviewall += 1;
  //     hasMoreDataviewall = response.nextPageUrl?.isNotEmpty ?? false;
  //
  //     debugPrint("hasMoreData: $hasMoreData, currentPage: $currentPage");
  //     debugPrint("Updated list length: ${sectionDataList.length}");
  //     debugPrint("Next page available? $hasMoreData");
  //   } catch (e, stacktrace) {
  //     debugPrint("Error loading view all: $e");
  //     debugPrint("Stacktrace: $stacktrace");
  //   } finally {
  //     isFetchingviewall = false;
  //     loadingViewAll = false;
  //     notifyListeners();
  //     debugPrint("===> notifyListeners called");
  //   }
  // }
  //
///
  Future<void> getViewallpagination(String sectionId, {bool loadMore = false}) async {

    if (isFetchingviewall || (!hasMoreDataviewall && loadMore)) return;

    isFetchingviewall = true;

    if (!loadMore) {
      currentPageviewall = 1;
      hasMoreDataviewall = true;
      sectionDataListviewall.clear();
       // loadingSection = true;
      loadingViewAll = true;
    }else {
      loadingMore = true;
    }

    // if (!loadMore) loadingSection = true;
    notifyListeners();

    try {
      ViewAllModelClass response = await ApiService().viewAll(sectionId, currentPageviewall);

      if (response.result != null && response.result!.isNotEmpty) {
        sectionDataListviewall.addAll(response.result!);
        currentPageviewall++;
        hasMoreDataviewall = response.nextPageUrl != null;
      } else {
        hasMoreData = false;
      }

      viewAllModelClass = ViewAllModelClass(
        status: response.status,
        message: response.message,
        result: sectionDataListviewall,
        currentPage: response.currentPage,
        nextPageUrl: response.nextPageUrl,
        total: response.total,
      );

    } catch (e) {
      debugPrint("Pagination error in getSectionList: $e");
    } finally {
      isFetchingviewall = false;
      if (loadMore) {
        loadingMore = false;
      } else {
        // loadingSection = false;
        loadingViewAll = false;
      }
      notifyListeners();
    }
  }

  // Future<void> getAllViewAllData(String sectionId) async {
  //   loadingViewAll = true;
  //   sectionDataListviewall.clear(); // Start fresh
  //   notifyListeners();
  //
  //   try {
  //     // Call the API without pagination parameters
  //     ViewAllModelClass response = await ApiService().viewAll(sectionId, 1);
  //
  //     if (response.result != null && response.result!.isNotEmpty) {
  //       sectionDataListviewall.addAll(response.result!);
  //     }
  //
  //     viewAllModelClass = ViewAllModelClass(
  //       status: response.status,
  //       message: response.message,
  //       result: sectionDataListviewall,
  //       currentPage: response.currentPage,
  //       nextPageUrl: response.nextPageUrl,
  //       total: response.total,
  //     );
  //   } catch (e) {
  //     debugPrint("Error loading all view all data: $e");
  //   } finally {
  //     loadingViewAll = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> getViewAll(String sectionId) async {
  //   debugPrint("getViewAll sectionId :==> $sectionId");
  //   loadingViewAll = true;
  //   sectionDataList = await ApiService().viewAll(sectionId);
  //   loadingViewAll = false;
  //   notifyListeners();
  // }

  clearProvider() {
    debugPrint("<================ clearProvider ================>");
    loadingBanner = false;
    loadingSection = false;
    loadingViewAll = false;
    sectionBannerModel = SectionBannerModel();
    sectionListModel = SectionListModel();
    sectionDataList = [];
    cBannerIndex = 0;
    lastTabPosition = 0;
  }
  void clearSections() {
    sectionListModel = SectionListModel();
    allSectionResults.clear();
    currentPage = 1;
    hasMoreData = true;
    isFetching = false;
    loadingMore = false;
    loadingSection = false;
    notifyListeners();
  }

}

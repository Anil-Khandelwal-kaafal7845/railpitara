import 'package:dtlive/model/sectionbannermodel.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/viewallmodel.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SectionDataProvider extends ChangeNotifier {
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  SectionListModel sectionListModel = SectionListModel();
  List<VideoData> sectionDataList = [];

  bool loadingBanner = false, loadingSection = false, loadingViewAll = false;
  int? cBannerIndex = 0, lastTabPosition;

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

  Future<void> getViewAll(String sectionId) async {
    debugPrint("getViewAll sectionId :==> $sectionId");
    loadingViewAll = true;
    sectionDataList = await ApiService().viewAll(sectionId);
    loadingViewAll = false;
    notifyListeners();
  }

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
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:dukan_user_app/api/api_client.dart';
import 'package:dukan_user_app/api/local_client.dart';
import 'package:dukan_user_app/common/enums/data_source_enum.dart';
import 'package:dukan_user_app/features/banner/domain/models/banner_model.dart';
import 'package:dukan_user_app/features/banner/domain/models/others_banner_model.dart';
import 'package:dukan_user_app/features/banner/domain/models/promotional_banner_model.dart';
import 'package:dukan_user_app/features/banner/domain/repositories/banner_repository_interface.dart';
import 'package:dukan_user_app/features/splash/controllers/splash_controller.dart';
import 'package:dukan_user_app/helper/header_helper.dart';
import 'package:dukan_user_app/util/app_constants.dart';

class BannerRepository implements BannerRepositoryInterface {
  final ApiClient apiClient;
  BannerRepository({required this.apiClient});

  @override
  Future getList({int? offset, bool isBanner = false, bool isTaxiBanner = false, bool isFeaturedBanner = false, bool isParcelOtherBanner = false, bool isPromotionalBanner = false, DataSourceEnum? source}) async {
    if (isBanner) {
      return await _getBannerList(source: source!);
    } else if (isTaxiBanner) {
      return await _getTaxiBannerList();
    } else if (isFeaturedBanner) {
      return await _getFeaturedBannerList();
    } else if (isParcelOtherBanner) {
      return await _getParcelOtherBannerList();
    } else if (isPromotionalBanner) {
      return await _getPromotionalBannerList();
    }
  }

  Future<BannerModel?> _getBannerList({required DataSourceEnum source}) async {
    BannerModel? bannerModel;
    String cacheId = '${AppConstants.bannerUri}-${Get.find<SplashController>().module!.id!}';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.bannerUri);
        if (response.statusCode == 200) {
          bannerModel = BannerModel.fromJson(response.body);
          LocalClient.organize(source, cacheId, jsonEncode(response.body), apiClient.getHeader());

        }
      case DataSourceEnum.local:

        String? cacheResponseData = await LocalClient.organize(source, cacheId, null, null);
        if(cacheResponseData != null) {
          bannerModel = BannerModel.fromJson(jsonDecode(cacheResponseData));
        }
    }


    return bannerModel;
  }

  Future<BannerModel?> _getTaxiBannerList() async {
    BannerModel? bannerModel;
    Response response = await apiClient.getData(AppConstants.taxiBannerUri);
    if (response.statusCode == 200) {
      bannerModel = BannerModel.fromJson(response.body);
    }
    return bannerModel;
  }

  Future<BannerModel?> _getFeaturedBannerList() async {
    BannerModel? bannerModel;
    Response response = await apiClient.getData('${AppConstants.bannerUri}?featured=1', headers: HeaderHelper.featuredHeader());
    if (response.statusCode == 200) {
      bannerModel = BannerModel.fromJson(response.body);
    }
    return bannerModel;
  }

  Future<ParcelOtherBannerModel?> _getParcelOtherBannerList() async {
    ParcelOtherBannerModel? parcelOtherBannerModel;
    Response response = await apiClient.getData(AppConstants.parcelOtherBannerUri);
    if (response.statusCode == 200) {
      parcelOtherBannerModel = ParcelOtherBannerModel.fromJson(response.body);
    }
    return parcelOtherBannerModel;
  }

  Future<PromotionalBanner?> _getPromotionalBannerList() async {
    PromotionalBanner? promotionalBanner;
    Response response = await apiClient.getData(AppConstants.promotionalBannerUri);
    if (response.statusCode == 200 && response.body is Map) {
      promotionalBanner = PromotionalBanner.fromJson(response.body);
    }
    return promotionalBanner;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}
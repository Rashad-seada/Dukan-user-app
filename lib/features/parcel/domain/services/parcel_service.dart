import 'package:get/get_connect/http/src/response/response.dart';
import 'package:dukan_user_app/common/enums/data_source_enum.dart';
import 'package:dukan_user_app/features/checkout/domain/models/place_order_body_model.dart';
import 'package:dukan_user_app/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:dukan_user_app/features/parcel/domain/models/parcel_category_model.dart';
import 'package:dukan_user_app/features/parcel/domain/models/video_content_model.dart';
import 'package:dukan_user_app/features/parcel/domain/models/why_choose_model.dart';
import 'package:dukan_user_app/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:dukan_user_app/features/parcel/domain/services/parcel_service_interface.dart';
import 'package:dukan_user_app/features/payment/domain/models/offline_method_model.dart';

import '../models/parcel_instruction_model.dart';

class ParcelService implements ParcelServiceInterface{
  final ParcelRepositoryInterface parcelRepositoryInterface;
  final CheckoutRepositoryInterface checkoutRepositoryInterface;
  ParcelService({required this.parcelRepositoryInterface, required this.checkoutRepositoryInterface});

  @override
  Future<List<ParcelCategoryModel>?> getParcelCategory() async {
    return await parcelRepositoryInterface.getList();
  }

  @override
  Future<List<Data>?> getParcelInstruction(int offset) async {
    return await parcelRepositoryInterface.getList(offset: offset, parcelCategory: false);
  }

  @override
  Future<WhyChooseModel?> getWhyChooseDetails({required DataSourceEnum source}) async {
    return await parcelRepositoryInterface.get(null, isVideoDetails: false, source: source);
  }

  @override
  Future<VideoContentModel?> getVideoContentDetails({required DataSourceEnum source}) async {
    return await parcelRepositoryInterface.get(null, isVideoDetails: true, source: source);
  }

  @override
  Future<Response> getPlaceDetails(String? placeID) async {
    return await parcelRepositoryInterface.getPlaceDetails(placeID);
  }

  @override
  Future<List<OfflineMethodModel>?> getOfflineMethodList() async {
    return await checkoutRepositoryInterface.getList();
  }

  @override
  Future<int> getDmTipMostTapped() async {
    return await checkoutRepositoryInterface.getDmTipMostTapped();
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody) async {
    return await checkoutRepositoryInterface.placeOrder(orderBody, null);
  }

}
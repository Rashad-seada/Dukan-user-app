import 'package:get/get_connect/http/src/response/response.dart';
import 'package:dukan_user_app/common/enums/data_source_enum.dart';
import 'package:dukan_user_app/interfaces/repository_interface.dart';

abstract class ParcelRepositoryInterface<T> implements RepositoryInterface {
  @override
  Future get(String? id, {bool isVideoDetails = true, DataSourceEnum source});
  @override
  Future getList({int? offset, bool parcelCategory = true});
  Future<Response> getPlaceDetails(String? placeID);
}
import 'package:get/get_connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dukan_user_app/common/models/module_model.dart';
import 'package:dukan_user_app/features/business/domain/models/package_model.dart';
import 'package:dukan_user_app/features/location/domain/models/zone_data_model.dart';
import 'package:dukan_user_app/features/auth/domain/models/store_body_model.dart';

abstract class StoreRegistrationServiceInterface{
  Future<List<ZoneDataModel>?> getZoneList();
  int? prepareSelectedZoneIndex(List<int>? zoneIds, List<ZoneDataModel>? zoneList);
  Future<List<ModuleModel>?> getModules(int? zoneId);
  Future<Response> registerStore(StoreBodyModel store, XFile? logo, XFile? cover);
  Future<bool> checkInZone(String? lat, String? lng, int zoneId);
  Future<PackageModel?> getPackageList();
}
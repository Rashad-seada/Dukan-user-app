import 'package:dukan_user_app/common/enums/data_source_enum.dart';
import 'package:dukan_user_app/features/home/domain/models/advertisement_model.dart';

abstract class AdvertisementServiceInterface {
  Future<List<AdvertisementModel>?> getAdvertisementList(DataSourceEnum source);
}
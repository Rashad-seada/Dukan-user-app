import 'package:dukan_user_app/common/enums/data_source_enum.dart';
import 'package:dukan_user_app/interfaces/repository_interface.dart';

abstract class FlashSaleRepositoryInterface<T> implements RepositoryInterface {
  Future<dynamic> getFlashSale({required DataSourceEnum source});
  Future<dynamic> getFlashSaleWithId(int id, int offset);
}
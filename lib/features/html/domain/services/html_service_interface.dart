import 'package:get/get.dart';
import 'package:dukan_user_app/util/html_type.dart';

abstract class HtmlServiceInterface{
  Future<Response> getHtmlText(HtmlType htmlType);
}
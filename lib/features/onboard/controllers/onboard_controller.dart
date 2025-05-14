import 'package:dukan_user_app/features/onboard/domain/models/onboarding_model.dart';
import 'package:get/get.dart';
import 'package:dukan_user_app/features/onboard/domain/service/onboard_service_interface.dart';
import 'package:dukan_user_app/util/images.dart';

class OnBoardingController extends GetxController implements GetxService {
  final OnboardServiceInterface onboardServiceInterface;
  OnBoardingController({required this.onboardServiceInterface});

  List<OnBoardingModel> _onBoardingList = [];
  List<OnBoardingModel> get onBoardingList => _onBoardingList;
  List<String> onBoardImages = [Images.favoriteItemImage,Images.easyPayment,Images.fastDelivery];
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void changeSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void getOnBoardingList() async {
    Response response = await onboardServiceInterface.getOnBoardingList();
    if (response.statusCode == 200) {
      _onBoardingList = [];
      _onBoardingList.addAll(response.body);
      _onBoardingList.add(OnBoardingModel('', '', ''));
    }
    update();
  }

}
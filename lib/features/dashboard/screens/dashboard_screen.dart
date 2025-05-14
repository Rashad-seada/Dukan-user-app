import 'dart:async';
import 'dart:io';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dukan_user_app/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:dukan_user_app/features/home/controllers/home_controller.dart';
import 'package:dukan_user_app/features/location/controllers/location_controller.dart';
import 'package:dukan_user_app/features/splash/controllers/splash_controller.dart';
import 'package:dukan_user_app/features/order/controllers/order_controller.dart';
import 'package:dukan_user_app/features/order/domain/models/order_model.dart';
import 'package:dukan_user_app/features/address/screens/address_screen.dart';
import 'package:dukan_user_app/features/auth/controllers/auth_controller.dart';
import 'package:dukan_user_app/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:dukan_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:dukan_user_app/features/store/controllers/store_controller.dart';
import 'package:dukan_user_app/helper/auth_helper.dart';
import 'package:dukan_user_app/helper/responsive_helper.dart';
import 'package:dukan_user_app/helper/route_helper.dart';
import 'package:dukan_user_app/util/dimensions.dart';
import 'package:dukan_user_app/util/images.dart';
import 'package:dukan_user_app/common/widgets/cart_widget.dart';
import 'package:dukan_user_app/common/widgets/custom_dialog.dart';
import 'package:dukan_user_app/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:dukan_user_app/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:dukan_user_app/features/dashboard/widgets/parcel_bottom_sheet_widget.dart';
import 'package:dukan_user_app/features/favourite/screens/favourite_screen.dart';
import 'package:dukan_user_app/features/home/screens/home_screen.dart';
import 'package:dukan_user_app/features/menu/screens/menu_screen.dart';
import 'package:dukan_user_app/features/order/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/styles.dart';
import '../widgets/running_order_view_widget.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
          Get.find<AuthController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
            const Duration(seconds: 1),
            () => showAnimatedDialog(
                Get.context!, const CongratulationDialogue()));
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const FavouriteScreen(),
      const SizedBox(),
      const OrderScreen(),
      const MenuScreen()
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
        Get.find<HomeController>().getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(
                    const Dialog(child: StoreRegistrationSuccessBottomSheet()))
                .then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              })
            : showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const StoreRegistrationSuccessBottomSheet(),
              ).then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              });
      });
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return GetBuilder<SplashController>(builder: (splashController) {
      bool isParcel = splashController.module != null &&
          splashController.configModel!.moduleConfig!.module!.isParcel!;
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (_pageIndex != 0) {
            _setPage(0);
          } else {
            if (!ResponsiveHelper.isDesktop(context) &&
                Get.find<SplashController>().module != null &&
                Get.find<SplashController>().configModel!.module == null) {
              Get.find<SplashController>().setModule(null);
              Get.find<StoreController>().resetStoreData();
            } else {
              if (_canExit) {
                if (GetPlatform.isAndroid) {
                  SystemNavigator.pop();
                } else if (GetPlatform.isIOS) {
                  exit(0);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('back_press_again_to_exit'.tr,
                      style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));
                _canExit = true;
                Timer(const Duration(seconds: 2), () {
                  _canExit = false;
                });
              }
            }
          }
        },
        child: GetBuilder<OrderController>(builder: (orderController) {
          List<OrderModel> runningOrder =
              orderController.runningOrderModel != null
                  ? orderController.runningOrderModel!.orders!
                  : [];

          List<OrderModel> reversOrder = List.from(runningOrder.reversed);

          return Scaffold(
              key: _scaffoldKey,
              body: ExpandableBottomSheet(
                background: Stack(children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _screens.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _screens[index];
                    },
                  ),
                  ResponsiveHelper.isDesktop(context) || keyboardVisible
                      ? const SizedBox()
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: GetBuilder<SplashController>(
                              builder: (splashController) {
                            bool isParcel = splashController.module != null &&
                                splashController.configModel!.moduleConfig!
                                    .module!.isParcel!;

                            _screens = [
                              const HomeScreen(),
                              isParcel
                                  ? const AddressScreen(fromDashboard: true)
                                  : const FavouriteScreen(),
                              const SizedBox(),
                              const OrderScreen(),
                              const MenuScreen()
                            ];
                            return Container(
                              // width: size.width,
                              // height: GetPlatform.isIOS ? 80 : 65,
                              //  decoration: BoxDecoration(
                              //    color: Theme.of(context).cardColor,
                              //    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                              //      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                              //  ),
                              child: Stack(
                                children: [
                                  //floating action button
                                  // Center(
                                  //   heightFactor: 0.6,
                                  //   child: ResponsiveHelper.isDesktop(context) ? null : (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) ? null
                                  //     : (orderController.showBottomSheet && orderController.runningOrderModel != null && orderController.runningOrderModel!.orders!.isNotEmpty && _isLogin) ? const SizedBox()
                                  //       : Container(
                                  //       width: 60, height: 60,
                                  //       decoration: BoxDecoration(
                                  //         border: Border.all(color: Theme.of(context).cardColor, width: 5),
                                  //         borderRadius: BorderRadius.circular(30),
                                  //         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                  //       ),
                                  //       child: FloatingActionButton(
                                  //         backgroundColor: Theme.of(context).primaryColor,
                                  //         onPressed: () {
                                  //           if(isParcel) {
                                  //             showModalBottomSheet(
                                  //               context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                  //               builder: (con) => ParcelBottomSheetWidget(parcelCategoryList: Get.find<ParcelController>().parcelCategoryList),
                                  //             );
                                  //           } else {
                                  //             Get.toNamed(RouteHelper.getCartRoute());
                                  //           }
                                  //         },
                                  //         elevation: 0,
                                  //         child: isParcel ? Icon(CupertinoIcons.add, size: 34, color: Theme.of(context).cardColor) : CartWidget(color: Theme.of(context).cardColor, size: 22),
                                  //       ),
                                  //   ),
                                  // ),
                                  //icons on the bottom nav bar
                                  // ResponsiveHelper.isDesktop(context) ? const SizedBox()
                                  //     : (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active)
                                  //     ? const SizedBox()
                                  // : (orderController.showBottomSheet && orderController.runningOrderModel != null && orderController.runningOrderModel!.orders!.isNotEmpty && _isLogin)
                                  //     ? const SizedBox()
                                  //     : Center(
                                  //   child: SizedBox(
                                  //       width: size.width, height: 80,
                                  //       child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                  //         BottomNavItemWidget(
                                  //           title: 'home'.tr, selectedIcon: Images.homeSelect,
                                  //           unSelectedIcon: Images.homeUnselect, isSelected: _pageIndex == 0,
                                  //           onTap: () => _setPage(0),
                                  //         ),
                                  //         BottomNavItemWidget(
                                  //           title: isParcel ? 'address'.tr : 'favourite'.tr,
                                  //           selectedIcon: isParcel ? Images.addressSelect : Images.favouriteSelect,
                                  //           unSelectedIcon: isParcel ? Images.addressUnselect : Images.favouriteUnselect,
                                  //           isSelected: _pageIndex == 1, onTap: () => _setPage(1),
                                  //         ),
                                  //         Container(width: size.width * 0.2),
                                  //         BottomNavItemWidget(
                                  //           title: 'orders'.tr, selectedIcon: Images.orderSelect, unSelectedIcon: Images.orderUnselect,
                                  //           isSelected: _pageIndex == 3, onTap: () => _setPage(3),
                                  //         ),
                                  //         BottomNavItemWidget(
                                  //           title: 'menu'.tr, selectedIcon: Images.menu, unSelectedIcon: Images.menu,
                                  //           isSelected: _pageIndex == 4, onTap: () => _setPage(4),
                                  //         ),
                                  //       ]),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          }),
                        ),
                ]),
                persistentContentHeight: (widget.fromSplash &&
                        Get.find<LocationController>().showLocationSuggestion &&
                        active)
                    ? 0
                    : GetPlatform.isIOS
                        ? 110
                        : 100,
                onIsContractedCallback: () {
                  if (!orderController.showOneOrder) {
                    orderController.showOrders();
                  }
                },
                onIsExtendedCallback: () {
                  if (orderController.showOneOrder) {
                    orderController.showOrders();
                  }
                },
                enableToggle: true,
                expandableContent: (widget.fromSplash &&
                        Get.find<LocationController>().showLocationSuggestion &&
                        active &&
                        !ResponsiveHelper.isDesktop(context))
                    ? const SizedBox()
                    : (ResponsiveHelper.isDesktop(context) ||
                            !_isLogin ||
                            orderController.runningOrderModel == null ||
                            orderController
                                .runningOrderModel!.orders!.isEmpty ||
                            !orderController.showBottomSheet)
                        ? const SizedBox()
                        : Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              if (orderController.showBottomSheet) {
                                orderController.showRunningOrders();
                              }
                            },
                            child: RunningOrderViewWidget(
                                reversOrder: reversOrder,
                                onOrderTap: () {
                                  _setPage(3);
                                  if (orderController.showBottomSheet) {
                                    orderController.showRunningOrders();
                                  }
                                }),
                          ),
              ),
              bottomNavigationBar: NavigationBar(
                  onDestinationSelected: (index) {
                    _pageIndex = index;
                    if (index == 0) {
                      _setPage(0);
                    } else if (index == 1) {
                      _setPage(1);
                    } else if (index == 3) {
                      _setPage(3);
                    } else if (index == 4) {
                      _setPage(4);
                    }
                    print(_pageIndex);
                  },
                  indicatorColor: Colors.transparent,
                  selectedIndex: _pageIndex,
                  destinations: [
                    NavigationDestination(
                      icon: Image.asset(
                        Images.homeSelect,
                        scale: 4,
                        color: _pageIndex == 0 ? Colors.red : Colors.black,
                      ),
                      label: "Home".tr,
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        Images.favouriteSelect,
                        scale: 4,
                        color: _pageIndex == 1 ? Colors.red : Colors.black,
                      ),
                      label: "Favourite".tr,
                    ),
                    Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).cardColor, width: 5),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1)
                        ],
                      ),
                      child: FloatingActionButton(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          if (isParcel) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (con) => ParcelBottomSheetWidget(
                                  parcelCategoryList:
                                      Get.find<ParcelController>()
                                          .parcelCategoryList),
                            );
                          } else {
                            Get.toNamed(RouteHelper.getCartRoute());
                          }
                        },
                        // elevation: 0,
                        child: isParcel
                            ? Icon(CupertinoIcons.add,
                                size: 34, color: Theme.of(context).cardColor)
                            : CartWidget(
                                color: Theme.of(context).cardColor, size: 22),
                      ),
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        Images.orderSelect,
                        scale: 4,
                        color: _pageIndex == 3 ? Colors.red : Colors.black,
                      ),
                      label: "Orders".tr,
                    ),
                    NavigationDestination(
                      icon: Image.asset(
                        Images.menu,
                        scale: 4,
                        color: _pageIndex == 4 ? Colors.red : Colors.black,
                      ),
                      label: "Menu".tr,
                    )
                  ])
              //
              );
        }),
      );
    });
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}

// SizedBox(
// width:size.width,height: 80,
// child: BottomNavigationBar(
// currentIndex: _pageIndex,
// onTap: (index){
// _pageIndex = index;
// if(index == 0){
// _setPage(0);
// }else if (index == 1){
// _setPage(1);
// }else if (index == 2){
// _setPage(2);
// }else if(index == 3){
// _setPage(3);
// }
// print(_pageIndex);
// },
// selectedItemColor:Colors.red ,
// unselectedItemColor: Colors.black,
// showUnselectedLabels: true,
// selectedLabelStyle: TextStyle(fontFamily: "$robotoRegular",fontSize: 12) ,
// unselectedLabelStyle:TextStyle(fontFamily: "$robotoRegular",fontSize: 12) ,
// items: [
// BottomNavigationBarItem(
// icon: Image.asset(Images.homeSelect,
// scale: 4,
// color:_pageIndex == 0 ? Colors.red:Colors.black ,),
// label: 'home'.tr,),
// BottomNavigationBarItem(
// icon: Image.asset(Images.favouriteSelect,
// scale: 4,
// color:_pageIndex == 1 ? Colors.red:Colors.black ,),
// label: 'favorite'.tr),
// BottomNavigationBarItem(
// icon: Image.asset(Images.orderSelect,
// scale: 4,
// color:_pageIndex == 2 ? Colors.red:Colors.black ,),
// label: 'orders'.tr),
// BottomNavigationBarItem(
// icon: Image.asset(Images.menu,
// scale: 4,
// color:_pageIndex == 3 ? Colors.red:Colors.black ,),
// label: 'menu'.tr
// )
// ]),
// )

//BottomAppBar(
//     notchMargin: 10,
//     elevation: 10,
//     shape: CircularNotchedRectangle(),
//     color: Theme.of(context).cardColor,
//     child: ResponsiveHelper.isDesktop(context) ? const SizedBox()
//     : (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active)
// ? const SizedBox()
//     : (orderController.showBottomSheet && orderController.runningOrderModel != null && orderController.runningOrderModel!.orders!.isNotEmpty && _isLogin)
// ? const SizedBox()
//     : Center(
// child: SizedBox(
// width: size.width, height: 80,
// child: Row(
//     children: [
//       BottomNavItemWidget(
//             title: 'home'.tr, selectedIcon: Images.homeSelect,
//             unSelectedIcon: Images.homeUnselect, isSelected: _pageIndex == 0,
//             onTap: () => _setPage(0),
//           ),
//       BottomNavItemWidget(
//                 title: isParcel ? 'address'.tr : 'favourite'.tr,
//                 selectedIcon: isParcel ? Images.addressSelect : Images.favouriteSelect,
//                 unSelectedIcon: isParcel ? Images.addressUnselect : Images.favouriteUnselect,
//                 isSelected: _pageIndex == 1, onTap: () => _setPage(1),
//               ),
//       // ResponsiveHelper.isDesktop(context) ? null : (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) ? null
//       //     : (orderController.showBottomSheet && orderController.runningOrderModel != null && orderController.runningOrderModel!.orders!.isNotEmpty && _isLogin) ? const SizedBox()
//       //     :
//       Container(
//         width: 60, height: 60,
//         decoration: BoxDecoration(
//           border: Border.all(color: Theme.of(context).cardColor, width: 5),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//         ),
//         child: FloatingActionButton(
//           backgroundColor: Theme.of(context).primaryColor,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           onPressed: () {
//             bool isM3 = Theme.of(context).useMaterial3;
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("mataria3 : $isM3" )));
//             if(isParcel) {
//               showModalBottomSheet(
//                 context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
//                 builder: (con) => ParcelBottomSheetWidget(parcelCategoryList: Get.find<ParcelController>().parcelCategoryList),
//               );
//             } else {
//               Get.toNamed(RouteHelper.getCartRoute());
//             }
//           },
//           // elevation: 0,
//           child: isParcel ? Icon(CupertinoIcons.add, size: 34, color: Theme.of(context).cardColor)
//               : CartWidget(color: Theme.of(context).cardColor, size: 22),
//         ),
//       ),
//
//       BottomNavItemWidget(
//                 title: 'orders'.tr, selectedIcon: Images.orderSelect, unSelectedIcon: Images.orderUnselect,
//                 isSelected: _pageIndex == 3, onTap: () => _setPage(3),
//               ),
//               BottomNavItemWidget(
//                 title: 'menu'.tr, selectedIcon: Images.menu, unSelectedIcon: Images.menu,
//                 isSelected: _pageIndex == 4, onTap: () => _setPage(4),
//               ),
//
// ]
// )
// )
//     )
//   ) ,

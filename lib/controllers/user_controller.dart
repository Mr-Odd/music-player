/*
 * @Creator: Odd
 * @Date: 2022-04-12 16:31:35
 * @LastEditTime: 2022-04-18 20:55:56
 * @FilePath: \flutter_easymusic\lib\controllers\user_controller.dart
 */
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easymusic/api/user_api.dart';
import 'package:flutter_easymusic/models/user.dart';
import 'package:flutter_easymusic/pages/routes/app_routes.dart';
import 'package:flutter_easymusic/services/user_state.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {

  final userState = Get.find<UserState>();

  var hasSend = false.obs;
  var ready2Send = true.obs;

  late Timer _timer;
  var timeCounter = 60.obs;

  final pc = TextEditingController(); // phone controller
  final cc = TextEditingController(); // captcha controller

  final box = GetStorage();

  @override
  void onInit() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
    super.onInit();
  }

  //使用手机号和验证码登录
  void login() async {
    //先检验验证码的有效性
    if (!RegExp(r'^\d{4,}$').hasMatch(cc.text)) {
      Get.snackbar('提示', '验证码错误！');
      return;
    }

    var data = await UserApi.login(pc.text, cc.text);
    if (data['code'] == 200) {
      User u = User.fromJson(data);
      userState.user.value = u;
      await box.write('user', u); //持久化
      userState.isLogin.value = true;

      //回到主页
      Get.offAllNamed('/home');
    } else {
      if (data['message'] != null) {
        Get.snackbar('提示', data['message']);
      }
    }
  }

  //向该手机号发送验证码
  void sendCaptcha() async {
    // if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
    //     .hasMatch(phone)) {
    //   Get.snackbar('提示', '请输入正确的手机号码');
    //   return;
    // }

    hasSend.value = true;

    ready2Send.value = false;

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      timeCounter.value -= 1;
      if (timeCounter.value == 0) {
        _timer.cancel();
        timeCounter.value = 60;
        ready2Send.value = true;
      }
    });

    var res = await UserApi.sendCapcha(pc.text);
    if (res['code'] == 400) {
      Get.snackbar('提示', res['message']);
    }
  }

  //自动登录
  void autoLogin() async {
    var d = box.read('user');
    if (d != null) {
      User u = User.fromBox(box.read('user'));
      //检查cookie是否过期
      var data = await UserApi.checkLoginStatus(u.cookie);
      if (data['data']['code'] == 200) {
        //验证成功
        userState.user.value = u;
        userState.isLogin.value = true;
        Get.offAllNamed(AppRoutes.home);
      }else{
        //验证失败
        await box.remove('user');
        Get.snackbar('提示', '请重新登录');
        Get.toNamed('/login');
      }
    }else{
      Get.snackbar('提示', '请登录');
      Get.toNamed('/login');
    }
  }

  @override
  void onClose() {
    log(runtimeType.toString() + ' closed');
    _timer.cancel();
    pc.dispose();
    cc.dispose();
    super.onClose();
  }
}

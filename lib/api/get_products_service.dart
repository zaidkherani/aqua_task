import 'dart:convert';
import 'package:aqua_task/models/products_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiEndpoints.dart';
import 'api_provider.dart';
import '../helpers/helper_file.dart';
import 'network_error.dart';

class ProductProvider extends ChangeNotifier{

  List data = [];
  ApiStatus status = ApiStatus.Stable;

  getProducts({
    BuildContext? context,
    WidgetRef? ref,
  }) async {
    data.clear();
    status = ApiStatus.Loading;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await ApiProvider.get(ApiEndPoints.getProducts, queryParam: {});
    print(ApiEndPoints.getProducts);
    print(response);

    if (response['status'] == 200) {
      status = ApiStatus.Success;

      var res = response['body'];
      showSnackBar(context!, res['message'] ?? "");
      print(res);
      List tempData = res['products'];
      tempData.forEach((element) {
        data.add(Product.fromJson(element));
      });


      notifyListeners();
      return true;
    }
    else if (response['status'] == 'No Connection') {
      status = ApiStatus.NetworkError;
      notifyListeners();
      Navigator.push(context!, MaterialPageRoute(builder: (context)=>NetworkError()));
      return false;
    }
    else {
      status = ApiStatus.Error;
      notifyListeners();
    }
  }

}


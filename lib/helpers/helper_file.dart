import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(milliseconds: 1000),
    ),
  );
}

getHeight(context){
  return MediaQuery.of(context).size.height;
}

getWidth(context){
  return MediaQuery.of(context).size.width;
}

enum ApiStatus{
  Stable,
  Loading,
  Success,
  NetworkError,
  Error,
  NoData,
}

class ShowLoader extends StatelessWidget {
  const ShowLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(context),
      width: getWidth(context),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

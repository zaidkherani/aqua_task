import 'dart:math';

import 'package:aqua_task/api/get_products_service.dart';
import 'package:aqua_task/helpers/helper_file.dart';
import 'package:aqua_task/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/products_model.dart';

class ProductScreen extends ConsumerStatefulWidget {
  ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {

  var productsProvider = ChangeNotifierProvider((ref) => ProductProvider());

  var cartItems = StateProvider<List<Product>>((ref) => []);
  var cartIds = StateProvider((ref) => []);
  var listView = StateProvider((ref) => true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 100),(){
      getProducts();
      ref.read(listView.notifier).state = true;
      ref.read(cartIds.notifier).state.clear();
      ref.read(cartItems.notifier).state.clear();
    });
  }

  getProducts()async{
    var res = await ref.read(productsProvider).getProducts(
      ref: ref,context: context,
    );
  }

  showNotification(id,name){
    Future.delayed(Duration(milliseconds: 100),(){
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(channel.id, channel.name,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        ongoing: false,
      );
      IOSNotificationDetails iosPlatformChannelSpecifics = IOSNotificationDetails(
        threadIdentifier: channel.id,
        presentAlert: true,presentBadge: true,presentSound: true,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,iOS: iosPlatformChannelSpecifics);
      flutterLocalNotificationsPlugin.show(
        id,
        'Added to cart',
        '$name is added to cart',
        platformChannelSpecifics,
        payload: null,
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    var status = ref.watch(productsProvider).status;
    var data = ref.watch(productsProvider).data;
    var _cartItems = ref.watch(cartItems);
    var _cartIds = ref.watch(cartIds);
    var _listView =ref.watch(listView);
    return Scaffold(
      appBar: AppBar(
        key: UniqueKey(),
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey,
        title: Text('E-Commerce App'),
        actions: [
          IconButton(
            iconSize: 30,
            onPressed: (){
              ref.read(listView.notifier).state = !_listView;
            },
            icon: !_listView ? Icon(Icons.list) : Icon(Icons.grid_view),
          ),

          GestureDetector(
            onTap: (){
              if(_cartItems.length > 0){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Cart(cartIds: _cartIds,cartItems: _cartItems,))).then((value) {
                  setState(() {});
                });
              }
              else{
                showSnackBar(context, 'Cart is empty');
              }
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Badge.count(child: Icon(Icons.shopping_cart_outlined,size: 30),count: _cartItems.length,),
            ),
          ),
        ],
      ),
      body: status == ApiStatus.Loading || status == ApiStatus.Stable
        ? ShowLoader()
        : _listView
          ? ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: data.length,
          itemBuilder: (context,index){
            Product products = data[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Image.network(products.images.first,width: 100,height: 100,fit: BoxFit.fill,),
                  ),
                  SizedBox(width: 20,),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(right: 50),
                                child: Text('${products.title}'),
                              ),
                            ),
                            Text('${products.rating}'),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Text('${products.description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20,),
                        Text('\u20b9 ${products.price}'),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: (){
                            if(!_cartIds.contains(products.id)){
                              ref.read(cartItems.notifier).state.add(products);
                              ref.read(cartIds.notifier).state.add(products.id);
                              showNotification(products.id,products.title);
                            }else{
                              var ind = _cartIds.indexWhere((element) => element == products.id);
                              _cartIds.removeAt(ind);
                              _cartItems.removeAt(ind);
                            }
                            print(_cartItems);
                            print(_cartIds);
                            setState(() {});

                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(_cartIds.contains(products.id) ? 'Added To Cart' : 'Add To Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            );
          },
        )
          : GridView.builder(
            padding: EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.53,
            ),
            itemCount: data.length,
            itemBuilder: (context,index){
              Product products = data[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Image.network(products.images.first,width: 100,height: 100,fit: BoxFit.fill,),
                          ),
                          Text('${products.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('${products.description}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('\u20b9 ${products.price}'),
                          GestureDetector(
                            onTap: (){
                              if(!_cartIds.contains(products.id)){
                                ref.read(cartItems.notifier).state.add(products);
                                ref.read(cartIds.notifier).state.add(products.id);
                              }else{
                                var ind = _cartIds.indexWhere((element) => element == products.id);
                                _cartIds.removeAt(ind);
                                _cartItems.removeAt(ind);
                              }
                              print(_cartItems);
                              print(_cartIds);
                              setState(() {});

                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(_cartIds.contains(products.id) ? 'Added To Cart' : 'Add To Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 60,
                        padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.star,size: 15,color: Colors.white,),
                            Text('${products.rating}',
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

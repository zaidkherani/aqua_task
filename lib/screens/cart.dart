import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products_model.dart';

class Cart extends ConsumerStatefulWidget {
  List<Product> cartItems;
  List cartIds;
  Cart({Key? key,required this.cartItems,required this.cartIds}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

var cartItems2 = StateProvider<List<Product>>((ref) => []);
var cartIds2 = StateProvider((ref) => []);
var quantity = StateProvider((ref) => []);
var totalAmount = StateProvider<double>((ref) => 0);

class _CartState extends ConsumerState<Cart> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 100),()async{
      SharedPreferences prefs = await SharedPreferences.getInstance();

      ref.read(totalAmount.state).state = 0;
      ref.read(quantity.state).state.clear();
      ref.read(cartItems2.notifier).state = widget.cartItems;
      ref.read(cartIds2.notifier).state = widget.cartIds;
      int count = 0;
      List tempData = jsonDecode(prefs.getString('cart')!);
      ref.read(quantity.state).state = tempData;
      widget.cartItems.forEach((element) {
        Product data = element;
        if(prefs.containsKey('cart')){

          if(tempData.isNotEmpty){
            List ids = ref.watch(cartIds2);
            if(ids.contains(data.id)){
              // ref.read(quantity.state).state = tempData;
              ref.read(totalAmount.notifier).state += (double.parse(data.price.toStringAsFixed(2)) * ref.watch(quantity)[count]);
            }

          }
          else{
            ref.read(totalAmount.state).state += double.parse(data.price.toString());
            ref.read(quantity.state).state.add(1);
          }
        }
        else{
          ref.read(totalAmount.state).state += double.parse(data.price.toString());
          ref.read(quantity.state).state.add(1);
        }
        count++;
      });



    });
  }

  refresh(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _cartItems2 = ref.watch(cartItems2);
    return WillPopScope(
      onWillPop: ()async{
        var _quantity = ref.watch(quantity);
        var _totalAmount = ref.watch(totalAmount);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cart', jsonEncode(_quantity));
        prefs.setString('totalAmount', _totalAmount.toStringAsFixed(2));
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          key: UniqueKey(),
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey,
          title: Text('Cart (${_cartItems2.length})'),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ListView.builder(
                  // shrinkWrap: true,
                  itemCount: _cartItems2.length,
                  itemBuilder: (context,index){
                    return CartContainer(key: UniqueKey(),index: index,data: _cartItems2[index],refresh:refresh);
                  },
                ),
              ),
              TotalPrice(),

            ],
          ),
        ),
      ),
    );
  }
}

class TotalPrice extends ConsumerWidget {
  const TotalPrice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,ref) {
    var _totalAmount = ref.watch(totalAmount);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Price'),
            Text('${_totalAmount}'),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('GST 18%'),
            Text('${(_totalAmount * 0.18).toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Amount'),
            Text('${(_totalAmount + (_totalAmount * 0.18)).toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}


class CartContainer extends ConsumerStatefulWidget {
  Product data;
  int index;
  Function refresh;
  CartContainer({Key? key,required this.refresh,required this.data,required this.index}) : super(key: key);

  @override
  _CartContainerState createState() => _CartContainerState(products: this.data);
}

class _CartContainerState extends ConsumerState<CartContainer> {
  Product products;
  _CartContainerState({required this.products});

  var qty = StateProvider((ref) => 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 100),(){
      print(ref.watch(quantity));
      ref.read(qty.notifier).state = ref.watch(quantity)[widget.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    var _qty = ref.watch(qty);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            if(_qty > 1){
                              ref.read(qty.state).state--;
                              ref.read(quantity.state).state[widget.index] = ref.watch(quantity)[widget.index]-1;
                              ref.read(totalAmount.state).state -= double.parse(products.price.toString());
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text('-',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Text('${_qty}'),
                        SizedBox(width: 10,),
                        GestureDetector(
                          onTap: (){
                            ref.read(qty.state).state++;
                            ref.read(quantity.state).state[widget.index] = ref.watch(quantity)[widget.index]+1;
                            ref.read(totalAmount.state).state += double.parse(products.price.toString());
                            print(ref.watch(quantity));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text('+',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        // var ind = _cartIds2.indexWhere((element) => element == products.id);
                        ref.read(cartIds2.notifier).state.removeAt(widget.index);
                        ref.read(cartItems2.notifier).state.removeAt(widget.index);
                        ref.read(quantity.notifier).state.removeAt(widget.index);
                        ref.read(totalAmount.state).state -= (double.parse(products.price.toString()) * double.parse(_qty.toString()));
                        widget.refresh();
                      },
                      child: Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(width: 20,),
          // Column(
          //   mainAxisSize: MainAxisSize.max,
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text('${products.rating}'),
          //     Icon(Icons.delete),
          //   ],
          // ),
        ],
      ),
    );
  }
}


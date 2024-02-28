import 'package:flutter/material.dart';


class ProductsData {
  List<Product> products;
  int total;
  int skip;
  int limit;

  ProductsData({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    var productsList = json['products'] as List;
    List<Product> products =
    productsList.map((product) => Product.fromJson(product)).toList();

    return ProductsData(
      products: products,
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}

class Product {
  int id;
  String title;
  String description;
  double price;
  double discountPercentage;
  double rating;
  int stock;
  String brand;
  String category;
  String thumbnail;
  List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List;
    List<String> images = imagesList.map((image) => image.toString()).toList();

    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountPercentage: json['discountPercentage'].toDouble(),
      rating: json['rating'].toDouble(),
      stock: json['stock'],
      brand: json['brand'],
      category: json['category'],
      thumbnail: json['thumbnail'],
      images: images,
    );
  }
}
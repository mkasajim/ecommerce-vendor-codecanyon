
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/image_model.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class AddProductRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> getAttributeList(String languageCode);
  Future<ApiResponse> getBrandList(String languageCode);
  Future<ApiResponse> getEditProduct(int? id);
  Future<ApiResponse> getCategoryList(String languageCode);
  Future<ApiResponse> getSubCategoryList();
  Future<ApiResponse> getSubSubCategoryList();
  Future<ApiResponse> addImage(BuildContext context, ImageModel imageForUpload, bool colorActivate);
  Future<ApiResponse> addProduct(Product product, AddProductModel addProduct, Map<String, dynamic> attributes, List<String?>? productImages, String? thumbnail, String? metaImage, bool isAdd, bool isActiveColor, List<ColorImage> colorImageObject, List<String?> tags, String? digitalFileReady);
  Future<ApiResponse> uploadDigitalProduct(File? filePath, String token);
  Future<ApiResponse> updateProductQuantity(int? productId,int currentStock, List <Variation> variation);
  Future<ApiResponse> deleteProductImage(String id, String name, String? color );
  Future<ApiResponse> getProductImage(String id );
}
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/exception/api_error_handler.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/image_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/repository/add_product_repository_interface.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';


class AddProductRepository implements AddProductRepositoryInterface{
  final DioClient? dioClient;
  AddProductRepository({required this.dioClient});

  @override
  Future<ApiResponse> getAttributeList(String languageCode) async {
    try {
      final response = await dioClient!.get(AppConstants.attributeUri,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getBrandList(String languageCode) async {
    try {
      final response = await dioClient!.get(AppConstants.brandUri,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getEditProduct(int? id) async {
    try {
      final response = await dioClient!.get('${AppConstants.editProductUri}/$id');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getCategoryList(String languageCode) async {
    try {
      final response = await dioClient!.get(AppConstants.categoryUri,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSubCategoryList() async {
    try {
      final response = await dioClient!.get(AppConstants.categoryUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSubSubCategoryList() async {
    try {
      final response = await dioClient!.get(AppConstants.categoryUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }

  }

  @override
  Future<ApiResponse> addImage(BuildContext context, ImageModel imageForUpload, bool colorActivate) async {
    http.MultipartRequest request = http.MultipartRequest(
        'POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.uploadProductImageUri}',
    ));
    if (kDebugMode) {
      print('==image is exist or not=${imageForUpload.image!.path}');
    }
    request.headers.addAll(<String, String>{'Authorization': 'Bearer ${Provider.of<AuthController>(context,listen: false).getUserToken()}'});
    if(Platform.isAndroid || Platform.isIOS && imageForUpload.image != null) {
      File file = File(imageForUpload.image!.path);
      request.files.add(http.MultipartFile('image', file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last));
    }
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      'type': imageForUpload.type!,
      'color': imageForUpload.color!,
      'colors_active' : colorActivate.toString()
    });
    request.fields.addAll(fields);
    if (kDebugMode) {
      print('=====> ${request.url.path}\n${request.fields}');
    }

    http.StreamedResponse response = await request.send();
    var res = await http.Response.fromStream(response);
    if (kDebugMode) {
      print('=====Response body is here==>${res.body}');
    }

    try {
      return ApiResponse.withSuccess(Response(statusCode: response.statusCode,
          requestOptions: RequestOptions(path: ''), statusMessage: response.reasonPhrase,
          data: res.body));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> addProduct(Product product, AddProductModel addProduct, Map<String, dynamic> attributes, List<String?>? productImages, String? thumbnail, String? metaImage, bool isAdd, bool isActiveColor, List<ColorImage> colorImageObject, List<String?> tags, String? digitalFileReady) async {
    dioClient!.dio!.options.headers = {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer ${Provider.of<AuthController>(Get.context!,listen: false).getUserToken()}'};
    Map<String, dynamic> fields = {};

    fields.addAll(<String, dynamic>{
      'name': addProduct.titleList,
      'description': addProduct.descriptionList,
      'unit_price': product.unitPrice,
      'discount': product.discount,
      'discount_type': product.discountType,
      'tax': product.tax,
      'tax_model': product.taxModel,
      'category_id': product.categoryIds![0].id,
      'unit': product.unit,
      'brand_id': Provider.of<SplashController>(Get.context!, listen: false).configModel!.brandSetting == "1"? product.brandId : null,
      'meta_title': product.metaTitle,
      'meta_description': product.metaDescription,
      'lang': addProduct.languageList,
      'colors':addProduct.colorCodeList,
      'images':productImages,
      'color_image': colorImageObject,
      'thumbnail':thumbnail,
      'colors_active': isActiveColor,
      'video_url': addProduct.videoUrl,
      'meta_image':metaImage,
      'current_stock':product.currentStock,
      'shipping_cost':product.shippingCost,
      'multiply_qty':product.multiplyWithQuantity,
      'code': product.code,
      'minimum_order_qty':product.minimumOrderQty,
      'product_type' : product.productType,
      "digital_product_type" : product.digitalProductType,
      "digital_file_ready" : digitalFileReady??product.digitalFileReady,
      "tags" : tags


    });
    if(product.categoryIds!.length > 1) {
      fields.addAll(<String, dynamic> {'sub_category_id': product.categoryIds![1].id});
    }
    if(product.categoryIds!.length > 2) {
      fields.addAll(<String, dynamic> {'sub_sub_category_id': product.categoryIds![2].id});
    }
    if(!isAdd) {
      fields.addAll(<String, dynamic> {'_method': 'put', 'id': product.id});
    }
    if(attributes.isNotEmpty) {
      fields.addAll(attributes);
    }

    if (kDebugMode) {
      log('==========Response Body======>$fields');
    }

    try {
      Response response = await dioClient!.post('${AppConstants.baseUrl}${isAdd ? AppConstants.addProductUri : '${AppConstants.updateProductUri}/${product.id}'}',

        data: fields,


      );
      return ApiResponse.withSuccess(response);

    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> uploadDigitalProduct(File? filePath, String token) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.digitalProductUpload}'));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
    if(filePath != null) {
      Uint8List list = await filePath.readAsBytes();
      var part = http.MultipartFile('digital_file_ready', filePath.readAsBytes().asStream(), list.length, filename: basename(filePath.path));
      request.files.add(part);
    }

    Map<String, String> fields = {};
    fields.addAll(<String, String>{
    });

    request.fields.addAll(fields);
    if (kDebugMode) {
      print('=====> ${request.url.path}\n${request.fields}');
    }

    http.StreamedResponse response = await request.send();
    var res = await http.Response.fromStream(response);
    if (kDebugMode) {
      print('=====Response body is here==>${res.body}');
    }

    try {
      return ApiResponse.withSuccess(Response(statusCode: response.statusCode,
          requestOptions: RequestOptions(path: ''), statusMessage: response.reasonPhrase, data: res.body));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> updateProductQuantity(int? productId,int currentStock, List <Variation> variation) async {
    try {
      final response = await dioClient!.post(AppConstants.updateProductQuantity,
          data: {
            "product_id": productId,
            "current_stock": currentStock,
            "variation" : variation,
            "_method":"put"
          }
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }



  @override
  Future<ApiResponse> deleteProductImage(String id, String name, String? color ) async {
    try {
      final response = await dioClient!.get("${AppConstants.deleteProductImage}?id=$id&name=$name&color=$color");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> getProductImage(String id ) async {
    try {
      final response = await dioClient!.get("${AppConstants.getProductImage}$id");
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }





  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
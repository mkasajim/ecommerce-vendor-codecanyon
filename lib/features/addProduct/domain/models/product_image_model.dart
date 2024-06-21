import 'package:sixvalley_vendor_app/features/addProduct/domain/models/image_model.dart';

class ProductImagesModel {
  List<String>? images;
  List<ColorImage>? colorImage;

  ProductImagesModel({this.images, this.colorImage});

  ProductImagesModel.fromJson(Map<String, dynamic> json) {
    if(json['images'] != null){
      images = json['images'] != null ? json['images'].cast<String>() : [];
    }
    if (json['color_image'] != null) {
      colorImage = <ColorImage>[];
      json['color_image'].forEach((v) {
        colorImage!.add(ColorImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['images'] = images;
    if (colorImage != null) {
      data['color_image'] = colorImage!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


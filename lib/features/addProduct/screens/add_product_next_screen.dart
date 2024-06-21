
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/attribute_view_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/attribute_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/variant_type_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_seo_screen.dart';

class AddProductNextScreen extends StatefulWidget {
  final ValueChanged<bool>? isSelected;
  final Product? product;
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandId;
  final AddProductModel? addProduct;
  final String? unit;

  const AddProductNextScreen({Key? key, this.isSelected, required this.product,required this.addProduct, this.categoryId, this.subCategoryId, this.subSubCategoryId, this.brandId, this.unit}) : super(key: key);

  @override
  AddProductNextScreenState createState() => AddProductNextScreenState();
}

class AddProductNextScreenState extends State<AddProductNextScreen> {
  bool isSelected = false;
  final FocusNode _discountNode = FocusNode();
  final FocusNode _shippingCostNode = FocusNode();
  final FocusNode _unitPriceNode = FocusNode();
  final FocusNode _taxNode = FocusNode();
  final FocusNode _totalQuantityNode = FocusNode();
  final FocusNode _minimumOrderQuantityNode = FocusNode();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  //final TextEditingController _totalQuantityController = TextEditingController();
  final TextEditingController _minimumOrderQuantityController = TextEditingController();
  AutoCompleteTextField? searchTextField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  SimpleAutoCompleteTextField? textField;
  bool showWhichErrorText = false;
  late bool _update;
  Product? _product;
  String? thumbnailImage ='', metaImage ='';
  List<String?>? productImage =[];
  int counter = 0, total = 0;
  int addColor = 0;
  int cat=0, subCat=0, subSubCat=0, unit=0, brand=0;


  void _load(){
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US'?
    'en':Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    Provider.of<SplashController>(context,listen: false).getColorList();
    Provider.of<AddProductController>(context,listen: false).getAttributeList(context, widget.product, languageCode);
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<AddProductController>(context,listen: false).colorImageObject = [];
    Provider.of<AddProductController>(context,listen: false).productReturnImage = [];
    _product = widget.product;
    _update = widget.product != null;
    _taxController.text = '0';
    _discountController.text = '0';
    _shippingCostController.text = '0';
    //_totalQuantityController.text = '1';
    _minimumOrderQuantityController.text = '1';
    _load();
    if(_update) {
      _unitPriceController.text = PriceConverter.convertPriceWithoutSymbol(context, _product!.unitPrice);
      _taxController.text = _product!.tax.toString();
      Provider.of<AddProductController>(context, listen: false).setCurrentStock(_product!.currentStock.toString());
      // _totalQuantityController.text = _product!.currentStock.toString();
      _shippingCostController.text = _product!.shippingCost.toString();
      _minimumOrderQuantityController.text = _product!.minimumOrderQty.toString();
      Provider.of<AddProductController>(context, listen: false).setDiscountTypeIndex(_product!.discountType == 'percent' ? 0 : 1, false);
      _discountController.text = _product!.discountType == 'percent' ?
      _product!.discount.toString() : PriceConverter.convertPriceWithoutSymbol(context, _product!.discount);
      thumbnailImage = _product!.thumbnail;
      metaImage = _product!.metaImage;
      productImage = _product!.images;
      Provider.of<AddProductController>(context, listen: false).setTaxTypeIndex(_product!.taxModel == 'include' ? 0 : 1, false);
      _asyncMethod();
    }else {
      _product = Product();
    }
    super.initState();
  }


  _asyncMethod() async {
    Future.delayed(const Duration(seconds: 3), () async {
      Provider.of<AddProductController>(context,listen: false).getProductImage(widget.product!.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBarWidget(title:  widget.product != null ?
      getTranslated('update_product', context):
      getTranslated('add_product', context),),
      body: Container(decoration: BoxDecoration(color: Theme.of(context).cardColor),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Consumer<AddProductController>(
            builder: (context, resProvider, child){
              List<int> brandIds = [];
              List<int> colors = [];
              brandIds.add(0);
              colors.add(0);
                if (_update && Provider.of<AddProductController>(context, listen: false).attributeList != null &&
                    Provider.of<AddProductController>(context, listen: false).attributeList!.isNotEmpty) {
                  if(addColor==0) {
                    addColor++;
                    if ( widget.product!.colors != null && widget.product!.colors!.isNotEmpty) {
                      Future.delayed(Duration.zero, () async {
                        Provider.of<AddProductController>(context, listen: false).setAttribute();
                      });
                    }
                    for (int index = 0; index < widget.product!.colors!.length; index++) {
                      colors.add(index);
                      Future.delayed(Duration.zero, () async {
                        resProvider.addVariant(context,0, widget.product!.colors![index].name, widget.product, false);
                        resProvider.addColorCode(widget.product!.colors![index].code, index: index);
                      });
                    }
                  }
                }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: (resProvider.attributeList != null &&
                          resProvider.attributeList!.isNotEmpty &&
                          resProvider.categoryList != null &&
                          Provider.of<SplashController>(context,listen: false).colorList!= null) ?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          resProvider.productTypeIndex == 0 ?
                          Column(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(getTranslated('variations', context)!,
                                      style: robotoBold.copyWith(color: ColorResources.getHeadTextColor(context),
                                          fontSize: Dimensions.fontSizeExtraLarge)),
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Row(children: [
                              Text(getTranslated('add_color_variation', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              const Spacer(),

                              FlutterSwitch(width: 60.0, height: 30.0, toggleSize: 28.0,
                                value: resProvider.attributeList![0].active,
                                borderRadius: 20.0,
                                activeColor: Theme.of(context).primaryColor,
                                padding: 1.0,
                                onToggle:(bool isActive) =>resProvider.toggleAttribute(context, 0, widget.product),
                              ),
                            ],),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            resProvider.attributeList![0].active ?
                            Consumer<SplashController>(builder: (ctx, colorProvider, child){
                              if (colorProvider.colorList != null) {
                                for (int index = 0; index < colorProvider.colorList!.length; index++) {
                                  colors.add(index);
                                }
                              }
                              return Autocomplete<int>(
                                optionsBuilder: (TextEditingValue value) {
                                  if (value.text.isEmpty) {
                                    return const Iterable<int>.empty();
                                  } else {
                                    return colors.where((color) => colorProvider.colorList![color].
                                    name!.toLowerCase().contains(value.text.toLowerCase()));
                                  }
                                },
                                fieldViewBuilder:
                                    (context, controller, node, onComplete) {
                                  return Container(
                                    height: 50,
                                    decoration: BoxDecoration(color: Theme.of(context).cardColor,
                                      border: Border.all(width: 1, color: Theme.of(context).hintColor.withOpacity(.50)),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                    ),
                                    child: TextField(
                                      controller: controller,
                                      focusNode: node, onEditingComplete: onComplete,
                                      decoration: InputDecoration(
                                        hintText: getTranslated('type_color_name', context),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.paddingSizeSmall),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  );
                                },
                                displayStringForOption: (value) => colorProvider.colorList![value].name!,
                                onSelected: (int value) {
                                  resProvider.addVariant(context, 0,colorProvider.colorList![value].name, widget.product, true);
                                  resProvider.addColorCode(colorProvider.colorList![value].code);
                                },
                              );
                            }):const SizedBox(),


                            SizedBox(height: resProvider.selectedColor.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

                            SizedBox(height: (resProvider.attributeList![0].variants.isNotEmpty) ? 40 : 0,
                              child: (resProvider.attributeList![0].variants.isNotEmpty) ?

                              ListView.builder(
                                itemCount: resProvider.attributeList![0].variants.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(.20),
                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                      ),
                                      child: Row(children: [
                                        Consumer<SplashController>(builder: (ctx, colorP,child){
                                          return Text(resProvider.attributeList![0].variants[index]!,
                                            style: robotoRegular.copyWith(color: ColorResources.titleColor(context)),);
                                        }),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: (){resProvider.removeVariant(context, 0, index, widget.product);
                                          resProvider.removeColorCode(index);},
                                          child: Icon(Icons.close, size: 15, color: ColorResources.titleColor(context)),
                                        ),
                                      ]),
                                    ),
                                  );
                                },
                              ):const SizedBox(),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            AttributeViewWidget(product: widget.product, colorOn: resProvider.attributeList![0].active),
                          ],):const SizedBox(),

                          SizedBox(height: resProvider.productTypeIndex == 0? 0 : Dimensions.paddingSizeDefault),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(getTranslated('product_price_and_stock',context)!,
                                style: robotoBold.copyWith(color: ColorResources.getHeadTextColor(context),
                                    fontSize: Dimensions.fontSizeExtraLarge)),
                          ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(getTranslated('unit_price', context)!,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextFieldWidget(
                            border: true,
                            controller: _unitPriceController,
                            focusNode: _unitPriceNode,
                            textInputAction: TextInputAction.done,
                            textInputType: TextInputType.number,
                            isAmount: true,
                            hintText: 'Ex: \$129',
                          ),


                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(getTranslated('tax_model', context)!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(color: Theme.of(context).cardColor,
                                  border: Border.all(width: .7,color: Theme.of(context).hintColor.withOpacity(.3)),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                ),
                                child: DropdownButton<String>(
                                  value: resProvider.taxTypeIndex == 0 ? 'include' : 'exclude',
                                  items: <String>['include', 'exclude'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(getTranslated(value, context)!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    resProvider.setTaxTypeIndex(value == 'include' ? 0 : 1, true);
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ),
                            ])),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getTranslated('tax_p',context)!,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                CustomTextFieldWidget(
                                  border: true,
                                  controller: _taxController,
                                  focusNode: _taxNode,
                                  nextNode: _discountNode,
                                  isAmount: true,
                                  textInputAction: TextInputAction.next,
                                  textInputType: TextInputType.number,
                                  hintText: 'Ex: \$10',
                                ),
                              ],
                            )),
                          ]),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(getTranslated('discount_type', context)!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(color: Theme.of(context).cardColor,
                                  border: Border.all(width: .7,color: Theme.of(context).hintColor.withOpacity(.3)),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                ),
                                child: DropdownButton<String>(
                                  value: resProvider.discountTypeIndex == 0 ? 'percent' : 'amount',
                                  items: <String>['percent', 'amount'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(getTranslated(value, context)!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    resProvider.setDiscountTypeIndex(value == 'percent' ? 0 : 1, true);
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ),
                            ])),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getTranslated('discount_amount', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                CustomTextFieldWidget(
                                  border: true,
                                  hintText: getTranslated('discount', context),
                                  controller: _discountController,
                                  focusNode: _discountNode,
                                  nextNode: _shippingCostNode,
                                  textInputAction: TextInputAction.next,
                                  textInputType: TextInputType.number,
                                  isAmount: true,
                                  // isAmount: true,
                                ),
                              ],
                            )),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Row(children: [
                            resProvider.productTypeIndex == 0?
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(getTranslated('total_quantity', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              CustomTextFieldWidget(
                                idDate: resProvider.variantTypeList.isNotEmpty,
                                border: true,
                                textInputType: TextInputType.number,
                                focusNode: _totalQuantityNode,
                                controller: resProvider.totalQuantityController,
                                textInputAction: TextInputAction.next,
                                isAmount: true,
                                hintText: 'Ex: 500',
                              ),
                            ],)): const SizedBox(),

                            SizedBox(width: resProvider.productTypeIndex == 0? Dimensions.paddingSizeDefault:0),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(getTranslated('minimum_order_quantity', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              CustomTextFieldWidget(
                                border: true,
                                textInputType: TextInputType.number,
                                focusNode: _minimumOrderQuantityNode,
                                controller: _minimumOrderQuantityController,
                                textInputAction: TextInputAction.next,
                                isAmount: true,
                                hintText: 'Ex: 500',
                              ),
                            ],)),
                          ],),

                          const SizedBox(height: Dimensions.paddingSizeExtraLarge,),

                          //__________Shipping__________
                          resProvider.productTypeIndex == 0 ?
                          Column(children: [
                            Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                              Text(getTranslated('shipping',context)!,
                                  style: robotoBold.copyWith(color: ColorResources.getHeadTextColor(context),
                                      fontSize: Dimensions.fontSizeExtraLarge)),
                            ],),

                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getTranslated('shipping_cost', context)!,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                CustomTextFieldWidget(
                                  border: true,
                                  controller: _shippingCostController,
                                  focusNode: _shippingCostNode,
                                  nextNode: _totalQuantityNode,
                                  textInputAction: TextInputAction.next,
                                  textInputType: TextInputType.number,
                                  isAmount: true,
                                  // isAmount: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault,),

                            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(getTranslated('shipping_cost_multiply', context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Text(getTranslated('shipping_cost_multiply_by_item', context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).hintColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              FlutterSwitch(width: 60.0, height: 30.0, toggleSize: 30.0,
                                value: resProvider.isMultiply,
                                borderRadius: 20.0,
                                activeColor: Theme.of(context).primaryColor,
                                padding: 1.0,
                                onToggle:(bool isActive) =>resProvider.toggleMultiply(context),
                              ),
                            ]),
                            const SizedBox(height: Dimensions.iconSizeLarge),
                          ],):const SizedBox(),

                        ],):

                      const Padding(padding: EdgeInsets.only(top: 300.0),
                        child: Center(child: CircularProgressIndicator()),),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                          spreadRadius: 0.5, blurRadius: 0.3)],
                    ),
                    height: 80,child: Row(children: [
                    Expanded(child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: ()=>Navigator.pop(context),
                      child: CustomButtonWidget(
                        isColor: true,
                        btnTxt: '${getTranslated('back', context)}',
                        backgroundColor: Theme.of(context).hintColor,),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Consumer<AddProductController>(
                        builder: (context,resProvider, _) {
                          return CustomButtonWidget(
                            btnTxt:  getTranslated('next', context),
                            onTap: () {

                              String unitPrice =_unitPriceController.text.trim();
                              String currentStock = resProvider.totalQuantityController.text.trim();
                              String orderQuantity = _minimumOrderQuantityController.text.trim();
                              String tax = _taxController.text.trim();
                              String discount = _discountController.text.trim();
                              String shipping = _shippingCostController.text.trim();
                              bool haveBlankVariant = false;
                              bool blankVariantPrice = false;
                              bool blankVariantQuantity = false;
                              for (AttributeModel attr in resProvider.attributeList!) {
                                if (attr.active && attr.variants.isEmpty) {
                                  haveBlankVariant = true;
                                  break;
                                }
                              }

                              for (VariantTypeModel variantType in resProvider.variantTypeList) {
                                if (variantType.controller.text.isEmpty) {
                                  blankVariantPrice = true;
                                  break;
                                }
                              }
                              for (VariantTypeModel variantType in resProvider.variantTypeList) {
                                if (variantType.qtyController.text.isEmpty) {
                                  blankVariantQuantity = true;
                                  break;
                                }
                              }
                              if (unitPrice.isEmpty) {
                                showCustomSnackBarWidget(getTranslated('enter_unit_price', context),context,  sanckBarType: SnackBarType.warning);
                              }

                              else if (currentStock.isEmpty &&  resProvider.productTypeIndex == 0) {
                                showCustomSnackBarWidget(getTranslated('enter_total_quantity', context),context,  sanckBarType: SnackBarType.warning);
                              }
                              else if (orderQuantity.isEmpty) {
                                showCustomSnackBarWidget(getTranslated('enter_minimum_order_quantity', context),context,  sanckBarType: SnackBarType.warning);
                              }
                              else if (haveBlankVariant) {
                                showCustomSnackBarWidget(getTranslated('add_at_least_one_variant_for_every_attribute',context),context,  sanckBarType: SnackBarType.warning);
                              } else if (blankVariantPrice) {
                                showCustomSnackBarWidget(getTranslated('enter_price_for_every_variant', context),context,  sanckBarType: SnackBarType.warning);
                              }else if (blankVariantQuantity) {
                                showCustomSnackBarWidget(getTranslated('enter_quantity_for_every_variant', context),context,  sanckBarType: SnackBarType.warning);
                              } else if (resProvider.productTypeIndex == 0 && _shippingCostController.text.isEmpty) {
                                showCustomSnackBarWidget(getTranslated('enter_shipping_cost', context),context,  sanckBarType: SnackBarType.warning);
                              }
                              // else if (resProvider.productTypeIndex == 0 &&  int.parse(_shippingCostController.text) <=0) {
                              //   showCustomSnackBarWidget(getTranslated('shipping_cost_must_be_gater_then', context),context,  sanckBarType: SnackBarType.warning);
                              // }
                              else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductSeoScreen(
                                  unitPrice: unitPrice,
                                  tax: tax,
                                  unit: widget.unit,
                                  categoryId: widget.categoryId,
                                  subCategoryId: widget.subCategoryId,
                                  subSubCategoryId: widget.subSubCategoryId,
                                  brandyId: widget.brandId,
                                  discount: discount,
                                  currentStock: currentStock,
                                  minimumOrderQuantity: orderQuantity,
                                  shippingCost: shipping,
                                  product: widget.product, addProduct: widget.addProduct)));
                              }
                            },
                          );
                        }
                    )),
                  ],),)
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

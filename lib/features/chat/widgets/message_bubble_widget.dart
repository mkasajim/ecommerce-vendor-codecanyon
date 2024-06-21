import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/message_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/image_diaglog_widget.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;

  const MessageBubbleWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMe = message.sentBySeller!;

    String? baseUrl = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    Provider.of<SplashController>(context, listen: false).baseUrls!.customerImageUrl:
    Provider.of<SplashController>(context, listen: false).baseUrls!.sellerImageUrl;
    String? image = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    message.customer != null? message.customer?.image :'' : message.deliveryMan?.image;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          isMe ? const SizedBox.shrink() :
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
            child: InkWell(child: ClipOval(child: Container(
              color: Theme.of(context).highlightColor,
              child: CustomImageWidget(image: '$baseUrl/$image',height: Dimensions.chatImage,width: Dimensions.chatImage,)
            ))),
          ),

          Flexible(child: Column(crossAxisAlignment: isMe ?CrossAxisAlignment.end:CrossAxisAlignment.start, children: [
               if(message.message != null && message.message!.isNotEmpty)
                Container(
                    margin: isMe ?  const EdgeInsets.fromLTRB(70, 5, 10, 5) : const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: isMe? const Radius.circular(10) : const Radius.circular(10),
                        bottomLeft: isMe ? const Radius.circular(10) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(10),
                        topRight: isMe? const Radius.circular(10): const Radius.circular(10)),
                      color: isMe ? Theme.of(context).hintColor.withOpacity(.125) : ColorResources.getPrimary(context).withOpacity(.10)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      (message.message != null && message.message!.isNotEmpty) ? Text(message.message!,
                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color: isMe ? ColorResources.getTextColor(context): ColorResources.getTextColor(context))) : const SizedBox.shrink(),
                    ]),
                ),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: Text(DateConverter.customTime(DateTime.parse(message.createdAt!)),
                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                        color: ColorResources.getHint(context)))),
            if(message.attachment!.isNotEmpty) const SizedBox(height: Dimensions.paddingSizeSmall),

            message.attachment!.isNotEmpty?
            Directionality(textDirection:Provider.of<LocalizationController>(context, listen: false).isLtr ? isMe ?
            TextDirection.rtl : TextDirection.ltr : isMe ? TextDirection.ltr : TextDirection.rtl,
              child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1, crossAxisCount: 3,
                  mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: message.attachment!.length,
                itemBuilder: (BuildContext context, index) {
                  return  InkWell(onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialogWidget(
                      imageUrl: '${AppConstants.baseUrl}/storage/app/public/chatting/${message.attachment![index]}')),
                    child: ClipRRect(borderRadius: BorderRadius.circular(5),
                        child:CustomImageWidget(height: 100, width: 100, fit: BoxFit.cover,
                            image: '${AppConstants.baseUrl}/storage/app/public/chatting/${message.attachment![index]}')),);

                },),
            ):
            const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

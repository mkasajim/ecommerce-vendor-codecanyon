import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/widgets/chat_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/widgets/message_bubble_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/widgets/send_message_widget.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final int? userId;
  const ChatScreen({Key? key, required this.userId, this.name = ''}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final ImagePicker picker = ImagePicker();




  @override
  void initState() {
    Provider.of<ChatController>(context, listen: false).getMessageList(widget.userId, 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChatController>(builder: (context, chat, child) {
        return Column(children: [

          CustomAppBarWidget(title: widget.name),

          Expanded(child: chat.messageList != null ? chat.messageList!.isNotEmpty ?
           ListView.builder(
             physics: const BouncingScrollPhysics(),
             padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
             itemCount: chat.messageList!.length,
             reverse: true,
              itemBuilder: (context, index) {
              return MessageBubbleWidget(message: chat.messageList![index]);
            },
           ) : const SizedBox.shrink() : const ChatShimmerWidget()),

          chat.pickedImageFileStored != null && chat.pickedImageFileStored!.isNotEmpty ?
          Container(height: 90, width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(scrollDirection: Axis.horizontal,
              itemBuilder: (context,index){
                return  Stack(children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(borderRadius: BorderRadius.circular(10),
                          child: SizedBox(height: 80, width: 80,
                              child: Image.file(File(chat.pickedImageFileStored![index].path), fit: BoxFit.cover)))),


                  Positioned(right: 5,
                      child: InkWell(
                          splashColor: Colors.transparent,
                          child: const Icon(Icons.cancel_outlined, color: Colors.red),
                          onTap: () => chat.pickMultipleImage(true,index: index))),
                ],
                );},
              itemCount: chat.pickedImageFileStored!.length,
            ),
          ) : const SizedBox(),
          SendMessageWidget(id: widget.userId)
        ]);
      }),
    );
  }
}




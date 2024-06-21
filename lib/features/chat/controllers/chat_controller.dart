import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/message_body.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/chat_model.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/message_model.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/services/chat_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'dart:async';
import 'package:http/http.dart' as http;


class ChatController extends ChangeNotifier {
  final ChatServiceInterface chatServiceInterface;
  ChatController({required this.chatServiceInterface});


  List<Chat>? _chatList;
  List<Chat>? get chatList => _chatList;
  List<Message>? _messageList;
  List<Message>? get messageList => _messageList;
  bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;
  int _userTypeIndex = 0;
  int get userTypeIndex =>  _userTypeIndex;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  ChatModel? _chatModel;
  ChatModel? get chatModel => _chatModel;


  Future<void> getChatList(BuildContext context, int offset, {bool reload = false}) async {
    if(reload){
      _chatModel = null;
    }
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.getChatList(_userTypeIndex == 0 ? 'customer' : 'delivery-man', offset);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        _chatModel = null;
        _chatModel = ChatModel.fromJson(apiResponse.response!.data);
      }else {
        _chatModel!.totalSize = ChatModel.fromJson(apiResponse.response!.data).totalSize;
        _chatModel!.offset = ChatModel.fromJson(apiResponse.response!.data).offset;
        _chatModel!.chat!.addAll(ChatModel.fromJson(apiResponse.response!.data).chat!);
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchedChatList(BuildContext context, String search) async {
    ApiResponse apiResponse = await chatServiceInterface.searchChat(_userTypeIndex == 0 ? 'customer' : 'delivery-man', search);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _chatModel = ChatModel(totalSize: 10, limit: '10', offset: '1', chat: []);
      apiResponse.response!.data.forEach((chat) {_chatModel!.chat!.add(Chat.fromJson(chat));});
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> getMessageList(int? id, int offset, {bool reload = true}) async {
    if(reload){
      _messageList = [];
    }
    _messageList = null;
    ApiResponse apiResponse = await chatServiceInterface.getMessageList(_userTypeIndex == 0 ? 'customer' : 'delivery-man', offset, id);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _messageList = [];
      _messageList!.addAll(MessageModel.fromJson(apiResponse.response!.data).message!);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  Future<http.StreamedResponse> sendMessage(MessageBody messageBody,) async {
    if(kDebugMode){
      print("===api call===id = ${messageBody.userId}");
    }
    _isLoading = true;
    notifyListeners();
    http.StreamedResponse response = await chatServiceInterface.sendMessage(messageBody,_userTypeIndex == 0? 'customer' : 'delivery-man' ,_pickedImageFiles);
    if (response.statusCode == 200) {
      getMessageList(messageBody.userId, 1, reload: false);
      _pickedImageFiles = [];
      pickedImageFileStored = [];
      _isLoading = false;
    } else {
      _isLoading = false;
    }
    _pickedImageFiles = [];
    pickedImageFileStored = [];
    _isLoading = false;
    notifyListeners();
    return response;
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    notifyListeners();
  }

  void setUserTypeIndex(BuildContext context, int index) {
    _userTypeIndex = index;
    _chatModel = null;
    getChatList(context, 1);
    notifyListeners();
  }

  List <XFile> _pickedImageFiles =[];
  List <XFile>? get pickedImageFile => _pickedImageFiles;
  List <XFile>?  pickedImageFileStored = [];
  void pickMultipleImage(bool isRemove,{int? index}) async {
    if(isRemove) {
      if(index != null){
        pickedImageFileStored?.removeAt(index);
      }
    }else {
      _pickedImageFiles = await ImagePicker().pickMultiImage(imageQuality: 40);
      pickedImageFileStored?.addAll(_pickedImageFiles);
    }
    notifyListeners();
  }

}

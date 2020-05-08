import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {

  String pid;
  String providerdsUid;
  String uid;
  String chatid;
  //ToDo - add in timestamp



  Chat({this.pid, this.providerdsUid, this.uid, this.chatid});


  Chat.fromMap(Map snapshot) :
        pid = snapshot['pid'] ?? '',
        providerdsUid = snapshot['providerdsUid'] ?? '',
        uid = snapshot['uid'] ?? '',
        chatid = snapshot['chatid'] ?? '';


  toJson() {
    return {
      if(pid != null) "pid" : pid,
      if(providerdsUid != null) "providerdsUid": providerdsUid ?? '',
      if(uid != null) "uid": uid,
      if(chatid != null) 'chatid' : chatid,
    };
  }

}

class ChatMessage {

  String sender;
  String text;
  FieldValue time;

  ChatMessage({this.sender,this.text,this.time});

  ChatMessage.fromMap(Map snapshot) :
        sender = snapshot['sender'] ?? '',
        text = snapshot['text'] ?? '',
        time = snapshot['time'] ?? '';


  toJson() {
    return {
      if(sender != null) "sender" : sender,
      if(text != null) "text" : text,
      if(time != null) "time" : time,
    };
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {

  String pid;
  String providerdsUid;
  String uid;
  String chatid;
  bool userHasUnreadMessage;
  bool providerHasUnreadMessage;
  bool isDeleted;
  String lastMessage;
  Timestamp time;

  Chat({this.pid, this.isDeleted, this.providerdsUid, this.uid, this.chatid, this.userHasUnreadMessage, this.providerHasUnreadMessage, this.lastMessage, this.time});


  Chat.fromMap(Map snapshot) :
        pid = snapshot['pid'] ?? '',
        providerdsUid = snapshot['providerdsUid'] ?? '',
        uid = snapshot['uid'] ?? '',
        userHasUnreadMessage = snapshot['userHasUnreadMessage'] ?? false,
        providerHasUnreadMessage = snapshot['providerHasUnreadMessage'] ?? false,
        isDeleted = snapshot['isDeleted'] ?? false,
        lastMessage = snapshot['lastMessage'] ?? '',
        chatid = snapshot['chatid'] ?? '',
        time = snapshot['time'] ?? Timestamp.now();


  toJson() {
    return {
      if(pid != null) "pid" : pid,
      if(providerdsUid != null) "providerdsUid": providerdsUid ?? '',
      if(uid != null) "uid": uid,
      if(isDeleted !=null) 'isDeleted' : isDeleted,
      if(chatid != null) 'chatid' : chatid,
      if(providerHasUnreadMessage != null) 'providerHasUnreadMessage' : providerHasUnreadMessage,
      if(userHasUnreadMessage != null) 'userHasUnreadMessage' : userHasUnreadMessage,
      if(lastMessage!=null) 'lastMessage' : lastMessage,
      if(time != null) "time" : time,
    };
  }
}

class ChatMessage {

  String sender;
  String text;
  Timestamp time;

  ChatMessage({this.sender,this.text,this.time});

  ChatMessage.fromMap(Map snapshot) :
        sender = snapshot['sender'] ?? '',
        text = snapshot['text'] ?? '',
        time = snapshot['time'] ?? Timestamp.now();


  toJson() {
    return {
      if(sender != null) "sender" : sender,
      if(text != null) "text" : text,
      if(time != null) "time" : time,
    };
  }

}

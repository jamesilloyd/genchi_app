import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String pid;
  String uid;
  String chatid;
  bool userHasUnreadMessage;
  bool providerHasUnreadMessage;
  bool isHiddenFromUser;
  bool isHiddenFromProvider;
  String lastMessage;
  Timestamp time;

  Chat(
      {this.pid,
      this.uid,
      this.chatid,
      this.userHasUnreadMessage,
      this.providerHasUnreadMessage,
      this.lastMessage,
      this.isHiddenFromProvider,
      this.isHiddenFromUser,
      this.time});

  Chat.fromMap(Map snapshot)
      : pid = snapshot['pid'] ?? '',
        uid = snapshot['uid'] ?? '',
        userHasUnreadMessage = snapshot['userHasUnreadMessage'] ?? false,
        providerHasUnreadMessage =
            snapshot['providerHasUnreadMessage'] ?? false,
        lastMessage = snapshot['lastMessage'] ?? '',
        chatid = snapshot['chatid'] ?? '',
        isHiddenFromProvider = snapshot['isHiddenFromProvider'] ?? false,
        isHiddenFromUser = snapshot['isHiddenFromUser'] ?? false,
        time = snapshot['time'] ?? Timestamp.now();

  toJson() {
    return {
      if (pid != null) "pid": pid,
      if (uid != null) "uid": uid,
      if (chatid != null) 'chatid': chatid,
      if (providerHasUnreadMessage != null)
        'providerHasUnreadMessage': providerHasUnreadMessage,
      if (userHasUnreadMessage != null)
        'userHasUnreadMessage': userHasUnreadMessage,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (isHiddenFromProvider != null)
        "isHiddenFromProvider": isHiddenFromProvider,
      if (isHiddenFromUser != null) "isHiddenFromUser": isHiddenFromUser,
      if (time != null) "time": time,
    };
  }
}



class ChatMessage {
  String sender;
  String text;
  Timestamp time;

  ChatMessage({this.sender, this.text, this.time});

  ChatMessage.fromMap(Map snapshot)
      : sender = snapshot['sender'] ?? '',
        text = snapshot['text'] ?? '',
        time = snapshot['time'] ?? Timestamp.now();

  toJson() {
    return {
      if (sender != null) "sender": sender,
      if (text != null) "text": text,
      if (time != null) "time": time,
    };
  }
}

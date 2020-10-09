import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {

  ///id1 is usually the chat initiator
  String id1;
  String id2;
  String chatid;
  bool user1HasUnreadMessage;
  bool user2HasUnreadMessage;
  bool isHiddenFromUser1;
  bool isHiddenFromUser2;
  String lastMessage;
  Timestamp time;
  ///This is needed for querying
  List<dynamic> ids;

  Chat(
      {this.id1,
      this.id2,
      this.ids,
      this.chatid,
      this.user1HasUnreadMessage,
      this.user2HasUnreadMessage,
      this.lastMessage,
      this.isHiddenFromUser1,
      this.isHiddenFromUser2,
      this.time});

  Chat.fromMap(Map snapshot)
      : id1 = snapshot['id1'] ?? snapshot['uid'] ?? '',
        id2 = snapshot['id2'] ?? snapshot['pid'] ?? '',
        ids = snapshot['ids'] ?? [],
        user1HasUnreadMessage = snapshot['user1HasUnreadMessage'] ?? snapshot['userHasUnreadMessage'] ?? false,
        user2HasUnreadMessage = snapshot['user2HasUnreadMessage'] ?? snapshot['providerHasUnreadMessage'] ?? false,
        lastMessage = snapshot['lastMessage'] ?? '',
        chatid = snapshot['chatid'],
        isHiddenFromUser1 = snapshot['isHiddenFromUser1'] ?? snapshot['isHiddenFromUser'] ?? false,
        isHiddenFromUser2 = snapshot['isHiddenFromUser2'] ?? snapshot['isHiddenFromProvider'] ?? false,
        time = snapshot['time'] ?? Timestamp.now();

  toJson() {
    return {
      if (id1 != null) "id1": id1,
      if (id2 != null) "id2": id2,
      if (ids != null) "ids": ids,
      if (chatid != null) 'chatid': chatid,
      if (user2HasUnreadMessage != null)
        'user2HasUnreadMessage': user2HasUnreadMessage,
      if (user1HasUnreadMessage != null)
        'user1HasUnreadMessage': user1HasUnreadMessage,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (isHiddenFromUser1 != null) "isHiddenFromUser1": isHiddenFromUser1,
      if (isHiddenFromUser2 != null) "isHiddenFromUser2": isHiddenFromUser2,
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

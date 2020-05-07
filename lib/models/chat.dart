import 'package:flutter/widgets.dart';

class Chat extends ChangeNotifier {

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

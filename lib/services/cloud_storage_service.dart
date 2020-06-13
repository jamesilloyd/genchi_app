import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';



class CloudStorageService {


  Future<CloudStorageResult> uploadImage({ @required File imageToUpload, @required String title}) async {

    var imageFileName = title + DateTime.now().millisecondsSinceEpoch.toString();

    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(imageFileName);

    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);

    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;

    var downladUrl = await storageSnapshot.ref.getDownloadURL();

    if(uploadTask.isComplete) {
      var url = downladUrl.toString();
      return CloudStorageResult(
        imageURL: url,
        imageFileName: imageFileName,
      );

    }
    return null;

  }


}

class CloudStorageResult {
  final String imageURL;
  final String imageFileName;

  CloudStorageResult({this.imageFileName, this.imageURL});
}
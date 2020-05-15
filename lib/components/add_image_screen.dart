import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/components/platform_alerts.dart';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

/* TODO: things left to do here:
    -handle timeout/failure errors
 */

Color _iconColor = Color(kGenchiCream);

class AddImageScreen extends StatefulWidget {
  @override
  _AddImageScreenState createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {

  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();
  bool uploadStarted = false;
  File _imageFile;
  bool noChangesMade = true;

  Future<void> _pickImage(ImageSource source) async {

    //TODO: You can pass in image selection properties here
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      if (selected != null) {
        noChangesMade = false;
        uploadStarted = false;
      }
      _imageFile = selected;
    });
  }

  //Remove image
  void _clear() {
    setState(() {
      noChangesMade = true;
      _imageFile = null;
    });
  }


  //Croper plugin
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        cropStyle: CropStyle.circle,
        compressFormat: ImageCompressFormat.png,
        //TODO: MUST check to see what this looks like
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop It',
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Photo',
        ));

    setState(() {
      if (cropped != null) {
        noChangesMade = false;
        uploadStarted = false;
      }
      _imageFile = cropped ?? _imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;

    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(kGenchiGreen),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  'Change Display Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: _iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.75 - 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _imageFile == null
                    ? CircleAvatar(
                        radius: (MediaQuery.of(context).size.height * 0.75 - 130) * 0.35,
                        backgroundColor: Color(kGenchiCream),
                        backgroundImage: currentUser.displayPictureURL!=null ? CachedNetworkImageProvider(currentUser.displayPictureURL) : null,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(_imageFile),
                        radius:
                            (MediaQuery.of(context).size.height * 0.75 - 130) *
                                0.35,
                        backgroundColor: Color(kGenchiCream),
                      ),
                SizedBox(
                  height: 30,
                  child: Center(
                    child: IconButton(
                      color: _iconColor,
                      iconSize: 25,
                      icon: Icon(Icons.crop),
                      onPressed: _imageFile == null ? () {} : _cropImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 40) / 3,
                  child: IconButton(
                    icon: Icon(
                      Platform.isIOS
                          ? CupertinoIcons.photo_camera_solid
                          : Icons.photo_camera,
                      size: 25,
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    color: _iconColor,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 40) / 3,
                  child: IconButton(
                    icon: Icon(
                      Platform.isIOS
                          ? CupertinoIcons.collections_solid
                          : Icons.photo_library,
                      size: 25,
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    color: _iconColor,
                  ),
                ),
                noChangesMade
                    ? SizedBox(
                        width: (MediaQuery.of(context).size.width - 40) / 3,
                        child: IconButton(
                          icon: Icon(
                            Platform.isIOS
                                ? CupertinoIcons.delete_solid
                                : Icons.delete,
                            size: 25,
                          ),
                          onPressed: () {
                            Platform.isIOS
                                ? showAlertIOS(context: context, actionFunction: () async {
                                  await firestoreAPI.deleteUserDisplayPicture(user: currentUser);
                                  await authProvider.updateCurrentUserData();
                                  Navigator.of(context).pop();

                            }, alertMessage: "Delete Current Picture")
                                : showAlertAndroid(context: context, actionFunction: () async {
                                  await firestoreAPI.deleteUserDisplayPicture(user: currentUser);
                                  await authProvider.updateCurrentUserData();
                                  Navigator.of(context).pop();

                            }, alertMessage: "Delete Current Picture");
                          setState(() {});
                            },
                          color: _iconColor,
                        ),
                      )
                    : SizedBox(
                        width: (MediaQuery.of(context).size.width - 40) / 3,
                        child: uploadStarted
                            ? Uploader(file: _imageFile)
                            : IconButton(
                                iconSize: 25,
                                color: _iconColor,
                                icon: Icon(
                                  Platform.isIOS
                                      ? CupertinoIcons.check_mark_circled
                                      : Icons.check_circle_outline,
                                ),
                                onPressed: () {
                                  setState(() => uploadStarted = true);
                                },
                              ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}






// Widget used to handle the management of sending files
class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}


class _UploaderState extends State<Uploader> {
  final FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://genchi-c96c1.appspot.com');

  StorageUploadTask _uploadTask;
  String filePath;

  Future<bool> updateUserDisplayPicture() async {
    final authProvider = Provider.of<AuthenticationService>(context,listen: false);

    try {
      filePath = 'images/users/${authProvider.currentUser.id}${DateTime.now()}.png';
      StorageReference ref = _storage.ref().child(filePath);
      print('Uploading image');
      _uploadTask = ref.putFile(widget.file);
      StorageTaskSnapshot storageSnapshot = await _uploadTask.onComplete;
      print('downloading url');
      String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      print(downloadUrl);
      String oldFileName = authProvider.currentUser.displayPictureFileName;
      print('Updating firestore');
      await firestoreAPI.updateUser(
          user: User(
              displayPictureFileName: filePath, displayPictureURL: downloadUrl),
          uid: authProvider.currentUser.id);
      print('Updating current user');
      await authProvider.updateCurrentUserData();
      print('Deleting old file');
      if (oldFileName != null)
        await FirebaseStorage.instance.ref().child(oldFileName).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> successfullUpload;


  @override
  void initState() {
    super.initState();
    successfullUpload = updateUserDisplayPicture();
  }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
        future: successfullUpload,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_iconColor),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            );
          }

          if (snapshot.data) {
            return IconButton(
              iconSize: 25,
              color: _iconColor,
              icon: Icon(
                Platform.isIOS
                    ? CupertinoIcons.check_mark_circled_solid
                    : Icons.check_circle,
              ),
              onPressed: () {},
            );
          } else {
            return IconButton(
              iconSize: 25,
              color: _iconColor,
              icon: Icon(Icons.error),
              //TODO Maybe add in a snackbar here
              onPressed: () {},
            );
          }
        },
      );
  }
}

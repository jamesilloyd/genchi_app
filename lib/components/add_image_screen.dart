import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/provider_service.dart';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

/* TODO: things left to do here:
    -handle timeout/failure errors
 */

Color _iconColor = Color(kGenchiCream);

class AddImageScreen extends StatefulWidget {

  final bool isUser;

  AddImageScreen({Key key, @required this.isUser}) : super(key: key);

  @override
  _AddImageScreenState createState() => _AddImageScreenState();
}


class _AddImageScreenState extends State<AddImageScreen> {

  bool showSpinner = false;

  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  bool uploadStarted = false;
  File _imageFile;
  bool noChangesMade = true;

  Future<void> _pickImage(ImageSource source) async {

    //TODO: You can pass in image selection properties here
    File selected = await ImagePicker.pickImage(source: source, imageQuality: 100);

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

    setState(() {
      showSpinner = true;
    });

    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        cropStyle: CropStyle.circle,
        compressFormat: ImageCompressFormat.png,
        androidUiSettings: AndroidUiSettings(
          backgroundColor: Color(kGenchiCream),
          toolbarTitle: 'Crop Photo',
          toolbarColor: Color(kGenchiGreen),
          toolbarWidgetColor: Color(kGenchiCream),
          activeControlsWidgetColor: Color(kGenchiOrange),
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Photo',
        ));

    setState(() {
      showSpinner = false;
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
    final providerService = Provider.of<ProviderService>(context);
    ProviderUser currentProvider = providerService.currentProvider;

    //TODO: clean up showModalBottomSheetWidgets
    return ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: CircularProgress(),
      child: Container(
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
              child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          'Change All Display Pictures',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.0,
                            color: _iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    GestureDetector(
                      onTap: (){Navigator.pop(context);},
                      child: Icon(Icons.close, color: Color(kGenchiCream),),
                    )
                  ],
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
                          backgroundImage: (widget.isUser ? currentUser.displayPictureURL : currentProvider.displayPictureURL) !=null ? (widget.isUser ? CachedNetworkImageProvider(currentUser.displayPictureURL) : CachedNetworkImageProvider(currentProvider.displayPictureURL)): null,
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(_imageFile),
                          radius:
                              (MediaQuery.of(context).size.height * 0.75 - 130) *
                                  0.35,
                          backgroundColor: Color(kGenchiCream),
                        ),
                  _imageFile == null ? SizedBox(height: 30): SizedBox(
                    height: 30,
                    child:  Center(
                      child: IconButton(
                        color: _iconColor,
                        iconSize: 25,
                        icon: Icon(Icons.crop),
                        onPressed: _cropImage,
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
                                    widget.isUser ? await firestoreAPI.deleteUserDisplayPicture(user: currentUser) : await firestoreAPI.deleteProviderDisplayPicture(provider: currentProvider);
                                    widget.isUser ? await authProvider.updateCurrentUserData() : await providerService.updateCurrentProvider(currentProvider.pid);
                                    Navigator.of(context).pop();

                              }, alertMessage: "Delete Current Picture")
                                  : showAlertAndroid(context: context, actionFunction: () async {
                                    widget.isUser ? await firestoreAPI.deleteUserDisplayPicture(user: currentUser) : await firestoreAPI.deleteProviderDisplayPicture(provider: currentProvider);
                                    widget.isUser ? await authProvider.updateCurrentUserData() : await providerService.updateCurrentProvider(currentProvider.pid);
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
                              ? Uploader(file: _imageFile, isUser: widget.isUser,)
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
      ),
    );
  }
}






// Widget used to handle the management of sending files
class Uploader extends StatefulWidget {
  final File file;
  final bool isUser;

  Uploader({Key key, this.file, @required this.isUser}) : super(key: key);

  createState() => _UploaderState();
}


class _UploaderState extends State<Uploader> {
  final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://genchi-c96c1.appspot.com');

  StorageUploadTask _uploadTask;
  String filePath;

  Future<bool> updateDisplayPicture() async {
    final authProvider = Provider.of<AuthenticationService>(context,listen: false);
    final providerService = Provider.of<ProviderService>(context, listen: false);

    try {
      //TODO: put this into cloud_storage_service
      filePath = 'images/users/${authProvider.currentUser.id}${DateTime.now()}.png';
      StorageReference ref = _storage.ref().child(filePath);
      print('Uploading image');
      _uploadTask = ref.putFile(widget.file);
      StorageTaskSnapshot storageSnapshot = await _uploadTask.onComplete;
      print('downloading url');
      String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      print(downloadUrl);


      String oldFileName = widget.isUser ? authProvider.currentUser.displayPictureFileName : providerService.currentProvider.displayPictureFileName;
      print('Updating firestore user');

      await firestoreAPI.updateUser(user: User(displayPictureFileName: filePath, displayPictureURL: downloadUrl), uid: authProvider.currentUser.id);

      print('Updating firestore providers');

      for(String pid in authProvider.currentUser.providerProfiles) {
        await firestoreAPI.updateProvider(provider: ProviderUser(displayPictureFileName: filePath,displayPictureURL: downloadUrl), pid: pid);
      }

      print('Updating current user and provider');
      if(widget.isUser) {
        await authProvider.updateCurrentUserData();
      } else {
        await authProvider.updateCurrentUserData();
        await providerService.updateCurrentProvider(providerService.currentProvider.pid);
      }
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
    successfullUpload = updateDisplayPicture();
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

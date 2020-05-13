import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:genchi_app/constants.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';

/* TODO: things left to do here:
    -design 3 scenarios (has image, doesn't have image, added/changed image)
    -store file to correct location
    -handle timeout/failure errors
    -passing in user's current image as placeholder
 */

bool noChangesMade = true;

Color _iconColor = Color(kGenchiCream);

class AddImageScreen extends StatefulWidget {
  @override
  _AddImageScreenState createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  File _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      if(selected!=null) noChangesMade = false;
      _imageFile = selected;
    });
  }

  //Remove image
  void _clear() {
    //TODO: need to change this so that any existing image is passed back to avatar

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
        if(cropped!=null) noChangesMade = false;
      _imageFile = cropped ?? _imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      )
                    : CircleAvatar(
                  //ToDo, existing image, this should probably be stored on the device, only if one exists!
                        backgroundImage: FileImage(_imageFile),
                        radius: (MediaQuery.of(context).size.height * 0.75 - 130) * 0.35,
                        backgroundColor: Color(kGenchiCream),
                      ),
                SizedBox(
                  height: 30,
                  child: Center(
                    child: IconButton(
                      color: _iconColor,
                      iconSize: 25,
                      icon: Icon(Icons.crop),
                      onPressed: _imageFile == null ? (){}: _cropImage,
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
                  width: (MediaQuery.of(context).size.width -40)/3,
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
                  width: (MediaQuery.of(context).size.width -40)/3,
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
                  width: (MediaQuery.of(context).size.width -40)/3,
                      child: IconButton(
                          icon: Icon(
                            Platform.isIOS
                                ? CupertinoIcons.delete_solid
                                : Icons.delete,
                            size: 25,
                          ),
                          /* ToDo: add in functionality that asks if the user wants to delete
                             their image and will clear the display and show standard image
                   */
                          //                  onPressed: _clear,
                          onPressed: () {},
                          color: _iconColor,
                        ),
                    )
                    : SizedBox(
                  width: (MediaQuery.of(context).size.width -40)/3,
                    child: Uploader(file: _imageFile)),

//                IconButton(
//                        icon: Icon(
//                          Platform.isIOS
//                              ? CupertinoIcons.clear_thick
//                              : Icons.clear,
//                          size: 25,
//                        ),
//                        //ToDo: add in functionality that asks if the user wants to reset changes
//                        //TODO this has also got to cancel any upload if clicked!
//                        onPressed: _clear,
//                        color: _iconColor,
//                      ),
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
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://genchi-c96c1.appspot.com');

  StorageUploadTask _uploadTask;

  _startUpload() {
    //TODO: change this to be the current users id
    String filePath = 'images/users/${DateTime.now()}.png';

    setState(() {
      noChangesMade = true;
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;

            //TODO: this doesn't work, but need to find a way to handle fails or timeouts
            if (!_uploadTask.isSuccessful) {
              print('Uncessessful');
            }
            if (_uploadTask.isComplete) {
              //TODO: must add file path to firestore
              //TODO: must update current user here

              print('Is complete');
              return IconButton(
                iconSize: 25,
                color: _iconColor,
                icon: noChangesMade
                    ? Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled_solid
                      : Icons.check_circle,
                )
                    : Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled
                      : Icons.check_circle_outline,
                ),
                onPressed: noChangesMade ? () {} : _startUpload,
              );
            } else if (_uploadTask.isInProgress) {
              print('inProgress');
              return FlatButton(
                onPressed: _uploadTask.pause,
                child: Container(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: CircularProgressIndicator(
//                    value: progressPercent,
                      valueColor: AlwaysStoppedAnimation<Color>(_iconColor),
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              );
            } else if(_uploadTask.isPaused) {
              return IconButton(
                iconSize: 25,
                color: _iconColor,
                icon: Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled
                      : Icons.check_circle_outline,
                ),
                onPressed: _uploadTask.resume,
              );
            }

            return Text("");

          });
    } else {
      return IconButton(
        iconSize: 25,
        color: _iconColor,
        icon: noChangesMade
            ? Icon(
                Platform.isIOS
                    ? CupertinoIcons.check_mark_circled_solid
                    : Icons.check_circle,
              )
            : Icon(
                Platform.isIOS
                    ? CupertinoIcons.check_mark_circled
                    : Icons.check_circle_outline,
              ),
        onPressed: noChangesMade ? () {} : _startUpload,
      );
    }
  }
}

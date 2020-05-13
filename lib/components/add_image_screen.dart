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
      _imageFile = selected;
    });
  }

  //Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  //Croper plugin
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        cropStyle: CropStyle.circle,
        compressFormat: ImageCompressFormat.png,
        //TODO: check to see what this looks like
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop It',
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Photo',
        ));

    setState(() {
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
//            color: Color(kGenchiCream),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (_imageFile != null) ...[
                  CircleAvatar(
                    radius:
                        (MediaQuery.of(context).size.height * 0.75 - 130) * 0.35,
                    backgroundImage: FileImage(_imageFile),
                    backgroundColor: Colors.transparent,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        color: _iconColor,
                        iconSize: 25,
                        icon: Icon(Icons.crop),
                        onPressed: _cropImage,
                      ),
                      Uploader(
                        file: _imageFile,
                      ),
                    ],
                  ),
                ] else ...[
                  CircleAvatar(
                    radius:
                    (MediaQuery.of(context).size.height * 0.75 - 130) * 0.35,
                    backgroundColor: Color(kGenchiCream),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.crop,
                        size: 25,
                        color: _iconColor,
                      ),
                      //Todo: add placeholder here
                      Uploader(
                        file: _imageFile,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Platform.isIOS
                        ? CupertinoIcons.photo_camera_solid
                        : Icons.photo_camera,
                    size: 25,
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                  color: _iconColor,
                ),
                IconButton(
                  icon: Icon(
                    Platform.isIOS
                        ? CupertinoIcons.collections_solid
                        : Icons.photo_library,
                    size: 25,
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  color: _iconColor,
                ),
                IconButton(
                  icon: Icon(
                    Platform.isIOS ? CupertinoIcons.delete_solid : Icons.delete,
                    size: 25,
                  ),
                  /*ToDo: add in functionality that asks if the user wants to delete
                     their image and will clear the display and show standard image
                   */
                  //                  onPressed: _clear,
                  onPressed: () {},
                  color: _iconColor,
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
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://genchi-c96c1.appspot.com');

  StorageUploadTask _uploadTask;

  _startUpload() {
    //TODO: change this
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
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

            //TODO: this doesn't work, but need to find a way to handle fails or timesout
            if (!_uploadTask.isSuccessful){
              print('Uncessessful');
            }

            if (_uploadTask.isComplete) {
              return SizedBox(
                height:25,
                width: 25,
                child: Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled_solid
                      : Icons.check_circle,
                  color: _iconColor,
                  size: 25,
                ),
              );
            } else if (_uploadTask.isInProgress) {
              return SizedBox(
                height: 40,
                child: Center(
                  child: Container(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
//                    value: progressPercent,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_iconColor),
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              );

            }

            return Text("");

            //TODO: MUST add file path to firestore and update current user

            //ToDo: implement this later
//                  if (_uploadTask.isPaused)
//                    FlatButton(
//                      child: Icon(Icons.play_arrow, size: 30),
//                      onPressed: _uploadTask.resume,
//                    ),
//                  if (_uploadTask.isInProgress)
//                    FlatButton(
//                      child: Icon(Icons.pause, size: 30),
//                      onPressed: _uploadTask.pause,
//                    ),


          });
    } else {
      return Container(
        child: IconButton(
          iconSize: 25,
          color: _iconColor,
          icon: Icon(
            Platform.isIOS
                ? CupertinoIcons.check_mark_circled
                : Icons.check_circle_outline,
          ),
          onPressed: _startUpload,
        ),
      );
    }
  }
}

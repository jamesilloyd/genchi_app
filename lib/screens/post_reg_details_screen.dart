import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/add_image_screen.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class PostRegDetailsScreen extends StatefulWidget {
  static const id = 'post_reg_details_screen';

  @override
  _PostRegDetailsScreenState createState() => _PostRegDetailsScreenState();
}

class _PostRegDetailsScreenState extends State<PostRegDetailsScreen> {
  TextEditingController bioController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();

  final FirestoreAPIService fireStoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  bool showSpinner = false;

  @override
  void dispose() {
    super.dispose();
    bioController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final accountService = Provider.of<AccountService>(context);
    GenchiUser currentUser = accountService.currentAccount;


    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            backgroundColor: Color(kGenchiGreen),
            title: Text(
              'A few extra details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            brightness: Brightness.light,
            actions: [
              FlatButton(
                  onPressed: () async {


                    bool skip = await showYesNoAlert(
                        context: context,
                        title: "Are you sure you want to skip?",
                        body: "You can set up your account later.");

                    if (skip) {
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          HomeScreen.id,
                          (Route<dynamic> route) => false);
                    }
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
          backgroundColor: Colors.white,
          body: Builder(
            builder: (BuildContext context) {
              return ModalProgressHUD(
                inAsyncCall: showSpinner,
                progressIndicator: CircularProgress(),
                child: ListView(
                  padding: EdgeInsets.all(15.0),
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Display Picture',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0))),
                          builder: (context) => SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  child: AddImageScreen()),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          LargeDisplayPicture(
                            imageUrl: currentUser.displayPictureURL,
                            height: 0.25,
                            isEdit: true,
                          ),
                          Positioned(
                            right: (MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.height * 0.25) /
                                2,
                            top: MediaQuery.of(context).size.height * 0.2,
                            child: new Container(
                              height: 30,
                              width: 30,
                              padding: EdgeInsets.all(2),
                              decoration: new BoxDecoration(
                                  color: Color(kGenchiCream),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Color(0xff585858), width: 2)),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Center(
                                    child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Color(0xff585858),
                                )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (currentUser.accountType != 'Individual')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            height: 30.0,
                          ),
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          PopupMenuButton(
                              elevation: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                    border: Border.all(color: Colors.black)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                  child: Text(
                                    categoryController.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (_) {
                                List<PopupMenuItem<String>> items = [];
                                for (GroupType groupType in groupsList) {
                                  var newItem = new PopupMenuItem(
                                    child: Text(
                                      groupType.databaseValue,
                                    ),
                                    value: groupType.databaseValue,
                                  );
                                  items.add(newItem);
                                }
                                return items;
                              },
                              onSelected: (value) async {
                                setState(() {
                                  categoryController.text = value;
                                });
                              }),
                        ],
                      ),
                    if (currentUser.accountType != 'Individual')
                      EditAccountField(
                        field: 'Subcategory',
                        hintText:
                            'What type of ${categoryController.text == "" ? currentUser.accountType.toLowerCase() : categoryController.text.toLowerCase()} are you?',
                        onChanged: (value) {
                          // changesMade = true;
                        },
                        textController: subCategoryController,
                      ),
                    EditAccountField(
                      field: "About",
                      onChanged: (value) {
                        //Update name
                        // changesMade = true;
                      },
                      textController: bioController,
                      hintText: currentUser.accountType == 'Individual'
                          ? 'College, Interests, Societies, etc.'
                          : 'Describe what you do you.',
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: RoundedButton(
                        buttonTitle: 'Enter the platform',
                        fontColor: Colors.black,
                        buttonColor: Color(kGenchiLightOrange),
                        onPressed: () async {
                          bool ready = await showYesNoAlert(
                              context: context, title: 'Ready?');

                          if (ready) {
                            setState(() {
                              showSpinner = true;
                            });

                            await fireStoreAPI.updateUser(
                                user: GenchiUser(
                                    bio: bioController.text,
                                    category: categoryController.text,
                                    subcategory: subCategoryController.text),
                                uid: currentUser.id);

                            await accountService.updateCurrentAccount(
                                id: currentUser.id);

                            setState(() {
                              showSpinner = false;
                            });

                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomeScreen.id,
                                    (Route<dynamic> route) => false);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

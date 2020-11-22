// import 'dart:io' show Platform;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
//
// import 'package:genchi_app/components/circular_progress.dart';
// import 'package:genchi_app/components/display_picture.dart';
// import 'package:genchi_app/components/message_list_item.dart';
// import 'package:genchi_app/components/platform_alerts.dart';
// import 'package:genchi_app/components/rounded_button.dart';
// import 'package:genchi_app/components/snackbars.dart';
// import 'package:genchi_app/constants.dart';
// import 'package:genchi_app/models/screen_arguments.dart';
// import 'package:genchi_app/models/user.dart';
// import 'package:genchi_app/screens/application_chat_screen.dart';
// import 'package:genchi_app/screens/edit_task_screen.dart';
// import 'package:genchi_app/screens/user_screen.dart';
// import 'package:genchi_app/services/account_service.dart';
// import 'package:genchi_app/services/authentication_service.dart';
// import 'package:genchi_app/services/firestore_api_service.dart';
// import 'package:genchi_app/services/task_service.dart';
// import 'package:genchi_app/models/task.dart';
//
// import 'package:genchi_app/services/time_formatting.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// //TODO: WHEN FINISHED ADD IN ADMIN CONTROLLS
// //TODO: WHEN FINISHED ADD IN MODAL PROGRESS FOR ASYNC
// //TODO: do front end then add in the back end
// class TaskScreen extends StatefulWidget {
//   static const id = 'task_screen';
//
//   @override
//   _TaskScreenState createState() => _TaskScreenState();
// }
//
// TextStyle titleTextStyle = TextStyle(
//   fontSize: 20.0,
//   fontWeight: FontWeight.w500,
// );
//
// class _TaskScreenState extends State<TaskScreen> {
//   bool showSpinner = false;
//   static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
//   static final FirebaseAnalytics analytics = FirebaseAnalytics();
//   List userPidsAndId = [];
//
//   Future hirerFuture;
//   Future applicantsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     Task task = Provider.of<TaskService>(context, listen: false).currentTask;
//     hirerFuture = firestoreAPI.getUserById(task.hirerId);
//     applicantsFuture = firestoreAPI.getTaskApplicants(task: task);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (debugMode) print('Task Screen: activated');
//     final authProvider = Provider.of<AuthenticationService>(context);
//     final taskProvider = Provider.of<TaskService>(context);
//     final accountService = Provider.of<AccountService>(context);
//     GenchiUser currentUser = authProvider.currentUser;
//     Task currentTask = taskProvider.currentTask;
//     bool isUsersTask = currentTask.hirerId == currentUser.id;
//
//     userPidsAndId.clear();
//     userPidsAndId.addAll(currentUser.providerProfiles);
//     userPidsAndId.add(currentUser.id);
//
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(
//           color: Colors.black,
//         ),
//         centerTitle: true,
//         title: Text(
//           'Job',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 30,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: Color(kGenchiGreen),
//         elevation: 2.0,
//         brightness: Brightness.light,
//         actions: <Widget>[
//           if (isUsersTask)
//             IconButton(
//               icon: Icon(
//                 Icons.settings,
//                 size: 30,
//                 color: Colors.black,
//               ),
//               onPressed: () async {
//                 Navigator.pushNamed(context, EditTaskScreen.id);
//               },
//             )
//         ],
//       ),
//       bottomNavigationBar: ActionButton(
//         userpidsAndId: userPidsAndId,
//         applicantsFuture: applicantsFuture,
//         isUsersTask: isUsersTask,
//       ),
//       body: ModalProgressHUD(
//         inAsyncCall: showSpinner,
//         progressIndicator: CircularProgress(),
//         child: ListView(
//           padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Expanded(
//                   flex: 6,
//                   child: SelectableText(
//                     currentTask.title,
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Builder(
//                     builder: (context) {
//                       return IconButton(
//                         onPressed: () async {
//                           bool likesFeature = await showYesNoAlert(
//                               context: context,
//                               title: 'Share this job with a friend?');
//
//                           if (likesFeature != null) {
//                             analytics.logEvent(
//                                 name: 'share_job_button_pressed',
//                                 parameters: {'response': likesFeature});
//
//                             if (likesFeature) {
//                               Scaffold.of(context)
//                                   .showSnackBar(kDevelopmentFeature);
//                             }
//                           }
//                         },
//                         icon: Icon(
//                           Platform.isIOS ? Icons.ios_share : Icons.share,
//                           size: 25,
//                         ),
//                       );
//                     },
//                     // child:
//                   ),
//                 )
//               ],
//             ),
//             Divider(
//               thickness: 1,
//               height: 10,
//             ),
//             SizedBox(
//               height: 5,
//             ),
//
//             ///APPLICANT VIEW
//             isUsersTask
//                 ? HirerViewHeader(
//                     taskStatus: currentTask.status,
//                     applicantsFuture: applicantsFuture,
//                     task: currentTask,
//                     hirer: currentUser,
//                   )
//                 : ApplicantViewHeader(
//                     hirerFuture: hirerFuture,
//                     task: currentTask,
//                   ),
//
//             ///KEEP
//             TaskDetailsSection(
//               task: currentTask,
//               linkOpen: _onOpenLink,
//             ),
//
//             ///Show the applicant's application (this returns a sizedBox if not applied)
//             if (!isUsersTask)
//               ApplicantsApplication(
//                 applicantsFuture: applicantsFuture,
//                 userpidsAndId: userPidsAndId,
//                 task: currentTask,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _onOpenLink(LinkableElement link) async {
//     if (link.runtimeType == EmailElement) {
//       //TODO handle email elements
//     } else {
//       String url = link.url;
//       if (await canLaunch(url)) {
//         await launch(url);
//       } else {
//         throw 'Could not launch $link';
//       }
//     }
//   }
// }
//
// class ApplicantViewHeader extends StatelessWidget {
//   Future hirerFuture;
//   Task task;
//
//   ApplicantViewHeader({@required this.hirerFuture, @required this.task});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       ///We probably don't need to check that the user exists here as the
//       ///task would have been deleted if the hirer doesn't exist.
//       ///Worst case scenario the infite scoller appears
//       future: hirerFuture,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Text('');
//         }
//         GenchiUser hirer = snapshot.data;
//
//         return GestureDetector(
//           onTap: () async {
//             await Provider.of<AccountService>(context, listen: false)
//                 .updateCurrentAccount(id: task.hirerId);
//             Navigator.pushNamed(context, UserScreen.id);
//           },
//           child: Row(
//             children: [
//               ListDisplayPicture(imageUrl: hirer.displayPictureURL, height: 90),
//               SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       hirer.name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style:
//                           TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//                     ),
//                     Text(
//                       hirer.bio,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
//                     ),
//                     Text(
//                       "Posted ${getTaskPostedTime(time: task.time)}",
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style:
//                           TextStyle(fontSize: 14, color: Color(kGenchiOrange)),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class HirerViewHeader extends StatefulWidget {
//   static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
//   final String taskStatus;
//   final Task task;
//   final GenchiUser hirer;
//   Future applicantsFuture;
//
//   HirerViewHeader(
//       {@required this.taskStatus,
//       @required this.applicantsFuture,
//       @required this.task,
//       @required this.hirer});
//
//   @override
//   _HirerViewHeaderState createState() => _HirerViewHeaderState();
// }
//
// class _HirerViewHeaderState extends State<HirerViewHeader> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         FutureBuilder(
//           //TODO just double check whether or not the refresh still works
//           future: widget.applicantsFuture,
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return CircularProgress();
//             }
//
//             bool hirerHasUnreadNotification = false;
//
//             final List<Map<String, dynamic>> applicationAndApplicants =
//                 snapshot.data;
//
//             if (applicationAndApplicants.isEmpty) {
//               //TODO: jazz this up
//               return Container(
//                 color: Color(kGenchiCream),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 5),
//                     tileColor: Color(kGenchiCream),
//                     leading: ListDisplayPicture(
//                       imageUrl: widget.hirer.displayPictureURL,
//                       height: 56,
//                     ),
//                     title: Text(
//                       'No Applicants Yet',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     onTap: () {
//                       //TODO: route through to hirer's profile
//                     },
//                   ),
//                 ),
//               );
//             }
//
//             ///First create messageListItems for each chat
//             List<Widget> applicationChatWidgets = [];
//
//             for (Map<String, dynamic> applicationAndApplicant
//                 in applicationAndApplicants) {
//               TaskApplication taskApplication =
//                   applicationAndApplicant['application'];
//               GenchiUser applicant = applicationAndApplicant['applicant'];
//
//               if (taskApplication.hirerHasUnreadMessage)
//                 hirerHasUnreadNotification = true;
//
//               MessageListItem chatWidget = MessageListItem(
//                 imageURL: applicant.displayPictureURL,
//                 name: applicant.name,
//                 lastMessage: taskApplication.lastMessage,
//                 time: taskApplication.time,
//                 hasUnreadMessage: taskApplication.hirerHasUnreadMessage,
//                 onTap: () async {
//                   taskApplication.hirerHasUnreadMessage = false;
//
//                   ///update the task application
//                   await HirerViewHeader.firestoreAPI
//                       .updateTaskApplication(taskApplication: taskApplication);
//
//                   Navigator.pushNamed(context, ApplicationChatScreen.id,
//                           arguments: ApplicationChatScreenArguments(
//                               taskApplication: taskApplication,
//                               userIsApplicant: false,
//                               hirer: widget.hirer,
//                               applicant: applicant))
//                       .then((value) {
//                     setState(() {
//                       ///Recall future to update chats
//                       widget.applicantsFuture = HirerViewHeader.firestoreAPI
//                           .getTaskApplicants(task: widget.task);
//                     });
//                   });
//                 },
//                 //TODO: add this ability in
//                 hideChat: () {},
//               );
//
//               applicationChatWidgets.add(chatWidget);
//             }
//
//             return HirerTaskApplicants(
//               title: widget.task.title,
//               time: widget.task.time,
//               subtitleText:
//                   '${applicationChatWidgets.length} applicant${applicationChatWidgets.length == 1 ? '' : 's'}',
//               hasUnreadMessage: hirerHasUnreadNotification,
//               messages: applicationChatWidgets,
//               hirer: widget.hirer,
//             );
//           },
//         ),
//         Text('Job Status', style: titleTextStyle),
//         Divider(
//           thickness: 1,
//           height: 8,
//         ),
//         Text(
//           widget.taskStatus == 'Vacant'
//               ? 'ACCEPTING APPLICATIONS'
//               : (widget.taskStatus == 'InProgress'
//                   ? 'IN PROGRESS'
//                   : 'COMPLETED'),
//           style: TextStyle(fontSize: 22, color: Color(0xff5415BA)),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//
//         //TODO: turn this into a button like the share button.
//         if (widget.taskStatus != 'Vacant')
//           Container(
//             width: MediaQuery.of(context).size.width * 0.6 - 15,
//             height: (MediaQuery.of(context).size.width * 0.6 - 15) * 0.2,
//             decoration: BoxDecoration(
//               color: Color(kGenchiLightOrange),
//               borderRadius: BorderRadius.circular(50.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               child: FittedBox(
//                 fit: BoxFit.contain,
//                 child: Container(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.attach_money,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 5),
//                       Text(
//                         'Pay Applicant(s)',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//         SizedBox(
//           height: 10,
//         ),
//       ],
//     );
//   }
// }
//
// class TaskDetailsSection extends StatelessWidget {
//   Task task;
//   Function linkOpen;
//
//   TaskDetailsSection({this.task, this.linkOpen});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Category', style: titleTextStyle),
//         Divider(
//           thickness: 1,
//           height: 8,
//         ),
//         Text(
//           task.service.toUpperCase(),
//           style: TextStyle(fontSize: 22, color: Color(kGenchiOrange)),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         Container(
//           child:
//               Text("Details", textAlign: TextAlign.left, style: titleTextStyle),
//         ),
//         Divider(
//           thickness: 1,
//           height: 8,
//         ),
//         SelectableLinkify(
//           text: task.details ?? "",
//           onOpen: linkOpen,
//           options: LinkifyOptions(humanize: false),
//           style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
//         ),
//         SizedBox(height: 10),
//         Container(
//           child: Text("Job Timings",
//               textAlign: TextAlign.left, style: titleTextStyle),
//         ),
//         Divider(
//           thickness: 1,
//           height: 8,
//         ),
//         SelectableLinkify(
//           text: task.date ?? "",
//           onOpen: linkOpen,
//           options: LinkifyOptions(humanize: false),
//           style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
//         ),
//         SizedBox(height: 10),
//         Container(
//           child: Text("Incentive",
//               textAlign: TextAlign.left, style: titleTextStyle),
//         ),
//         Divider(
//           thickness: 1,
//           height: 8,
//         ),
//         SelectableText(
//           task.price ?? "",
//           style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
//         ),
//         SizedBox(height: 10),
//       ],
//     );
//   }
// }
//
// class ApplicantsApplication extends StatelessWidget {
//   static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
//
//   final Future applicantsFuture;
//   final List userpidsAndId;
//   final Task task;
//
//   ApplicantsApplication(
//       {@required this.applicantsFuture,
//       @required this.userpidsAndId,
//       @required this.task});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: applicantsFuture,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgress();
//         }
//
//         bool applied = false;
//         GenchiUser appliedAccount;
//         TaskApplication usersApplication;
//         final List<Map<String, dynamic>> applicantsAndProviders = snapshot.data;
//
//         for (var applicantAndProvider in applicantsAndProviders) {
//           GenchiUser applicant = applicantAndProvider['applicant'];
//           TaskApplication application = applicantAndProvider['application'];
//
//           if (userpidsAndId.contains(applicant.id)) {
//             ///currentUser has applied
//             applied = true;
//             appliedAccount = applicant;
//             usersApplication = application;
//           }
//         }
//
//         if (applied) {
//           ///user has already applied
//           List<Widget> widgets = [
//             Center(
//               child: Text(
//                 'Your Application',
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             Divider(
//               height: 0,
//               thickness: 1,
//             ),
//           ];
//
//           ///Show user's application
//           MessageListItem chatWidget = MessageListItem(
//             imageURL: appliedAccount.displayPictureURL,
//             name: appliedAccount.name,
//             lastMessage: usersApplication.lastMessage,
//             time: usersApplication.time,
//             hasUnreadMessage: usersApplication.applicantHasUnreadMessage,
//             onTap: () async {
//               // setState(() {
//               //   showSpinner = true;
//               // });
//               GenchiUser hirer = await firestoreAPI.getUserById(task.hirerId);
//
//               ///Check that the hirer exists before opening chat
//               if (hirer != null) {
//                 usersApplication.applicantHasUnreadMessage = false;
//                 await firestoreAPI.updateTaskApplication(
//                     taskApplication: usersApplication);
//
//                 // setState(() {
//                 //   showSpinner = false;
//                 // });
//
//                 ///Segue to application chat screen with user as the applicant
//                 Navigator.pushNamed(context, ApplicationChatScreen.id,
//                     arguments: ApplicationChatScreenArguments(
//                       hirer: hirer,
//                       userIsApplicant: true,
//                       taskApplication: usersApplication,
//                       applicant: appliedAccount,
//                     )).then((value) {
//                   //TODO: add in function to refresh screen
//                   // setState(() {});
//                 });
//               }
//             },
//             deleteMessage: 'Withdraw',
//             hideChat: () {},
//             //TODO: this is going at the bottom instead
//             // {
//             //   bool withdraw = await showYesNoAlert(
//             //       context: context, title: 'Withdraw your application?');
//             //
//             //   if (withdraw) {
//             //     setState(() {
//             //       showSpinner = true;
//             //     });
//             //
//             //     await analytics.logEvent(
//             //         name: 'applicant_removed_application');
//             //
//             //     await firestoreAPI.removeTaskApplicant(
//             //         applicantId: appliedAccount.id,
//             //         applicationId: usersApplication.applicationId,
//             //         taskId: usersApplication.taskid);
//             //
//             //     await Provider.of<AuthenticationService>(context,
//             //             listen: false)
//             //         .updateCurrentUserData();
//             //
//             //     setState(() {
//             //       showSpinner = false;
//             //     });
//             //   }
//             // }
//           );
//
//           widgets.add(chatWidget);
//
//           Widget withdraw = Center(
//             child: Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: RoundedButton(
//                 buttonTitle: 'Withdraw',
//                 buttonColor: Color(kGenchiLightGreen),
//                 //TODO: add in function
//                 onPressed: () {},
//                 fontColor: Colors.black,
//                 elevation: false,
//               ),
//             ),
//           );
//
//           widgets.add(withdraw);
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: widgets,
//           );
//         } else {
//           ///user has not applied
//           return SizedBox.shrink();
//         }
//       },
//     );
//   }
// }
//
// class ActionButton extends StatelessWidget {
//   final bool isUsersTask;
//   final Future applicantsFuture;
//   final List userpidsAndId;
//
//   ActionButton({
//     @required this.isUsersTask,
//     @required this.applicantsFuture,
//     @required this.userpidsAndId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       height: MediaQuery.of(context).size.height * 0.1,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//             horizontal: 80,
//             vertical: MediaQuery.of(context).size.height * 0.012),
//         child: isUsersTask
//             ? RoundedButton(
//                 elevation: false,
//                 buttonTitle: 'Change Job Status',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 buttonColor: Color(kGenchiLightGreen),
//                 fontColor: Colors.black,
//                 onPressed: () {},
//               )
//             : FutureBuilder(
//                 future: applicantsFuture,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return SizedBox.shrink();
//                   }
//
//                   bool applied = false;
//                   ///CHeck if the user has already applied to the task
//                   final List<Map<String, dynamic>> applicantsAndProviders =
//                       snapshot.data;
//
//                   for (var applicantAndProvider in applicantsAndProviders) {
//                     GenchiUser applicant = applicantAndProvider['applicant'];
//
//                     if (userpidsAndId.contains(applicant.id)) {
//                       ///currentUser has applied
//                       applied = true;
//                     }
//                   }
//
//                   if (applied) {
//                     ///User has already applied so remove bottom bar
//                     return SizedBox.shrink();
//                   } else {
//                     ///User has not applied so show them the apply button
//                     return RoundedButton(
//                       elevation: false,
//                       buttonTitle: 'APPLY',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       buttonColor: Color(kGenchiLightOrange),
//                       fontColor: Colors.black,
//                       onPressed: () {},
//                     );
//                   }
//                 }),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/registration_screen.dart';

class CompanyOrStudentScreen extends StatelessWidget {
  static const id = 'company_or_student_screen';

  const CompanyOrStudentScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(kGenchiGreen),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: MaterialButton(
              color: Color(kGenchiBlue),
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id,
                    arguments: RegistrationScreenArguments(
                        accountType: GenchiUser.companyAccount));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            'Who are you?',
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox.shrink()),
                    ],
                  ),
                  Icon(
                    Icons.business_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                  Text(
                    'Company',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: MaterialButton(
              color: Color(kGenchiGreen),
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id,
                    arguments: RegistrationScreenArguments(
                        accountType: GenchiUser.groupAccount));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group,
                    size: 100,
                    color: Colors.white,
                  ),
                  Text(
                    'Student Group',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: MaterialButton(
              color: Color(kGenchiOrange),
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id,
                    arguments: RegistrationScreenArguments(
                        accountType: GenchiUser.individualAccount));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                  Text(
                    'Individual Student',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

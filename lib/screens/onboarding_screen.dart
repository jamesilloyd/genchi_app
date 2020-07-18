import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/registration_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const id = 'onboarding_screen';

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index){
    setState(() {
      _currentPage = index;
    });
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(kGenchiGreen),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: sliderArrayList.length,
                itemBuilder: (ctx, i) => SlideItem(i),
              ),
              Stack(
                alignment: AlignmentDirectional.topStart,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 15.0, bottom: 15.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            if(_currentPage < 2) {
                              _currentPage++;
                              _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOutSine);
                            } else {
                              Navigator.pushNamed(context, RegistrationScreen.id);
                            }

                          });
                        },
                        child: Text(
                          _currentPage!=2 ? 'Next' : 'Get Started',
                          style: TextStyle(
                            fontWeight:  FontWeight.w500 ,
                            color: Color(kGenchiCream),
                            fontSize:_currentPage!=2 ? 16.0 : 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            if(_currentPage > 0) {
                              _currentPage--;
                              _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOutSine);
                            } else {
                              Navigator.pop(context);
                            }

                          });
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(kGenchiCream),
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.bottomCenter,
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (int i = 0; i < sliderArrayList.length; i++)
                          if (i == _currentPage)
                            SlideDots(true)
                          else
                            SlideDots(false)
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3.3),
      height: isActive ? 12 : 6,
      width: isActive ? 12 : 6,
      decoration: BoxDecoration(
        color: isActive ? Color(kGenchiOrange) : Color(kGenchiCream),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}


class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height*0.05,
        ),
        SizedBox(

          height: MediaQuery.of(context).size.height * 0.4,
          child: Image(
            alignment: Alignment.center,
            image:  AssetImage(sliderArrayList[index].sliderImageUrl),
            fit: BoxFit.fitHeight,
          ),
        ),
        Text(
          sliderArrayList[index].sliderHeading,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(kGenchiCream),
            fontSize: 35,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              sliderArrayList[index].sliderSubHeading,
              style: TextStyle(
                color: Color(kGenchiCream),
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
                fontSize: MediaQuery.of(context).size.height < 600 ? 11 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}


class Slider {
  final String sliderImageUrl;
  final String sliderHeading;
  final String sliderSubHeading;

  Slider(
      {@required this.sliderImageUrl,
        @required this.sliderHeading,
        @required this.sliderSubHeading});
}

final sliderArrayList = [
  Slider(
      sliderImageUrl: 'images/onboarding/onboarding1.png',
      sliderHeading: 'GENCHI',
      sliderSubHeading: 'Genchi is a Cambridge Student Services Marketplace that connects people in need of services (Hirers) with the people that can offer those services (Providers).'),
  Slider(
      sliderImageUrl: 'images/onboarding/hire.png',
      sliderHeading: 'HIRE',
      sliderSubHeading: 'We give you the freedom to easily select between service providers you need or post a job and choose from those that apply. \n \n All users are created with a hiring profile where you can add basic details about yourself and start hiring.'),
  Slider(
      sliderImageUrl: 'images/onboarding/provide.png',
      sliderHeading: 'PROVIDE',
      sliderSubHeading: 'We also allow you to effortlessly set up a provider profile alongside your hiring profile. You can create multiple provider profiles for each service you offer. \n\n Start applying to opportunities and begin gaining valuable experience.'),
];
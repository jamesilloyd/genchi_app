import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
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

  Animatable<Color> background = TweenSequence<Color>([
    TweenSequenceItem(
      weight: 10.0,
      tween: ColorTween(
        begin: Color(kGenchiGreen),
        end: Color(kGenchiOrange),
      ),
    ),
    TweenSequenceItem(
      weight: 10.0,
      tween: ColorTween(
        begin: Color(kGenchiOrange),
        end: Color(kGenchiGreen),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(kGenchiGreen),
        end: Color(kGenchiGreen),
      ),
    ),
  ]);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _currentPage == 1 ? Color(kGenchiLightOrange) : Color(kGenchiGreen),

      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: sliderArrayList.length,
              itemBuilder: (ctx, i) => SlideItems[i],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Stack(
                alignment: AlignmentDirectional.topStart,
                children: <Widget>[
                  if (_currentPage != 2)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0, bottom: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_currentPage < 2) {
                                _currentPage++;
                                _pageController.animateToPage(_currentPage,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOutSine);
                              } else {
                                Navigator.pushNamed(
                                    context, RegistrationScreen.id);
                              }
                            });
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0, bottom: 15.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_currentPage > 0) {
                              _currentPage--;
                              _pageController.animateToPage(_currentPage,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOutSine);
                            } else {
                              Navigator.pop(context);
                            }
                          });
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
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
                            SlideDots(true, i)
                          else
                            SlideDots(false, i)
                      ],
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

class SlideDots extends StatelessWidget {
  bool isActive;
  int page;

  SlideDots(this.isActive, this.page);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3.3),
      height: isActive ? 15 : 10,
      width: isActive ? 15 : 10,
      decoration: BoxDecoration(
        color: isActive
            ? (page == 1 ? Color(kGenchiGreen) : Color(kGenchiOrange))
            : Color(kGenchiCream),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );
  }
}

List SlideItems = [
  SlideItem1(),
  SlideItem2(),
  SlideItem3(),
];



class SlideItem1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Text(
          sliderArrayList[0].sliderHeading,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontSize: 35,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          child: Image(
            alignment: Alignment.center,
            image: AssetImage(sliderArrayList[0].sliderImageUrl),
            fit: BoxFit.fitWidth,
          ),
        ),

        SizedBox(height: 20),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              sliderArrayList[0].sliderSubHeading,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                wordSpacing: 2,
                height: 1.5,
                fontSize: MediaQuery.of(context).size.height < 600 ? 12 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}

class SlideItem2 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image(
              alignment: Alignment.center,
              image: AssetImage(sliderArrayList[1].sliderImageUrl),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Text(
          sliderArrayList[1].sliderHeading,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 35,
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              sliderArrayList[1].sliderSubHeading,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                wordSpacing: 2,
                height: 1.5,
                fontSize: MediaQuery.of(context).size.height < 600 ? 12 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class SlideItem3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image(
              alignment: Alignment.center,
              image: AssetImage(sliderArrayList[2].sliderImageUrl),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Text(
          sliderArrayList[2].sliderHeading,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 35,
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              sliderArrayList[2].sliderSubHeading,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                wordSpacing: 2,
                height: 1.5,
                fontSize: MediaQuery.of(context).size.height < 600 ? 12 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 70,
          width: MediaQuery.of(context).size.width*0.8,
          child: RoundedButton(
            buttonTitle: 'Get Started',
            onPressed: (){

              Navigator.pushNamed(
                  context, RegistrationScreen.id);
            },
            buttonColor: Color(kGenchiLightOrange),
            fontColor: Colors.black,
            elevation: true,
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
      sliderImageUrl: 'images/onboarding/Genchi.png',
      sliderHeading: 'WELCOME TO',
      sliderSubHeading:
          'Genchi is a Cambridge Student Services Marketplace that connects people in need of services (Hirers) with the people that can offer those services (Providers).'),
  Slider(
      sliderImageUrl: 'images/onboarding/Hire.png',
      sliderHeading: 'HIRE',
      sliderSubHeading:
          'We give you the freedom to easily select between service providers you need or post a job and choose from those that apply. \n \n All users are created with a hiring profile where you can add basic details about yourself and start hiring.'),
  Slider(
      sliderImageUrl: 'images/onboarding/Provide.png',
      sliderHeading: 'PROVIDE',
      sliderSubHeading:
          'We also allow you to effortlessly set up a provider profile alongside your hiring profile. You can create multiple provider profiles for each service you offer. \n\n Start applying to opportunities and begin gaining valuable experience.'),
];

import 'package:flutter/material.dart';
import 'package:instagram_project/pages/explore.dart';
import 'package:instagram_project/pages/home.dart';
import 'package:instagram_project/pages/notifications.dart';
import 'package:instagram_project/pages/profile.dart';
import 'package:instagram_project/pages/upload.dart';
import 'package:instagram_project/services/AuthorizationService.dart';
import 'package:instagram_project/services/NavigatorService.dart';
import 'package:provider/provider.dart';

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  int _pageIndex = 0;
  String aktifkullaniciID;
  PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<AuthorizationService>(context, listen: false).userId;

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (value) => _pageIndex = value,
        controller: pageController,
        children: [
          Home(),
          Explore(),
          Upload(),
          Notifications(),
          Profile(profileID: aktifKullaniciId)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: ("Explore")),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), label: ("Upload")),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: ("Activity")),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity), label: ("Profile")),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            pageController.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}

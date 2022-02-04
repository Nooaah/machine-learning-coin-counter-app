import '../utils/firebase_authentification.dart';
import 'package:flutter/material.dart';
import 'page_camera.dart';
import 'page_connexion.dart';


class PageDemarrage extends StatefulWidget {
  const PageDemarrage({
    Key ? key
  }): super(key: key);

  @override
  _PageDemarrageState createState() => _PageDemarrageState();
}

class _PageDemarrageState extends State < PageDemarrage > {
  @override
  void initState() {
    super.initState();
    FirebaseAuthentification authentification = FirebaseAuthentification();
    authentification.lireUtilisateur().then((user) async {
      MaterialPageRoute route;

      if (user == null) {
        route = MaterialPageRoute(builder: (context) => const PageCamera());
      } else {
        route = MaterialPageRoute(builder: (context) => const PageConnexion());
      }
      Navigator.pushReplacement(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
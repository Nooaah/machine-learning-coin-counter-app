// ignore_for_file: avoid_print

import 'package:evenements/pages/page_camera.dart';

import '../utils/firebase_authentification.dart';
import 'package:flutter/material.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({Key? key}) : super(key: key);

  @override
  _PageConnexionState createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  String? _idUtilisateur;

  bool _estConnectable = true;
  String? _message = '';

  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtMdp = TextEditingController();
  late FirebaseAuthentification authentification;

  @override
  void initState() {
    authentification = FirebaseAuthentification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: <Widget>[
                saisirEmail(),
                saisirMdp(),
                boutonPrincipal(),
                boutonSecondaire(),
                messageValidation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget saisirEmail() {
    return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: txtEmail,
          decoration:
              const InputDecoration(hintText: 'Email', icon: Icon(Icons.email)),
          validator: (texte) =>
              texte!.isEmpty ? 'Email address required' : '',
        ));
  }

  Widget saisirMdp() {
    return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: TextFormField(
          controller: txtMdp,
          keyboardType: TextInputType.emailAddress,
          obscureText: true,
          decoration: const InputDecoration(
              hintText: 'Mot de passe', icon: Icon(Icons.lock)),
          validator: (texte) =>
              texte!.isEmpty ? 'Password required' : '',
        ));
  }

  Widget boutonPrincipal() {
    String buttonText = _estConnectable ? 'Login 👋' : 'Register 📝';
    return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: SizedBox(
            height: 40,
            child: ElevatedButton(
              child: Text(buttonText),
              onPressed: soumettre,
              style: ElevatedButton.styleFrom(
                elevation: 4,
                onPrimary: Colors.white,
                primary: Theme.of(context).colorScheme.primary,
              ),
            )));
  }

  Widget boutonSecondaire() {
    String texte = !_estConnectable ? 'Login' : 'Register';
    return TextButton(
      child: Text(texte),
      onPressed: () {
        setState(() {
          _estConnectable = !_estConnectable;
        });
      },
    );
  }

  Widget messageValidation() {
    return Text(
      _message!,
      style: const TextStyle(
          fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Future soumettre() async {
    setState(() {
      _message = "";
    });

    try {
      if (_estConnectable) {
        _idUtilisateur =
            await authentification.connexion(txtEmail.text, txtMdp.text);
        print('Connexion pour l\'utilisateur $_idUtilisateur');
      } else {
        _idUtilisateur =
            await authentification.inscription(txtEmail.text, txtMdp.text);
        print('Inscription pour l\'utilisateur $_idUtilisateur');
      }
      if (_idUtilisateur != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PageCamera()));
      }
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    }
  }
}

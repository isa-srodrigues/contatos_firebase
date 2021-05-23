import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'PaginaLogin.dart';
import 'PaginaRegister.dart';

class PaginaEntry extends StatefulWidget {
  @override
  _PaginaEntryState createState() => _PaginaEntryState();

  PaginaEntry({Key key}) : super(key: key);
}

class _PaginaEntryState extends State<PaginaEntry> {
  TextEditingController _controllerLogin = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String firebaseError = "";

  void proximo(String email) async {
    try {
      var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if(methods.contains('password')) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaginaLogin(email:email))
        );
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaginaRegister(email:email))
        );
      }
      setState(() {
        firebaseError = "";
      });
    } on FirebaseAuthException catch (e) {
      errorCallback(e.message);
    }
  }

  void errorCallback(String message) {
    setState(() {
      firebaseError = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Login"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Form(
          key: _formKey,
          child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  'Bem vindo. Digite seu email.',
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "Login:",
                      hintText: "Digite o login",
                      errorText: firebaseError
                  ),
                  controller: _controllerLogin,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),
                RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text("Próximo", style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    )),
                    onPressed: (){
                      bool formOk = _formKey.currentState.validate();
                      if(!formOk){
                        return;
                      }else{
                        proximo(_controllerLogin.text);
                      }
                    }
                ),
              ]
          ),
        ),
      ),
    );
  }
}
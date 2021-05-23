import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'PaginaList.dart';

class PaginaLogin extends StatefulWidget {
  @override
  _PaginaLoginState createState() => _PaginaLoginState();

  final String email;

  const PaginaLogin({Key key, this.email}) : super(key: key);
}

class _PaginaLoginState extends State<PaginaLogin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerSenha = TextEditingController();
  String firebaseError = "";

  void login(String email, String pass) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      setState(() {
        firebaseError = "";
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PaginaList()),
            (Route<dynamic> route) => false,
      );
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
                  'Digite sua senha.',
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Senha:",
                    hintText: "Digite a senha",
                    errorText: firebaseError,
                  ),
                  controller: _controllerSenha,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 20),
                RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text("Login", style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    )),
                    onPressed: (){
                      bool formOk = _formKey.currentState.validate();
                      if(!formOk){
                        return;
                      }else{
                        login(widget.email, _controllerSenha.text);
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

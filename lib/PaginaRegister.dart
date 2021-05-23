import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'PaginaList.dart';

class PaginaRegister extends StatefulWidget {
  @override
  _PaginaRegisterState createState() => _PaginaRegisterState();

  final String email;

  const PaginaRegister({Key key, this.email}) : super(key: key);
}

class _PaginaRegisterState extends State<PaginaRegister> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerSenha2 = TextEditingController();
  String firebaseError = "";

  void register(String email, String pass) async {
    try {
      var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
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
        title: Text("Cadastrar"),
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
                  'Cadastro de novo usuário.',
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Senha:",
                    hintText: "Digite a senha",
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
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Senha:",
                    hintText: "Digite a senha novamente",
                    errorText: firebaseError,
                  ),
                  controller: _controllerSenha2,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    } else if(text != _controllerSenha.text) {
                      return "Senhas não correspondentes.";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 20),
                RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text("Cadastrar", style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    )),
                    onPressed: (){
                      bool formOk = _formKey.currentState.validate();
                      if(!formOk){
                        return;
                      }else{
                        register(widget.email, _controllerSenha.text);
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

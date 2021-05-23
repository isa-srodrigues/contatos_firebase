import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Contact.dart';

class PaginaContact extends StatefulWidget {
  @override
  _PaginaContactState createState() => _PaginaContactState();

  final Contact contact;

  const PaginaContact({Key key, this.contact}) : super(key: key);
}

class _PaginaContactState extends State<PaginaContact> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerEndereco = TextEditingController();
  TextEditingController _controllerCep = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if(widget.contact != null) {
      _controllerNome.text = widget.contact.nome;
      _controllerEmail.text = widget.contact.email;
      _controllerEndereco.text = widget.contact.endereco;
      _controllerCep.text = widget.contact.cep;
      _controllerTelefone.text = widget.contact.telefone;
    }
  }

  void delete(String id) {
    try {
      var uid = FirebaseAuth.instance.currentUser.uid;
      FirebaseFirestore.instance.collection('users/'+uid+"/contacts").doc(id).delete();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
    }
  }

  void save(Contact contact, String n, String em, String en, String c, String t) {
    try {
      var uid = FirebaseAuth.instance.currentUser.uid;
      if(contact == null) {
        FirebaseFirestore.instance.collection('users/'+uid+"/contacts").add({
          'name': n,
          'email': em,
          'address': en,
          'postal': c,
          'phone': t,
        });
      } else {
        FirebaseFirestore.instance.collection('users/'+uid+"/contacts").doc(contact.ID).set({
          'name': n,
          'email': em,
          'address': en,
          'postal': c,
          'phone': t,
        });
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
    }
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
        title: Text("Contato"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Form(
          key: _formKey,
          child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "Nome:",
                      hintText: "Digite o nome",
                  ),
                  controller: _controllerNome,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "Email:",
                      hintText: "Digite o email",
                  ),
                  controller: _controllerEmail,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "Endereco:",
                      hintText: "Digite o endereco",
                  ),
                  controller: _controllerEndereco,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "CEP:",
                      hintText: "Digite o CEP",
                  ),
                  controller: _controllerCep,
                  validator: (String text){
                    if(text.isEmpty){
                      return "Campo não pode estar vazio.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      labelText: "Telefone:",
                      hintText: "Digite o telefone",
                  ),
                  controller: _controllerTelefone,
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
                    child: Text("Salvar", style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    )),
                    onPressed: (){
                      bool formOk = _formKey.currentState.validate();
                      if(!formOk){
                        return;
                      }else{
                        save(widget.contact, _controllerNome.text, _controllerEmail.text, _controllerEndereco.text, _controllerCep.text, _controllerTelefone.text);
                      }
                    }
                ),
                SizedBox(height: 20),
                Visibility(
                  child: RaisedButton(
                      padding: EdgeInsets.all(16),
                      color: Colors.pink,
                      child: Text("Excluir", style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                      )),
                      onPressed: (){
                        delete(widget.contact.ID);
                      }
                  ),
                  visible: (widget.contact != null),
                )
              ]
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as bn;

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
  TextEditingController _controllerData = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File profilePicture;
  String imageURL = "";
  String aniversario = "";

  @override
  void initState() {
    super.initState();
    if(widget.contact != null) {
      _controllerNome.text = widget.contact.nome;
      _controllerEmail.text = widget.contact.email;
      _controllerEndereco.text = widget.contact.endereco;
      _controllerCep.text = widget.contact.cep;
      _controllerTelefone.text = widget.contact.telefone;
      imageURL = widget.contact.img;
      aniversario = widget.contact.aniversario;
      DateTime dt = DateTime.parse(widget.contact.aniversario);
      final df = new DateFormat('dd/MM');
      _controllerData.text = df.format(dt);
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

  void save(Contact contact, String n, String em, String en, String c, String t, File image, String b) {
    if(image == null) {
      saveData(contact, n, em, en, c, t, imageURL, b);
    } else {
      String fileName = bn.basename(image.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      uploadTask.then((value) {
        value.ref.getDownloadURL().then((url) {
          saveData(contact, n, em, en, c, t, url, b);
        }
        );
      },
      );
    }
  }

  void saveData(Contact contact, String n, String em, String en, String c, String t, String img, String b) {
    try {
      var uid = FirebaseAuth.instance.currentUser.uid;
      if(contact == null) {
        FirebaseFirestore.instance.collection('users/'+uid+"/contacts").add({
          'name': n,
          'email': em,
          'address': en,
          'postal': c,
          'phone': t,
          'image': img,
          'birthday': b,
        });
      } else {
        FirebaseFirestore.instance.collection('users/'+uid+"/contacts").doc(contact.ID).set({
          'name': n,
          'email': em,
          'address': en,
          'postal': c,
          'phone': t,
          'image': img,
          'birthday': b,
        });
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
    }
  }

  void buscarEndereco(String cep) async {
    var uri = Uri.parse("https://viacep.com.br/ws/${cep}/json/");
    http.Response response = await http.get(uri);
    Map<String, dynamic> data = json.decode(response.body);
    String lg = data["logradouro"];
    String c = data["complemento"];
    String b = data["bairro"];
    String lo = data["localidade"];
    setState(() {
      _controllerEndereco.text = "${lg}, ${c}, ${b}, ${lo}";
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(8),
                  ],
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
                  onChanged:(text) {
                    if(text.length == 8) {
                      buscarEndereco(text);
                    }
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
                TextFormField(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Aniversário:",
                    hintText: "Digite o aniversário"
                  ),
                  controller: _controllerData,
                  validator: (String text){
                      if(text.isEmpty){
                        return "Campo não pode estar vazio.";
                      }
                      return null;
                  },
                  onTap: () async {
                    DateTime date = DateTime(1900);
                    //FocusScope.of(context).requestFocus(new FocusNode());

                    date = await showDatePicker(
                        context: context,
                        initialDate:DateTime.now(),
                        firstDate:DateTime(1900),
                        lastDate: DateTime(2100));

                    final df = new DateFormat('dd/MM');

                    _controllerData.text = df.format(date);
                    aniversario = date.toIso8601String();
                  }
                ),
                SizedBox(height: 20),
                (profilePicture!=null) ?
                (Image(
                  width: 64,
                  height: 64,
                  image: FileImage(profilePicture),
                )) :
                (FadeInImage.assetNetwork(
                  width: 64,
                  height: 64,
                  placeholder: 'images/icon.jpg',
                  image: (imageURL!=null) ? (imageURL) : "",
                )),
                SizedBox(height: 20),
                RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text("Carregar Imagem", style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    )),
                    onPressed: () async{
                      final picker = ImagePicker();
                      final pickedFile = await picker.getImage(source: ImageSource.gallery);
                      setState(() {
                        profilePicture = File(pickedFile.path);
                      });
                    }
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
                        save(widget.contact, _controllerNome.text, _controllerEmail.text, _controllerEndereco.text, _controllerCep.text, _controllerTelefone.text, profilePicture, aniversario);
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

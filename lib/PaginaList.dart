import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Contact.dart';
import 'PaginaContact.dart';

class PaginaList extends StatefulWidget {
  @override
  _PaginaListState createState() => _PaginaListState();
}

class _PaginaListState extends State<PaginaList> {
  TextEditingController _controllerSearch = TextEditingController();
  List<Contact> contacts = List();
  String searchFilter = "";

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              refresh();
            },
          )
        ],
      ),
      body: Column(
          children: <Widget>[
            Container(
            margin: EdgeInsets.all(16),
            child: TextFormField(
              onChanged: (text) {
                setState(() {
                  searchFilter = text;
                });
              },
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: "Pesquisa:",
                hintText: "Pesquisa por nome",
              ),
              controller: _controllerSearch,
              validator: (String text){
                return null;
              },
            ),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: EdgeInsets.all(10.0),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return buildContact(context, index);
                  }
              ),
            ),
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newContact();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> refresh() async {
    try {
      var uid = FirebaseAuth.instance.currentUser.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users/'+uid+"/contacts").get();
      setState(() {
        contacts.clear();
        for(final c in querySnapshot.docs) {
          Contact cc = Contact();
          cc.ID = c.id;
          cc.nome = c.data()['name'];
          cc.email = c.data()['email'];
          cc.endereco = c.data()['address'];
          cc.cep = c.data()['postal'];
          cc.telefone = c.data()['phone'];
          contacts.add(cc);
        }
      });
    } on FirebaseAuthException catch (e) {
    }
  }

  void newContact() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaginaContact(contact:null))
    ).then((value) {
      refresh();
    });
  }

  void editContact(Contact contact) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaginaContact(contact:contact))
    ).then((value) {
      refresh();
    });
  }

  Widget buildContact(BuildContext context, int index) {
    var c = contacts[index];
    if(searchFilter.length > 0 && !c.nome.contains(searchFilter)) {
      return const SizedBox();
    }
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("images/icon.jpg"),
                            fit: BoxFit.cover)),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              contacts[index].nome ?? "",
                              style:
                              TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              contacts[index].email ?? "",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              contacts[index].endereco ?? "",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              contacts[index].cep ?? "",
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              contacts[index].telefone ?? "",
                              style: TextStyle(fontSize: 18.0),
                            )
                          ],
                        ),
                      ))
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 1,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.grey
                  )
                )
              )
            ]
        ),
      ),
      onTap: () {
        editContact(contacts[index]);
      },
    );
  }
}
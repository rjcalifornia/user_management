import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:architect_theme/api/users_list_api.dart';
import 'package:architect_theme/apps/home.dart';
import 'package:architect_theme/models/contacts_entity.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';

//Packages to select a file in flutter web
import 'dart:html' as html;
import 'dart:typed_data';

class AddNewUserForm extends StatefulWidget {
  AddNewUserForm({Key key}) : super(key: key);

  @override
  _AddNewUserFormState createState() => _AddNewUserFormState();
}

class _AddNewUserFormState extends State<AddNewUserForm> {
  int currStep = 0;

  //Variables for the file to upload
  List<int> _selectedFile;
  Uint8List _bytesData;
  String serverMessage;

  String _fileName;
  ContactsEntity contacts = new ContactsEntity();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  //This will let us open a file dialog and choose an image
  startWebFilePicker() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();
      setState(() {
        _fileName = uploadInput.files[0].name;
      });

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);
    });
  }

  //This function will convert the image selected from Bas64 to bytes data

  void _handleResult(Object result) {
    setState(() {
      _bytesData = Base64Decoder().convert(result.toString().split(",").last);
      _selectedFile = _bytesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // height: MediaQuery.of(context).size.height,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Enter user details',
              style: TextStyle(
                color: Color(0xff73879C),
                fontWeight: FontWeight.w500,
                fontSize: 26.0,
              ),
            ),
            SizedBox(
              height: 32.0,
            ),
            Container(
              //  height: MediaQuery.of(context).size.height,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 35.0),
              color: Color(0xffffffff),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Add user form',
                    style: TextStyle(
                        color: Color(0xff73879C),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w100),
                  ),
                  Divider(),
                  Text(
                    'Use this page to add a new user to the database',
                    style: TextStyle(
                        color: Color(0xff73879C),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w100),
                  ),
                  SizedBox(
                    height: 28.0,
                  ),
                  new Form(
                    key: _formKey,
                    child: new Stepper(
                      type: StepperType.vertical,
                      currentStep: this.currStep,
                      onStepContinue: () {
                        setState(() {
                          if (currStep < 5 - 1) {
                            currStep = currStep + 1;
                          } else {
                            currStep = 0;
                          }
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          if (currStep > 0) {
                            currStep = currStep - 1;
                          } else {
                            currStep = 0;
                          }
                        });
                      },
                      onStepTapped: (step) {
                        setState(() {
                          currStep = step;
                        });
                      },
                      controlsBuilder: (BuildContext context,
                          {VoidCallback onStepContinue,
                          VoidCallback onStepCancel}) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              currStep == 4 // this is the last step
                                  ? SizedBox(
                                      width: 95,
                                      child: Text(''),
                                    )
                                  : SizedBox(
                                      width: 105,
                                      child: RaisedButton(
                                        onPressed: onStepContinue,
                                        elevation: 4.0,
                                        color: Color(0xff313945),
                                        textColor: Colors.white,
                                        child: Text('Continue'),
                                      ),
                                    ),
                              currStep == 0
                                  ? Spacer()
                                  : FlatButton.icon(
                                      icon: Icon(Icons.arrow_back),
                                      label: const Text('Previous'),
                                      onPressed: onStepCancel,
                                    )
                            ],
                          ),
                        );
                      },
                      steps: [
                        Step(
                          title: const Text('Name:'),
                          isActive: true,
                          state: StepState.indexed,
                          content: new TextFormField(
                            keyboardType: TextInputType.text,
                            autocorrect: true,
                            decoration: new InputDecoration(
                              labelText: 'Enter the full name',
                              hintText: 'Example: John Doe',
                              icon: const Icon(Icons.person_outline),
                              labelStyle: new TextStyle(
                                  decorationStyle: TextDecorationStyle.solid),
                            ),
                            onSaved: (String value) {
                              contacts.fullname = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter valid name';
                              }
                            },
                          ),
                        ),
                        Step(
                          title: const Text('Username:'),
                          isActive: true,
                          state: StepState.indexed,
                          content: new TextFormField(
                            keyboardType: TextInputType.text,
                            autocorrect: true,
                            decoration: new InputDecoration(
                              labelText: 'Enter a valid username',
                              hintText: 'Example: john.doe',
                              icon: const Icon(Icons.verified_user),
                              labelStyle: new TextStyle(
                                  decorationStyle: TextDecorationStyle.solid),
                            ),
                            onSaved: (String value) {
                              contacts.username = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter valid username';
                              }
                            },
                          ),
                        ),
                        Step(
                          title: const Text('Email:'),
                          isActive: true,
                          state: StepState.indexed,
                          content: new TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: true,
                            decoration: new InputDecoration(
                              labelText: 'Enter a valid email',
                              hintText: 'Example: jdoe@example.com',
                              icon: const Icon(Icons.person_outline),
                              labelStyle: new TextStyle(
                                  decorationStyle: TextDecorationStyle.solid),
                            ),
                            validator: (value) {
                              if (value.isEmpty || !value.contains('@')) {
                                return 'Please enter valid email';
                              }
                            },
                            onSaved: (String value) {
                              contacts.email = value;
                            },
                          ),
                        ),
                        Step(
                          title: const Text('Phone number:'),
                          isActive: true,
                          state: StepState.indexed,
                          content: new TextFormField(
                            keyboardType: TextInputType.text,
                            autocorrect: true,
                            decoration: new InputDecoration(
                              labelText: 'Please enter a phone number',
                              hintText: 'Example: 501-308-8888',
                              icon: const Icon(Icons.phone_android),
                              labelStyle: new TextStyle(
                                  decorationStyle: TextDecorationStyle.solid),
                            ),
                            onSaved: (String value) {
                              contacts.phone = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a valid phone number';
                              }
                            },
                          ),
                        ),
                        Step(
                            title: const Text('Select a profile image:'),
                            isActive: true,
                            state: StepState.indexed,
                            content: Column(
                              children: <Widget>[
                                MaterialButton(
                                  color: Colors.pink,
                                  elevation: 8,
                                  highlightElevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  textColor: Colors.white,
                                  child: Text('Select a file'),
                                  onPressed: () {
                                    startWebFilePicker();
                                  },
                                ),
                                _fileName != null
                                    ? Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 22,
                                          ),
                                          Text("File selected: $_fileName"),
                                        ],
                                      )
                                    : Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 22,
                                          ),
                                          Text(
                                            "Image is required",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                              ],
                            )),
                      ],
                    ),
                  ),
                  RaisedButton(
                    child: Text('Send'),
                    onPressed: () {
                      _sendToSextan();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45.0,
            )
          ],
        ));
  }

  Future<String> _sendToSextan() async {
    final FormState formState = _formKey.currentState;
    if (!formState.validate() || _fileName == null) {
      showDialog(
          barrierDismissible: true,
          context: context,
          child: new AlertDialog(
            title: Text('Alert'),
            content: new Text('Please enter correct data'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ));
    } else {
      formState.save();
      var url = Uri.parse(api_v2);

      var request = new http.MultipartRequest("POST", url);
      request.fields['fullname'] = contacts.fullname;
      request.fields['username'] = contacts.username;
      request.fields['email'] = contacts.email;
      request.fields['phone'] = contacts.phone;
      request.files.add(await http.MultipartFile.fromBytes(
        'file',
        _selectedFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: _fileName,
      ));

      request.send().then((response) {
        //print("test");
        print(response.statusCode);
        if (response.statusCode.toString() == '200') {
          setState(() {
            serverMessage = "User was saved successfully";
          });
        }

        if (response.statusCode.toString() == '500') {
          setState(() {
            serverMessage = "There was a problem saving the user";
          });
        }
        showDialog(
            barrierDismissible: false,
            context: context,
            child: new AlertDialog(
              title: new Text("Detalles"),
              //content: new Text("Hello World"),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(serverMessage.toString()),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Dismiss'),
                  onPressed: () {
                    //Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
                    Navigator.pushNamed(context, '/dashboard/');

                    /*
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => GentelellaAdmin()),
                  (Route<dynamic> route) => false,
                );*/
                  },
                ),
              ],
            ));
      });


    }
  }
}

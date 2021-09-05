
import 'dart:io';
import 'dart:math';

import 'package:e_commerc/constans.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:e_commerc/widgets/custom_text.dart';
import 'package:e_commerc/services/store.dart';
import 'package:e_commerc/models/product.dart';
import 'package:image_picker/image_picker.dart';
class AddProduct extends StatefulWidget {
  static String id='AddProduct';
   GlobalKey<FormState>_globalKey=GlobalKey<FormState>();

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String _name,_price,_description;
  GlobalKey<FormState>_globalKey=GlobalKey<FormState>();

  var _image1, _image2, _image3, _image4;
bool waiting=false;
  String imageurl;

  Store _store=Store();
  Future getImage(var requierdImage) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      requierdImage = image;
    });
  }
  Future getImageFromCamera(var requierdImage) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      requierdImage = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Add Product',style: TextStyle(color: Colors.black),),backgroundColor: KmainColor,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _globalKey,
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                SizedBox(height: 30,),
                  CustomTextField(hint:'Product Name',
                    onClick: (value){
                      _name=value;
                    },),
                  SizedBox(height: 10,),
                  CustomTextField(hint:'Product price',onClick: (value){
                    _price=value;
                  } ,),
                  SizedBox(height: 10,),
                  CustomTextField(hint:'Product Description',onClick: (value){
                    _description=value;
                  }, ),
                  SizedBox(height: 10,),

                  SizedBox(height: 10,),
                  // CustomTextField(hint:'Product Location',onClick: (value){
                  //   _ImageLocation=value;
                  // } ,),
                  SizedBox(height: 20,),
                  Row(
crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _displayImagesGrids(),
                      _displayImagesGridsCamera(),
                    ],
                  ),
                  SizedBox(height: 20,),

             waiting==true?  RaisedButton(child: Text("waiting"),):  RaisedButton(
                    child: Text('Add Product',),

                    onPressed: ()async{
setState(() {
  waiting=true;
});
                      if(_globalKey.currentState.validate()){

                        if(_image1!=null)

                          imageurl= await UploadImage(_image1);


                      //  String imageurl2= await UploadImage(_image2);
                      // String imageurl3= await UploadImage(_image3);
                      else if(_image4!=null)

                        imageurl=await UploadImage(_image4);
                        try{

                         _globalKey.currentState.save();

                          _store.AddProduct(Product(
                              pDescription: _description,
                              plocation: imageurl,
                              pName: _name,
                              pPrice: _price
                          ));
                      _globalKey.currentState.reset();
                       setState(() {
                         waiting=false;
                       });
                        }
                        catch(e){
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('something wrong'),
                          ));
                          setState(() {
                            waiting=false;
                          });
                        }

                      }
                    },
                  )


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<String> UploadImage(var image) async {
    String name = Random().nextInt(1000).toString() + '_product';
    final StorageReference storageReference = FirebaseStorage.instance.ref().child(name);
    final StorageUploadTask UploadTask = storageReference.putFile(image);
    StorageTaskSnapshot respons = await UploadTask.onComplete;
    String URL = await respons.ref.getDownloadURL();

    return URL;
  }

  Widget _displayImagesGrids() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              child: Icon(
                Icons.photo_filter,

                //color: Colors.teal,
              ),
              onTap: () async {
               var image = await ImagePicker.pickImage(source: ImageSource.gallery);

                setState(() {
                  _image1 = image;
                });
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _displayImagesGridsCamera() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    var image =
                    await ImagePicker.pickImage(source: ImageSource.camera);

                    setState(() {
                      _image4 = image;
                    });
                  }),
            )
          ],
        )
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
void main() {
  runApp(MaterialApp(
    home: DetectMain(),
    debugShowCheckedModeBanner: false,
  ));
}

class DetectMain extends StatefulWidget {
  @override
  _DetectMainState createState() => _DetectMainState();
}

class _DetectMainState extends State<DetectMain> {
    File _image;
    double _imageWidth;
    double _imageHeight;
    var _recognitions;
  // charger le model en utilisant TFlite
    loadModel() async {
      Tflite.close();
      try {
        String res;
        res = await Tflite.loadModel(
          model: "assets/mobilenet.tflite",
          labels: "assets/labels.txt",
        );
        print(res);
      } on PlatformException {
        print("Erreur dans le chargement du model");
      }
    }
    // démarrer la prediction en utilisant TfLite en donnant l'image
    Future predict(File image) async {

      var recognitions = await Tflite.runModelOnImage(
          path: image.path,   // required
          imageMean: 0.0,   // defaults to 117.0
          imageStd: 255.0,  // defaults to 1.0
          numResults: 2,    // defaults to 5
          threshold: 0.2,   // defaults to 0.1
          asynch: true      // defaults to true
      );

      print(recognitions);

      setState(() {
        _recognitions = recognitions;
      });

    }
    // Envoyer l'image pour predite soit en selectionnant Gallery ou camera
    sendImage(File image) async {
      if(image == null) return;
      await predict(image);

      // get the width and height of selected image
      FileImage(image).resolve(ImageConfiguration()).addListener((ImageStreamListener((ImageInfo info, bool _){
        setState(() {
          _imageWidth = info.image.width.toDouble();
          _imageHeight = info.image.height.toDouble();
          _image = image;
        });
      })));
    }
    // select image from gallery
    selectFromGallery() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      if(image == null) return;
      setState(() {

      });
      sendImage(image);
    }

    // select image from camera
    selectFromCamera() async {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      if(image == null) return;
      setState(() {

      });
      sendImage(image);
    }
    // charger le model dans le debut de programme
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel().then((val){
      setState(() {});
    });
  }
    // Methode pour afficher la reconnaissance
    Widget printValue(recognize) {
      if (recognize == null) {
        return Text('', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
      }else if(recognize.isEmpty){
        return Center(
          child: Text("Pas de reconnaissance", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        );
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(0,0,0,0),
        child: Center(
          child: Text(
            "Prediction: "+_recognitions[0]['label'].toString().toUpperCase(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    // cette methode est appelé chaque fois que le widget a besoin
    // de re-rendre ou de construire
    @override
    Widget build(BuildContext context) {

      // obtenir la largeur et la hauteur de l'écran actuel sur lequel
      // l'application s'exécute
      Size size = MediaQuery.of(context).size;

      // initialiser deux variables qui représenteront la largeur
      // et la hauteur finales de la segmentation et l'aperçu de l'image à l'écran
      double finalW;
      double finalH;

      // lors du premier lancement de l'application, la largeur et la hauteur
      // de l'image seront généralement nulles.Par conséquent, pour la valeur
      // par défaut, la largeur et la hauteur de l'écran sont données
      if(_imageWidth == null && _imageHeight == null) {
        finalW = size.width;
        finalH = size.height;
      }else {

        // le rapport largeur et le rapport hauteur
        // donneront le rapport pour agrandir ou réduire l'image d'aperçu
        double ratioW = size.width / _imageWidth;
        double ratioH = size.height / _imageHeight;

        // largeur et hauteur finales après l'application
        // de la mise à l'échelle du rapport
        finalW = _imageWidth * ratioW*.85;
        finalH = _imageHeight * ratioH*.50;
      }

//    List<Widget> stackChildren = [];


      return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            title: Text("Smart Agriculture", style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.lightBlue,
            centerTitle: true,
          ),
          body: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0,30,0,30),
                child: printValue(_recognitions),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0,0,0,10),
                child: _image == null ? Center(child: Text("Selectionner l'image from camera or gallery"),): Center(child: Image.file(_image, fit: BoxFit.fill, width: finalW, height: finalH)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Container(
                      height: 50,
                      width: 150,
                      color: Colors.redAccent,
                      child: FlatButton.icon(
                        onPressed: selectFromCamera,
                        icon: Icon(Icons.camera_alt, color: Colors.white, size: 30,),
                        color: Colors.deepPurple,
                        label: Text(
                          "Camera",style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 150,
                    color: Colors.tealAccent,
                    child: FlatButton.icon(
                      onPressed: selectFromGallery,
                      icon: Icon(Icons.file_upload, color: Colors.white, size: 30,),
                      color: Colors.blueAccent,
                      label: Text(
                        "Gallery",style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  ),
                ],
              ),
            ],
          )
      );
    }
}



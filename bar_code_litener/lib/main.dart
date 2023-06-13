import 'dart:async';

import 'package:bar_code_litener/flutter_barcode_listener.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Barcode Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _barcode;
  String _debugStr = "";
  late bool visible;
  final _scanTextFieldController = TextEditingController();
  final _scanFocus = FocusNode();
  final _scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child:  Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Add visiblity detector to handle barcode
        // values only when widget is visible
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              VisibilityDetector(
                onVisibilityChanged: (VisibilityInfo info) {
                  visible = info.visibleFraction > 0;
                },
                key: Key('visible-detector-key'),
                child: BarcodeKeyboardListener(
                  bufferDuration: Duration(milliseconds: 1000),
                  onBarcodeScanned: (barcode) {
                    if (!visible) return;
                    print(barcode);
                    setState(() {
                      _barcode = barcode;
                    });
                  },
                  onDebugBarcodeScanner: (str){
                    setState(() {
                      _debugStr += str;
                      updateScroll();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _barcode == null ? 'SCAN BARCODE' : 'BARCODE: $_barcode',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 48,
              ),
              TextField(
                cursorColor: Colors.black,
                decoration: getScanBarCodeTextFieldStyle(
                    "enter manual code", () {
                  searchCode(_scanTextFieldController.text);
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  //searchCode(text);
                },
                onSubmitted: (text) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  searchCode(text);
                },
                onEditingComplete: () {
                  searchCode(_scanTextFieldController.text);
                },
                focusNode: _scanFocus,
                controller: _scanTextFieldController,
                textInputAction: TextInputAction.next,
              ),
              SizedBox( height: 28,),
              new Expanded(
              flex: 1,
              child: new SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,//.horizontal
                child:
                Text(_debugStr),
              ),),

              TextButton(onPressed: (){
                setState(() {
                      _debugStr = "";
                    });
              }, child: const Text("CLEAR DEBUG"))
            ],
          ),
        ),
      ),
    )
    );
  }
  
  void searchCode(String text) {
    print("searchCode : {$searchCode}");
    setState(() {
      _barcode = text;
    }); 
  }

  updateScroll() {
    Timer(
        Duration(milliseconds: 100),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));


    // var scrollPosition = _scrollController.position;
    //   _scrollController.animateTo(
    //     scrollPosition.maxScrollExtent,
    //     duration: new Duration(milliseconds: 200),
    //     curve: Curves.easeOut,
    //   );
  }
}


InputDecoration getScanBarCodeTextFieldStyle(
    String hintText, Function? action) {
  return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      enabledBorder: const OutlineInputBorder(
          gapPadding: 10,
          borderSide: BorderSide(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      focusedBorder: const OutlineInputBorder(
          gapPadding: 10,
          borderSide: BorderSide(width: 1, color: Colors.blue ),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      hintText: hintText,
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.black38,
        fontStyle: FontStyle.normal,
      ),
      contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      suffixIcon: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: 38,
          height: 38,
          child: getInputButton(action),
        ),
      ));
}

Widget getInputButton(Function? action) {
  return Builder(builder: (context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Colors.transparent),
        onPressed: (action != null)
            ? () {
                action();
              }
            : null,
        child: const Icon(
          Icons.send,
          color: Colors.black,
          size: 24.0,
        ),
      ),
    );
  });
}

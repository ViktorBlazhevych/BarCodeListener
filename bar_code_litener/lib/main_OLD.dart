import 'dart:async';

import 'package:bar_code_litener/flutter_barcode_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';
//import 'package:zebrascanner/zebrascanner.dart';

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
  String _tempBarcode = "";
  String _debugStr = "";
  late bool visible;
  final _scanTextFieldController = TextEditingController();
  final _scanFocus = FocusNode();
  final _customFocus = FirstDisabledFocusNode();
  final _scrollController = ScrollController();
  FocusNode _textNode = new FocusNode();

  String qrCodeText = "";

  @override
  void dispose() {
    _scanFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      // Init Zebra
      // initBarcodeReceiver();
      // initPlatformState();

      return GestureDetector(
          onTap: () {
            reFocus();
          },
          child: Scaffold(
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
                      child:

                          /*
                    BarcodeKeyboardListener(
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
                      child: 
                      */
                          Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _barcode == null
                                ? 'SCAN BARCODE'
                                : 'BARCODE: $_barcode',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                      //),
                    ),
                    SizedBox(
                      height: 48,
                    ),
                    TextField(
                      autofocus: true,
                      cursorColor: Colors.black,
                      decoration:
                          getScanBarCodeTextFieldStyle("enter manual code", () {
                        searchCode(_scanTextFieldController.text);
                        //FocusManager.instance.primaryFocus?.unfocus();
                        //FocusScope.of(context).requestFocus(_customFolus);
                      }),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        searchCode(text);
                      },
                      onSubmitted: (text) {
                        //FocusManager.instance.primaryFocus?.unfocus();
                        //searchCode(text, isSubmitted: true);
                        print("onSubmitted");
                      },
                      onEditingComplete: () {
                        print("onEditingComplete");
                        searchCode(_scanTextFieldController.text,
                            isSubmitted: true);
                      },
                      focusNode: _customFocus, // _scanFocus,
                      controller: _scanTextFieldController,
                      textInputAction: TextInputAction.search,
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    new Expanded(
                      flex: 1,
                      child: new SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical, //.horizontal
                        child: Text(_debugStr),
                      ),
                    ),

                    TextButton(
                        onPressed: () {
                          setState(() {
                            _debugStr = "";
                            qrCodeText = "";
                          });
                        },
                        child: const Text("CLEAR DEBUG")),
                    // --------------------------------------------------------------
                    // --------------------------------------------------------------
                    /*
                  RawKeyboardListener(
                    autofocus: true,
                    focusNode: _textNode,
                    onKey: (event) {
                      _debugStr += ("event -> ${event.toString()}\n\n");
                      _debugStr += ("event.data -> ${event.data}\n\n");
                      _debugStr +=
                                ("event.character -> ${event.character.toString()}\n\n");
                      
                      _debugStr += ("event.physicalKey.debugName -> ${event.physicalKey.debugName}\n\n");
                      _debugStr +=
                                ("event.logicalKey.keyId -> ${event.logicalKey.keyId}\n\n");
                      _debugStr +=
                                ("isKeyPressed(LogicalKeyboardKey.enter) -> ${event.isKeyPressed(LogicalKeyboardKey.enter)}\n\n");


                      //print("RawKeyboardListener Event: -> $event");
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey.keyLabel.length == 1) {
                          qrCodeText += event.logicalKey.keyLabel;
                        } else if (event.logicalKey.keyLabel == 'Enter') {
                          //print('Data received from the QR Code: $qrCodeText');
                        }
                      }

                      setState(() {
                              updateScroll();
                            });
                    },
                    child: Text('$qrCodeText')
                  ),
                  */
                  ],
                ),
              ),
            ),
          ));
    });
  }

  void reFocus() {
    if (!_customFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_customFocus);
    }
    SystemChannels.textInput.invokeMapMethod("TextInput.hide");
  }

  void searchCode(String text, {bool isSubmitted = false}) {
    if ((_tempBarcode.length - text.length).abs() == 1 || text.isEmpty) {
      _tempBarcode = text;
      return;
    } else {
      _tempBarcode = "";
      _scanTextFieldController.text = "";
      // if !(isSubmitted){

      // }
      Future.delayed(const Duration(milliseconds: 100), () {
        reFocus();
      });
      print("searchCodeMethod =>  {$text}");
    }

    // debug
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

// --------------------------------------------------------------
// --------------------------------------------------------------

  String _platformVersion = 'Unknown';

  dynamic map;

  StreamSubscription? subscription;

  String? eventData = "";
/*
  initBarcodeReceiver() {
    subscription = Zebrascanner.getBarCodeEventStream.listen((barcodeData) {
      setState(() {
        map = barcodeData;

        _debugStr += ("Zebrascanner MAP: -> $map\n");

        var _list = map.values.toList();

        // Barcode
        _debugStr += ("Zebrascanner Barcode: -> $_list[0]\n");
        //print(_list[0]);
        // BarcodeType
        _debugStr += ("Zebrascanner BarcodeType: -> $_list[1]\n");
        //print(_list[1]);
        _debugStr += ("Zebrascanner ScannerId: -> $_list[2]\n");
        // ScannerId
        //print(_list[2]);

        eventData = _list[0] + "-" + _list[1] + "-" + _list[2];
      });
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await Zebrascanner.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    _debugStr += ("Zebrascanner initPlatformState platformVersion: -> $_platformVersion\n");
    _debugStr += ("Zebrascanner initPlatformState mounted: -> $mounted\n");

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      updateScroll();
    });
  }
  */
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
          borderSide: BorderSide(width: 1, color: Colors.blue),
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

  // --------------------------------------------------------------
  // --------------------------------------------------------------
}

class FirstDisabledFocusNode extends FocusNode {
  // @override
  // bool consumeKeyboardToken() {
  //   return false;
  // }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

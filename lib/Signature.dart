import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signature/signature.dart';

class MySignature extends StatefulWidget {
  @override
  _MySignatureState createState() => _MySignatureState();
}

class _MySignatureState extends State<MySignature> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.blue,
    exportPenColor: Colors.black,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No content')));
      return;
    }

    final Uint8List? data = await _controller.toPngBytes();
    if (data == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.grey[300],
                child: Image.memory(data),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> exportSVG(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No content')));
      return;
    }

    final SvgPicture data = _controller.toSVG()!;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(color: Colors.grey[300], child: data),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: ListView(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //SHOW EXPORTED IMAGE IN NEW ROUTE
                    IconButton(
                      icon: const Icon(Icons.image),
                      color: Colors.blue,
                      onPressed: () => exportImage(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.polyline),
                      color: Colors.blue,
                      onPressed: () => exportSVG(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.undo());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.redo());
                      },
                    ),
                    //CLEAR CANVAS
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.clear());
                      },
                    ),
                  ],
                ),
              ),
              //SIGNATURE CANVAS
              Signature(
                controller: _controller,
                height: MediaQuery.of(context).size.height,
                backgroundColor: Colors.lightBlueAccent,
              ),
              //OK AND CLEAR BUTTONS
            ],
          ),
        ),
      ),
    );
  }
}

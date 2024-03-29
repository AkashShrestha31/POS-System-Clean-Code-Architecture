import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shoppos/core/constants/SizeConfig.dart';
import 'package:shoppos/features/boarding_screen/presentation/widgets/widgets.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Future<void> resumeCamera() async {
    await controller?.resumeCamera();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    resumeCamera();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 10, child: _buildQrView(context)),
          // if (result != null) Text('Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}') else const Text('Scan a code'),
          Expanded(
              flex: 1,
              child: Container(
                height: SizeConfig.screenHeight! * 0.07,
                color: Colors.grey.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {});
                      },
                      icon: Icon(Icons.flip_camera_ios),
                    ),
                    IconButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                          setState(() {});
                        },
                        icon: FutureBuilder(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return Icon(Icons.flash_on);
                            }
                            return Icon(Icons.flash_off_sharp);
                          },
                        )),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor, borderRadius: 10, borderLength: 20, borderWidth: 5, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

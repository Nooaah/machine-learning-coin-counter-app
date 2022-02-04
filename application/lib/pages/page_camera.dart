import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';

class PageCamera extends StatefulWidget {
  const PageCamera({Key? key}) : super(key: key);

  @override
  _PageCameraState createState() => _PageCameraState();
}

class _PageCameraState extends State<PageCamera> {
  File? imageFile;
  String? imageNetwork;
  String result_total_coin = "??";

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  void upload(File imageFile) async {
    // Open a bytestream
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // Get file length
    var length = await imageFile.length();

    // String to uri
    var uri = Uri.parse("http://192.168.1.12:5000/send_image");

    // Create multipart request
    var request = http.MultipartRequest("POST", uri);

    // Multipart that takes file
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    // Add file to multipart
    request.files.add(multipartFile);

    // Send
    var response = await request.send();

    // Listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      final jsonString = value.toString();
      final parsedJson = json.decode(jsonString);

      final coins_total = parsedJson['coins_total'];
      final calculated_image_path = parsedJson['calculated_image_path'];

      setState(() {
        result_total_coin = coins_total.toString();
        imageNetwork = calculated_image_path;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Coin Counter'),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 30),
            Column(
              children: [
                if (imageFile == null && imageNetwork == null) ...[
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ElevatedButton(
                      child: const Text('Take a picture with the camera'),
                      onPressed: () {
                        _getFromCamera();
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(12.0)),
                          textStyle: MaterialStateProperty.all(
                              const TextStyle(fontSize: 16))),
                    ),
                  ),
                  Center(
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: const Text(
                              'Hello World ! This application will allow you to calculate how many euros are on a picture. To start, click on the button above, and take a picture of your coins.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15))))
                ] else ...[
                  Text("Result: " + result_total_coin + " €",
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  if (imageNetwork != null) ...[
                    Image.network(imageNetwork!)
                  ] else if (imageFile != null) ...[
                    Image.file(imageFile!)
                  ],
                  const SizedBox(height: 5),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 39, 174, 96))),
                    child: const Text('Calculate money'),
                    onPressed: () async {
                      upload(imageFile!);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ElevatedButton(
                      child: const Text('Take another picture'),
                      onPressed: () {
                        setState(() {
                          imageNetwork = null;
                          result_total_coin = "??";
                        });
                        _getFromCamera();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ));
  }
}

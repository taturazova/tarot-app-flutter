import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TarotCard extends StatefulWidget {
  const TarotCard({super.key});
  @override
  TarotCardState createState() => TarotCardState();
}

class TarotCardState extends State<TarotCard> {
  String imageUrl = "";
  bool isLoading = false;
  List<String> keywords = [];

  @override
  Widget build(BuildContext context) {
    return VxFlip(
      front: _buildFrontWidget(),
      back: _buildBackWidget(),
      touchFlip: !isLoading,
    );
  }

  Widget _buildSurroundingContainer(Widget w) {
    double cardHeight = context.screenHeight * 0.5;
    double cardWidth = cardHeight / 1.7;
    return Card(
        elevation: 8.0,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: VxBox(child: w)
                .width(cardWidth)
                .height(cardHeight)
                .white
                .padding(Vx.m12)
                .make()));
  }

  Widget _buildFrontWidget() {
    return _buildSurroundingContainer(isLoading
        ? const Center(child: CircularProgressIndicator())
        : (imageUrl.isNotEmpty
            ? Image.network('http://52.36.235.243:5000${imageUrl}',
                fit: BoxFit.cover)
            : Container())); // Display image on front if available
  }

  Widget _buildBackWidget() {
    return _buildSurroundingContainer(isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (keywords.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: keywords
                      .map(
                        (keyword) => Text(keyword)
                            .text
                            .lg
                            .thin
                            .fontFamily(GoogleFonts.poppins().fontFamily!)
                            .make()
                            .py12(),
                      )
                      .toList(),
                )
              else
                const Text('...'),
            ],
          ));
  }

  // Function to fetch data from the API
  Future<void> fetchData(File? file) async {
    setState(() {
      isLoading = true;
    });
    // String imagePath = 'assets/images/thefool.jpg';

    // ByteData data = await rootBundle.load(imagePath);
    // List<int> bytes = data.buffer.asUint8List();

    // Read the contents of the file as bytes
    if (file == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    List<int> bytes = await file.readAsBytes();
    // Create a Uri from the URL string
    var uri = Uri.parse('http://52.36.235.243:5000/one_card_spread');

    // Create a MultipartRequest to upload the image
    var request = http.MultipartRequest('POST', uri);

    // Add the file to the request
    var multipartFile = http.MultipartFile.fromBytes(
      'image', // Field name for the file in the request
      bytes,
      filename: 'thefool.jpg',
      contentType:
          MediaType('image', 'jpeg'), // Adjust the content type as needed
    );
    request.files.add(multipartFile);

    // Send the request
    var response = await request.send();

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      isLoading = false;
      var result = jsonDecode(await response.stream.bytesToString());
      setState(() {
        imageUrl = result["img_url"]; // Replace with API result
        keywords = result["keywords"].cast<String>(); // Replace with API result
        isLoading = false;
      });
      return;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }
}

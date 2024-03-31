import 'dart:io';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/card.dart';

Color greenTouch = Vx.hexToColor("#788154");
final GlobalKey<TarotCardState> tarotCardKey = GlobalKey<TarotCardState>();
File? _selectedImage;

class CardView extends StatelessWidget {
  const CardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.hexToColor("#D3E5F5"),
      body: SafeArea(
          child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/app_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: TarotCard(
                  key: tarotCardKey,
                ),
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _UploadImageBottomSheet().displayBottomSheet(context);
        },
        backgroundColor: Colors.blue.shade900,
        elevation: 10.0,
        child: const Icon(Icons.add, color: Colors.white),
      ).p16(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

void fetchDataForTarotCard() {
  tarotCardKey.currentState?.fetchData(_selectedImage);
}

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key, required this.icon, required this.text, this.onPressed});
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.blueGrey; // Color for disabled state
            }
            return Colors.blue.shade800; // Default color for other states
          },
        )),
        icon: Icon(icon, color: Colors.white),
        label: Text(text)
            .text
            .lg
            .thin
            .color(Colors.white)
            .fontFamily(GoogleFonts.poppins().fontFamily!)
            .make());
  }
}

class _UploadImageBottomSheet with VxBottomSheet {
  Future displayBottomSheet(BuildContext context) async {
    await VxBottomSheet.bottomSheetView(context,
        backgroundColor: Colors.white,
        child: SizedBox(
          height: context.screenHeight * 0.2,
          child: Center(
              child: VStack(
            [
              "Upload your card photo from:"
                  .text
                  .lg
                  .color(Colors.blue.shade900)
                  .align(TextAlign.center)
                  .fontFamily(GoogleFonts.poppins().fontFamily!)
                  .make(),
              10.heightBox,
              HStack([
                MyButton(
                  icon: Icons.collections_rounded,
                  text: "Gallery",
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                12.widthBox,
                MyButton(
                  icon: Icons.camera_alt_outlined,
                  text: "Camera",
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                )
              ])
            ],
            alignment: MainAxisAlignment.center,
            crossAlignment: CrossAxisAlignment.center,
          )),
        ),
        enableDrag: true,
        roundedFromTop: true,
        barrierColor: Colors.black45,
        isDismissible: true);
  }

  _pickImage(ImageSource source) async {
    await ImagePicker().pickImage(source: source).then((returnedImage) => {
          if (returnedImage != null)
            {_selectedImage = File(returnedImage.path), fetchDataForTarotCard()}
        });
  }
}

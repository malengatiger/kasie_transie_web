import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/utils/file_uploader.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../../utils/emojis.dart';

class FileUploaderWidget extends StatefulWidget {
  const FileUploaderWidget(
      {Key? key,
      required this.isVehicles,
      required this.isUsers,
      required this.onFileUploaded, required this.onClose})
      : super(key: key);
  final bool isVehicles;
  final bool isUsers;
  final Function onFileUploaded;
  final Function onClose;


  @override
  State<FileUploaderWidget> createState() => _FileUploaderWidgetState();
}

class _FileUploaderWidgetState extends State<FileUploaderWidget> {
  static const mm = '😡😡😡😡😡 FileUploaderWidget 😡';

  @override
  void initState() {
    super.initState();
  }

  Uint8List? bytes;
  bool busy = false;
  String? fileName;

  Future _pickFile() async {
    // get file
    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      bytes = result.files.first.bytes;
      fileName = result.files.first.name;
      pp('$mm .. file picked is ${bytes!.length} bytes long; ${E.blueDot} fileName: $fileName');
      var decoded = utf8.decode(bytes!);
      pp('$mm contents of user file:${E.leaf}\n$decoded');
      setState(() {});
    }
  }

  void _submit() async {
    final user = await prefs.getUser();
    var type = '';
    if (fileName!.contains('json')) {
      if (widget.isVehicles) {
        type = 'cars.json';
      }
      if (widget.isUsers) {
        type = 'users.json';
      }
    } else if (fileName!.contains('csv')) {
      if (widget.isVehicles) {
        type = 'cars.csv';
      }
      if (widget.isUsers) {
        type = 'users.csv';
      }
    } else {
      showSnackBar(
          message: 'Invalid File Type, expecting file type .csv or .json',
          context: context);
      return;
    }
    try {
      setState(() {
        busy = true;
      });
      if (widget.isUsers) {
            final resp = await fileUploader.uploadUserFile(
                associationId: user!.associationId!, bytes: bytes!, fileName: type);
            pp('$mm user file upload complete? ${resp.length} users');
            _showSuccess();
            widget.onClose();
          }
      if (widget.isVehicles) {
            final resp = await fileUploader.uploadVehicleFile(
                associationId: user!.associationId!, bytes: bytes!, fileName: type);
            pp('$mm vehicle file upload complete? ${resp.length} cars');
            _showSuccess();
            widget.onClose();

      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            duration: Duration(seconds: 20),
            backgroundColor: Colors.red,
            message: 'Error: $e', context: context);
      }
    }
    setState(() {
      bytes = null;
      busy = false;
    });
  }

  void _showSuccess() {
    if (mounted) {
      showToast(
          padding: 24,
          textStyle: myTextStyleMediumLargeWithColor(context, Colors.white, 16),
          message: 'File uploaded successfully! ${E.blueDot} Yay!', context: context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      width: 600,
      child: busy? TimerWidget(title: 'Uploading file ...'): Card(
        shape: getDefaultRoundedBorder(),
        elevation: 12,
        child: Column(
          children: [
            gapH32,
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: (){
                  widget.onClose();
                }, icon: Icon(Icons.close)),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User File Upload',
                  style: myTextStyleLarge(context),
                ),
              ],
            ),
            gapH32,
            bytes == null
                ? gapW16
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'File:',
                        style: myTextStyleMediumLargeWithColor(
                            context, Colors.grey, 24),
                      ),
                      gapW16,
                      Text(
                        '${fileName}',
                        style: myTextStyleMediumLargeWithColor(
                            context, getPrimaryColor(context), 24),
                      )
                    ],
                  ),
             gapH32,
            bytes == null
                ? SizedBox(
                    width: 300,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(12.0),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue),
                        ),
                        onPressed: () {
                          _pickFile();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Pick File'),
                        )),
                  )
                : gapH4,
            gapH32,
            bytes == null
                ? gapH32
                : SizedBox(
                    width: 300,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(12.0),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.pink),
                        ),
                        onPressed: () {
                          _submit();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Upload File', style: TextStyle(color: Colors.white, fontSize: 20),),
                        )),
                  ),
            gapH32,

          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSheet {
  static Future<XFile?> show(
    BuildContext context, {
    bool hasImage = false,
  }) async {
    return await showCupertinoModalPopup<XFile?>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Change Profile Picture'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Take Photo'),
            onPressed: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.camera);
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Choose from Library'),
            onPressed: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          if (hasImage)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, XFile(''));
              },
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

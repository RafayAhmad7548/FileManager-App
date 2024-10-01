import 'package:filemanager/file_button.dart';
import 'package:flutter/material.dart';

enum FileOptions{delete, copy, cut, rename}

class FileOptionsMenu extends StatefulWidget{
  const FileOptionsMenu({
    super.key, required this.selected,
  });

  final List<FileButton> selected;

  @override
  State<FileOptionsMenu> createState() => _FileOptionsMenuState();
}

class _FileOptionsMenuState extends State<FileOptionsMenu> {
  void _handleOption(FileOptions value){
    switch (value){
      case FileOptions.cut:
        for(FileButton button in widget.selected){
          button.globalKey.currentState?.setButton(false);
        }
        continue copy;
      copy:
      case FileOptions.copy:
        // widget.copyFile(widget.fsEntity, value);
        break;
      case FileOptions.rename:
        var controller = TextEditingController();
        // String fileExtension = widget.fsEntity.path.substring(widget.fsEntity.path.lastIndexOf('.'));
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Rename'),
            content: TextField(
              controller: controller,
            ),
            actions: <IconButton>[
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel)),
              // IconButton(
              //     onPressed: () {
              //       widget.fsEntity.renameSync(
              //           '${widget.fsEntity.parent.path}/${controller.text}$fileExtension');
              //       Navigator.pop(context);
              //       widget.refresh();
              //     },
                  // icon: const Icon(Icons.check)),
            ],
          ),
        );
        break;
      case FileOptions.delete:
        // widget.fsEntity.deleteSync(recursive: true);
      //TODO: call getdirbuttons here
    }
    // widget.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => <PopupMenuEntry<FileOptions>>[
        const PopupMenuItem<FileOptions>(value: FileOptions.copy,child: Text('Copy')),
        const PopupMenuItem<FileOptions>(value: FileOptions.cut,child: Text('Cut')),
        const PopupMenuItem<FileOptions>(value: FileOptions.rename,child: Text('Rename')),
        const PopupMenuItem<FileOptions>(value: FileOptions.delete,child: Text('Delete')),
      ],
      onSelected: _handleOption
    );
  }
}
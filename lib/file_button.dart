import 'dart:io';

import 'package:filemanager/main.dart';
import 'package:flutter/material.dart';

enum FileOptions{delete, copy, cut, rename}

class FileButton extends StatefulWidget{
  FileButton({super.key, required this.fsEntity, required this.openFile, required this.refresh, required this.copyFile, required this.setMode, required this.getMode, required this.selectionList}) : name = fsEntity.path.split('/').last;

  final FileSystemEntity fsEntity;
  final Function(FileSystemEntity, String) openFile;
  final Function() refresh;
  final Function(FileSystemEntity, FileOptions) copyFile;
  final Function(FMMode) setMode;
  final Function() getMode;
  final Function(FileButton, bool) selectionList;
  final String name;

  @override
  State<FileButton> createState() => _FileButtonState();
}

class _FileButtonState extends State<FileButton>{

  bool selected = false;
  late Icon icon;
  Color? color;
  VoidCallback? onPress;
  VoidCallback? onLongPress;

  @override
  void initState(){
    super.initState();
    onPress = onPressed;
    onLongPress = onLongPressed;
  }

  void onPressed(){
    if(widget.getMode() == FMMode.normal){
      widget.openFile(widget.fsEntity, widget.name);
    }
    else if(widget.getMode() == FMMode.selection){
      setState((){
        if(selected){
          selected = false;
          widget.selectionList(widget, false);
        }
        else{
          selected = true;
          widget.selectionList(widget, true);
        }
      });
    }
  }

  void onLongPressed(){
    setState((){
      selected = true;
    });
    widget.setMode(FMMode.selection);
    widget.selectionList(widget, true);
  }

  @override
  Widget build(BuildContext context){
    color = null;
    if(selected){
      icon = const Icon(Icons.check);
      color = Theme.of(context).focusColor;
    }
    else if(widget.fsEntity is File){
      icon = const Icon(Icons.file_copy);
    }
    else if(widget.fsEntity is Directory){
      icon = const Icon(Icons.folder);
    }
    else{
      icon = const Icon(Icons.question_mark);
    }
    return MaterialButton(
      color: color,
      onPressed: onPress, 
      onLongPress: onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SafeArea(child: icon),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.name)),
          SafeArea(
            child: PopupMenuButton(
              itemBuilder: (context) => <PopupMenuEntry<FileOptions>>[
                const PopupMenuItem<FileOptions>(value: FileOptions.copy,child: Text('Copy')),
                const PopupMenuItem<FileOptions>(value: FileOptions.cut,child: Text('Cut')),
                const PopupMenuItem<FileOptions>(value: FileOptions.rename,child: Text('Rename')),
                const PopupMenuItem<FileOptions>(value: FileOptions.delete,child: Text('Delete')),
              ],
              onSelected: (FileOptions value){
                switch(value){
                  case FileOptions.cut:
                    setState((){
                      onPress = null;
                      onLongPress = null;
                    });
                  continue copy;
                  copy:
                  case FileOptions.copy:
                    widget.copyFile(widget.fsEntity, value);
                  break;
                  case FileOptions.rename:
                    var controller = TextEditingController();
                    String fileExtension = widget.fsEntity.path.substring(widget.fsEntity.path.lastIndexOf('.'));
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Rename'),
                        content: TextField(controller: controller,),
                        actions: <IconButton>[
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.cancel)),
                          IconButton(
                            onPressed: (){
                              widget.fsEntity.renameSync('${widget.fsEntity.parent.path}/${controller.text}$fileExtension');
                              Navigator.pop(context);
                              widget.refresh();
                            },
                            icon: const Icon(Icons.check)),
                        ],
                    ),);
                  break;
                  case FileOptions.delete: widget.fsEntity.deleteSync(recursive: true);
                  //TODO: call getdirbuttons here
                }
                widget.refresh();
              },
            ),
          )
        ],
      ),
    );
  }
}
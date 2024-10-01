import 'dart:io';

import 'package:filemanager/file_options_menu.dart';
import 'package:filemanager/main.dart';
import 'package:flutter/material.dart';


class FileButton extends StatefulWidget{
  FileButton({required this.globalKey, required this.fsEntity, required this.openFile, required this.refresh, required this.copyFile, required this.setMode, required this.getMode, required this.selectionList}) : name = fsEntity.path.split('/').last, super(key: globalKey);
  
  final GlobalKey<_FileButtonState> globalKey;
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

  void setButton(bool enabled){
    setState((){
      if(enabled){
        onPress = onPressed;
        onLongPress = onLongPressed;
      }
      else{
        onPress = null;
        onLongPress = null;
      }
    });
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
            child: FileOptionsMenu(selected: [widget],),
          )
        ],
      ),
    );
  }
}
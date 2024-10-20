import 'dart:io';

import 'package:filemanager/file_button.dart';
import 'package:flutter/material.dart';

enum FileOptions{delete, copy, cut, rename}

class FileOptionsMenu extends StatelessWidget{

  final List<FileButton> selected;
  final Function(List<FileSystemEntity>, FileOptions, BuildContext) doOnFile;

  const FileOptionsMenu({super.key, required this.selected, required this.doOnFile});

  @override
  Widget build(BuildContext context){
    List<PopupMenuEntry<FileOptions>> menuItems = [
      const PopupMenuItem<FileOptions>(value: FileOptions.copy,child: Text('Copy')),
      const PopupMenuItem<FileOptions>(value: FileOptions.cut,child: Text('Cut')),
      const PopupMenuItem<FileOptions>(value: FileOptions.delete,child: Text('Delete')),
    ];

    if(selected.length == 1){
      menuItems.add(const PopupMenuItem<FileOptions>(value: FileOptions.rename,child: Text('Rename')));
    }

    return PopupMenuButton(
      itemBuilder: (context) => menuItems,
      onSelected: (FileOptions value){
        List<FileSystemEntity> fsEntities = selected.map((fButton) => fButton.fsEntity).toList();
        // if(value == FileOptions.cut){
        //   for(FileSystemEntity fsEntity in fsEntities){

        //   }
        // }
        doOnFile(fsEntities, value, context);
      },
    );
  }

}
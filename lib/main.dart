import 'dart:io';

import 'package:filemanager/file_options_menu.dart';
import 'package:io/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:filemanager/file_button.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  void askPermission() async{
    var status = await Permission.manageExternalStorage.request();
    if(!status.isGranted) throw Exception('Permssion Denied');
  }

  @override
  Widget build(BuildContext context){
    askPermission();
    return MaterialApp(
      title: 'File Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'File Manager'),
    );
  }
}

enum FMMode{normal, selection}

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  //TODO: add popupmenubutton for selected items

  String _currentDir = '/storage/emulated/0';
  List<Widget> _list = List.empty(growable: true);
  FloatingActionButton? _faButton;
  FMMode _mode = FMMode.normal;
  final List<FileButton> _selected = List.empty(growable: true);

  @override
  void initState(){
    super.initState();
    getDirButtons(_currentDir);
  }

  void refresh(){
    setState((){});
  }

  void selectionList(FileButton selected, bool option){
    setState((){
      if(option){
        _selected.add(selected);
      }
      else{
        _selected.remove(selected);
      }
    });
    if(_selected.isEmpty){
      _mode = FMMode.normal;
    }
  }

  FMMode getMode(){
    return _mode;
  }

  void setMode(FMMode mode){
    setState((){
      _mode = mode;
    });
  }

  void copyFile(FileSystemEntity fsEntity, FileOptions fileOption){
    setState((){
      _faButton = FloatingActionButton.extended(
        onPressed: (){
          if(fsEntity is File){
            fsEntity.copySync('$_currentDir/${fsEntity.path.split(Platform.pathSeparator).last}');
          }
          else{
            copyPathSync(fsEntity.path, '$_currentDir/${fsEntity.path.split(Platform.pathSeparator).last}');
          }
          if(fileOption == FileOptions.cut && fsEntity.path != '$_currentDir/${fsEntity.path.split(Platform.pathSeparator).last}'){
            fsEntity.deleteSync(recursive: true);
          }
          _faButton = null;
          getDirButtons(_currentDir);
        },
        label: const Row(
          children: [
            Icon(Icons.paste),
            SizedBox(width: 10,),
            Text('Paste'),
          ],
        )
      ); 
    });
  }

  void openFile(FileSystemEntity fsEntity, String name){
    setState((){
      if(fsEntity is Directory){
        _currentDir = '$_currentDir${Platform.pathSeparator}$name';
      } 
      else if(fsEntity is File){
        //TODO: opening file logic
      }
    });
    getDirButtons(_currentDir);
  }

  void backButtonPressed(){
    setState((){
      if(_mode == FMMode.normal){
        if(_currentDir != '/storage/emulated/0'){
          _currentDir = _currentDir.substring(0, _currentDir.lastIndexOf(Platform.pathSeparator));
        }
      }
      else if(_mode == FMMode.selection){
        _mode = FMMode.normal;
      }
    });
    getDirButtons(_currentDir);
  }

  void getDirButtons(String dir){
    setState((){
      _list = List.empty(growable: true);
      Directory directory = Directory(dir);
      try{
        directory.listSync().forEach((element) => _list.add(FileButton(
            globalKey: GlobalKey(),
            fsEntity: element,
            openFile: openFile,
            refresh: refresh,
            copyFile: copyFile,
            setMode: setMode,
            getMode: getMode,
            selectionList: selectionList,
          )));
      }
      on PathAccessException{
        _list = List.empty(growable: true);
      }
    });
  }

  @override
  Widget build(BuildContext context){
    var alignment = Alignment.topCenter;
    if(_list.isEmpty){
      alignment = Alignment.center;
      _list.add(const Center(
        child: Text('nothing in this directory'),
      ));
    }
    List<Widget>? actionsButtons;
    if(_mode == FMMode.selection){
      actionsButtons = List.of([FileOptionsMenu(selected: _selected)]);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(onPressed: backButtonPressed, icon: const Icon(Icons.arrow_back)),
        actions: actionsButtons,
      ),
      body: Align(
        alignment: alignment,
        child: ListView(
          shrinkWrap: true,
          children: _list,
        ),
      ),
      floatingActionButton: _faButton
    );
  }
}
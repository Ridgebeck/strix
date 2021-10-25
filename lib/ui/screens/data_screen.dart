import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/new_data.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/picture_screen.dart';

class DataScreen extends StatefulWidget {
  final AvailableAssetEntry assets;
  final NewData newData;
  final Function resetFunction;
  const DataScreen({
    Key? key,
    required this.assets,
    required this.newData,
    required this.resetFunction,
  }) : super(key: key);

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final int numberOfCards = 4;
  String selection = DataSelection.menu;

  void changeSelection(String value) {
    setState(() {
      selection = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 89,
          child: Row(
            children: [
              Expanded(flex: 5, child: Container()),
              Expanded(
                flex: 90,
                child: displaySelection(
                  selection: selection,
                  changeSelection: changeSelection,
                  resetFunction: widget.resetFunction,
                  assets: widget.assets,
                  newData: widget.newData,
                ),
              ),
              Expanded(flex: 5, child: Container()),
            ],
          ),
        ),
      ],
    );
  }
}

Widget displaySelection({
  required String selection,
  required Function changeSelection,
  required Function resetFunction,
  required AvailableAssetEntry assets,
  required NewData newData,
}) {
  switch (selection) {
    case DataSelection.menu:
      {
        return DataScreenMenu(
            changeSelection: changeSelection,
            data: assets.data,
            newData: newData);
      }
    case DataSelection.reports:
      {
        //return ReportsScreen(changeSelection: changeSelection);
        return DataSelectionScreen(
          changeSelection: changeSelection,
          data: assets.data!.reports!,
          folder: DataSelection.reportsFolder,
        );
      }
    case DataSelection.social:
      {
        resetFunction(DataSelection.social);
        return DataSelectionScreen(
          changeSelection: changeSelection,
          data: assets.data!.social!,
          folder: DataSelection.socialFolder,
        );
      }
    case DataSelection.messages:
      {
        resetFunction(DataSelection.messages);
        return DataSelectionScreen(
          changeSelection: changeSelection,
          data: assets.data!.messages!,
          folder: DataSelection.messagesFolder,
        );
      }
    case DataSelection.images:
      {
        resetFunction(DataSelection.images);
        return DataSelectionScreen(
          changeSelection: changeSelection,
          data: assets.data!.images!,
          folder: DataSelection.imagesFolder,
        );
      }
    case DataSelection.videos:
      {
        resetFunction(DataSelection.videos);
        return DataSelectionScreen(
          changeSelection: changeSelection,
          data: assets.data!.videos!,
          folder: DataSelection.videosFolder,
        );
      }
    case DataSelection.audio:
      {
        resetFunction(DataSelection.audio);
        return DataSelectionScreen(
          changeSelection: changeSelection,
          data: assets.data!.audioFiles!,
          folder: DataSelection.audioFolder,
        );
      }
    default:
      {
        return DataScreenMenu(
          changeSelection: changeSelection,
          data: assets.data,
          newData: newData,
        );
      }
  }
}

class DataSelectionScreen extends StatelessWidget {
  final Function changeSelection;
  final String folder;
  final List<String> data;
  const DataSelectionScreen({
    Key? key,
    required this.changeSelection,
    required this.folder,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: () {
              changeSelection(DataSelection.menu);
            },
            child: const Text('BACK'),
          ),
        ),
        Expanded(
          flex: 9,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              childAspectRatio: 0.65,
              //crossAxisSpacing: 20,
              //mainAxisSpacing: 20,
            ),
            itemCount: data.length,
            itemBuilder: (BuildContext context, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      PictureScreen.routeId,
                      arguments: folder + '/' + data[index],
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/data/' + folder + '/' + data[index],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DataScreenMenu extends StatelessWidget {
  final Function changeSelection;
  final DataEntry? data;
  final NewData newData;
  const DataScreenMenu({
    Key? key,
    required this.changeSelection,
    required this.data,
    required this.newData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: Container(),
        ),
        Expanded(
          flex: 80,
          child: data == null
              ? const Center(
                  child: FittedBox(
                    child: Text(
                      'No data has been received yet.',
                      //style: TextStyle(fontSize: 10.0),
                    ),
                  ),
                )
              : Column(
                  children: [
                    data!.social == null
                        ? Container()
                        : MenuTile(
                            selectedDataType: DataSelection.social,
                            iconData: Icons.person,
                            changeSelection: changeSelection,
                            newMedia: newData.newSocial,
                          ),
                    data!.messages == null
                        ? Container()
                        : MenuTile(
                            selectedDataType: DataSelection.messages,
                            iconData: Icons.message_outlined,
                            changeSelection: changeSelection,
                            newMedia: newData.newMessages,
                          ),
                    data!.images == null
                        ? Container()
                        : MenuTile(
                            selectedDataType: DataSelection.images,
                            iconData: Icons.camera_alt,
                            changeSelection: changeSelection,
                            newMedia: newData.newImages,
                          ),
                    data!.videos == null
                        ? Container()
                        : MenuTile(
                            selectedDataType: DataSelection.videos,
                            iconData: Icons.video_collection,
                            changeSelection: changeSelection,
                            newMedia: false,
                          ),
                    data!.audioFiles == null
                        ? Container()
                        : MenuTile(
                            iconData: Icons.audiotrack_outlined,
                            selectedDataType: DataSelection.audio,
                            changeSelection: changeSelection,
                            newMedia: false,
                          ),
                    data!.reports == null
                        ? Container()
                        : MenuTile(
                            selectedDataType: DataSelection.reports,
                            iconData: Icons.folder_open,
                            changeSelection: changeSelection,
                            newMedia: false,
                          ),
                    Expanded(
                      flex: data!.categories() - data!.length(),
                      child: Container(),
                    ),
                  ],
                ),
        ),
        Expanded(
          flex: 10,
          child: Container(),
        ),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData iconData;
  final String selectedDataType;
  final Function changeSelection;
  final bool newMedia;
  const MenuTile({
    Key? key,
    required this.iconData,
    required this.selectedDataType,
    required this.changeSelection,
    required this.newMedia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FractionallySizedBox(
        widthFactor: 0.85,
        heightFactor: 0.8,
        child: TextButton(
          onPressed: () {
            changeSelection(selectedDataType);
          },
          //provideHapticFeedback: true,
          child: Container(
            decoration: BoxDecoration(
              color: newMedia ? Colors.red : Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Expanded(child: Container()),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.7,
                            widthFactor: 0.7,
                            child: FittedBox(
                              child: Icon(
                                iconData,
                                size: 150.0,
                                color: Colors.blueGrey[300],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            Expanded(child: Container()),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  child: Text(
                                    selectedDataType,
                                    style: TextStyle(
                                      fontSize: 50.0,
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

const List<String> urls = [
  "https://live.staticflickr.com/5541/12783619194_50ded63d91_n.jpg",
  "https://live.staticflickr.com/7352/12783298103_8fd74e5bd5_n.jpg",
  "https://live.staticflickr.com/7722/16870313937_fc0ce26ccf_n.jpg",
  "https://live.staticflickr.com/5497/12783313033_a0740135b7_n.jpg"
];

class PhotoState {
  String url;
  bool selected = false;
  bool display = false;
  Set<String> tags = {};

  PhotoState({
    required this.url,
    this.selected = false,
    this.display = true,
    required this.tags});
}
class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool isTagging = false;

  List<PhotoState> photoStates = List.of(urls.map((url) => PhotoState(url: url, tags: {})));
  Set<String> tags = {"all", "nature", "none"};

  void toggleTagging(String? url){
    setState(() {
      isTagging = !isTagging;
      for(var ps in photoStates){
        if(isTagging && ps.url == url) {
          ps.selected = true;
        } else {
          ps.selected = false;
        }
      }
    });
  }

  void onPhotoSelect(String url, bool selected) {
    setState(() {
      for(var ps in photoStates) {
        if (ps.url == url) {
          ps.selected = selected;
        }
      }
    });
  }

  void selectTag(String tag) {
    setState(() {
      if (isTagging) {
        if (tag != "all") {
          for (var ps in photoStates) {
            if (ps.selected == true) {
              ps.tags.add(tag);
            }
          }
        }
        toggleTagging(null);
      } else {
        for (var ps in photoStates) {
          ps.display = tag == "all" ? true : ps.tags.contains(tag);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Photo Viewer',
      home: GalleryPage(
        title: 'Image Gallery',
        photoStates: photoStates,
        tags: tags,
        tagging: isTagging,
        toggleTagging: toggleTagging,
        selectTag: selectTag,
        onPhotoSelect: onPhotoSelect,
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final List<PhotoState> photoStates;
  final Set<String> tags;
  final bool tagging;

  final Function toggleTagging;
  final Function selectTag;
  final Function onPhotoSelect;

  const GalleryPage({
    required this.title,
    required this.photoStates,
    required this.tags,
  required this.tagging,
  required this.toggleTagging,
  required this.selectTag,
  required this.onPhotoSelect,
    super.key
  });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.count(
          primary: false,
          crossAxisCount: 2,
          children: List.of(photoStates.where((ps) => ps.display).map((ps) => Photo(
            state: ps,
            selectable: tagging,
            onLongPress: toggleTagging,
            onSelect: onPhotoSelect,
          )))
      ),
      drawer: Drawer(
        child: ListView(
          children: List.of(tags.map((t) => ListTile(title: Text(t),
          onTap: (){
            selectTag(t);
            Navigator.of(context).pop();
          }))),
        ),
      ),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final bool selectable;

  final Function onLongPress;
  final Function onSelect;

  const Photo({
    super.key,
    required this.state,
    required this.selectable,
    required this.onLongPress,
  required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      GestureDetector(
        child: Image.network(state.url),
        onLongPress: () => onLongPress(state.url),
      )
    ];
    if (selectable) {
      children.add(Positioned(
        left: 20,
        top: 0,
        child: Theme(
          data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.grey[200]),
          child: Checkbox(
            onChanged: (value) {
              onSelect(state.url, value);
            },
            value: state.selected,
            activeColor: Colors.white,
            checkColor: Colors.black,
          )
        )
      ));
    }

    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }

}


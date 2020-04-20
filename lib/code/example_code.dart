import 'package:flutter/material.dart';
export 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'markdown_dart_code.dart';
import 'package:flutterbyrhyme/code/code_highlighter.dart';
export 'package:flutterbyrhyme/widgets/paramWidgets.dart';
export 'code_highlighter.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MarkdownState<T extends StatefulWidget> extends State<T> {
  bool showFloatingButton = false;
  final ScrollController _controller = new ScrollController();

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (showFloatingButton &&
              notification.metrics.pixels <=
                  MediaQuery.of(context).size.height) {
            setState(() {
              showFloatingButton = notification.metrics.pixels >
                  MediaQuery.of(context).size.height;
            });
          } else if (!showFloatingButton &&
              notification.metrics.pixels >
                  MediaQuery.of(context).size.height) {
            setState(() {
              showFloatingButton = notification.metrics.pixels >
                  MediaQuery.of(context).size.height;
            });
          }
          return false;
        },
        child: CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: false,
              title: Text(getTitle()),
            ),
            SliverToBoxAdapter(
              child: DartMarkDown(getMarkdownSource()),
            ),
          ],
        ),
      ),
      floatingActionButton: showFloatingButton
          ? IconButton(
              onPressed: () {
                _controller.animateTo(0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.linear);
              },
              color: Theme.of(context).textTheme.title.color,
              icon: Icon(
                Icons.arrow_upward,
              ),
            )
          : null,
    );
  }

  @protected
  String getTitle();

  @protected
  String getMarkdownSource();
}

class XLayout extends StatelessWidget{
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  XLayout({
    this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment
});
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if(width<520){
    return Column(
      children: this.children,
      mainAxisAlignment: this.mainAxisAlignment,
      crossAxisAlignment: this.crossAxisAlignment,
    );

    }
    return Row(
      children: this.children,
      mainAxisAlignment: this.mainAxisAlignment,
      crossAxisAlignment: this.crossAxisAlignment,
    );
  }

}

abstract class ExampleState<T extends StatefulWidget> extends State<T> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  GlobalKey<ExampleScaffoldState> _exampleKey =
      new GlobalKey<ExampleScaffoldState>();

  GlobalKey<ExampleScaffoldState> get exampleKey => _exampleKey;
  /** 获取屏幕宽度 */
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /** 获取屏幕高度 */
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }



  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);
    return ExampleScaffold(
      key: _exampleKey,
      scaffoldKey: _scaffoldKey,
      exampleCode: getExampleCode(),
      title: getTitle(),
      detail: getDetail(),
      body: Container(
        width: double.infinity,
//        color: Colors.green,
        child: XLayout(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child:
                  // start
                  getWidget(),
            ),
            // end
            Divider(),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getSetting(),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @protected
  String getTitle();

  @protected
  String getExampleCode();

  @protected
  Widget getWidget();

  @protected
  List<Widget> getSetting();

  @protected
  String getDetail();
}

class ExampleScaffold extends StatefulWidget {
  ExampleScaffold(
      {Key key,
      this.scaffoldKey,
      this.title,
      this.detail,
      this.actions,
      this.body,
      this.exampleCode})
      : super(key: key);
  final String title;
  final String detail;
  final String exampleCode;
  final List<Widget> actions;
  final Widget body;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ExampleScaffoldState createState() => ExampleScaffoldState();
}

class ExampleScaffoldState extends State<ExampleScaffold> {
  AnimationController controller;
  String content;
  Color nbColor = Colors.transparent;
  Color ntColor = Colors.transparent;
  Color vbColor;
  Color vtColor;
  bool isShowToast = false;
  List<Widget> body;

  void showToast(String content) {
    if (!mounted) return;

    setState(() {
      this.content = content;
      nbColor = this.vbColor;
      ntColor = this.vtColor;
      isShowToast = true;
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        nbColor = Colors.transparent;
        ntColor = Colors.transparent;
        isShowToast = false;
      });
    });
  }

  Widget toastWidget() {
    return Positioned(
      left: 50.0,
      right: 50.0,
      bottom: 20.0,
      child: AnimatedContainer(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeIn,
        color: nbColor,
        child: Text(
          content ?? 'hello',
          style: Theme.of(context).textTheme.title.copyWith(color: ntColor),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    vbColor = isDark ? Colors.grey : Colors.black87;
    vtColor = isDark ? Colors.black : Colors.white;
    body = [widget.body];
    if (isShowToast) {
      body.add(toastWidget());
    }
    return Scaffold(
        key: widget.scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
          actions: (widget.actions ?? <Widget>[])
            ..addAll(<Widget>[
              IconButton(
                icon: Icon(Icons.info),
                tooltip: 'Show the detail!\n详情',
                onPressed: () {
                  _showDetail(context);
                },
              ),
              IconButton(
                  icon: Icon(Icons.description),
                  tooltip: 'Show example code!\n展示示例代码!',
                  onPressed: () {
                    _showExampleCode(context);
                  }),
            ]),
        ),
        body: Stack(
          children: body,
        ));
  }

  //显示示例代码
  void _showExampleCode(BuildContext context) {
    Navigator.push(
        context,
        new MaterialPageRoute<FullScreenCodeDialog>(
            builder: (BuildContext context) => FullScreenCodeDialog(
                  exampleCode: widget.exampleCode,
                )));
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: new Text(widget.detail,
                    textAlign: TextAlign.justify,
                    style: new TextStyle(fontSize: 18.0)),
              ));
        });
  }
}

class FullScreenCodeDialog extends StatefulWidget {
  FullScreenCodeDialog({this.exampleCode});

  final String exampleCode;

  @override
  _FullScreenCodeDialogState createState() => _FullScreenCodeDialogState();
}

class _FullScreenCodeDialogState extends State<FullScreenCodeDialog> {
  double fontSize = 16.0;

  bool isShowFontSet = false;

  GlobalKey<ScaffoldState> _key = GlobalKey();
  SharedPreferences _preferences;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    initPreference();
  }

  @override
  Widget build(BuildContext context) {
    final SyntaxHighlighterStyle style =
        Theme.of(context).brightness == Brightness.dark
            ? SyntaxHighlighterStyle.darkThemeStyle()
            : SyntaxHighlighterStyle.lightThemeStyle();
    Widget body;
    if (widget.exampleCode == null) {
      body = const Center(
        child: const CircularProgressIndicator(),
      );
    } else {
      body = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: fontSize),
                    children: <TextSpan>[
                  DartSyntaxHighlighter(style).format(widget.exampleCode),
                ])),
          ),
        ),
      );
    }
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.clear,
              semanticLabel: 'close',
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Tooltip(
          message: '示例代码',
          child: const Text('Example Code'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: '字体大小',
            icon: Icon(Icons.format_size),
            onPressed: () {
              setState(() {
                isShowFontSet = !isShowFontSet;
              });
            },
          ),
          IconButton(
            tooltip: '复制代码',
            icon: Icon(Icons.content_copy),
            onPressed: _handleCopyCode,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          body,
          Positioned(
            bottom: 0.0,
            right: 5.0,
            child: isShowFontSet
                ? Row(
                    children: <Widget>[
                      Text('字体大小：'),
                      Slider(
                        divisions: 24,
                        min: 10,
                        max: 34,
                        label: '$fontSize',
                        value: fontSize,
                        onChanged: (value) {
                          _preferences.setDouble('fontSize', value);
                          setState(() {
                            fontSize = value;
                          });
                        },
                      ),
                      Text('$fontSize'),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  //复制代码
  void _handleCopyCode() async {
    await Clipboard.setData(ClipboardData(text: DartSyntaxHighlighter.formatCode(widget.exampleCode)));
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text('代码已复制到粘贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void initPreference() async {
    _preferences = await SharedPreferences.getInstance();
    double saveSize = _preferences.getDouble('fontSize');
    if (saveSize != null) {
      setState(() {
        fontSize = saveSize;
      });
    }
  }
}

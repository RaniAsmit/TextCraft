import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class TextState {
  String text;
  String fontFamily;
  double fontSize;
  Color color;
  double left;
  double top;

  TextState(this.text, this.fontFamily, this.fontSize, this.color,
      {this.left = 50.0, this.top = 50.0});
}

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String _text = "New Text";
  String _fontFamily = 'Arial';
  double _fontSize = 16;
  Color _color = Colors.black;

  List<TextState> _textBoxes = [];
  List<List<TextState>> _history = [];
  int _historyIndex = -1;

  int _selectedTextIndex = -1;

  final List<String> _fonts = [
    'Arial',
    'Times New Roman',
    'Courier New',
    'Verdana'
  ];
  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green
  ];

  void _saveState() {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }
    _history.add(List.from(_textBoxes));
    _historyIndex++;
  }

  void _undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _restoreState();
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _restoreState();
    }
  }

  void _restoreState() {
    setState(() {
      _textBoxes = List.from(_history[_historyIndex]);
    });
  }

  void _updateSelectedTextState(
      {String? text, String? fontFamily, double? fontSize, Color? color}) {
    if (_selectedTextIndex != -1) {
      setState(() {
        TextState selectedText = _textBoxes[_selectedTextIndex];
        _textBoxes[_selectedTextIndex] = TextState(
          text ?? selectedText.text,
          fontFamily ?? selectedText.fontFamily,
          fontSize ?? selectedText.fontSize,
          color ?? selectedText.color,
          left: selectedText.left,
          top: selectedText.top,
        );
        _saveState();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TextStyler'),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _redo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  children: _textBoxes.asMap().entries.map((entry) {
                    int index = entry.key;
                    TextState textState = entry.value;
                    return Positioned(
                      left: textState.left,
                      top: textState.top,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            textState.left += details.delta.dx;
                            textState.top += details.delta.dy;
                          });
                        },
                        onTap: () {
                          setState(() {
                            _selectedTextIndex = index;
                            _text = textState.text;
                            _fontFamily = textState.fontFamily;
                            _fontSize = textState.fontSize;
                            _color = textState.color;
                          });

                          showDialog<String>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Text'),
                                content: TextField(
                                  onChanged: (value) {
                                    _text = value;
                                  },
                                  controller: TextEditingController(
                                    text: textState.text,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _updateSelectedTextState(text: _text);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          textState.text,
                          style: TextStyle(
                            fontFamily: textState.fontFamily,
                            fontSize: textState.fontSize,
                            color: textState.color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              children: [
                Text('Font: '),
                DropdownButton<String>(
                  value: _fontFamily,
                  items: _fonts.map((String font) {
                    return DropdownMenuItem<String>(
                      value: font,
                      child: Text(font),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _fontFamily = newValue!;
                    });
                    _updateSelectedTextState(fontFamily: _fontFamily);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8,
                    max: 48,
                    divisions: 8,
                    label: _fontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _fontSize = value;
                      });
                      _updateSelectedTextState(fontSize: _fontSize);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Color: '),
                DropdownButton<Color>(
                  value: _color,
                  items: _colors.map((Color color) {
                    return DropdownMenuItem<Color>(
                      value: color,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: color,
                      ),
                    );
                  }).toList(),
                  onChanged: (Color? newColor) {
                    setState(() {
                      _color = newColor!;
                    });
                    _updateSelectedTextState(color: _color);
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _textBoxes.add(TextState(
                    _text,
                    _fontFamily,
                    _fontSize,
                    _color,
                  ));
                  _saveState();
                });
              },
              child: Text('Add Text'),
            ),
          ],
        ),
      ),
    );
  }
}

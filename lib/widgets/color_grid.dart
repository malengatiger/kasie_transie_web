import 'package:flutter/material.dart';
import 'package:kasie_transie_web/utils/functions.dart';

import '../blocs/theme_bloc.dart';

class ColorGrid extends StatelessWidget {
  const ColorGrid(
      {Key? key,
        required this.colors,
        required this.onColorChosen,
        this.crossAxisCount, this.height, required this.onClose, required this.changeColor})
      : super(key: key);

  final List<ColorFromTheme> colors;
  final Function(ColorFromTheme) onColorChosen;
  final Function onClose;
  final int? crossAxisCount;
  final double? height;
  final String changeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height == null? 400: height!, width: 400,
      child: Card(
        shape: getDefaultRoundedBorder(),
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(changeColor, style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 18),),
                  gapW32,gapW32,gapW32,
                  IconButton(onPressed: (){
                    onClose();
                  }, icon: Icon(Icons.close, size: 14,)),
                ],
              ),
              Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        crossAxisCount: crossAxisCount == null? 6: crossAxisCount!),
                    itemCount: colors.length,
                    itemBuilder: (ctx, index) {
                      final c = colors.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onColorChosen(c);
                        },
                        child: Container(
                          color: c.color,
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

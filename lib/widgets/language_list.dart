
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_web/l10n/strings_helper.dart';
import '../blocs/theme_bloc.dart';
import '../l10n/translation_handler.dart';
import '../utils/color_and_locale.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

class LanguageList extends StatefulWidget {
  const LanguageList(
      {Key? key, required this.onLanguageChosen, required this.onClose})
      : super(key: key);
  final Function(LangBag) onLanguageChosen;
  final Function onClose;

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  static const mm = '🌽🌽🌽 LanguageList: 💪💪';

  @override
  void initState() {
    super.initState();
    _getLanguages();
  }
  List<LangBag> languageBags = [];
  var locale = 'en';

   StringsHelper? stringsHelper;

  Future _getLanguages() async {
    colorAndLocale = await prefs.getColorAndLocale();
    stringsHelper = await StringsHelper.getTranslatedTexts();
    locale = colorAndLocale.locale;
    pp('$mm ... _getLanguages ... locale: $locale');
    try {
      languageBags.clear();
      languageBags.add(LangBag(
        language: await translator.translate("en", locale),
        index: 0,
        locale: 'en',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("af", locale),
        index: 1,
        locale: 'af',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("fr", locale),
        index: 2,
        locale: 'fr',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("es", locale),
        index: 3,
        locale: 'es',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("pt", locale),
        index: 4,
        locale: 'pt',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("de", locale),
        index: 5,
        locale: 'de',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("ts", locale),
        index: 6,
        locale: 'ts',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("st", locale),
        index: 7,
        locale: 'st',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("zu", locale),
        index: 8,
        locale: 'zu',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("xh", locale),
        index: 9,
        locale: 'xh',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("zh", locale),
        index: 10,
        locale: 'zh',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("yo", locale),
        index: 11,
        locale: 'yo',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("sw", locale),
        index: 12,
        locale: 'sw',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("sn", locale),
        index: 13,
        locale: 'sn',
      ));
      languageBags.add(LangBag(
        language: await translator.translate("ig", locale),
        index: 14,
        locale: 'ig',
      ));

      pp('$mm language bags built up: ${languageBags.length}');
      setState(() {

      });
    } catch (e) {
      pp(e);
    }
  }
  late ColorAndLocale colorAndLocale;
  LangBag? langBag;


  Future<void> onLanguageChosen(LangBag bag) async {
    pp('$mm ......... onLanguageChosen, language: ${bag.language}');
    colorAndLocale.locale = bag.locale;
    prefs.saveColorAndLocale(colorAndLocale);
    locale = bag.locale;
    themeBloc.changeColorAndLocale(colorAndLocale);
    translator.translationStreamController.sink.add(true);

    await _getLanguages();
    setState(() {
      langBag = bag;
    });

    widget.onLanguageChosen(bag);
  }
  @override
  Widget build(BuildContext context) {
    languageBags.sort((a, b) => a.language.compareTo(b.language));
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(width: (width/2) + 200, height: (height/3) + 24,
      child: Card(
        shape: getDefaultRoundedBorder(),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: bd.Badge(
            badgeContent: Text('${languageBags.length}'),
            position: bd.BadgePosition.bottomEnd(bottom: -12, end: -12),
            badgeStyle: bd.BadgeStyle(
              padding: const EdgeInsets.all(12),
              badgeColor: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stringsHelper == null? 'Change Language':stringsHelper!.changeLanguage, style: myTextStyleMediumLargeWithColor(context, Theme.of(context).primaryColor,
                          20),),
                      gapW32,
                      IconButton(onPressed: (){
                        widget.onClose();
                      }, icon: Icon(Icons.close, size: 14,)),
                    ],
                  ),
                  gapH32,
                  Expanded(
                    child: SizedBox(height: 36,
                      child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                          itemCount: languageBags.length,
                          itemBuilder: (ctx, index) {
                            final l = languageBags.elementAt(index);
                            return GestureDetector(
                                onTap: () async {
                                  final m = await translator.translate(l.locale, l.locale);
                                  pp('${E.redDot} language picked: ${l.language} translated to $m');
                                  l.language = m;
                                  onLanguageChosen(l);
                                },
                                child: Card(
                                  elevation: 12,
                                  shape: getDefaultRoundedBorder(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Text(l.language, style: myTextStyleSmall(context),)),
                                  ),
                                ));
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LangBag {
  late String language;
  late int index;
  late String locale;

  LangBag({required this.language, required this.index, required this.locale});
}
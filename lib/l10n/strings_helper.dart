import 'package:kasie_transie_web/l10n/translation_handler.dart';

import '../utils/functions.dart';
import '../utils/prefs.dart';

class StringsHelper {
  String assRouteOperations = 'assRouteOperations';
  String changeColor = 'changeColor';
  String passengers = 'passengers';
  String changeLanguage = 'changeLanguage';
  String commutersText = 'commuters';
  String arrivalsText = 'arrivals';
  String departuresText = 'departures';
  String dispatchesText = 'dispatches';
  String timeLastUpdate = 'timeLastUpdate';
  String emailAddress = 'emailAddress';
  String password = 'password';
  String kasieSignIn = 'kasieSignIn';
  String sendSignIn = 'sendSignIn';
  String enterEmail = 'enterEmail';
  String enterPassword = 'enterPassword';
  String signInWithEmail = 'signInWithEmail';
  String numberMinutes = 'numberMinutes';
  String loadingRoutes = 'loadingRoutes';
  String heartbeats = 'heartbeats';
  String operationsSummary = 'operationsSummary';
  String dataLoader = 'dataLoader';
  String thisMayTakeMinutes = 'thisMayTakeMinutes';
  String commuterRequest = 'commuterRequest';
  String commuterRequests = 'commuterRequests';
  String signInFailed = 'signInFailed';
  String signInComplete = 'signInComplete';
  String serverUnreachable = 'serverUnreachable';

  StringsHelper(
      {required this.assRouteOperations,
      required this.changeColor,
      required this.signInFailed,
      required this.passengers,
      required this.changeLanguage,
      required this.commutersText,
      required this.arrivalsText,
      required this.departuresText,
      required this.dispatchesText,
      required this.timeLastUpdate,
      required this.emailAddress,
      required this.password,
      required this.kasieSignIn,
      required this.sendSignIn,
      required this.enterEmail,
      required this.enterPassword,
      required this.signInWithEmail,
      required this.numberMinutes,
      required this.loadingRoutes,
      required this.heartbeats,
      required this.dataLoader,
      required this.serverUnreachable,
      required this.commuterRequests,
      required this.commuterRequest,
      required this.signInComplete,
      required this.operationsSummary,
      required this.thisMayTakeMinutes});

  static Future<StringsHelper> getTranslatedTexts() async {
    pp('🔵 ....... translations will be set');

    final cl = await prefs.getColorAndLocale();
    final locale = cl.locale;
    var assRouteOperations =
        await translator.translate('assRouteOperations', locale);
    var changeColor = await translator.translate('changeColor', locale);
    var loadingRoutes = await translator.translate('loadingRoutes', locale);
    var thisMayTakeMinutes =
        await translator.translate('thisMayTakeMinutes', locale);

    var changeLanguage = await translator.translate('changeLanguage', locale);
    var commutersText = await translator.translate('commuters', locale);
    var arrivalsText = await translator.translate('arrivals', locale);
    var departuresText = await translator.translate('departures', locale);
    var dispatchesText = await translator.translate('dispatches', locale);
    var timeLastUpdate = await translator.translate('timeLastUpdate', locale);
    var emailAddress = await translator.translate('emailAddress', locale);
    var password = await translator.translate('password', locale);
    var kasieSignIn = await translator.translate('kasieSignIn', locale);
    var sendSignIn = await translator.translate('sendSignIn', locale);
    var enterEmail = await translator.translate('enterEmail', locale);
    var enterPassword = await translator.translate('enterPassword', locale);
    var signInWithEmail = await translator.translate('signInWithEmail', locale);
    var numberMinutes = await translator.translate('numberMinutes', locale);
    var passengers = await translator.translate('passengers', locale);
    var heartbeats = await translator.translate('heartbeats', locale);
    var operationsSummary =
        await translator.translate('operationsSummary', locale);
    var dataLoader = await translator.translate('dataLoader', locale);
    var commuterRequests =
        await translator.translate('commuterRequests', locale);

    var commuterRequest = await translator.translate('commuterRequest', locale);
    var signInFailed = await translator.translate('signInFailed', locale);
    var signInComplete = await translator.translate('signInComplete', locale);
    var serverUnreachable =
        await translator.translate('serverUnreachable', locale);

    pp('🔵 ....... translations completed');
    final h = StringsHelper(
        serverUnreachable: serverUnreachable,
        signInComplete: signInComplete,
        signInFailed: signInFailed,
        commuterRequest: commuterRequest,
        commuterRequests: commuterRequests,
        operationsSummary: operationsSummary,
        dataLoader: dataLoader,
        assRouteOperations: assRouteOperations,
        changeColor: changeColor,
        passengers: passengers,
        changeLanguage: changeLanguage,
        commutersText: commutersText,
        arrivalsText: arrivalsText,
        departuresText: departuresText,
        dispatchesText: dispatchesText,
        timeLastUpdate: timeLastUpdate,
        emailAddress: emailAddress,
        password: password,
        kasieSignIn: kasieSignIn,
        sendSignIn: sendSignIn,
        enterEmail: enterEmail,
        enterPassword: enterPassword,
        signInWithEmail: signInWithEmail,
        numberMinutes: numberMinutes,
        loadingRoutes: loadingRoutes,
        heartbeats: heartbeats,
        thisMayTakeMinutes: thisMayTakeMinutes);
    return h;
  }
}

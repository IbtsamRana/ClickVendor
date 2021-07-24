import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor/Auth/MobileNumber/UI/phone_number.dart';

import 'package:vendor/Locale/locales.dart';
import 'package:vendor/OrderItemAccount/order_item_account.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/Themes/style.dart';
import 'package:vendor/UI/language_cubit.dart';
import 'package:vendor/parcel/parcelmainpage.dart';
import 'package:vendor/pharmacy/order_item_account_pharma.dart';
import 'package:vendor/restaturant/order_item_account_rest.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    Firebase.initializeApp();
  }catch(e){}
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('islogin');
  dynamic ui_type = prefs.getString('ui_type');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kMainColor.withOpacity(0.5),
  ));
  if (ui_type != null && ui_type == "2") {
    runApp(Phoenix(
        child: (result != null && result)
            ? GoMarketMangerHomeRest()
            : GoMarketManger()));
  } else if (ui_type != null && ui_type == "3") {
    runApp(Phoenix(
        child: (result != null && result)
            ? GoMarketMangerHomePharma()
            : GoMarketManger()));
  } else if (ui_type != null && ui_type == "4") {
    runApp(Phoenix(
        child: (result != null && result)
            ? GoMarketMangerHomeParcel()
            : GoMarketManger()));
  } else {
    runApp(Phoenix(
        child: (result != null && result)
            ? GoMarketMangerHome()
            : GoMarketManger()));
  }
}



class GoMarketManger extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('hi'),
              const Locale('es'),
            ],
            theme: appTheme,
            home: PhoneNumber_New(),
            routes: PageRoutes().routes(),
          );
        },
      ),

    );
  }

}

class GoMarketMangerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('hi'),
              const Locale('es'),
            ],
            theme: appTheme,
            home: OrderItemAccount(),
            routes: PageRoutes().routes(),
          );
        },
      ),

    );
  }
}

class GoMarketMangerHomeRest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('hi'),
              const Locale('es'),
            ],
            theme: appTheme,
            home: OrderItemAccountRest(),
            routes: PageRoutes().routes(),
          );
        },
      ),

    );
  }
}

class GoMarketMangerHomeParcel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('hi'),
              const Locale('es'),
            ],
            theme: appTheme,
            home: OrderParcelItemAccount(),
            routes: PageRoutes().routes(),
          );
        },
      ),

    );
  }
}

class GoMarketMangerHomePharma extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('hi'),
              const Locale('es'),
            ],
            theme: appTheme,
            home: OrderItemAccountPharma(),
            routes: PageRoutes().routes(),
          );
        },
      ),

    );
  }
}

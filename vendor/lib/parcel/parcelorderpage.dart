import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/parcel/parcelbean/todayorderparcel.dart';

class OrderPageParcel extends StatefulWidget {
  @override
  _OrderPageParcelState createState() => _OrderPageParcelState();
}

class _OrderPageParcelState extends State<OrderPageParcel>
    with SingleTickerProviderStateMixin {
  List<Tab> tabs = <Tab>[
    Tab(text: 'NEW ORDERS'),
    Tab(text: 'NEXTDAY ORDERS'),
  ];
  TabController tabController;
  List<TodayOrderParcel> orederList = [];

  bool isFetch = true;
  bool isRun = false;

  dynamic curency;

  dynamic status = 0;

  SharedPreferences preferences;

  @override
  void initState() {
    getSharedPref();
    super.initState();
    hitStatusServiced();
    getTodayOrders();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        print(tabController.index);
        setState(() {
          isFetch = true;
          if (orederList != null) {
            orederList.clear();
          }
          orederList = null;
        });
        if (tabController.index == 0) {
          getTodayOrders();
        } else if (tabController.index == 1) {
          getNextDayOrders();
        }
      }
    });
  }

  void hitStatusServiced() async {
    setState(() {
      isRun = true;
    });
    preferences = await SharedPreferences.getInstance();
    var vendorId = preferences.getInt('vendor_id');
    print('${status} - ${vendorId}');
    var client = http.Client();
    var statusUrl = store_current_status;
    client.post(statusUrl, body: {'vendor_id': '${vendorId}'}).then((value) {
      setState(() {
        isRun = false;
      });
      if (value.statusCode == 200 && value.body != null) {
        var jsonData = jsonDecode(value.body);
        print('${jsonData.toString()}');
        if (jsonData['status'] == 1) {
          var sats = jsonData['data'][0];
          print('----  --${sats.toString()}');
          var sat = sats['online_status'];
          print('${sat}');
          if (sat == "on" || sat == "On" || sat == "ON") {
            preferences.setInt('duty', 1);
            setState(() {
              status = 1;
            });
          } else if (sat == "off" || sat == "Off" || sat == "OFF") {
            preferences.setInt('duty', 0);
            setState(() {
              status = 0;
            });
          }
        }
        Toast.show(jsonData['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isRun = false;
      });
    });
  }

  void getSharedPref() async {
    preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('duty')) {
      setState(() {
        print('${preferences.getInt('duty')}');
        setState(() {
          status = preferences.getInt('duty');
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    setState(() {
      tabs = <Tab>[
        Tab(text: locale.NEWORDERS),
        Tab(text: locale.NEXTDAYORDERS),
      ];
    });
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            centerTitle: false,
            title: Text(
              locale.myorder,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            actions: [
              isRun
                  ? CupertinoActivityIndicator(
                      radius: 15,
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: (status == 1) ? kRed : kGreen)),
                  color: (status == 1) ? kRed : kGreen,
                  onPressed: () {
                    // Navigator.popAndPushNamed(context, PageRoutes.offlinePage)
                    if (!isRun) {
                      hitStatusService();
                    }
                  },
                  child: Text(
                    '${status == 1 ? locale.GoOffline : locale.GoOnline}',
                    style: Theme.of(context).textTheme.caption.copyWith(
                        color: kWhiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.7,
                        letterSpacing: 0.06),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.0),
              child: TabBar(
                controller: tabController,
                tabs: tabs,
                isScrollable: true,
                labelColor: kMainColor,
                unselectedLabelColor: kLightTextColor,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 24.0),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: tabs.map((Tab tab) {
            return (orederList != null && orederList.length > 0)
                ? ListView.builder(
                    itemCount: orederList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          //
                          if (orederList[index].payment_method == null ||
                              orederList[index].payment_status == null ||
                              '${orederList[index].order_status}'.toUpperCase() == "CANCEL" ||
                              '${orederList[index].order_status}'.toUpperCase() == 'CANCELLED') {
                          } else {
                            Navigator.pushNamed(
                                context, PageRoutes.orderInfoPageparcel,
                                arguments: {
                                  'orderdetails': orederList[index],
                                  'curency': curency,
                                }).then((value) {
                              // print('${tabController.index}');
                              int indi = tabController.index;
                              if (indi == 0) {
                                setState(() {
                                  isFetch = true;
                                  if (orederList != null) {
                                    orederList.clear();
                                  }
                                  orederList = null;
                                });
                                getTodayOrders();
                              } else if (indi == 1) {
                                setState(() {
                                  isFetch = true;
                                  if (orederList != null) {
                                    orederList.clear();
                                  }
                                  orederList = null;
                                });
                                getNextDayOrders();
                              }
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          child: Column(
                            children: [
                              Divider(
                                color: kCardBackgroundColor,
                                thickness: 8.0,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: ListTile(
                                  leading: Image.asset(
                                    'images/user.png',
                                    scale: 2.5,
                                    width: 33.7,
                                    height: 42.3,
                                  ),
                                  title: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text:
                                            '${orederList[index].user_name}\n\n',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .copyWith(
                                                fontSize: 13.3,
                                                letterSpacing: 0.07),
                                      ),
                                      TextSpan(
                                        text:
                                            '${orederList[index].pickup_date} | ${orederList[index].pickup_time}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                                fontSize: 11.7,
                                                letterSpacing: 0.06,
                                                fontWeight: FontWeight.w500),
                                      )
                                    ]),
                                  ),
                                  trailing: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text:
                                            '${curency} ${(double.parse('${orederList[index].distance}') > 1) ? (double.parse('${orederList[index].charges}') * double.parse('${orederList[index].distance}')) : double.parse('${orederList[index].charges}')}\n\n',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .copyWith(
                                                fontSize: 13.3,
                                                letterSpacing: 0.07),
                                      ),
                                      TextSpan(
                                        text:
                                            '${orederList[index].payment_method}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                                fontSize: 11.7,
                                                letterSpacing: 0.06,
                                                fontWeight: FontWeight.w500),
                                      )
                                    ]),
                                  ),
                                ),
                              ),
                              Divider(
                                color: kCardBackgroundColor,
                                thickness: 1.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 20.0, left: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 5, bottom: 5),
                                      child: Text(locale.pickupadd,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.06,
                                                  color: kMainColor)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_city,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${orederList[index].source_houseno}, ${orederList[index].source_add}, ${orederList[index].source_city}, ${orederList[index].source_state}(${orederList[index].source_pincode})\nLandmark :- ${orederList[index].source_landmark}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                      fontSize: 11.7,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.06,
                                                      color:
                                                          Color(0xff393939))),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 5, bottom: 5),
                                      child: Text(locale.destinationadd,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.06,
                                                  color: kMainColor)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_city,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${orederList[index].destination_houseno}, ${orederList[index].destination_add}, ${orederList[index].destination_city}, ${orederList[index].destination_state}(${orederList[index].destination_pincode})\nLandmark :- ${orederList[index].destination_landmark}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                      fontSize: 11.7,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.06,
                                                      color:
                                                          Color(0xff393939))),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color: kCardBackgroundColor,
                                thickness: 1.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Spacer(),
                                    Text(
                                        '${locale.Orderh2} #${orederList[index].cart_id}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                                fontSize: 11.7,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.06,
                                                color: Color(0xff393939))),
                                    Spacer(),
                                    Text(locale.oneparcel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                                fontSize: 11.7,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.06,
                                                color: Color(0xff393939))),
                                    Spacer(),
                                    Text('${orederList[index].order_status}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            .copyWith(
                                                color: Color(0xffffa025),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.7,
                                                letterSpacing: 0.06)),
                                  ],
                                ),
                              ),
                              Divider(
                                color: kCardBackgroundColor,
                                thickness: 8.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isFetch ? CircularProgressIndicator() : Container(),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            isFetch
                                ? locale.fetching1
                                : (tabController.index == 0)
                                    ? locale.fetchingdata1
                                    : locale.fetchingdata2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
          }).toList(),
        ),
      ),
    );
  }

  void hitStatusService() async {
    setState(() {
      isRun = true;
    });
    preferences = await SharedPreferences.getInstance();
    var vendorId = preferences.getInt('vendor_id');
    dynamic statuss = preferences.getInt('duty');
    if (preferences.containsKey('duty')) {
      statuss = preferences.getInt('duty');
    } else {
      statuss = status;
    }
    var client = http.Client();
    var statusUrl = store_status;
    client.post(statusUrl, body: {
      'vendor_id': '${vendorId}',
      'status': (statuss == 1) ? 'off' : 'on'
    }).then((value) {
      setState(() {
        isRun = false;
      });
      if (value.statusCode == 200 && value.body != null) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var sat = jsonData['Status'];
          if (sat == "on" || sat == "On" || sat == "ON") {
            preferences.setInt('duty', 1);
            setState(() {
              status = 1;
            });
          } else if (sat == "off" || sat == "Off" || sat == "OFF") {
            preferences.setInt('duty', 0);
            setState(() {
              status = 0;
            });
          }
        } else {
          preferences.setInt('duty', statuss);
        }
        Toast.show(jsonData['message'], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        setState(() {
          isRun = false;
          status = preferences.getInt('duty');
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isRun = false;
      });
    });
  }

  void getTodayOrders() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      curency = pref.getString('curency');
    });
    orederList = [];
    var vendorId = pref.getInt('vendor_id');
    print('vendor_id ${vendorId}');
    var client = http.Client();
    var todayOrderUrl = parcel_today_order;
    client
        .post(todayOrderUrl, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        if (value.body
                .toString()
                .contains("[{\"order_details\":\"no orders found\"}]") ||
            value.body
                .toString()
                .contains("[{\"no_order\":\"no orders found\"}]")) {
          setState(() {
            orederList = [];
            isFetch = false;
          });
        } else {
          var jsonData = jsonDecode(value.body) as List;
          List<TodayOrderParcel> oreder =
              jsonData.map((e) => TodayOrderParcel.fromJson(e)).toList();
          print('${oreder.toString()}');
          if (oreder != null && oreder.length > 0) {
            isFetch = false;
            setState(() {
              orederList = List.from(oreder);
            });
          } else {
            setState(() {
              isFetch = false;
            });
          }
        }
      } else {
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
      print(e);
    });
  }

  void getNextDayOrders() async {
    orederList = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var vendorId = pref.getInt('vendor_id');
    var client = http.Client();
    var todayOrderUrl = parcel_next_day_order;
    client
        .post(todayOrderUrl, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        if (value.body
                .toString()
                .contains("[{\"order_details\":\"no orders found\"}]") ||
            value.body
                .toString()
                .contains("[{\"no_order\":\"no orders found\"}]")) {
          setState(() {
            orederList = [];
            isFetch = false;
          });
        } else {
          var jsonData = jsonDecode(value.body) as List;
          List<TodayOrderParcel> oreder =
              jsonData.map((e) => TodayOrderParcel.fromJson(e)).toList();
          print('${oreder.toString()}');
          if (oreder != null && oreder.length > 0) {
            isFetch = false;
            setState(() {
              orederList = List.from(oreder);
            });
          } else {
            setState(() {
              isFetch = false;
            });
          }
        }
      } else {
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
      print(e);
    });
  }
}

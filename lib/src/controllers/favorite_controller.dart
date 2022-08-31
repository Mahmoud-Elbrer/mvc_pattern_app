import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/favorite.dart';
import '../repository/product_repository.dart';

class FavoriteController extends ControllerMVC {
  List<Favorite> favorites = <Favorite>[];
  late GlobalKey<ScaffoldState> scaffoldKey;
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FavoriteController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForFavorites();
  }

  void listenForFavorites({String? message}) async {
    final Stream<Favorite> stream = await getFavorites();
    stream.listen((Favorite _favorite) {
      setState(() {
        favorites.add(_favorite);
      });
    }, onError: (a) {
//      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
//        content: Text(S.of(state.context).verify_your_internet_connection),
//      ));

      scaffoldKey.currentState!.showSnackBar(new SnackBar(
        content: new Text(message!),
      ));

    }, onDone: () {
      if (message != null) {
//        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
//          content: Text(message),
//        ));


        scaffoldKey.currentState!.showSnackBar(new SnackBar(
          content: new Text(message),
        ));

      }
    });
  }

  Future<void> refreshFavorites() async {
    favorites.clear();
    listenForFavorites(message: S.of(state!.context)!.favoritesRefreshedSuccessfully);
  }
}

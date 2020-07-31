import 'package:flutter/material.dart';
import 'package:uber/telas/Login.dart';
import 'package:uber/telas/RouteGenerator.dart';


final ThemeData temPadrao = ThemeData(
  primaryColor: Color(0xff37474f),
  accentColor: Color(0xff546e7a)
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Uber",
    home: Login(),
    theme: temPadrao,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.gerarRotas,
    debugShowCheckedModeBanner: false,
    
  ),
  
  );
}

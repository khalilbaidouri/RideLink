import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final moroccoCitiesProvider = FutureProvider<List<String>>((ref) async {
  final response = await http.post(
    Uri.parse(
      "https://countriesnow.space/api/v0.1/countries/cities",
    ),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "country": "Morocco",
    }),
  );

  final data = jsonDecode(response.body);

  final cities = List<String>.from(data["data"]);

  cities.sort();

  return cities;
});

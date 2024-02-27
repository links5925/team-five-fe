import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proto_just_design/class/misiklist_class.dart';
import 'package:proto_just_design/providers/misiklist_provider/misiklist_page_provider.dart';
import 'package:proto_just_design/providers/misiklist_provider/my_misiklist_page_provider.dart';
import 'package:proto_just_design/providers/network_provider.dart';
import 'package:proto_just_design/providers/userdata.dart';
import 'package:proto_just_design/screen_pages/misiklist_page/misiklist_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MyMisiklist extends StatefulWidget {
  const MyMisiklist({super.key});

  @override
  State<MyMisiklist> createState() => _MyMisiklistState();
}

class _MyMisiklistState extends State<MyMisiklist> {
  Future<void> getMyMisiklists() async {
    bool isNetwork = await context.read<NetworkProvider>().checkNetwork();
    if (!isNetwork) {
      return;
    }
    String? token = context.read<UserData>().token;
    final url = Uri.parse('https://api.misiklog.com/v1/misiklist/my/');

    final response = (token == null)
        ? await http.get(url)
        : await http.get(url, headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));

      List<dynamic> responseMisiklists = responseData['results'];
      for (var misiklistData in responseMisiklists) {
        Misiklist misiklist = Misiklist(misiklistData);
        if (mounted) {
          context.read<MyMisiklistProvider>().addMisiklist(misiklist);
        }
        if (misiklist.isBookmarked) {
          if (mounted) {
            context.read<MisiklistProvider>().addFavMisiklist(misiklist.uuid);
          }
        }
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    if (context.read<MisiklistProvider>().myMisiklists.isEmpty) {
      getMyMisiklists();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Misiklist> misiklists =
        context.watch<MisiklistProvider>().myMisiklists;
    int len = misiklists.length;
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 600,
      child: ListView.builder(
        itemCount: len + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == len) {
            return const SizedBox(height: 100);
          }
          if ((index % 2 == 0)) {
            if ((len % 2 == 1) && (index + 2 > len)) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MisiklistButton(misiklist: misiklists[index]),
                  const SizedBox(width: 20),
                  Container(width: 171)
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MisiklistButton(misiklist: misiklists[index]),
                const SizedBox(width: 20),
                MisiklistButton(misiklist: misiklists[index + 1])
              ],
            );
          }
          return Container(height: 20);
        },
      ),
    );
  }
}

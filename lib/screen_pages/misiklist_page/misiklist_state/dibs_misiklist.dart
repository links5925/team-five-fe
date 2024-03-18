import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proto_just_design/class/misiklist_class.dart';
import 'package:proto_just_design/main.dart';
import 'package:proto_just_design/providers/misiklist_provider/dibs_misiklist_provider.dart';
import 'package:proto_just_design/providers/misiklist_provider/misiklist_page_provider.dart';
import 'package:proto_just_design/providers/network_provider.dart';
import 'package:proto_just_design/providers/userdata.dart';
import 'package:proto_just_design/screen_pages/misiklist_page/misiklist_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DibsMisiklist extends StatefulWidget {
  const DibsMisiklist({super.key});

  @override
  State<DibsMisiklist> createState() => _DibsMisiklistState();
}

class _DibsMisiklistState extends State<DibsMisiklist> {
  Future<void> getMisiklists() async {
    bool isNetwork = await context.read<NetworkProvider>().checkNetwork();
    if (!isNetwork) {
      return;
    }
    String? token = context.read<UserDataProvider>().token;
    final url = Uri.parse('${rootURL}v1/misiklist/');

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
          context.read<DibsMisiklistProvider>().addMisiklist(misiklist);
        }
        if (misiklist.isBookmarked) {
          if (mounted) {
            context.read<MisiklistProvider>().addFavMisiklist(misiklist.uuid);
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    } else {}
  }

  @override
  void initState() {
    super.initState();
    if (context.read<DibsMisiklistProvider>().dibsMisiklists.isEmpty) {
      getMisiklists();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Misiklist> misiklists =
        context.watch<DibsMisiklistProvider>().dibsMisiklists.toList();
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

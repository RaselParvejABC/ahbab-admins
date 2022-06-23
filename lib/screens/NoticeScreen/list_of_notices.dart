import 'package:ahbabadmin/FCMNotificationSender/notification_sender.dart';
import 'package:ahbabadmin/dialogs/confirmation_dialog.dart';
import 'package:ahbabadmin/dialogs/inform_dialog.dart';
import 'package:ahbabadmin/dialogs/wait_dialog.dart';
import 'package:ahbabadmin/utilities/for_json.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/accordion/gf_accordion.dart';
import 'package:getwidget/components/loader/gf_loader.dart';

class ListOfNotices extends StatelessWidget {
  const ListOfNotices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('notices').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'কিছু একটা সমস্যা হয়েছে। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          );
        }
        if (snapshot.hasData) {
          QuerySnapshot qs = snapshot.data as QuerySnapshot;
          return Column(
            children: qs.docs.map((e) => getNoticeTile(e, context)).toList(),
          );
        }
        return const GFLoader();
      },
    );
  }

  Widget getNoticeTile(DocumentSnapshot snapshot, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0).copyWith(top: 8.0),
      child: GFAccordion(
        titleChild: Row(
          children: [
            Expanded(
              child: SelectableText(snapshot.get('title')),
            ),
            IconButton(
              icon: const Icon(Icons.doorbell),
              onPressed: () async {
                showWaitDialog(context);
                Notifications notifier = Notifications.instance;
                List<String> to = getListFromJSONArray(snapshot.get('to'));
                if(to.contains('1000')){ // everyone
                  int httpCode = await notifier.send(
                    title: snapshot.get('title'),
                    body: snapshot.get('body'),
                    topic: 'all',
                  );
                  Navigator.of(context).pop();
                  if(httpCode == 200) {
                    showInformDialog(context, 'সফল', 'সদস্যরা নোটিফাইড হবেন।');
                  } else {
                    showInformDialog(context, 'ব্যর্থ', 'নোটিফিকেশন যায়নি। পরে চেষ্টা করুন।');
                  }
                  return;
                }

                for(String memberID in to){
                  DocumentSnapshot memberDoc = await FirebaseFirestore.instance.collection('members').doc(memberID).get();
                  if(!memberDoc.exists){
                    continue;
                  }
                  List<String> tokens = [];
                  try {
                    tokens = getListFromJSONArray(memberDoc.get('FCMTokens'));
                  } catch(e){
                    1;
                  }

                  List<String> expiredTokens = [];

                  for(String token in tokens){
                    int response = await notifier.send(
                      title: snapshot.get('title'),
                      body: snapshot.get('body'),
                      token: token,
                    );
                    if(response == 404) {
                      expiredTokens.add(token);
                    }
                  }
                  tokens.removeWhere((token) => expiredTokens.contains(token));
                  await memberDoc.reference.update({
                    'FCMTokens' : tokens,
                  });
                }

                Navigator.of(context).pop();
                showInformDialog(context, 'সফল', 'সদস্যরা নোটিফাইড হবেন।');
              },
            ),
          ],
        ),
        contentChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () async {
                  bool response = await showConfirmationDialog(context, 'সাবধান', 'আপনি নোটিশটি ডিলিট করতে চাচ্ছেন?');
                  if (!response) {
                    return;
                  }
                  snapshot.reference.delete().then((value) {
                    showInformDialog(context, 'সফল', 'নোটিশ ডাটাবেস থেকে ডিলিট হয়েছে।');
                  }, onError: (error) {
                    showInformDialog(context, 'ব্যর্থ', 'নোটিশ ডাটাবেস থেকে ডিলিট হয়নি। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।');
                  });
                },
              ),
            ),
            SelectableText(
              'By: ' + snapshot.get('byAdmin'),
              textAlign: TextAlign.start,
            ),
            SelectableText(
              'To: ' + getListFromJSONArray(snapshot.get('to')).join(' '),
              textAlign: TextAlign.start,
            ),
            SelectableText(
              'Time: ' + DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot.get('timestamp').toString())).toString(),
              textAlign: TextAlign.start,
            ),
            SelectableText(
              "\n\n" + snapshot.get('body'),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

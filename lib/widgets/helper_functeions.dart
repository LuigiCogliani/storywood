import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/environment.dart';
import '../data/theme_data.dart';

/// copy content from development to the other branches
/// we had to use this one for the welcome tips because they need to have a storywood Id
/// which has to be the same in development, staging and production.
/// Takes in input a list of maps in the format shown in the commented out code
void copyContent({required List<Map> contentTypeAndId}) async {
  //final List contentTypeAndId = [
  // {'contentType': constContentTypeBook, 'id': 'zXOMfp2JdYXr3xibR5oX'},
  // {
  //   'contentType': constContentTypePodcast,
  //   'id': 'wxPqbe2eAWxvxILmSHpC'
  // },
  // {'contentType': constContentTypeTv, 'id': 'uxxpJQcDZfjyMj9IMcpW'},
  // {'contentType': constContentTypeMovie, 'id': 'Bu458kl4ekQrb34eZFjE'}
  //];
  final List environments = ['staging/staging/', 'production/production/'];
  for (var environment in environments) {
    for (var instructions in contentTypeAndId) {
      // first we will assume the id we receive is the SW id
      var content = await FirebaseFirestore.instance
          .doc(
              'development/development/content${instructions['contentType']}/${instructions['id']}')
          .get();
      await FirebaseFirestore.instance
          .collection('${environment}content${instructions['contentType']}/')
          .doc('${instructions['id']}')
          .set(content.data()!);
    }
  }
}

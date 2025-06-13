import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  //create
  Future<void> addItem(String item) {
    return items.add({
      'item': item,
      'timestamp': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getItemsStream() {
    final itemStream = items.orderBy('timestamp', descending: true).snapshots();

    return itemStream;
  }
  //update

  //delete

  // Function to get a stream of real-time updates from a Firestore collection
  Stream<QuerySnapshot> getFieldServicesStream() {
    return _firestore.collection('field_services').snapshots();
  }
}

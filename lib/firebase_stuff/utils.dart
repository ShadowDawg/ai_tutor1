import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadThreadIdToFirebase(
    String userId,
    String assistantId,
    String grade,
    String subject,
    String chapterNumber,
    String levelNumber,
    String threadId) async {
  DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

  print(grade);

  try {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDocRef);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      Map<String, dynamic> userData =
          snapshot.data() as Map<String, dynamic>? ?? {};
      Map<String, dynamic> threadsMap =
          userData['ThreadsMap'] as Map<String, dynamic>? ?? {};

      // Navigate through the nested structure to set the thread ID
      if (!threadsMap.containsKey(assistantId)) {
        threadsMap[assistantId] = {};
      }
      if (!threadsMap[assistantId].containsKey(grade)) {
        threadsMap[assistantId][grade] = {};
      }
      if (!threadsMap[assistantId][grade].containsKey(subject)) {
        threadsMap[assistantId][grade][subject] = {};
      }
      if (!threadsMap[assistantId][grade][subject].containsKey(chapterNumber)) {
        threadsMap[assistantId][grade][subject][chapterNumber] = {};
      }

      threadsMap[assistantId][grade][subject][chapterNumber][levelNumber] =
          threadId;

      transaction.update(userDocRef, {'ThreadsMap': threadsMap});
    });
  } catch (e) {
    print('Error updating thread ID in Firebase: $e');
    // Handle the error appropriately
  }
}

Future<void> createSubjectDocument() async {
  // Reference to the Firestore collection and document
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection('classes')
      .doc('5') // Assuming '5' is the grade identifier
      .collection('subjectList')
      .doc('evs'); // Assuming 'evs' is the subject identifier

  // Data to be added
  List<Map<String, String>> chapterList = [
    {'index': '1', 'name': 'Super Senses', 'assId': 'ADD_ASST_ID'},
    {'index': '2', 'name': 'A Snake Charmer’s Story', 'assId': 'ADD_ASST_ID'},
    {'index': '3', 'name': 'From Tasting to Digesting', 'assId': 'ADD_ASST_ID'},
    {'index': '4', 'name': 'Mangoes Round the Year', 'assId': 'ADD_ASST_ID'},
    {'index': '5', 'name': 'Seeds and Seeds', 'assId': 'ADD_ASST_ID'},
    {'index': '6', 'name': 'Every Drop Counts', 'assId': 'ADD_ASST_ID'},
    {'index': '7', 'name': 'Experiments with Water', 'assId': 'ADD_ASST_ID'},
    {'index': '8', 'name': 'A Treat for Mosquitoes', 'assId': 'ADD_ASST_ID'},
    {'index': '9', 'name': 'Up You Go!', 'assId': 'ADD_ASST_ID'},
    {'index': '10', 'name': 'Walls Tell Stories', 'assId': 'ADD_ASST_ID'},
    {'index': '11', 'name': 'Sunita in Space', 'assId': 'ADD_ASST_ID'},
    {'index': '12', 'name': 'What if it Finishes ...?', 'assId': 'ADD_ASST_ID'},
    {'index': '13', 'name': 'A Shelter so High!', 'assId': 'ADD_ASST_ID'},
    // Add more chapters as needed
  ];

  // Add the document with the 'chapterList' field
  await documentReference.set({'chapterList': chapterList}).catchError((e) {
    print(e); // Handle the error appropriately
  });
}

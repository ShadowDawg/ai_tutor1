// File: api_stuff.dart
import 'package:ai_tutor1/models/chapter_info_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = "http://10.0.2.2:3000/api"; // local
//const baseUrl = "https://ornate-entropy-414110.el.r.appspot.com/api";

Future<String> sendMessageToAPI(String text) async {
  try {
    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2:3000/chat'), // Replace with your API endpoint (localhost of comp is kinda different in emulator )
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'prompt': text}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return "Bot: ${data['message']}";
    } else {
      print('Failed to get response from API');
      return "Failed to get response from API";
    }
  } catch (e) {
    print('Error: $e');
    return "Error: $e";
  }
}

Future<Map<String, dynamic>> initChat(
    grade, subject, chapterNumber, levelNumber) async {
  final response = await http.post(
    Uri.parse('$baseUrl/init-chat'),
    headers: {
      'Content-Type': 'application/json',
      // Include any other headers your API requires
    },
    body: json.encode({
      'grade': grade,
      'subject': subject,
      'chapterNumber': chapterNumber,
      'levelNumber': levelNumber,
    }),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to initialize chat');
  }
}

Future<List<dynamic>> getChat(String threadId) async {
  final url = Uri.parse('$baseUrl/get-chat');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'threadId': threadId,
    }),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get chat response: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> sendUserResponseAndGetThread(
    String threadId, String userMessage) async {
  final response = await http.post(
    Uri.parse('$baseUrl/send-user-response'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'threadId': threadId,
      'userMessage': userMessage,
    }),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['messages'] ?? []; // Return an empty list if 'messages' is null
  } else {
    throw Exception(
        'Failed to send user response and get thread: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> getAssResponse(
    String threadId, String assistantId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/get-ass-response'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'threadId': threadId,
      'assistantId': assistantId,
    }),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    print(data);
    return {
      'messages':
          data['messages'] ?? [], // Return an empty list if 'messages' is null
      'verdict':
          data['verdict'], // Return the verdict, can be null if not provided
      'is_level_complete': data['is_level_complete']
    };
  } else {
    throw Exception('Failed to get assistant response: ${response.statusCode}');
  }
}

Future<List<String>> getChatResponse(
    String threadId, String assistantId, String userMessage) async {
  final url = Uri.parse('$baseUrl/chat-response');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'threadId': threadId,
      'assistantId': assistantId,
      'userMessage': userMessage,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['messages'].cast<String>();
  } else {
    throw Exception('Failed to get chat response: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> getChapterList(
    String grade, String subject) async {
  final response = await http.post(
    Uri.parse('$baseUrl/get-chapter-list'),
    headers: {
      'Content-Type': 'application/json',
      // Include any other headers your API requires
    },
    // If your API uses POST method, you might need to change it to http.post and include a body
    body: json.encode({'grade': grade, 'subject': subject}),
  );

  print("Requesting chapterList for grade $grade, subject $subject");

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    print(data);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception(
        'Failed to load chapter list. Status code: ${response.statusCode}');
  }
}

Future<String> getQuestionsByGradeSubjectChapter(
    String grade, String subject, String chapterNumber) async {
  print(
      "Fetching question list for class ${grade}, subject ${subject}, chapter ${chapterNumber}");
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/get-questions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'grade': grade,
        'subject': subject.toLowerCase(), // Ensure the subject is in lowercase
        'chapterNumber': chapterNumber,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully retrieved data
      print("Success.");
      return response.body; // Returns the JSON string
    } else {
      // Handle server response errors
      throw Exception(
          'Failed to load questions. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any exceptions
    throw Exception('Error fetching questions: $e');
  }
}

Future<void> addStars(String userId, int starsToAdd) async {
  final headers = {"Content-Type": "application/json"};
  final body = json.encode({
    "userId": userId,
    "starsToAdd": starsToAdd,
  });

  try {
    final response = await http.post(Uri.parse("$baseUrl/firebase/add-stars"),
        headers: headers, body: body);

    if (response.statusCode == 200) {
      print("stars added successfully.");
    } else {
      print("Failed to add stars. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error adding stars: $e");
  }
}

Future<Map<String, dynamic>> getUserStarsAndStreak(String userId) async {
  final headers = {"Content-Type": "application/json"};
  final body = json.encode({
    "userId": userId,
  });

  try {
    final response = await http.post(
        Uri.parse("$baseUrl/firebase/get-stars-and-streak"),
        headers: headers,
        body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData ?? {}; // Returns 0 if stars is not found
    } else {
      throw Exception('Failed to load user stats');
    }
  } catch (e) {
    print('Error fetching user stats: $e');
    throw Exception('Error fetching user stats');
  }
}

Future<void> updateLevelCompletion(String userId, String grade, String subject,
    String chapterNumber, String levelNumber) async {
  final url = Uri.parse(
      '$baseUrl/firebase/update-level-completion'); // Replace with your actual server URL
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'userId': userId,
      'grade': grade,
      'subject': subject,
      'chapterNumber': chapterNumber,
      'levelNumber': levelNumber,
    }),
  );

  if (response.statusCode == 200) {
    print('Level completion updated successfully.');
  } else {
    throw Exception('Failed to update level completion: ${response.body}');
  }
}

Future<Map<String, dynamic>> fetchChapterCompletion(
    String userId, String grade, String subject) async {
  final Uri url = Uri.parse('$baseUrl/firebase/get-level-completion');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'grade': grade,
        'subject': subject,
      }),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> completionDetails = json.decode(response.body);
      print(completionDetails);
      return completionDetails;
    } else {
      // Handle server errors or invalid responses
      print('Server error: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    // Handle any exceptions/errors that may occur during the HTTP request
    print('Error fetching chapter completion details: $e');
    return {};
  }
}

// Future<List<Chapter>> fetchChapters(String grade, String subject) async {
//   try {
//     // Call the getChapterList function with the provided grade and subject
//     List<Map<String, dynamic>> chapterData =
//         await getChapterList(grade, subject);

//     // Map the response data to a list of Chapter objects
//     List<Chapter> chapters = chapterData.map((chapterMap) {
//       // Parse the assId field, which is a map
//       Map<String, String> assIdMap = {};
//       var assIdJson = chapterMap['assId'];
//       if (assIdJson is Map) {
//         assIdMap = Map<String, String>.from(assIdJson);
//       }

//       return Chapter(
//         chapterMap['index'].toString(),
//         chapterMap['name'],
//         assIdMap,
//       );
//     }).toList();

//     return chapters;
//   } catch (e) {
//     // Handle any exceptions here
//     print('Error fetching chapters: $e');
//     throw Exception('Could not fetch chapters');
//   }
// }

Future<List<String>> getSubjectList(String grade) async {
  final url = Uri.parse(
      '$baseUrl/firebase/get-subject-list'); // Replace with your actual backend URL
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'grade': grade}),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<String> subjects = List<String>.from(data['subjects']);
    return subjects;
  } else {
    throw Exception('Failed to load subjects');
  }
}

Future<Map<String, dynamic>> fetchUserData(String userId) async {
  print("fetching user data.");
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/firebase/get-user-data'),
      body: jsonEncode({'userId': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body) as Map<String, dynamic>;
      return userData;
    } else {
      throw Exception('Failed to fetch user data: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching user data: $error');
  }
}

Future<Map<String, dynamic>> getLeaderboardAndUserRank(
    String userId, String grade, String school) async {
  final response = await http.post(
    Uri.parse("$baseUrl/firebase/get-leaderboard"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'userId': userId,
      'grade': grade,
      'school': school,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return json.decode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load leaderboard');
  }
}

Future<Map<String, dynamic>> onChatOpen({
  required String userId,
  required String grade,
  required String subject,
  required String chapterNumber,
  required String levelNumber,
}) async {
  final url = Uri.parse(
      '$baseUrl/on-chat-open'); // Replace with your actual API base URL
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'grade': grade,
      'subject': subject,
      'chapterNumber': chapterNumber,
      'levelNumber': levelNumber,
    }),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to open chat: ${response.body}');
  }
}

Future<Map<String, dynamic>> updateStreak(String userId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/firebase/update-streak'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assuming the backend returns an object with "streakUpdated" and "currentStreak"
      return {
        'streakUpdated': data['streakUpdated'],
        'currentStreak': data['currentStreak'],
      };
    } else {
      // Handle server errors
      print('Server error: ${response.body}');
      return {'error': 'Failed to update streak'};
    }
  } catch (e) {
    // Handle any errors that occur during HTTP send/receive
    print('Error updating streak: $e');
    return {'error': 'Failed to connect to server'};
  }
}

import 'package:ctt/pages/admin/admin_dashboard.dart';
import 'package:ctt/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ctt/utils/base_url.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final baseUrl = BaseUrl.baseUrl;

  final _formKey = GlobalKey<FormState>();
  Map currentRequest = {};
  final titleController = TextEditingController();
  String eventTitle = '';
  String selectedType = '';
  String eventType = 'Seminar';
  final topicController = TextEditingController();
  String eventTopic = '';
  final descriptionController = TextEditingController();
  String eventDescription = '';
  final startDateController = TextEditingController();
  DateTime? eventStartDate;
  final endDateController = TextEditingController();
  DateTime? eventEndDate;
  final startTimeController = TextEditingController();
  String eventStartTime = '';
  final endTimeController = TextEditingController();
  String? eventEndTime;
  final imageURLController = TextEditingController();
  String eventImageURL = '';

  String name = 'Guest';
  String role = 'GUEST';
  String email = '';

  int selectedIndex = 0;
  int selectedPage = 0;
  final searchController = TextEditingController();
  String currentFilter = 'All';

  List events = [
    {
      'id': '1',
      'image': '',
      'title': 'Flutter Workshop',
      'category': 'Seminar',
      'description':
          'A flutter workshop that teaches flutter basics and everything else inbetween',
      'topic': 'Mobile Hybrid Solution',
      'startDate': '2026-06-20',
      'endDate': '',
      'startTime': '09:20',
      'endTime': '13:00',
      'status': 'APPROVED',
    },
    {
      'id': '2',
      'image':
          'https://images.unsplash.com/photo-1555255707-c07966088b7b?w=800&q=80',
      'title': 'Flutter Bootcamp',
      'category': 'Bootcamp',
      'description':
          'A flutter bootcamp that teaches flutter basics and everything else inbetween',
      'topic': 'Mobile Hybrid Solution',
      'startDate': '2026-06-21',
      'endDate': '',
      'startTime': '07:20',
      'endTime': '11:00',
      'status': 'APPROVED',
    },
  ];

  List searchedEvents = [];
  Map currentEvent = {};

  List bookings = [
    {
      'id': '2',
      'image':
          'https://images.unsplash.com/photo-1555255707-c07966088b7b?w=800&q=80',
      'title': 'Flutter Bootcamp',
      'category': 'Bootcamp',
      'description':
          'A flutter bootcamp that teaches flutter basics and everything else inbetween',
      'topic': 'Mobile Hybrid Solution',
      'startDate': '2026-06-21',
      'endDate': '',
      'startTime': '07:20',
      'endTime': '11:00',
      'status': 'APPROVED',
    },
  ];

  List requests = [
    {
      'id': '3',
      'image':
          'https://images.unsplash.com/photo-1555255707-c07966088b7b?w=800&q=80',
      'title': 'Flutter Bootcamp',
      'category': 'Bootcamp',
      'description':
          'A flutter bootcamp that teaches flutter basics and everything else inbetween',
      'topic': 'Mobile Hybrid Solution',
      'startDate': '2026-06-21',
      'endDate': '',
      'startTime': '07:20',
      'endTime': '11:00',
      'status': 'APPROVED',
    },
  ];

  List notifications = [
    {
      'message':
          'You booked "Introduction to Flutter Introduction to Flutter Introduction to Flutter"',
      'date': '2026-06-20',
      'time': '14:15',
      'status': 'UNREAD',
    },
    {
      'message': 'You booked "Pico"',
      'date': '2026-06-21',
      'time': '17:15',
      'status': 'UNREAD',
    },
    {
      'message': 'You booked "Introduction to Flutter"',
      'date': '2026-06-20',
      'time': '14:15',
      'status': 'READ',
    },
  ];

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "Guest";
      role = prefs.getString("role") ?? "GUEST";
      email = prefs.getString("email") ?? "";
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("name");
    await prefs.remove("role");
    await prefs.remove("email");

    if (!mounted) return;

    setState(() {
      name = 'Guest';
      role = 'GUEST';
      email = '';
      selectedIndex = 0;
      selectedPage = 0;
    });
  }

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          events = List<Map<String, dynamic>>.from(
            data.map(
              (event) => {
                'id': event['id'],
                'image': event['imageUrl'] ?? '',
                'title': event['title'] ?? '',
                'category': event['category'] ?? '',
                'description': event['description'] ?? '',
                'topic': event['topic'] ?? '',
                'location': event['location'] ?? '',
                'startDate': event['startDate']?.toString().split('T')[0] ?? '',
                'endDate': event['endDate']?.toString().split('T')[0] ?? '',
                'startTime': event['startTime'] ?? '',
                'endTime': event['endTime'] ?? '',
                'status': 'APPROVED',
              },
            ),
          );
          print(data);
          searchedEvents = List.from(events);
        });

        print("EVENT COUNT: ${events.length}");
      } else {
        debugPrint('Failed to load events: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> bookEvent() async {
    try {
      final headers = await getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        headers: headers,
        body: jsonEncode({'eventId': currentEvent['id']}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getBookings();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event booked successfully')),
        );

        await createNotifications();
      } else {
        debugPrint(response.body);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to book event')));
      }
    } catch (e) {
      debugPrint('Book event error: $e');
    }
  }

  Future<void> unbookEvent(String bookingId) async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/bookings/$bookingId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await getBookings();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Unbook event error: $e');
    }
  }

  Future<void> getBookings() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/my'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          bookings = data.map((booking) {
            final event = booking['event'];

            return {
              'bookingId': booking['id'],
              'id': event['id'],
              'imageURL': event['imageUrl'] ?? '',
              'title': event['title'] ?? '',
              'category': event['category'] ?? '',
              'description': event['description'] ?? '',
              'topic': event['topic'] ?? '',
              'startDate': event['startDate'] ?? '',
              'endDate': event['endDate'] ?? '',
              'startTime': event['startTime'] ?? '',
              'endTime': event['endTime'] ?? '',
              'status': event['status'] ?? 'APPROVED',
            };
          }).toList();
          print(bookings);
        });
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Get bookings error: $e');
    }
  }

  Future<void> addRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (eventStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    if (eventEndDate == null) {
      eventEndDate = eventStartDate;
    }

    try {
      final headers = await getHeaders();

      final body = {
        'title': eventTitle,
        'description': eventDescription,
        'imageUrl': eventImageURL,
        'category': eventType,
        'topic': eventTopic,
        'startDate': eventStartDate!.toUtc().toIso8601String(),
        'endDate': eventEndDate!.toUtc().toIso8601String(),
        'startTime': eventStartTime,
        'endTime': eventEndTime ?? '',
      };

      print(body);

      final response = await http.post(
        Uri.parse('$baseUrl/api/requests'),
        headers: headers,
        body: jsonEncode(body),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getRequests();

        setState(() {
          selectedPage = 3;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      debugPrint('Add request error: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> getRequests() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/requests/my'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          requests = data.map((request) {
            return {
              'id': request['id'],
              'imageUrl': request['imageUrl'] ?? '',
              'title': request['title'] ?? '',
              'category': request['category'] ?? '',
              'description': request['description'] ?? '',
              'topic': request['topic'] ?? '',
              'startDate': request['startDate'] ?? '',
              'endDate': request['endDate'] ?? '',
              'startTime': request['startTime'] ?? '',
              'endTime': request['endTime'] ?? '',
              'status': request['status'] ?? 'PENDING',
            };
          }).toList();
        });
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Get requests error: $e');
    }
  }

  Future<void> editRequest() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final headers = await getHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/api/requests/${currentRequest["id"]}'),
        headers: headers,
        body: jsonEncode({
          'title': titleController.text,
          'description': descriptionController.text,
          'imageUrl': imageURLController.text,
          'category': eventType,
          'topic': topicController.text,
          'startDate': eventStartDate!.toUtc().toIso8601String(),
          'endDate': eventEndDate!.toUtc().toIso8601String(),
          'startTime': startTimeController.text,
          'endTime': endTimeController.text,
        }),
      );

      if (response.statusCode == 200) {
        await getRequests();

        setState(() {
          selectedPage = 3;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request updated successfully')),
        );
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Edit request error: $e');
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/requests/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await getRequests();

        setState(() {
          selectedPage = 3;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request deleted')));
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Delete request error: $e');
    }
  }

  Future<void> createNotifications() async {
    try {
      final headers = await getHeaders();

      print("URL: $baseUrl/notifications");

      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
        body: jsonEncode({}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
    } catch (e) {
      debugPrint('Create notification error: $e');
    }
  }

  Future<void> getNotifications() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          notifications = data.map((notification) {
            return {
              'id': notification['id'],
              'message': notification['message'] ?? '',
              'date': notification['createdAt'] ?? '',
              'status': notification['isRead'] ? 'READ' : 'UNREAD',
            };
          }).toList();

          // print(notifications);
        });
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Get notifications error: $e');
    }
  }

  Future<void> readAllNotifications() async {
    try {
      final headers = await getHeaders();

      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await getNotifications();
      } else {
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Read all notifications error: $e');
    }
  }

  String getInitials(String name) {
    List<String> parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void searchEvents(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        searchedEvents = List.from(events);
        return;
      }

      searchedEvents = events.where((event) {
        final title = event['title'].toString().toLowerCase();
        final description = event['description'].toString().toLowerCase();
        final topic = event['topic'].toString().toLowerCase();

        final search = query.toLowerCase();

        return title.contains(search) ||
            description.contains(search) ||
            topic.contains(search);
      }).toList();
    });
  }

  Future<void> showDeleteDialog(Map request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          "Delete Request?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          "This will permanently remove your event request.",
          style: TextStyle(color: Color(0xFF555555), fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFE9DD),
              foregroundColor: Color(0xFFD97941),
            ),
            child: Text("Cancel", style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Color(0xFFFFFFFF),
            ),
            child: Text("Delete", style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteRequest(request['id']);
    }
  }

  Widget buildItemList(
    List items,
    String filter,
    bool clickable,
    bool editable,
  ) {
    String eventFilter = filter;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['category'] == eventFilter || eventFilter == 'All') {
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => clickable
                ? setState(() {
                    selectedPage = 5;
                    currentEvent = item;
                  })
                : null,
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFD97941), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['imageUrl'] != null && item['imageUrl'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Image.network(
                        "${item['imageUrl']}",
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    SizedBox(height: 0),

                  Container(
                    padding: EdgeInsetsGeometry.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFE9DD),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Color(0xFFD97941),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                item['category'],
                                style: TextStyle(
                                  color: Color(0xFFD97941),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        Text(
                          item['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF555555),
                          ),
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFFD97941),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              item['topic'],
                              style: TextStyle(
                                color: Color(0xFFD97941),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 14),
                            SizedBox(width: 4),
                            Text(
                              item['startDate'],
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14),
                            SizedBox(width: 4),
                            Text(
                              '${item['startTime']} - ${item['endTime']}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  editable
                      ? Row(
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() {
                                  selectedPage = 6;
                                  currentRequest = item;
                                }),
                                icon: Icon(Icons.edit_outlined),
                                label: Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFE9DD),
                                  foregroundColor: Color(0xFFD97941),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => showDeleteDialog(item),
                                icon: Icon(Icons.delete_outline),
                                label: Text(
                                  'Delete',
                                  style: TextStyle(fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  foregroundColor: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        )
                      : SizedBox(height: 0),

                  editable ? SizedBox(height: 6) : SizedBox(height: 0),
                ],
              ),
            ),
          );
        } else {
          return SizedBox(height: 0);
        }
      },
    );
  }

  Widget buildNotificationList(List notifications) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: notification['status'] == 'UNREAD'
                ? Color(0xFFFFE9DD)
                : Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFD97941), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsetsGeometry.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          color: Color(0xFFD97941),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['message'],
                                style: TextStyle(fontSize: 14),
                              ),

                              Text(
                                '${notification['date']}}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        notification['status'] == 'UNREAD'
                            ? SizedBox(width: 8)
                            : SizedBox(width: 0),

                        notification['status'] == 'UNREAD'
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFD97941),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Color(0xFFD97941),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'New',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : SizedBox(width: 0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getCurrentPage(int index) {
    switch (index) {
      case 0:
        {
          // Discover Page
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Events',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              SizedBox(height: 2),

              Text(
                'Find CS-related seminars, websites, bootcamps, and tutoring sessions',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),

              SizedBox(height: 8),

              TextField(
                controller: searchController,
                onChanged: searchEvents,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFFFFF),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: Color(0xFF555555)),

                  SizedBox(width: 8),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      currentFilter = 'All';
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: (currentFilter == 'All')
                            ? Color(0xFFD97941)
                            : Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: (currentFilter == 'All')
                              ? Color(0xFFFFFFFF)
                              : Color(0xFF000000),
                          fontSize: (currentFilter == 'All') ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      currentFilter = 'seminar';
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: (currentFilter == 'seminar')
                            ? Color(0xFFD97941)
                            : Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: Text(
                        'Seminar',
                        style: TextStyle(
                          color: (currentFilter == 'seminar')
                              ? Color(0xFFFFFFFF)
                              : Color(0xFF000000),
                          fontSize: (currentFilter == 'seminar') ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      currentFilter = 'webinar';
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: (currentFilter == 'webinar')
                            ? Color(0xFFD97941)
                            : Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: Text(
                        'Webinar',
                        style: TextStyle(
                          color: (currentFilter == 'webinar')
                              ? Color(0xFFFFFFFF)
                              : Color(0xFF000000),
                          fontSize: (currentFilter == 'webinar') ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      currentFilter = 'bootcamp';
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: (currentFilter == 'bootcamp')
                            ? Color(0xFFD97941)
                            : Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: Text(
                        'Bootcamp',
                        style: TextStyle(
                          color: (currentFilter == 'bootcamp')
                              ? Color(0xFFFFFFFF)
                              : Color(0xFF000000),
                          fontSize: (currentFilter == 'bootcamp') ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      currentFilter = 'tutoring';
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: (currentFilter == 'tutoring')
                            ? Color(0xFFD97941)
                            : Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: Text(
                        'Tutoring',
                        style: TextStyle(
                          color: (currentFilter == 'tutoring')
                              ? Color(0xFFFFFFFF)
                              : Color(0xFF000000),
                          fontSize: (currentFilter == 'tutoring') ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              buildItemList(searchedEvents, currentFilter, true, false),
            ],
          );
        }

      case 1:
        {
          // Bookings Page
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              SizedBox(height: 2),

              Text(
                'Your registered events and sessions',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),

              SizedBox(height: 8),

              bookings.isEmpty
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 64),

                          Icon(Icons.calendar_today_outlined, size: 80),

                          SizedBox(height: 20),

                          Text(
                            'No bookings yet!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Browse events on the Discover page',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    )
                  : buildItemList(bookings, currentFilter, true, false),
            ],
          );
        }

      case 2:
        {
          // Add Page
          titleController.text = '';
          selectedType = 'Seminar';
          topicController.text = '';
          descriptionController.text = '';
          startDateController.text = '';
          endDateController.text = '';
          startTimeController.text = '';
          endTimeController.text = '';
          imageURLController.text = '';

          eventStartDate = null;
          eventStartTime = '';
          eventEndDate = null;
          eventEndTime = '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request New Event',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              SizedBox(height: 2),

              Text(
                'Submit for admin approval',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),

              SizedBox(height: 16),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            onChanged: (value) => eventTitle = value,
                            decoration: InputDecoration(
                              labelText: "Event Title *",
                              hintText: "e.g. Introduction to Flutter",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Event title is required!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField(
                            value: eventType,
                            decoration: InputDecoration(
                              label: Text("Event Type *"),
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            isExpanded: true,
                            items:
                                ["Seminar", "Webinar", "Bootcamp", 'Tutoring']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setState(() {
                              eventType = v!;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Event type is required!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            onChanged: (value) => eventTopic = value,
                            decoration: InputDecoration(
                              labelText: "Event Topic *",
                              hintText: "e.g. Mobile Hybrid Solution",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Topic is required!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            onChanged: (value) => eventDescription = value,
                            decoration: InputDecoration(
                              labelText: "Description *",
                              hintText: "Describe the event...",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Description is required!";
                              }
                              return null;
                            },
                            minLines: 1,
                            maxLines: null,
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: startDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Start Date *",
                                    hintText: 'dd/mm/yyyy',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2026),
                                      lastDate: DateTime(2035),
                                      initialDate: DateTime.now(),
                                    );

                                    if (picked != null) {
                                      startDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                      eventStartDate = picked;
                                    }
                                  },
                                  validator: (value) {
                                    if (eventStartDate == null) {
                                      return "Start date is required!";
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                child: TextFormField(
                                  controller: startTimeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Start Time *",
                                    hintText: '--:-- --',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (picked != null) {
                                      startTimeController.text = picked.format(
                                        context,
                                      );
                                      eventStartTime = picked.format(context);
                                    }
                                  },
                                  validator: (value) {
                                    if (eventStartTime.isEmpty) {
                                      return "Start time is required!";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: endDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "End Date",
                                    hintText: 'dd/mm/yyyy',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2026),
                                      lastDate: DateTime(2035),
                                      initialDate: DateTime.now(),
                                    );

                                    if (picked != null) {
                                      endDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                      eventEndDate = picked;
                                    }
                                  },
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                child: TextFormField(
                                  controller: endTimeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "End Time",
                                    hintText: '--:-- --',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (picked != null) {
                                      endTimeController.text = picked.format(
                                        context,
                                      );
                                      eventEndTime = picked.format(context);
                                    }
                                  },
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            onChanged: (value) => eventImageURL = value,
                            decoration: InputDecoration(
                              labelText: "Image URL (Optional)",
                              hintText: "https://example.com/image.jpg",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: addRequest,
                              child: Text("Submit Request"),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFE9DD),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFFD97941),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Note: Your event will be reviewed by an admin before appearing in the discovery feed.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

      case 3:
        {
          // Requests Page
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Pending Requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              SizedBox(height: 2),

              Text(
                "Events you have submitted, please wait for admin's approval",
                style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),

              SizedBox(height: 8),

              requests.isEmpty
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 64),

                          Icon(Icons.description_outlined, size: 80),

                          SizedBox(height: 8),

                          Text(
                            'No event requests yet',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF555555),
                            ),
                          ),

                          SizedBox(height: 8),

                          ElevatedButton.icon(
                            onPressed: () => setState(() {
                              selectedIndex = 2;
                              selectedPage = 2;
                            }),
                            icon: Icon(Icons.add, color: Color(0xFFFFFFFF)),
                            label: Text(
                              'Submit an Event',
                              style: TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : buildItemList(requests, currentFilter, false, true),
            ],
          );
        }

      case 4:
        {
          // Notifications Page
          getNotifications();
          List unreadNotifications = notifications.where((notif) {
            final notifStatus = notif['status'].toString();

            return notifStatus == 'UNREAD';
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  unreadNotifications.isEmpty
                      ? SizedBox(width: 0)
                      : InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            readAllNotifications();

                            getNotifications();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFE9DD),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Color(0xFFD97941),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Mark all as read',
                              style: TextStyle(
                                color: Color(0xFFD97941),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),

              SizedBox(height: 8),

              notifications.isEmpty
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 64),

                          Icon(Icons.notifications_none_outlined, size: 80),

                          SizedBox(height: 20),

                          Text(
                            'No notifications yet!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    )
                  : buildNotificationList(notifications),
            ],
          );
        }

      case 5:
        {
          // Details Page
          List eventBooked = bookings.where((booking) {
            final bookId = booking['id'].toString();
            final eventId = currentEvent['id'].toString();

            return bookId == eventId;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE9DD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          selectedPage = selectedIndex;
                        }),
                        icon: Icon(
                          Icons.keyboard_backspace,
                          size: 14,
                          color: Color(0xFFD97941),
                        ),
                        label: Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFFD97941),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (currentEvent['image'] != null &&
                  currentEvent['image'].isNotEmpty)
                SizedBox(height: 12)
              else
                SizedBox(height: 0),

              if (currentEvent['image'] != null &&
                  currentEvent['image'].isNotEmpty)
                ClipRRect(
                  child: Image.network(
                    "${currentEvent['image']}",
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                SizedBox(height: 0),

              Container(
                padding: EdgeInsetsGeometry.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            currentEvent['title'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFE9DD),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Color(0xFFD97941),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            currentEvent['category'],
                            style: TextStyle(
                              color: Color(0xFFD97941),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFD97941),
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          currentEvent['topic'],
                          style: TextStyle(
                            color: Color(0xFFD97941),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE9DD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFD97941), width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                                color: Color(0xFFD97941),
                              ),
                              SizedBox(width: 8),
                              Text(
                                currentEvent['startDate'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: Color(0xFFD97941),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${currentEvent['startTime']} - ${currentEvent['endTime']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      currentEvent['description'],
                      style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                    ),

                    SizedBox(height: 12),

                    if (role != 'GUEST')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => eventBooked.isEmpty
                                  ? bookEvent()
                                  : unbookEvent(currentEvent['id']),
                              style: eventBooked.isEmpty
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFD97941),
                                      foregroundColor: Color(0xFFFFFFFF),
                                    )
                                  : ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Color(0xFFFFFFFF),
                                    ),
                              label: eventBooked.isEmpty
                                  ? Text(
                                      'Book Event',
                                      style: TextStyle(fontSize: 16),
                                    )
                                  : Text(
                                      'Booked',
                                      style: TextStyle(fontSize: 16),
                                    ),
                              icon: eventBooked.isEmpty
                                  ? null
                                  : Icon(Icons.check),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        }

      case 6:
        {
          // Edit Page
          titleController.text = currentRequest['title'];
          selectedType = currentRequest['category'];
          topicController.text = currentRequest['topic'];
          descriptionController.text = currentRequest['description'];
          startDateController.text = currentRequest['startDate'];
          endDateController.text = currentRequest['endDate'] ?? "";
          startTimeController.text = currentRequest['startTime'];
          endTimeController.text = currentRequest['endTime'] ?? "";
          imageURLController.text = currentRequest['image'] ?? "";

          eventStartDate = DateTime.parse(currentRequest['startDate']);
          eventStartTime = currentRequest['startTime'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Event',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              SizedBox(height: 2),

              Text(
                'Update requested event details',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),

              SizedBox(height: 16),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: "Event Title *",
                              hintText: "e.g. Introduction to Flutter",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Event title is required!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField(
                            value: selectedType,
                            decoration: InputDecoration(
                              label: Text("Event Type *"),
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            isExpanded: true,
                            items:
                                ["Seminar", "Webinar", "Bootcamp", 'Tutoring']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setState(() {
                              eventType = v!;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Event type is required!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: topicController,
                            decoration: InputDecoration(
                              labelText: "Event Topic *",
                              hintText: "e.g. Mobile Hybrid Solution",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Topic is required!";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: "Description *",
                              hintText: "Describe the event...",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Description is required!";
                              }
                              return null;
                            },
                            minLines: 1,
                            maxLines: null,
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: startDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Start Date *",
                                    hintText: 'dd/mm/yyyy',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2026),
                                      lastDate: DateTime(2035),
                                      initialDate: DateTime.now(),
                                    );

                                    if (picked != null) {
                                      startDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                      eventStartDate = picked;
                                    }
                                  },
                                  validator: (value) {
                                    if (eventStartDate == null) {
                                      return "Start date is required!";
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                child: TextFormField(
                                  controller: startTimeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "Start Time *",
                                    hintText: '--:-- --',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (picked != null) {
                                      startTimeController.text = picked.format(
                                        context,
                                      );
                                      eventStartTime = picked.format(context);
                                    }
                                  },
                                  validator: (value) {
                                    if (eventStartTime.isEmpty) {
                                      return "Start time is required!";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: endDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "End Date",
                                    hintText: 'dd/mm/yyyy',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2026),
                                      lastDate: DateTime(2035),
                                      initialDate: DateTime.now(),
                                    );

                                    if (picked != null) {
                                      endDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                      eventEndDate = picked;
                                    }
                                  },
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                child: TextFormField(
                                  controller: endTimeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "End Time",
                                    hintText: '--:-- --',
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                  ),
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (picked != null) {
                                      endTimeController.text = picked.format(
                                        context,
                                      );
                                      eventEndTime = picked.format(context);
                                    }
                                  },
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: imageURLController,
                            decoration: InputDecoration(
                              labelText: "Image URL (Optional)",
                              hintText: "https://example.com/image.jpg",
                              fillColor: Color(0xFFFFFFFF),
                              filled: true,
                            ),
                            validator: (value) {
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: editRequest,
                              child: Text("Edit Request"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

      default:
        {
          return Text("Invalid");
        }
    }
  }

  @override
  void initState() {
    super.initState();

    initializePage();
  }

  Future<void> initializePage() async {
    await loadUser();

    getEvents();

    if (role != 'GUEST') {
      getBookings();
      getRequests();
      getNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.75,
                child: Image.asset(
                  'assets/images/Ctt_logo.png',
                  height: 80,
                  width: 80,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ctt',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFFFFFFF),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'C things through',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDDDDDD),
                      height: .9,
                    ),
                  ),
                ],
              ),
            ),

            if (role == "GUEST") ...[
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignInPage()),
                ),
                icon: Icon(Icons.login),
                label: Text('Sign In'),
                style: TextButton.styleFrom(
                  iconColor: Color(0xFFFFFFFF),
                  foregroundColor: Color(0xFFFFFFFF),
                  textStyle: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                ),
              ),
            ] else ...[
              SizedBox(
                child: Row(
                  children: [
                    if (role == "ADMIN") ...[
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AdminDashboard()),
                        ),
                        icon: Icon(Icons.shield_outlined),
                        label: Text('Admin'),
                        style: TextButton.styleFrom(
                          iconColor: Color(0xFFFFFFFF),
                          foregroundColor: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],

                    IconButton(
                      onPressed: () => setState(() {
                        selectedPage = 4;
                      }),
                      icon: Icon(
                        Icons.notifications_none,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),

                    SizedBox(width: 4),

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(100),
                        child: PopupMenuButton<String>(
                          child: CircleAvatar(
                            backgroundColor: Color(0xFFFFFFFF),
                            child: Text(
                              getInitials(name),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97941),
                              ),
                            ),
                          ),

                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: Color(0xFF222222),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          onSelected: (value) {
                            if (value == 'logout') {
                              logout();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsetsGeometry.all(16),
        child: getCurrentPage(selectedPage),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFD97941), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xFFFFFFFF),
          selectedItemColor: Color(0xFFD97941),
          unselectedItemColor: Color(0xFF555555),
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 1 && role == "GUEST") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignInPage()),
              );
              return;
            }

            setState(() {
              selectedIndex = index;
              selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Discover',
              activeIcon: Icon(Icons.home),
            ),
            if (role == "GUEST") ...[
              BottomNavigationBarItem(
                icon: Icon(Icons.login),
                label: 'Sign In',
              ),
            ] else if (role != "GUEST") ...[
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                label: 'Bookings',
                activeIcon: Icon(Icons.calendar_today),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_outlined),
                label: 'Add',
                activeIcon: Icon(Icons.add),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                label: 'Requests',
                activeIcon: Icon(Icons.description),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

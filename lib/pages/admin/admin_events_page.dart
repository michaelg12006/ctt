import 'package:ctt/pages/admin/admin_service.dart';
import 'package:flutter/material.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {

  final AdminService adminService = AdminService();

  List<dynamic> events = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {

    try {

      events = await adminService.getEvents();

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

  }

  // Future<void> deleteEvent(String id) async {

  //   await adminService.deleteEvent(id);

  //   await loadEvents();

  // }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Active Events (${events.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Manage approved platform events",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {

              final event = events[index];

              return _buildEventCard(event);

            },
          ),
        )

      ],
    );
  }

  Widget _buildEventCard(dynamic event) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x80F4A261),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "approved",
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )

            ],
          ),

          const SizedBox(height: 8),

          Text(
            "${event['topic'] ?? ""} - ${event['category']}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            event['startDate']
                .toString()
                .substring(0, 10),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Edit feature coming soon"),
                      ),
                    );

                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                ),
              ),

              const SizedBox(width: 12),

              // Expanded(
              //   child: ElevatedButton.icon(
              //     onPressed: () => deleteEvent(event['id']),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.red,
              //     ),
              //     icon: const Icon(
              //       Icons.delete_outline,
              //       color: Colors.white,
              //     ),
              //     label: const Text(
              //       "Delete",
              //       style: TextStyle(
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),

            ],
          )

        ],
      ),
    );
  }

}
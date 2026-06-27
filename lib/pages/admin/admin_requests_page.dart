import 'package:ctt/pages/admin/admin_service.dart';
import 'package:flutter/material.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {

  final AdminService adminService = AdminService();

  List<dynamic> requests = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {

    try {

      requests = await adminService.getRequests();

      requests = requests.where(
        (request) => request['status'] == "PENDING"
      ).toList();

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

  Future<void> approve(String id) async {

    await adminService.approveRequest(id);

    await loadRequests();

  }

  Future<void> reject(String id) async {

    await adminService.rejectRequest(id);

    await loadRequests();

  }

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
                "Pending Requests (${requests.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Review and approve event submissions",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )

            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            itemCount: requests.length,
            itemBuilder: (context, index) {

              final request = requests[index];

              return _buildRequestCard(request);

            },
          ),
        ),

      ],
    );
  }

  Widget _buildRequestCard(dynamic request) {
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
                  request['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                  ),
                ),
                child: Text(
                  request['category'],
                  style: const TextStyle(
                    color: Color(0xFFF57F17),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 8),

          Text(
            request['topic'] ?? "",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            request['startDate']
                .toString()
                .substring(0, 10),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [

              Icon(
                Icons.person_outline,
                size: 14,
                color: Colors.grey.shade600,
              ),

              const SizedBox(width: 4),

              Text(
                "Submitted by: ${request['user']['name']}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

            ],
          ),

          const SizedBox(height: 12),

          Text(
            request['description'] ?? "",
            style: const TextStyle(
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => approve(request['id']),
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Approve",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B050),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => reject(request['id']),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFE53935),
                  ),
                  label: const Text(
                    "Reject",
                    style: TextStyle(
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ),

            ],
          )

        ],
      ),
    );
  }

}
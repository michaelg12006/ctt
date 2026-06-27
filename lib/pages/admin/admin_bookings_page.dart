import 'package:ctt/pages/admin/admin_service.dart';
import 'package:flutter/material.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {

  final AdminService adminService = AdminService();

  List<dynamic> bookings = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {

    try {

      bookings = await adminService.getBookings();

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

  Future<void> deleteBooking(String id) async {

    await adminService.deleteBooking(id);

    await loadBookings();

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
                "Bookings (${bookings.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "All event registrations",
                style: TextStyle(
                  fontSize: 14,
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
            itemCount: bookings.length,
            itemBuilder: (context, index) {

              final booking = bookings[index];

              return _buildBookingCard(booking);

            },
          ),
        ),

      ],
    );
  }

  Widget _buildBookingCard(dynamic booking) {

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
                  booking['event']['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['event']['category'],
                  style: const TextStyle(
                    color: Color(0xFF1967D2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )

            ],
          ),

          const SizedBox(height: 12),

          Text(
            "Student: ${booking['user']['name']} (${booking['user']['email']})",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Event: ${booking['event']['startDate'].toString().substring(0,10)}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Booked: ${booking['createdAt'].toString().substring(0,16)}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => deleteBooking(booking['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              label: const Text(
                "Remove",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

}
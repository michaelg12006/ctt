import 'package:ctt/pages/admin/admin_service.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {

  final AdminService adminService = AdminService();

  List<dynamic> users = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {

    try {

      users = await adminService.getUsers();

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString())
        )
      );

    }

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Users (${users.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'All registered accounts',
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
            itemCount: users.length,
            itemBuilder: (context, index) {

              final user = users[index];

              return _buildUserCard(user);

            },
          ),
        ),

      ],
    );
  }

  Widget _buildUserCard(dynamic user) {

    bool isAdmin = user['role'] == "ADMIN";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x80F4A261),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFCC80),
              ),
            ),
            child: Icon(
              isAdmin
                  ? Icons.shield_outlined
                  : Icons.person_outline,
              color: const Color(0xFFE65100),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? const Color(0xFFE65100)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user['role'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isAdmin
                              ? Colors.white
                              : const Color(0xFF1565C0),
                        ),
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  user['email'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Joined ${user['createdAt'].toString().substring(0,10)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () async {

              await adminService.deleteUser(
                user['id']
              );

              await loadUsers();

            },
          )

        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'manage_notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const AdminDashboardScreen({
    Key? key,
    required this.token,
    required this.adminData,
  }) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();

  List<dynamic> _allBookings = [];
  List<dynamic> _filteredBookings = [];
  Map<String, dynamic> _stats = {
    'totalBookings': 0,
    'activeUsers': 0,
    'terminatedUsers': 0,
    'upcomingBookings': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all bookings
      final bookingsResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/admin/bookings'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      // Fetch user stats
      final usersResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/admin/users'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (bookingsResponse.statusCode == 200 && usersResponse.statusCode == 200) {
        final bookingsData = json.decode(bookingsResponse.body);
        final usersData = json.decode(usersResponse.body);

        setState(() {
          _allBookings = bookingsData['bookings'] ?? [];
          _filteredBookings = _allBookings;

          // Calculate stats
          _stats['totalBookings'] = _allBookings.length;
          _stats['activeUsers'] = (usersData['users'] as List)
              .where((u) => u['accountStatus'] == 'active')
              .length;
          _stats['terminatedUsers'] = (usersData['users'] as List)
              .where((u) => u['accountStatus'] == 'terminated')
              .length;
          _stats['upcomingBookings'] = _allBookings
              .where((b) => b['status'] == 'upcoming')
              .length;
        });
      }
    } catch (e) {
      _showError('Failed to load dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchBookings(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBookings = _allBookings;
      } else {
        _filteredBookings = _allBookings.where((booking) {
          final userName = booking['userId']?['name']?.toLowerCase() ?? '';
          final userEmail = booking['userId']?['email']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return userName.contains(searchLower) || userEmail.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _terminateUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e2538),
        title: Text(
          'Terminate User',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to terminate $userName? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Terminate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/v1/admin/users/$userId/terminate'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reason': 'Terminated by admin'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User terminated successfully'),
            backgroundColor: Colors.red,
          ),
        );
        _loadDashboardData(); // Reload data
      } else {
        throw Exception('Failed to terminate user');
      }
    } catch (e) {
      _showError('Failed to terminate user: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final adminName = widget.adminData['name'] ?? 'Admin';
    final adminRole = widget.adminData['role'] == 'main_admin'
        ? 'Super Admin'
        : 'Sub-Admin';

    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1a1f35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00d9ff),
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: Color(0xFF0a0e1a),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$adminRole Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Full Access - User & Booking Management',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Manage Notifications Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageNotificationsScreen(
                            token: widget.token,
                            adminData: widget.adminData,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.notifications, size: 18),
                    label: Text('Manage Notifications'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00ff88),
                      foregroundColor: Color(0xFF0a0e1a),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Logout Button
                  TextButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout, color: Colors.white70, size: 18),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00d9ff),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistics Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Bookings',
                                  _stats['totalBookings'].toString(),
                                  Icons.track_changes,
                                  Color(0xFF00d9ff),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Active Users',
                                  _stats['activeUsers'].toString(),
                                  Icons.people,
                                  Color(0xFF00ff88),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Terminated Users',
                                  _stats['terminatedUsers'].toString(),
                                  Icons.person_off,
                                  Colors.red,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Upcoming',
                                  _stats['upcomingBookings'].toString(),
                                  Icons.calendar_today,
                                  Color(0xFF00d9ff),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          // Search Bar
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFF1e2538),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.white),
                              onChanged: _searchBookings,
                              decoration: InputDecoration(
                                hintText: 'Search by user email or name...',
                                hintStyle: TextStyle(color: Colors.white38),
                                prefixIcon: Icon(Icons.search, color: Colors.white54),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Section Title
                          Text(
                            'All User Bookings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Bookings List
                          if (_filteredBookings.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                  'No bookings found',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._filteredBookings.map((booking) => _buildBookingCard(booking)).toList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1e2538),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final user = booking['userId'] ?? {};
    final userName = user['name'] ?? 'Unknown';
    final userEmail = user['email'] ?? '';
    final userId = user['_id'] ?? '';

    final status = booking['status'] ?? 'unknown';
    final date = booking['date'] ?? '';
    final startTime = booking['startTime'] ?? '';
    final endTime = booking['endTime'] ?? '';
    final duration = booking['duration'] ?? 0;
    final lane = booking['lane'] ?? 0;
    final weapon = booking['weapon'] ?? '';
    final coach = booking['coach'] ?? '';
    final bookedAt = booking['createdAt'] ?? '';

    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Color(0xFF00ff88);
        statusText = 'COMPLETED';
        break;
      case 'upcoming':
        statusColor = Color(0xFF00d9ff);
        statusText = 'UPCOMING';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'CANCELLED';
        break;
      default:
        statusColor = Colors.orange;
        statusText = status.toUpperCase();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1e2538),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.email_outlined, color: Color(0xFF00ff88), size: 16),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Booking Details
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildDetailItem(Icons.calendar_today, date, Color(0xFF00ff88)),
              _buildDetailItem(Icons.access_time, '$startTime - $endTime', Color(0xFF00d9ff)),
              _buildDetailItem(Icons.timer, '${duration.toInt()}m', Color(0xFF00ff88)),
              _buildDetailItem(Icons.gps_fixed, 'Lane $lane', Color(0xFF00d9ff)),
            ],
          ),
          SizedBox(height: 12),

          // Weapon and Coach
          Row(
            children: [
              Icon(Icons.sports_martial_arts, color: Color(0xFF00d9ff), size: 16),
              SizedBox(width: 8),
              Text(
                weapon,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(width: 24),
              Text(
                'Coach: $coach',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Booked timestamp and Terminate button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booked: ${_formatDate(bookedAt)}',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: () => _terminateUser(userId, userName),
                icon: Icon(Icons.person_off, color: Colors.red, size: 16),
                label: Text(
                  'Terminate User',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'pm' : 'am'}';
    } catch (e) {
      return dateStr;
    }
  }
}

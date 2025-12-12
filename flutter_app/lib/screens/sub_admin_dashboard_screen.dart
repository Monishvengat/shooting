import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'manage_notifications_screen.dart';
import 'manage_resources_screen.dart';

class SubAdminDashboardScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const SubAdminDashboardScreen({
    Key? key,
    required this.token,
    required this.adminData,
  }) : super(key: key);

  @override
  _SubAdminDashboardScreenState createState() => _SubAdminDashboardScreenState();
}

class _SubAdminDashboardScreenState extends State<SubAdminDashboardScreen> {
  List<dynamic> _bookings = [];
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  int _totalBookings = 0;
  int _totalUsers = 0;
  int _upcomingBookings = 0;
  int _notifications = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingsResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/admin/bookings'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      final usersResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/admin/users'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (bookingsResponse.statusCode == 200) {
        final bookingsData = json.decode(bookingsResponse.body);
        setState(() {
          _bookings = bookingsData['bookings'] ?? [];
          _totalBookings = _bookings.length;
          _upcomingBookings = _bookings.where((b) => b['status'] == 'upcoming').length;
        });
      }

      if (usersResponse.statusCode == 200) {
        final usersData = json.decode(usersResponse.body);
        setState(() {
          _users = usersData['users'] ?? [];
          _totalUsers = _users.length;
        });
      }
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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

  List<dynamic> get _filteredBookings {
    if (_searchQuery.isEmpty) return _bookings;
    return _bookings.where((booking) {
      final userName = booking['userName']?.toString().toLowerCase() ?? '';
      final userEmail = booking['userEmail']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return userName.contains(query) || userEmail.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
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
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sub-Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View Bookings & Manage Notifications',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageResourcesScreen(
                    token: widget.token,
                    adminData: widget.adminData,
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings, size: 18),
            label: Text('Manage Resources'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00d9ff),
              foregroundColor: Color(0xFF0a0e1a),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: 12),
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
            label: Text('Notifications'),
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
          TextButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.white70, size: 18),
            label: Text(
              'Logout',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading
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
                          _totalBookings.toString(),
                          Icons.gps_fixed,
                          Color(0xFF00d9ff),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Users',
                          _totalUsers.toString(),
                          Icons.people,
                          Color(0xFF00ff88),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Upcoming',
                          _upcomingBookings.toString(),
                          Icons.calendar_today,
                          Color(0xFF00d9ff),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Notifications',
                          _notifications.toString(),
                          Icons.notifications,
                          Color(0xFFffa000),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // View Bookings Section Header
                  Container(
                    padding: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF00ff88),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: Color(0xFF00ff88),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'View Bookings',
                          style: TextStyle(
                            color: Color(0xFF00ff88),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by user email or name...',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.search, color: Colors.white38),
                      filled: true,
                      fillColor: Color(0xFF1e2538),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Read-Only Warning Banner
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2a2416),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFffa000),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Color(0xFFffa000),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Read-Only Access: You can view bookings but cannot modify them',
                            style: TextStyle(
                              color: Color(0xFFffa000),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Bookings List
                  if (_filteredBookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No bookings found'
                                  : 'No bookings match your search',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...(_filteredBookings.map((booking) => _buildBookingCard(booking)).toList()),
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
        border: Border.all(color: Colors.white10, width: 1),
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
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final userName = booking['userName'] ?? 'Unknown User';
    final userEmail = booking['userEmail'] ?? '';
    final date = booking['date'] ?? '';
    final startTime = booking['startTime'] ?? '';
    final endTime = booking['endTime'] ?? '';
    final duration = booking['duration'] ?? 0;
    final lane = booking['lane'] ?? 'N/A';
    final weapon = booking['weapon'] ?? 'N/A';
    final coach = booking['coach'] ?? 'N/A';
    final status = booking['status']?.toString().toUpperCase() ?? 'UNKNOWN';

    Color statusColor;
    Color statusBgColor;
    switch (status) {
      case 'COMPLETED':
        statusColor = Color(0xFF00ff88);
        statusBgColor = Color(0xFF1a4d3d);
        break;
      case 'UPCOMING':
        statusColor = Color(0xFF00d9ff);
        statusBgColor = Color(0xFF1a3d4d);
        break;
      case 'CANCELLED':
        statusColor = Color(0xFFff4444);
        statusBgColor = Color(0xFF4d1a1a);
        break;
      default:
        statusColor = Colors.white70;
        statusBgColor = Color(0xFF2a3142);
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
          Row(
            children: [
              Icon(Icons.email, color: Color(0xFF00d9ff), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    children: [
                      TextSpan(
                        text: userName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' ($userEmail)',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.calendar_today,
                  _formatDate(date),
                  Color(0xFF00ff88),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  Icons.access_time,
                  '$startTime - $endTime',
                  Color(0xFF00ff88),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.timer,
                  '${duration}m',
                  Color(0xFF00d9ff),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  Icons.track_changes,
                  'Lane $lane',
                  Color(0xFF00ff88),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Weapon: $weapon • Coach: $coach',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

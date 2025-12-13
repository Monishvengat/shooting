import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

class MemberNotificationsScreen extends StatefulWidget {
  final String token;

  const MemberNotificationsScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  _MemberNotificationsScreenState createState() =>
      _MemberNotificationsScreenState();
}

class _MemberNotificationsScreenState extends State<MemberNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/v1/members/notifications'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications =
              List<Map<String, dynamic>>.from(data['notifications']);
          _unreadCount = data['unreadCount'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load notifications');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/v1/members/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _fetchNotifications(); // Refresh notifications
      }
    } catch (e) {
      _showError('Error marking as read: $e');
    }
  }

  void _downloadFile(String filePath, String fileName) {
    try {
      final url = 'http://localhost:3000$filePath';
      // Open file in new tab for web
      html.window.open(url, '_blank');
    } catch (e) {
      _showError('Error downloading file: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFff6b00)),
            SizedBox(width: 12),
            Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFFff6b00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFff0844),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_unreadCount unread',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFff6b00),
              ),
            )
          : _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      color: Color(0xFFff6b00),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] ?? false;
    final priority = notification['priority'] ?? 'normal';
    final type = notification['type'] ?? 'info';
    final attachments =
        notification['attachments'] as List<dynamic>? ?? [];

    Color priorityColor;
    IconData typeIcon;

    switch (priority) {
      case 'urgent':
        priorityColor = Color(0xFFff0844);
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Color(0xFFff6b00);
    }

    switch (type) {
      case 'alert':
        typeIcon = Icons.warning;
        break;
      case 'announcement':
        typeIcon = Icons.campaign;
        break;
      case 'maintenance':
        typeIcon = Icons.build;
        break;
      default:
        typeIcon = Icons.info;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _markAsRead(notification['_id']);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Color(0xFF1a1f35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? Colors.white12
                : priorityColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.white.withOpacity(0.05)
                    : priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(typeIcon, color: priorityColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification['title'] ?? 'Notification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isRead)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFff0844),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Message
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                notification['message'] ?? '',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),

            // Attachments
            if (attachments.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Color(0xFFff6b00),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Attachments (${attachments.length}):',
                          style: TextStyle(
                            color: Color(0xFFff6b00),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ...attachments.map((attachment) {
                      return _buildAttachmentItem(attachment);
                    }).toList(),
                  ],
                ),
              ),

            // Footer
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white12, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white54,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(notification['createdAt']),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: priorityColor, width: 1),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final fileName = attachment['originalName'] ?? 'File';
    final fileSize = _formatFileSize(attachment['size'] ?? 0);
    final filePath = attachment['path'] ?? '';

    IconData fileIcon;
    Color iconColor;

    if (fileName.endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      fileIcon = Icons.description;
      iconColor = Colors.blue;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      fileIcon = Icons.table_chart;
      iconColor = Colors.green;
    } else if (fileName.endsWith('.txt')) {
      fileIcon = Icons.text_snippet;
      iconColor = Colors.grey;
    } else if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif')) {
      fileIcon = Icons.image;
      iconColor = Colors.purple;
    } else {
      fileIcon = Icons.attach_file;
      iconColor = Color(0xFFff6b00);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFF0a0e1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _downloadFile(filePath, fileName),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(fileIcon, color: iconColor, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        fileSize,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.download, color: Color(0xFFff6b00), size: 20),
                SizedBox(width: 4),
                Text(
                  'Download',
                  style: TextStyle(
                    color: Color(0xFFff6b00),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr.toString();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

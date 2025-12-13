import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;

class ManageNotificationsScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const ManageNotificationsScreen({
    Key? key,
    required this.token,
    required this.adminData,
  }) : super(key: key);

  @override
  _ManageNotificationsScreenState createState() => _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/v1/admin/notifications'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _notifications = data['notifications'] ?? [];
        });
      }
    } catch (e) {
      _showError('Failed to load notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => _UploadNotificationDialog(
        token: widget.token,
        onSuccess: () {
          _loadNotifications();
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final adminRole = widget.adminData['role'] == 'main_admin'
        ? 'Super Admin'
        : 'Sub-Admin';

    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              adminRole,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: Icon(Icons.add, size: 18),
              label: Text('Upload Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00ff88),
                foregroundColor: Color(0xFF0a0e1a),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00d9ff),
              ),
            )
          : _notifications.isEmpty
              ? Center(
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
                        'No notifications yet',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showUploadDialog,
                        icon: Icon(Icons.add),
                        label: Text('Create First Notification'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00ff88),
                          foregroundColor: Color(0xFF0a0e1a),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index]);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Untitled';
    final message = notification['message'] ?? '';
    final hasFile = notification['fileUrl'] != null;
    final createdAt = notification['createdAt'] ?? '';

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
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF00d9ff).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications,
                  color: Color(0xFF00d9ff),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (createdAt.isNotEmpty)
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasFile)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF00ff88).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Color(0xFF00ff88), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, color: Color(0xFF00ff88), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Attached',
                        style: TextStyle(
                          color: Color(0xFF00ff88),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditDialog(notification),
                icon: Icon(Icons.edit, size: 16, color: Color(0xFF00d9ff)),
                label: Text(
                  'Edit',
                  style: TextStyle(color: Color(0xFF00d9ff)),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteNotification(notification['_id'], title),
                icon: Icon(Icons.delete, size: 16, color: Colors.red),
                label: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
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

  void _showEditDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => _EditNotificationDialog(
        token: widget.token,
        notification: notification,
        onSuccess: () {
          _loadNotifications();
        },
      ),
    );
  }

  Future<void> _deleteNotification(String? notificationId, String title) async {
    if (notificationId == null) {
      _showError('Invalid notification ID');
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e2538),
        title: Text(
          'Delete Notification',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$title"?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/v1/admin/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted successfully!'),
            backgroundColor: Color(0xFF00ff88),
          ),
        );
        _loadNotifications();
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      _showError('Failed to delete notification: $e');
    }
  }
}

class _UploadNotificationDialog extends StatefulWidget {
  final String token;
  final VoidCallback onSuccess;

  const _UploadNotificationDialog({
    Key? key,
    required this.token,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _UploadNotificationDialogState createState() => _UploadNotificationDialogState();
}

class _UploadNotificationDialogState extends State<_UploadNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String? _fileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _pickFile() {
    try {
      // Create a file input element for web
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.pdf,.doc,.docx,.xls,.xlsx,.txt';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();

          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            final bytes = reader.result as List<int>?;
            setState(() {
              _selectedFile = PlatformFile(
                name: file.name,
                size: file.size,
                bytes: bytes != null ? Uint8List.fromList(bytes) : null,
              );
              _fileName = file.name;
            });
          });
        }
      });
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _uploadNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/v1/admin/notifications'),
      );

      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.fields['title'] = _titleController.text;
      request.fields['message'] = _messageController.text;
      // Model defaults: targetAudience='all', type='info', priority='normal'

      if (_selectedFile != null && _selectedFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachments',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Notification sent to all members successfully!'),
            backgroundColor: Color(0xFF00ff88),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Failed to upload notification');
      }
    } catch (e) {
      _showError('Failed to upload notification: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF1e2538),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Notification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Info banner
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF00ff88).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF00ff88).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF00ff88), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This notification will be sent to all members',
                        style: TextStyle(
                          color: Color(0xFF00ff88),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Notification Title
              Text(
                'Notification Title *',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter notification title...',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF2a3142),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter notification title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Message
              Text(
                'Message (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter notification message...',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF2a3142),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // File Upload
              Text(
                'Attach File (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xFF2a3142),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: Colors.white54,
                        size: 40,
                      ),
                      SizedBox(height: 12),
                      Text(
                        _fileName ?? 'Click to upload file',
                        style: TextStyle(
                          color: _fileName != null ? Color(0xFF00ff88) : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PDF, Word, Excel, Text files',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00ff88),
                      foregroundColor: Color(0xFF0a0e1a),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isUploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0a0e1a)),
                            ),
                          )
                        : Text(
                            'Upload',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditNotificationDialog extends StatefulWidget {
  final String token;
  final Map<String, dynamic> notification;
  final VoidCallback onSuccess;

  const _EditNotificationDialog({
    Key? key,
    required this.token,
    required this.notification,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _EditNotificationDialogState createState() => _EditNotificationDialogState();
}

class _EditNotificationDialogState extends State<_EditNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;

  String? _fileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _hasExistingFile = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notification['title'] ?? '');
    _messageController = TextEditingController(text: widget.notification['message'] ?? '');
    _hasExistingFile = widget.notification['fileUrl'] != null;
    if (_hasExistingFile) {
      final fileUrl = widget.notification['fileUrl'] as String?;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        _fileName = fileUrl.split('/').last;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _pickFile() {
    try {
      // Create a file input element for web
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.pdf,.doc,.docx,.xls,.xlsx,.txt';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();

          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            final bytes = reader.result as List<int>?;
            setState(() {
              _selectedFile = PlatformFile(
                name: file.name,
                size: file.size,
                bytes: bytes != null ? Uint8List.fromList(bytes) : null,
              );
              _fileName = file.name;
            });
          });
        }
      });
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _updateNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://localhost:3000/v1/admin/notifications/${widget.notification['_id']}'),
      );

      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.fields['title'] = _titleController.text;
      request.fields['message'] = _messageController.text;

      // Ensure targetAudience is set to 'all' for member visibility
      request.fields['targetAudience'] = 'all';
      request.fields['type'] = 'announcement';

      if (_selectedFile != null && _selectedFile!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachments',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Notification updated and sent to all members!'),
            backgroundColor: Color(0xFF00ff88),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Failed to update notification');
      }
    } catch (e) {
      _showError('Failed to update notification: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF1e2538),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Notification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Notification Title
              Text(
                'Notification Title *',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter notification title...',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF2a3142),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter notification title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Message
              Text(
                'Message (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter notification message...',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF2a3142),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // File Upload
              Text(
                'Attach File (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xFF2a3142),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: Colors.white54,
                        size: 40,
                      ),
                      SizedBox(height: 12),
                      Text(
                        _fileName ?? (_hasExistingFile ? 'Current file attached' : 'Click to upload file'),
                        style: TextStyle(
                          color: _fileName != null || _hasExistingFile ? Color(0xFF00ff88) : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _hasExistingFile && _selectedFile == null
                            ? 'Click to replace file'
                            : 'PDF, Word, Excel, Text files',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _updateNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00d9ff),
                      foregroundColor: Color(0xFF0a0e1a),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isUploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0a0e1a)),
                            ),
                          )
                        : Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

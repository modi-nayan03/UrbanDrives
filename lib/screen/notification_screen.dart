import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationCard(
              'Your booking for Toyota Camry has been confirmed',
              DateTime.now().subtract(const Duration(minutes: 5))),
          _buildNotificationCard('Payment successfull for ₹ 500.',
              DateTime.now().subtract(const Duration(hours: 1))),
          _buildNotificationCard(
              'Your booking has been updated, Please check the details',
              DateTime.now().subtract(const Duration(hours: 3, minutes: 45))),
          _buildNotificationCard('New offers are available, check now!',
              DateTime.now().subtract(const Duration(days: 2, hours: 2))),
          _buildNotificationCard('We have added some new cars in our list!',
              DateTime.now().subtract(const Duration(days: 10))),
          _buildNotificationCard('Welcome to our app!',
              DateTime.now().subtract(const Duration(days: 20))),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String message, DateTime time) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.grey,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(_formatTimestamp(time),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(time);
    }
  }
}

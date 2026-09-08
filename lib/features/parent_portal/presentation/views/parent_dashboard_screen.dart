import 'package:flutter/material.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Ward Badge
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF4F46E5),
                      child: Text(
                        'LS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Liam Scott • Roll No. 14',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1B4B),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Class 10-A • Class Teacher: Sarah Jenkins',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text(
                            'Present Today',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Overview Indicators
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Attendance',
                    value: '96.2%',
                    caption: 'Present 46/48 Days',
                    color: const Color(0xFF16A34A),
                    icon: Icons.calendar_month,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Fee Dues',
                    value: '\$0.00',
                    caption: 'Term 1 Fully Settled',
                    color: const Color(0xFF4F46E5),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Homework',
                    value: '2 Due Today',
                    caption: 'Math & Physics',
                    color: const Color(0xFFD97706),
                    icon: Icons.assignment_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Exam Grade',
                    value: 'A (88.4%)',
                    caption: 'Mid-Term Exam',
                    color: const Color(0xFF7C3AED),
                    icon: Icons.stars_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Services List
            const Text(
              'Parent Services & Records',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 12),

            _buildServiceItem(
              title: 'Attendance Calendar & Leave Application',
              description: 'Color-coded monthly register. Submit medical/planned leaves with doctor note upload.',
              icon: Icons.date_range,
              iconColor: const Color(0xFF16A34A),
              onTap: () {},
            ),
            _buildServiceItem(
              title: 'Fee Ledger & UPI Payment',
              description: 'Instant dues clearance via UPI (GPay/PhonePe) or Cards. Download tax receipts (PDF).',
              icon: Icons.payment,
              iconColor: const Color(0xFF4F46E5),
              onTap: () {},
            ),
            _buildServiceItem(
              title: 'Structured Homework & Document Viewer',
              description: 'Tasks due today, upcoming deadlines, and in-app worksheets viewer.',
              icon: Icons.menu_book,
              iconColor: const Color(0xFFD97706),
              onTap: () {},
            ),
            _buildServiceItem(
              title: 'Examination Archive & Signed Report Cards',
              description: 'Subject-by-subject theory/practical scores and official school-stamped PDF downloads.',
              icon: Icons.picture_as_pdf,
              iconColor: const Color(0xFFDC2626),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String caption,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }
}

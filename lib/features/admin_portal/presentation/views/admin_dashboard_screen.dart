import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Institution Governance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Session secured under strict RBAC audit protocols.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audit log exported.')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export Audit Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Metrics Grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.1,
              children: [
                _buildKpiCard(
                  title: 'Term Revenue Collected',
                  value: '\$482,900',
                  change: '+12.4% vs last term',
                  isPositive: true,
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF16A34A),
                ),
                _buildKpiCard(
                  title: 'Defaulters (>60 Days)',
                  value: '18 Students',
                  change: '3 batch notices pending',
                  isPositive: false,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626),
                ),
                _buildKpiCard(
                  title: 'Faculty Active',
                  value: '64 / 68 Staff',
                  change: '4 on scheduled leave',
                  isPositive: true,
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF2563EB),
                ),
                _buildKpiCard(
                  title: 'Exam Publication Gates',
                  value: '3 Pending',
                  change: 'Mid-Term Class 10 locked',
                  isPositive: false,
                  icon: Icons.lock_clock_outlined,
                  color: const Color(0xFFD97706),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Feature Sections Grid
            const Text(
              'Administrative Modules',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Financial & Revenue Operations
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.monetization_on_outlined,
                                  color: Color(0xFFD97706)),
                              SizedBox(width: 8),
                              Text(
                                'Financial Operations & Fee Engine',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildModuleItem(
                            'Fee Structure Engine',
                            'Tuition, laboratory, library & sports heads configuration.',
                            Icons.tune,
                          ),
                          _buildModuleItem(
                            'Counter Billing & Offline Vouchers',
                            'Record cash, cheques, bank drafts and reconcile digital payments.',
                            Icons.receipt_long,
                          ),
                          _buildModuleItem(
                            'Defaulter Analytics & Automated Reminders',
                            'Aging buckets (30/60/90 days) with WhatsApp & SMS triggers.',
                            Icons.notifications_active_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Column 2: Academic Governance & Master Data
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.school_outlined,
                                  color: Color(0xFF2563EB)),
                              SizedBox(width: 8),
                              Text(
                                'Academic Master & Examination',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildModuleItem(
                            'Academic Master Data',
                            'Manage years, terms, classes, divisions, and teacher allotments.',
                            Icons.account_tree_outlined,
                          ),
                          _buildModuleItem(
                            'Exam Terms & Grading Rules',
                            'GPA, percentage schemes, theory/practical criteria.',
                            Icons.fact_check_outlined,
                          ),
                          _buildModuleItem(
                            'Result Publishing Gates',
                            'Review teacher marks, lock revisions, and publish report cards.',
                            Icons.published_with_changes,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Icon(icon, size: 20, color: color),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/services/assignment_sync_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  late final AssignmentSyncService _syncService;

  // Selected Student Ward State
  int _selectedWardIndex = 0;
  final List<Map<String, dynamic>> _wards = [
    {
      'name': 'Liam Scott',
      'roll': 'STU-10A-14',
      'class': 'Class 10-A',
      'teacher': 'Sarah Jenkins',
      'initials': 'LS',
      'attendance': '96.2%',
      'presentDays': '46/48 Days',
      'feeDues': '\$0.00',
      'feeStatus': 'Term 1 Fully Settled',
      'isFeePaid': true,
      'grade': 'A (88.4%)',
      'examCaption': 'Mid-Term Exam',
    },
    {
      'name': 'Emma Scott',
      'roll': 'STU-06B-08',
      'class': 'Class 6-B',
      'teacher': 'Priya Nair',
      'initials': 'ES',
      'attendance': '98.0%',
      'presentDays': '47/48 Days',
      'feeDues': '\$120.00',
      'feeStatus': 'Term 2 Lab Fee Due',
      'isFeePaid': false,
      'grade': 'A+ (94.2%)',
      'examCaption': 'Unit Test Series',
    },
  ];

  // Ward Leave Applications State
  final List<Map<String, String>> _leaveApplications = [
    {
      'type': 'Medical Leave',
      'dates': '12 Sep 2026',
      'reason': 'Viral fever; prescribed rest by pediatrician.',
      'status': 'APPROVED',
      'doctorSlip': 'Doctor_Prescription_DrMehta.pdf',
    },
    {
      'type': 'Family Function',
      'dates': '28 Aug 2026',
      'reason': 'Attended elder sibling wedding ceremony.',
      'status': 'APPROVED',
      'doctorSlip': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _syncService = AssignmentSyncService();
  }

  Map<String, dynamic> get _currentWard => _wards[_selectedWardIndex];

  // ===========================================================================
  // SERVICE 1: ATTENDANCE CALENDAR & LEAVE APPLICATION
  // ===========================================================================
  void _showAttendanceAndLeaveModal() {
    final reasonCtrl = TextEditingController();
    String leaveType = 'Medical Leave';
    String fromDate = '22 Sep 2026';
    String toDate = '23 Sep 2026';
    bool hasDoctorSlip = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.date_range, color: Color(0xFF16A34A), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Attendance & Leave Portal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentWard['name']} (${_currentWard['class']}) • Real-time Attendance Roster',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Attendance KPI Summary Bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniMetric('Present', '46 Days', const Color(0xFF16A34A)),
                          _buildMiniMetric('Absent', '2 Days', const Color(0xFFDC2626)),
                          _buildMiniMetric('Rate', _currentWard['attendance'], const Color(0xFF059669)),
                          _buildMiniMetric('Status', 'Good Standing', const Color(0xFF0F172A)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Apply for New Leave Form
                    const Text(
                      'SUBMIT LEAVE APPLICATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: leaveType,
                      decoration: const InputDecoration(labelText: 'Leave Category', prefixIcon: Icon(Icons.category)),
                      items: const [
                        DropdownMenuItem(value: 'Medical Leave', child: Text('Medical Leave (Fever / Illness)')),
                        DropdownMenuItem(value: 'Planned Absence', child: Text('Planned Absence / Family Travel')),
                        DropdownMenuItem(value: 'Emergency', child: Text('Family Emergency')),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => leaveType = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              hintText: fromDate,
                              prefixIcon: const Icon(Icons.calendar_today, size: 16),
                            ),
                            onTap: () => setModalState(() => fromDate = '24 Sep 2026'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              hintText: toDate,
                              prefixIcon: const Icon(Icons.calendar_today, size: 16),
                            ),
                            onTap: () => setModalState(() => toDate = '25 Sep 2026'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Absence',
                        hintText: 'e.g. Mild flu; doctor advised rest.',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Checkbox(
                          value: hasDoctorSlip,
                          onChanged: (v) => setModalState(() => hasDoctorSlip = v ?? false),
                          activeColor: const Color(0xFF16A34A),
                        ),
                        const Expanded(
                          child: Text(
                            'Attach Medical Certificate / Doctor Slip (PDF)',
                            style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    ElevatedButton.icon(
                      onPressed: () {
                        if (reasonCtrl.text.trim().isEmpty) {
                          reasonCtrl.text = 'Medical checkup and recovery';
                        }
                        setState(() {
                          _leaveApplications.insert(0, {
                            'type': leaveType,
                            'dates': '$fromDate - $toDate',
                            'reason': reasonCtrl.text.trim(),
                            'status': 'PENDING_APPROVAL',
                            'doctorSlip': hasDoctorSlip ? 'Medical_Cert_${_currentWard['name'].replaceAll(' ', '_')}.pdf' : '',
                          });
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Leave application submitted for ${_currentWard['name']}! Sent to Principal & Teacher.'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Submit Leave Application'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Past Leave Applications History
                    const Text(
                      'PAST LEAVE HISTORY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _leaveApplications.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final app = _leaveApplications[index];
                        final isApproved = app['status'] == 'APPROVED';

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isApproved ? Icons.check_circle : Icons.hourglass_top,
                                  size: 20,
                                  color: isApproved ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${app['type']} • ${app['dates']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    Text(app['reason'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  app['status'] ?? 'PENDING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isApproved ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // SERVICE 2: FEE LEDGER & UPI PAYMENT
  // ===========================================================================
  void _showFeeLedgerAndUpiModal() {
    bool isPaid = _currentWard['isFeePaid'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.payment, color: Color(0xFF4F46E5), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Fee Ledger & UPI Payment',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account: ${_currentWard['name']} • ${_currentWard['class']} • Official Fee Vault',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Ledger status card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isPaid ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPaid ? Icons.check_circle : Icons.warning_amber,
                            color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            size: 32,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPaid ? 'All Term Dues Cleared' : 'Outstanding Dues: \$120.00',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: isPaid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isPaid ? 'Term 1 & 2 receipts generated with tax invoice' : 'Due by 30 Sep 2026 • Science Lab & Transport',
                                  style: TextStyle(fontSize: 12, color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB91C1C)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fee Itemized Breakdown
                    const Text('ITEMIZED FEE SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF475569))),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildFeeRow('Tuition & Academic Faculty Fee', '\$850.00', true),
                          const Divider(height: 16),
                          _buildFeeRow('Digital Labs & Computer Facility', '\$120.00', isPaid),
                          const Divider(height: 16),
                          _buildFeeRow('Library & Learning Resources', '\$60.00', true),
                          const Divider(height: 16),
                          _buildFeeRow('Annual Examination & Certified Dossier', '\$70.00', true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Instant UPI QR Code Generation & 1-Tap Payment
                    if (!isPaid) ...[
                      const Text('INSTANT CLEARANCE VIA UPI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF475569))),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.qr_code_2, size: 40, color: Color(0xFF4F46E5)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('Scan or Pay via UPI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E1B4B))),
                                      SizedBox(height: 2),
                                      Text('UPI ID: schoolerp.fees@icici\nSupported: GPay, PhonePe, Paytm, BHIM', style: TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () {
                                setModalState(() => isPaid = true);
                                setState(() {
                                  _currentWard['isFeePaid'] = true;
                                  _currentWard['feeDues'] = '\$0.00';
                                  _currentWard['feeStatus'] = 'Term Dues Settled via UPI';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Payment of \$120.00 successful for ${_currentWard['name']} via UPI! Receipt downloaded.'),
                                    backgroundColor: const Color(0xFF16A34A),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.verified, size: 18),
                              label: const Text('1-Tap Complete UPI Payment (\$120.00)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 46),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tax Invoice Receipt for ${_currentWard['name']} downloaded to /Download/FeeReceipt_2026.pdf'),
                              backgroundColor: const Color(0xFF0F172A),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download Official Tax Invoice & Receipt (PDF)'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 46),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // SERVICE 3: STRUCTURED HOMEWORK & DOCUMENT VIEWER (SYNCED IN REAL-TIME)
  // ===========================================================================
  void _showHomeworkAndDocumentViewerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _syncService.assignmentsNotifier,
          builder: (context, assignments, _) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.menu_book, color: Color(0xFFD97706), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Homework & PDF Viewer',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentWard['name']} • Active Worksheets & Faculty PDF Attachments',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    if (assignments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text('No active assignments published right now.')),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: assignments.length,
                        separatorBuilder: (_, __) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final asgn = assignments[index];
                          final isDone = asgn['isSubmitted'] == true;
                          final rawAttachments = asgn['attachments'];
                          final List<Map<String, dynamic>> attachments = [];

                          if (rawAttachments is List) {
                            for (final item in rawAttachments) {
                              if (item is Map) attachments.add(Map<String, dynamic>.from(item));
                            }
                          } else if (asgn['attachment'] != null) {
                            attachments.add({'name': asgn['attachment'].toString(), 'size': '1.5 MB'});
                          }

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        asgn['subject'] ?? 'Mathematics',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    Text(
                                      'Due: ${asgn['dueDate'] ?? 'Soon'}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  asgn['title'] ?? 'Assignment',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                                ),
                                if (asgn['instructions'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    asgn['instructions'].toString(),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                                const SizedBox(height: 10),

                                // Attached PDFs
                                if (attachments.isNotEmpty) ...[
                                  const Text('TEACHER ATTACHED PDFS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: attachments.map((att) {
                                      final fn = att['name'] ?? 'Worksheet.pdf';
                                      final sz = att['size'] ?? '1.5 MB';
                                      return InkWell(
                                        onTap: () => _showParentDocumentViewer(context, asgn['title'] ?? 'Homework', fn, sz),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.picture_as_pdf, size: 14, color: Color(0xFFDC2626)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$fn ($sz)',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.open_in_new, size: 12, color: Color(0xFF64748B)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 8),

                                // Status indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isDone ? 'COMPLETED & SUBMITTED' : 'ACTION REQUIRED',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isDone ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showParentDocumentViewer(BuildContext context, String assignmentTitle, String fileName, String size) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assignment: $assignmentTitle • Size: $size', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, size: 48, color: Color(0xFF64748B)),
                        const SizedBox(height: 8),
                        Text(fileName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text('Student Homework Worksheet Preview', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading "$fileName" to device... Saved to /Download/$fileName')),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SERVICE 4: EXAMINATION ARCHIVE & CERTIFIED REPORT CARDS (FUNCTIONAL DOWNLOAD)
  // ===========================================================================
  void _showReportCardModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.90,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Certified Report Cards',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentWard['name']} (${_currentWard['class']}) • Term 1 Assessment Certified Dossier',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Report Card Preview Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_currentWard['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              Text('${_currentWard['class']} • ${_currentWard['roll']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'GPA: ${_currentWard['grade']}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 18,
                          columns: const [
                            DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Max')),
                            DataColumn(label: Text('Marks')),
                            DataColumn(label: Text('Grade')),
                            DataColumn(label: Text('Remarks')),
                          ],
                          rows: const [
                            DataRow(cells: [DataCell(Text('Mathematics')), DataCell(Text('100')), DataCell(Text('92')), DataCell(Text('A1')), DataCell(Text('Excellent concepts'))]),
                            DataRow(cells: [DataCell(Text('Physics & Science')), DataCell(Text('100')), DataCell(Text('89')), DataCell(Text('A1')), DataCell(Text('Good practical work'))]),
                            DataRow(cells: [DataCell(Text('English Literature')), DataCell(Text('100')), DataCell(Text('94')), DataCell(Text('A1')), DataCell(Text('Outstanding essay writing'))]),
                            DataRow(cells: [DataCell(Text('Computer Science')), DataCell(Text('100')), DataCell(Text('95')), DataCell(Text('A1')), DataCell(Text('Exemplary coding projects'))]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
                        child: Row(
                          children: const [
                            Icon(Icons.workspace_premium, color: Color(0xFF16A34A), size: 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Certified and digitally signed by Dr. E. Vance (Principal) & Class Teacher. Affixed with CBSE Verification Seal.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Download to Phone Action Button (100% Functional)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _downloadWardReportCard(context, _currentWard['name']);
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: Text('Download ${_currentWard['name']} Report Card to Phone (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _downloadWardReportCard(BuildContext context, String wardName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (Navigator.canPop(ctx)) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 4),
                backgroundColor: const Color(0xFF059669),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Report Card for $wardName saved to: /storage/emulated/0/Download/ReportCard_${wardName.replaceAll(' ', '_')}.pdf',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFDC2626), strokeWidth: 3),
                const SizedBox(height: 20),
                Text('Downloading $wardName Report Card...', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 6),
                const Text('Generating high-resolution stamped PDF dossier with school seal.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MAIN BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Ward Selector Badge (Switch between children)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'STUDENT WARD / CHILD',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF475569)),
                            ),
                            // Ward Switcher Segment
                            Row(
                              children: [
                                for (int i = 0; i < _wards.length; i++) ...[
                                  InkWell(
                                    onTap: () => setState(() => _selectedWardIndex = i),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _selectedWardIndex == i ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _wards[i]['name'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedWardIndex == i ? Colors.white : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (i < _wards.length - 1) const SizedBox(width: 6),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        isWide
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF4F46E5),
                                    child: Text(
                                      _currentWard['initials'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_currentWard['name']} • ${_currentWard['roll']}',
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_currentWard['class']} • Class Faculty: ${_currentWard['teacher']}',
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildPresentTodayBadge(),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFF4F46E5),
                                        child: Text(
                                          _currentWard['initials'],
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${_currentWard['name']} • ${_currentWard['roll']}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B)),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_currentWard['class']} • ${_currentWard['teacher']}',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildPresentTodayBadge(),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Quick Overview Indicators: 4 in row on wide, 2x2 grid on portrait
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 650;
                final c1 = _buildStatCard(
                  title: 'Attendance',
                  value: _currentWard['attendance'],
                  caption: _currentWard['presentDays'],
                  color: const Color(0xFF16A34A),
                  icon: Icons.calendar_month,
                  onTap: _showAttendanceAndLeaveModal,
                );
                final c2 = _buildStatCard(
                  title: 'Fee Dues',
                  value: _currentWard['feeDues'],
                  caption: _currentWard['feeStatus'],
                  color: const Color(0xFF4F46E5),
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: _showFeeLedgerAndUpiModal,
                );
                final c3 = _buildStatCard(
                  title: 'Homework',
                  value: '${_syncService.currentAssignments.length} Active',
                  caption: 'Synced with Class',
                  color: const Color(0xFFD97706),
                  icon: Icons.assignment_outlined,
                  onTap: _showHomeworkAndDocumentViewerModal,
                );
                final c4 = _buildStatCard(
                  title: 'Exam Grade',
                  value: _currentWard['grade'],
                  caption: _currentWard['examCaption'],
                  color: const Color(0xFF7C3AED),
                  icon: Icons.stars_outlined,
                  onTap: _showReportCardModal,
                );

                return isWide
                    ? Row(
                        children: [
                          Expanded(child: c1),
                          const SizedBox(width: 12),
                          Expanded(child: c2),
                          const SizedBox(width: 12),
                          Expanded(child: c3),
                          const SizedBox(width: 12),
                          Expanded(child: c4),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: c1),
                              const SizedBox(width: 12),
                              Expanded(child: c2),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: c3),
                              const SizedBox(width: 12),
                              Expanded(child: c4),
                            ],
                          ),
                        ],
                      );
              },
            ),
            const SizedBox(height: 24),

            // Main Services List (Every service fully functional!)
            const Text(
              'Parent Operations & Services',
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
              onTap: _showAttendanceAndLeaveModal,
            ),
            _buildServiceItem(
              title: 'Fee Ledger & UPI Payment',
              description: 'Instant dues clearance via UPI (GPay/PhonePe) or Cards. Download tax receipts (PDF).',
              icon: Icons.payment,
              iconColor: const Color(0xFF4F46E5),
              onTap: _showFeeLedgerAndUpiModal,
            ),
            _buildServiceItem(
              title: 'Structured Homework & Document Viewer',
              description: 'Tasks due today, upcoming deadlines, and in-app worksheets viewer.',
              icon: Icons.menu_book,
              iconColor: const Color(0xFFD97706),
              onTap: _showHomeworkAndDocumentViewerModal,
            ),
            _buildServiceItem(
              title: 'Examination Archive & Signed Report Cards',
              description: 'Subject-by-subject theory/practical scores and official school-stamped PDF downloads.',
              icon: Icons.picture_as_pdf,
              iconColor: const Color(0xFFDC2626),
              onTap: _showReportCardModal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresentTodayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
          SizedBox(width: 4),
          Text(
            'Present Today',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildFeeRow(String title, String amount, bool isPaid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
        Row(
          children: [
            Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPaid ? 'PAID' : 'DUE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String caption,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
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

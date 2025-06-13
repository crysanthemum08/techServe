import 'package:app/pages/admin_inventory_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/work_order_admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkOrder {
  final String id;
  final String assignedTo;
  final String status;
  final String title; // Add title field

  WorkOrder({
    required this.id,
    required this.assignedTo,
    required this.status,
    required this.title, // Initialize title
  });

  factory WorkOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkOrder(
      id: doc.id,
      title: data['title'] ?? '', // Get title from Firestore
      assignedTo: data['assignedTo'] ?? '',
      status: data['status'] ?? '',
    );
  }
}

class AdminModel {
  void initState() {}

  void dispose() {}
}

class AdminWidget extends StatefulWidget {
  const AdminWidget({super.key});

  @override
  State<AdminWidget> createState() => _AdminWidgetState();
}

class _AdminWidgetState extends State<AdminWidget> {
  late AdminModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = AdminModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B39EF), Color(0xFF39D2C0)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0, -1),
                    end: AlignmentDirectional(0, 1),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispatcher Dashboard',
                        style: TextStyle(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage tasks, workers, and inventory',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Today\'s Schedule',
                                      style: TextStyle(
                                        fontFamily: 'Inter Tight',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFF4B39EF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Add Job'),
                                    ),
                                  ],
                                ),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE0E3E7),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12, 12, 12, 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'HVAC Repair',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'John Doe - 123 Main St',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(4, 8, 4, 8),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE3F2FD),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    '9:00 AM',
                                                    style: TextStyle(
                                                      color: Color(0xFF1565C0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE0E3E7),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(12, 12, 12, 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Electrical Inspection',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Jane Smith - 456 Elm St',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(4, 8, 4, 8),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE3F2FD),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    '11:30 AM',
                                                    style: TextStyle(
                                                      color: Color(0xFF1565C0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 12)),
                                ),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigate to work_admin_page.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WorkOrderAdminWidget(), // Update this as per your actual page class
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Work Orders',
                                        style: TextStyle(
                                          fontFamily: 'Inter Tight',
                                          color: Color(
                                              0xFF14181B), // Primary text color
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // StreamBuilder to fetch work orders from Firestore
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('workOrders')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    List<WorkOrder> workOrders = snapshot
                                        .data!.docs
                                        .map((doc) =>
                                            WorkOrder.fromFirestore(doc))
                                        .toList();

                                    return ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              8), // Add padding around the list
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: workOrders.map((workOrder) {
                                        Color statusColor;
                                        Color textColor;
                                        if (workOrder.status == 'In Progress') {
                                          statusColor = const Color(0xFFFFF3E0);
                                          textColor = const Color(0xFFEF6C00);
                                        } else if (workOrder.status ==
                                            'Completed') {
                                          statusColor = const Color(0xFFE8F5E9);
                                          textColor = const Color(0xFF2E7D32);
                                        } else {
                                          statusColor = Colors.grey[200]!;
                                          textColor = Colors.grey[600]!;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  12), // Add space between each item
                                          child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFE0E3E7),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(12, 12, 12, 12),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${workOrder.title}',
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Assigned to: ${workOrder.assignedTo}',
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF57636C),
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Align(
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            1, -1),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                              10, 8, 10, 8),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: statusColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          child: Text(
                                                            workOrder.status,
                                                            style: TextStyle(
                                                              color: textColor,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Align(
                                  alignment: AlignmentDirectional(0, -1),
                                  child: Text(
                                    'Field Workers Status',
                                    style: TextStyle(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFF14181B),
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Active Workers',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '8/10 workers on duty',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(
                                                0xFF57636C), // Use your secondary text color here
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Align(
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            '80%',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Color(0xFF2E7D32),
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Align(
                                      alignment: AlignmentDirectional(0, -1),
                                      child: Text(
                                        'Inventory',
                                        style: TextStyle(
                                          fontFamily: 'Inter Tight',
                                          color: Colors
                                              .black, // Replace with your desired color
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminInventoryWidget()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 0, 0),
                                        backgroundColor: const Color(
                                            0xFF4B39EF), // Replace with your primary color
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        fixedSize: const Size(100, 40),
                                      ),
                                      child: const Text(
                                        'View All',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection(
                                          'inventory') // Firestore collection name
                                      .where('stock',
                                          isLessThan: 5) // Low stock condition
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    final lowStockItems =
                                        snapshot.data?.docs.length ?? 0;

                                    return Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Low Stock Items',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.0,
                                                fontSize:
                                                    16, // Adjust size as necessary
                                              ),
                                            ),
                                            Text(
                                              '$lowStockItems items need reorder',
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                color: Color(
                                                    0xFF57636C), // Replace with your secondary text color
                                                letterSpacing: 0.0,
                                                fontSize:
                                                    14, // Adjust size as necessary
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Icon(
                                          Icons.warning_amber,
                                          color: Color(0xFFFFA000),
                                          size: 24,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Forms & Reports',
                                      style: TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontWeight: FontWeight.w600,
                                        color: Color(
                                            0xFF14181B), // Replace with your primary text color
                                        letterSpacing: 0.0,
                                        fontSize:
                                            24, // Adjust size as necessary
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(100, 40),
                                        backgroundColor:
                                            const Color(0xFF4B39EF),
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 0,
                                            0), // Replace with your primary button color
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        'View All',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE0E3E7),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12, 12, 12, 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Daily Performance Report',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Submitted by: John Doe',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(
                                                        0xFF57636C), // Replace with your secondary text color
                                                    letterSpacing: 0.0,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Color(
                                                  0xFF57636C), // Replace with your secondary text color
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE0E3E7),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12, 12, 12, 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Weekly Inventory Check',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.0,
                                                    fontSize:
                                                        16, // Adjust size as per your requirement
                                                  ),
                                                ),
                                                Text(
                                                  'Submitted by: Jane Smith',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Color(
                                                        0xFF57636C), // Replace with your secondary text color
                                                    letterSpacing: 0.0,
                                                    fontSize:
                                                        12, // Adjust size as per your requirement
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Color(
                                                  0xFF57636C), // Replace with your secondary text color
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 12)),
                                ),
                              ].divide(const SizedBox(height: 16)),
                            ),
                          ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 24)),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.dashboard,
                                color: Color(0xFF4B39EF), // Primary color
                                size: 28,
                              ),
                            ],
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment,
                                color:
                                    Color(0xFF57636C), // Secondary text color
                                size: 28,
                              ),
                            ],
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory,
                                color:
                                    Color(0xFF57636C), // Secondary text color
                                size: 28,
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context,
                                  '/admin_profile'); // Navigate to the admin profile page
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  color:
                                      Color(0xFF57636C), // Secondary text color
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

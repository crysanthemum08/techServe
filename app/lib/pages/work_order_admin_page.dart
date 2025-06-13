import 'package:app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// WorkOrderModel integrated into the same file
class WorkOrderAdminModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getWorkOrders() {
    return _firestore.collection('workOrders').snapshots();
  }

  Future<Map<String, int>> getWorkOrderCounts() async {
    var snapshot = await _firestore.collection('workOrders').get();
    int total = snapshot.docs.length;
    int inProgress = 0;
    int completed = 0;

    for (var doc in snapshot.docs) {
      var data = doc.data();
      if (data['status'] == 'In Progress') {
        inProgress++;
      } else if (data['status'] == 'Completed') {
        completed++;
      }
    }

    return {
      'total': total,
      'inProgress': inProgress,
      'completed': completed,
    };
  }

  Future<List<String>> getAvailableWorkers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('workers').get();
      print('Number of workers fetched: ${snapshot.docs.length}');
      List<String> workers =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      print('Workers: $workers');
      return workers;
    } catch (e) {
      print('Error fetching available workers: $e');
      return [];
    }
  }

  Future<void> addWorkOrder(Map<String, dynamic> newWorkOrder) async {
    await _firestore.collection('workOrders').add(newWorkOrder);
  }

  Future<void> updateWorkOrderStatus(
      String workOrderId, String newStatus) async {
    try {
      await _firestore.collection('workOrders').doc(workOrderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error updating work order status: $e');
    }
  }

  Future<void> assignWorker(String workOrderId, String worker) async {
    try {
      await _firestore.collection('workOrders').doc(workOrderId).update({
        'assignedTo': worker,
      });
    } catch (e) {
      print('Error assigning worker: $e');
    }
  }

  Future<void> deleteWorkOrder(String workOrderId) async {
    try {
      await _firestore.collection('workOrders').doc(workOrderId).delete();
      print("Work order deleted successfully");
    } catch (e) {
      print("Error deleting work order: $e");
      rethrow;
    }
  }
}

// WorkOrderWidget with integrated WorkOrderModel
class WorkOrderAdminWidget extends StatefulWidget {
  const WorkOrderAdminWidget({super.key});

  @override
  State<WorkOrderAdminWidget> createState() => _WorkOrderWidgetState();
}

class _WorkOrderWidgetState extends State<WorkOrderAdminWidget> {
  late WorkOrderAdminModel _model;

  final Map<String, int> _workOrderCounts = {
    'total': 0,
    'inProgress': 0,
    'completed': 0,
  };

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> selectedWorkOrderIds = []; // Track selected work orders

  @override
  void initState() {
    super.initState();
    _model = WorkOrderAdminModel();
  }

  // Updated to include customer details
  void _addNewWorkOrder(
      String title,
      String priority,
      String assignedTo,
      DateTime dueDate,
      String customerName,
      String customerAddress,
      String customerContact) async {
    try {
      await FirebaseFirestore.instance.collection('workOrders').add({
        'title': title,
        'priority': priority,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'customerName': customerName,
        'customerAddress': customerAddress,
        'customerContact': customerContact,
        'status': 'In Progress', // Default status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New work order added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add work order: $e')),
      );
    }
  }

  Future<void> _showAddWorkOrderDialog() async {
    String title = '';
    String priority = 'Medium';
    String assignedTo = ''; // Assigned worker, initially empty
    DateTime dueDate = DateTime.now();

    // New fields for customer details
    String customerName = '';
    String customerAddress = '';
    String customerContact = '';

    // Fetch available workers asynchronously
    List<String> availableWorkers = await _model.getAvailableWorkers();

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Work Order'),
          content: SingleChildScrollView(
            // Use SingleChildScrollView to avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  onChanged: (value) => customerName = value,
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Customer Address'),
                  onChanged: (value) => customerAddress = value,
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Customer Contact'),
                  onChanged: (value) => customerContact = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Due Date'),
                  readOnly: true, // Make it read-only
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(), // Prevent past dates
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        dueDate =
                            pickedDate; // Update the dueDate when selected
                      });
                    }
                  },
                  controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd')
                          .format(dueDate)), // Show the selected date
                ),
                DropdownButton<String>(
                  value: priority,
                  items: <String>['High', 'Medium', 'Low'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) priority = value; // Update priority
                  },
                ),
                DropdownButton<String>(
                  hint: const Text('Assign to Worker'),
                  value: assignedTo.isEmpty
                      ? null
                      : assignedTo, // Show selected worker or null if empty
                  items: availableWorkers.map((String worker) {
                    return DropdownMenuItem<String>(
                      value: worker,
                      child: Text(worker),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      assignedTo = value; // Update assigned worker
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addNewWorkOrder(title, priority, assignedTo, dueDate,
                    customerName, customerAddress, customerContact);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            backgroundColor: const Color(0xFF4B39EF),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back), // Back button icon
              onPressed: () {
                Navigator.of(context).pop(); // Go back to the previous page
              },
            ),
            actions: const [],
            centerTitle: false,
            elevation: 0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey[
                              200], // Replace with your desired background color
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 24, // Adjust font size as needed
                                  color: Colors
                                      .black, // Replace with your primary text color
                                  letterSpacing: 0.0,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _showAddWorkOrderDialog,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                          50),
                                      backgroundColor: const Color(
                                          0xFF4B39EF), // Primary button color
                                      textStyle: const TextStyle(
                                        fontFamily: 'Inter',
                                        color:
                                            Colors.white, // Button text color
                                        letterSpacing: 0.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ).copyWith(
                                      foregroundColor: WidgetStateProperty.all(
                                          Colors.white), // Set text color here
                                    ), // Call the dialog function
                                    child: const Text('New Work Order'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      print('Assign Tasks button pressed ...');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(
                                        MediaQuery.of(context).size.width * 0.4,
                                        50,
                                      ),
                                      backgroundColor: const Color(
                                          0xFF39D2C0), // Primary button color
                                      textStyle: const TextStyle(
                                        fontFamily: 'Inter',
                                        color:
                                            Colors.white, // Button text color
                                        letterSpacing: 0.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ).copyWith(
                                      foregroundColor: WidgetStateProperty.all(
                                          Colors.white), // Set text color here
                                    ),
                                    child: const Text('Assign Tasks'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 16, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Work Orders',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    fontSize: 24,
                                    color: Colors.black,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: _model
                                  .getWorkOrders(), // Fetch work orders from Firestore
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                var workOrders = snapshot.data!.docs;

                                return FutureBuilder<List<String>>(
                                  future: _model
                                      .getAvailableWorkers(), // Fetch available workers asynchronously
                                  builder: (context, workerSnapshot) {
                                    if (!workerSnapshot.hasData) {
                                      return const CircularProgressIndicator();
                                    }

                                    var availableWorkers = workerSnapshot.data!;

                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: workOrders.length,
                                      itemBuilder: (context, index) {
                                        var workOrder = workOrders[index];
                                        var data = workOrder.data()
                                            as Map<String, dynamic>;

                                        DateTime dueDate =
                                            (data['dueDate'] as Timestamp)
                                                .toDate();
                                        String formattedDueDate =
                                            DateFormat.yMMMd().format(dueDate);

                                        // Assuming customer details are part of the data Map
                                        String customerName =
                                            data['customerName'] ?? 'Unknown';
                                        String customerAddress =
                                            data['customerAddress'] ??
                                                'No address provided';
                                        String customerContact =
                                            data['customerContact'] ??
                                                'No contact info';

                                        return WorkOrderCard(
                                          title: data['title'],
                                          priority: data['priority'],
                                          assignedTo: data['assignedTo'] ?? '',
                                          dueDate: formattedDueDate,
                                          status: data['status'],
                                          workOrderId: workOrder.id,
                                          availableWorkers: availableWorkers,
                                          isSelected: selectedWorkOrderIds
                                              .contains(workOrder.id),
                                          onSelected: (isChecked) {
                                            setState(() {
                                              if (isChecked == true) {
                                                selectedWorkOrderIds
                                                    .add(workOrder.id);
                                              } else {
                                                selectedWorkOrderIds
                                                    .remove(workOrder.id);
                                              }
                                            });
                                          },
                                          onPressed: () {
                                            print(
                                                'Update button pressed for ${data['title']}');
                                          },
                                          deleteCallback: () async {
                                            await _model
                                                .deleteWorkOrder(workOrder.id);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Work order deleted successfully!'),
                                              ),
                                            );
                                          },
                                          customerName: customerName,
                                          customerAddress: customerAddress,
                                          customerContact: customerContact,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ].divide(const SizedBox(height: 16)),
                        ),
                      ),
                    ),
                  ),

                  // Work Order Statistics Section
                  Material(
                    color: Colors.transparent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                'Work Order Statistics',
                                style: TextStyle(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 20,
                                  color: Colors.black,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Total
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '15',
                                      style: TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize: 32,
                                        color: Colors.blue,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 8)),
                                ),
                                // In Progress
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Align(
                                      alignment: AlignmentDirectional(0, -1),
                                      child: Text(
                                        '8',
                                        style: TextStyle(
                                          fontFamily: 'Inter Tight',
                                          fontSize: 32,
                                          color: Colors.orange,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      'In Progress',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 8)),
                                ),
                                // Completed
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '5',
                                      style: TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize: 32,
                                        color: Colors.green,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const Text(
                                      'Completed',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 8)),
                                ),
                                // Overdue
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '2',
                                      style: TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize: 32,
                                        color: Colors.red,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const Text(
                                      'Overdue',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.grey,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 8)),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

class WorkOrderCard extends StatefulWidget {
  final String title;
  final String priority;
  final String assignedTo;
  final String dueDate;
  final String status;
  final String workOrderId; // Pass work order ID for updates
  final Function onPressed;
  final List<String> availableWorkers; // List of available workers
  final Function deleteCallback; // Callback for deleting the work order
  final ValueChanged<bool?>? onSelected; // Callback for checkbox
  final bool isSelected; // To track if this work order is selected
  final String customerName;
  final String customerAddress;
  final String customerContact;

  const WorkOrderCard({
    required this.title,
    required this.priority,
    required this.assignedTo,
    required this.dueDate,
    required this.status,
    required this.workOrderId, // Add work order ID
    required this.availableWorkers, // Add available workers
    required this.onPressed,
    required this.deleteCallback,
    required this.isSelected,
    required this.onSelected,
    required this.customerName,
    required this.customerAddress,
    required this.customerContact,
    super.key,
  });

  @override
  _WorkOrderCardState createState() => _WorkOrderCardState();
}

class _WorkOrderCardState extends State<WorkOrderCard> {
  late String _currentStatus;
  late String? _assignedWorker; // Can be null initially
  List<String> _availableWorkers = []; // List to hold workers

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status; // Initialize with the current status
    _assignedWorker = widget.assignedTo.isNotEmpty
        ? widget.assignedTo
        : null; // Initialize with current worker, allow null if unassigned
    _fetchWorkers(); // Fetch workers on init
  }

// Function to fetch workers from Firestore

// Function to fetch and set workers in state
  Future<void> _fetchAndSetWorkers() async {
    final workers = await _fetchWorkers(); // Fetch the workers
    setState(() {
      _availableWorkers = workers; // Update the state with the fetched workers
    });
  }

  Future<List<String>> _fetchWorkers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('workers').get();
      return snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList(); // Make sure 'name' matches your field
    } catch (e) {
      print('Error fetching workers: $e');
      return [];
    }
  }

  // Function to update work order status in Firestore
  Future<void> _updateWorkOrderStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('workOrders')
          .doc(widget.workOrderId) // Use the passed workOrderId
          .update({
        'status': newStatus,
      });
      setState(() {
        _currentStatus = newStatus; // Update the current status
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Work order status updated to $newStatus')),
      );
    } catch (e) {
      print('Error updating work order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update work order status')),
      );
    }
  }

  // Function to update the assigned worker in Firestore
  Future<void> _assignWorker(String worker) async {
    try {
      await FirebaseFirestore.instance
          .collection('workOrders')
          .doc(widget.workOrderId)
          .update({
        'assignedTo': worker, // Update the assigned worker
      });
      setState(() {
        _assignedWorker = worker; // Update the UI
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned to $worker')),
      );
    } catch (e) {
      print('Error assigning worker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign worker')),
      );
    }
  }

  // Helper function to determine priority color
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.purple[200]!;
      case 'Medium':
        return Colors.orange[100]!;
      case 'Urgent':
        return Colors.red[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  // Helper function to determine status label color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.teal[100]!;
      case 'Completed':
        return Colors.green[200]!;
      case 'Pending':
        return Colors.orange[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  // Helper function to get status text
  String _getStatusText(String status) {
    switch (status) {
      case 'In Progress':
        return 'In Progress';
      case 'Completed':
        return 'Completed';
      case 'Pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Priority Label
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(widget.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.priority,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Assigned To and Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _assignedWorker != null
                          ? 'Assigned to: $_assignedWorker'
                          : 'Unassigned',
                      style: TextStyle(
                        fontSize: 14,
                        color: _assignedWorker != null
                            ? Colors.black54
                            : Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Due: ${widget.dueDate}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Customer Details Section
                const Divider(height: 20, thickness: 1),
                Text(
                  'Customer Details:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${widget.customerName}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Address: ${widget.customerAddress}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Contact: ${widget.customerContact}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Status Indicator and Dropdown Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_currentStatus),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(_currentStatus),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _currentStatus,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Colors.blue,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _updateWorkOrderStatus(newValue);
                        }
                      },
                      items: <String>['Pending', 'In Progress', 'Completed']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/home_page.dart';
import 'package:intl/intl.dart';

// WorkOrderModel integrated into the same file
class WorkOrderModel {
  // You can add variables and methods for your model logic here
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getWorkOrders() {
    return _firestore.collection('workOrders').snapshots();
  }

  // Count work orders by status
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

  // Add a new work order to Firestore
  Future<void> addWorkOrder(Map<String, dynamic> newWorkOrder) async {
    await _firestore.collection('work_orders').add(newWorkOrder);
  }

  // Update an existing work order in Firestore
  Future<void> updateWorkOrder(
      String workOrderId, Map<String, dynamic> updatedData) async {
    await _firestore
        .collection('work_orders')
        .doc(workOrderId)
        .update(updatedData);
  }

  Future<void> updateWorkOrderStatus(
      String workOrderId, String newStatus) async {
    try {
      // Reference to the Firestore collection
      CollectionReference workOrders =
          FirebaseFirestore.instance.collection('workOrders');

      // Update the status
      await workOrders.doc(workOrderId).update({'status': newStatus});
      print('Work order $workOrderId status updated to $newStatus');
    } catch (e) {
      print('Error updating work order status: $e');
    }
  }

  void initState() {
    // Initialize any resources here
  }
  void dispose() {
    // Clean up any resources here
  }
  void someAction() {
    // Example method to show functionality
    print("Action performed!");
  }

  Future<List<String>> getAvailableWorkers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('workers').get();

      // Debug print to see how many documents were fetched
      print('Number of workers fetched: ${snapshot.docs.length}');

      // Extracting worker names
      List<String> workers =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      // Print the names to debug
      print('Workers: $workers');

      return workers;
    } catch (e) {
      print('Error fetching available workers: $e');
      return [];
    }
  }
}

// WorkOrderWidget with integrated WorkOrderModel
class WorkOrderWidget extends StatefulWidget {
  const WorkOrderWidget({super.key});

  @override
  State<WorkOrderWidget> createState() => _WorkOrderWidgetState();
}

class _WorkOrderWidgetState extends State<WorkOrderWidget> {
  late WorkOrderModel _model;

  List<String> _availableWorkers =
      []; // Add this variable to hold available workers

  final Map<String, int> _workOrderCounts = {
    'total': 0,
    'inProgress': 0,
    'completed': 0,
  };

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize the WorkOrderModel instance
    _model = WorkOrderModel();
    _model.initState();
    _fetchAvailableWorkers(); // Call the method to fetch workers
  }

  void _fetchAvailableWorkers() async {
    List<String> workers = await _model.getAvailableWorkers();
    setState(() {
      _availableWorkers = workers; // Update the state with the fetched workers
    });
  }

  @override
  void dispose() {
    // Dispose of the WorkOrderModel instance
    _model.dispose();
    super.dispose();
  }

  void _addNewWorkOrder(String title, String priority, String assignedTo,
      DateTime dueDate) async {
    try {
      // Add a new work order to Firestore
      await FirebaseFirestore.instance.collection('workOrders').add({
        'title': title,
        'priority': priority,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'status': 'In Progress', // Default status
      });

      // Show a success message or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New work order added successfully!')),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add work order: $e')),
      );
    }
  }

  void _showAddWorkOrderDialog() {
    String title = '';
    String priority = 'Medium'; // Default value
    String assignedTo = '';
    DateTime dueDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Work Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Assigned To'),
                onChanged: (value) => assignedTo = value,
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Due Date (yyyy-mm-dd)'),
                onChanged: (value) {
                  // Parse the date string and set the due date
                  dueDate = DateTime.parse(value);
                },
              ),
              // Add a dropdown or another method for selecting priority
              // Example for a dropdown:
              DropdownButton<String>(
                value: priority,
                items: <String>['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    priority = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addNewWorkOrder(title, priority, assignedTo, dueDate);
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
                  Material(
                    color: Colors.transparent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        color: Colors
                            .white, // Replace with your desired background color
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Work Orders',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    fontSize:
                                        24, // Adjust the font size as needed
                                    color: Colors
                                        .black, // Replace with your desired text color
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      Icons.filter_list,
                                      color: Colors
                                          .blue, // Replace with your desired icon color
                                      size: 24,
                                    ),
                                    const SizedBox(
                                        width:
                                            8), // Space between icon and text
                                    const Text(
                                      'Filter',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            16, // Adjust the font size as needed
                                        color: Colors
                                            .blue, // Replace with your desired text color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ].divide(const SizedBox(
                                      width:
                                          8)), // Use .divide for spacing here
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: _model
                                  .getWorkOrders(), // Fetch work orders from Firestore
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child:
                                          CircularProgressIndicator()); // Show loading
                                }

                                var workOrders = snapshot
                                    .data!.docs; // Get the list of work orders

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: workOrders
                                      .length, // Number of work orders
                                  itemBuilder: (context, index) {
                                    var workOrder = workOrders[index];
                                    var data = workOrder.data() as Map<String,
                                        dynamic>; // Work order data
                                    DateTime dueDate = (data['dueDate']
                                            as Timestamp)
                                        .toDate(); // Convert Timestamp to DateTime
                                    String formattedDueDate = DateFormat.yMMMd()
                                        .format(dueDate); // Format the DateTime

                                    return WorkOrderCard(
                                      title: data['title'] ??
                                          'No Title', // Provide a default value
                                      priority: data['priority'] ??
                                          'Normal', // Provide a default value
                                      assignedTo: data['assignedTo'] ??
                                          'Unassigned', // Provide a default value
                                      dueDate: formattedDueDate,
                                      status: data['status'] ??
                                          'Pending', // Provide a default value
                                      workOrderId: workOrder.id,
                                      customerName: data['customerName'] ??
                                          'Unknown Customer', // Provide a default value
                                      customerAddress: data[
                                              'customerAddress'] ??
                                          'No Address', // Provide a default value
                                      customerContact: data[
                                              'customerContact'] ??
                                          'No Contact', // Provide a default value
                                      onPressed: () {
                                        print(
                                            'Update button pressed for ${data['title']}');
                                      },
                                      availableWorkers: _availableWorkers,
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
  final VoidCallback onPressed;
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
    required this.onPressed,
    required this.customerName,
    required this.customerAddress,
    required this.customerContact,
    super.key,
    required List<String> availableWorkers,
  });

  @override
  _WorkOrderCardState createState() => _WorkOrderCardState();
}

class _WorkOrderCardState extends State<WorkOrderCard> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status; // Initialize with the current status
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

  // Helper function to determine the button text based on status
  String _getButtonText(String status) {
    switch (status) {
      case 'In Progress':
        return 'Update';
      case 'Completed':
        return 'View Details';
      case 'Pending':
        return 'Assign';
      default:
        return 'Action';
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
            color: Colors.white, // Background color of the card
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(16), // General padding inside the card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align left
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Priority Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                      widget.assignedTo.isNotEmpty
                          ? 'Assigned to: ${widget.assignedTo}'
                          : 'Unassigned',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.assignedTo.isNotEmpty
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

                // Customer Details
                const Divider(height: 20, thickness: 1),
                Text(
                  'Customer Name: ${widget.customerName ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Customer Address: ${widget.customerAddress ?? 'No Address'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Customer Contact: ${widget.customerContact ?? 'No Contact'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

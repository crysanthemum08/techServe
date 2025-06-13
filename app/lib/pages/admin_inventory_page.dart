import 'package:app/pages/home_page.dart';
import 'package:app/services/database/firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminInventoryModel {
  /// State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(String?)? textControllerValidator;

  InventoryModel() {
    textFieldFocusNode = FocusNode();
    textController = TextEditingController();
    textControllerValidator = (value) {
      // Example validation logic
      if (value == null || value.isEmpty) {
        return 'Field cannot be empty';
      }
      return null; // No error
    };
  }

  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}

class AdminInventoryWidget extends StatefulWidget {
  /// *Inventory Management*: Tracks equipment, tools, and parts used in the
  /// field, helping technicians know what’s available or needed for their
  /// tasks.
  const AdminInventoryWidget({super.key});

  @override
  State<AdminInventoryWidget> createState() => _AdminInventoryWidgetState();
}

class _AdminInventoryWidgetState extends State<AdminInventoryWidget> {
  late AdminInventoryModel _model; // Declare the model variable
  late TextEditingController _textController;
  late TextEditingController _itemNameController;
  late TextEditingController _itemStockController;
  late FocusNode _focusNode;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late FirestoreService _firestoreService; // Add FirestoreService

  List<Map<String, dynamic>> _inventoryItems = [];

  @override
  void initState() {
    super.initState();
    _model = AdminInventoryModel(); // Initialize the model
    _itemNameController = TextEditingController();
    _itemStockController = TextEditingController();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _fetchInventoryItems();
  }

  @override
  void dispose() {
    _model.dispose(); // Dispose of the model
    _textController.dispose();
    _focusNode.dispose();
    _itemNameController.dispose();
    _itemStockController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventoryItems() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('inventory').get();
    setState(() {
      _inventoryItems = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'stock': doc['stock'],
        };
      }).toList();
    });
  }

  Future<void> _addItem(String name, int stock) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('inventory').add({
      'name': name,
      'stock': stock,
    });
    _fetchInventoryItems(); // Refresh the list
  }

  Future<void> _updateItem(String id, String name, int stock) async {
    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(id)
        .update({'name': name, 'stock': stock, 'timestamp': Timestamp.now()});
    _fetchInventoryItems(); // Refresh the list
  }

  Future<void> _deleteItem(String id) async {
    await FirebaseFirestore.instance.collection('inventory').doc(id).delete();
    _fetchInventoryItems(); // Refresh the list
  }

  // Function to calculate statistics
  int get totalItems => _inventoryItems.length;
  int get lowStock =>
      _inventoryItems.where((item) => item['stock'] < 10).length;
  int get outOfStock =>
      _inventoryItems.where((item) => item['stock'] == 0).length;

  // Stream to listen for items in Firestore
  Stream<QuerySnapshot> getItemsStream() {
    return _firestore
        .collection('inventory')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _searchInventory(String query) {
    if (query.isEmpty) {
      _fetchInventoryItems(); // If the search query is empty, show all items
    } else {
      setState(() {
        // Filter inventory items that contain the query
        _inventoryItems = _inventoryItems.where((item) {
          String itemName = item['name'].toString().toLowerCase();
          return itemName.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void openItemBox() {
    // Create controllers for stock input
    final TextEditingController itemStockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'), // Optional: Add a title for clarity
        content: Column(
          mainAxisSize: MainAxisSize.min, // Adjust the size to wrap content
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter item name',
              ),
            ),
            const SizedBox(height: 16), // Add some space between fields
            TextField(
              controller: itemStockController,
              keyboardType: TextInputType.number, // Ensure input is numeric
              decoration: const InputDecoration(
                hintText: 'Enter item stock',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_textController.text.isNotEmpty &&
                  itemStockController.text.isNotEmpty) {
                // Parse stock quantity to an integer
                int stock = int.tryParse(itemStockController.text) ??
                    1; // Default to 1 if parsing fails
                _addItem(
                    _textController.text, stock); // Use the user-defined stock
                Navigator.of(context).pop(); // Close the dialog after adding
              } else {
                // Handle empty input cases
                print("Item name and stock cannot be empty");
              }
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String id, String currentName, int currentStock) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController stockController =
        TextEditingController(text: currentStock.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String updatedName = nameController.text.trim();
                final int? updatedStock =
                    int.tryParse(stockController.text.trim());

                if (updatedName.isNotEmpty && updatedStock != null) {
                  _updateItem(id, updatedName, updatedStock);
                  Navigator.of(context)
                      .pop(); // Close the dialog after updating
                } else {
                  // Handle validation error (e.g., show a snackbar)
                  print('Invalid input');
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForItem(String itemName) {
    switch (itemName.toLowerCase()) {
      case 'screwdriver ':
        return FontAwesomeIcons.screwdriver; // Screwdriver icon
      case 'power drill':
        return Icons.power; // Build icon for power tools
      case 'circuit tester':
        return Icons.electrical_services; // Circuit tester icon
      case 'pipe wrench':
        return Icons.plumbing; // Pipe wrench icon
      case 'hammer':
        return FontAwesomeIcons.hammer; // Hammer icon
      case 'tape measure':
        return Icons.straighten; // Tape measure icon
      case 'multimeter':
        return Icons.tune; // Multimeter icon
      case 'safety goggles':
        return Icons.visibility; // Safety goggles icon
      case 'gloves':
        return Icons.handyman; // Gloves icon
      case 'drill bit':
        return Icons.donut_large; // Use a donut as a placeholder for drill bits
      case 'soldering iron':
        return Icons.hot_tub; // Soldering iron icon (as a placeholder)
      case 'level':
        return Icons.equalizer; // Level tool icon
      case 'flashlight':
        return Icons.flashlight_on; // Flashlight icon
      case 'toolbox':
        return Icons.build_circle; // Toolbox icon
      case 'wrench':
        return Icons.build; // Wrench icon
      // Add more items and their corresponding icons as needed
      default:
        return Icons.help_outline; // Default icon bui unknown items
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor:
              const Color(0xFF4B39EF), // Use your primary button color
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Back button icon
            onPressed: () {
              Navigator.of(context).pop(); // Go back to the previous page
            },
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        color: Colors.grey[
                            200], // Replace with your desired secondary background color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Quick Stats',
                              style: TextStyle(
                                fontFamily: 'Inter Tight',
                                fontWeight: FontWeight.bold,
                                fontSize: 20, // Adjust font size as needed
                                color: Color(0xFF14181B), // Primary text color
                                letterSpacing: 0.0,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Center the content
                                  children: [
                                    const Text(
                                      'Total Items',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            16, // Adjust font size as needed
                                        color: Color(
                                            0xFF57636C), // Secondary text color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    Text(
                                      totalItems.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize:
                                            24, // Adjust font size as needed
                                        color: Color(
                                            0xFF4B39EF), // Primary button color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Center the content
                                  children: [
                                    const Text(
                                      'Low Stock',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            16, // Adjust font size as needed
                                        color: Color(
                                            0xFF57636C), // Secondary text color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    Text(
                                      lowStock.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize:
                                            24, // Adjust font size as needed
                                        color: Colors.red, // Error color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Center the content
                                  children: [
                                    const Text(
                                      'Out of Stock',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize:
                                            16, // Adjust font size as needed
                                        color: Color(
                                            0xFF57636C), // Secondary text color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    Text(
                                      outOfStock.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Inter Tight',
                                        fontSize:
                                            24, // Adjust font size as needed
                                        color: Colors.orange, // Warning color
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ].divide(const SizedBox(height: 12)),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        color: Colors.grey[
                            200], // Replace with your desired secondary background color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Inventory List',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    fontSize: 20, // Adjust font size as needed
                                    color:
                                        Color(0xFF14181B), // Primary text color
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.filter_list,
                                    color: Color(
                                        0xFF4B39EF), // Primary button color
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    print('IconButton pressed ...');
                                  },
                                  iconSize: 40, // Button size
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _model.textController,
                              focusNode: _model
                                  .textFieldFocusNode, // Changed from _model.value to _model.textFieldFocusNode
                              autofocus: false,
                              obscureText: false,
                              decoration: const InputDecoration(
                                labelStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                                hintText: 'Search inventory...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: true,
                                fillColor: Color(0xFFF1F4F8),
                                suffixIcon: Icon(
                                  Icons.search,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                letterSpacing: 0.0,
                              ),
                              minLines: 1,
                              validator: _model
                                  .textControllerValidator, // Assign the validator function
                              onChanged: (value) {
                                _searchInventory(
                                    value); // Call search function as user types
                              },
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              primary: false,
                              shrinkWrap: true,
                              itemCount:
                                  _inventoryItems.length, // Dynamic list length
                              itemBuilder: (context, index) {
                                final item = _inventoryItems[
                                    index]; // Access each item dynamically
                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color:
                                                item['color'], // Dynamic color
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getIconForItem(item[
                                                'name']), // Get the icon based on item name
                                            color: const Color(0xFF14181B),
                                            size: 24,
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'], // Dynamic name
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 16,
                                                color: Color(0xFF14181B),
                                              ),
                                            ),
                                            Text(
                                              'In Stock: ${item['stock']}', // Dynamic stock
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                color: Color(0xFF57636C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ].divide(const SizedBox(width: 12)),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xFF4B39EF),
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            // Add your edit action here
                                            _showEditDialog(item['id'],
                                                item['name'], item['stock']);
                                            print('Edit ${item['name']}');
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color(0xFF4B39EF),
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            // Call the remove function dynamically
                                            _deleteItem(item['id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ].divide(const SizedBox(height: 12)),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      openItemBox(); // Call the function to open the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFF4B39EF), // Replace with your desired primary color
                      fixedSize: Size(MediaQuery.of(context).size.width, 50),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add New Item',
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontSize: 16, // Adjust font size as needed
                      ),
                    ),
                  ),
                ),
              ].divide(const SizedBox(height: 16)),
            ),
          ),
        ),
      ),
    );
  }
}

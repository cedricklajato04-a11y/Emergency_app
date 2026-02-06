import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'emergency_menu.dart';

class CustomContactsPage extends StatefulWidget {
  const CustomContactsPage({super.key});


  @override // ignore: library_private_types_in_public_api
  State<CustomContactsPage> createState() => _CustomContactsPageState();
  
}


class _CustomContactsPageState extends State<CustomContactsPage> {

//supabase client
  final supabase = Supabase.instance.client;

  User? get user => supabase.auth.currentUser;

//fetching contacts from database
  Future<void> fetchContacts() async {
  if (user == null) return;

  try { // Fetch contacts for the current user, ordered by creation time
    final response = await supabase
        .from('custom_contacts')
        .select()
        .order('created_at');

    setState(() { // Update state with fetched contacts
      contacts = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  } catch (e) { // Handle errors and update loading state
    isLoading = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load contacts")),
    );
  }
  } 

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }


  // List to hold contacts
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;


  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  String emergencyType = "Police"; // Default value

  Future<void> addContact() async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  final name = nameController.text.trim();
  final phone = phoneController.text.trim();
  final location = locationController.text.trim();

  if (name.isEmpty || phone.isEmpty || location.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All fields are required")),
    );
    return;
  }
  //adding contact to database
  try {
    await supabase.from('custom_contacts').insert({
      'user_id': user.id,
      'name': name,
      'number': phone, 
      'location': location,
      'type': emergencyType,
    });

    setState(() {
      contacts.add({
        'name': name,
        'number': phone,
        'location': location,
        'type': emergencyType,
      });
    });

    nameController.clear();
    phoneController.clear();
    locationController.clear();
    emergencyType = "Police";

    Navigator.pop(context);
  } catch (e) {
    debugPrint("ADD CONTACT ERROR: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to add contact")),
    );
  }
}


  


  void showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Emergency Contact"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),

                // Phone
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Contact Number",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),

                // Location
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),

                // Type of Emergency Dropdown
                DropdownButtonFormField<String>(
                  initialValue: emergencyType,
                  items: const [
                    DropdownMenuItem(value: "Police", child: Text("Police")),
                    DropdownMenuItem(value: "Hospital", child: Text("Hospital")),
                    DropdownMenuItem(value: "Fire Station", child: Text("Fire Station")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      emergencyType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Type of Emergency",
                    prefixIcon: Icon(Icons.warning),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: addContact,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 199, 199),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text(
          "Custom Contacts",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        onPressed: showAddContactDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : contacts.isEmpty
            ? const Center(
                child: Text(
                  "No emergency contacts added",
                  style: TextStyle(fontSize: 16),
                ),
              )
        : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Color.fromARGB(214, 184, 23, 23),
                    ),
                    title: Text(
                      contact['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${contact['number'] ?? ''}\n${contact['location'] ?? ''} - ${contact['type'] ?? ''}",
                    ),
                    isThreeLine: true,

                    // Tap contact → Emergency Menu
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EmergencyMenuPage(contacts: contacts),
    ),
  );
},

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                          final contactId = contact['id'];

                          await supabase
                              .from('custom_contacts')
                              .delete()
                              .eq('id', contactId);

                          fetchContacts();
                        },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
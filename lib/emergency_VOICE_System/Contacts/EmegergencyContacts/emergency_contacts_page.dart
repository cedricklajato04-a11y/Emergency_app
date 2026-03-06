import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/constants/fallback_numbers.dart';

class EmergencyContactsPage extends StatefulWidget {
  final String title;
  final String contactType; // 'police' | 'hospital' | 'fire_station'

  const EmergencyContactsPage({
    super.key,
    required this.title,
    required this.contactType,
  });

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> rows = [];
  String fallbackNumber = "911";

  @override
  void initState() {
    super.initState();
    _load();
  }

Future<void> _load() async {
  setState(() {
    loading = true;
    error = null;
  });

  try {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception("Not logged in");

    // 1) Load emergency contacts
    final res = await supabase
        .from('emergency_contacts')
        .select()
        .eq('user_id', uid)
        .eq('contact_type', widget.contactType)
        .order('rank', ascending: true);

    rows = List<Map<String, dynamic>>.from(res);

    // 2) Load user settings row
    final settings = await supabase
        .from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
        
    if (settings != null) {
      switch (widget.contactType) {
        case 'police':
          fallbackNumber =
              (settings['police_fallback'] ?? FallbackNumbers.police).toString();
          break;
        case 'hospital':
          fallbackNumber =
              (settings['hospital_fallback'] ?? FallbackNumbers.hospital).toString();
          break;
        case 'fire_station':
          fallbackNumber =
              (settings['fire_fallback'] ?? FallbackNumbers.fireStation).toString();
          break;
        default:
          fallbackNumber = "911";
      }
    } else {
      switch (widget.contactType) {
        case 'police':
          fallbackNumber = FallbackNumbers.police;
          break;
        case 'hospital':
          fallbackNumber = FallbackNumbers.hospital;
          break;
        case 'fire_station':
          fallbackNumber = FallbackNumbers.fireStation;
          break;
        default:
          fallbackNumber = "911";
      }
    }
    } catch (e) {
      error = e.toString();
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  String _rankLabel(int r) {
    if (r == 1) return "Nearest";
    if (r == 2) return "2nd Nearest";
    return "3rd Nearest";
  }

  Future<void> _call(String number) async {
    final n = number.trim();
    if (n.isEmpty) return;

    final ok = await launchUrl(
      Uri(scheme: 'tel', path: n),
      mode: LaunchMode.externalApplication,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open phone dialer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 40),
                      Center(child: Text("Error: $error")),
                    ],
                  )
                : rows.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 40),
                          Center(child: Text("No emergency contacts yet.")),
                        ],
                      )
                    : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: rows.length + 1, // +1 for fallback hotline
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        // Last item = fallback hotline
                        if (i == rows.length) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                              title: const Text("Fallback Hotline"),
                              subtitle: Text(fallbackNumber),
                              trailing: const Icon(Icons.call),
                              onTap: fallbackNumber.trim().isEmpty
                                  ? null
                                  : () => _call(fallbackNumber),
                            ),
                          );
                        }

                        final c = rows[i];
                        final rank = (c['rank'] ?? (i + 1)) as int;
                        final name = (c['name'] ?? '').toString();
                        final number = (c['phone_number'] ?? '').toString();
                        final address = (c['address'] ?? '').toString();

                        return Card(
                          child: ListTile(
                            title: Text("${_rankLabel(rank)} • $name"),
                            subtitle: Text("$number\n$address"),
                            isThreeLine: true,
                            trailing: const Icon(Icons.call),
                            onTap: number.isEmpty ? null : () => _call(number),
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}
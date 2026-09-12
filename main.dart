import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ElsorvisaApp());

const destinations = <String>[
  'Venezyela',
  'Kolonbi',
  'Giyàn',
  'Kiba',
  'Albani',
];

class ElsorvisaApp extends StatelessWidget {
  const ElsorvisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elsorvisa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0d5c63)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elsorvisa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Aplikasyon e‑Visa ou',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Prepare yon demann pou youn nan destinasyon yo.'),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Kòmanse yon aplikasyon'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VisaFormPage()),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.track_changes),
            label: const Text('Swiv yon dosye demo'),
            onPressed: () => _showStatus(context),
          ),
          const SizedBox(height: 28),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Demo MVP: soumèt yo ale nan mock API a. '
                'API ofisyèl yo dwe ajoute sèlman apre otorizasyon ekri ak yon backend sekirize.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Estati dosye'),
        content: const Text('Demo: Dosye resevwa — ap tann verifikasyon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fèmen'),
          ),
        ],
      ),
    );
  }
}

class VisaFormPage extends StatefulWidget {
  const VisaFormPage({super.key});

  @override
  State<VisaFormPage> createState() => _VisaFormPageState();
}

class _VisaFormPageState extends State<VisaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _passport = TextEditingController();
  String? _destination;
  DateTime? _travelDate;
  PlatformFile? _passportFile;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _passport.dispose();
    super.dispose();
  }

  Future<void> _pickPassport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) setState(() => _passportFile = result.files.single);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _travelDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _destination == null ||
        _travelDate == null ||
        _passportFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ranpli tout chan yo ak dokiman paspò a.')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _sending = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dosye soumèt nan demo a'),
        content: Text(
          'Nimewo dosye: ELS-${DateTime.now().millisecondsSinceEpoch}\n'
          'Destinasyon: $_destination',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Fèmen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvo demann e‑Visa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              value: _destination,
              decoration: const InputDecoration(labelText: 'Peyi destinasyon'),
              items: destinations
                  .map((country) =>
                      DropdownMenuItem(value: country, child: Text(country)))
                  .toList(),
              onChanged: (value) => setState(() => _destination = value),
              validator: (value) => value == null ? 'Chwazi yon peyi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Non konplè jan li sou paspò a'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Chan obligatwa' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passport,
              decoration: const InputDecoration(labelText: 'Nimewo paspò'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Chan obligatwa' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(_travelDate == null
                  ? 'Chwazi dat vwayaj la'
                  : '${_travelDate!.day}/${_travelDate!.month}/${_travelDate!.year}'),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(_passportFile == null
                  ? 'Telechaje kopi paspò a'
                  : _passportFile!.name),
              onPressed: _pickPassport,
            ),
            const SizedBox(height: 26),
            FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(_sending ? 'Ap voye…' : 'Soumèt nan demo a'),
            ),
          ],
        ),
      ),
    );
  }
}

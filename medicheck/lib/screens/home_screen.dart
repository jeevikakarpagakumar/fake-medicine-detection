import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  File? _pickedImage;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) setState(() { _pickedImage = File(picked.path); _error = null; });
  }

  Future<void> _verify() async {
    if (_textCtrl.text.trim().isEmpty && _pickedImage == null) {
      setState(() => _error = 'Please enter text or pick an image.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = _pickedImage != null
          ? await ApiService.uploadImage(_pickedImage!)
          : await ApiService.verifyText(_textCtrl.text.trim());

      if (!mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.medication_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MediCheck',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Fake medicine detector',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                ]),
              ])
              .animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 40),

              // Text input section
              Text('Enter medicine name or label text',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white54))
              .animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 10),
              TextField(
                controller: _textCtrl,
                maxLines: 4,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. Paracetamol 500mg Batch no: ABC123...',
                  hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFF161B22),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF30363D)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF30363D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                ),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Divider
              Row(children: [
                Expanded(child: Divider(color: Colors.white12)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or scan an image',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white30)),
                ),
                Expanded(child: Divider(color: Colors.white12)),
              ]).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 20),

              // Image picker area
              GestureDetector(
                onTap: () => _showImagePicker(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: _pickedImage != null ? 200 : 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _pickedImage != null
                            ? const Color(0xFF3ECFCF)
                            : const Color(0xFF30363D),
                        width: 1.5),
                  ),
                  child: _pickedImage != null
                      ? Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_pickedImage!,
                                width: double.infinity, height: 200, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 10, right: 10,
                            child: GestureDetector(
                              onTap: () => setState(() => _pickedImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ])
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              color: Color(0xFF3ECFCF), size: 36),
                          const SizedBox(height: 8),
                          Text('Tap to upload or take a photo',
                              style: GoogleFonts.inter(color: Colors.white30, fontSize: 13)),
                        ]),
                ),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                        style: GoogleFonts.inter(color: Color(0xFFE74C3C), fontSize: 13))),
                  ]),
                ),
              ],

              const SizedBox(height: 30),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.search_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Verify Medicine',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ]),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Choose source',
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _PickerButton(
                icon: Icons.camera_alt_rounded, label: 'Camera',
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); })),
            const SizedBox(width: 12),
            Expanded(child: _PickerButton(
                icon: Icons.photo_library_rounded, label: 'Gallery',
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); })),
          ]),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF3ECFCF), size: 30),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
        ]),
      ),
    );
  }
}
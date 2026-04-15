import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/medicine_result.dart';
import '../widgets/result_card.dart';
import 'chat_screen.dart';

class ResultScreen extends StatelessWidget {
  final MedicineResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3ECFCF),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
        onPressed: () {
          final contextData = result.toString();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(context: contextData),
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Verification Result',
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: result.error != null
            ? _ErrorView(error: result.error!)
            : ResultCard(result: result)
                .animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        const SizedBox(height: 60),
        const Icon(Icons.cloud_off_rounded, color: Color(0xFFE74C3C), size: 64),
        const SizedBox(height: 16),
        Text('Something went wrong',
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
      ]),
    );
  }
}
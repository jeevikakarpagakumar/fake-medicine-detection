import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/medicine_result.dart';

class ResultCard extends StatelessWidget {
  final MedicineResult result;
  const ResultCard({super.key, required this.result});

  Color _statusColor(String? status) {
    switch (status) {
      case 'Genuine': return const Color(0xFF2ECC71);
      case 'Needs Verification': return const Color(0xFFF39C12);
      default: return const Color(0xFFE74C3C);
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Genuine': return Icons.verified_rounded;
      case 'Needs Verification': return Icons.warning_amber_rounded;
      default: return Icons.dangerous_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(result.finalStatus);
    final confidence = (result.confidenceRuleBased ?? 0) / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Column(children: [
            Icon(_statusIcon(result.finalStatus), color: color, size: 52),
            const SizedBox(height: 10),
            Text(
              result.finalStatus ?? 'Unknown',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26, fontWeight: FontWeight.w700, color: color,
              ),
            ),
            if (result.medicine != null)
              Text(
                result.medicine!,
                style: GoogleFonts.inter(fontSize: 15, color: Colors.white70),
              ),
          ]),
        ),

        const SizedBox(height: 20),

        // Confidence Gauge
        if (result.confidenceRuleBased != null) ...[
          Text('Rule-based confidence',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 14.0,
            percent: confidence.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            progressColor: color,
            barRadius: const Radius.circular(7),
            padding: EdgeInsets.zero,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${result.confidenceRuleBased}%',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
        ],

        // ML Prediction chip
        if (result.mlPrediction != null && result.mlPrediction != 'Unknown')
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.psychology_rounded, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text('ML: ${result.mlPrediction}',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              if (result.mlConfidence != null && result.mlConfidence! > 0) ...[
                const SizedBox(width: 6),
                Text('(${(result.mlConfidence! * 100).toStringAsFixed(0)}%)',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ]
            ]),
          ),

        // Details rows
        _DetailRow(label: 'Manufacturer', value: result.manufacturer),
        _DetailRow(label: 'Composition', value: result.composition),
        _DetailRow(label: 'Batch Number', value: result.batchNumber),
        _DetailRow(label: 'Barcode', value: result.barcode),
        if (result.extractedText != null)
          _DetailRow(label: 'Extracted Text', value: result.extractedText),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  const _DetailRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
        ),
        Expanded(
          child: Text(value!,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
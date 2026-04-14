class MedicineResult {
  final String? medicine;
  final String? manufacturer;
  final String? composition;
  final String? batchNumber;
  final String? barcode;
  final String? ruleStatus;
  final int? confidenceRuleBased;
  final String? mlPrediction;
  final double? mlConfidence;
  final String? finalStatus;
  final String? inputText;
  final String? extractedText;
  final String? error;

  MedicineResult({
    this.medicine,
    this.manufacturer,
    this.composition,
    this.batchNumber,
    this.barcode,
    this.ruleStatus,
    this.confidenceRuleBased,
    this.mlPrediction,
    this.mlConfidence,
    this.finalStatus,
    this.inputText,
    this.extractedText,
    this.error,
  });

  factory MedicineResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? json;
    return MedicineResult(
      medicine: result['medicine'],
      manufacturer: result['manufacturer'],
      composition: result['composition'],
      batchNumber: result['batch_number'],
      barcode: result['barcode'],
      ruleStatus: result['rule_status'],
      confidenceRuleBased: result['confidence_rule_based'],
      mlPrediction: result['ml_prediction'],
      mlConfidence: (result['ml_confidence'] as num?)?.toDouble(),
      finalStatus: result['final_status'] ?? result['status'],
      inputText: json['input_text'],
      extractedText: json['extracted_text'],
      error: json['error'],
    );
  }
}
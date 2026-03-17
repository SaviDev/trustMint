class ValidationPolicy {
  /// Marca il batch come valido o sospetto basato su varianza/range
  bool isBatchValid(List<double> samples, String sensorType) {
    if (samples.isEmpty) return false;
    // Dummy: se tutti i valori sono uguali (device appoggiato per molto), 
    // potrebbe essere considerato valid ma "idle".
    return true; 
  }
}

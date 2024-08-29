/// Bhattacharyya Distance
///
/// The Bhattacharyya distance is a measure of the similarity of two discrete
/// or continuous probability distributions.
///
/// Example:
/// ```dart
/// import 'package:bhattacharyya/bhattacharyya.dart';
///
/// void main() {
///   print(bhattacharyya([0.1, 0.2, 0.7], [0.1, 0.2, 0.7])); // 0
///   print(bhattacharyya([0.1, 0.2, 0.7], [0.2, 0.3, 0.5])); // 0.08512282595722162
/// }

library bhattacharyya;

import 'dart:math';
import 'package:fhel/afhe.dart' show Afhe, Ciphertext;

/// Bhattacharyya Distance
///
/// The Bhattacharyya distance is a measure of the similarity of two discrete
/// or continuous probability distributions.
///
double bhattacharyya(List<double> p, List<double> q) {
  if (p.length != q.length) {
    throw ArgumentError('The length of p and q must be the same.');
  }
  double sum = 0;
  for (int i = 0; i < p.length; i++) {
    sum += sqrt(p[i] * q[i]);
  }
  return -log(sum);
}

/// Bhattacharyya Distance for encrypted double
///
/// See [bhattacharyya] for more details.
///
Ciphertext bhattacharyyaCiphertextDouble(Afhe fhe, Ciphertext sqrtX, double sqrtY) {
  return fhe.multiplyPlain(sqrtX, fhe.encodeDouble(sqrtY));
}

/// Bhattacharyya Distance for encrypted list of doubles
///
/// See [bhattacharyya] for more details.
///
List<Ciphertext> bhattacharyyaCiphertextVecDouble(Afhe fhe, List<Ciphertext> sqrtX, List<double> sqrtY) {
  if (sqrtX.length != sqrtY.length) {
    throw ArgumentError('The length of sqrtX and sqrtY must be the same.');
  }
  List<Ciphertext> result = [];
  for (int i = 0; i < sqrtX.length; i++) {
    result.add(bhattacharyyaCiphertextDouble(fhe, sqrtX[i], sqrtY[i]));
  }
  return result;
}

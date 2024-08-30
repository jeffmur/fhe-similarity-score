/// Bhattacharyya Coefficient and Distance
///
/// The Bhattacharyya Coefficient is a measure of the overlap between the two distributions,
/// where a value of 1 indicates complete overlap (identical distributions) and a value of 0 indicates no overlap.
///
/// The Bhattacharyya Distance is a measure of the separation between the two distributions,
/// where a value of 0 indicates complete overlap (identical distributions) and a value of infinity indicates no overlap.
///
/// Example:
/// ```dart
/// import 'package:bhattacharyya/bhattacharyya.dart';
///
/// void main() {
///   print(distance([0.1, 0.2, 0.7], [0.1, 0.2, 0.7])); // 0
///   print(distance([0.1, 0.2, 0.7], [0.2, 0.3, 0.5])); // 0.022267788308219707
//    print(coefficient([0.1, 0.2, 0.7], [0.1, 0.2, 0.7])); // 1.0
//    print(coefficient([0.1, 0.2, 0.7], [0.2, 0.3, 0.5])); // 0.9779783088255889
/// }
/// ```

library bhattacharyya;

import 'dart:math';
import 'package:fhel/afhe.dart' show Afhe, Ciphertext;

/// Bhattacharyya Coefficient
///
/// The Bhattacharyya Coefficient is a measure of the overlap between the two distributions,
/// where a value of 1 indicates complete overlap (identical distributions) and a value of 0 indicates no overlap.
/// The function assumes that both p and q are lists of probabilities with the same length.
/// If the lists are of different lengths, the function throws an [ArgumentError].
/// The coefficient is a non-negative value, and higher values indicate greater similarity between the distributions.
///
double coefficient(List<double> p, List<double> q) {
  if (p.length != q.length) {
    throw ArgumentError('The length of p and q must be the same.');
  }
  double sum = 0;
  for (int i = 0; i < p.length; i++) {
    sum += sqrt(p[i] * q[i]);
  }
  return sum;
}

/// Bhattacharyya Distance
///
/// The Bhattacharyya Distance is a measure of dissimilarity between two distributions and
/// is calculated by taking the negative logarithm of the Bhattacharyya [coefficient].
/// The function assumes that both p and q are lists of probabilities with the same length.
/// If the lists are of different lengths, the function throws an [ArgumentError].
/// The result is a non-negative value, with smaller values indicating more similar distributions.
///
double distance(List<double> p, List<double> q) {
  return -log(coefficient(p, q));
}

/// Bhattacharyya Distance for encrypted double
///
/// See [distance] for more details.
///
Ciphertext distanceCiphertextDouble(Afhe fhe, Ciphertext sqrtX, double sqrtY) {
  return fhe.multiplyPlain(sqrtX, fhe.encodeDouble(sqrtY));
}

/// Bhattacharyya Distance for encrypted list of doubles
///
/// See [distance] for more details.
///
List<Ciphertext> distanceCiphertextVecDouble(Afhe fhe, List<Ciphertext> sqrtX, List<double> sqrtY) {
  if (sqrtX.length != sqrtY.length) {
    throw ArgumentError('The length of sqrtX and sqrtY must be the same.');
  }
  List<Ciphertext> result = [];
  for (int i = 0; i < sqrtX.length; i++) {
    result.add(distanceCiphertextDouble(fhe, sqrtX[i], sqrtY[i]));
  }
  return result;
}

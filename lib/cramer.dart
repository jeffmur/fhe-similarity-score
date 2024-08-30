/// Cramer's Distance
///
/// The Cramer Distance is a measure of dissimilarity between two distributions and
/// is calculated by taking the square root of the sum of the squared differences between the two distributions.
///
/// Example:
/// ```dart
/// import 'package:fhe_similarity_score/cramer.dart';
///
/// void main() {
///  print(distance([0.1, 0.2, 0.7], [0.1, 0.2, 0.7])); // 0
///  print(distance([0.1, 0.2, 0.7], [0.2, 0.3, 0.5])); // 0.24494897427831777
/// }
///
library cramer;

import 'dart:math';
import 'package:fhel/afhe.dart' show Afhe, Plaintext, Ciphertext;

/// Cramer Distance
///
/// The Cramer Distance is a measure of dissimilarity between two distributions and
/// is calculated by taking the square root of the sum of the squared differences between the two distributions.
/// The function assumes that both [p] and [q] are lists of probabilities with the same length.
/// If the lists are of different lengths, the function throws an [ArgumentError].
///
double distance(List<double> p, List<double> q) {
  if (p.length != q.length) {
    throw ArgumentError('The length of p and q must be the same.');
  }
  double sum = 0;
  for (int i = 0; i < p.length; i++) {
    sum += pow(p[i] - q[i], 2);
  }
  return sqrt(sum);
}

/// Cramer Distance for encrypted double
///
/// Apply the square root of the [Plaintext] before returning.
///
/// See [distance] for more details.
///
Ciphertext distanceOfCiphertextDouble(Afhe fhe, Ciphertext x, double y) {
  return fhe.square(fhe.subtractPlain(x, fhe.encodeDouble(y)));
}

/// Cramer Distance for encrypted list of doubles
///
/// Apply the square root of the sum of List<[Plaintext]> before returning.
///
/// See [distance] for more details.
///
List<Ciphertext> distanceOfCiphertextVecDouble(Afhe fhe, List<Ciphertext> x, List<double> y) {
  if (x.length != y.length) {
    throw ArgumentError('The length of x and y must be the same.');
  }
  List<Ciphertext> result = [];
  for (int i = 0; i < x.length; i++) {
    result.add(distanceOfCiphertextDouble(fhe, x[i], y[i]));
  }
  return result;
}

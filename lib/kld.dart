/// Kullback-Leibler Divergence
///
/// Measure of how one probability distribution diverges from a second,
/// expected probability distribution.
///
/// Example:
/// ```dart
/// import 'package:fhe_similarity_score/kld.dart';
///
/// void main() {
///  print(divergence([0.1, 0.2, 0.7], [0.1, 0.2, 0.7])); // 0
///  print(divergence([0.1, 0.2, 0.7], [0.2, 0.3, 0.5])); // 0.08512282595722162
/// }

library kld;

import 'dart:math';
import 'package:fhel/afhe.dart' show Afhe, Plaintext, Ciphertext;

/// Kullback-Leibler Divergence
///
/// The Kullback-Leibler Divergence (KLD) is a measure of how one probability
/// distribution diverges from a second, expected probability distribution.
///
double divergence(List<double> p, List<double> q) {
  if (p.length != q.length) {
    throw ArgumentError('The length of p and q must be the same.');
  }
  double sum = 0;
  for (int i = 0; i < p.length; i++) {
    if (p[i] == 0 || q[i] == 0) {
      continue;
    }
    sum += p[i] * log(p[i] / q[i]);
  }
  return sum;
}

/// Kullback-Leibler Divergence between [Ciphertext] and [double]
///
/// See [divergence] for more details.
///
Ciphertext divergenceOfCiphertextDouble(
    Afhe fhe, Ciphertext x, Ciphertext logX, double q) {
  Plaintext logQ = fhe.encodeDouble(log(q));
  Ciphertext subLog = fhe.subtractPlain(logX, logQ);
  return fhe.multiply(x, subLog);
}

/// Kullback-Leibler Divergence for encrypted list of doubles
///
/// Apply the sum of List<[Plaintext]> before returning.
///
/// See [divergence] for more details.
///
List<Ciphertext> divergenceOfCiphertextVecDouble(
    Afhe fhe, List<Ciphertext> x, List<Ciphertext> logX, List<double> q) {
  if (x.length != logX.length || x.length != q.length) {
    throw ArgumentError('The length of x and logX and q must be the same.');
  }
  List<Ciphertext> result = [];
  for (int i = 0; i < x.length; i++) {
    result.add(divergenceOfCiphertextDouble(fhe, x[i], logX[i], q[i]));
  }
  return result;
}

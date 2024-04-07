import 'dart:math';
import 'package:fhel/afhe.dart' show Afhe, Plaintext, Ciphertext;

/// Kullback-Leibler Divergence
///
/// The Kullback-Leibler Divergence (KLD) is a measure of how one probability
/// distribution diverges from a second, expected probability distribution.
///
double kld(List<double> p, List<double> q) {
  if (p.length != q.length) {
    throw ArgumentError('The length of p and q must be the same.');
  }
  double sum = 0;
  for (int i = 0; i < p.length; i++) {
    if (p[i] == 0) {
      continue;
    }
    sum += p[i] * log(p[i] / q[i]);
  }
  return sum;
}

/// Kullback-Leibler Divergence for encrypted scalars
///
/// The Kullback-Leibler Divergence (KLD) is a measure of how one probability
/// distribution diverges from a second, expected probability distribution.
///
Ciphertext kldElement(Afhe fhe, Ciphertext x, Ciphertext logX, double q) {
  Plaintext logQ = fhe.encodeDouble(log(q));
  Ciphertext subLog = fhe.subtractPlain(logX, logQ);
  return fhe.multiply(x, subLog);
}

/// Kullback-Leibler Divergence for encrypted vectors
///
/// The Kullback-Leibler Divergence (KLD) is a measure of how one probability
/// distribution diverges from a second, expected probability distribution.
///
List<Ciphertext> kldCiphertext(Afhe fhe, List<Ciphertext> x, List<Ciphertext> logX, List<double> q) {
  if (x.length != logX.length) {
    throw ArgumentError('The length of x and logX must be the same.');
  }
  List<Ciphertext> result = [];
  for (int i = 0; i < x.length; i++) {
    result.add(kldElement(fhe, x[i], logX[i], q[i]));
  }
  return result;
}

import 'package:test/test.dart';
import 'package:fhe_similarity_score/kl_divergence.dart';
import 'test_utils.dart';

void main() {

  test('Simple', () {
    expect(kld([0.1, 0.2, 0.7], [0.1, 0.2, 0.7]), 0);
    expect(kld([0.1, 0.2, 0.7], [0.2, 0.3, 0.5]), 0.08512282595722162);
  });

  test('Different length', () {
    expect(() => kld([0.1, 0.2, 0.7], [0.1, 0.2]), throwsArgumentError);
  });

  test('SEAL CKKS', () {
    Seal seal = Seal('ckks');
    String status = seal.genContext({
      'polyModDegree': 8192,
      'encodeScalar': pow(2, 40),
      'qSizes': [60, 40, 40, 60]
    });
    expect(status, 'success: valid');
    seal.genKeys();
    final x = [0.1, 0.2, 0.7];
    final logX = x.map((e) => log(e)).toList();
    final y = [0.2, 0.3, 0.5];

    final cipherX = x.map((e) => seal.encrypt(seal.encodeDouble(e))).toList();
    final cipherLogX = logX.map((e) => seal.encrypt(seal.encodeDouble(e))).toList();
    
    List<Ciphertext> cipherSum = kldCiphertext(seal, cipherX, cipherLogX, y);

    List<Plaintext> decrypted = cipherSum.map((e) => seal.decrypt(e)).toList();
    List<List<double>> result = decrypted.map((e) => seal.decodeVecDouble(e, 1)).toList();

    // flatten the list, TODO: Remove this when we have decodeDouble
    List<double> flat = [];
    for (int i = 0; i < result.length; i++) {
      flat.addAll(result[i]);
    }

    double sum = flat.reduce((value, element) => value + element);
    near(sum, 0.08512282595722162, eps: 1e-7); // Up-to 7 decimal precision
  });

  test('SEAL Different length', () {
    Seal seal = Seal('ckks');
    String status = seal.genContext({
      'polyModDegree': 8192,
      'encodeScalar': pow(2, 40),
      'qSizes': [60, 40, 40, 60]
    });
    expect(status, 'success: valid');
    seal.genKeys();
    final x = [0.1, 0.2, 0.7];
    final logX = x.map((e) => log(e)).toList();
    final y = [0.2, 0.3];

    final cipherX = x.map((e) => seal.encrypt(seal.encodeDouble(e))).toList();
    final cipherLogX = logX.map((e) => seal.encrypt(seal.encodeDouble(e))).toList();
    
    expect(() => kldCiphertext(seal, cipherX, cipherLogX, y), throwsArgumentError);
  });
}

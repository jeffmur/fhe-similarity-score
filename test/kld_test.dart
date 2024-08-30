import 'package:test/test.dart';
import 'package:fhe_similarity_score/kld.dart';
import 'test_utils.dart';

void main() {

  group("Plaintext", () {
    test('List<Double>', () {
      expect(kld([0.1, 0.2, 0.7], [0.1, 0.2, 0.7]), 0);
      expect(kld([0.1, 0.2, 0.7], [0.2, 0.3, 0.5]), 0.08512282595722162);
    });

    test('Throw on different length', () {
      expect(() => kld([0.1, 0.2, 0.7], [0.1, 0.2]), throwsArgumentError);
    });
  });

  group("SEAL", () {
    test('CKKS', () {
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

      final cipherX = encryptVecDouble(seal, x);
      final cipherLogX = encryptVecDouble(seal, logX);

      List<Ciphertext> cipherSum = kldCiphertextVecDouble(seal, cipherX, cipherLogX, y);

      List<Plaintext> decrypted = cipherSum.map((e) => seal.decrypt(e)).toList();
      List<double> result = decrypted.map((e) => seal.decodeVecDouble(e, 1).first).toList();

      double sum = result.reduce((value, element) => value + element);
      near(sum, kld(x, y), eps: 1e-7); // Up-to 7 decimal precision
    });

    test('Throw on different length', () {
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

      final cipherX = encryptVecDouble(seal, x);
      final cipherLogX = encryptVecDouble(seal, logX);

      expect(() => kldCiphertextVecDouble(seal, cipherX, cipherLogX, y), throwsArgumentError);
    });
  });
}

import 'package:test/test.dart';
import 'package:fhe_similarity_score/bhattacharyya.dart';
import 'test_utils.dart';

void main() {
  group("Plaintext", () {
    test('List<Double>', () {
      expect(bhattacharyya([0.1, 0.2, 0.7], [0.1, 0.2, 0.7]), 0);
      expect(bhattacharyya([0.1, 0.2, 0.7], [0.2, 0.3, 0.5]),
          0.022267788308219707);
    });

    test('Throw on different length', () {
      expect(() => bhattacharyya([0.1, 0.2, 0.7], [0.1, 0.2]),
          throwsArgumentError);
    });
  });

  group("SEAL", () {
    test("CKKS", () {
      Seal seal = Seal('ckks');
      String status = seal.genContext({
        'polyModDegree': 8192,
        'encodeScalar': pow(2, 40),
        'qSizes': [60, 40, 40, 60]
      });
      expect(status, 'success: valid');
      seal.genKeys();
      final x = [0.1, 0.2, 0.7];
      final sqrtX = x.map((e) => sqrt(e)).toList();
      final y = [0.2, 0.3, 0.5];
      final sqrtY = y.map((e) => sqrt(e)).toList();

      final cipherSqrtX = encryptVecDouble(seal, sqrtX);

      List<Ciphertext> cipherSum = bhattacharyyaCiphertextVecDouble(seal, cipherSqrtX, sqrtY);
      List<Plaintext> decrypted = cipherSum.map((e) => seal.decrypt(e)).toList();
      List<double> result = decrypted.map((e) => seal.decodeVecDouble(e, 1).first).toList();

      double sum = result.reduce((value, element) => value + element);
      double logSum = -log(sum);
      near(logSum, bhattacharyya(x, y), eps: 1e-7); // Up-to 7 decimal precision
    });

    test("Throw on different length", () {
      Seal seal = Seal('ckks');
      String status = seal.genContext({
        'polyModDegree': 8192,
        'encodeScalar': pow(2, 40),
        'qSizes': [60, 40, 40, 60]
      });
      expect(status, 'success: valid');
      seal.genKeys();
      final x = [0.1, 0.2, 0.7];
      final sqrtX = x.map((e) => sqrt(e)).toList();
      final y = [0.2, 0.3];
      final sqrtY = y.map((e) => sqrt(e)).toList();

      final cipherSqrtX = encryptVecDouble(seal, sqrtX);

      expect(() => bhattacharyyaCiphertextVecDouble(seal, cipherSqrtX, sqrtY), throwsArgumentError);
    });
  });
}

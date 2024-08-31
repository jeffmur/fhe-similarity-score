import 'package:test/test.dart';
import 'package:fhe_similarity_score/kld.dart';
import 'test_utils.dart';

void main() {
  List<Map<String, dynamic>> tests = [
    {
      'x': [0.1, 0.2, 0.7],
      'y': [0.1, 0.2, 0.7],
      'divergence': 0.0
    },
    {
      'x': [0.1, 0.2, 0.7],
      'y': [0.2, 0.3, 0.5],
      'divergence': 0.08512282595722162
    },
  ];

  group("Plaintext", () {
    for (var config in tests) {
      var {'x': x, 'y': y} = config;
      test("List<Double> where x:$x y:$y", () {
        near(divergence(x, y), config['divergence'], eps: 1e-7);
      });
    }

    test('Throw on different length', () {
      expect(() => divergence([1], [1, 2, 3]), throwsArgumentError);
      expect(() => divergence([1, 2, 3], [1]), throwsArgumentError);
    });
  });

  Seal seal = Seal('ckks');
  seal.genContext({
    'polyModDegree': 8192,
    'encodeScalar': pow(2, 40),
    'qSizes': [60, 40, 40, 60]
  });
  seal.genKeys();

  group("SEAL CKKS", () {
    for (var config in tests) {
      var {'x': x, 'y': y} = config;
      var encryptX = encryptVecDouble(seal, x);
      var logX = x.map<double>((e) => log(e)).toList();
      var encryptLogX = encryptVecDouble(seal, logX);
      test("Divergence where x:$x y:$y", () {
        near(
            decryptAndSum(seal,
                divergenceOfCiphertextVecDouble(seal, encryptX, encryptLogX, y)),
            config['divergence'],
            eps: 1e-7);
      });

      test("Throw on different length", () {
        expect(() => divergenceOfCiphertextVecDouble(seal, encryptX, encryptLogX, y + [0.0]),
            throwsArgumentError);
      });
    }
  });
}

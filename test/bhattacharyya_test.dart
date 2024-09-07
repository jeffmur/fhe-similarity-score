import 'package:test/test.dart';
import 'package:fhe_similarity_score/bhattacharyya.dart';
import 'test_utils.dart';

void main() {
  List<Map<String, dynamic>> tests = [
    {
      'x': [0.1, 0.2, 0.7],
      'y': [0.1, 0.2, 0.7],
      'coefficent': 1.0
    },
    {
      'x': [0.1, 0.2, 0.7],
      'y': [0.2, 0.3, 0.5],
      'coefficent': 0.9779783088255889
    },
  ];

  group("Plaintext List<Double>", () {
    for (var config in tests) {
      var {'x': x, 'y': y} = config;
      test("coefficent where x:$x y:$y", () {
        near(coefficient(x, y), config['coefficent'], eps: 1e-7);
      });

      test("Symmetric Measure", () {
        expect(coefficient(x, y), coefficient(y, x));
      });
    }
    test('Throw on different length', () {
      expect(() => coefficient([1, 2, 3], [1]), throwsArgumentError);
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
      final sqrtX = x.map<double>((e) => sqrt(e)).toList();
      final sqrtY = y.map<double>((e) => sqrt(e)).toList();
      var encryptSqrtX = encryptVecDouble(seal, sqrtX);
      test("Coefficent where x:$x y:$y", () {
        near(
            decryptedSumOfDoubles(seal,
                coefficientOfCiphertextVecDouble(seal, encryptSqrtX, sqrtY)),
            config['coefficent'],
            eps: 1e-7);
      });

      test("Throw on different length", () {
        expect(() => coefficientOfCiphertextVecDouble(seal, encryptSqrtX, y + [0.0]),
            throwsArgumentError);
      });
    }
  });
}

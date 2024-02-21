import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Post toMap() method', () {
    // Test case 1: Check if the toMap() method produces the expected map
    final post = Post(id: 1, userId: 1, title: 'Test Title', body: 'Test Body');
    final map = post.toMap();
    expect(map, {'id': 1, 'userId': 1, 'title': 'Test Title', 'body': 'Test Body'});

    // Test case 2: Check if toMap() handles different input values
    final postWithDifferentValues = Post(id: 2, userId: 3, title: 'Different Title', body: 'Different Body');
    final differentMap = postWithDifferentValues.toMap();
    expect(differentMap, {'id': 2, 'userId': 3, 'title': 'Different Title', 'body': 'Different Body'});

    // Test case 3: Check if toMap() handles null values
    final postWithNullValues = Post(id: 4, userId: 5, title: null, body: null);
    final nullMap = postWithNullValues.toMap();
    expect(nullMap, {'id': 4, 'userId': 5, 'title': null, 'body': null});
  });
}

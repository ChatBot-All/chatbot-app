
import '../../base.dart';

final homeIndexProvider = StateProvider<int>((ref) {
  return 0;
}, name: "homeIndex");

class Pair<A, B, C> {
  final A first;
  final B second;
  final C last;

  Pair(this.first, this.second, this.last);
}

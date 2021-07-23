import 'package:flutter/scheduler.dart';

class RenliteTicker extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

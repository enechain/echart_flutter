import 'package:collection/collection.dart';
import 'package:echart_flutter/echart_flutter.dart';
import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Sample1 extends StatelessWidget {
  const Sample1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    DateFormat outputFormat = DateFormat('yy-MM-dd');
    return GridView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final spotsList = createSpotsList(spotsNum: 1, length: 5);
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LineChart(
                  data: LineChartData(
                    lineBarsData: spotsList
                        .map((spots) => LineChartBarData(
                              spots: spots,
                              color:
                                  index % 2 == 0 ? Colors.orange : Colors.cyan,
                              point: const LineChartPoint(
                                type: LineChartPointType.circle,
                              ),
                            ))
                        .toList(),
                    area: const LineChartArea(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    runAlignment: WrapAlignment.center,
                    runSpacing: 4,
                    children: spotsList.first
                        .sublist(1, 4)
                        .mapIndexed(
                          (index, spot) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                outputFormat.format(
                                  DateTime(today.year, today.month,
                                      today.day - 5 + spot.x.toInt() + 1),
                                ),
                              ),
                              Text(spot.y.toStringAsFixed(2)),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

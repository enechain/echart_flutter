import 'package:collection/collection.dart';
import 'package:echart_flutter/echart_flutter.dart';
import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _colors = [
  Colors.blueAccent,
  Colors.redAccent,
  Colors.greenAccent,
];

const _labels = [
  'Brent',
  'JCC',
  'HH',
];

const _dataNum = 100;

class Sample2 extends StatefulWidget {
  const Sample2({Key? key}) : super(key: key);

  @override
  State<Sample2> createState() => _Sample2State();
}

class _Sample2State extends State<Sample2> {
  late List<List<LineChartSpot>> spotsList;

  @override
  void initState() {
    setSpotsList();
    super.initState();
  }

  void setSpotsList() {
    setState(() {
      spotsList = createSpotsList(spotsNum: 3, length: _dataNum);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    DateFormat outputFormat = DateFormat('yy-MM-dd');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: LineChart(
            data: LineChartData(
              lineBarsData: spotsList
                  .mapIndexed(
                    (index, spots) => LineChartBarData(
                      spots: spots,
                      color: _colors[index],
                    ),
                  )
                  .toList(),
              xAxis: LineChartXAxis(
                label: LineChartXLabel(
                  texts: spotsList.first
                      .map((spot) => LineChartLabelText(
                          spot.x,
                          outputFormat.format(DateTime(today.year, today.month,
                              today.day - _dataNum + spot.x.toInt() + 1))))
                      .toList(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  rotation: -50,
                  alignment: LineChartXLabelAlignment.spaceAround,
                  count: 5,
                  hideOverflowedLabels: true,
                ),
              ),
              yAxis: LineChartYAxis(
                label: LineChartYLabel(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                grid: LineChartGrid(
                  color: Colors.grey.shade300,
                ),
              ),
              area: LineChartArea(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.all(16),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Colors.white),
            ),
            tooltip: LineChartTooltip(
              builder: (spots) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: Colors.white,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(7),
                            ),
                            color: Colors.white,
                          ),
                          child: Text(
                            outputFormat.format(DateTime(
                                today.year,
                                today.month,
                                today.day -
                                    _dataNum +
                                    spots.first!.x.toInt() +
                                    1)),
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 1,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(7),
                              bottomRight: Radius.circular(7),
                            ),
                          ),
                          child: Column(
                            children: spots.mapIndexed(
                              (index, spot) {
                                return Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _colors[index],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_labels[index]}: ${spot!.y.toStringAsFixed(2)}',
                                    ),
                                  ],
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
            onPressed: () => setSpotsList(), child: const Text('Refresh'))
      ],
    );
  }
}

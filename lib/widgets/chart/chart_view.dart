// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'dart:collection';
import 'dart:math';
import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:fml/helper/common_helpers.dart';
import 'package:fml/helper/time.dart';
import 'package:fml/log/manager.dart';
import 'package:fml/observable/observable_barrel.dart';
import 'package:fml/template/template.dart';
import 'package:fml/widgets/chart/chart_model.dart';
import 'package:fml/widgets/chart/series/chart_series_model.dart';
import 'package:fml/widgets/chart/axis/chart_axis_model.dart';
import 'package:fml/widgets/widget/iWidgetView.dart';
import 'package:fml/widgets/busy/busy_view.dart' as BUSY;
import 'package:fml/widgets/busy/busy_model.dart' as BUSY;
import 'package:community_charts_flutter/community_charts_flutter.dart' as CF;
import 'package:fml/widgets/widget/widget_state.dart';
import 'package:intl/intl.dart';

enum ChartType {
  TimeSeriesChart,
  BarChart,
  OrdinalComboChart,
  NumericComboChart,
  PieChart
}

/// Chart View
///
/// Builds a Chart View using [CHART.ChartModel], [SERIES.ChartSeriesModel], [AXIS.ChartAxisModel] and
/// [EXCERPT.Model] properties
class ChartView extends StatefulWidget implements IWidgetView
{
  final ChartModel model;
  ChartView(this.model) : super(key: ObjectKey(model));

  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends WidgetState<ChartView>
{
  Future<Template>? template;
  Future<ChartModel>? chartViewModel;
  BUSY.BusyView? busy;
  ChartType? chartType;

  @override
  void initState()
  {
    super.initState();
    chartType = getChartType();
  }

  /// Identifies the chart type from the model attributes
  ///
  /// The logic needs to follow a specific ordinal flow here:
  ///  - Check for Date/Time Axis => [ChartType.TimeSeriesChart]
  ///  - Check if all Series are Bar Series => [ChartType.BarChart]
  ///  - Check if the type is `pie` => [ChartType.PieChart]
  ///  - Check if X axis is a Category or Numeric Axis
  ///   => [ChartType.OrdinalComboChart]
  ///   => [ChartType.NumericComboChart]
  ///  We don't support a fallback in the case your axis/series are unmatched
  ///  its important to show the data type syntax for template clarity
  ChartType? getChartType() {
    // This is a bit odd- time series needs to be identified first because if the
    // x axis is a date/time based axis you must use a TimeSeriesChart.
    // You can still have grouped bars in a TimeSeries but not in combo charts.
    // Check for pie type before letting the category axis determine a combo chart.
    if (widget.model.xaxis!.type == ChartAxisType.datetime ||
        widget.model.xaxis!.type == ChartAxisType.date ||
        widget.model.xaxis!.type == ChartAxisType.time) {
      // Determine if the X Axis is time based
      return ChartType.TimeSeriesChart;
    }

    ChartSeriesModel? nonBarSeries = widget.model.series.firstWhereOrNull((series) => series.type != 'bar');
    if (nonBarSeries == null) {
      // Exclusively BarSeries, can use BarChart
      return ChartType.BarChart;
    } else if (widget.model.type != null &&
        (widget.model.type!.toLowerCase() == 'pie' ||
            widget.model.type!.toLowerCase() == 'circle')) {
      return ChartType.PieChart;
    } else if (widget.model.xaxis!.type == ChartAxisType.category) {
      return ChartType.OrdinalComboChart;
    } else if (widget.model.xaxis!.type == ChartAxisType.numeric) {
      return ChartType.NumericComboChart;
    } else {
      Log().warning(
          'Unable to determine the type of chart required from model parameters');
      return null;
    }
  }

  /// Measure/Y Axis Specifications
  CF.NumericAxisSpec yNumericAxisSpec() => CF.NumericAxisSpec(
      tickProviderSpec: CF.BasicNumericTickProviderSpec(zeroBound: false, dataIsInWholeNumbers: false),
      viewport: widget.model.yaxis?.min != null && widget.model.yaxis?.max != null
          ? CF.NumericExtents(S.toNum(widget.model.yaxis!.min!)!, S.toNum(widget.model.yaxis!.max!)!) : null,
      renderSpec: CF.GridlineRendererSpec(
          axisLineStyle: CF.LineStyleSpec(
              color: CF.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          labelStyle: CF.TextStyleSpec(
              fontSize: widget.model.yaxis?.labelvisible == false ? 0 : widget.model.yaxis!.labelsize,
              color: CF.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onBackground)),
          // lineStyle: CF.LineStyleSpec(
          //   dashPattern: [4, 4])
      ),
  );

  CF.NumericAxisSpec xNumComboAxisSpec() => CF.NumericAxisSpec(
      tickProviderSpec: CF.BasicNumericTickProviderSpec(dataIsInWholeNumbers: false),
      viewport: widget.model.yaxis?.min != null && widget.model.yaxis?.max != null
          ? CF.NumericExtents(S.toNum(widget.model.yaxis!.min!)!, S.toNum(widget.model.yaxis!.max!)!) : null,
      renderSpec: CF.SmallTickRendererSpec(
        axisLineStyle: CF.LineStyleSpec(
            color: CF.ColorUtil.fromDartColor(
                Theme.of(context).colorScheme.onBackground)),
        labelStyle: CF.TextStyleSpec(
            fontSize: widget.model.xaxis?.labelvisible == false ? 0 : widget.model.xaxis!.labelsize,
            color: CF.ColorUtil.fromDartColor(
                Theme.of(context).colorScheme.onBackground)),
        labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
        labelOffsetFromAxisPx:
        (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
            .ceil() +
            8, // 80 is rough estimate of our text length
      ),
  );

  CF.AxisSpec<String> xStringAxisSpec() => CF.AxisSpec<String>(
    renderSpec: CF.SmallTickRendererSpec(
      axisLineStyle: CF.LineStyleSpec(
          color: CF.ColorUtil.fromDartColor(
              Theme.of(context).colorScheme.onBackground)),
      labelStyle: CF.TextStyleSpec(
          fontSize: widget.model.xaxis?.labelvisible == false ? 0 : widget.model.xaxis!.labelsize,
          color: CF.ColorUtil.fromDartColor(
              Theme.of(context).colorScheme.onBackground)),
      labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
      labelOffsetFromAxisPx:
      (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
          .ceil() +
          (widget.model.horizontal == true
              ? 28
              : 8), // 80 is rough estimate of our text length
    ),
  );

  CF.AxisSpec<DateTime> xDateTimeAxisSpec(List<CF.TickSpec<DateTime>> ticks) {
    return CF.DateTimeAxisSpec(
      renderSpec: CF.SmallTickRendererSpec(
        axisLineStyle: CF.LineStyleSpec(
            color: CF.ColorUtil.fromDartColor(
                Theme.of(context).colorScheme.onBackground)),
        labelAnchor: CF.TickLabelAnchor.after,
        labelStyle: CF.TextStyleSpec(
            fontSize: widget.model.xaxis?.labelvisible == false ? 0 : widget.model.xaxis!.labelsize,
            color: CF.ColorUtil.fromDartColor(
                Theme.of(context).colorScheme.onBackground)),
        labelRotation: widget.model.xaxis!.labelrotation.abs() * -1,
        labelOffsetFromAxisPx:
        (sin(widget.model.xaxis!.labelrotation.abs() * (pi / 180)) * 80)
            .ceil() +
            8, // 80 is rough estimate of our text length
      ),
      tickProviderSpec: CF.StaticDateTimeTickProviderSpec(ticks),
    );
  }

  List<CF.TickSpec<DateTime>> dateTimeTickBuilder(
      List<DateTime> tickData, {String? interval, String? format}) {
    // Axis Ticks
    List<CF.TickSpec<DateTime>> ticks = [];
    // Utilize a TUD to define our interval
    TimeUnitDuration tud = DT.getTUDurationFromString(interval ?? '0');

    // Check if we need to draw interval ticks/ have enough data to display the interval
    if (tud.amount == 0 || tickData.length < 2) {
      for (DateTime v in tickData) {
        ticks.add(CF.TickSpec(v, label: format != null
                    ? DT.formatDateTime(v, format)
                    : null));
      }
      return ticks;
    }

    // Build the interval ticks with min/max and every interval between
    DateTime firstTick = tickData.first;
    DateTime lastTick = tickData.last;
    // ensure min is <= max
    if (DT.isAfter(firstTick, lastTick)) {
      firstTick = lastTick;
    }
    // Establish the axis bounds based on the min/max and the interval
    firstTick = DT.floor(firstTick, tud.timeUnit);
    lastTick = DT.ceil(lastTick, tud.timeUnit);
    // Set the first tick to min DateTime
    DateTime tick = firstTick;
    // Add all the interval ticks starting at min
    while(DT.isBefore(tick, lastTick)) {
      ticks.add(CF.TickSpec(tick, label: format != null ? DT.formatDateTime(tick, format) : null));
      tick = DT.add(tick, tud);
    }
    // Add the last (max) DateTime tick
    ticks.add(CF.TickSpec(lastTick, label: format != null ? DT.formatDateTime(lastTick, format) : null));

    return ticks;
  }

  CF.BarChart buildBarChart(List<CF.Series<dynamic, String>> series) {
    // Determine if there is any grouping and/or stacking (grouped/stacked/groupedStacked)
    CF.BarGroupingType barGroupingType;
    ChartSeriesModel seriesModel = widget.model.series[0];
    // Based on the series if the series have both a group and stack, or neither,
    // but are only a single series set bargrouping to groupedStacked

    if ((seriesModel.group != null && seriesModel.stack != null) ||
        (seriesModel.group == null &&
            seriesModel.stack == null &&
            series.length == 1)) {
      barGroupingType = CF.BarGroupingType.groupedStacked;
    } else if (seriesModel.group != null) {
      barGroupingType = CF.BarGroupingType.grouped;
    } else if (seriesModel.stack != null) {
      barGroupingType = CF.BarGroupingType.stacked;
    } else {
      barGroupingType = CF.BarGroupingType.grouped;
    }

    List<CF.SeriesRendererConfig<String>> seriesRenderers = [];
    for (var s in widget.model.series) {
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      CF.SeriesRendererConfig<String> config = configFunc(s);
      seriesRenderers.add(config);
    }

    return CF.BarChart(
      series,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      primaryMeasureAxis: yNumericAxisSpec(),
      domainAxis: xStringAxisSpec(),
      barGroupingType: barGroupingType,
      vertical: widget.model.horizontal == true ? false : true,
      // barRendererDecorator: CF.BarLabelDecorator<String>(labelPosition: CF.BarLabelPosition.inside, labelAnchor: CF.BarLabelAnchor.middle),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        CF.SelectionModelConfig(
          type: CF.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  CF.NumericComboChart buildNumericChart(List<CF.Series> series) {
    List<CF.SeriesRendererConfig<num>> seriesRenderers = [];
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null)
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      CF.SeriesRendererConfig<num> config = configFunc(s);
      seriesRenderers.add(config);
    }
    return CF.NumericComboChart(
      series as List<Series<dynamic, num>>,
      animate: widget.model.animated,
      behaviors: getBehaviors<num>(),
      primaryMeasureAxis: yNumericAxisSpec(),
      domainAxis: xNumComboAxisSpec(),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        CF.SelectionModelConfig(
          type: CF.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  CF.OrdinalComboChart buildOrdinalChart(List<CF.Series> series) {
    List<CF.SeriesRendererConfig<String>> seriesRenderers = [];
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null)
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis!.type)!;
      CF.SeriesRendererConfig<String> config = configFunc(s);
      seriesRenderers.add(config);
    }
    return CF.OrdinalComboChart(
      series as List<Series<dynamic, String>>,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      primaryMeasureAxis: yNumericAxisSpec(),
      domainAxis: xStringAxisSpec(),
      customSeriesRenderers: seriesRenderers,
      selectionModels: [
        CF.SelectionModelConfig(
          type: CF.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  CF.TimeSeriesChart buildTimeChart(List<CF.Series> series) {
    List<CF.SeriesRendererConfig<DateTime>> seriesRenderers = [];
    List<CF.TickSpec<DateTime>> ticks = [];
    SplayTreeMap<int, DateTime> ticksMap = SplayTreeMap<int, DateTime>();

    // get x values for all series to determine min and max values
    for (var s in widget.model.series) {
      if (s.type == 'bar' && s.stack != null)
        Log().warning(
            'Stacked Bar Series are only compatible with Category type X Axis and each series must be type="bar"');
      Function configFunc = getSeriesRenderer(s, widget.model.xaxis?.type ?? ChartAxisType.datetime);
      CF.SeriesRendererConfig<DateTime> config = configFunc(s);
      seriesRenderers.add(config);
      // Map all the x values for the ticks
      for (ChartDataPoint x in s.dataPoint) {
        DateTime? xDateTime = S.toDate(x.x);
        if (xDateTime != null) {
          int epoch = xDateTime.toUtc().millisecondsSinceEpoch;
          // Ignore date/time data ticks before the min datetime on the x axis
          if (widget.model.xaxis?.min != null
              && DT.isBefore(xDateTime, S.toDate(widget.model.xaxis!.min!)!))
            continue;
          // Ignore date/time data ticks after the max datetime on the x axis
          if (widget.model.xaxis?.max != null
              && DT.isAfter(xDateTime, S.toDate(widget.model.xaxis!.max!)!))
            continue;
          ticksMap[epoch] = xDateTime;
        } else {
          Log().warning(
              '${x.x.toString()} is not a DateTime value in the ${s.name.toString()} TimeSeries');
        }
      }
    }
    ticks = dateTimeTickBuilder(ticksMap.entries.map((entry) => entry.value).toList(),
        interval: widget.model.xaxis?.interval.toString().trim(),
        format: widget.model.xaxis?.format);

    return CF.TimeSeriesChart(
      series as List<Series<dynamic, DateTime>>,
      animate: widget.model.animated,
      customSeriesRenderers: seriesRenderers,
      behaviors: getBehaviors<DateTime>(),
      primaryMeasureAxis: yNumericAxisSpec(),
      domainAxis: xDateTimeAxisSpec(ticks),
      selectionModels: [
        CF.SelectionModelConfig(
          type: CF.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  CF.PieChart buildPieChart(List<CF.Series<dynamic, String>> series) {
    return CF.PieChart<String>(
      series,
      animate: widget.model.animated,
      behaviors: getBehaviors<String>(),
      defaultRenderer: CF.ArcRendererConfig(arcRendererDecorators: [
        CF.ArcLabelDecorator(labelPosition: CF.ArcLabelPosition.auto)
      ]),
      selectionModels: [
        CF.SelectionModelConfig(
          type: CF.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  /// Series Builder
  List<CF.Series>? buildSeriesList() {
    // Setup a list of series for each X Axis type
    List<CF.Series<dynamic, DateTime>> timeSeriesList = [];
    List<CF.Series<dynamic, num>> numericSeriesList = [];
    List<CF.Series<dynamic, String>> categorySeriesList = [];
    if (widget.model.xaxis == null || widget.model.yaxis == null) {
      Log().error(
          'Unable to build series list because of a null axis, x: ${widget.model.xaxis.toString()} y: ${widget.model.yaxis.toString()}');
      return null;
    }
    bool pureBar = false;

    ChartSeriesModel? nonBarSeries =
        widget.model.series.firstWhereOrNull((series) => series.type != 'bar');
    if (nonBarSeries == null) // Exclusively BarSeries
      pureBar = true;
    // Loop through each series
    for (ChartSeriesModel series in widget.model.series) {
      // Auto group bar series if not specified
      if ((series.stack == null ||
              widget.model.xaxis!.type != ChartAxisType.category) &&
          series.group == null &&
          pureBar == true) series.group = 'defaultgrouping';
      // Build the data points
      List<ChartDataPoint> seriesData = [];
      bool xAllNull = true;
      bool yAllNull = true;
      // Loop through each point
      for (ChartDataPoint point in series.dataPoint) {
        // Parse x and y data values from the databroker string values
        if (!S.isNullOrEmpty(point.x)) {
          // y value can be null, creating a gap in the chart
          var xParsed;
          var yParsed;
          try {
            xParsed = parsePlotPoint(point.x, widget.model.xaxis!.type);
          } catch(e) {
            Log().error(
                'Unable to parse X axis plot point, chart id: ${widget.model.id.toString()} - series name: ${series.name.toString()} - ' +
                    e.toString());
            break;
          }
          try {
            yParsed = S.isNullOrEmpty(point.y)
                ? null
                : parsePlotPoint(point.y, widget.model.yaxis!.type);
          } catch(e) {
            Log().error(
                'Unable to parse Y axis plot point, chart id: ${widget.model.id.toString()} - series name: ${series.name.toString()} - ' +
                    e.toString());
            break;
          }
          // Parsed Values
          var xVal = xParsed;
          var yVal = yParsed;
          // Null Series Point Check
          if (xAllNull == true) xAllNull = xVal == null;
          if (yAllNull == true) yAllNull = yVal == null;
          // Ignore date/time data points before the min datetime on the x axis
          if ((widget.model.xaxis!.type == ChartAxisType.datetime ||
              widget.model.xaxis!.type == ChartAxisType.date ||
              widget.model.xaxis!.type == ChartAxisType.time) &&
              widget.model.xaxis?.min != null && xVal != null
              && DT.isBefore(xVal, S.toDate(widget.model.xaxis!.min!)!))
            continue;
          // Ignore date/time data points after the max datetime on the x axis
          if ((widget.model.xaxis!.type == ChartAxisType.datetime ||
              widget.model.xaxis!.type == ChartAxisType.date ||
              widget.model.xaxis!.type == ChartAxisType.time) &&
              widget.model.xaxis?.max != null && xVal != null
              && DT.isAfter(xVal, S.toDate(widget.model.xaxis!.max!)!))
            continue;
          // get label
          var label = S.isNullOrEmpty(point.label) ? null : point.label.trim();
          // Add to point list
          if (xVal != null && (series.labelled != true || label != null))
            seriesData.add(ChartDataPoint(
                x: xVal, y: yVal, color: point.color, label: label));
          if (xVal == null)
            Log().warning(
                'id: ${series.id.toString()} name: ${series.name.toString()} Has a null X value, only Y vals can be null, every point must have a non-null X value');
        }
      }

      // Null Series Warning
      //if (xAllNull) Log().warning('id: ${series.id.toString()} name: ${series.name.toString()} X values are all null');
      //if (yAllNull) Log().warning('id: ${series.id.toString()} name: ${series.name.toString()} Y values are all null');

      switch (widget.model.xaxis!.type) {
        // Date/Time based X Axis
        case ChartAxisType.datetime:
        case ChartAxisType.date:
        case ChartAxisType.time:
          timeSeriesList.add(CF.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              // seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) => CF.ColorUtil.fromDartColor(
                  (plot.color ?? series.color)?.withOpacity(0.1) ??
                      Colors.black12),
              colorFn: (dynamic plot, _) => CF.ColorUtil.fromDartColor(
                  plot.color ??
                      series.color ??
                      (ColorObservable.niceColors.length > _!
                          ? ColorObservable.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  '${plot.label ?? (plot.y > 0 ? plot.y : '')}', // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(CF.rendererIdKey, getRendererKey(series)));
          break;
        // Numeric based X axis
        case ChartAxisType.numeric:
          numericSeriesList.add(CF.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              // seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) => CF.ColorUtil.fromDartColor(
                  (plot.color ?? series.color)?.withOpacity(0.1) ??
                      Colors.black12),
              colorFn: (dynamic plot, _) => CF.ColorUtil.fromDartColor(
                  plot.color ??
                      series.color ??
                      (ColorObservable.niceColors.length > _!
                          ? ColorObservable.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  '${plot.label ?? (plot.y > 0 ? plot.y : '')}', // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(CF.rendererIdKey, getRendererKey(series)));
          break;
        // Category/String based X axis
        case ChartAxisType.category:
          categorySeriesList.add(CF.Series(
              id: series.id,
              displayName: series.name ?? series.id,
              seriesCategory: series.stack,
              areaColorFn: (dynamic plot, _) => CF.ColorUtil.fromDartColor(
                  (plot.color ?? series.color)?.withOpacity(0.1) ??
                      Colors.black12),
              colorFn: (dynamic plot, _) => CF.ColorUtil.fromDartColor(
                  plot.color ??
                      series.color ??
                      (ColorObservable.niceColors.length > _!
                          ? ColorObservable.niceColors[_]!
                          : Colors.black)),
              domainFn: (dynamic plot, _) => plot.x,
              measureFn: (dynamic plot, _) => plot.y,
              labelAccessorFn: (dynamic plot, _) =>
                  '${plot.label ?? (plot.y > 0 ? plot.y : '')}', // Unavailable outside of pie/bar charts
              data: seriesData)
            ..setAttribute(CF.rendererIdKey, getRendererKey(series)));
          break;
        default:
          Log().warning(
              'Unable to determine Chart Series for id: ${widget.model.id}');
          break;
      }
    }
    // We return the series of the correct data type here
    switch (widget.model.xaxis!.type) {
      case ChartAxisType.datetime:
      case ChartAxisType.date:
      case ChartAxisType.time:
        return timeSeriesList;
      case ChartAxisType.numeric:
        return numericSeriesList;
      case ChartAxisType.category:
        return categorySeriesList;
      default:
        return null;
    }
  }

  /// Unique id for each series based off the FML id, fallback on the name attribute
  /// Importantly bar charts that have a group attribute must share the same render key
  String? getRendererKey(ChartSeriesModel series) {
    if (chartType == ChartType.BarChart || chartType == ChartType.PieChart)
      return null;
    return (series.type == 'bar' ? series.group : null) ?? series.id;
  }

  /// Parser for databroker data to convert it from a String to appropriate data type for the axis
  dynamic parsePlotPoint(String? val, ChartAxisType type) {
    if (type == ChartAxisType.category) {
      return val;
    } else if (type == ChartAxisType.numeric) {
      return num.tryParse(val!) ?? 0;
    } else if (type == ChartAxisType.date ||
        type == ChartAxisType.time ||
        type == ChartAxisType.datetime) {
      DateTime? formatted;
      formatted = S.toDate(val); //, format: 'yMd Hm');
      return formatted; //DateTime.tryParse(val);
    }
  }

  /// Each series needs a specific type of renderer, this method passes back a
  /// function that builds the specific type needed with the correct attributes
  Function getSeriesRenderer(ChartSeriesModel series, ChartAxisType? type) {
    dynamic rendererConfig;
    // if (chartType == ChartType.BarChart)
    //   type = 'category';
    switch (series.type) {
      case 'bar':
        if (type == ChartAxisType.category)
          rendererConfig = buildCategoryBarRenderer;
        else if (type == ChartAxisType.datetime ||
            type == ChartAxisType.date ||
            type == ChartAxisType.time)
          rendererConfig = buildDateTimeBarRenderer;
        else if (type == ChartAxisType.numeric)
          rendererConfig = buildNumericBarRenderer;
        break;
      case 'line':
        if (type == ChartAxisType.category)
          rendererConfig = buildCategoryLineRenderer;
        else if (type == ChartAxisType.datetime ||
            type == ChartAxisType.date ||
            type == ChartAxisType.time)
          rendererConfig = buildDateTimeLineRenderer;
        else if (type == ChartAxisType.numeric)
          rendererConfig = buildNumericLineRenderer;
        break;
      case 'point':
        if (type == ChartAxisType.category)
          rendererConfig = buildCategoryPointRenderer;
        else if (type == ChartAxisType.datetime ||
            type == ChartAxisType.date ||
            type == ChartAxisType.time)
          rendererConfig = buildDateTimePointRenderer;
        else if (type == ChartAxisType.numeric)
          rendererConfig = buildNumericPointRenderer;
        break;
    }
    return rendererConfig;
  }

  CF.SeriesRendererConfig<String> buildCategoryBarRenderer(
      ChartSeriesModel series) {
    return CF.BarRendererConfig(
      customRendererId: series.group ?? series.id,
    );
  }

  CF.SeriesRendererConfig<DateTime> buildDateTimeBarRenderer(
      ChartSeriesModel series) {
    return CF.BarRendererConfig(customRendererId: series.group ?? series.id);
  }

  CF.SeriesRendererConfig<num> buildNumericBarRenderer(
      ChartSeriesModel series) {
    return CF.BarRendererConfig(
      customRendererId: series.group ?? series.id,
    );
  }

  CF.SeriesRendererConfig<String> buildCategoryLineRenderer(
      ChartSeriesModel series) {
    return CF.LineRendererConfig(
        customRendererId: series.id,
        includeLine: series.showline,
        includePoints: series.showpoints,
        includeArea: series.showarea,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 2);
  }

  CF.SeriesRendererConfig<DateTime> buildDateTimeLineRenderer(
      ChartSeriesModel series) {
    return CF.LineRendererConfig(
        customRendererId: series.id,
        includeLine: series.showline,
        includePoints: series.showpoints,
        includeArea: series.showarea,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 2);
  }

  CF.SeriesRendererConfig<num> buildNumericLineRenderer(
      ChartSeriesModel series) {
    return CF.LineRendererConfig(
        customRendererId: series.id,
        includeLine: series.showline,
        includePoints: series.showpoints,
        includeArea: series.showarea,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 2);
  }

  CF.SeriesRendererConfig<String> buildCategoryPointRenderer(
      ChartSeriesModel series) {
    return CF.PointRendererConfig(
        customRendererId: series.id,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 0);
  }

  CF.SeriesRendererConfig<DateTime> buildDateTimePointRenderer(
      ChartSeriesModel series) {
    return CF.PointRendererConfig(
        customRendererId: series.id,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 0);
  }

  CF.SeriesRendererConfig<num> buildNumericPointRenderer(
      ChartSeriesModel series) {
    return CF.PointRendererConfig(
        customRendererId: series.id,
        radiusPx: series.radius,
        strokeWidthPx: series.stroke ?? 0);
  }

  /// Event called when a point selection changes
  _onSelectionChanged(CF.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    dynamic domain;
    dynamic selectedSeriesId;

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    if (selectedDatum.isNotEmpty) {
      try {
        domain = selectedDatum.first.datum.x;
        selectedSeriesId = selectedDatum.first.series.id;
        // measure = selectedDatum.first.datum.y; // Not accurate with multi series as it doesn't know which series you selected
        // Get the series model by matching to the selected series id
        ChartSeriesModel? selectedSeries = widget.model.series
            .firstWhereOrNull((s) => s.id == selectedSeriesId);
        if (selectedSeries != null && selectedDatum.length > 0)
          // Loop through the selected series datum
          for (int i = 0; i < selectedDatum[0].series.data.length; i++) {
            // Match the selected x value to the selected series, set the
            //model.selected observable for binding to the data point and stop looping
            if (selectedDatum[0].series.data[i].x == domain) {
              Map seriesData = selectedSeries.data[i];
              // We also add the series id to the data set
              seriesData['series'] = selectedSeriesId;
              widget.model.selected = seriesData;
              break;
            }
          }
      } catch(e) {
        Log().warning(
            'Unable to set Chart Series Point selection' + e.toString());
      }
    }
    // print('Approximate Series Clicked on [${selectedSeriesId}]: x: ${domain.toString()}, y: ${measure.toString()}'); // Only works for single series
    // measures.forEach((key, value) {
    //   print('key: ${key.toString()}, x: ${domain.toString()}, y: ${measure.toString()}');
    // });
    // print(widget.model.selected[0]?.join(','));
  }

  /// Returns additional chart behaviors based on model settings
  List<CF.ChartBehavior<T>> getBehaviors<T>() {
    List<CF.ChartBehavior<T>> behaviors = [];
    if (chartType != ChartType.PieChart) behaviors.add(CF.PanAndZoomBehavior());
    if (widget.model.showlegend != 'false' && chartType != ChartType.PieChart)
      behaviors.add(
          CF.SeriesLegend(
              position: legendPosition(widget.model.showlegend,),
              entryTextStyle: CF.TextStyleSpec(
                fontSize: widget.model.legendsize,
                color: CF.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}')),
          ));
    if (widget.model.showlegend != 'false' && chartType == ChartType.PieChart)
      behaviors.add(CF.DatumLegend(
        position: legendPosition(widget.model.showlegend),
        entryTextStyle: CF.TextStyleSpec(
          color: CF.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
        ),
        outsideJustification: CF.OutsideJustification.middleDrawArea,
        horizontalFirst: true,
        desiredMaxColumns: 4,
        cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0),
      ));
    if (widget.model.xaxis!.title != null)
      behaviors.add(CF.ChartTitle(widget.model.xaxis!.title!,
          titleStyleSpec: CF.TextStyleSpec(
            color: CF.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
          ),
          behaviorPosition: widget.model.horizontal == true
              ? CF.BehaviorPosition.start
              : CF.BehaviorPosition.bottom,
          titleOutsideJustification: CF.OutsideJustification.middleDrawArea));
    if (widget.model.yaxis!.title != null)
      behaviors.add(CF.ChartTitle(widget.model.yaxis!.title!,
          titleStyleSpec: CF.TextStyleSpec(
            color: CF.Color.fromHex(code: '#${Theme.of(context).colorScheme.onBackground.value.toRadixString(16).toString().substring(2)}'),
          ),
          behaviorPosition: widget.model.horizontal == true
              ? CF.BehaviorPosition.bottom
              : CF.BehaviorPosition.start,
          titleOutsideJustification: CF.OutsideJustification.middleDrawArea));
    return behaviors;
  }

  // Gets the legend position based on the model string
  CF.BehaviorPosition legendPosition(String? pos) {
    switch (pos) {
      case 'left':
      case 'start':
        return CF.BehaviorPosition.start;
      case 'right':
      case 'end':
        return CF.BehaviorPosition.end;
      case 'top':
        return CF.BehaviorPosition.top;
      case 'bottom':
      case 'true':
      default:
        return CF.BehaviorPosition.bottom;
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);

  Widget builder(BuildContext context, BoxConstraints constraints)
  {
    // save system constraints
    onLayout(constraints);

    // Check if widget is visible before wasting resources on building it
    if (!widget.model.visible) return Offstage();

    // Busy / Loading Indicator
    if (busy == null) busy = BUSY.BusyView(BUSY.BusyModel(widget.model, visible: widget.model.busy, observable: widget.model.busyObservable));

    Widget view;

    // get the children
    List<Widget> children = widget.model.inflate();

    chartType = getChartType();
    List<CF.Series>? series = buildSeriesList();

    try {
      switch (chartType) {
        case ChartType.BarChart:
          view = buildBarChart(series as List<Series<dynamic, String>>);
          break;
        case ChartType.NumericComboChart:
          view = buildNumericChart(series!);
          break;
        case ChartType.OrdinalComboChart:
          view = buildOrdinalChart(series!);
          break;
        case ChartType.PieChart:
          view = buildPieChart((series as List<CF.Series<dynamic, String>>));
          break;
        case ChartType.TimeSeriesChart:
          view = buildTimeChart(series!);
          break;
        default:
          view = Center(child: Icon(Icons.add_chart));
      }
    } catch(e) {
      Log().exception(e, caller: 'chart_view builder() ');
      view = Center(child: Icon(Icons.add_chart));
    }

    // Prioritize chart ux interactions
    view = Listener(behavior: HitTestBehavior.opaque, child: view);
    view = SafeArea(child: view);
    children.insert(0, SafeArea(child: view));

    // add busy
    children.add(Center(child: busy));

    // Display children over chart
    view = Stack(children: children);

    // add margins
    view = addMargins(view);

    // apply user defined constraints
    view = applyConstraints(view, widget.model.constraints.tightestOrDefault);

    return view;
  }
}

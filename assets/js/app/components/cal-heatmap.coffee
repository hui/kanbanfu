KanbanFu.CalHeatmapComponent = Ember.Component.extend
  dataChange: (()->
    @renderChart()
  ).observes("data")

  didInsertElement: ()->
    @renderChart()

  renderChart: ()->
    return unless @get("data")?

    cal = new CalHeatMap()
    cal.init start: moment().subtract('days', 9).toDate(), itemSelector: "##{@get("element").id} .cal-heatmap", domain:'day', subDomain:'x_hour', range:10, tooltip: true, data: @get("data"), cellSize: 12, legendCellSize: 12, domainGutter: 8, displayLegend: false
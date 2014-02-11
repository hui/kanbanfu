KanbanFu.StackedAreaChartComponent = Ember.Component.extend
  dataChange: (()->
    @renderChart()
  ).observes("data")

  didInsertElement: ()->
    @renderChart()

  renderChart: ()->
    return unless @get("data")?

    nv.addGraph () =>
      chart = nv.models.stackedAreaChart().x((d)->
        return d[0]
      ).y((d)->
        return d[1]
      ).clipEdge(true).showControls(false)

      chart.xAxis.tickFormat (d)->
        d3.time.format('%m-%d')(new Date(d))
      chart.yAxis.tickFormat(d3.format(',.0f'))

      d3.select("##{@get("element").id} .chart svg").datum(@get("data")).transition().duration(500).call(chart)
      nv.utils.windowResize(chart.update)

      chart
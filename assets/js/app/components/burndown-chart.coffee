KanbanFu.BurndownChartComponent = Ember.Component.extend
  dataChange: (()->
    @renderChart()
  ).observes("data")

  didInsertElement: ()->
    @renderChart()

  renderChart: ()->
    return unless @get("data")?

    nv.addGraph () =>
      data = @get("data")
      chart = nv.models.lineChart().x((d, i)->
        return d[0]
      ).y((d, i)->
        return d[1]
      )

      chart.lines.forceY([0])

      chart.xAxis.tickFormat (d)->
        d3.time.format('%m-%d')(new Date(d))
      chart.yAxis.tickFormat(d3.format('d'))

      d3.select("##{@get("element").id} .chart svg").datum(data).transition().duration(500).call(chart)
      nv.utils.windowResize(chart.update)

      chart
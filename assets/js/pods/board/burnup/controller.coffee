KanbanFu.BoardBurnupController = Ember.Controller.extend
  needs: ["board"]
  board: Ember.computed.alias("controllers.board")

  totalCardsByDayData: (() ->
    checkedLabels = @get('board.labels').filterBy('checked', true).map (item)->
      item.label
    checkedLists = @get('board.trelloLists').filterBy('checked', true).map (item)->
      item.id

    totalData = @get("board.totalCardsByDay").map (item)=>
      cards = item.cards.filter (card, index, self)=>
        idList = card.currentList
        labels = @get("board.cards")[card.id].labels.map (item)->
          item.color

        if checkedLabels.length > 0
            if checkedLabels.every((label, index, self)=>
                labels.contains label
              )

              return true

          else
            return true

      [moment(item.date), cards.length]

    remainingData = @get("board.totalCardsByDay").map (item, index)=>
      cards = item.cards.filter (card, index, self)=>
        idList = card.currentList
        labels = @get("board.cards")[card.id].labels.map (item)->
          item.color
        unless checkedLists.contains(idList)
          if checkedLabels.length > 0
            if checkedLabels.every((label, index, self)=>
                labels.contains label
              )

              return true

          else
            return true

      [moment(item.date), cards.length]

    finishData = @get("board.totalCardsByDay").map (item, index)=>
      [moment(item.date), totalData[index][1] - remainingData[index][1]]

    [ {key: 'Total Cards', values: totalData, color: '#00CBE7'}, {key: 'Finished Cards', values: finishData, color: '#00DA3C'}, {key: 'Remaining Cards', values: remainingData, color: '#DF151A'} ]
  ).property("board.labels.@each.checked", "board.trelloLists.@each.checked")
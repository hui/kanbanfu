KanbanFu.BoardBurndownController = Ember.Controller.extend
  needs: ["board"]
  board: Ember.computed.alias("controllers.board")

  buildBurndown: (() ->
    checkedLabels = @get('board.labels').filterBy('checked', true)
    checkedLists = @get('board.trelloLists').filterBy('checked', true)

    return unless checkedLabels.length > 0 && checkedLists.length > 0

    console.log checkedLists, checkedLabels
  ).observes("board.labels.@each.checked", "board.trelloLists.@each.checked")
KanbanFu.BoardHeatController = Ember.Controller.extend
  needs: ["board"]
  board: Ember.computed.alias("controllers.board")

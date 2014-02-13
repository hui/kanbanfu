KanbanFu.BoardIndexController = Ember.Controller.extend
  needs: ["board"]
  board: Ember.computed.alias("controllers.board")

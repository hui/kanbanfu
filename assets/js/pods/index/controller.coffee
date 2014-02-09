KanbanFu.IndexController = Ember.ObjectController.extend
  needs: ["currentMember"]
  currentMember: Ember.computed.alias("controllers.currentMember")
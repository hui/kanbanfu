KanbanFu.IndexRoute = Ember.Route.extend
  setupController: (controller, model) ->
    Trello.authorize interactive: false, name: "KanbanFu.com", success: () =>
      @controllerFor("currentMember").login()
    , error: () ->
      console.log "error"

KanbanFu.ApplicationController = Ember.Controller.extend
  needs: ["currentMember"]
  currentMember: Ember.computed.alias("controllers.currentMember")

  actions:
    login: ->
      Trello.authorize type: "popup", name: "KanbanFu.com", scope: { write: true, read: true }, expiration: 'never', success: =>
        @get("currentMember").login()

    logout: ->
      Trello.deauthorize()
      @get("currentMember").logout()
KanbanFu.ApplicationController = Ember.Controller.extend
  needs: ["currentMember"]
  currentMember: Ember.computed.alias("controllers.currentMember")

  actions:
    login: ->
      currentMember = @get "currentMember"
      Trello.authorize(type: "popup", success: =>
        currentMember.login()
      , name: "KanbanFu.com", scope: { write: true, read: true })

    logout: ->
      Trello.deauthorize()
      currentMember = @get "currentMember"
      currentMember.logout()
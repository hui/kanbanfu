KanbanFu.CurrentMemberController = Ember.ObjectController.extend
  authorized: false
  content: null

  login: ->
    Trello.members.get "me", (member) =>
      @set "authorized", true
      @set "content", member

  logout: ->
    @set 'authorized', false
    @set 'content', null

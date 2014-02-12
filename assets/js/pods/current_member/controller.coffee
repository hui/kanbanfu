KanbanFu.CurrentMemberController = Ember.ObjectController.extend
  authorized: false
  content: null

  login: ->
    Trello.members.get "me", (member) =>
      @set "authorized", true
      @set "content", member
    , (error) =>
      Trello.deauthorize()
      @logout()

  logout: ->
    @set 'authorized', false
    @set 'content', null
    @transitionToRoute "/"

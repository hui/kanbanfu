#= require jquery
#= require bootstrap
#= require handlebars-1.1.2
#= require ember-1.3.2
#= require ember-data
#= require templates
#= require_self
#= require_tree .

window.KanbanFu = Ember.Application.create()
KanbanFu.Router.map ()->
  @resource 'boards', path: '/boards'
  @resource 'board', path: '/board/:board_id'

KanbanFu.LoadingRoute = Ember.Route.extend
  activate: ->
    @_super()
    Pace.restart()

  deactivate: ->
    @_super()
    Pace.stop()

KanbanFu.AuthorizedRoute = Ember.Route.extend
  beforeModel: ()->
    unless Trello.authorized()
      new Ember.RSVP.Promise (resolve)=>
        Trello.authorize interactive: false, name: "KanbanFu.com", success: () =>
          new Ember.RSVP.Promise (resolve)=>
            @controllerFor("currentMember").login()
            resolve(true)
          resolve(Trello.authorized())
        , error: () =>
          @transitionTo "/"
          resolve(false)
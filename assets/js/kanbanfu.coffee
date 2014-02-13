#= require templates
#= require_self
#= require_tree .

window.paceOptions = { ajax: true }

window.KanbanFu = Ember.Application.create()
KanbanFu.Router.map ()->
  @resource 'boards', path: '/boards'
  @resource 'board', path: '/board/:board_id', () ->
    @route 'burndown'
    @route 'cumulative'
    @route 'heat'

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
          Trello.deauthorize()
          @transitionTo "/"
          resolve(false)

Ember.Handlebars.helper 'timeAgo', (value, options) ->
  return moment(value).fromNow()

Ember.Handlebars.helper 'calendarTime', (value, options) ->
  return moment(value).calendar()

Ember.Handlebars.helper 'cardSizeList', (value, options) ->
  html = ""
  for list in options
    html += "<td>#{value[list.name]}</td>"
  return new Handlebars.SafeString(html)

$ ->
  $("#loadingJS").hide()
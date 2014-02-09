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
  @resource('boards', path: '/boards')

$ ->
  # Trello.get "members/me/boards", filter: 'open', (boards) ->

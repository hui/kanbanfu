#= require jquery
#= require bootstrap
#= require_tree .

$ ->
  onAuthorize = () ->
    updateLoggedIn()
    $("#output").empty()
    cardsBox = $("<div>").text("Loading...").appendTo("#output")

    Trello.members.get "me", (member) ->
      $("#fullName").text(member.fullName)
      Trello.get "members/me/boards", filter: 'open', (boards) ->
        cardsBox.empty()
        console.log boards

  updateLoggedIn = () ->
    isLoggedIn = Trello.authorized()
    console.log isLoggedIn
    $("#loggedout").toggle(!isLoggedIn)
    $("#loggedin").toggle(isLoggedIn)

  logout = () ->
    Trello.deauthorize()
    updateLoggedIn()

  onError = () ->
    updateLoggedIn()

  Trello.authorize interactive: false, success: onAuthorize, error: onError, name: "KanbanFu.com"

  $("#connectLink").bind 'click', () ->
    Trello.authorize(type: "popup", success: onAuthorize, name: "KanbanFu.com", scope: { write: true, read: true })

  $("#disconnect").bind 'click', logout
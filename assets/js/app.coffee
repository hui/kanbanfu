#= require_tree .

onAuthorize = () ->
  updateLoggedIn()
  $("#output").empty()
  cardsBox = $("<div>").text("Loading...").appendTo("#output")

  Trello.members.get "me", (member) ->
    $("#fullName").text(member.fullName)
    Trello.get "members/me/cards", (cards) ->
      cardsBox.empty()
      console.log cards

updateLoggedIn = () ->
    isLoggedIn = Trello.authorized()
    $("#loggedout").toggle(!isLoggedIn)
    $("#loggedin").toggle(isLoggedIn)

logout = () ->
  Trello.deauthorize()
  updateLoggedIn()

Trello.authorize interactive:false, success: onAuthorize

$("#connectLink").bind 'click', () ->
  Trello.authorize(type: "popup", success: onAuthorize, name: "KanbanFu.com", scope: { write: true, read: true })

$("#disconnect").bind 'click', logout
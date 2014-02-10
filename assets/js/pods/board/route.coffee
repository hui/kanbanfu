KanbanFu.BoardRoute = KanbanFu.AuthorizedRoute.extend
  model: (params) ->
    return Trello.boards.get params['board_id']

  setupController: (controller, model) ->
    controller.set("cards", [])
    controller.set("model", model)

    Trello.get "boards/#{model.id}/cards", (cards) =>
      console.log cards
      controller.set("cards", cards)

    Trello.get "boards/#{model.id}/actions", (actions) =>
      console.log actions
      controller.set("trello_actions", actions)
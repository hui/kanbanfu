KanbanFu.BoardRoute = KanbanFu.AuthorizedRoute.extend
  model: (params) ->
    return Trello.boards.get params['board_id']

  setupController: (controller, model) ->
    controller.set("cards", [])
    controller.set("trelloActions", [])
    controller.set("model", model)

    # Trello.get "boards/#{model.id}/cards", (cards) =>
    #   controller.set("cards", cards)

    Trello.get "boards/#{model.id}/actions", filter: ['createCard', 'updateCard:idList', 'deleteCard'], limit: 1000, since: moment().subtract('days', 7).format(), (actions) =>
      trelloActions = []
      for action in actions
        trelloAction = KanbanFu.TrelloAction.create()
        trelloAction.set 'memberCreator', action.memberCreator
        trelloAction.set 'type', action.type
        trelloAction.set 'data', action.data
        trelloAction.set 'date', action.date
        trelloActions.push(trelloAction)

      controller.set("trelloActions", trelloActions)
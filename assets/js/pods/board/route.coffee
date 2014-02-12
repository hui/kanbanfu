KanbanFu.BoardRoute = KanbanFu.AuthorizedRoute.extend
  model: (params) ->
    return Trello.boards.get params['board_id']

  setupController: (controller, model) ->
    controller.set("cards", [])
    controller.set("trelloLists", [])
    controller.set("trelloActions", [])
    controller.set("model", model)

    Trello.get "boards/#{model.id}/lists", filter: 'open', cards: 'open', card_fields: 'id,name', (lists) =>
      trelloLists = []
      for list in lists
        trelloList = KanbanFu.TrelloList.create()
        trelloList.set 'id', list.id
        trelloList.set 'name', list.name
        trelloList.set 'cards', list.cards
        trelloList.set 'pos', list.cards
        trelloLists.push(list)
        # console.log list
      controller.set("trelloLists", trelloLists)

    Trello.get "boards/#{model.id}/actions", filter: ['createCard', 'updateCard', 'deleteCard', 'commentCard', 'updateCheckItemStateOnCard'], limit: 1000, since: moment().subtract('days', 10).format(), (actions) =>
      trelloActions = []
      for action in actions
        trelloAction = KanbanFu.TrelloAction.create()
        trelloAction.set 'memberCreator', action.memberCreator
        trelloAction.set 'type', action.type
        trelloAction.set 'data', action.data
        trelloAction.set 'date', moment(action.date).local()
        trelloActions.push(trelloAction)
        # console.log action
      controller.set("trelloActions", trelloActions)
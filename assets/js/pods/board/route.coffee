KanbanFu.BoardRoute = KanbanFu.AuthorizedRoute.extend
  model: (params) ->
    actionTypes = 'createCard,updateCard,deleteCard,commentCard,updateCheckItemStateOnCard'
    return Trello.boards.get params['board_id'], actions: actionTypes, actions_since: moment().subtract('days', 10).format(), actions_limit: 1000, lists: 'open', cards: 'all', card_fields: 'closed,idMembers,idList,labels,name,url', members: 'all'

  setupController: (controller, model) ->
    controller.set("model", model)
    controller.set("listCardsByDayHash", {})

    members = {}
    for member in model.members
      members[member.id] = member
    controller.set("members", members)

    trelloLists = {}
    for list in model.lists
      trelloList = KanbanFu.TrelloList.create()
      trelloList.set 'id', list.id
      trelloList.set 'name', list.name
      trelloList.set 'cards', []
      trelloList.set 'pos', list.pos
      trelloLists[list.id] = trelloList
      # console.log list

    cards = {}
    for card in model.cards
      cards[card.id] = card
      unless card.closed
        if trelloLists[card.idList]?
          card.members = $.map card.idMembers, (id) ->
            members[id]
          trelloLists[card.idList].cards.push(card)

    controller.set("cards", cards)
    controller.set "trelloLists", $.map(trelloLists, (a) ->
      a
    )

    trelloActions = []
    for action in model.actions
      trelloAction = KanbanFu.TrelloAction.create()
      trelloAction.set 'memberCreator', action.memberCreator
      trelloAction.set 'type', action.type
      trelloAction.set 'data', action.data
      trelloAction.set 'date', moment(action.date).local()
      trelloActions.push(trelloAction)
      # console.log action
    controller.set("trelloActions", trelloActions)
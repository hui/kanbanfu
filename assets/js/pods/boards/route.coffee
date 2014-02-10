KanbanFu.BoardsRoute = KanbanFu.AuthorizedRoute.extend
  model: () ->
    return Trello.get("members/me/boards", filter: 'open')
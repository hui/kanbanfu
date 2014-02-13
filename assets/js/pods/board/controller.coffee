KanbanFu.BoardController = Ember.ObjectController.extend
  cards: []
  trelloActions: []
  trelloLists: []
  listCardsByDayHash: {}

  closeCardOnDay: (card, day, maxDay)->
    Trello.get "cards/#{card.id}/list", (list) =>
      listCardsByDay = @get("listCardsByDayHash")
      for i in [day..maxDay]
        listCardsByDay[i]['info'][list.id] += 1
      @set("listCardsByDayHash", listCardsByDay)
      @notifyPropertyChange("listCardsByDayHash")

  actionsByDay: (() ->
    actionsByDay = {}
    for action in @get("trelloActions")
      dateKey = moment(action.date).format("L")
      actionsByDay[dateKey] ||= []
      actionsByDay[dateKey].push(action)
      # console.log action
    actionsByDay
  ).property("trelloActions")

  actionsByMember: (() ->
    actions = {}
    for action in @get("trelloActions")
      actions[action.memberCreator.id] ||= {}
      actions[action.memberCreator.id]['name'] ||= action.memberCreator.fullName
      actions[action.memberCreator.id]['values'] ||= {}
      actions[action.memberCreator.id]['values'][moment(action.date).unix()] = 1

    $.map actions, (a) ->
      a
  ).property("trelloActions")

  listCardsByDayArray: (() ->
    listCardsByDayDataArray = []
    for list in @get("trelloLists")
      listData = {}
      listData['key'] = list.name
      listData['values'] = []
      for info in @get("listCardsByDayHash")
        listData['values'].push [moment(info['date']), info['info'][list.id]]
      listCardsByDayDataArray.push listData
    listCardsByDayDataArray
  ).property("listCardsByDayHash")

  buildListCardsByDayHash: (() ->
    unless @get("trelloLists").length > 0 && @get("trelloActions").length > 0
      return null

    actionsByDay = @get("actionsByDay")

    # build list for 10 days
    listCardsByDay = []
    listCardsByDayDataTemp = []
    firstDay = moment().format("L") # today
    listCardsByDay[0] = {}
    listCardsByDay[0]['date'] = firstDay
    listCardsByDay[0]['date'] = firstDay
    listCardsByDay[0]['info'] = {}
    for list in @get("trelloLists")
      listCardsByDay[0]['info'][list.id] = list.cards.length

    for day in [1..10]
      date = moment().subtract("days", day).format("L")
      listCardsByDay[day] = {}
      listCardsByDay[day]['date'] = date
      listCardsByDay[day]['info'] = Ember.copy(listCardsByDay[day-1]['info'])

      prevDate = listCardsByDay[day-1]['date']
      if actionsByDay[prevDate]?
        for action in actionsByDay[prevDate]
          switch action.type
            when 'createCard'
              listCardsByDay[day]['info'][action.data.list.id] -= 1
            when 'updateCard'
              if action.data.listAfter?
                listCardsByDay[day]['info'][action.data.listAfter.id]  -= 1
                listCardsByDay[day]['info'][action.data.listBefore.id] += 1
              if action.data.old.closed == false
                @closeCardOnDay(action.data.card, day, 10)
            when 'deleteCard'
              listCardsByDay[day]['info'][action.data.list.id] += 1

    @set("listCardsByDayHash", listCardsByDay)
  ).observes("trelloLists", "trelloActions")
KanbanFu.BoardController = Ember.ObjectController.extend
  cards: []
  trelloActions: []
  trelloLists: []

  actionsByDay: (() ->
    actionsByDay = {}
    for action in @get("trelloActions")
      dateKey = moment(action.date).format("L")
      actionsByDay[dateKey] ||= []
      actionsByDay[dateKey].push(action)
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

  listCardsByDayData: (() ->
    unless @get("trelloLists").length > 0 && @get("trelloActions").length > 0
      return null

    actionsByDay = @get("actionsByDay")

    # build list for 7 days
    listCardsByDay = []
    listCardsByDayDataTemp = []
    firstDay = moment().format("L") # today
    listCardsByDay[0] = {}
    listCardsByDay[0]['date'] = firstDay
    listCardsByDay[0]['date'] = firstDay
    listCardsByDay[0]['info'] = {}
    for list in @get("trelloLists")
      listCardsByDay[0]['info'][list.id] = list.cards.length

    for day in [1..7]
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
            when 'deleteCard'
              listCardsByDay[day]['info'][action.data.list.id] += 1

    for list in @get("trelloLists")
      listData = {}
      listData['key'] = list.name
      listData['values'] = []
      for info in listCardsByDay
        listData['values'].push [moment(info['date']), info['info'][list.id]]
      listCardsByDayDataTemp.push listData

    # console.log listCardsByDayDataTemp
    return listCardsByDayDataTemp
  ).property("trelloLists", "trelloActions")
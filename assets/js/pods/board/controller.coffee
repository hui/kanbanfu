KanbanFu.BoardController = Ember.ObjectController.extend
  labels: []
  members: {}
  cards: {}
  trelloActions: []
  trelloLists: []
  listCardsByDayHash: {}
  totalCardsByDay: []

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

  buildListCardsByDayHash: () ->
    unless @get("trelloLists").length > 0 && @get("trelloActions").length > 0
      return null

    actionsByDay = @get("actionsByDay")

    totalCardsByDay = []
    totalCardsByDay[0] = {}

    # build list for 10 days
    listCardsByDay = []
    listCardsByDayDataTemp = []
    firstDay = moment().format("L") # today
    listCardsByDay[0] = {}
    listCardsByDay[0]['date'] = firstDay
    listCardsByDay[0]['info'] = {}

    totalCardsByDay[0]['date'] = firstDay
    totalCardsByDay[0]['cards'] = []

    for list in @get("trelloLists")
      listCardsByDay[0]['info'][list.id] = list.cards.length
      totalCardsByDay[0]['cards'].pushObjects list.cards.map (card)->
        card.currentList = list.id
        Ember.copy(card)

    for day in [1..10]
      date = moment().subtract("days", day).format("L")
      listCardsByDay[day] = {}
      listCardsByDay[day]['date'] = date
      listCardsByDay[day]['info'] = Ember.copy(listCardsByDay[day-1]['info'])

      totalCardsByDay[day] = {}
      totalCardsByDay[day]['date'] = date
      totalCardsByDay[day]['cards'] = Ember.copy(totalCardsByDay[day-1]['cards'].map (card)->
        Ember.copy(card)
      )

      prevDate = listCardsByDay[day-1]['date']
      if actionsByDay[prevDate]?
        for action in actionsByDay[prevDate]
          findCard = totalCardsByDay[day]['cards'].find((item, index, self) ->
            if item.id == action.data.card.id
              return true
          )
          switch action.type
            when 'createCard'
              listCardsByDay[day]['info'][action.data.list.id] -= 1
              totalCardsByDay[day]['cards'].removeObject findCard
            when 'updateCard'
              if action.data.listAfter?
                listCardsByDay[day]['info'][action.data.listAfter.id]  -= 1
                listCardsByDay[day]['info'][action.data.listBefore.id] += 1
                findCard.currentList = action.data.listBefore.id
                index = totalCardsByDay[day]['cards'].indexOf findCard
                totalCardsByDay[day]['cards'].replace index, 1, findCard
              if action.data.old.closed == false
                idList = @get("cards")[action.data.card.id].idList
                listCardsByDay[day]['info'][idList] += 1

                card = action.data.card
                card.currentList = idList
                totalCardsByDay[day]['cards'].pushObject card

            when 'deleteCard'
              listCardsByDay[day]['info'][action.data.list.id] += 1

    @set("totalCardsByDay", totalCardsByDay)
    @set("listCardsByDayHash", listCardsByDay)
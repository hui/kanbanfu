KanbanFu.TrelloAction = Ember.Object.extend
  memberCreator: null
  type: null
  date: null
  data: null

  cardLink: (() ->
    "https://trello.com/c/#{@get("data").card.shortLink}"
  ).property('data')

  typeName: (() ->
    switch @get('type')
      when 'createCard'
        'created'
      when 'updateCard'
        if @get('data').listAfter?
          'moved'
        else
          'updated'
      when 'deleteCard'
        'deleted'
      when 'commentCard'
        'commented'
      when 'updateCheckItemStateOnCard'
        'checked'
  ).property('type')

  labelClass: (() ->
    switch @get('type')
      when 'createCard', 'deleteCard'
        'label-danger'
      when 'updateCard', 'updateCheckItemStateOnCard'
        'label-info'
      when 'commentCard'
        'label-default'
  ).property('type')

  updatedField: (() ->
    Ember.keys(@get('data').old)[0]
  ).property('old')

  isCreateType: (() ->
    @get('type') == 'createCard'
  ).property('type')

  isMoveType: (() ->
    @get('type') == 'updateCard' && @get('data').listAfter?
  ).property('type')

  isUpdateType: (() ->
    @get('type') == 'updateCard' && !@get('data').listAfter?
  ).property('type')

  isDeleteType: (() ->
    @get('type') == 'deleteCard'
  ).property('type')
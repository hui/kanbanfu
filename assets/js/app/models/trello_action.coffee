KanbanFu.TrelloAction = Ember.Object.extend
  memberCreator: null
  type: null
  date: null
  data: null

  typeName: (() ->
    switch @get('type')
      when 'createCard'
        'created'
      when 'updateCard'
        'updated'
      when 'deleteCard'
        'deleted'
  ).property('type')

  isCreateType: (() ->
    @get('type') == 'createCard'
  ).property('type')

  isUpdateType: (() ->
    @get('type') == 'updateCard'
  ).property('type')

  isDeleteType: (() ->
    @get('type') == 'deleteCard'
  ).property('type')
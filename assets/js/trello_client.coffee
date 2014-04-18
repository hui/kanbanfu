# NOTE: The client library expects that jQuery has already been included,
# and that there is an "opts" variable (this is created automatically)
# when there is a request to client.js?key=...&token=...
#
# The expected options are:
#   version - The API version
#   apiEndpoint - The URL that API calls should go to (e.g. https://api.trello.com)
#   authEndpoint - The URL the authentication requests should go to (e.g. https://trello.com)
#   key - the application key to use in API requests.  This is set automatically when using <script src=".../client.js?key=..."
#   token - Optional.  The token to use in API requests.  This is set automatically when using <script src=".../client.js?key=...&token=..."
wrapper = (window, jQuery, opts) ->
  $ = jQuery

  { key, token, apiEndpoint, authEndpoint, version } = opts

  baseURL = "#{ apiEndpoint }/#{ version }/"
  location = window.location

  Trello =
    version: -> version

    key: -> key
    setKey: (newKey) ->
      key = newKey
      return

    token: -> token
    setToken: (newToken) ->
      token = newToken
      return

    # Issue a REST call to the API
    #
    # .rest(method, path, params, success, error)
    # .rest(method, path, success, error)
    #
    # method - The HTTP method to use/simulate (e.g. GET, POST, PUT, DELETE)
    # path - The API path to use (e.g. "members/me")
    # params - Optional.  A hash of values to include in the querystring/body (e.g. { filter: "open", fields: "name,desc" })
    # success - Function to call when the request succeeds
    # error - Function to call when the request fails
    rest: (method, args...) ->
      [path, params, success, error] = parseRestArgs(args)

      opts =
        url: "#{ baseURL }#{ path }"
        type: method
        data: {}
        dataType: "json"
        success: success
        error: error

      # If the browser doesn't support CORS, then use JSONP
      if !$.support.cors
        opts.dataType = "jsonp"
        if method != "GET"
          opts.type = "GET"
          $.extend opts.data, { _method: method }

      # Only include the key if it's been set to something truthy
      if key
        opts.data.key = key
      # Only include the token if it's been set to something truthy
      if token
        opts.data.token = token

      if params?
        $.extend opts.data, params

      $.ajax opts

    # Has Trello been authorized to issue requests on a user's behalf?
    authorized: -> token?

    # Clear any existing authorization
    deauthorize: ->
      token = null
      writeStorage("token", token)
      clearReady()
      return

    # Request a token that will allow us to make API requests on a user's behalf
    #
    # opts =
    #   type - "redirect" or "popup"
    #   name - Name to display
    #   persist - Save the token to local storage?
    #   interactive - If false, don't redirect or popup, only use the stored token, if one exists
    #   scope - The permissions we're requesting
    #   expiration - When we want the requested token to expire ("1hour", "1day", "30days", "never")
    authorize: (userOpts) ->

      opts = $.extend true,
        type: "redirect"
        persist: true
        interactive: true
        scope:
          read: true
          write: false
          account: false
        expiration: "30days"
      , userOpts

      regexToken = /[&#]?token=([0-9a-f]{64})/

      persistToken = ->
        if opts.persist && token?
          writeStorage("token", token)

      if opts.persist
        token ?= readStorage("token")

      token ?= regexToken.exec(location.hash)?[1]

      if @authorized()
        persistToken()
        location.hash = location.hash.replace(regexToken, "")
        return opts.success?()

      # If we aren't in interactive mode, and we didn't get the token from
      # storage or from the hash, then we error out here
      if !opts.interactive
        return opts.error?()

      scope = (k for k, v of opts.scope when v).join(",")

      switch opts.type
        when "popup"
          do ->
            waitUntil "authorized", (isAuthorized) =>
              if isAuthorized
                persistToken()
                opts.success?()
              else
                opts.error?()

            width = 420
            height = 470
            left = window.screenX + (window.innerWidth - width) / 2
            top = window.screenY + (window.innerHeight - height) / 2

            origin = ///^ [a-z]+ :// [^/]* ///.exec(location)?[0]
            window.open authorizeURL({ return_url: origin, callback_method: "postMessage", scope, expiration: opts.expiration, name: opts.name}), "trello", "width=#{ width },height=#{ height },left=#{ left },top=#{ top }"
        else
          # We're leaving the current page now; but the user should be calling .authorize({ interactive: false })
          # on page load
          window.location = authorizeURL({ redirect_uri: location.href, callback_method: "fragment", scope, expiration: opts.expiration, name: opts.name})

      return

  # Hook up some convenience methods for HTTP methods
  #
  # Trello.get(path, params, success, error)
  # Trello.put(path, params, success, error)
  # Trello.post(path, params, success, error)
  # Trello.delete(path, params, success, error)
  for type in ["GET", "PUT", "POST", "DELETE"]
    do (type) ->
      Trello[type.toLowerCase()] = -> @rest(type, arguments...)

  # Provide another alias for Trello.delete, since delete is a keyword in javascript
  Trello.del = Trello.delete

  # Hook up convenience methods for the different collections
  # e.g. Trello.cards(id, params, success, error)
  for collection in ["actions", "cards", "checklists", "boards", "lists", "members", "organizations", "lists"]
    do (collection) ->
      Trello[collection] =
        get: (id, params, success, error) ->
          Trello.get("#{ collection }/#{ id }", params, success, error)

  window.Trello = Trello

  authorizeURL = (args) ->
    baseArgs =
      response_type: "token"
      key: key

    authEndpoint + "/" + version + "/authorize?" + $.param($.extend(baseArgs, args))

  parseRestArgs = ([path, params, success, error]) ->
    if isFunction(params)
      error = success
      success = params
      params = {}

    # Get rid of any leading /
    path = path.replace(/// ^/* ///, "")

    [path, params, success, error]

  receiveMessage = (event) ->
    return if event.origin != authEndpoint

    event.source?.close()

    if event.data? && event.data.length > 4
      token = event.data
    else
      token = null

    isReady("authorized", Trello.authorized())
    return

  localStorage = window.localStorage
  if localStorage?
    storagePrefix = "trello_"
    readStorage = (key) -> localStorage[storagePrefix + key]
    writeStorage = (key, value) ->
      if value == null
        delete localStorage[storagePrefix + key]
      else
        localStorage[storagePrefix + key] = value
  else
    readStorage = writeStorage = ->


  window.addEventListener? "message", receiveMessage, false

  return

deferred = {}
ready = {}

clearReady = () ->
  ready = {}

waitUntil = (name, fx) ->
  if ready[name]?
    fx(ready[name])
  else
    (deferred[name] ?= []).push(fx)

isReady = (name, value) ->
  ready[name] = value
  if deferred[name]
    fxs = deferred[name]
    delete deferred[name]
    fx(value) for fx in fxs
  return

isFunction = (val) ->
  typeof val == "function"

opts = {"version":1,"apiEndpoint":"https://api.trello.com","authEndpoint":"https://trello.com","key":"e60aca6e0ce93e626823f4710758f538"}

wrapper(window, jQuery, opts)
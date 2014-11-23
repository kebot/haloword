define ['jquery', 'underscore'], ($, _, Backbone) ->

  class ShanbayApiClient
    ajax: $.ajax

    constructor: (
      @apikey,
      @apisecret,
      @redirect_uri='https://api.shanbay.com/oauth2/auth/success/'
    ) ->
      chrome.storage.sync.get('shanbay_authinfo', (items) =>
        authinfo = items['shanbay_authinfo']
        if authinfo
          @restoreAccessInfo(authinfo)
      )

    restoreAccessInfo: (@authinfo) ->

    isLogin: -> !!@authinfo

    saveAuthInfo: (response) ->
      response.expires_in = Date.now() + response.expires_in * 1000
      @authinfo = response

      chrome.storage.sync.set({
        shanbay_authinfo: @authinfo
      })

    logout: ->
      @authinfo = null
      chrome.storage.sync.remove('shanbay_authinfo')

    authorizeUrl: ->
      return 'https://api.shanbay.com/oauth2/authorize/?' + $.param({
         client_id: @apikey,
         response_type: 'token',
         redirect_uri: @redirect_uri
      })

    getAccessToken: (callbackUrl) ->
      [prefix, hash] = callbackUrl.split('#')
      if prefix != @redirect_uri
        console.warnning('Shanbay: redirect uri mismatched:', prefix, '->', @redirect_uri )
        return null

      results = _.object(hash.split(
        '&'
      ).map(
        (i) -> i.split('=')
      ))

      @saveAuthInfo(results)

      return results

    refreshToken: (code) ->
      new Promise (resolve, reject) =>
        this.ajax(
          url: 'https://api.shanbay.com/oauth2/token/',
          type: 'post',
          dataType: 'json',
          data: {
            grant_type: 'refresh_code'
            client_id: @apikey
            client_secret: @apisecret
            redirect_uri: @redirect_uri,
            code: code
          }
        ).then (authinfo) =>
          @saveAuthInfo(authinfo)
          resolve()
        , reject

    request: (ajaxOptions)->
      _.defaults(ajaxOptions, {
        dataType: 'json',
        type: 'get',
        contentType: 'application/json',
      })

      if not this.authinfo.access_token
        this.ajax(ajaxOptions)
      else if Date.now() < this.authinfo.expires_in
        ajaxOptions.headers = _.extend(ajaxOptions.headers or {}, {
          'Authorization': 'Bearer ' + this.authinfo.access_token
        })
        this.ajax(ajaxOptions)
      else
        this.refreshToken(this.authinfo.refresh_token, ture).then(=>
          return this.request(ajaxOptions)
        , this.logout)

    getAccount: -> return this.request({url: 'https://api.shanbay.com/account/'})


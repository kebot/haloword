define ['react', 'haloword/service/shanbay'], (React, ShanbayApiClient) ->
  {div, button} = React.DOM

  apiClient = new ShanbayApiClient('a46a066fb1827f316fd4', '7b372f23cededaa257b55f87ffac50474501124c')

  React.createClass {
    getInitialState: ->
      account: {}

    componentWillMount: ->
      Object.observe(apiClient, (changes) =>
        for i in changes
          if i.name == 'authinfo'
            this.forceUpdate()
            apiClient.getAccount().then (a) => this.setState({account: a})
      )

    checkTab: (tabId, changeInfo, tab) ->
      if tabId == @tabId
        tokens = apiClient.getAccessToken(tab.url)
        console.log tokens
        if tokens
          chrome.tabs.remove(tabId, =>
            @tabId = null
            chrome.tabs.onUpdated.removeListener @checkTab
            @forceUpdate()
          )

    auth: ->
      chrome.tabs.onUpdated.addListener @checkTab

      chrome.windows.create({
        url: apiClient.authorizeUrl(),
        type: 'normal',
        width: 600,
        height: 600
      }, (createdWindow) =>
        tab = createdWindow.tabs[0]
        @tabId = tab.id
      )

    logout: ->
      apiClient.logout()
      this.forceUpdate()

    render: ->
      (div {
      }, (if apiClient.isLogin() then (
        (div null, this.state.account.nickname, (button onClick: this.logout, 'Logout'))
      ) else (button onClick: this.auth, 'Auth Shanbay Account')))
  }



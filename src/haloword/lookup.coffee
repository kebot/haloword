define ['react', 'jquery', 'ui/draggable', 'haloword/storage', 'haloword/dicts/youdao'], (
  React,
  $,
  draggable,
  storage,
  YouDaoDefination
)->
  {
    div, span, a, p, br
  } = React.DOM

  # Lookup box
  LookupBox = React.createClass
    displayName: 'Lookup'

    getDefaultProps: ->
      {
        word: 'foo',
        x: 0,
        y: 0
      }

    getInitialState: ->
      display: false
      loading: true

    componentDidMount: ->
      $(this.getDOMNode()).draggable({
        handler: '#haloword-title'
      })

    render: ->
      (div id: 'haloword-lookup', className: 'ui-widget-content', style: {
          display: if this.state.display then 'none' else 'block',
          top: this.props.y,
          left: this.props.x
        },
        (div id: 'haloword-title',
          (span id: 'haloword-word', this.props.word),
          (a href: '#', id: 'haloword-pron', className: 'haloword-button', title: '发音'),
          (div id: 'haloword-control-container',
            (a id: 'haloword-add', className: 'haloword-button', title: '加入单词表'),
            (a id: 'haloword-remove', className: 'haloword-button', title: '移出单词表'),
            (a
              id: 'haloword-open',
              href: chrome.extension.getURL('main.html#' + this.props.word),
              target: '_blank',
              className: 'haloword-button',
              title: '查看单词详细释义'
            ),
            (a id: 'haloword-close', className: 'haloword-button', title: '关闭查询窗')
          )
        ),
        (YouDaoDefination
          id: 'halowrod-content',
          word: this.props.word,
          miniui: true
        )
      )

  # util functions
  getSelection = ->
    selection = window.getSelection()
    if not selection
      $('iframe').each ->
        if this.contentDocument
          selection = this.contentDocument.getSelection()
        if selection
          return false

    return selection

  {
    setup: (root) ->
      if not root
        root = document.getElementById('haloword-lookup-wrapper')

      $('body').on('mouseup', (e) ->
        selection = getSelection()
        if selection.type != 'Range'
          return
        word = $.trim(selection.toString())

        windowWidth = $(window).outerWidth()
        halowordWidth = $('#haloword-lookup').outerWidth()
        left = Math.min(windowWidth + window.scrollX - halowordWidth, e.pageX - $('body').offset().left)

        React.renderComponent(
          (LookupBox {
            word: word,
            x: left,
            y: e.pageY,
            onLookup: (info) ->
              # only save it's a word
              storage.saveRecord({
                word: word,
                url: location.href,
                context: selection.focusNode.data
              })
          })
        , root)


      )
    }

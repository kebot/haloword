define ['react', 'jquery', 'ui/draggable', 'haloword/storage'], (
  React,
  $,
  draggable,
  storage
)->
  {div, span, a} = React.DOM

  # Lookup box
  LookupBox = React.createClass
    displayName: 'Lookup'

    getDefaultProps: ->
      {
        word: 'foo'
      }

    getInitialState: ->
      display: false

    componentDidMount: ->
      $(this.getDOMNode()).draggable({
        handler: '#haloword-title'
      })

    render: ->
      (div id: 'haloword-lookup', className: 'ui-widget-content', style: {
          display: if this.state.display then 'none' else 'block'
        },
        (div id: 'haloword-title',
          (span id: 'haloword-word', this.props.word),
          (a href: '#', id: 'haloword-pron', className: 'haloword-button', title: '发音'),
          (div id: 'haloword-control-container',
            (a id: 'haloword-add', className: 'haloword-button', title: '加入单词表'),
            (a id: 'haloword-remove', className: 'haloword-button', title: '移出单词表'),
            (a id: 'haloword-open', className: 'haloword-button', title: '查看单词详细释义'),
            (a id: 'haloword-close', className: 'haloword-button', title: '关闭查询窗')
          )
        )
      )

  getSelection = ->
    selection = window.getSelection()
    if not selection
      $('iframe').each ->
        if this.contentDocument
          selection = this.contentDocument.getSelection()
        if selection
          return false
    return selection

  return {
    run: ->
      root = document.getElementById('haloword')

      $('body').on('mouseup', ->
        selection = getSelection()
        if selection.type != 'Range'
          return
        word = $.trim(selection.toString())

        React.renderComponent(
          (LookupBox {
            word: word
          })
        , root)

        storage.saveRecord({
          word: word,
          url: location.href,
          context: selection.focusNode.data
        })
      )

  }


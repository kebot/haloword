define ['react', 'jquery', 'haloword/config'], (React, $, config)->
  {section, p, a, span, div} = React.DOM

  React.createClass
    displayName: 'YoudaoDef'

    componentDidMount: ->
      if this.props.word
        this.lookup(this.props.word)

    lookup: (word) ->
      $.ajax({
        url: config.youdao_url + word
      }).success (data) =>
        if data.errorCode == 0
          this.setState(data)

    componentWillReceiveProps: (props) ->
      if props.word
        this.lookup(props.word)

    render: ->
      data = this.state
      if not data
        return (section null)

      (section id: 'extradef', style: {display: 'block'},
        (p null,
          (if data.basic?.phonetic then (
            span className: 'phonetic', style: {
            display: 'inline-block'
            }, (span null, data.basic.phonetic)) else (span null, )
          ),
          (a
            className: 'from',
            target: '_blank',
            href: 'http://dict.youdao.com/search?q=' + encodeURIComponent(this.props.word),
            'Youdao'
          )
        ),
        (div className: 'content', (for explain, id in (data.basic?.explains or data.translation)
          (p key: id, explain)
        ))
      )


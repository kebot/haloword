define ['react', 'jquery', 'haloword/config'], (React, $, config)->
  {section, p, a, span, div} = React.DOM

  React.createClass
    displayName: 'YoudaoDef'

    getDefaultProps: ->
      {
        word: null,
        miniui: false
      }

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
        return (div null, (p null, 'loading definitions'))

      if this.props.miniui
        this.transferPropsTo(
          if data.basic
            (div null,
              (p className: 'phonetic', (span null, data.basic.phonetic)),
              (for i in data.basic.explains
                (p null, i)
              )
            )
          else if data.translation
            (div null, (for i in data.translation
              (p null, i)
            ))
          else
            (div null,
              (p null, "I'm sorry, Dave."),
              (p null, "I'm afraid I can't find that.")
            )
        )
      else
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

          (div className: 'content', (
            for explain, id in (data.basic?.explains or data.translation)
              (p key: id, explain)
          ))

        )


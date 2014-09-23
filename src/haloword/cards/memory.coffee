define [
  'react',
  'haloword/storage'
], (React, db) ->
  {div, p, a, br, time, span} = React.DOM

  React.createClass {

    getDefaultProps: ->
      return {
        word: ''
      }

    getInitialState: ->
      return {
        records: []
        word: {}
      }

    componentDidMount: ->
      if this.props.word
        this.lookup(this.props.word)

    componentWillReceiveProps: (props) ->
      if props.word and props.word != this.props.word
        this.lookup(props.word)

    lookup: (word) ->
      db.words.query()
        .filter('word', word)
        .execute()
        .done (results) =>
          if results.length == 1
            this.setState({word: results[0]})

      db.records.query()
        .filter('word', word)
        .execute()
        .done (r) =>
          if r.length > 0
            this.setState({records: r})

    render: ->
      if _.isEmpty(this.state.word)
        (div null, 'loading')
      else
        currentWord = this.state.word.word
        (div id: 'memory-card',
          this.state.records.map (record) ->
            context = _.map record.context.split(/\b/), (word) ->
              if word == currentWord
                (span {className: 'current'}, word)
              else
                (span null, word)
            (p null,
              context,
              (br null),
              (a className: 'link', href: record.url, '来自：', record.url),
              (time null,
                (new Date(record.datetime)).toLocaleString()
              )
            )
        )

  }

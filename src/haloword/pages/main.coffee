define [
  'react',
  'haloword/dicts/youdao',
  'haloword/storage',
  'underscore'
], (React, YoudaoDef,  db, _) ->
  {
    header, div, hr, p, section, ul, li, a, form, input, span, button
  } = React.DOM

  # HaloWelcome

  Main = React.createClass
    render: ->
      (section id: 'main',
        (header null,
          (span id: 'wordtitle', 'Halo Word'),
          # button add
          (div
            id: 'button_remove',
            className: 'button',
            title: 'Remove from word list'
          ),
          if this.props.currentWord == 'halo:welcome' then (div
            id: 'toolbar',
            className: 'toolbar',
            style:
              display: 'block'
            (button className: 'first', 'Import/Export'),
            (button className: 'middle', 'Donate'),
            (button className: 'middle', 'Feedback'),
            (button className: 'last', 'Github')
          ) else (
            (if false then (div
              id: 'button_remove',
              className: 'button',
              title: 'Remove from word list',
              style: {display: 'block'}
            ) else (div
              id: 'button_add',
              className: 'button',
              title: 'Add to word list',
              style: {display: 'block'}
            ))
          )
        ),
        (hr style: {
          clear: 'both'
          marginTop: 80
        }),
        (YoudaoDef {word: this.props.currentWord})
        (div id: 'bubble', null)
      )

  Asite = React.createClass
    render: ->
      (section id: 'side',
        (li
          id: 'title',
          className: if this.props.currentWord == 'halo:welcome' then 'current' else null,
          (a href: '#halo:welcome', onClick: (e) =>
            e.preventDefault()
            this.props.onSelectWord('halo:welcome')
          , 'Halo Word')
        )
        (li id: 'search',
          (form id: 'search_form',
            (input
              id: 'search_field',
              type: 'search',
              placeholder: 'Enter a word...',
              results: '0',
              autofocus: true
            )
          )
        )
        (ul id: 'wordlist',
          this.props.words.map (dict) =>
            (li
              key: dict.word,
              className: if dict.word == this.props.currentWord then 'current' else null,
              onClick: this.props.onSelectWord.bind(null, dict)
              (div
                className: 'delete',
                title: 'Remove from word list'
                onClick: -> console.log 'delete :', dict
              ),
              dict.word
            )
        )
      )

  return React.createClass
    getInitialState: ->
      currentWord: 'halo:welcome'
      words: []

    componentDidMount: ->
      db.words.query('last_lookup')
        .all()
        .desc()
        .execute()
        .done (result) =>
          this.setState(words: result)
        .fail (msg) ->
          console.error msg

    onSelectWord: (wordDict) ->
      if _.isObject wordDict
        word = wordDict.word
      else if _.isString wordDict
        word = wordDict
      this.setState({
        currentWord: word
      })

    onRemoveWord: (word) ->
      # hello - world

    render: ->
      (div className: 'app',
        (Asite
          onSelectWord: this.onSelectWord,
          words: this.state.words
          currentWord: this.state.currentWord
        ),
        (Main currentWord: this.state.currentWord)
      )


define [
  'react',
  'haloword/cards/memory', 
  'haloword/dicts/youdao',
  'haloword/dicts/webster',
  'haloword/storage',
  'underscore'
], (React, MemoryCard, YoudaoDef, WebSterDef, db, _) ->
  {
    header, div, hr, p, section, ul, li, a, form, input, span, button
  } = React.DOM

  VERSION = '7.0'

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
        (MemoryCard {word: this.props.currentWord}),
        (YoudaoDef {word: this.props.currentWord}),
        (WebSterDef {word: this.props.currentWord}),
        (div id: 'bubble', null)
      )

  Aside = React.createClass

    displayName: 'HalowordAside'

    focusSearchInput: ->
      this.refs.searchInput.getDOMNode().focus()

    render: ->
      (section id: 'side',
        (li
          id: 'title',
          className: if this.props.currentWord == 'halo:welcome' then 'current' else null,
          (a href: '#halo:welcome', onClick: (e) =>
            e.preventDefault()
            this.props.onSelectWord('halo:welcome')
          , 'Halo Word')
        ),
        (li id: 'search',
          (form
            id: 'search_form',
            onSubmit: (e) =>
              e.preventDefault()
              word = this.refs.searchInput.state.value.trim()
              return this.props.onSelectWord(word)
            (input
              id: 'search_field',
              type: 'search',
              name: 'word',
              ref: 'searchInput',
              label: 'word',
              placeholder: 'Enter a word...',
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
                onClick: this.props.onRemoveWord.bind(null, dict)
              ),
              dict.word
            )
        )
      )

  buildins = ['creator', 'credits', 'io', 'loadings', 'me', 'notfound',
              'version', 'welcome']

  return React.createClass
    getInitialState: ->
      currentWord: 'halo:welcome'
      words: []
      buildinHTML: null

    componentDidMount: ->
      db.words.query('last_lookup')
        .all()
        .desc()
        .execute()
        .done (result) =>
          this.setState(words: result)
        .fail (msg) ->
          console.error msg

      window.onkeydown = this.onKeyDown.bind(this)
      this.onSelectWord(this.state.currentWord)

    onSelectWord: (wordDict) ->
      if _.isObject wordDict
        word = wordDict.word
      else if _.isString wordDict
        word = wordDict

      if word.substring(0, 5) == 'halo:'
        page = word.substring(5)
        $.get('release/builtin/' + page + '.html', (html) =>
          this.setState({
            'buildinHTML': html.replace(/__VERSION__/g, '<a href="#halo:version">' + VERSION + '</a>')
          })
        )
      else
        this.setState({
          buildinHTML: null,
          currentWord: word
        })

    onRemoveWord: (dict, event) ->
      # hello - world
      # dict: {word: '', ...}
      self = this
      db.delWord(dict.word).then (key) ->
        self.setState 'words': _.reject(
          self.state.words,
          (w) -> dict.word == w.word
        )

    onKeyDown: (key) ->
      if document.activeElement.tagName not in ['TEXTAREA', 'INPUT']
        if (
          !key.ctrlKey and !key.metaKey and key.which >= 65 and key.which <= 90
        ) or ((key.ctrlKey or key.metaKey) and key.which == 86)
          this.refs.aside.focusSearchInput()

    render: ->
      (div
        className: 'app',
        (Aside
          ref: 'aside',
          onSelectWord: this.onSelectWord,
          onRemoveWord: this.onRemoveWord,
          words: this.state.words
          currentWord: this.state.currentWord
        ),
        if this.state.currentWord.substring(0, 5) == 'halo:'
          (section id: 'main',
            (header null, (span id: 'wordtitle', this.state.title)),
            (div id: 'worddef', dangerouslySetInnerHTML: {__html: this.state.buildinHTML})
          )
        else
          (Main currentWord: this.state.currentWord)

      )


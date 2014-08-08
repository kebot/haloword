define ['react', 'jquery'], (React, $) ->
  api_key = '16E4956996E52002A290C95FC0E63605'
  base_url = "http://dict-co.iciba.com/api/dictionary.php"
  # "?type=json&key=#{api_key}&word="

  React.createComponent

    displayName: 'icibaDef'

    getDefaultProps: ->
      miniui: true
      word: null

    componentDidMount: ->
      if this.props.word
        this.lookup(this.props.word)

    componentWillReceiveProps: (props) ->
      if props.word
        this.lookup(props.word)

    lookup: (word) ->
      $.ajax({
        url: base_url,
        dataType: 'json',
        data: {
          type: 'json',
          key: api_key,
          word: word
        }
      }).success (response) ->
        console.log response

    render: ->
      (h1 null, word)


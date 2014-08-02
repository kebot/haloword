define ['react', 'jquery'], (React, $) ->
  {div, a, p, span, sup, ol, li, audio} = React.DOM

  React.createClass
    displayName: 'WebsterDiff',

    getInitialState: ->
      return {
        show: false,
        entries: []
      }

    componentDidMount: ->
      if this.props.word
        this.lookup(this.props.word)

    componentWillReceiveProps: (props) ->
      if props.word
        this.lookup(props.word)

    lookup: (word) ->
      $.ajax({
        url: 'http://halo.xhacker.im/webster/query/' + word,
        dataType: 'xml'
      }).success (xmlData) =>
        entries = $(xmlData).find('entry_list entry')
        if entries.length is 0
          this.setState(show: false)

        entries_list = entries.map ->
          def_list = []
          sub_list = []
          in_sub_list = false
          $($(this).children("def")[0]).children().each ->
            if $(this).is("sn")
              sn = $(this).text()
              if /^[a-zA-Z]+$/.test(sn)
                # a
                in_sub_list = true
              else unless isNaN(sn)
                # 1
                in_sub_list = false
                if sub_list.length > 0
                  def_list[def_list.length - 1]["sub"] = sub_list
                  sub_list = []
              else
                segments = sn.split(" ")
                if segments.length > 1 and not isNaN(segments[0]) and /^[a-zA-Z]+$/.test(segments[1])
                  # 1 a
                  if sub_list.length > 0
                    def_list[def_list.length - 1]["sub"] = sub_list
                    sub_list = []
                  def_list.push {}
                  in_sub_list = true
            else if $(this).is("dt")
              xml_to_html = (xml) ->
                html = ""
                tagName = $(xml).prop("tagName")
                html += "<span class=\"mw-" + tagName + "\">"  if tagName
                if $(xml).contents().length is 0
                  html += $(xml).text()
                else
                  $(xml).contents().each ->
                    html += xml_to_html(this)
                    return
                html += "</span>"  if tagName
                html
              content = xml_to_html(this)
              content = $(content).html().trim()
              content = content.replace(/^:/, "")
              if in_sub_list
                sub_list.push content: content
              else
                def_list.push content: content
            return

          def_list[def_list.length - 1]["sub"] = sub_list  if sub_list.length > 0

          sounds = $(this).find('sound wav').map(->
            filename = $(this).text()
            return {
              src: 'http://media.merriam-webster.com/soundc11/' + filename[0] + '/' + filename
            }
          )

          return {
            hw: $(this).children("hw").text().replace(/\*/g, "·")
            hwindex: $(this).children("hw").attr("hindex")
            pr: $(this).children("pr").text().trim()
            sounds: sounds
            fl: $(this).children("fl").text()
            def: def_list
          }

        return this.setState(
          entries: entries_list
        )

    render: ->
      console.log this.state.entries

      (div id: 'worddef',
        (for entry in this.state.entries
          (div className: 'mw-item',
            (div className: 'mw-meta',
              (span className: 'mw-headword',
                (if entry.hwindex then (
                  sup null, entry.hwindex
                ) else null), entry.hw
              ),
              (span className: 'mw-part-of-speech', entry.fl),
              (if entry.pr then (
                span className: 'mw-pr', '\\' + entry.pr + '\\'
              ) else null),
              (for sound in entry.sounds
                (a
                  className: 'pronounce',
                  onClick: (e) -> $(e.target).children('audio').trigger('play')
                  (audio src: sound.src)
                )
              )
            ),
            (ol null, (for def in entry.def
              (li dangerouslySetInnerHTML: {__html: def.content})
              if def.sub?.length
                (ol null, (for sub in def.sub
                  (li dangerouslySetInnerHTML: {__html: sub.content})
                ))
            ))
          )
        ),
        (p className: 'credits',
          'Content provided by ',
          (a href: 'http://www.merriam-webster.com/', target: '_blank', 'Marriam-Webster')
        )
      )




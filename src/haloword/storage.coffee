define ['finish', 'underscore', 'db'], (finish, _, db)->
  # this is for debug
  # indexedDB.deleteDatabase('words')

  db.open({
    server: 'words',
    version: 1,
    schema: {
      records: {
        key: {
          keyPath: 'id',
          autoIncrement: true
        },
        indexes: {
          url: {},
          word: {}
        }
      },
      words: {
        key: {
          keyPath: 'word'
        },
        indexes: {
          word: {}
        }
      }
    }
  }).done( (server) ->
    # link record to the new word table
    addRecordToWord = (word, record_id) ->
      currentTime = Date.now()
      server.words.add({
        word: word
        records: [record_id]
        created_time: currentTime
        last_lookup: currentTime
      }).done (r) ->
        console.log '[words] Created ', r
      .fail (r) ->
        console.log '[words] Exists'
        return server.words.query('word', word)
          .all()
          # .only(word)
          .modify({
            records: (rs) ->
              if not _.contains(rs.records, record_id)
                rs.records.push(record_id)
              return rs.records
            last_lookup: currentTime
          })
          .execute()

    # public method for lookup usage
    server.saveRecord = (attrs) ->
      server.records.query()
      .filter('url', attrs.url)
      .filter('word', attrs.word)
      .execute()
      .done (results) ->
        # Check the record exists or not
        if _.isArray(results) and results.length == 0
        # @TODO remove this hack
        # if true
          server.records.add(
            _.extend(attrs, {
              datetime: Date.now()
            })
          ).done (records)->
            # console.log 'Record saved!', records
            if _.isArray(records)
              record = records[0]
            else
              record = records
            addRecordToWord(record.word, record.id).done((result)->
              console.log 'update words', results
            )
        else
          console.log('you have already record this word!')

    finish(server)
  )


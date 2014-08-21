define [], ->
  isEnglish = (word) -> (/^[a-z\sA-Z]+$/g).test(word)
  isChinese = (word) -> (/^[\u4e00-\u9fa5]+$/g).test(word)

  validWord: (word) ->
    if word.length == 0 or word.length > 190
      return false
    if isEnglish(word)
      return 'English'
    else if isChinese(word)
      return 'Chinese'
    else
      return 'Mixed'


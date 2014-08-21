define ['finish'], (finish)->
  config = {}
  YOUDAO_API_KEYFROM = "HaloWordDictionary"
  YOUDAO_API_KEY = "1311342268"
  WEBSTER_KEY = "6d9366e8-dc95-4b44-931a-ff90bc8f96bd"

  config.youdao_url = "http://fanyi.youdao.com/fanyiapi.do?keyfrom=" +
                      YOUDAO_API_KEYFROM +
                      "&key=" + YOUDAO_API_KEY +
                      "&type=data&doctype=json&version=1.1&q="

  if not window.chrome.storage?.local
    config.disable_querybox = false
    config.getURL = (path) -> return '/release/' + path

    finish config
  else
    chrome.storage.local.get('disable_querybox', (ret) ->
      config.disable_querybox = ret.disable_querybox
      config.getURL = chrome.extension.getURL

      finish config
    )





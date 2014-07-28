define [], ->
  YOUDAO_API_KEYFROM = "HaloWordDictionary"
  YOUDAO_API_KEY = "1311342268"
  WEBSTER_KEY = "6d9366e8-dc95-4b44-931a-ff90bc8f96bd"

  return {
    youdao_url: "http://fanyi.youdao.com/fanyiapi.do?keyfrom=" + YOUDAO_API_KEYFROM + "&key=" + YOUDAO_API_KEY + "&type=data&doctype=json&version=1.1&q=";
  }

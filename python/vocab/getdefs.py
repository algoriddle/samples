import urllib.request, time, random

url1 = "http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100&q="
url2 = "&sl=en&tl=en"

words = [line.strip() for line in open('words')]

with open('dict', "w") as dict:
    for word in words:
        time.sleep(random.random() * 4)
        print(urllib.request.urlopen(url1 + word + url2).read(), file = dict)

import json, codecs, itertools, random, sys

words = []

with open('dict') as df:
    for line in df:
        line = bytes(codecs.decode(line, 'unicode-escape'), 'iso-8859-1').decode('utf-8').strip()
        line = line.replace('\\x3c', '<').replace('\\x3e', '>').replace('\\x27', "'")
        line = line[27:-11]
        word = json.loads(line)
        words.append(word)

def getdefs(word):
    defs = []
    primaries = word['primaries'];
#    print(word['query'] + " " + str(len(primaries)))
    for primary in primaries:
        entries = primary['entries']
#        print(len(entries))
        for entry in entries:
            if (entry['type'] == "meaning"):
                terms = entry['terms']
                for term in terms:
                    defs.append(term['text'])
    return defs

choice_count = 4
perms = list(itertools.permutations(range(choice_count)))

while True:
    print()

    choices = [words[random.randint(0, len(words))] for x in range(choice_count)]

    for i in range(choice_count):
        print(i + 1)
        defs = getdefs(choices[i])
        for deff in defs:
            print(deff)
        print()

    mix = perms[random.randint(0, len(perms))]

    for i in range(choice_count):
        print(choices[mix[i]]['query'])

    for i in range(choice_count):
        print()
        print(str(i + 1) + "?")
        answer = input();
        if (answer == "quit"):
            sys.exit()
        if (choices[i]['query'] == answer):
            print("OH YES!")
        else:
            print("NOOOOOO!")
            print("correct answer: " + choices[i]['query'])

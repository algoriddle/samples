import json, codecs, itertools, random, sys, time

words = []

with open('dict') as df:
    for line in df:
        line = bytes(codecs.decode(line, 'unicode-escape'), 'iso-8859-1').decode('utf-8').strip()
        line = line.replace('\\x3c', '<').replace('\\x3e', '>').replace('\\x27', "'")\
            .replace('<em>', '').replace('</em>', '').replace('<b>', '').replace('</b>', '')
        line = line[27:-11]
        word = json.loads(line)
        words.append(word)

def get_defs(word):
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

def get_exs(word):
    exs = []
    primaries = word['primaries'];
    for primary in primaries:
        entries = primary['entries']
        for entry in entries:
            if (entry['type'] == "meaning"):
                if 'entries' in entry:
                    examples = entry['entries']
                    for example in examples:
                        if example['type'] == "example":
                            terms = example['terms']
                            for term in terms:
                                exs.append(term['text'])
    return exs

choice_count = 4
perms = list(itertools.permutations(range(choice_count)))

try:
    with open('results') as f:
        results = json.load(f)
except IOError:
        results = {}

while True:
    print()
    print()

    choices = [words[random.randint(0, len(words) - 1)] for x in range(choice_count)]
    if len([choice for choice in choices if choice['query'] in results]) > 1:
        choices = [words[random.randint(0, len(words) - 1)] for x in range(choice_count)]

    for i in range(choice_count):
        print(i + 1)
        defs = get_defs(choices[i])
        for deff in defs:
            print(deff)
        print()

    mix = perms[random.randint(0, len(perms) - 1)]

    for i in range(choice_count):
        print(choices[mix[i]]['query'])

    answers = []
    for i in range(choice_count):
        print()
        print(str(i + 1) + "?")
        answer = input()
        if answer == "quit":
            sys.exit()
        answers.append(answer)

    print()

    for i in range(choice_count):
        print(str(i + 1) + ": " + answers[i])
        if choices[i]['query'] == answers[i]:
            print("CORRECT")
            if answers[i] in results:
                results[answers[i]] += 1
            else:
                results[answers[i]] = 1
        else:
            print("WRONG: " + choices[i]['query'])
        print()
        exs = get_exs(choices[i])
        for ex in exs:
            print(ex)
        print()
        print()

    with open('results', 'w') as f:
        json.dump(results, f)

    print("Press ENTER")
    quit = input()
    if quit == "quit":
        break

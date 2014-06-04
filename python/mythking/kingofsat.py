# -*- coding: utf-8 -*-
import MythTV, BeautifulSoup, urllib2, time, os, sys

class Dtv_multiplex( MythTV.DBDataWrite ):
    def __str__(self):
        if self._wheredat is None:
            return u"<Uninitialized Dtv at %s>" % hex(id(self))
        return u"<Dtv_multiplex '%d' at %s>" % \
            (self.mplexid, hex(id(self)))

    def __repr__(self):
        return str(self).encode('utf-8')

kingofsat_combined_to_frq_to_name = { }

chlineupx = [
    ["TVE International",  1],
    ["Canal 24 Horas"],
    ["TF 1", 11, 6, 8 ],
    ["TF 1", 12, 6, 302 ],
    ["M6 HD"],
    ["M6"],
    ["W9"],
    ["EBS - Europe by Satellite", 16, 6, 233],
    ["EBS - Europe by Satellite", 17, 6, 433],
    ["France 2", 21, 1],
    ["France 3 Sat"],
    ["France 5"],
    ["France Ô"],
    ["TMC (Télé Monte Carlo)"],
    ["LCP - La Chaîne Parlementaire"],
    ["KTO"],
    ["TV8 Mont Blanc"],
    ["Vosges Television"],
#    ["TV 5 Monde (France Belgique Suisse)"],
    ["TV 5 Monde (France Belgique Suisse)", 31, 8],
    ["TV5 Monde Europe"],
    ["Arte HD"],
    ["Arte (France)"],
    ["Canal+", 41, 5],
    ["D17"],
#    ["Arte (France)"],
    ["""TELE" HREF="http://www.itele.fr/" TARGET="_blank"&gt;i-Télé"""], # i-Télé
#    ["i-Télé"],
    ["BFM Business"],
    ["BFM TV"],
    ["Arte HD", 51],
    ["Das Erste HD"],
    ["rbb Berlin HD"],
    ["MDR Thüringen HD"],
    ["Sudwest Fernsehen Rheinland-Pfalz HD"],
    ["Bayerisches Fernsehen Süd HD"],
    ["Phoenix HD"],
    ["WDR HD Köln"],
    ["NDR Fernsehen"],
    ["hr-fernsehen HD"],
    ["Tagesschau 24 HD"],
    ["Eins Festival HD"],
    ["Eins Plus HD"],
    ["ZDF HD"],
    ["ZDFinfo HD"],
    ["ZDF_neo HD"],
    ["ZDF Kultur HD"],
    ["3sat HD"],
    ["KiKa HD"],
    ["RTL Television"],
    ["RTL 2"],
    ["RTL Nitro"],
    ["Super RTL"],
    ["Sat 1"],
    ["SAT 1 Gold"],
    ["ProSieben"],
    ["ProSieben MAXX"],
    ["Sixx"],
    ["Kabel 1"],
    ["N24"],
    ["Tele 5"],
    ["DMAX"],
    ["Das Vierte"],
    ["VOX"],
    ["Servus TV HD"],
    ["BBC One London", 101, 3],
    ["BBC Two England"],
    ["ITV 1 London"],
    ["Channel 4 London"],
    ["Channel 5 London"],
    ["BBC Three"],
    ["BBC Four"],
    ["BBC One HD", 108, 3, 6941],
    ["BBC Two HD"],
    ["BBC Alba"],
    ["ITV 1 London +1", 112],
    ["ITV 2"],
    ["ITV 2 +1"],
    ["ITV 3"],
    ["ITV 3 +1"],
    ["ITV 4"],
    ["ITV 4 +1"],
    ["ITV 1 London HD", 119, 3, 10000],
    ["S4C Digidol"],
    ["Channel 4 London +1"],
    ["E4 UK"],
    ["E4 +1"],
    ["More 4"],
    ["More 4 +1"],
    ["Channel 4 HD"],
    ["4Seven"],
    ["Channel 5 +1"],
    ["5 USA"],
    ["5 USA +1"],
    ["5*"],
    ["5* +1"],
    ["CBS Drama", 134],
    ["CBS Reality", 135, 3, 53205],
    ["CBS Reality +1"],
    ["CBS Action"],
    ["Horror Channel"],
    ["Horror Channel +1"],
    ["BET U.K."],
    ["BET +1"],
    ["True Entertainment"],
    ["Men & Movies"],
    ["Pick TV", 144, 3, 5109],
    ["Challenge", 145, 3, 6031],
    ["VIVA U.K."],
    ["BBC News", 200],
    ["BBC Parliament"],
    ["Sky News"],
    ["Al Jazeera English"],
    ["EuroNews"],
    ["France 24 (in English)"],
    ["Russia Today"],
    ["CNN International Europe"],
    ["Bloomberg U.K."],
    ["NHK World HD"],
    ["CNBC Europe"],
    ["CCTV News"],
    ["Film4", 300],
    ["Film4 +1"],
    ["True Christmas"], #  ["True Movies 1"],
    ["True Movies 2"],
    ["Movies4men"],\
    ["Movies4Men +1"],
    ["Showcase", 400],
    ["Information TV"],
    ["Showcase 2"],
    ["Food Network"],
    ["Food Network +1"],
    ["Travel Channel"],
    ["The Active Channel"],
    ["Holiday + Cruise"],
    ["Chart Show TV", 500],
    ["The Vault"],
    ["Flava"],
    ["ChartShow Dance"],
    ["B4U Music"],
    ["BuzMuzik"],
    ["Blissmas"],
    ["Zing", 509],
    ["Clubland TV"],
    ["Planet Pop"],
    ["Vintage TV", 515],
    ["Heart TV"],
    ["Capital TV"],
    ["Kiss TV (UK)"],
    ["The Box"],
    ["Heat"],
    ["Smash Hits !"],
    ["Magic (UK)", 523],
    ["Kerrang !"],
    ["CBBC", 600],
    ["CBeebies"],
    ["CITV U.K."],
    ["Pop"],
    ["PopGirl"],
    ["Tiny Pop"],
    ["Kix"],
    ["Babestation", 870],
    ["Playboy TV Chat", 875],
    ["Magyar TV 2", 901, 6],
    ["Duna 1 HD"],
    ["Duna World HD"]
    ]


chlineup = { }

def channels( ):
    print "verifying and deleting channels"
    ss = { } # verified channels
    dd = { } # mplexes
    kcns = { } # KOS channels by name
    cs = MythTV.Channel.getAllEntries()
    dtv = Dtv_multiplex.getAllEntries()
    delcount = 0
    for d in dtv:
        dd[d.mplexid] = d
    for c in cs:
        mp = dd[c.mplexid];
        freqs = get_freqs_from_kingofsat_dict(c.sourceid, mp.polarity, mp.networkid, mp.transportid, c.serviceid)
        name_found = None
        if freqs is not None:
            freq_search = int(round(float(dd[c.mplexid].frequency) / 1000.0))
            for freq in freqs.keys():
                if abs(freq_search - freq) < 10:
                    name_found = freqs[freq]

        if name_found is None:
            print "delete " + c.channum + ", " + c.name + ", " + str(dd[c.mplexid].frequency) + ",  " + str(int(round(float(dd[c.mplexid].frequency) / 1000.0))) + ", " + str(c.serviceid)
            if freqs is not None:
                print "NO FREQ"
            delcount += 1
            c.delete()
            continue
        else:
            kcn = kcns.get(name_found, None)
            if kcn == None:
                kcn = [ ]
                kcns[name_found] = kcn
            kcn.append(c)

        if c.sourceid in ss:
            l = ss[c.sourceid]
        else:
            l = []
            ss[c.sourceid] = l
        l.append(c)

    print "deleted: " + str(delcount)

    print "finding requested channels"
    cc = 0
    prefsrc = 0
    for lu in chlineupx:
        if len(lu) < 2 or lu[1] == 0:
            cc += 1
        else:
            cc = lu[1]
        if len(lu) > 2:
            prefsrc = lu[2]
        if len(lu) > 3:
            prefserviceid = lu[3]
        else:
            prefserviceid = -1
        cf = kcns.get(lu[0], None)
        print str(cc) + " : " + lu[0] + " :",
        if cf == None:
            print("NOT FOUND")
            print("# DISABLED - CHANNEL NOT FOUND")
        else:
            if len(cf) == 1:
                print("OK : " + cf[0].name + " (" + str(cf[0].sourceid) + ", " + str(cf[0].chanid) + ")")
                if prefsrc != 0 and cf[0].sourceid != prefsrc:
                    print("# DISABLED - NOT PREFERRED SAT")
                else:
                    chlineup[cf[0].chanid] = str(cc)
            else:
                print "MULTIPLE " + str(len(cf))
                onlyone = 0
                for mcf in cf:
                    if prefsrc == 0:
                        print("- " + mcf.name + " (" + str(mcf.sourceid) + ", " + str(mcf.chanid) + ")")
                    else:
                        print "- " + mcf.name + " (" + str(mcf.sourceid) + ", " + str(mcf.chanid) + ")",
                        if mcf.sourceid == prefsrc:
                            if prefserviceid > 0:
                                if mcf.serviceid == prefserviceid:
                                    if onlyone == 0:
                                        onlyone = mcf.chanid
                                        print ": SAT AND SID FOUND"
                                    else:
                                        onlyone = -1
                                        print ": SAT AND SID DUPLICATE"
                                else:
                                    print ": -"
                            else:
                                if onlyone == 0:
                                    onlyone = mcf.chanid
                                    print ": SAT FOUND"
                                else:
                                    onlyone = -1
                                    print ": SAT DUPLICATE"
                        else:
                            print ": -"
                if onlyone > 0:
                    chlineup[onlyone] = str(cc)
                else:
                    print("# DISABLED - AMBIGUOUS")

    print "renumbering"
    for si in ss.keys():
        ss[si].sort(key = lambda channel: channel.name.lower())
        nn = 1
        for c in ss[si]:
#            print str(si) + ", " + c.name + ", " + c.channum + ", " + str(si) + "%03d"%nn
            rchid = chlineup.get(c.chanid, None)
            if (rchid == None):
                c.update(channum = str(si) + "%03d"%nn)
                nn += 1
            else:
                print rchid + ", " + c.name
                c.update(channum = rchid)


def read_and_cache_kingofsat(index, url):
    cache_file_name = "cache" + str(index) + ".html"
    if os.path.isfile(cache_file_name) and time.time() - os.path.getmtime(cache_file_name) < 86400:
        print(cache_file_name)
        cache_file = open(cache_file_name, "r")
        html = cache_file.read()
        cache_file.close()
    else:
        print(url)
        html = urllib2.urlopen(url).read()
        cache_file = open(cache_file_name, "w")
        cache_file.write(html)
        cache_file.close()
    return html


def cache_in_dict(dict, key):
    value = dict.get(key)
    if value is None:
        value = { }
        dict[key] = value
    return value


def add_to_kingofsat_dict(sat_index, frequency, polarization, network, transport, sid, name):
    key = str(sat_index) + polarization + str(network) + '|' + str(transport) + '|' + str(sid)
    freq_dict = cache_in_dict(kingofsat_combined_to_frq_to_name, key)
    if frequency in freq_dict:
        print "DUPE - ALL MATCH!"
#        raise Exception
    freq_dict[frequency] = name


def get_freqs_from_kingofsat_dict(sat_index, polarization, network, transport, sid):
    key = str(sat_index) + polarization + str(network) + '|' + str(transport) + '|' + str(sid)
    return kingofsat_combined_to_frq_to_name.get(key)


def scrape_kingofsat( ):
    urls = { 1: "http://en.kingofsat.net/pos-5W.php",
             2: "http://en.kingofsat.net/pos-7E.php",
             3: "http://en.kingofsat.net/pos-28.2E.php",
             5: "http://en.kingofsat.net/pos-19.2E.php",
             6: "http://en.kingofsat.net/pos-9E.php",
             7: "http://en.kingofsat.net/pos-30W.php",
             8: "http://en.kingofsat.net/pos-13E.php",
             9: "http://en.kingofsat.net/pos-0.8W.php" }

    for sat_index in urls.keys():
        html = read_and_cache_kingofsat(sat_index, urls[sat_index])
        soup = BeautifulSoup.BeautifulSoup(html, convertEntities = BeautifulSoup.BeautifulSoup.HTML_ENTITIES)
        html_tables = soup.findAll("table")
        frequency = None
        polarization = None
        tid = None
        nid = None
        for html_table in html_tables:
            html_class = html_table.get("class", "")
            if html_class == "frq":
                polarization = html_table.find("td", {"class": ["bld", "nbld"], "width": "2%"}).contents[0].lower()
                if polarization is None:
                    raise Exception
                frequency = int(round(float(html_table.find("td", {"class": ["bld", "nbld"], "width": "5%"}).contents[0])))
                tid = None
                nid = None
                tid_nid = html_table.findAll("td", {"width": "6%"})
                if len(tid_nid) != 2:
                    raise Exception
                for tid_or_nid in tid_nid:
                    contents = "".join(tid_or_nid.findAll(text=True))
                    if contents.startswith("TID:"):
                        tid = int(contents[4:])
                    elif contents.startswith("NID:"):
                        nid = int(contents[4:])
            if html_class == "fl":
                if frequency is None or polarization is None or tid is None or nid is None:
                    raise Exception
                fls = html_table.findAll("tr")
                for fl in fls:
                    service = fl.find("td", { "class": "s", "width": "5%" })
                    if service is not None:
                        service = service.contents[0]
                    channel_name = fl.find("a", { "class": "A3" })
                    if channel_name is not None:
                        channel_name = str(channel_name.contents[0])
                    if channel_name is not None and service is not None and service.isdigit():
                        service_int = int(service);
                        print str(frequency) + str(polarization) + ", " + str(service_int) + ", " + channel_name
                        add_to_kingofsat_dict(sat_index, frequency, polarization, nid, tid, service_int, channel_name)

scrape_kingofsat()
channels()

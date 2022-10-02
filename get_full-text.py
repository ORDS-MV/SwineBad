#!/usr/bin/env python3

from dataclasses import replace
import os
import re

from urllib.request import urlopen
import xml.etree.ElementTree as ET

# if all full texts are available, these information might be generated automatically from:
# https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093
METS_FULL_TEXT = [
    'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1910',
    'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1915',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1916',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1917',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1918',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1919',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1920',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1921',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1922',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1924',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1925',
    'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1926',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1927',
    'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1928',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1929',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1932'
]

dates = {}

for url in METS_FULL_TEXT:
    year = re.sub(r".*_", '', url)
    target_folder = os.path.join('fulltexts/', year)
    abs_target_folder = os.path.join(os.getcwd(), target_folder)

    if not os.path.isdir(abs_target_folder): 
        os.mkdir(abs_target_folder)

    with urlopen(url) as conn:
        data = ET.fromstring(conn.read())
        for fileSec in data.findall('{http://www.loc.gov/METS/}fileSec'):
            for fileGrp in fileSec:
                if fileGrp.attrib['USE'] != 'DEFAULT':
                    continue

                for file in fileGrp:
                    file_id = file.attrib['ID']

                    for structMap in data.findall('{http://www.loc.gov/METS/}structMap'):
                        if structMap.attrib['TYPE'] != 'PHYSICAL':
                            continue
                        for div in structMap.findall('{http://www.loc.gov/METS/}div'):
                            if div.attrib['TYPE'] == 'physSequence':
                                for div2 in div.findall('{http://www.loc.gov/METS/}div'):
                                    div2_id = None
                                    for fptr in div2.findall('{http://www.loc.gov/METS/}fptr'):
                                        if fptr.attrib['FILEID'] == file_id:
                                            div2_id = div2.attrib['ID']
                                            break
                                    
                                    for structLink in data.findall('{http://www.loc.gov/METS/}structLink'):
                                        for smLink in structLink.findall('{http://www.loc.gov/METS/}smLink'):
                                            # print(smLink.attrib)
                                            if smLink.attrib['{http://www.w3.org/1999/xlink}to'] == div2_id:
                                                log_id = 'DMD' + smLink.attrib['{http://www.w3.org/1999/xlink}from']
                                                
                                                for dmdSec in data.findall('{http://www.loc.gov/METS/}dmdSec'):
                                                    if dmdSec.attrib['ID'] == log_id:
                                                        # print(dmdSec[0][0][0].)
                                                        for originInfo in dmdSec[0][0][0].findall('{http://www.loc.gov/mods/v3}originInfo'):
                                                            for dateIssued in originInfo.findall('{http://www.loc.gov/mods/v3}dateIssued'):
                                                                date_issued = dateIssued.text

                    for Flocat in file:
                        image_url = Flocat.attrib['{http://www.w3.org/1999/xlink}href']
                        fulltext_url = image_url.replace('/viewer/content/', '/viewer/api/v1/records/')
                        fulltext_url = fulltext_url.replace("/800/0/", "/files/plaintext/")
                        fulltext_url = fulltext_url.replace('.jpg', '.xml')
                        print('Downloading %s ...' % (fulltext_url))
                        
                        filename = re.sub(r".*/", "", fulltext_url)
                        filepath = os.path.join(abs_target_folder, filename)
                        dates[os.path.join(target_folder, filename)] = date_issued
                        
                        try:
                            with urlopen(fulltext_url) as fulltext_conn:
                                with open(filepath, 'b+w') as f:
                                    f.write(fulltext_conn.read())
                        except Exception:
                            print("ERROR")

# write csv
with open('dates_fulltexts.csv', 'w') as csvfile:
    csvfile.write('fulltextfile,date\n')
    for key, value in dates.items():
        csvfile.write('%s,%s\n' % (key, value))
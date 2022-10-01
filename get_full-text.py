#!/usr/bin/env python3

from dataclasses import replace
import os
import re

from urllib.request import urlopen
import xml.etree.ElementTree as ET

# if all full texts are available, these information might be generated automatically from:
# https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093
METS_FULL_TEXT = [
    # 'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1910',
    # 'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1915',
    # 'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1926',
    'https://www.digitale-bibliothek-mv.de/viewer/sourcefile?id=PPN636776093_1927',
    # 'https://www.digitale-bibliothek-mv.de/viewer/metsresolver?id=PPN636776093_1928'
]

for url in METS_FULL_TEXT:
    year = re.sub(r".*_", '', url)
    target_folder = os.path.join(os.getcwd(), 'fulltexts/', year)

    if not os.path.isdir(target_folder): 
        os.mkdir(target_folder)

    with urlopen(url) as conn:
        data = ET.fromstring(conn.read())
        for fileSec in data.findall('{http://www.loc.gov/METS/}fileSec'):
            for fileGrp in fileSec:
                if fileGrp.attrib['USE'] != 'DEFAULT':
                    continue

                for file in fileGrp:
                    for Flocat in file:
                        image_url = Flocat.attrib['{http://www.w3.org/1999/xlink}href']
                        fulltext_url = image_url.replace('/viewer/content/', '/viewer/api/v1/records/')
                        fulltext_url = fulltext_url.replace("/800/0/", "/files/plaintext/")
                        fulltext_url = fulltext_url.replace('.jpg', '.xml')
                        print('Downloading %s ...' % (fulltext_url))
                        
                        filename = re.sub(r".*/", "", fulltext_url)
                        filepath = os.path.join(target_folder, filename)
                        with urlopen(fulltext_url) as fulltext_conn:
                            with open(filepath, 'b+w') as f:
                                f.write(fulltext_conn.read())

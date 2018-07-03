import requests
import codecs
import time
import json
import math
import sys

ARTICLE_SEARCH_URL = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.stderr.write('usage: %s <api_key> <section_name> <num_articles>\n' % sys.argv[0])
        sys.exit(1)

    api_key = sys.argv[1]
    section_name = sys.argv[2]
    num_articles = int(sys.argv[3])

    #Number of full pages of articles to download
    num_pages = math.floor(num_articles/10)

    #Number of articles that are leftover
    num_extra = num_articles%10

    #Opening file for writing and making the header
    f = open(section_name + '.tsv', 'w')
    f.write('\t'.join(['section_name', 'web_url', 'pub_date', 'snippet']) + '\n')

    #Getting whole pages of articles
    for i in range(int(num_pages)):
        params = {'api-key': api_key,
                  'fq': 'section_name:' + section_name,
                  'sort': 'newest',
                  'page': i}
        r = requests.get(ARTICLE_SEARCH_URL, params)
        data = json.loads(r.text)
        for doc in data['response']['docs']:
            f.write('\t'.join([section_name, doc['web_url'], doc['pub_date'], doc['snippet']]) + '\n')
        time.sleep(1)

    #Getting the remaining articles
    params = {'api-key': api_key,
              'fq': 'section_name:' + section_name,
              'sort': 'newest',
              'page': int(num_pages+1)}
    r = requests.get(ARTICLE_SEARCH_URL, params)
    data = json.loads(r.text)
    for i in range(num_extra):
        curr_doc = data['response']['docs'][i]
        f.write('\t'.join([section_name, curr_doc['web_url'], curr_doc['pub_date'], curr_doc['snippet']]) + '\n')

    f.close()

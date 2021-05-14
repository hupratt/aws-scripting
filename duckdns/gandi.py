# -*- coding: UTF-8 -*-
import requests, time, re, sys, os

from xmlrpc import client

# API de Production
api = client.ServerProxy('https://rpc.gandi.net/xmlrpc/')

############ A Modifier #############

# URL de la page retournant l'ip publique
url_page = 'http://ifconfig.me/ip'

# Renseignez ici votre clef API générée depuis l'interface Gandi:
apikey = os.getenv('gandiapikey')

# Domaine concerné
mydomain = 'mondomaineamoi.org'

# Enregistrement à modifier
myrecord = {'name': 'monserveur', 'type': 'A'}

# TTL
myttl = 300

api.domain.list(apikey, {'items_per_page': 10, 'page': 0})
# id de la zone concernée (à récupérer depuis l'interface Gandi) 
zone_id = xxxxxx

####################################

# Récupération de l'ancienne ip
oldip = api.domain.zone.record.list(apikey, zone_id, 0, myrecord)[0].get('value')

try:
    # Récupération de l'ip actuelle
    f = requests.get(url_page)
    data = f.read()
    f.close()
    pattern = re.compile('\d+\.\d+\.\d+\.\d+')
    result = pattern.search(data, 0)
    if result == None:
        print("Pas d'ip dans cette page.")
        sys.exit() 
    else:
        currentip = result.group(0)

    # Comparaison et mise à jour si besoin
    if oldip != currentip:
        # On cree une nouvelle version de la zone
        version = api.domain.zone.version.new(apikey, zone_id)
        # Mise a jour (suppression puis création de l'enregistrement)
        api.domain.zone.record.delete(apikey, zone_id, version, myrecord)
        myrecord['value'] = currentip
        myrecord['ttl'] = myttl
        api.domain.zone.record.add(apikey, zone_id, version, myrecord)
        # On valide les modifications sur la zone
        api.domain.zone.version.set(apikey, zone_id, version)
        api.domain.zone.set(apikey, mydomain, zone_id)
        print("Modification de l'enregistrement effectuée avec l'ip: %s" % currentip)
except xmlrpclib.ProtocolError:
    print("Site indisponible.")
finally:
    sys.exit()

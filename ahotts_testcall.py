import sys, requests

host="127.0.0.1"
port="1200"
text="xanna e best"
if len(sys.argv) > 1:
    text=sys.argv[1]
    

url="http://" + host +":" + port + "/ahotts_getaudio"
data={'text': text, 'lang': 'eu', 'voice': {'lang': 'eu', 'name': 'ahotts-eu-female', 'engine': 'ahotts', 'adapter': 'adapters.ahotts_adapter'}, 'speed': '200'}
response1 = requests.post(url, data=data)

files=response1.json()
wavfile=files['wav']
wrdfile=files['wrd']

response2=requests.get("http://" + host + ":" + port + "/ahotts_downloadfile?file="+wavfile)

sys.stderr.write("%s\n" % response2)

print("wav/"+wavfile)


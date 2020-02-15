import sys, requests

host="127.0.0.1"
port="1200"
text="xanna e best"
if len(sys.argv) > 1:
    text=sys.argv[1]
    

url="http://" + host +":" + port + "/ahotts_getaudio"
data={'text': text, 'lang': 'eu', 'voice': {'lang': 'eu', 'name': 'ahotts-eu-female', 'engine': 'ahotts', 'adapter': 'adapters.ahotts_adapter'}, 'speed': '200'}
response1 = requests.post(url, data=data)

if response1.status_code==200:
    
    files=response1.json()
    wavfile=files['wav']
    wrdfile=files['wrd']
    
    response2=requests.get("http://" + host + ":" + port + "/ahotts_downloadfile?file="+wavfile)
    if response1.status_code==200:
        print("wav/"+wavfile)
    else:
        print("FAIL", response2)
        sys.exit(1)

else:
    print("FAIL", response1)
    sys.exit(1)


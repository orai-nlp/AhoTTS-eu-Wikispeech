import BaseHTTPServer
import urlparse
import hashlib,socket,struct,os,json,sys

def socket_write_filelength_file(tts_socket,filename):
    file_length=os.stat(filename).st_size
    length_struct=struct.Struct('11s')
    length_struct_packed=length_struct.pack(str(file_length).encode('utf-8'))
    totalsent=0
    while totalsent<len(length_struct_packed):
	sent=tts_socket.send(length_struct_packed[totalsent:])
	if sent==0:
	    raise RuntimeError("socket connection broken")
	totalsent=totalsent+sent
    inputfile=open(filename,"rb")
    left=inputfile.read(1024)
    while (left):
	sent=tts_socket.send(left)
	if sent==0:
	    raise RuntimeError("socket connection broken")
	left=inputfile.read(1024)
    inputfile.close()

def socket_read_filelength_file(tts_socket):
    chunks=[]
    bytes_recd=0
    while bytes_recd<11:
	chunk=tts_socket.recv(11-bytes_recd)
	if chunk==b'':
	    raise RuntimeError("socket connection broken")
	chunks.append(chunk)
	bytes_recd=bytes_recd+len(chunk)
    length_struct_packed=b''.join(chunks)
    length_struct=struct.Struct('11s')
    file_length=length_struct.unpack(length_struct_packed)[0]
    file_length=file_length[:file_length.find(b'\x00')]
    file_length=int(file_length)
    chunks=[]
    bytes_recd=0
    while bytes_recd<file_length:
	chunk=tts_socket.recv(min(file_length-bytes_recd,2048))
	if chunk==b'':
	    raise RuntimeError("socket connection broken")
	chunks.append(chunk)
	bytes_recd=bytes_recd+len(chunk)
    return b''.join(chunks)




class AhoTTS_HTTPServer(BaseHTTPServer.BaseHTTPRequestHandler):

	def do_GET(self):
		if "ahotts_downloadfile" in self.path:
			params={}
			for key,value in dict(urlparse.parse_qsl(self.path.split("?")[1], True)).items():
				params[key]=value
				wholefilename=params['file']
				print "download file: "+wholefilename
				filename,file_extension=os.path.splitext(wholefilename)
				if file_extension=='wav':
				    self.send_response(200)
				    self.send_header('Content-type','')
				    self.end_headers()
				    f=open("wav/"+wholefilename,'rb')
				    self.wfile.write(f.read())
				    f.close()
				else:
				    self.send_response(200)
				    self.send_header('Content-type','audio/wav')
				    self.end_headers()
				    f=open("wav/"+wholefilename,'rt')
				    self.wfile.write(f.read())
				    f.close()
		else:
			self.send_response(200)
		return
  
	def do_POST(self):
		if "ahotts_getaudio" in self.path:
			if self.rfile:
				params={}
				for key,value in dict(urlparse.parse_qs(self.rfile.read(int(self.headers['Content-Length'])))).items():
					params[key]=value
				input=params['text'][0]
				lang=params['lang'][0]
				voice=params['voice'][0]
				speed=params['speed'][0]
				hashstring=input+'&Lang='+lang+'&Voice='+voice
				print "get audio: "+hashstring
				try:
					hash_object=hashlib.md5(hashstring.encode('latin-1'))
				except:
					try:
						hash_object=hashlib.md5(hashstring.encode('utf-8'))
					except:
						try:
							hash_object=hashlib.md5(hashstring.encode())
						except:
							hash_object=hashlib.md5(hashstring)
				hashnumber=hash_object.hexdigest()
				# Write text to file
				inputfilename="txt/tts_%s.txt" % (hashnumber)
				inputfile=open(inputfilename,"wb")
				inputfile.write(input+'\n')
				inputfile.close()
				# Open socket
				socketa=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
				socketa.connect((sys.argv[1],int(sys.argv[3])))
				# Write options
				options_struct=struct.Struct('4s 4s 4s 1024s 1024s 1024s ?')
				options_struct_packed=options_struct.pack(lang.encode('utf-8'),"".encode('utf-8'),speed.encode('utf-8'),"".encode('utf-8'),("wav/tts_%s.pho" % hashnumber).encode('utf-8'),("wav/tts_%s.wrd" % hashnumber).encode('utf-8'),True)
				totalsent=0
				while totalsent<len(options_struct_packed):
					sent=socketa.send(options_struct_packed[totalsent:])
					if sent==0:
						raise RuntimeError("socket connection broken")
					totalsent=totalsent+sent
				# Write text file length + text file
				socket_write_filelength_file(socketa,inputfilename)
				# Read wav file
				wavfilename="wav/tts_%s.wav" % (hashnumber)
				wavfile=open(wavfilename,"wb")
				wavfile.write(socket_read_filelength_file(socketa))
				wavfile.close()
				# Read pho file
				socket_read_filelength_file(socketa)
				# Read wrd file
				wrdfilename="wav/tts_%s.wrd" % (hashnumber)
				wrdfile=open(wrdfilename,"wb")
				wrdfile.write(socket_read_filelength_file(socketa))
				wrdfile.close()
				# Close socket
				socketa.close()
				self.send_response(200)
				self.send_header('Content-type','application/json')
				self.end_headers()
				self.wfile.write(json.dumps({'wav':"tts_%s.wav" % (hashnumber),'wrd':"tts_%s.wrd" % (hashnumber)}))
		return



	def log_request(self, code=None, size=None):
		return

if __name__ == "__main__":
	try:
		address=sys.argv[1]
		port=sys.argv[2]
		print 'starting server',sys.argv[1],sys.argv[2]
		BaseHTTPServer.HTTPServer((sys.argv[1],int(sys.argv[2])),AhoTTS_HTTPServer).serve_forever()
	except KeyboardInterrupt:
		print('shutting down server')

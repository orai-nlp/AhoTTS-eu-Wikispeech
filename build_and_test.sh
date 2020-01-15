# build script for Wikispeech
# mimic travis build tests, always run before pushing!

set -e
RELEASE=master

basedir=`dirname $0`
basedir=`realpath $basedir`
cd $basedir
builddir="${basedir}/.build"
mkdir -p .build

for proc in `ps --sort pid -Af|egrep 'tts_server|ahotts' | egrep -v 'docker.*build' | egrep -v  "grep .E"|sed 's/  */\t/g'|cut -f2`; do
    kill $proc || echo "Couldn't kill $pid"
done


## AHOTTS
cd $builddir
git clone https://github.com/stts-se/AhoTTS-eu-Wikispeech.git && cd AhoTTS-eu-Wikispeech || cd AhoTTS-eu-Wikispeech && git pull
git checkout $RELEASE || echo "No such release for ahotts. Using master."
if [ ! -f bin/tts_server ]; then
    sh script_compile_all_linux.sh && mkdir -p txt wav
fi
sh start_ahotts_wikispeech.sh &
export ahotts_pid=$!
echo "ahotts started with pid $ahotts_pid"
sleep 5
python ahotts_testcall.py "test call for ahotts"

for proc in `ps --sort pid|egrep 'tts_server|ahotts|python' | egrep -v  "grep .E"|sed 's/  */\t/g'|cut -f2`; do
    kill $proc || echo "Couldn't kill $pid"
done

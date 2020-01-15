# build script for Wikispeech
# mimic travis build tests, always run before pushing!

set -e

for proc in `ps --sort pid -Af|egrep 'tts_server|ahotts' | egrep -v 'docker.*build' | egrep -v  "grep .E"|sed 's/  */\t/g'|cut -f2`; do
    kill $proc || echo "Couldn't kill $pid"
done


## AHOTTS
if [ ! -f bin/tts_server ]; then
    sh script_compile_all_linux.sh && mkdir -p txt wav
fi
sh start_ahotts_wikispeech.sh &
export ahotts_pid=$!
echo "ahotts started with pid $ahotts_pid"
sleep 5
python ahotts_testcall.py "test call for ahotts"

for proc in `ps -f --sort pid|egrep 'tts_server|ahotts|python' | egrep -v  "grep .E"|sed 's/  */\t/g'|cut -f2`; do
    kill $proc || echo "Couldn't kill $pid"
done

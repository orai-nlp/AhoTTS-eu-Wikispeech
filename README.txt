Text-to-Speech conversor for Basque and Spanish

-----------------------------------------------

LICENSE: Read COPYRIGHT_and_LICENSE_code.txt and COPYRIGHT_and_LICENSE_voices.txt

INSTALLATION (in linux environments)
    sh script_compile_all_linux.sh

RUN (in linux environments)
    sh start_ahotts_wikispeech.sh

TEST
    python ahotts_testcall.py <text>

FOLDERS:
    libhtts: code of the library
    tts: code of examples using the library
    data_tts: all the necessary data files for each language
    lib: where the library will be stored
    bin: where example binaries will be installed
    wav: where the output audio files are saved

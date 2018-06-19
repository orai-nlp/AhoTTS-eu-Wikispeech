# Download sttsse/wikispeech_base from hub.docker.com | source repository: https://github.com/stts-se/wikispeech_compose: docker/wikispeech_base
FROM sttsse/wikispeech_base

LABEL "eus.elhuyar.vendor"="Elhuyar Fundazioa - https://www.elhuyar.eus/"

RUN mkdir -p /wikispeech/bin
WORKDIR "/wikispeech"

##################### INSTALL AhoTTS-eu-Wikispeech #####################
RUN apt-get install -y cmake

RUN git clone https://github.com/Elhuyar/AhoTTS-eu-Wikispeech.git

WORKDIR "/wikispeech/AhoTTS-eu-Wikispeech"

RUN chmod a+x script_compile_all_linux.sh
RUN ./script_compile_all_linux.sh

##################### AFTER INSTALL #####################

WORKDIR "/wikispeech"


# BUILD INFO
ENV BUILD_INFO_FILE /wikispeech/.ahotts-eu-wikispeech_build_info.txt
RUN echo "Application name: ahotts-eu-wikispeech"  >> $BUILD_INFO_FILE
RUN echo -n "Build timestamp: " >> $BUILD_INFO_FILE
RUN date --utc "+%Y-%m-%d %H:%M:%S %Z" >> $BUILD_INFO_FILE
RUN echo "Built by: docker" >> $BUILD_INFO_FILE
RUN echo -n "Git release: " >> $BUILD_INFO_FILE
RUN cd /wikispeech/AhoTTS-eu-Wikispeech && git describe --tags --always >> $BUILD_INFO_FILE

## RUNTIME SETTINGS
WORKDIR "/wikispeech/AhoTTS-eu-Wikispeech"
CMD bin/tts_server -IP=127.0.0.1 -Port=1200


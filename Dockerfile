FROM buildpack-deps

############# INITIAL SETUP/INSTALLATION #############
# setup apt
RUN apt-get update -y && apt-get upgrade -y && apt-get install apt-utils -y

LABEL "eus.elhuyar.vendor"="Elhuyar Fundazioa - https://www.elhuyar.eus/"

############# COMPONENT SPECIFIC DEPENDENCIES #############
RUN apt-get install -y cmake
RUN apt-get install -y python

############# WIKISPEECH #############
ENV BASEDIR /wikispeech/AhoTTS-eu-Wikispeech
WORKDIR $BASEDIR

# local copy of https://github.com/elhuyar/AhoTTS-eu-Wikispeech.git 
COPY . $BASEDIR

WORKDIR $BASEDIR

RUN sh script_compile_all_linux.sh

RUN mkdir -p $BASEDIR/txt
RUN mkdir -p $BASEDIR/wav


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
WORKDIR $BASEDIR
EXPOSE 1200
CMD sh start_ahotts_wikispeech.sh


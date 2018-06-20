
if [ $# -ne 1 ]; then
    echo "USAGE: mk_release.sh <release-tag>"
    exit 1
fi

#TAG="0.3.0beta4"
TAG=`echo $1 | sed 's/^\([^v]\)/v\1/'`
shorttag=$TAG
longtag=$shorttag

createReleaseTag() {
    echo ""
    echo "(1) COMMANDS FOR RELEASE TAGS - COPY AND RUN!"
    
    tagcmd="git tag -a $shorttag -m \"$longtag\""
    pushcmd="git push origin $shorttag"

    cmd="$tagcmd && $pushcmd"
    echo "    $cmd"
    echo ""
}

buildDockerImages() {
    cache="--no-cache"
    echo "(2) COMMANDS FOR GENERATING AND PUBLISHING DOCKER IMAGES"
    
    echo "    docker build --build-arg RELEASE=$TAG $cache . -t elhuyar/ahotts-eu-wikispeech:$shorttag

    ### PAUSE ###
    
    docker push elhuyar/ahotts-eu-wikispeech:$shorttag"

    echo "" && echo ""
}

echo "RELEASE TAG: $TAG"

createReleaseTag
buildDockerImages


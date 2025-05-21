FROM debian

LABEL version="0.2"
RUN apt-get update -y
RUN apt-get install openssh-client -y
RUN apt-get install rsync -y
RUN apt-get install inotify-tools -y
RUN apt-get install sudo -y

ADD syncScript.sh /syncScript.sh

ENTRYPOINT ["/syncScript.sh"]

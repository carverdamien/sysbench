FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
&&  apt-get install -y build-essential automake libtool mysql-server mysql-client libmysqlclient-dev
WORKDIR /home
COPY . .
RUN ./autogen.sh \
&&  ./configure  \
&&  make         \
&&  make install
RUN sysbench --test=fileio --file-total-size=1G prepare
CMD sysbench --test=fileio --file-total-size=1G --file-test-mode=rndrw --init-rng=on --max-time=60 --report-interval=1 --max-requests=0 run
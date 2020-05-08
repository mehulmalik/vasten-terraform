#Import the required operating system
FROM centos:7

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

ADD app /usr/src/app

RUN yum update -y

ARG mount_ip

RUN yum install -y openmpi-bin openmpi-common openssh-client openssh-server libopenmpi1.3 libopenmpi-dbg libopenmpi-dev make wget

RUN yum install -y mount nfs-common gcc openssl-devel bzip2-devel libffi libffi-devel

COPY lars.lic /usr/src/app

RUN wget https://www.dropbox.com/s/jost9y1sagb2l6n/build_02_14_20.tar.gz

RUN tar xzf build_02_14_20.tar.gz

#RUN mkdir -p mount-point-directory

#RUN sudo mount ${var.mount_ip}:/vastenshare1 ../mount-point-directory

COPY hostfile.txt /usr/src/app

ENV VSIM_LICENSE_FILE=/usr/src/app/lars.lic

ENV VSIM_INSTALL_DIR=/usr/src/app

ENV OPAL_PREFIX=$VSIM_INSTALL_DIR/opt

ENV PATH=$OPAL_PREFIX/bin:$VSIM_INSTALL_DIR/bin:$PATH

ENV LD_LIBRARY_PATH=$OPAL_PREFIX/lib

CMD tail -f /dev/null

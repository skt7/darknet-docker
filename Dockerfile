#base image
FROM ubuntu

#disable interactive mode
ARG DEBIAN_FRONTEND=noninteractive

#installing
RUN apt-get -y update 
RUN apt-get -y upgrade 
RUN apt-get install -y make
RUN apt-get install -y git 
RUN apt-get install -y wget
RUN apt-get install -y unzip
RUN apt-get install -y vim
RUN apt-get install -y build-essential
RUN apt-get install -y cmake
RUN apt-get install -y python3

#cloning darknet repo
RUN git clone https://github.com/AlexeyAB/darknet.git

#build darknet
WORKDIR /darknet
RUN sed -i 's/LIBSO=0/LIBSO=1/g' Makefile
RUN make

#download yolo weights
RUN wget https://pjreddie.com/media/files/yolov3.weights

#installing nginix
RUN apt-get install -y nginx
RUN apt-get install -y ca-certificates

#install pip
RUN apt-get install -y python3-pip

#installing libraries
RUN pip3 install numpy pandas flask gevent gunicorn 
RUN pip3 install pillow

#adding serving files
COPY nginx.conf /darknet
COPY predictor.py /darknet
COPY serve /darknet
COPY wsgi.py /darknet

RUN chmod +x nginx.conf
RUN chmod +x serve
RUN chmod +x predictor.py
RUN chmod +x wsgi.py

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/darknet:${PATH}"

CMD ["python3", "serve"]



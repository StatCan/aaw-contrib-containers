# syntax=docker/dockerfile:1

FROM debian:stable

# Not sure what this does.
# ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y sqlite3 && \
    apt-get install -y apt-utils && \
    apt-get install -y unixodbc && \
    apt-get autoclean

# Not necessary for now:
# RUN apt-get install -y openmpi-bin &&
#     apt-get autoclean

#Set local timezone:
RUN rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Toronto /etc/localtime

# Set working directory:
WORKDIR / 

RUN mkdir openmpp && cd openmpp && \
    wget https://github.com/openmpp/main/releases/download/v1.15.4/openmpp_debian_20230803.tar.gz && \
    tar -xf openmpp_debian_20230803.tar.gz

# Something is not working with this reductive setup below, so keeping the whole archive for now...
# Create the appropriate directory structure and just the stuff necessary for running the UI:
# RUN cd /openmpp/openmpp_debian_20230803 && \
#     mkdir /openmpp/bin && \
#     mv bin/oms ../bin/ && \
#     mv bin/dbcopy ../bin/ && \
#     mkdir /openmpp/html && \
#     mv html ../ && \
#     mkdir /openmpp/etc && \
#     mv etc ../etc && \
#     mkdir ../log && \
#     mkdir -p /openmpp/models/bin && \
#     mkdir /openmpp/models/home && \
#     mkdir /openmpp/models/log && \
#     mv models/bin ../models && \
#     mv models/home ../models && \
#     mv models/log ../models 

# Remove archive and unnecessary files from image:
# RUN rm -R /openmpp/openmpp_debian_20230803 && rm /openmpp/openmpp_debian_20230803.tar.gz

 
# Since I'm downloading from an archive I don't expect to copy over much locally.
# Maybe an ini file as an alternative to command line configuration options?
# COPY ?

WORKDIR /openmpp/openmpp_debian_20230803

CMD ["./bin/oms","-oms.HomeDir", "./models/home", "-oms.AllowDownload", "-oms.AllowUpload", "-oms.AllowMicrodata","-l", ":4040", "-OpenM.LogToFile", "-OpenM.LogFilePath", "./log/oms.log", "-OpenM.LogUseDailyStamp"]

# Expose default port for OpenM++ web service:
EXPOSE 4040
                    

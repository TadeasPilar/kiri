
# This docker image will be used as a base for further kicad project processing. 
# If you only care about running KiRI, you can inherit from debian directly.
# FROM debian
FROM ghcr.io/inti-cmnb/kicad6_auto:dev as kiri_deb
RUN apt-get clean && \
    apt-get update -y && \
    apt-get install apt-utils python3-pip python3-testresources ssh git sudo nano -y


RUN apt-get install libatspi2.0-0=2.38.0-4 libcurl4=7.74.0-1.3+deb11u3 libatk-bridge2.0-0=2.38.0-1 libatspi2.0-dev libatk1.0-0=2.36.0-2 libepoxy0=1.5.5-1 -y --allow-downgrades
RUN apt-get install curl -y 
RUN apt-get install libelf1=0.183-1 -y --allow-downgrades
RUN pip3 install attrdict
#Downgrade libraries to allow installing libgtk-3-dev
RUN apt-get install libepoxy0=1.5.5-1 libatspi2.0-0=2.38.0-4 libatk1.0.0=2.36.0-2 libatk-bridge2.0-0=2.38.0-1 -y --allow-downgrades
RUN apt-get install pkg-config libgtk-3-dev -y
RUN pip3 install --no-compile --verbose "wxpython>=4.0.7"

RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/TadeasPilar/kiri/main/install_dependencies.sh)"
RUN echo -e "\n" | bash -c "INSTALL_KIRI_REMOTELLY=1; $(curl -fsSL https://raw.githubusercontent.com/TadeasPilar/kiri/main/install_kiri.sh)"

RUN echo 'eval $(opam env);' >> /root/.bashrc
RUN echo 'export KIRI_HOME=${HOME}/.local/share/kiri;' >> /root/.bashrc 
RUN echo 'export PATH=${KIRI_HOME}/submodules/KiCad-Diff/bin:${PATH};' >> /root/.bashrc 
RUN echo 'export PATH=${KIRI_HOME}/bin:${PATH};' >> /root/.bashrc

SHELL ["/bin/bash", "-c", "-l"]

FROM kiri_deb as kiri_run

COPY ./project ./project

ENV DISPLAY=:0.0
ENTRYPOINT  cd project && \
            xvfb-run kiri && \
            mv .kiri kiri

#wxpython compile runtime - 21:23 3.97GB
#wxpython non-compile runtime - 19:16 / 3.97GB
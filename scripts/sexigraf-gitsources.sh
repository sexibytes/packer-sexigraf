# retrieve and unzip source
echo "Retrieving SexiGraf sources"
#
wget -q --no-proxy https://github.com/sexibytes/sexigraf/archive/dev6.zip -O /tmp/sexigraf-src.zip
unzip /tmp/sexigraf-src.zip -d /tmp/
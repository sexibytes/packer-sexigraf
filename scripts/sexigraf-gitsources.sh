# retrieve and unzip source
echo "Retrieving SexiGraf sources"
if [ $# -gt 0 ]; then
  export http_proxy=$1
  export https_proxy=$1
fi

wget -q --no-proxy https://github.com/sexibytes/sexigraf/archive/dev6.zip -O /tmp/sexigraf-src.zip
unzip /tmp/sexigraf-src.zip -d /tmp/

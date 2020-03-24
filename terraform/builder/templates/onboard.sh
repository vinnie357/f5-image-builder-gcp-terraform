# logging
LOG_FILE=/var/log/startup-script.log
if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi

exec 1>$LOG_FILE 2>&1

# get atc packages
# CHECK TO SEE NETWORK IS READY
count=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "internet access check passed"
    break
  elif [ $count -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    count=$[$count+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done
# download latest atc tools
toolsList=$(cat -<<EOF
{
  "tools": [
      {
        "name": "f5-declarative-onboarding",
        "version": "${doVersion}",
        "url": ""
      },
      {
        "name": "f5-appsvcs-extension",
        "version": "${as3Version}",
        "url": ""
      },
      {
        "name": "f5-telemetry-streaming",
        "version": "${tsVersion}",
        "url": ""
      },
      {
        "name": "f5-cloud-failover-extension",
        "version": "${cfVersion}",
        "url": ""
      },
      {
        "name": "f5-appsvcs-templates",
        "version": "${fastVersion}",
        "url": ""
      }

  ]
}
EOF
)
function getAtc () {
atc=$(echo $toolsList | jq -r .tools[].name)
for tool in $atc
do
    version=$(echo $toolsList | jq -r ".tools[]| select(.name| contains (\"$tool\")).version")
    if [ $version == "latest" ]; then
        path=''
    else
        path='tags/v'
    fi
    echo "downloading $tool, $version"
    if [[ $tool == "f5-cloud-failover-extension" || $tool == "f5-appsvcs-templates" ]]; then
        files=$(/usr/bin/curl -sk https://api.github.com/repos/f5devcentral/$tool/releases/$path$version | jq -r '.assets[] | select(.name | contains (".rpm")) | .browser_download_url')
    else
        files=$(/usr/bin/curl -sk https://api.github.com/repos/F5Networks/$tool/releases/$path$version | jq -r '.assets[] | select(.name | contains (".rpm")) | .browser_download_url')
    fi
    for file in $files
    do
    echo "download: $file"
    name=$(basename $file )
    # make download dir
    mkdir -p /var/tmp/downloads/
    result=$(/usr/bin/curl -Lsk  $file -o /var/tmp/downloads/$name)
    done
done
}

# builder
git init
git clone https://github.com/f5devcentral/f5-bigip-image-generator.git
cd f5-bigip-image-generator
git checkout v${builderVersion}
./setup-build-env --add-dev-tools

# builder config
cat > /f5-bigip-image-generator/config.yml <<EOF
${config}
EOF

# download atc
getAtc
echo "=====done====="
exit
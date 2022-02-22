#!/bin/sh

# Global variables
DIR_CONFIG="/home/rku/AppData/v2fly"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write v2fly configuration
cat << EOF > ${DIR_TMP}/rku.json
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}",
                "email": "vmess_ws@v2fly.com",
                "level": 0
            }]
        },
        "streamSettings": {
            "network": "ws",
            "security": "none",
            "wsSettings": {
                "acceptProxyProtocol": false,
                "path": "${WSPATH}",
                "maxEarlyData": 2048
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get v2fly executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2fly_dist.zip
busybox unzip ${DIR_TMP}/v2fly_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/v2ctl config ${DIR_TMP}/rku.json > ${DIR_CONFIG}/config.pb

# Install v2fly
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run v2fly
${DIR_RUNTIME}/v2ray -config=${DIR_CONFIG}/config.pb

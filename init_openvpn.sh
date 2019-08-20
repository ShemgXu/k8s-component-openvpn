#!/bin/bash
protocol="udp"
server="172.168.50.89"
port="30909"
#openvpn服务器地址
serverPublicUrl="$protocol://$server:$port"
#openvpn dns
dnsParams="-n 218.85.157.99 -n 218.85.152.99"
#vpn隧道子网段
serverSubnetParams="-s 10.10.0.0/16"
#vpn服务器内网网段
#pushParams='-p "route 192.168.0.0 255.255.0.0" -p "route 10.10.0.0 255.255.255.0"'
pushParams='-p "route 10.244.0.0 255.255.0.0" -p "route 10.96.0.0 255.255.0.0"'
clientName="vpn_pub_test"
isUpdateK8s=1

rm -rf ovpn0 && mkdir ovpn0 && cd ovpn0
docker pull kylemanna/openvpn
#推送DNS
#getConfigCommand="docker run --net=none --rm -it -v $PWD:/etc/openvpn kylemanna/openvpn ovpn_genconfig -u $serverPublicUrl -C 'AES-256-GCM' -a 'SHA384' -T 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384' -b $dnsParams $serverSubnetParams $pushParams";
#不推送DNS
getConfigCommand="docker run --net=none --rm -it -v $PWD:/etc/openvpn kylemanna/openvpn ovpn_genconfig -u $serverPublicUrl -C 'AES-256-GCM' -a 'SHA384' -T 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384' -c -d -b -D $serverSubnetParams $pushParams";
eval $getConfigCommand

#2.生成PKI(公钥基础设施)、CA(证书颁发机构)、生成服务端证书、服务端证书签约、创建Diffie-Hellman证书
docker run -e EASYRSA_ALGO=ec -e EASYRSA_CURVE=secp384r1 --net=none --rm -it -v $PWD:/etc/openvpn kylemanna/openvpn ovpn_initpki
#按提示设置密码，比如：shemg

#生成服务端证书
docker run --net=none --rm -it -v $PWD:/etc/openvpn kylemanna/openvpn ovpn_copy_server_files
docker run -e EASYRSA_ALGO=ec -e EASYRSA_CURVE=secp384r1 --net=none --rm -it -v $PWD:/etc/openvpn kylemanna/openvpn easyrsa build-client-full $clientName
#Enter PEM pass phrase: 输入客户端密码
#Verifying - Enter PEM pass phrase: 输入客户端密码
#Enter pass phrase for /etc/openvpn/pki/private/ca.key:输入CA密码

#导出客户端配置文件
docker run --net=none --rm -v $PWD:/etc/openvpn kylemanna/openvpn ovpn_getclient $clientName > $clientName.ovpn

#客户端配置账号密码登录
echo 'verify-client-cert none' >> server/openvpn.conf
echo 'username-as-common-name' >> server/openvpn.conf
echo 'script-security 3' >> server/openvpn.conf
echo 'auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env' >> server/openvpn.conf

#生成的配置信息.ovpn删除证书和秘钥信息<key>...</key>和<cert>...</cert>，并添加如下信息：
keyTagBeginNum=$(grep -n "<key>" ./$clientName.ovpn | cut -d ":" -f 1)
keyTagEndNum=$(grep -n "</key>" ./$clientName.ovpn | cut -d ":" -f 1)
sed -i "$keyTagBeginNum","$keyTagEndNum"d $clientName.ovpn
certTagBeginNum=$(grep -n "<cert>" ./$clientName.ovpn | cut -d ":" -f 1)
certTagEndNum=$(grep -n "</cert>" ./$clientName.ovpn | cut -d ":" -f 1)
sed -i "$certTagBeginNum","$certTagEndNum"d $clientName.ovpn
echo 'auth-user-pass' >> $clientName.ovpn

cp ../psw-file ../checkpsw.sh server

if [ "$isUpdateK8s" = "1" ]; then
    echo "update k8s..."
    kubectl delete secret ovpn0-cert ovpn0-key ovpn0-pki
    kubectl delete configmap ovpn0-conf ccd0
    kubectl delete service ovpn0
    kubectl delete deployment ovpn0

    #服务端秘钥
    kubectl create secret generic ovpn0-key --from-file=server/pki/private/"$server".key
    #服务端证书
    kubectl create secret generic ovpn0-cert --from-file=server/pki/issued/"$server".crt
    #服务端pki
    kubectl create secret generic ovpn0-pki --from-file=server/pki/ca.crt --from-file=server/pki/dh.pem --from-file=server/pki/ta.key
    kubectl create configmap ovpn0-conf --from-file=server/
    kubectl create configmap ccd0 --from-file=server/ccd
    kubectl apply -f ../openvpn.yaml

fi

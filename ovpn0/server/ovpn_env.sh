declare -x OVPN_AUTH=SHA384
declare -x OVPN_CIPHER=AES-256-GCM
declare -x OVPN_CLIENT_TO_CLIENT=
declare -x OVPN_CN=172.168.50.89
declare -x OVPN_COMP_LZO=0
declare -x OVPN_DEFROUTE=1
declare -x OVPN_DEVICE=tun
declare -x OVPN_DEVICEN=0
declare -x OVPN_DISABLE_PUSH_BLOCK_DNS=1
declare -x OVPN_DNS=1
declare -x OVPN_DNS_SERVERS=([0]="218.85.157.99" [1]="218.85.152.99")
declare -x OVPN_ENV=/etc/openvpn/ovpn_env.sh
declare -x OVPN_EXTRA_CLIENT_CONFIG=()
declare -x OVPN_EXTRA_SERVER_CONFIG=()
declare -x OVPN_FRAGMENT=
declare -x OVPN_KEEPALIVE='10 60'
declare -x OVPN_MTU=
declare -x OVPN_NAT=0
declare -x OVPN_PORT=30909
declare -x OVPN_PROTO=udp
declare -x OVPN_PUSH=([0]="route 192.168.0.0 255.255.0.0" [1]="route 10.10.0.0 255.255.255.0")
declare -x OVPN_ROUTES=([0]="192.168.254.0/24")
declare -x OVPN_SERVER=10.10.0.0/24
declare -x OVPN_SERVER_URL=udp://172.168.50.89:30909
declare -x OVPN_TLS_CIPHER=TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384

echo "zenith-os" > /etc/hostname
sed -i -e 's/^root::/root:!:/' /etc/shadow
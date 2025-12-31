#!/bin/bash
## RUN sudo ./prepare_image.sh
# Sprawdzenie, czy skrypt jest uruchomiony z sudo/jako root
if [[ $EUID -ne 0 ]]; then
   echo "BŁĄD: Ten skrypt musi być uruchomiony z uprawnieniami sudo!" 
   echo "Użyj: sudo $0"
   exit 1
fi

echo "--- START: Przygotowanie obrazu Debian 13 ---"

# --- 1. DYNAMICZNY HOSTNAME ---
echo "1/4: Konfigurowanie usługi dynamicznego hostname (blkXXXXXX)..."

cat << 'EOF' > /usr/local/bin/set-dynamic-hostname.sh
#!/bin/bash
MAC=$(cat /sys/class/net/eth0/address 2>/dev/null || cat /sys/class/net/wlan0/address)
if [ -z "$MAC" ] || [ "$MAC" = "none" ]; then exit 1; fi

MAC_CLEAN=$(echo $MAC | tr -d ':')
ID=${MAC_CLEAN: -6}
NEW_HOSTNAME="blk$ID"

hostnamectl set-hostname "$NEW_HOSTNAME"
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
EOF

chmod +x /usr/local/bin/set-dynamic-hostname.sh

# Usługa systemd (zawsze startuje jako root)
cat << 'EOF' > /etc/systemd/system/dynamic-hostname.service
[Unit]
Description=Set dynamic hostname base`d on MAC
Before=network.target
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set-dynamic-hostname.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable dynamic-hostname.service

# --- 2. CZYSZCZENIE APT ---
echo "2/4: Czyszczenie pakietów i cache APT..."
apt-get autoremove -y
apt-get clean

# --- 3. CZYSZCZENIE SYSTEMU ---
echo "3/4: Usuwanie unikalnych identyfikatorów i logów..."

# Czyszczenie logów systemd
journalctl --vacuum-time=0d

# Czyszczenie Machine ID (kluczowe dla DHCP)
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

# Usuwanie dzierżaw DHCP
rm -rf /var/lib/dhcp/*
rm -rf /var/lib/NetworkManager/*.lease

# Usuwanie unikalnych kluczy SSH
rm -f /etc/ssh/ssh_host_*

# Czyszczenie logów tekstowych i katalogów tmp
find /var/log -type f -exec truncate -s 0 {} \;
rm -rf /tmp/*
rm -rf /var/tmp/*

# --- 4. FINALIZACJA ---
echo "4/4: Wyłączanie systemu..."
echo "--------------------------------------------------------"
echo "GOTOWE! Hostname przy starcie zostanie ustawiony na blk[MAC]."
echo "System wyłączy się za 3 sekundy. Potem wyjmij kartę i zrób obraz."
echo "--------------------------------------------------------"

sleep 3
# Czyszczenie historii bieżącej sesji przed samym końcem
history -c
poweroff
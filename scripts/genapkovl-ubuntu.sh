#!/bin/sh -e

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	echo "usage: $0 hostname"
	exit 1
fi

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF
makefile root:root 0644 "$tmp"/etc/inittab <<EOF
# /etc/inittab

::sysinit:/sbin/openrc sysinit
::sysinit:/sbin/openrc boot
::wait:/sbin/openrc default

# Set up a couple of getty's
tty1::respawn:/sbin/agetty --autologin root --noclear 38400 tty1 linux
tty1::respawn:/sbin/agetty --autologin root --noclear 38400 tty2 linux
tty1::respawn:/sbin/agetty --autologin root --noclear 38400 tty3 linux
tty1::respawn:/sbin/agetty --autologin root --noclear 38400 tty4 linux
tty1::respawn:/sbin/agetty --autologin root --noclear 38400 tty5 linux
tty1::respawn:/sbin/agetty --autologin root --noclear 38400 tty6 linux

# Put a getty on the serial port
#ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100

# Stuff to do for the 3-finger salute
::ctrlaltdel:/sbin/reboot

# Stuff to do before rebooting
::shutdown:/sbin/openrc shutdown
EOF

mkdir -p "$tmp"/etc/network
makefile root:root 0644 "$tmp"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
openssl
vim
util-linux
debootstrap
xfsprogs
perl
EOF
makefile root:root 0644 "$tmp"/etc/apk/repositories <<EOF
http://dl-cdn.alpinelinux.org/alpine/edge/main
EOF

mkdir -p "$tmp"/bin
makefile root:root 0755 "$tmp"/bin/arch-chroot <<EOF
#!/bin/sh

set -e
#set -x

[ -d \$1/proc ] || (echo "\$1/proc: does not exist"; exit 1;)
[ -d \$1/sys  ] || (echo "\$1/sys: does not exist"; exit 1;)
[ -d \$1/dev  ] || (echo "\$1/dev: does not exist"; exit 1;)

echo "mounting /proc"
mount -t proc /proc \$1/proc
echo "mounting /sys"
mount -t sysfs /sys \$1/sys
echo "mounting /dev"
mount --rbind /dev \$1/dev

chroot \$1 \$2

echo "unmounting /proc"
umount \$1/proc
echo "unmounting /sys"
umount \$1/sys
echo "unmounting /dev"
umount -R \$1/dev
EOF

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add networking boot

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

tar -c -C "$tmp" etc bin | gzip -9n > $HOSTNAME.apkovl.tar.gz

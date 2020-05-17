# Intro
This repo makes a small ISO which contains all you need when installing Ubuntu system by debootstrap.

Fork from [git://git.alpinelinux.org/aports](https://git.alpinelinux.org/aports/) commit: e51fcde1ce0373940c401afe04929b074ac17a34.

Install a Ubuntu system to a PC can not only use the Ubuntu official ISO, but also use [debootstrap](https://help.ubuntu.com/lts/installation-guide/amd64/apds04.html) which is similar to installation process guided by [ArchLinux](https://wiki.archlinux.org/index.php/installation_guide). The former installs a normal Ubuntu system but with some preloads (e.g. cloud-init, netplan, multipath-tools), and the latter installs a relative "clean" Ubuntu.

Using debootstrap to install Ubuntu needs a running Linux system. In the past, I downloaded Ubuntu server official ISO, then I switched to tty2 and doing everything I needed. But debootstrap downloads all packages to the target system at runtime, the only reason to use the Ubuntu official ISO is that I can get a debootstrap on it.

So this repo makes a small bootable ISO built on the top of AlpineLinux, equipped with all you need when installing Ubuntu.

Why don't I use Ubuntu mini.iso? Because same as official ISO, mini.iso also brings some stuff I don't want to the target system.

# Usage
Have a AlpineLinux Edge system, docker is fine.

Follow the [Prerequisite in the guide](https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage#Prerequisite), but git clone from this repo.

In the [Configuration section](https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage#Configuration), this repo provide two configured files 'mkimg.ubuntu.sh' and 'genapkovl-ubuntu.sh'.

Finally in [Create the ISO](https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage#Create_the_ISO), run the command in the scripts folder:
```
sh mkimage.sh --hostkeys --outdir $PWD/outdir --workdir $PWD/workdir --arch x86_64 --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --profile ubuntu
```
The generated ISO will locate at scripts/outdir.

# Different from official AlpineLinux ISO
* Preload packages relative to Ubuntu installation, e.g. debootstrap, perl. (See scripts/mkimg.ubuntu.sh)
* Change the default apk repository to [http://dl-cdn.alpinelinux.org/alpine/edge/main](http://dl-cdn.alpinelinux.org/alpine/edge/main).
* Auto login on tty1~6. (See scripts/genapkovl-ubuntu.sh)
* Doing DHCP on startup.
* A custom command "arch-chroot" which is similar to arch-chroot in ArchLinux, helping you to mount /proc /sys /dev before chroot into the target system.


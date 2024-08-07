# Arch Linux - Install Guide
[Arch Wiki](https://wiki.archlinux.org/title/installation_guide)
[Arch ISO](http://repos.uo.edu.cu/archlinux/iso/latest/)

## Pre-install

### verify signature

For security proposes

```sh
pacman-key -v archlinux-_version_-x86_64.iso.sig
```

### keyboard layout

```sh
localectl list-keymaps

# set keyboard layout to US
loadkeys us
loadkeys de-latin1
```

### verify boot mode

If the command returns `64`, then system is booted in UEFI mode and has a 64-bit x64 UEFI. If the command returns `32`, then system is booted in UEFI mode and has a 32-bit IA32 UEFI

```sh
cat /sys/firmware/efi/fw_platform_size

# or
ls /sys/firmware/efi/efivars  # If directory exists, EFI is supported.
```

### wifi

```sh
iwctl
device list
device <wlan0> set-property Powered on
station <wlan0> scan
station <wlan0> get-networks
station <wlan0> connect _SSID_
```

### Partitioning

```sh
fdisk -l

# or

lsblk
```

> [!Tip] Check that your NVMe drives and Advanced Format hard disk drives are using the [optimal logical sector size](https://wiki.archlinux.org/title/Advanced_Format "Advanced Format") before partitioning.

The following [partitions](https://wiki.archlinux.org/title/Partition "Partition") are **required** for a chosen device:
- One partition for the [root directory](https://en.wikipedia.org/wiki/Root_directory "wikipedia:Root directory") `/`.
- For booting in [UEFI](https://wiki.archlinux.org/title/UEFI "UEFI") mode: an [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition "EFI system partition").

UEFI with GPT

| Mount point on the installed system | Partition                     | [Partition type](https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs "wikipedia:GUID Partition Table") | Suggested size                               |
| ----------------------------------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| `/efi`                              | `/dev/_efi_system_partition_` | [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition "EFI system partition")                       | 1 GiB                                        |
| `[SWAP]`                            | `/dev/_swap_partition_`       | Linux swap                                                                                                                 | At least 4 GiB                               |
| `/`                                 | `/dev/_root_partition_`       | Linux x86-64 root (/)                                                                                                      | Remainder of the device. At least 23–32 GiB. |

Format 

```sh
fdisk /dev/the_disk_to_be_partitioned

# format EFI partition to fat32
mkfs.fat -F 32 /dev/sd_xY

# format root partition to ext4
mkfs.ext4 -L arch /dev/$ROOT_PARTITION
```

Mount 

```sh
# mount root
mount /dev/root_partition /mnt

# mount EFI
mount --mkdir /dev/boot_partition /mnt/efi
```

Swap File 

```sh
# create swap file
mkswap -U clear --size 4G --file /mnt/swapfile

# activate swap file
swapon /mnt/swapfile

# Finally, edit the fstab configuration to add an entry for the swap file:
/etc/fstab
/swapfile none swap defaults 0 0
```

## Install

### mirrors

```sh
# uninstall reflector
pacman -Rns reflector
```

| mirror    | url                                                           |
| --------- | ------------------------------------------------------------- |
| uo        | `http://repos.uo.edu.cu/archlinux/$repo/os/$arch`             |
| jovenclub | `http://download.jovenclub.cu/repos/archlinux/$repo/os/$arch` |

```sh
vim /etc/pacman.conf
```

### Update GPG keys

```bash
killall gpg-agent
rm -rf /etc/pacman.d/gnupg/

pacman-key --init
pacman-key --populate archlinux 
pacman -Sy archlinux-keyring
```

### Install essential pkgs

See [[apps]] for a full list of packages

```sh
# essencial
pacstrap -i /mnt base linux-lts linux-lts-headers linux-lts-firmware \
				 intel-ucode base-devel \
				 # network
				 networkmanager wpa_supplicant wireless_tools netctl dialog \
				 # bootloader
				 grub efibootmgr dosfstools os-prober mtools
```

| pkg                          | desc                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `intel-ucode`                | CPU [microcode](https://wiki.archlinux.org/title/Microcode "Microcode") updates for hardware bug and security fixes,                                                                                                                                                                                                                                                                                                                                                                                                        |
|                              | [userspace utilities for file systems](https://wiki.archlinux.org/title/File_systems "File systems") that will be used on the system—for the purposes of e.g. file system creation and [fsck](https://wiki.archlinux.org/title/Fsck "Fsck"),                                                                                                                                                                                                                                                                                |
|                              | specific firmware for other devices not included in [linux-firmware](https://archlinux.org/packages/?name=linux-firmware) (e.g. [sof-firmware](https://archlinux.org/packages/?name=sof-firmware) for [onboard audio](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#ALSA_firmware "Advanced Linux Sound Architecture")),                                                                                                                                                                               |
| `network-manager`, `dhcp`    | software necessary for [networking](https://wiki.archlinux.org/title/Networking "Networking") (e.g. [a network manager or a standalone DHCP client](https://wiki.archlinux.org/title/Network_configuration#Network_managers "Network configuration"), [authentication software](https://wiki.archlinux.org/title/Network_configuration/Wireless#Authentication "Network configuration/Wireless") for Wi-Fi, [ModemManager](https://wiki.archlinux.org/title/ModemManager "ModemManager") for mobile broadband connections), |
| vim                          | console editor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `man`, `man-db`, `man-pages` | documentation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

## Configure the system

### copy mirrors

```sh
# backup original
mv /mnt/etc/pacman.conf /mnt/etc/pacman.conf

# copy from livecd
cp /etc/pacman.conf /mnt/etc/pacman.conf
```

### 3. 1 - Fstab

Generate an [fstab](https://wiki.archlinux.org/title/Fstab "Fstab") file (file system table) (use `-U` or `-L` to define by [UUID](https://wiki.archlinux.org/title/UUID "UUID") or labels, respectively):

```sh
# mount ntfs partitions you want to use before

# gen fstab
genfstab -U /mnt >> /mnt/etc/fstab
```

> [!question]- what is fstab?
> The [fstab(5)](https://man.archlinux.org/man/fstab.5) file can be used to define how disk partitions, various other block devices, or remote file systems should be mounted into the file system.

### 3.2 - Chroot

[Change root](https://wiki.archlinux.org/title/Change_root "Change root") into the new system:

```sh
arch-chroot /mnt
```

### 3.3 - Time

Set the [time zone](https://wiki.archlinux.org/title/Time_zone "Time zone"):

```sh
timedatectl set-timezone America/Havana
systemctl enable systemd-timesyncd

# or
ln -sf /usr/share/zoneinfo/America/Havana /etc/localtime
```

Run [hwclock(8)](https://man.archlinux.org/man/hwclock.8) to generate `/etc/adjtime`:

```sh
hwclock --systohc
```


### 3.4 - Localization

Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and other needed UTF-8 [locales](https://wiki.archlinux.org/title/Locale "Locale"). 

```sh
vim /etc/locale.gen

# Generate the locales by running
locale-gen

# Create the locale.conf set the LANG variable
vim /etc/locale.conf
# LANG=en_US.UTF-8
```

If you [set the console keyboard layout](https://wiki.archlinux.org/title/installation_guide#Set_the_console_keyboard_layout_and_font), make the changes persistent in [vconsole.conf(5)](https://man.archlinux.org/man/vconsole.conf.5):

```sh
/etc/vconsole.conf

KEYMAP=de-latin1
```

### 3.5 - Network configuration

[Create](https://wiki.archlinux.org/title/Create "Create") the [hostname](https://wiki.archlinux.org/title/Hostname "Hostname") file:

```sh
vim /etc/hostname

/etc/hostname

yourhostname
```

Edit `/etc/hosts`

```sh
vim /etc/hosts

# add
127.0.0.1 localhost
127.0.0.1 <hostname>
```

Enable Network Manage on startup

```sh
systemctl enable NetworkManager
```


### 3.6 - Root password

```sh
# set a root password
passwd
```

Create a user

```sh
useradd -m -g users -G wheel <user>
passwd <user>

pacman -S sudo 
```

Associate the wheel group with sudo

```sh
# EDITOR=vim visudo

# Uncomment %wheel ALL=(ALL) ALL
```

### 3.7 - Boot loader

```sh
pacman -S 

grub-install --target=x86_64-efi --bootloader-id=grub --recheck
# if does not exist -> mkdir /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

# go to /etc/default/grub
# uncomment last line
grub-mkconfig -o /boot/grub/grub.cfg
```

## Reboot

```sh
exit

# unmount all partitions
umount -R /mnt

reboot
```


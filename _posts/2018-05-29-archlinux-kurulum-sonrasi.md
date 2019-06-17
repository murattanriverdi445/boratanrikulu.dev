---
layout: post
title: "Archlinux - Kurulum Sonrası"
tags: [GNU/Linux]
subtitle: "archlinux + xfce = rocks!"
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

--- 

**NOT 1:** Kurulumu gerçekleştirebilmeniz için orta seviye GNU/LINUX bilginiz olması gerekmektedir, aşağıdaki anlatım da buna uygun olarak hazırlanmıştır. **Kurulum sırasında yaşayabileceğiniz herhangi bir sorun, sorumluluğum altında değildir.**  

**NOT 2:** Adımlar XFCE masaüstüne uygun olacak şekildedir. Bazı paket yüklemeleri tercihendir. Kendi kişisel zevkinize göre şekillendirebilirsiniz.

**Not 3:** Adımlar Intel + Nvidia sistemlere uygun olacak şekilde yapılmıştır. Açık kaynak sürücülerin kurulumu yapılmıştır.

**Not 4:** Ne yaptığınızı bilmiyorsanız adımları uygulamayın.

---

## XORG Kurulumu

Xorg kurulumu için aşağıdaki işlemleri yapmanız gerekmektedir.
```
	sudo pacman -S xorg xorg-xinit
```  
```
	sudo pacman -S pulseaudio pulseaudio-alsa
```  
```
	sudo pacman -S xf86-video-intel
```  
```
	sudo pacman -S libva-vdpau-driver libvdpau-va-gl libva-intel-driver
```  
Aşağıdaki gibi dosya oluşturun  
```
	sudo nano /etc/X11/xorg.conf.d/20-intel.conf
```
```
	Section	"Device"
		Identifier		"Intel Graphics"
		Driver			"intel"
	EndSection

```
Ayrıca aşağıdaki parametreyi grub'a ekleyebilirsiniz.  
```
	intel_idle.max_cstate=1
```

---

## XFCE4 Kurulumu

XFCE4 kurulumu için aşağıdaki gibi bir yol izleyebilirsiniz. Gerekli görülen bazı paketleri de aşağıdaki gibi kurmanızı öneririm.
```
	sudo pacman -S xfce4
```  
```
	echo "exec startxfce4" > .xinitrc
```  
```
	sudo pacman -S xfce4-pulseaudio-plugin pavucontrol xfce4-notifyd xfce4-notes-plugin xfce4-screenshooter xfce4-clipman-plugin xfce4-taskmanager slock
```  
```
	sudo pacman -S gedit gnome-system-log gnome-logs gnome-calculator gnome-disk-utility evince
```  
```
	sudo pacman -S viewnior unrar p7zip file-roller htop screenfetch
```  
```
	sudo pacman -S gvfs gvfs-mtp ntfs-3g
```  
```
	sudo pacman -S arc-gtk-theme arc-icon-theme gtk-engine-murrine conky
```  
```
	sudo pacman -S firefox vlc
```  
Bilgisayar uykuya alındığında otomatik olarak slock ile kitlenmesi için aşağıdaki gibi bir servis oluşturun.
```
	sudo nano /etc/systemd/system/slock@.service
```
```
	[Unit]
	Description=Lock X session using slock for user %i
	Before=sleep.target

	[Service]
	User=%i
	Environment=DISPLAY=:0
	ExecStartPre=/usr/bin/xset dpms force suspend
	ExecStart=/usr/bin/slock

	[Install]
	WantedBy=sleep.target
```
Ardından enable çekin.
```
	sudo systemctl enable slock@USERNAME.service
```

---

## LightDM Kurulumu

LightDM'i aşağıdaki gibi kurabilirsiniz.

```
	sudo pacman -S lightdm
```  
```
	sudo pacman -S lightdm-gtk-greeter lightdm-gtk-greeter-settings
```  
```
	sudo systemctl enable lightdm.service
```  

---

## Network Paketlerinin Kurulumu

Network ile ilgili paketleri aşağıdaki gibi kurabilirsiniz.
```
	sudo pacman -S networkmanager network-manager-applet gnome-keyring
```  
```
	sudo pacman -S openvpn openssh
```  
```
	sudo systemctl enable NetworkManager.service
```  

---

## Güvenlik Duvarının Kurulumu

Güvenlik duvarı olarak UFW basit ve etkili bir çözüm olacaktır. Aşağıdaki gibi kurabilirsiniz.

```
	sudo pacman -S ufw && sudo systemctl enable ufw
```  
```
	sudo ufw enable && sudo ufw status verbose
```  

---

## Klavye Dilinin Belirlenmesi

Klavye'nin X'de Türkçe olarak ayarlanması için aşağıdaki adımları uygulamanız gerekmektedir.
```
	sudo localectl --no-convert set-x11-keymap tr
```  
Sonucu aşağıdaki gibi kontrol edebilirsiniz.
```
	less /etc/X11/xorg.conf.d/00-keyboard.conf
```  

---

## Trizen Kurulumu

AUR Helper olarak yaourt kullanmanızı tavsiye etmiyorum. Trizen kullanım açısından basit ve güvenilirdir. Aşağıdaki gibi kurabilirsiniz. [**[1]**](https://wiki.archlinux.org/index.php/AUR_helpers) [**[2]**](https://www.reddit.com/r/archlinux/comments/4azqyb/whats_so_bad_with_yaourt/)  

```
	sudo pacman -S git
```  
```
	cd Downloads && git clone https://aur.archlinux.org/trizen.git
```  
```
	cd trizen && makepkg -si
```  

**[1] :**  https://wiki.archlinux.org/index.php/AUR_helpers  
**[2] :**  https://www.reddit.com/r/archlinux/comments/4azqyb/whats_so_bad_with_yaourt/

---

## CUPS Kurulumu

```
	sudo pacman -S cups
```
```
	sudo systemctl start org.cups.cupsd.service
```
```
	sudo pacman -S hplip
```
```
	hp-plugin -i
```
Ardından aşağıdaki adrese gidip konfigürasyonu yapabilirsiniz.
```
	localhost:631/
```

---

## Tavsiye Edilen Bazı Uygulamalar

Aşağıdaki adımlar **tamamen kişiseldir**. Eğer sizin de benzer ihtiyaçlarınız var ise aşağıdaki gibi kurabilirsiniz.

**Komutların ne yaptığını bilmiyorsanız kullanmayın!**

```
	sudo pacman -S gimp kdenlive frei0r-plugins breeze-icons audacity libreoffice-fresh qt4 bleachbit catfish transmission-gtk simplescreenrecorder telegram-desktop mypaint nmap smplayer smplayer-themes smplayer-icons gparted baobab python-pip rofi net-tools
```  
```
	sudo pacman -S jre9-openjdk-headless jre9-openjdk jdk9-openjdk openjdk9-doc openjdk9-src
```  
```
	sudo pacman -S virtualbox virtualbox-host-modules-arch linux-headers
```  
```
	sudo modprobe vboxdrv && sudo gpasswd -a username vboxusers
```  
```
	trizen -S paper-icon-theme-git spotify
```  
```
	curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg 
```  
```
	echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
```  
```
	sudo pacman -Syu sublime-text
```  
```
	sudo ufw enable
```  

## Bazı Link'ler

[useradd: group 'nogroup' does not exist](https://bbs.archlinux.org/viewtopic.php?id=75693)  
[Pacman Similarities with Others](https://wiki.archlinux.org/index.php/Pacman/Rosetta)  
[Group List](https://wiki.archlinux.org/index.php/users_and_groups#Group_list)  
[Xorg](https://wiki.archlinux.org/index.php/xorg#Driver_installation)  
[Blicklist Nouveau](https://wiki.archlinux.org/index.php/nouveau#Keep_NVIDIA_driver_installed)

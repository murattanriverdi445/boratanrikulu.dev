---
layout: post
title: "Archlinux - Temel Kurulum"
tags: [GNU/Linux]
subtitle: "archlinux + xfce = rocks!"
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

**Kaynaklar**  
[wiki.archlinux.org/installation_guide](https://wiki.archlinux.org/index.php/Installation_guide)  
[youtube.com/AverageLinuxUser](https://www.youtube.com/watch?v=GKdPSGb9f5s)

--- 

**NOT 1:** Kurulumu gerçekleştirebilmeniz için orta seviye GNU/LINUX bilginiz olması gerekmektedir, aşağıdaki anlatım da buna uygun olarak hazırlanmıştır. **Kurulum sırasında yaşayabileceğiniz herhangi bir sorun, sorumluluğum altında değildir.**  

**NOT 2:** Kurulum **UEFI** sistemlere uygun olacak şekilde yapılmıştır.

**NOT 3:** Kurulum sırasında, ethernet kullanmanızı öneririm. Wifi bağlantıları sorun çıkarabiliyor. Ama yine de wifi kullanmanız gerekyor ise **wifi-menu** kullanabilirsiniz.

**Not 4:** Ne yaptığınızı bilmiyorsanız adımları uygulamayın.

---  

## Temel İşler
Türkçe klavyeyi terminalde kullanabilmek için load'layın.
```
	loadkeys trq
```  
Bağlantınızı test etmek için herhangi bir yere ping atabilirsiniz.
```
	ping -c 3 archlinux.org
```  
Sistem saatinin doğrulu için aşağıdaki komutu yürütün.
```
	timedatectl set-ntp true
```  

---

## Disklerin Ayarlanması

Cihazınızdaki disklerin durumunu görebilmek için lsblk kullanabilirsiniz.
```
	lsblk
```  
Diskinizi aşağıdaki üçe ayırmanızı öneririm.

| Disk          | Boyutu | Dizin    |
|:-------------:|:------:|:--------:|
| **/dev/sdx1** | ~30GB  | /       |
| **/dev/sdx2** | ~550MB  | /boot/efi |
| **/dev/sdx3** | Kalan Disk  | /home |

Diskinizi ayırmak için **cfdisk** tool'unu kullanabilirsiniz. Kullanımı oldukça basittir.  
Disk type'larını doğru girmeniz önemlidir, aşağıdaki fotoğraftaki gibi yapabilirisiniz.

<p align="center"> 
	<img src="/img/archlinux-kurulum-rehberi/1.png">
</p>

ROOT bölümünü EXT4 olarak biçimlendirin.
```
	mkfs.ext4 /dev/sdx1
```  
EFI bölümünü FAT32 olarak biçimlendirin.
```
	mkfs.fat -F32 /dev/sdx2
```  
HOME bölümünü EXT4 olarak biçimlendirin.
```
	mkfs.ext4 /dev/sdx3
```  
ROOT bölümü /mnt dizinine bağlanmalıdır.
```
	mount /dev/sdx1 /mnt
```  
EFI bölümünün bağlanması için öncelikle **/mnt/boot/efi** oluşturulmalıdır.
```
	mkdir /mnt/boot && mkdir /mnt/boot/efi
```  
Oluşturulma işleminin ardından artık mount edilebilir.
```
	mount /dev/sdx2 /mnt/boot/efi
```  
HOME bölümünün bağlanması için de **/mnt/home** dizini oluşturulması gerekmektedir.
```
	mkdir /mnt/home
```  
Ardından mount işlemi yapılabilir
```
	mount /dev/sdx3 /mnt/home
```  
Tüm bu işlemlerin sonunda yanlışlık olmadığını görmek için **lsblk** yürütmeniz de fayda vardır. Aşağıdaki gibi bir sonuç görmelisiniz.

<p align="center"> 
	<img src="/img/archlinux-kurulum-rehberi/2.png">
</p>

---

## MirrorList'in Ayarlanması

Default olan gelen mirrotlist'i değiştirmeniz yararınıza olacaktır. Bunun için **reflector** çok kullanışlı olabilir.

Default mirrotlist'i görmek için aşağıdaki komutu yürütebilirsiniz.
```
	less /etc/pacman.d/mirrorlist
```  

Aşağıdaki gibi **reflector**'u kurun.
```
	pacman -Syy reflector
```  
Aşağıdaki gibi bir yapı ile istediğiniz ülkede bulunan mirror'ı kullanabilirsiniz. Ülke tercihe bağlı olarak değişebilir. Konumunuza yakın bir ülke daha yararlı olacaktır.
```
	reflector --country 'United States' --age 12 --completion-percent 100 -i kernel.org --sort rate --save /etc/pacman.d/mirrorlist
```  
Değişikliği görmek için aşağıdaki komutu yürütebilirsiniz.
```
	less /etc/pacman.d/mirrorlist
```  
Ardından repo'ları güncellemeniz gerekmektedir.
```
	pacman -Syy
```  

---

## Base ve Base-Devel Kurulumu

Temel paketlerin kurulumu için aşağıdaki komutu yürütmeniz gerekmektedir.
```
	pacstrap /mnt base base-devel
```  
Bağlı olan disklere uygun olarak fstab oluşturulması için **genfstab** kullanmamız gerekmetedir.
```
	genfstab -U /mnt >> /mnt/etc/fstab
```  
Oluşan değişikliği görmek için aşağıdaki komutu yürütebilirsiniz.
```
	less /mnt/etc/fstab
```  

Tüm bu işlemlerin ardından artık sisteme bağlanabiliriz, bunun için **arch-chroot** kullanılır.
```
	arch-chroot /mnt
```  

---

## Dil ve Saatin Ayarlanması

Zaman dilimini ayarlamak için aşağıdaki komutları yürütmeniz gerekmektedir.
```
	ln -sf /usr/share/zoneinfo/Turkey /etc/localtime
```  
```
	hwclock --systohc
```  
Dil seçimi için /etc/locale.gen dosyasından seçilen dil *uncomment* edilmelidir. Yani seçeceğimiz dilin başındaki **#** ifadesini silmemiz gerekmektedir. Biz bu kurulumu ingilizce olarak yapacağımız için **#en_GB.UTF-8 UTF-8**'den **#**'i silmeliyiz.
```
	nano /etc/locale.gen
```  
Ardından locale-gen yürütürlür.
```
	locale-gen
```  
Ek olarak /etc/locale.conf dosyasına da dilin yazılması gerekiyor. Bunun için aşağıdaki komutu yürütebilirsiniz.
```
	echo "LANG=en_GB.UTF-8" > /etc/locale.conf
```  
Ayrıca terminalde kullanılacak olarak klavye dilinin de /etc/vconsole.conf dosyasına yazılması gerekmektedir.
```
	echo "KEYMAP=trq" > /etc/vconsole.conf
```  

---

## Bilgisayar Adının Ayarlanması

Bilgisayarın adını belirlemek için bilgisayar adı /etc/hostname'a yazılır.
```
	echo "PcNAME" > /etc/hostname
```  
Ayrıca /etc/hosts dosyası da aşağıdaki gibi ayarlanmalıdır.
```
	nano /etc/hosts
```  
> **/etc/hosts**  
	```
		127.0.0.1	localhost
	```  
	```
		::1		localhost
	```  
	```
		127.0.1.1	PcNAME.localdomain	PcNAME
	```

---

## Kullanıcı Eklenmesi ve Şifre Belirlemelerinin Yapılması

ROOT kullanıcısının parolasını belirlemek için direkt olarak **passwd** yürütün.
```
	passwd
```  
Eklemek istediğiniz kullanıcıyı aşağıdaki gibi ekleyebilirsiniz.
```
	useradd -m -g users -G wheel -s /bin/bash username
```  
Eklediğiniz kullanıcının parolasını aşağıdaki gibi belirleyebilirsiniz.
```
	passwd username
```  
Kullanıcının bulunduğu **wheel** grubuna sudo yetkisi verebilmek için **# %wheel ALL=(ALL) ALL**'in başındaki **#**'i silmeniz gerekmektedir.
```
	EDITOR=nano visudo
```  

---

## Önerilen Bir Kaç İşlem

Otomatik tamamlamalar için **bash-completion**'ı kurmanızı tavsiye ederim.
```
	pacman -S bash-completion && pacman -Syy
```  
Intel işlemciler için **intel-ucode** kurulmasını tavsiye ederim.
```
	pacman -S intel-ucode
```  
**WPA_Supplicant**'ın kurulmasını tavsiye ederim.
```
	pacman -S iw wpa_supplicant dialog
```  
**DHCPCD**'in aktifleştirilmesini tavsiye ederim.
```
	systemctl enable dhcpcd
```  
Bilgisayardan gelen **beep** sesinin engellenmesi için **pcspkr**'ın karalisteye alınmasını tavsiye ederim.
```
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
```  
Nvidia sorunlar çıkarmakta. Sadece intel kartımı kullanmayı tercih ettiğim için nvidia açık kaynak sürücülerini devre dışı bırakmayı tercih ediyorum, isterseniz siz de yapabilirsiniz.  
```
	echo "blacklist nouveau" > /etc/modprobe.d/nouveau.conf
```
Ses kartı için power save modunu aktifleştirmenizi öneririm.  
```
	echo "options snd_hda_intel power_save=1" > /etc/modprobe.d/audio_powersave.conf
```
Home dizini klasörlerinin otomatik olarak oluşturulması için **xdg-user-dirs**'in kurulmasını tavsiye ederim.
```
	pacman -S xdg-user-dirs
```  
Pacman'nın çıktısını reklendirmek ve multilib'i dahil etmek için conf dosyasında ilgili satırları yorum satırı dışına almanızı öneririm.
```
	nano /etc/pacman.conf
```
Aşağıdaki gibi username kullanıcısının HOME dizinindeki klasörler otomatik olarak oluşturulabilir.
```
	su username && cd && xdg-user-dirs-update && exit && cd /
```  
SSD kullanan kullanıcıların **fstrim.timer**'ı aktifleştirilmesini öneririm.
```
	systemctl enable fstrim.timer
```  

---

## GRUB Kurulumu

UEFI kurulumlar için **grub** ve **efibootmgr** paketlerinin kurulması gerekmektedir.
```
	pacman -S grub efibootmgr
```  
GRUB aşağıdaki gibi kurulabilir.
```
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archgrub
```  
Benim sistemimde rtl8723be wifi kartından dolayı pci error hatası almaktayım. Bu yüzden grub menusunda aşağıdaki parametreyi ekliyorum. Eğer siz pci error hatası ile karşılaşmıyorsanız bunu yapmayabilirsiniz.
```
	pci=nomsi
```
```
	grub-mkconfig -o /boot/grub/grub.cfg
```  

---

## Temel Kurulumun Tamamlanması

chroot'tan çıkabilmek için exit yürütürüz.
```
	exit
```  
Bağlı olan disklerin umount işlemi yapılır.
```
	umount -R /mnt/home && umount -R /mnt/boot/efi && umount -R /mnt
```  
Ardından reboot yapılabilir.
```
	reboot
```

---

## Temel Kurulum Sonrası İşlemler

Bu işlemler ayrı post olarak paylaşılmıştır, aşağıdaki adresten erişebilirsiniz.  

[**boratanrikulu.me/archlinux-kurulum-sonrasi/**](http://boratanrikulu.me/archlinux-kurulum-sonrasi/)

---
layout: post
title: "Raspberry Pi 3 Torrent İstemcisi"
tags: [GNU/Linux]
subtitle: "raspberry pi 3 ile torrent istemcisi hazırlanması."
---
***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

---

<p align="center"> 
	<img src="/img/pi3-torrent-server/0.png">
</p>

Raspberry Pi 3 ile kolaylıkla bir torrent istemcisi hazırlayabilirsiniz. Bu mini server üzerinden gerekli indirme işlemlerinizi gerçekleştirebilir, indirilen verileri tüm ağdaki cihazların erişebileceği şekilde paylaşabilirsiniz.

#### Malzemeler:  
1) Raspberry Pi 3  
2) Harici Hard Disk  
3) SD Kart  
4) Boş Bir Vakit

**Not 1:** Anlatım adımları GNU/Linux dağıtımlarına uygun olacak şekilde hazırlanmıştır. Windows ve OSX kullanıcıları başka kaynaklara göz gezdirebilir.

**Not 2:** Anlatım adımlarını gerçekleştirebilmeniz için orta seviye GNU/Linux bilginiz olması gerekmektedir, aşağıdaki anlatım da buna uygun olarak hazırlanmıştır. **Kurulum sırasında yaşayabileceğiniz herhangi bir sorun, sorumluluğum altında değildir.**  

**Not 3:** Anlatım adımlarını ihtiyacınıza göre yapınız. Örneğin indirilen verileri tüm ağa açık şekilde paylaşmak gibi bir amacınız yok ise Apache2 kurulum adımını yapmamanız gerekir.

---

## SD Kartın Hazırlanışı

Öncelikle bu adresten[**[1]**](https://www.raspberrypi.org/downloads/raspbian/)  **Raspbian Stretch Lite**'i indirin. Ardından aşağıdaki işlemleri uygulayın.

**lsblk** ile SD kartınızın lokasyonunu tespit edin. Örneğin benim sistemimde aşağıdaki gibi **/dev/mmcblk0** adresinde. Sizin de benzer olacaktır.
<p align="center"> 
	<img src="/img/pi3-torrent-server/1.png">
</p>

Ardından raspbian'nın bulunduğu lokasyona gidin ve aşağıdaki adımları **girdileri kendinize göre değiştirerek** uygulayın.  
Benim sistemimde **/tmp** altında idi. Bu işlem biraz uzun sürecektir.
```
	cd /tmp
```  
```
	sudo dd if=2018-04-18-raspbian-stretch-lite.img of=/dev/mmcblk0 status=progress && sync
```

İşlemin ardından aşağıdaki gibi bir çıktı görmelisiniz.
<p align="center"> 
	<img src="/img/pi3-torrent-server/2.png">
</p>

Yukardaki adımlarda bir sorun yaşamadıysanız imaj dosyasını başarı ile SD karta yazmışsınız demektir. Şimdi yapamamız gereken SSH servisinin otomatik olarak başlatılması için boot bölümünde **ssh.txt** isimli bir dosya oluşturmak.  
**Bu işlemi dosya yöneticiniz üzerinden de yapabilirsiniz** ya da aşağıdaki örnekteki gibi de yapabilirsiniz.
<p align="center"> 
	<img src="/img/pi3-torrent-server/3.png">
</p>

Artık SD kartınızı Raspberry Pi3 cihazınıza takıp gücü bağlayabilirsiniz.

---

## Pi3 Cihazının IP Tespiti

Local IP'yi tespit edebilmeniz için bir çok yol mevcut. En basit olarak aşağıdaki gibi bir nmap taraması yapabilirsiniz. Root yetkisini hostname tespiti için vermeniz gerekmektedir. Aksi halde sadece sadece aktif IP'leri elde edersiniz.
```
	sudo nmap -sP 192.168.2.0/24
```  

---

## Temel Server Ayarları

Pi3 server'ımız sadece local network'te çalışacak olmasına rağmen temel sunucu ayarlarının yapılmasında fayda vardır. Bunlar sizin için bir problem değil ise bu aşamayı atlayabilirsiniz. Ama uygulamanızı **kesinlikle** öneririm.

Pi3 cihazımızın default parolası **raspberry**'dir. Aşağıdaki gibi bağlantı kurabilirsiniz.
```
	ssh pi@IPADRESI
```  

Eğer buraya kadar bir problem çıkmadıysa başarı ile bağlantı kurmuş olmalısınız.
<p align="center"> 
	<img src="/img/pi3-torrent-server/4.png">
</p>

---

#### Upgrade İşlemleri

İlk iş olarak gerekli olan upgrade'leri yapmanızı öneririm. Aşağıdaki gibi yapabilirsiniz.
```
	sudo apt update && sudo apt upgrade -y && sudo reboot
```  

---

#### Parola Değiştirilmesi

Default olarak **raspberry** olan parolayı aşağıdaki gibi değiştirebilirsiniz.

```
	passwd pi
```  

---

#### Sudo Yetkisi Parola Kontrolü

Raspbian' **pi** kullanıcısı sudo yetkisini herhangi bir parola kontrolü olmadan kullanabilir. Bunu güvenlik sebepleri nedeniyle kapatmakta fayda vardır. Bu sayede sudo yetkisinin kullanılması için parola kontrolü yapılması sağlanmış olur.

Bunun için aşağıdaki komutu yürütebilirsiniz.
```
	echo "pi ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/010_pi-nopasswd
```  

---

#### SSH-Key Aktifleştirmek

Sunuculara parola ile bağlanmak hem işlemleri uzatmakta hem de güvenli değil. Bu yüzden ssh-key kullanmanızı öneririm. Oluşturmak için aşağıdaki adımları **kendi bilgisayarınızda** uygulayın. Çıkan seçenekleri kendinize göre cevaplayın ya da default bırakmak için enter yapın.

```
	ssh-keygen
```  

Eğer seçenekleri default olarak bıraktıysanız key'iniz **~/.ssh/id_rsa.pub** altındadır. Aşağıdaki gibi dosyayı okuyun ve kopyalayın.
```
	cat ~/.ssh/id_rsa.pub
```  

Ardından **server'a geri dönün** ve aşağıdaki adımları uygulayın.
```
	cd && mkdir .ssh && chmod 700 .ssh
``` 

.ssh klasörüne girin ve **authorized_keys**'i aşağıdaki gibi oluşturun.
```
	cd .ssh && touch authorized_keys && chmod 600 authorized_keys
```  

Aşağıdaki gibi key'inizi authorized_keys dosyasına yazın.
```
	echo "KEYINIZ BURAYA" > authorized_keys
```  
<p align="center"> 
	<img src="/img/pi3-torrent-server/5.png">
</p>

---

#### SSH Ayarları

Default ssh ayarlarını değiştirmek için **/etc/ssh/sshd_config** dosyasını aşağıdaki gibi açın.
```
	sudo nano /etc/ssh/sshd_config
```  

Aşağıdaki gibi satırları değiştirin

| Eski | Yeni |
|:----:|:----:|
| #Port 22 | Port KullanmakIstediginizPort |
| #PasswordAuthentication yes | PasswordAuthentication no |
| #PubkeyAuthentication yes | PubkeyAuthentication yes |

Ardından ssh servisini reload'layın
```
	sudo systemctl reload ssh
```  

Ardından aşağıdaki gibi bağlantınızı koparın ve sorun olup olmadığını tespit etmek için tekrar bağlanmayı deneyin.
```
	exit
```  
```
	ssh -i ~/.ssh/id_rsa pi@IPADRESI -p KullanmakIstediginizPort
```  

---

#### UFW Kurulumu

UFW Kurulumunu aşağıdaki gibi yapabilirsiniz.
```
	sudo apt install ufw
```  
```
	sudo ufw allow KullanmakIstediginizPort
```  
```
	sudo ufw allow 80
```  
```
	sudo ufw enable
```  
Durumu aşağıdaki gibi görebilirsiniz.
```
	sudo ufw status verbose
```  

---

#### Saat Ayarı

Saat ayarlamasını aşağıdaki gibi yapabilirsiniz.
```
	sudo dpkg-reconfigure tzdata
```

---

## Harici Disk'in Bağlanması

İndireceğiniz verileri kaydetmek için harici bir diske ihtiyacınız olacak. Otomatik olarak bağlama işlemlerini aşağıdaki gibi yapabilirsiniz. Diskin formatının **ntfs** olması beklenmektedir.

```
	sudo apt install ntfs-3g
```  
```
	sudo mkdir /media/DATA
```  
Ardından **lsblk** ile diskinizin lokasyonunu tespit edin ve aşağıdaki gibi bağlayın. 
```
	sudo mount /dev/sda1 /media/DATA
```  
Bu ilemin boot sırasında otomatik olarak yapılabilmesi için **/etc/fstab** dosyasını düzenlememiz gerekir. **Girdileri kendinize göre değiştirerek** aşağıdaki gibi yapabilirsiniz.
```
	echo -e "/dev/sda1\t/media/DATA\tntfs\tdefault\t0\t0" | sudo tee -a /etc/fstab
```

Artık /dev/sda1 bölümü otomatik olarak cihaz başlatıldığında /media/DATA bölümüne bağlanacak.

---

## Apache2 Kurulumu

İndirdiğiniz verileri direkt olarak görüntülemek için http sunucusu mantıklı olackatır. Aşağıdaki gibi uygulayabilirsiniz.

```
	sudo apt install apache2
```  

Apache2'nin çalıştığı lokasyonu /media/DATA olarak değiştirmek için aşağıdaki adımları uygulayın.
```
	echo -e "\n<Directory /media/DATA>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n\tRequire all granted\n</Directory>" | sudo tee -a /etc/apache2/apache2.conf
```  

Ardından aşağıdaki 000-default.conf dosyasındaki DocumentRoot'u aşağıdaki gibi değiştirin.
```
	sudo nano /etc/apache2/sites-available/000-default.conf
```  

| Eski | Yeni |
|:----:|:----:|
| DocumentRoot /var/www/html  | DocumentRoot /media/DATA |

---

## Transmission-Daemon Kurulumu

Torrent server'ını kurmak için aşağıdaki adımları takip edin.

```
	sudo apt install transmission-daemon
```  
```
	sudo service transmission-daemon stop
```  

Ardından aşağıdaki gib ayar dosyasını açın ve gerekli satırları değiştirin.
```
	sudo nano /var/lib/transmission-daemon/info/settings.json
```  

| Eski | Yeni |  
| ----------------- | -------------------|  
| "download-dir": "/var/lib/transmission-daemon/downloads", | "download-dir": "/media/DATA/Torrents", |  
| "incomplete-dir": "/var/lib/transmission-daemon/Downloads", | "incomplete-dir": "/media/DATA/Torrents", |  
| “rpc-password”: “hashBilgisi”, | “rpc-password”: “parolaniz”, | 
| "rpc-whitelist": "127.0.0.1", | "rpc-whitelist": "127.0.0.1, 192.168.\*.\*", |  
| "umask": 18, | "umask": 2, |  


Ardından aşağıdaki gibi gerekli izin ayarlamalarını yapın.
```
	sudo ufw allow 9091
```  
```
	sudo usermod -a -G debian-transmission pi
```  

Ve Servisimizi artık başlatabiliriz.
```
	sudo service transmission-daemon start
```  

Aynı network'te bulunan herhangi bir cihaz üzerinden [**http://IPADRESI:9091**]() olarak bağlanabilirsiniz.

<p align="center"> 
	<img src="/img/pi3-torrent-server/6.png">
</p>

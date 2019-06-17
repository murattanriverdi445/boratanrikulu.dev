---
layout: post
title: "Pacman ve APT Cheatsheet"
tags: [GNU/Linux]
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

**Kaynaklar**  
[wiki.archlinux.org/Pacman/Rosetta](https://wiki.archlinux.org/index.php/Pacman/Rosetta)

---

**NOT** : Eksik gördüğünüz kısımlar için **pull request** yollayabilirsiniz.[**[1]**](https://github.com/boratanrikulu/boratanrikulu.github.io)

---

| PACMAN | APT | Açıklama |
|:------:|:--------:|:--------:|
| pacman -S *[packageName]* | apt install *[packageName]* | paket yükler |
| pacman -Rs *[packageName]* | apt remove *[packageName]* | paket siler |
| pacman -Ss *[packageName]* | apt search *[packageName]* | paket arar |
| pacman -Sy | apt update | repo paket bilgilerini günceller |
| pacman -Syu | apt update && apt upgrade | yüklü paketleri günceller |
| pacman -Syu | apt update && apt dist-upgrade | sistemin tam güncellemesini yapar |
| pacman -Qdtq \| pacman -Rs - | apt autoremove | herhangi bir pakete bağlı olmayan gereksiz paketleri siler |
| pacman -Sw *[packageName]* | apt install --download-only *[packageName]* | paketi yalnızca indirir (paket yöneticisi cache konumuna) |
| ls /var/cache/pacman/pkg/ | ls /var/cache/apt/archives/ | paket yöneticisi cache'ni görüntüler |
| pacman -U *[/path/to/packageName.pkg.tar.xz]* | apt install *[/path/to/packageName.deb]* | paketi dosya ile yükler |
| tail -f /var/log/pacman.log | tail -f /var/log/dpkg.log | paket yöneticisi log'larını gösterir |
| pacman -Si *[packageName]* | apt show *[packageName]* | repo'daki bir paketin bilgisini gösterir |
| pacman -Qi *[packageName]* | dpkg -s *[packageName]* | yüklü olan bir paketin bilgisini gösterir |
| pacman -Q \| less | dpkg -l \| less <br>**-ya da-**<br>apt list --installed \| less | yük olan tüm paketleri listeler |
| pacman -Qsq > packages.list | **?** | yüklü olan tüm paketlerin isimlerini *packages.list* dosyasına kaydeder |
| pacman -Ss \| less | apt list \| less | repo'da bulunan tüm paketleri listeler |
| pacman -Ql *[packageName]* | dpkg -L *[packageName]* | yüklü olan paketin dosyalarının konumlarını gösterir |
| less /etc/pacman.d/mirrorlist | apt-cache policy | paket kaynak adreslerini listeler |
| less /etc/pacman.conf | **?** | paket yöneticisi ayarlarını gösterir |

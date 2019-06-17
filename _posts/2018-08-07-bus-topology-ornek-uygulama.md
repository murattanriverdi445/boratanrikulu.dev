---
layout: post
title: "Bus Topology - Örnek Uygulama"
tags: [GNU/Linux]
subtitle: "lyk18'de yapılan network uygulamasının bir özeti."
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

**Kaynaklar**  
LYK'18 - GNU/Linux Sistem Yönetimi 2. Düzey (Engür Pişirici)

**NOT:** Anlatım için VirtualBox ve Debian9 kullanılmıştır.

---

## Bus Topology Nedir ?

Cihazların tek bir çizgi(line) üzerinde birbirine bağlanması ile oluşturulan network'e Bus Topology denir.

- Avantajları  
	- Küçük network için kolay bir çözümdür.  
	- Star Topology'e göre daha az kablo gerektirir, ucuzdur.  
- Dezavantajları  
	- Temassızlık, kopukluk, kısa devre vs. tüm sistemi etkiler.  
	- Arıza tespiti zordur.  

---

## Oluşturulacak Yapıya Genel Bir Bakış

<p align="center"> 
	<img src="/img/bus-topology-ornek-uygulama/logo.png">
</p>

Bu şekilde bir yapı kurup, B server'ı üzerinden akan trafiği yönetmek istiyoruz. Bunun için 3 interface'e ihtiyacımız var. Interface'leri aşağıdaki gibi oluşturabilirsiniz.

---

## Interface'lerin Ayarlanması

<p align="center"> 
	<img src="/img/bus-topology-ornek-uygulama/1.png">
</p>

Interface oluşturmalarının yapılmasından sonra 4 tane sanal makine oluşturun ve network ayarlarını "Host Only Adapter" seçerek aşağıdaki gibi yapın.  
(Adaptör sıralarına dikkat edin, script'ler bunlara uygun yazılmıştır.)

| Device | Adapter 1 | Adapter 2 | Adapter 3 |
|:------:|:---------:|:---------:|:---------:|
| Client - **A** | vboxnet**0** | vboxnet**1** | - |
| Forwarder - **B** | vboxnet**1** | vboxnet**0** | vboxnet**2** |
| Server - **C** | vboxnet**2** | vboxnet**1** | - |
| Server - **D** | vboxnet**2** | vboxnet**1** | - |

---

## Client - A' nın Yapılandırılması

A Cihazını bir istemci gibi kullanacağımız için **curl**'e ihtiyacımız olacak. Yüklü değil ise kurun. Eğer istiyorsanız terminal browser'ı da kurabilirsiniz.

Network ayarlarını yapılandırmak için aşağıdaki script'i root yetkisi ile her başlangıçta çalıştırılacak şekilde hazırlayın.

```bash
#!/bin/bash

setName() {
	ip link set dev enp0s8 down
	ip link set dev enp0s8 name AtoB
	ip link set dev AtoB up
}

setIPs() {
	ip addr add 192.168.3.3/24 dev AtoB # sets Device A IP for vboxnet1
	ip route add 192.168.4.0/24 dev AtoB via 192.168.3.40 # sets Device B as the router to access vboxnet2
}

main() {
	setName
	setIPs
}

main
```

---

## Forwarder - B' nin Yapılandırılması

B Cihazını bir forwarder olarak kullanacağız. C ve D cihazlarına erişim kapatıldığında bir uyarı sayfası göstermek istediğimizden dolayı **apache2**'e ihtiyacımız olacak. Sunucuya apache2'yi kurun.

Uyarı sayfasını **/var/www/hmtl/index.html** altına koyabilirsiniz.

```html
<!DOCTYPE html>
<html>
<head>
	<title>!Warning!</title>
</head>
<body>
	<h1>C and D is unreachable.</h1>
</body>
</html>
```

Network ayarlarını yapılandırmak için aşağıdaki script'i root yetkisi ile her başlangıçta çalıştırılacak şekilde hazırlayın.

```bash
#!/bin/bash

setNames() {
	ip link set dev enp0s8 down
	ip link set dev enp0s8 name BtoA
	ip link set dev BtoA up

	ip link set dev enp0s9 down
	ip link set dev enp0s9 name BtoC
	ip link set dev BtoC up
}

setIPs() {
	ip addr add 192.168.3.40/24 dev BtoA # sets Device B IP for vboxnet0
	ip addr add 192.168.4.2/24 dev BtoC # sets Device B IP for vboxnet2

}

setIPForward() {
	ipForward=`cat /proc/sys/net/ipv4/ip_forward`

	if [[ "$ipForward" -eq "0" ]]; then # sets IP Forward as 1
		sysctl net.ipv4.ip_forward=1
	fi
}

main() {
	setNames
	setIPs
	setIPForward
}

main
```

---

## Server - C' nin Yapılandırılması

Birinci sunucumuz olan C'ye apache2'i kurun ve **/var/www/hmtl/index.html** dosyasını istediğiniz gibi şekillendirin. Ben bu örnekte aşağıdaki gibi sadece C olduğunu belirtecek bir yapı kullandım.

```html
<!DOCTYPE html>
<html>
<head>
	<title>!Device-C!</title>
</head>
<body>
	<h1>Yep. That's Fucking C!</h1>
</body>
</html>
```

Network ayarlarını yapılandırmak için aşağıdaki script'i root yetkisi ile her başlangıçta çalıştırılacak şekilde hazırlayın.

```bash
#!/bin/bash

setName() {
	ip link set dev enp0s8 down
	ip link set dev enp0s8 name CtoB
	ip link set dev CtoB up
}

setIPs() {
	ip addr add 192.168.4.4/24 dev CtoB # sets Device C IP for vboxnet1
	ip route add 192.168.3.0/24 dev CtoB via 192.168.4.2 # sets Device B as the router to access vboxnet0
}

main() {
	setName
	setIPs
}

main
```

---

## Server - D' nin Yapılandırılması

İkinci sunucumuz olan D'ye apache2'i kurun ve **/var/www/hmtl/index.html** dosyasını istediğiniz gibi şekillendirin. Ben bu örnekte aşağıdaki gibi sadece D olduğunu belirtecek bir yapı kullandım.

```html
<!DOCTYPE html>
<html>
<head>
	<title>!Device-D!</title>
</head>
<body>
	<h1>Yep. That's Fucking D!</h1>
</body>
</html>
```

Network ayarlarını yapılandırmak için aşağıdaki script'i root yetkisi ile her başlangıçta çalıştırılacak şekilde hazırlayın.

```bash
#!/bin/bash

setName() {
	ip link set dev enp0s8 down
	ip link set dev enp0s8 name DtoB
	ip link set dev DtoB up
}

setIPs() {
	ip addr add 192.168.4.5/24 dev DtoB # sets Device D IP for vboxnet1
	ip route add 192.168.3.0/24 dev DtoB via 192.168.4.2 # sets Device B as the router to access vboxnet0
}

main() {
	setName
	setIPs
}

main
```

---

## Ne Yaptık ? Ne Yapmak İstiyoruz ?

Oluşturulan scriptlerin çalışması için tüm cihazların kapatıp tekrar açın.  
Şuan oluşan yapıda A cihazından (B üzerinden geçerek) C ve D cihazlarına erişim sağlanabiliyor. Ama bizim yapmak istediğimiz yapı tam olarak bu değil. Biz A cihazından yalnızca B'ye istek yapılmasını, hangi cevabın dönüleceğini B üzerinden karar vermek istiyoruz.

Yani aslında buradaki amaç B cihazı üzerinden client'lara hizmet vermek, C ve D cihazlarını B'nin arkasında tutmak. Bu sayede direkt olarak B üzerinde yaptığımız ayarlar sayesinde network'ü kollaylıkla yönetebileceğiz.

---

## Forwarder Yapılandırılması

B üzerine yapılan web servisi sorgularında hangi server'dan dönüş sağlanılacağını ayarlamak için aşağıdaki gibi bir script kullanacağız.  

Bu sayede Client - A üzerinden yapılacak olacak olan "curl 192.168.3.40" sorgularında hangi sunucunun sonucunun dönüleceğini kolaylıkla belirleyebiliriz.

```bash
#!/bin/bash

C_IP=192.168.4.4
D_IP=192.168.4.5

delete_them_all() {
	iptables -t nat -F # deletes all nat rules
}

add_nat_rule() {
	iptables -t nat -A PREROUTING -p tcp --dport 80 -d 192.168.3.40 -j DNAT --to-destination "$1"
}

main() {
	if [[ "$1" == "c" ]]; then
		delete_them_all
		add_nat_rule "$C_IP" # adds Device C IP to forward
		echo "Process is Completed [C]."
	elif [[ "$1" == "d" ]]; then
		delete_them_all
		add_nat_rule "$D_IP" # adds Device D IP to forward
		echo "Process is Completed [D]."
	elif [[ "$1" == "off" ]]; then
		delete_them_all
		echo "All NAT Rules are Deleted."
	else
		echo "Please use only \"c\", \"d\" or \"off\" as the input"
	fi
}

main "$*"
```

---

## Client Üzerinden Görüntüleme Yapılması

Eğer B üzerinde aşağıdaki gibi bir işlem yapılırsa,

```bash
B$ ./forward.sh c
```

A artık B'yi sorguladığında C'yi görüntüleyecektir.

<p align="center"> 
	<img src="/img/bus-topology-ornek-uygulama/2.png">
</p>

---

Eğer B üzerinden D forward'ı açılırsa

```bash
B$ ./forward.sh d
```

Client - A, D'yi görüntüler

<p align="center"> 
	<img src="/img/bus-topology-ornek-uygulama/3.png">
</p>

---

Eğer B üzerinden Forward işlemi kapatılırsa,

```bash
B$ ./forward.sh off
```

Client - A aşağıdaki gibi bir ekranla karşılaşır.

<p align="center"> 
	<img src="/img/bus-topology-ornek-uygulama/4.png">
</p>

---

## B Üzerinden Hız Ayarlarının Kontrolü

...  
...  
Buraya Yazı Gelecek  
...  
...
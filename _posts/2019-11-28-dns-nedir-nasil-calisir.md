---
layout: post
title: "DNS Nedir ? Nasıl Çalışır ?"
tags: [System]
subtitle: "dns'i tanımını yapar, nasıl çalıştığını açıklar."
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

**Kaynaklar:**  
[**`cloudflare.com/what-is-dns`**](https://www.cloudflare.com/learning/dns/what-is-dns/)  
[**`çağlar yeşilyurt - dhcp / dns`**](https://person.zettlina.com/sunum/dns/dns.html#16)   
[**`howdns.works`**](https://howdns.works/ep1/)

---

## DNS Nedir ?

DNS'i internetin adres defteri olarak düşünebiliriz. Insanlar Websitelerine domain adresleri ile ulaşır, boratanrikulu.dev gibi. Fakat gerçekte tarayıcılar için bu text ifadesi anlamsızdır, tarayıcının websitesine istek yapıp cevap alabilmesi için IP adresine ihtiyacı vardır. Bu IP adresini DNS bize verir.

<p align="center">
  <img src="/img/dns-nedir-nasil-calisir/0.png" alt="what-is-dns">
</p>

Internete bağlı her cihazın eşsiz bir IP adresi vardır. Yani yukarda DNS sorgusuna baktığımız boratanrikulu.dev için '185.199.109.153' adresi eşsizdir. Tekildir. Fakat IP4 ve IP6 adreslerinin belirli bir sınırı vardır. Bu konu ile ilgili DHCP'e ilerde değineceğiz.

---

## DNS Nasıl Çalışır ?

Anladık, DNS text'e karşılık bize bir IP adresi verir. Peki DNS nasıl çalışarak bu işlemi gerçekleştirir ?

DNS'in nasıl çalıştığını anlamak için DNS sunucu türlerinin neler olduğunu anlamakta fayda var. 4 çeşit DNS sunucusu bulunur.

Bunlar;
- Recursive resolvers,  
- Root nameservers,  
- TLD nameservers,  
- Authoritative nameservers.

Hadi bunların neler olduğuna tek tek bakalım. [**`[kaynak]`**](https://www.cloudflare.com/learning/dns/dns-server-types/)

---

#### Recursive Resolver Nedir ?  

DNS recursor olarak ta bilinen Recursive resolvers, DNS sorgu ayağının ilk adımıdır. Bunu client(istemci) ile DNS nameserver arasındaki elçi olarak düşünebiliriz.

```
 --------   What is IP of boratanrikulu.dev ?
| Client | ------------------------------------|
 --------                                      |
                                               |
                                               |
                                               |
                                 -------------------------
                                | DNS Recursive Resolver  |
                                |     (listens at 53)     |
                                 -------------------------
                                               |
                                               |
                                               |
                                               |
                                            .......
                                            .......
                                            .......
```

Bu elçi tarayıcı tarafından (veya isteği ne atıyor ise) yapılan isteği alır ve DNS sorgulama sürecini yapıp sonucu geri client'e döndürür. DNS Recursive Resolvers isteğin cevabını ilk olarak cache üzerinden sorgular. Eğer aranan cevap cache'de zaten var ise ve bu bilginin güncelliği sisteme göre kabul edilebilir ise istek yapılmadan direkt olarak sonuç dönülebilir. Ya da Root nameserver, TLD nameserver, Authoritative nameserver için gerekli istekler atılır.

<p align="center">
  <img src="https://www.cloudflare.com/img/learning/dns/dns-server-types/root-nameserver.png" alt="how-dns-works-cloudfleare">
</p>

---

#### Root nameserver Nedir ?  

Root nameserver'i insanlar tarafından okunabilir olan text dosyasının IP karşılığına çevrilmesindeki ilk adım olarak düşünebiliriz. Recursive Resolver tarafından ilk istek atılan yerdir.

<p align="center">
  <img src="https://www.cloudflare.com/img/learning/dns/glossary/dns-root-server/dns-root-server.png" alt="root nameservers">
</p>

Root nameserver'lar zone olarak düşünülebilir. Dünyada 13 adet zone bulunur. Yani 13 çeşit Root Nameserver vardır. Fakat bu yalnızca 13 sunucu olduğunu anlamına gelmez. Birbirinin kopyası bir çok sunucu vardır. Bu sayede sunuculara daha kolay erişilebilir. Bu yapı anycast ile sağlanır.

Recursive Resolver tarafından, eğer cache'da ilgili veri yok ise, istek Root Nameserver'a ilk olarak atılır. Ardından ağaç yapısında aşağılara, TLD Nameserver ve Authoritative Nameserver'a istek atılarak devam edilir. Yani DNS yapısı ağaç şeklinde kurgulanmıştır, aynı *nix tabanlı sistemlerde olduğu gibi.

<p align="center">
  <img src="https://person.zettlina.com/sunum/dns/hiyerarsi.png" alt="dns tree structure">
</p>


Root Nameserver'ların sorumluluğu Internet Corporation for Assigned Names and Numbers (ICANN) kurumu tarafından üstlenilmiştir. Yetkili kurum budur.

Her Recursive Resolver'ın Root Nameserver listesi vardır. Nereye gideceğini bu şekilde bilir. 13 IP'lik bu liste sayesinde ilk isteği nereye atacağını bilir.

---

#### TLD nameserver Nedir ?   

TLD, yani Top Level Domain Server, bir domain'de bulunan son noktadan sonra gelen text ifadelerinin karşılığı olarak bulunan sunuculara denk gelir.

Örneğin **.com** bir TLD Nameserver'dir. Ve bu server'da ilgili tüm domain'lerin bilgileri bulunur.

TLD'lerin yönetimi, ICAAN'nin bir dalı olan, Internet Assigned Numbers Authority (IANA) tarafından üstlenilmiştir.

- Generic Top Level Domains: Ülke bilgisi içermez.  
  .com, .org, .net, .edu, .gov, .dev vb.
- Country Code Top Level Domains: Ülke bilgisini içerir.  
  .fi, .it, .se, .no, .tr

---

#### Authoritative nameserver Nedir ?  

Recursive Resolver tarafından atılacak isteklerin sonucusudur.

TLD Nameserver tarafından aldığımız Authoritative Nameserver'e istek yapılır. Bu isteğe karşılık olarak server bize DNS bilgisi olarak bulunan verileri geri döndürülür.

Recursive Resolver aldığı bu bilgiyi kendisine isteği yapan yere geri cevap olarak verir ve süreç bu şekilde tamamlanmış olur.

Peki Authoritative Nameserver tarafından geri verilen cevapta neler olabilir, hangi record'lar (kayıt) bulunabilir.

---

## Genel Resim

DNS sunucu türlerini öğrendiğimize göre artık genel resme bakabiliriz.

```
 --------   What is IP of boratanrikulu.dev ?
| Client | ------------------------------------|
 --------                                      |
                                               |  Gets request
                                               |
                                               |
                                 -------------------------
                                | DNS Recursive Resolver  |
                                |     (listens at 53)     |
                                 -------------------------
                                               |
                                               |  Make request
                                               |
                                               |
                                               |
                                               |
                                               |
        Do you know where is TLD nameservers   |
    -----------------  <---------------------- |
   | Root Nameserver |                         |
    -----------------  ----------------------> |
         Of course. Here is your list.         |
                                               |
                                               |
                                               |
                                               |
                                               |
                                               |
                                               |
            Do you know where is               |
        boratanrikulu.dev nameservers          |
    ----------------------  <----------------- |
   | TLD Nameserver (.dev)|                    |
    ----------------------  -----------------> |
        Of course. Here is your server.        |
                                               |
                                               |
                                               |
                                               |
                                               |
                                               |
                                               |
            Do you know what are               |
         records of boratanrikulu.dev          |
    ----------------------------  <----------- |
   | Authoritative Nameserver   |              |
   |     (boratanrikulu.dev)    |              |
    ----------------------------  -----------> |
     Of course. Here are your records.                                               

```

---

## DNS Records (Kayıt)

[**`[kaynak]`**](https://www.cloudflare.com/learning/dns/dns-records/)

dns kayıtları
a, aaaa, cname, soa, mx .....


- A record - Domain'in IP karşılığını tutar. Yalnızca IPv4 saklayabilir. IPv6 saklamak için AAAA Record tercih edilir.
- CNAME record - Bir domain'i diğerine yönlendirmek için kullanılır. TEXT veri saklar.
- MX record - E-posta isteklerini E-posta sunucusuna yönlendirmek için kullanılır. Server IP'sini saklar.
- TXT record - Yöneticiye, record verisinde text saklayabilmesi için kullanılır. Sadece veriyi saklamak içindir.
- NS record - Domain için nameserver saklar.
- SOA record - Domain hakkında yönetici bilgisini içerir.

  | example.com | Record Type  | Value | TTL |
  |:-----------:|:------------:|:------:|:---:|
  | @ |	A |	12.34.56.78 |	14400 |
  | blog |	CNAME |	is an alias of example.com | 	32600 |
  |  @ |	MX |	10 mailhost.example.com |	45000 |
  | @ |	MX |	20 mailhost2.example.com |	45000 |
  | @ |	TXT |	This is an awesome domain! Definitely not spammy. |	32600 |
  | @ |	NS |	ns1.exampleserver.com |	21600 |
  | @ | SOA | admin.example.com<br>(admin@example.com) | 11200 |

---

## Bazı Araçlar

DNS üzerinde işlem yapmak için bir çok araç vardır. Bunların bir kaçına bakalım.

---

### Host

Domain'in nameserver'ina bakmak amacıyla kullanılır.

```
Lookup Domain Name Server.

- Lookup A, AAAA, and MX records of a domain:
  host domain

- Lookup a field (CNAME, TXT,...) of a domain:
  host -t field domain

- Reverse lookup an IP:
  host ip_address

- Specify an alternate DNS server to query:
  host domain 8.8.8.8
```

<p align="center">
  <img src="/img/dns-nedir-nasil-calisir/1.png" alt="host">
</p>

---

### DIG

DNS Record hakkında detaylı bilgilere bakmak için kullanılır.

```
DNS Lookup utility.

- Lookup the IP(s) associated with a hostname (A records):
  dig +short example.com

- Lookup the mail server(s) associated with a given domain name (MX record):
  dig +short example.com MX

- Get all types of records for a given domain name:
  dig example.com ANY

- Specify an alternate DNS server to query:
  dig @8.8.8.8 example.com

- Perform a reverse DNS lookup on an IP address (PTR record):
  dig -x 8.8.8.8

- Find authoritative name servers for the zone and display SOA records:
  dig +nssearch example.com

- Perform iterative queries and display the entire trace path to resolve a domain name:
  dig +trace example.com
```

<p align="center">
  <img src="/img/dns-nedir-nasil-calisir/2.png" alt="dig">
</p>

---

### TCPDump

DNS için özel bir araç değildir. Fakat 53 portu dinlenerek DNS tarafiğine bakmak amacıyla kullanılabilir.

```
tcpdump

Dump traffic on a network.
More information: .

- List available network interfaces:
  tcpdump -D

- Capture the traffic of a specific interface:
  tcpdump -i eth0

- Capture all TCP traffic showing contents (ASCII) in console:
  tcpdump -A tcp

- Capture the traffic from or to a host:
  tcpdump host www.example.com

- Capture the traffic from a specific interface, source, destination and destination port:
  tcpdump -i eth0 src 192.168.1.1 and dst 192.168.1.2 and dst port 80

- Capture the traffic of a network:
  tcpdump net 192.168.1.0/24

- Capture all traffic except traffic over port 22 and save to a dump file:
  tcpdump -w dumpfile.pcap not port 22

- Read from a given dump file:
  tcpdump -r dumpfile.pcap
```


---

### Traceroute

[**`[kaynak]`**](https://www.lifewire.com/traceroute-linux-command-4092586)

Bir host'a yapılan istekte paketin geçtiği yollara bakmak amacıyla kullanabilir.

```
Print the route packets trace to network host.

- Traceroute to a host:
  traceroute host

- Disable IP address and host name mapping:
  traceroute -n host

- Specify wait time for response:
  traceroute -w 0.5 host

- Specify number of queries per hop:
  traceroute -q 5 host

- Specify size in bytes of probing packet:
  traceroute host 42
```

---

## DHCP Nedir ?

...

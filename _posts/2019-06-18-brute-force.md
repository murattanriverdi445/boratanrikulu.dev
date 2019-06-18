---
layout: post
title: "Brute Force"
tags: [Computer Science]
subtitle: "'algoritmalar - brute force' konusu hakkında aldığım notlar."
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

**Kaynaklar:**  
[**Introduction to the Design & Analysis of Algorithms 3e - Pearson**](https://www.pandora.com.tr/kitap/introduction-to-the-design-and-analysis-of-algorithms-3e/270012)  
[**@elif_haytaoglu**](https://www.linkedin.com/in/elif-haytaoglu-97176564/)

---

## Brute Force

Brute Force yaklışımı, bir problemin çözümü için en kolay yollardan biridir. Direkt sonuç odaklıdır, performans aranmaz.  

Örneğin 5^5'i brute force yaklaşımı ile aşağıdaki gibi 4 çarpma işlemi yaparak buluruz.  

`5^5 = 5x5x5x5x5`

Brute Force uygularken, performans geliştirmesi yapmak amacıyla pek düşünülmez. Örneğin yukarda yaptığımız çarpma işlemlerinde değerini bildiğimiz 5^2 değerlerini kullanarak, bilgisayar için oldukça maliyetli olan çarpma işleminde azalma sağlayabilirdik ama brute force yaklaşımda pek fazla **performans kazancı sağlama düşüncelerine girilmeyeceği için** bunu düşünmedik.

---

## Brute Force ile Sıralama Algoritmaları

Bilgisayar bilimleri için oldukça önemli olan sıralama problemini çözmek amacıyla yüzlerce algoritma geliştirilmiştir. Bunlardan Selection Sort ve Bubble Sort ile brute force yaklaşımıyla yapılan sıralama algoritmalarına örnektir. Bu iki algoritma da `Θ(n)` ile çalışır.

### Selection Sort

<p align="center"> 
  <img src="/img/brute-force/brute_force_2.gif" alt="selection sort">
</p>

Algoritması:  
- Tüm listeyi tara ve en küçük elemanı bul.
- İlk eleman ile en küçük elamanı yer değiştir.
- Listenin ikinci elemanından başlayarak sona kadar git, en küçük elamanı bul.
- İkinci eleman ile yeni en küçük elemanı yer değiştir.
- Tekrarla

Sözde kodu:

```java
def selection_sort(list)
  for i : 0 to n-2 do
    min = i
    for j : i+1 to n-1 do
      if list(j) < list(min)
        min = j
    swap(list[i], list[min])
```

Büyüme hızı: `Θ(n^2)`

Selection Sort'un diğer sıralama algoritmalarından **ayıran bir özelliği** vardır. Algoritma tüm elemanları n^2 kere dolaşırken swap işlemi yalnızca n kez yapılır.

### Bubble Sort

<p align="center"> 
  <img src="/img/brute-force/brute_force_1.gif" alt="bubble sort">
</p>

Algoritması:  
- Listedeki komşu elemanları karşılaştır
- Eğer sıralı değilse yerini swap et

Sözde kodu:

```java
def bubble_sort(list)
  for i : 0 to n-2 do
    for j : 0 to n-1-i do
      if list[j] > list[j+1]
        swap(list[j], list[j+1])
```

Büyüme hızı: `Θ(n^2)`

Sıralama algoritmaları hakkında çözülebilecek problemler: (syf 129)  
- A stack of fake coins
- Alternating disks

---

## Brute Force ile Arama Algoritmaları

Bir önceki bölümde girilen dizinin sıralanmasını sağlamıştık. Bu bölümde ise girilen veriye göre brute force yaklaşımı uygulayarak arama yapacağız. Bunlardan ilki girilen dizi üzerinde arama yapan Sequential Search diğer ise bir string içersinde arama yapan String Matching.

### Sequential Search

Algoritması:

- Aranan key ile tüm elemanları karşılaştır
  - Key bulunduğunda index'i döndür
  - Eğer key listenenin hiç bir elemanında bulunamadıysa -1 döndür

Sözde kodu:

```java
def sequential_search(list, key)
  for i : 0 to n-1 do
    if  key == list[i]
      return i
  return -1
```

Büyüme hızı: `Θ(n)`

### String Matching

N karakterli bir cümle içersinde m karakterli bir kelime olup olmadığını bulunması.

Algoritması:

- Kelimenin ilk harfi cümlede denk geldiğinde devamını karşılaştırmaya başla
  - Karakterler eşleştikçe dönmeye devam et
- Hepsi denk geldi mi ?
- Hepsi denk gelmediyse bir dahaki ilk harf tutan yere
- Karşılaştırma durumuna tekrar başla

Sözde kodu:

```java
def string_matching(text, word)
  for i : 0 to n-m do
    j = 0
    while j < m AND word[j] == text[i+j]
      j++
    if j == m
      return i
  return -1
```

Büyüme hızı: En kötü durumda, her defasında while'a gireceği için, `Θ(nm)`

---

## Brute Force ile Bilindik İki Problemin Çözümü

Bu bölümde bilindik iki problem olen Closest-Pair ve Convex-Hull problemlerini brute force yaklaşımı ile çözeceğiz.

### Closest-Pair Problem

N nokta arasından en yakın iki noktanın bulunması problemidir. Brute Force yaklaşımı ile tüm nokta çiftlerinin uzaklıklarına bakılır, en küçük olan değer bu şekilde bulunur.

Sözde kodu:

```java
def closest_pair(list)
  dmin = infinite
  index1 = -1
  index2 = -1
  for i : 1 to n-1 do
    for j : i+1 to n do
      d = sqrt((xi-xj)^2 + (yi-yj)^2)
      if d < dmin
        dmin = d
        index1 = i
        index2 = j
  return index1, index2
```

Temel işlem d'nin bulunduğu yerdir.  

Büyüme hızı: `Θ(n^2)`

### Convex-Hull Problem

<p align="center"> 
	<img height="400" src="/img/brute-force/brute_force_1.png" alt="convex-hull problem">
</p>

Verilen noktalar için **dışbükey bir çevreleyici**nin bulunmasıdır.

X ve X birleştiren doğru parçası diğer tüm noktaları bir tarafta bırakıyorsa bu doğru parçası Convex Hull’ın bir kenarıdır. Bu testi tüm nokta çiftleri için gerçekleştirdiğimizde Convex-Hull'ın uç noktalarını bulabiliriz.

---

## Exhaustive Search (kapsamlı arama)

Exhaustive Search, kombinasyonal problemlerine brute force yaklaşımı ile çözüm bulmaktadır.

Bir problemin tüm elemanlarını bulur ve bu buldukları arasından problemin kısıtlamlarına uygun olanları seçer. Ardından seçilen elemanlar arasından problem için uygun olan eleman seçilir (en optimize olan eleman).

Exhaustive Search'ü üç problemin çözümünde kullanacağız; Traveling Salesman Problem, Knapsack Problem, Assignment Problem.

### Traveling Salesman Problem (gezgin satıcı problemi)

150 yıldır araştırmacılar tarafından araştırılan bu problemde istenen, verilen n şehir içerisinde, her şehirde yalnızca bir kez uğranılan minimum turun bulunmasıdır. Bu noktada problem en kısa Hemiltonaian çevrimini bulmaya dönmüş olur. Brute force yaklaşımı ile, Exhaustive Search yaparsak, bu sorunu çözerken tüm kombinasyonal durumlar yazılır ve ağırlık bakımından en optimal yol(lar) seçilir.

<p align="center"> 
	<img height="600" src="/img/brute-force/brute_force_0.png" alt="traveling salesman problem">
</p>

Kaç yol vardır ?  

`(n-1)!`

Yukarda da gözüktüğü gibi yolların yarısı yalnızca yön anlamında farklıdır, ağırlık anlamında elimizde `(n-1)!/2` ihtimal vardır.  

Bu problemin çözümünün büyüme hızı o halde,  
Büyüme hızı: `Θ(n!)`

### Knapsack Problem (sırtçantası problemi)

Çok bilindik diğer bir problem olan Knapsack probleminde amaç bir sırt çantasına maksimum olarak sığabilecek alt ürün grubunu bulmaktır. Bir yük uçağı hayal edin, bu uçağın kapasitesini verimli kullanabilmek amacıyla, kapasiteyi aşmadan elmizdeki metaryeller optimum şekilde uçağa koymamız gerekir. Ya da bir hırsız düşünün, hırsız torbasını en verimli şekilde doldurmalıdır, hırsız çantasına ağırlıkça en az, **pahaca en çok eşyayı doldurmak** ister.

<p align="center"> 
	<img src="/img/brute-force/brute_force_2.png" alt="knapsack problem">
</p>

Exhaustive Search yaklaşımına göre problemi çözmek istersek, kombinasyonal olarak tüm alt grupları bulur, problem sınırımız olan kapasiteye en uygun değeri taşıyan alt grubu seçeriz.

n elemanlı bir kümenin tüm alt kümeleri `2^n` dir. Problemin çözümünün büyüme hızı o halde,  
Büyüme hızı: `Ω(2^n)`

### Assignment Problem (atama problemi)

Bir diğer problem olan Assignment Probleminde n tane insan ve n tane iş olduğu söylenir, her çalışan yalnızca bir işe atabilir ve her işte yalnızca bir çalışan çalışabilir. Her çalışanın bir işte çalışması için belirli bir maliyet vardır. **En düşük maliyete sahip çalışan-iş eşleştirilmesi**nin nasıl yapılması gerektiğini sorar.

<p align="center"> 
	<img src="/img/brute-force/brute_force_3.png" alt="assignment problem">
</p>

Yukardağı tabloyu bir matrix olarak düşünürseniz, her satırda ve kolonda yalnızca bir seçim yapılarak en düşük maliyet hesabı yapılacaktır.

<p align="center"> 
	<img src="/img/brute-force/brute_force_4.png" alt="assignment problem">
</p>

Exhaustive Search yaklaşımı ile problem çözülecek olursa olabilecek tüm kombinasyonal ifadeler bulunur ve en düşük maliyete sahip olan seçilir. Fakat bu yöntemden çok daha kullanışlı olan Hungarian method'unun kullanılması daha mantıklı olacaktır.

Exhaustive Search hakkında çözülebilecek problemler: (syf 147)
- Eight-queens problem  
- Famous alphametic

---

## Exhaustive Search ile Graph Traversal Algoritmaları (DFS - BFS)

Exhaustive Search dolaşma yöntemi olan DFS ve BFS'ye de uygulanabilir.

### Depth-first search (DFS)

Derine gidilir. Dolaşma işlemi bir düğümden başlar. Gidilebilecek mümkün komşulardan bir tanesini seçer ve ilerler. Gidilebilecek diğer düğümlere bakmadan önce yeni gidilen düğümün komşuları incelenir ve bir tanesine gidilir. Gidilebilecek komşu kalmayınca geri sarılarak mümkün komşular aranır.

<p align="center"> 
	<img src="/img/brute-force/brute_force_5.png" alt="depth-first search">
</p>

Sözde kodu:

```java
def depth_first_search(graph)
  mark each vertex in V with 0 as a mark of being 'unvisited'
  count = 0
  for each vertex v in V do
    if v is marked with 0
      dfs(v)

def dfs(v)
  count++
  mark v with count
  for each vertex w in V adjacent to v do
    if w is marked with 0
      dfs(w)
```

### Breadth-first search (BFS)

Enine gidilir. Dolaşma işlemi bir düğümden başlar. Gidilebilecek mümkün komşular hepsini sırayla seçer ve ilerler. Gidilebilecek bütün komşular gezildikten sonra ilk komşunun komşuları seçilir.

<p align="center"> 
	<img src="/img/brute-force/brute_force_6.png" alt="breadth-first search">
</p>

Sözde kodu:

```java
def breadth_first_search(graph)
  mark each vertex in V with 0 as a mark of being 'unvisited'
  count = 0
  for each vertex v in V do
    if v is marked with 0
      bfs(v)

def bfs(v)
  count++
  mark v with count
  initialize a queue with v
  while the queue is not empty do
    for each vertex w in V adjacent to the front vertex do
      if w is marked with 0
        count++
        add w to the queue
    remove the front vertex from the queue
```
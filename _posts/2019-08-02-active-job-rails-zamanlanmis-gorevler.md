---
layout: post
title: "Active Job - Rails Arkaplan Görevleri"
tags: [Software]
subtitle: "Rails'da arkaplan görevlerin nasıl yapılacağını anlatır."
---

***Yazan: [boratanrikulu](https://github.com/boratanrikulu)***

**Kaynaklar:**  
[Rails Guides](https://edgeguides.rubyonrails.org/active_job_basics.html)

**Not:** Anlatımda `ruby-2.6.3`, `rails-6.0.0.rc2` kullanılmıştır.

---

# Arkaplan Görevi Nedir ?

Rails'da arka plan görevlerini yönetmek için kullanılan Active Record'u açıklamaya başlamadan önce ilk olarak arkaplan görevi kavramının ne olduğuna açıklık getirmek gerekiyor.

Arkaplan görevleri bir işlemin durmasına rol açmadan, eş bir çizgide yürüyerek rol almasıdır. E-posta yollanması buna çok güzel bir örnektir. Örneğin kullanıcı sistemimize kayıt olmak için kayıt ol formunu doldurduğunda onaylama epostası yollanıyor olsun. Kullanıcı bu tuşa bastığında eposta yollama işlemini direkt olarak işleme alırsak, e-posta yollanasıya kadar kullanıcı yükleme ekranında bekler. Fakat eğer arka plan görevi olarak çalışmasını sağlar ise işlem bir kuyruğa alınır ve sayfa direkt yüklenir.


---

# Nerelerde Arkaplan Görevlerine İhtiyaç Olabilir ?

Örneğin bir kullanıcı alışveriş sitesinden bir şey satın aldığında arka planda bir fatura oluşturup e-posta olarak yollamak gerekir. Bu fatura oluşturma ve e-posta yollama aşamalarında arka plan görevi kullanmak mantıklı olacaktır.

Ya da şunu hayal edin haftalık bülten sitemiz var. Kullanıcı e-postasını sisteme girdiğinde haftalık olarak bilgilendirme e-postası almak istiyor, bu durumda da arka plan görevleri kullanmak mantıklı olacaktır.


---

# Active Job nedir ?

Active Job, zamanlanmış olarak çalışacak görevleri tanımlayan, bu görevlerin kuyruk servislerine (çoğunlukla III. parti) aktarılmasından sorumlu bir framework yani uygulama çatısıdır.


Active Job'un ana amacı; Kuyruk(queue) amacıyla kullandığımız III. parti servisi değişse dahi daha önceden yazmış olduğumuz görevlerin yani job'ların baştan yazımının önüne geçmektir.


Active Job sayesinde görevlerimizi yazabilir ve istediğimiz kuyruk servisi kullanabilir, değiştirebiliriz.

---

# Kuyruk Servisleri

Rails'de varsayılan olarak kuyruk mekanizması RAM üzerinde tutulacak şekildedir. Herhangi bir elektrik kesintisinde ya da RAM'de oluşacak bir sorunda kuyruktaki tüm görevler yok olacaktır.


Bu durumda III. parti bir kuyruk servisi kullanmak mantıklı olabilir.  
Bu servislere `Sidekiq`, `Resque`, `Delayed Job` vs. örnek verilebilir.  
Servislerin güncel listesine buradan [**`QueueAdapters`**](https://edgeapi.rubyonrails.org/classes/ActiveJob/QueueAdapters.html) bakılabilir.

Kuyruk servisini ayarlamak oldukça basit. Config dosyasında belirtmemiz yeterli.

```ruby
config.active_job.queue_adapter = :sidekiq
```

Ya da görev bazlı olarak seçeceğimiz servisi değiştirebiliriz. Yani config dosyasında varsayılan olarak ayarlanan servisin üzerine yazmış oluruz. Örneğin haftalık bülten görevi için "sidekiq" kullanırken, ödeme hatırlatıcı e-postaların atılması için "resque" kullanabiliriz.


```ruby
class NewsletterJob < ApplicationJob
  self.queue_adapter = :sidekiq
end
```

```ruby
class FeeJob < ApplicationJob
  self.queue_adapter = :resque
end
```

Ben, bu örnekte sidekiq kullanmayı tercih ettim.

Bunun için Gemfile'e sidekiq'i eklemeli ve routes dosyasını da aşağıdaki gibi ayarlamalısınız. Ayrıca sidekiq çalışmak için redis sunucusuna ihtiyaç duyuyor.


Gemfile
```ruby
gem 'sidekiq', '~> 5.2', '>= 5.2.7'
```

Routes
```ruby
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'
end
```

---

# Kullanıcı Kayıt Olduğunda Arkaplanda E-posta Atılması

Uygulamızda kullanıcılar kayıt olduğunda arka planda e-posta yollamak istiyoruz.

Kullanıcıyı yaratalım.

```ruby
rails generate scaffold User name:string email:string
```

E-posta yollayabilmek için mailer ekleyelim


```ruby
rails generate mailer UserMailer
```

Bu mailer'e **welcome** diye bir method ekleyelim

```ruby
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome!')
  end
end

```

Model'e de bir callback ekleyelim. Artık kullanıcı kayıt olduğunda arka plan görevi olarak bir e-posta atıyoruz.

```ruby
class User < ApplicationRecord
  after_create :send_welcome_mail

  private

  def send_welcome_mail
    UserMailer.welcome(self).deliver_later
  end
end
```

Burada `deliver_later` ifadesi oldukça önemli. Böyle diyerek işlemin bir görev olarak kuyruğa girmesini sağlıyoruz. Eğer `deliver_now` deseydik kuyruğa girmeden direkt olarak işleme alınacaktı.

```ruby
UserMailer.welcome(self).deliver_now

UserMailer.welcome(self).deliver_later
```

---

# Görev (Job) Oluşturma

Sistemimizde kullanıcılar satın aldıkları aboneliklere uygun şekilde bir pasif olma tarihine sahip olsun. Yani örneğin kullanıcı 10 Ağustos tarihine kadar abone olup parasını ödemiş olsun. Bu tarihte artık pasif hale getirilmesi gerekir.

Bunun için bir görev yaratalım.

```ruby
rails generate job users_clean
```

```ruby
class UsersCleanJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
```

Bunu tetiklemek için 
```ruby
GuestsCleanupJob.perform_later(@user)
```

Bizim tetikleme tarihimiz belli olduğu için

```ruby
GuestsCleanupJob.set(wait_until: @user.expire_date).perform_later(@user)
```

---

# Görevlere Callbacks eklemek

Görevlere de aynı modellerde yaptığımız gibi callback eklenebilir.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default
 
  around_perform :around_cleanup
 
  def perform
    # Do something later
  end
 
  private
    def around_cleanup
      # Do something before perform
      yield
      # Do something after perform
    end
end
```

Diğer callback'ler de aynı model'deki gibidir.
- before_enqueue
- around_enqueue
- after_enqueue
- before_perform
- around_perform
- after_perform

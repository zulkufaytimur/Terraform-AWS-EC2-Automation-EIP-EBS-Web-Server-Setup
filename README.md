# Terraform AWS EC2 Otomasyonu — EIP, EBS ve Web Sunucusu Kurulumu
<img width="1536" height="1024" alt="ChatGPT Image 27 Ara 2025 19_38_53" src="https://github.com/user-attachments/assets/51292b1b-17d8-4fe7-a1d4-a4053c66091b" />

## 📌 Proje Açıklaması
Bu proje, AWS üzerinde EC2 altyapısının Terraform kullanılarak otomatik ve tekrarlanabilir şekilde oluşturulmasını amaçlayan bir uygulama çalışmasıdır. Projede, biri Elastic IP ve ek EBS diski ile yapılandırılmış, diğeri ise daha basit test amaçlı olmak üzere iki EC2 instance oluşturulmuştur. User Data betikleri ile web sunucusu kurulumu otomatikleştirilmiştir. Çalışma, Infrastructure as Code (IaC) yaklaşımının pratik olarak uygulanmasına yöneliktir.

## 🛠️ Kullanılan Teknolojiler
- Terraform  
- AWS EC2  
- Elastic IP  
- EBS Volume  
- Security Groups  
- User Data Otomasyonu  

## 🚀 Projede Öğrenilen / Gösterilen Kazanımlar
- AWS üzerinde altyapı otomasyonu
- EBS diskin eklenmesi ve yönetimi
- Elastic IP ile EC2 yapılandırması
- Otomatik web sunucusu kurulumu
- Security Group yapılandırması
- Terraform state ve provisioning mantığı

## 📂 Proje Dosya Yapısı
- `main.tf` — Temel kaynaklar ve EC2 yapılandırması  
- `variables.tf` — Girdi değişkenleri  
- `providers.tf` — AWS provider ayarları  
- `outputs.tf` — Çıktı değerleri  

## 🔧 Gelecek Geliştirmeler
- Docker kurulumu ve container tabanlı dağıtım
- Nginx ile web uygulaması yayını
- Çoklu instance mimarisi
- Load balancer entegrasyonu

## 🎯 Projenin Amacı
Terraform ve AWS üzerinde altyapı otomasyonu konularında pratik deneyim kazanmak ve DevOps odaklı çalışma mantığını geliştirmek.

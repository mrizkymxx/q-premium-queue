# 🌟 Q-PREMIUM (Sistem Antrean Cerdas)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
</p>

**Q-PREMIUM** adalah inovasi sistem manajemen antrean berbasis web dan perangkat bergerak (*mobile*) yang dirancang untuk menghilangkan penumpukan kustomer di ruang tunggu konvensional. Dibangun dengan kekuatan **Flutter** dan **Supabase Realtime**, sistem ini memungkinkan kustomer untuk mendaftar secara mandiri (*Kiosk*) dan memantau giliran mereka dari jarak jauh (*Live Tracking*).

---

## 💖 Dedikasi Khusus (Special Acknowledgement)

> *"Terima kasih banyak ya bu, atas bimbingan, kesabaran, dan ilmu yang telah Ibu berikan selama perkuliahan. Cara Ibu mengajar tidak hanya membantu saya memahami teori, tetapi juga memberikan wawasan yang lebih luas mengenai pengembangan perangkat lunak modern. Saya sangat menghargai dedikasi Ibu dalam membimbing mahasiswa. Semoga Ibu selalu diberikan kesehatan, kebahagiaan, dan kesuksesan dalam setiap langkah ily bu donaa"*

**Dosen Pengampu:** Alzena Dona Sabilla, M.Kom  
**Dikembangkan Oleh:** Muhammad Rizky  
**Mata Kuliah:** Pemrograman Perangkat Bergerak (UAS Genap 2026)

---

## ✨ Fitur Unggulan

1. **📱 Kiosk Pendaftaran Mandiri**
   Pelanggan cukup memasukkan nama mereka dan sistem akan menerbitkan nomor urut (*Virtual Ticket*).
2. **🔊 Integrasi Text-to-Speech (TTS)**
   Sistem memanggil nama pelanggan secara lantang melalui suara robot/mesin dari Dasbor Operator.
3. **🛡️ Anti-Hilang Tiket (Session Persistence)**
   Nomor antrean tidak akan lenyap meskipun *browser* tertutup atau dimuat ulang, berkat penerapan *SharedPreferences* yang menyimpan UUID secara lokal.
4. **⚡ Sinkronisasi Real-Time**
   Perubahan status layanan (Panggil / Selesai / Lewati) oleh Operator langsung terkirim seketika (*WebSocket*) ke layar pemantauan kustomer tanpa perlu memuat ulang halaman.

## 🚀 Teknologi yang Digunakan
- **Frontend:** Flutter (Dart)
- **Backend & Database:** Supabase (PostgreSQL)
- **State Management:** Provider
- **Penyimpanan Lokal:** SharedPreferences
- **Layanan Suara:** flutter_tts

## 📂 Cara Menjalankan Proyek Secara Lokal

1. Kloning repositori ini.
2. Buka terminal dan jalankan perintah:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di perangkat Chrome / Web:
   ```bash
   flutter run -d chrome
   ```

---
*© 2026 Q-Premium Project. All Rights Reserved.*

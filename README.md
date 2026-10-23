# HADOOYY-CLI

Paket setup portabel dari lingkungan Hadi untuk Claude Code dan Hermes.
143 skill, 2 plugin Claude, template 4 MCP, preferensi engineering dan Hermes.
Inventaris lengkap: INVENTORY.json. Instruksi agent: SETUP.md.

## Cara pakai paling gampang

1. Clone atau download repository ini ke laptop sendiri.
2. Buka Claude Code / Hermes yang sudah terpasang dan bisa digunakan di folder clone.
3. Kirim prompt:

   Tolong setup agent gw pakai repo ini. Baca SETUP.md dulu. Tanya nama panggilan,
   panggilan asisten, persona dan provider/model gw sebelum konfigurasi.
   Jangan minta API key di chat.

Agent membaca CLAUDE.md / AGENTS.md, menanyakan preferensi penerima, menyiapkan
backup, menyalin skill, lalu memasang dependensi, plugin dan MCP yang disetujui.
API key/login diisi lokal atau melalui login resmi. Tidak perlu edit konfigurasi manual.
Kalau belum ada agent/login, instal dan login agent dulu; repo ini bukan installer aplikasinya.

    git clone https://github.com/Hadi-Akram-Ramadhan/hadooyy-cli.git
    cd hadooyy-cli
    claude

Bisa ganti perintah terakhir dengan hermes. Jangan tempel seluruh repo ke folder config.

## Isi paket

- skills/: seluruh 143 skill default Hermes, mencakup semua 59 nama skill Claude lokal.
  References, scripts, templates dan license yang tersedia ikut disalin.
- plugins/: antislop 3.2.12 dan gopls-lsp 1.0.0 untuk Claude, marketplace lokal hadooyy.
- config/mcp.template.json: rea, agent-reach, exa, headroom. Antislop menyediakan contrast MCP sendiri.
- config/hermes_settings.snapshot.json: snapshot pengaturan non-rahasia, bukan konfigurasi siap ditimpa.
- config/hermes_config.template.yaml: subset preferensi portable untuk digabung lewat CLI.
- config/claude_settings.template.json: default aman, tanpa model/provider/proxy/pengabaian izin.
- config/claude_optional.json: hook RTK opsional, aktifkan setelah dependensi tersedia.
- skins/hadooyy.yaml: tema merah opsional. Tidak otomatis jadi identitas penerima.
- setup.py: copier stdlib dengan dry-run, backup, merge aman, verifikasi jumlah skill.

## Batasan yang sengaja dipertahankan

Tidak membawa API key, token, OAuth, cookie, .env, auth.json, riwayat chat, memory
personal, cron, akun gateway, nomor telepon, atau channel/chat ID.
Nama penulis/lisensi dan URL repository tetap merupakan atribusi, bukan persona.
Model/proxy, panggilan dan persona ditentukan penerima. Permission bypass tidak dibawa.

Skill terpasang bukan berarti seluruh aplikasi/CLI sudah terinstal. Integrasi Google,
Notion, security scanners, media tools dan platform lain membutuhkan dependensi/login
masing-masing. Beberapa skill merujuk tool Hermes yang tidak tersedia di Claude;
agent harus memilih tool setara, bukan mengklaim fitur identik.

Plugin Claude bukan plugin native Hermes. Hermes memperoleh standalone antislop skills;
gopls tidak otomatis aktif di Hermes hanya karena foldernya disalin.
Agent Reach MCP menyediakan status, bukan seluruh alat pencarian 16 platform.
Tidak ada janji "semua online" sampai health check di laptop penerima lolos.
Download dependency butuh internet dan persetujuan penerima.

## Cek mandiri

    python setup.py --target claude
    python test_setup.py

Perintah pertama hanya rencana, tidak mengubah akun/config. Agent menjalankan --apply
setelah menerima preferensi dan izin. install.sh / install.ps1 meneruskan argumen yang sama.
MCP Claude user-scope disimpan di ~/.claude.json, bukan ~/.claude/settings.json.
Hermes memakai HERMES_HOME aktif; profile lain tidak disentuh otomatis.

## Lisensi

Lihat LICENSE dan lisensi masing-masing skill/plugin. Lisensi repository ini tidak
menggantikan lisensi komponen pihak ketiga. Pertahankan atribusi saat membagikan ulang.

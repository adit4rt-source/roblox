# Roblox Game - Rojo Project

Project Roblox Studio yang menggunakan **Rojo** untuk sinkronisasi otomatis antara file system dan Roblox Studio.

## Struktur Project

```
roblox-game/
├── default.project.json    # Konfigurasi Rojo
├── rokit.toml              # Toolchain manager
├── README.md
├── .gitignore
└── src/
    ├── ServerScriptService/    # Script server (hanya berjalan di server)
    │   └── GameManager.server.luau
    ├── ServerStorage/          # Asset/module server-only
    ├── ReplicatedStorage/      # Module yang bisa diakses server & client
    │   └── Utils.luau
    ├── ReplicatedFirst/        # Script client yang dimuat pertama kali
    ├── StarterGui/             # UI/ScreenGui
    ├── StarterPack/            # Tools untuk pemain
    └── StarterPlayer/
        ├── StarterCharacterScripts/
        └── StarterPlayerScripts/   # Script client per pemain
            └── PlayerController.client.luau
```

## Cara Setup (Langkah demi Langkah)

### Prasyarat

1. **Roblox Studio** - Sudah terinstall
2. **Rokit** (Toolchain Manager) - Install dari: https://github.com/rojo-rbx/rokit
3. **Git** - Untuk clone repository

### Langkah 1: Clone Repository

```bash
git clone https://github.com/USERNAME/roblox-game.git
cd roblox-game
```

### Langkah 2: Install Tools dengan Rokit

```bash
rokit install
```

Ini akan otomatis menginstall:
- **Rojo** v7.4.4 - Sync tool
- **Wally** v0.3.2 - Package manager
- **Selene** v0.27.1 - Linter
- **StyLua** v0.20.0 - Formatter

### Langkah 3: Install Rojo Plugin di Roblox Studio

1. Buka Roblox Studio
2. Pergi ke **Plugins** > **Manage Plugins**
3. Cari "**Rojo**" dan install
4. Atau jalankan: `rojo plugin install`

### Langkah 4: Mulai Rojo Server

```bash
rojo serve
```

Rojo akan berjalan di `localhost:34872` secara default.

### Langkah 5: Hubungkan dari Roblox Studio

1. Buka Roblox Studio
2. Klik tab **Plugins**
3. Klik tombol **Rojo** di toolbar
4. Klik **Connect**
5. Selesai! Sekarang semua perubahan file akan otomatis sync ke Studio

## Cara Kerja Sinkronisasi

```
[VS Code / Editor]  -->  [Rojo Server]  -->  [Roblox Studio]
   Edit file .luau        Deteksi              Update otomatis
                          perubahan            di Studio
```

- File `.server.luau` = **ServerScript** (berjalan di server)
- File `.client.luau` = **LocalScript** (berjalan di client/pemain)
- File `.luau` (tanpa suffix) = **ModuleScript** (bisa di-require)

## Perintah Berguna

| Perintah | Fungsi |
|----------|--------|
| `rojo serve` | Mulai live sync server |
| `rojo build -o build.rbxl` | Build file place |
| `selene src/` | Jalankan linter |
| `stylua src/` | Format semua kode |
| `wally install` | Install package dependencies |

## Menambah Script Baru

### Server Script
Buat file di `src/ServerScriptService/NamaScript.server.luau`

### Local Script (Client)
Buat file di `src/StarterPlayer/StarterPlayerScripts/NamaScript.client.luau`

### Module Script
Buat file di `src/ReplicatedStorage/NamaModule.luau`

## Tips

- Selalu gunakan ekstensi `.luau` (bukan `.lua`) untuk dukungan type-checking Luau
- Gunakan `$ignoreUnknownInstances: true` di project.json agar instance yang dibuat langsung di Studio tidak dihapus oleh Rojo
- Jalankan `selene src/` sebelum commit untuk memastikan kode bebas dari masalah umum

## Troubleshooting

**Rojo tidak connect?**
- Pastikan `rojo serve` berjalan di terminal
- Pastikan plugin Rojo terinstall di Studio
- Cek apakah port 34872 tidak diblok firewall

**Script tidak muncul di Studio?**
- Pastikan nama file menggunakan suffix yang benar (`.server.luau`, `.client.luau`, `.luau`)
- Cek `default.project.json` apakah path sudah benar

**Perubahan tidak tersync?**
- Disconnect dan reconnect Rojo dari Studio
- Restart `rojo serve`

## Lisensi

MIT License - Bebas digunakan dan dimodifikasi.

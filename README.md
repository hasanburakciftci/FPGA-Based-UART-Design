## Languages [TR](#-türkçe) | [EN](#-english)

 ## 🇬🇧 English
 
# FPGA-Based UART Design (VHDL)

This repository contains a fully synthesizable UART (Universal Asynchronous
Receiver/Transmitter) implementation written in VHDL. The design includes
independent transmitter (TX) and receiver (RX) modules, along with a top-level
integration module supporting internal loopback for verification.

The project is verified using self-checking testbenches and RTL simulation.

![UART Loopback Waveform](docs/uart_top_wf.png)

## Project Structure

FPGA-Based-UART-Design/
├── rtl/
│   ├── uart_tx.vhd      -- UART transmitter (FSM-based)
│   ├── uart_rx.vhd      -- UART receiver with input synchronization
│   └── uart_top.vhd     -- Top-level integration with optional loopback
│
├── tb/
│   ├── tb_uart_tx.vhd   -- Self-checking TX testbench
│   ├── tb_uart_rx.vhd   -- RX testbench (good frame & frame error cases)
│   └── tb_uart_top.vhd  -- End-to-end loopback verification
│
├── docs/
│   └── *.png            -- Simulation waveform screenshots
│
├── README.md
└── .gitignore

## Design Overview

- Standard UART frame format (8 data bits, no parity, 1 stop bit)
- Configurable baud rate via generics
- FSM-based TX and RX architectures
- RX input synchronized using double flip-flop technique
- Active-low synchronous reset

## UART Transmitter (uart_tx)

- Accepts data using a one-clock-cycle `tx_valid` handshake
- Indicates availability through `tx_ready`
- Generates start bit, data bits (LSB first), and stop bit
- Baud-rate timing derived from system clock using a counter

## UART Receiver (uart_rx)

- Asynchronous RX input synchronized using a 2-FF synchronizer
- Start bit detection with half-bit confirmation
- Mid-bit sampling for data bits
- Stop bit validation with frame error detection
- Outputs received byte with a one-clock-cycle `rx_valid` pulse

## Top-Level Integration (uart_top)

- Integrates TX and RX modules
- Optional internal loopback (TXD → RXD) enabled via generic
- Suitable for both standalone simulation and FPGA integration

## Verification Strategy

All modules are verified using self-checking testbenches:

- TX testbench verifies bit timing, start/stop bits, and data integrity
- RX testbench verifies correct reception and frame error detection
- Top-level testbench verifies end-to-end UART communication using internal loopback

Simulation waveforms are provided in the `docs/` directory.

## Tools

- Language: VHDL
- Simulator: Vivado Simulator (or any compatible VHDL simulator)

## Usage

1. Clone the repository
2. Run the desired testbench under the `tb/` directory
3. Observe assertions and waveform outputs for verification

----------------------------------------------------------------------------------------------
## UART Protocol Overview
![UART Frame Format](docs/uart_frame.png)
----------------------------------------------------------------------------------------------

 ## 🇹🇷 Türkçe
 
 # FPGA Tabanlı UART Tasarımı (VHDL)

Bu repo, VHDL kullanılarak geliştirilmiş tam sentezlenebilir bir
UART (Universal Asynchronous Receiver/Transmitter) tasarımını içerir.
Tasarım; bağımsız verici (TX), alıcı (RX) modülleri ve dahili loopback
destekli üst seviye entegrasyon modülünden oluşur.

Proje, kendi kendini doğrulayan (self-checking) testbench’ler ile
RTL seviyesinde test edilmiştir.

## Proje Yapısı

FPGA-Based-UART-Design/
├── rtl/
│   ├── uart_tx.vhd      -- FSM tabanlı UART verici
│   ├── uart_rx.vhd      -- Giriş senkronizasyonlu UART alıcı
│   └── uart_top.vhd     -- Opsiyonel loopback içeren üst seviye modül
│
├── tb/
│   ├── tb_uart_tx.vhd   -- TX için self-checking testbench
│   ├── tb_uart_rx.vhd   -- RX doğrulama ve frame error testleri
│   └── tb_uart_top.vhd  -- Uçtan uca loopback doğrulaması
│
├── docs/
│   └── *.png            -- Simülasyon dalga formları
│
├── README.md
└── .gitignore

## Tasarım Özeti

- Standart UART çerçevesi (8 veri biti, parity yok, 1 stop biti)
- Generic parametreler ile ayarlanabilir baud hızı
- TX ve RX için FSM tabanlı mimari
- RX hattı için çift flip-flop senkronizasyonu
- Aktif düşük senkron reset yapısı

## UART Verici (uart_tx)

- `tx_valid` sinyali ile 1 clock genişliğinde veri kabulü
- `tx_ready` ile vericinin hazır durumu
- Start biti, veri bitleri (LSB first) ve stop biti üretimi
- Sistem saatinden türetilmiş baud zamanlaması

## UART Alıcı (uart_rx)

- Asenkron RX girişinin 2FF ile senkronizasyonu
- Start bit için yarım-bit doğrulaması
- Veri bitleri için orta-bit örnekleme
- Stop bit kontrolü ve frame error tespiti
- Alınan byte için 1 clock’luk `rx_valid` darbesi

## Üst Seviye Entegrasyon (uart_top)

- TX ve RX modüllerinin entegrasyonu
- Generic ile kontrol edilen dahili loopback (TXD → RXD)
- Hem simülasyon hem FPGA entegrasyonu için uygun yapı

## Doğrulama Yaklaşımı

Tüm modüller self-checking testbench’ler ile test edilmiştir:

- TX testbench: bit zamanlaması ve veri bütünlüğü
- RX testbench: doğru çerçeve ve stop bit hatası senaryoları
- Top-level testbench: uçtan uca UART loopback doğrulaması

Simülasyon dalga formları `docs/` klasöründe yer almaktadır.

## Kullanılan Araçlar

- Dil: VHDL
- Simülatör: Vivado Simulator veya uyumlu VHDL simülatörleri

## Kullanım

1. Repoyu klonlayın
2. `tb/` altındaki testbench’lerden birini çalıştırın
3. Assertion mesajları ve dalga formlarını inceleyin

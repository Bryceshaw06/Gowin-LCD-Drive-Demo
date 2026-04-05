<div align="center">
  <h1 style="font-size: 48px; font-weight: bold;">Gowin LCD Drive Demo</h1>

  [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/Bryceshaw06/Gowin-LCD-Drive-Demo/blob/main/LICENSE.md)
  ![Language: SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-purple.svg)

  <img src="https://github.com/Bryceshaw06/Gowin-LCD-Drive-Demo/blob/main/assets/demo.gif" alt="Gowin LCD Drive Demo - test patterns cycling on 5 inch 800x480 LCD" width="800" style="max-width: 100%; border: 1px solid #ddd; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>


A highly portable FPGA framework that drives parallel RGB LCD panels using the **Sipeed Tang Nano 9K**. It comes pre-loaded with several test patterns and acts as a clean, beginner-friendly reference for display timings, pixel rendering, and hardware management written in **SystemVerilog**. Patterns are located in the `src/patterns/` directory and are easy to modify.

By default, this repository is configured for a **5 inch 800x480 40-Pin LCD**. 

While this demo runs easily out-of-the-box on the Tang Nano 9K, the code is heavily parameterized and meant to be highly portable to your custom development boards utilizing Gowin chips like the `GW1NR-LV9QN88P` on the Tang.

## Features

- **Multi-display Support**: Swap targets extremely easily. By default, it drives the 5" 800x480 screen, but a few parameters in `top.sv` allow for support of a 3.5" 640x480 panel from [BuyDisplay](https://www.buydisplay.com/ips-3-5-inch-full-viewing-640x480-tft-display-capacitive-touch-screen) / [RG35XX](https://www.aliexpress.us/item/3256805605409482.html). *(Note: This 3.5" panel uses a different FFC layout than the Tang Nano's connector, so this 3.5" option is mostly useful for custom routed boards or a breakout of some kind).*
- **Interactive Patterns**: Press the onboard user button (closest to the LCD) to cycle through animated test patterns.
- **Backlight Dimming**: Includes a PWM module to control backlight brightness via the onboard booster chip (LP3320 - see note under Important Hardware Quirks).
- **SPI Initialization:** Automatically configures the 3.5" 640x480 display over SPI at boot using a state machine.

## Project Structure

```text
Gowin-LCD-Drive-Demo
 ┣ src
 ┃ ┣ gowin_rpll
 ┃ ┃ ┗ gowin_rpll.v
 ┃ ┣ patterns
 ┃ ┃ ┣ border_pattern.sv
 ┃ ┃ ┣ bounce_pattern.sv
 ┃ ┃ ┣ color_cycle_pattern.sv
 ┃ ┃ ┣ moving_stripes_pattern.sv
 ┃ ┃ ┣ solid_pattern.sv
 ┃ ┃ ┗ xor_pattern.sv
 ┃ ┣ button_toggle.sv
 ┃ ┣ lcd_shared.sv
 ┃ ┣ pattern_selector.sv
 ┃ ┣ pwm_backlight.sv
 ┃ ┣ spi_lcd_init.sv
 ┃ ┣ top.cst
 ┃ ┣ top.sv
 ┃ ┗ video_timings.sv
 ┣ Gowin-LCD-Drive-Demo.gprj
 ┗ README.md
```

## Usage

This project is built using the **Gowin IDE Education Edition** and targets the **Sipeed Tang Nano 9K** (`GW1NR-LV9QN88PC6/I5`).

### 1. Install Tools

- Install the Gowin IDE Education Edition corresponding to your operating system. [Download link is here](https://www.gowinsemi.com/en/support/download_eda/)

### 2. Open the Project

1. Download this repository and launch Gowin IDE.
2. Click **Open Project** and select `Gowin-LCD-Drive-Demo.gprj` from the repo root.
3. Confirm the target device is set for the Tang Nano 9K (`GW1NR-9C` / `GW1NR-LV9QN88PC6/I5`).

### 3. Build and Program

1. In the Gowin IDE Process pane, click **Run Synthesis**, **Run Place and Route**, and then **Programmer**.
2. Insert the 40-pin 5" LCD into the connector on the Tang Nano 9K board.
3. Connect your Tang Nano 9K to the computer via USB.
4. Program the FPGA by flashing the bitstream to the SRAM. (SRAM does not persist after power loss. To program to flash memory, set **Access Mode** to **Embedded Flash Mode** and save).

After programming, the LCD will immediately boot up and display a test pattern. Press the LCD-facing button on the Tang Nano 9K board to cycle through them! The second user button is mapped to **reset**, and will cause the LCD to restart if pressed.

## Important Hardware Quirks

**Backlight Brightness Control (PWM):** 
This project features logic to smoothly control screen brightness via PWM by outputting to Pin 86. However, on the Tang Nano 9K development board, the physical connection to the onboard backlight boost converter is severed by default. 

**You must solder a small puddle of solder or a jumper across the `R24` pads** (which are left NC - No Connect from the factory) to enable this hardware brightness control. 

## Resources

Here are a few resources I used for understanding during the creation of this project that may be helpful for further research:

- [Project F: Video Timings](https://projectf.io/posts/video-timings-vga-720p-1080p/)
- [Electronica y Ciencia: LCD Tang Nano Patrones](https://www.electronicayciencia.com/2021/11/lcd_tang_nano_I_patrones.html)
- [Sipeed Wiki: RGB Screen Example](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/examples/rgb_screen.html)
- [Lushay Labs: Tang Nano Series](https://learn.lushaylabs.com/tang-nano-series/)
- [Sipeed Downloads: Tang Nano 9K Resources](https://dl.sipeed.com/shareURL/TANG/Nano%209K/)
- [Greg Huhler - I2C Target (Slave) on Tang Nano 9K FPGA Board Integrated with PWM Controller Dimming LED](https://www.youtube.com/watch?v=o_eFtO93-dE)

## Issues or Improvements

If you find a bug, have a question, or want to suggest an improvement, open an issue here:

https://github.com/Bryceshaw06/Gowin-LCD-Drive-Demo/issues

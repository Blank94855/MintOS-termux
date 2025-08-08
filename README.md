
# MintOS-Termux 🌿🐟

**MintOS** is a sleek, customizable Termux shell environment powered by the powerful **fish shell**. It transforms your Termux terminal into a colorful, user-friendly workspace with:

- Vibrant, easy-to-read banners & greetings
- Fully customizable user aliases
- Built-in neofetch for system info with optional Android logo
- Simple update & maintenance commands
<img width="1815" height="3840" alt="iMockup - Google Pixel 9 Pro" src="https://github.com/user-attachments/assets/277e3788-8088-4e19-94c9-96543224a673" />

---

## Features

- Powered by **fish shell** for a modern, user-friendly command experience
- Dynamic ASCII banners with multiple font & color options
- Automatic dependency checks & installs: fish, figlet, neofetch, lolcat (optional)
- Handy aliases like `updateme`, `software-update`, and `myaliases`
- Interactive setup to customize banner text, fonts, and aliases
- Neofetch integration showing your system info on startup
- Easy update process to keep your MintOS fresh and stable

---

## Installation

Run this command in Termux to install MintOS-Termux:

```bash
pkg update && pkg upgrade -y && pkg install git -y && git clone https://github.com/Blank94855/MintOS-termux.git && cd MintOS-termux && chmod +x script.sh && ./script.sh
```

---

## Updating MintOS-Termux

To update MintOS without reinstalling, use this command:

```bash
cd ~/MintOS-termux && git reset --hard && git pull origin main && chmod +x script.sh && ./script.sh
```

This command discards any local changes, pulls the latest version from GitHub, and reruns the setup script to keep your shell environment up to date.

---

## Usage

- Open a new Termux session after installation
- Enjoy the fresh MintOS banner and custom greeting
- Use `updateme` alias to update Termux packages easily
- Type `software-update` to see MintOS system info & changelog
- Customize your shell further with `myaliases`

---

## Why MintOS?

MintOS-Termux is designed to bring a fresh, stylish, and efficient command-line experience to Termux users who want more than the default shell. With fish shell's advanced features and MintOS's vibrant setup, your terminal becomes a fun, powerful tool.

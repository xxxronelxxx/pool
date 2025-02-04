# Yiimpool Yiimp Installer with DaemonBuilder

<p align="center">
  <img alt="Discord" src="https://img.shields.io/discord/904564600354254898?label=Discord">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/afiniel/yiimp_install_script">
  <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/afiniel/yiimp_install_script">
</p>

## Description

This installer provides an automated way to set up a full Yiimp mining pool on Ubuntu and Debian systems. Key features include:

- Automated installation and configuration of all required components
- Built-in DaemonBuilder for compiling coin daemons
- Multiple SSL configuration options (Let's Encrypt or self-signed)
- Support for both domain and subdomain setups
- Enhanced security features and server hardening
- Automatic stratum setup with autoexchange capability
- Web-based admin interface
- Built-in upgrade tools
- Comprehensive screen management for monitoring
- PhpMyAdmin for database management

## System Requirements

- Fresh Ubuntu/Debian installation
- Minimum 8GB RAM (16GB recommended)
- 2+ CPU cores
- Clean domain or subdomain pointed to your VPS

## Supported Operating Systems

### Ubuntu
⚠️ Installation Works (Limited Testing):
- Ubuntu 24.04 LTS
- Ubuntu 23.04
- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS
- Ubuntu 18.04 LTS

### Debian
⚠️ Installation Works (Limited Testing):
- Debian 11
- Debian 12 (Build Stratum not working)

## Installation

### Quick Install
```bash
curl https://raw.githubusercontent.com/afiniel/Yiimpoolv1/master/install.sh | bash
```

### Configuration Steps
The installer will guide you through:
1. Domain setup (main domain or subdomain)
2. SSL certificate installation
3. Database credentials
4. Admin portal location
5. Email settings
6. Stratum configuration

## Post-Installation Steps
1. **Required**: Reboot your server after installation
2. Wait 1-2 minutes after first login for services to initialize
3. Run `motd` to view pool status

## Directory Structure

The installer uses a secure directory structure:

| Directory | Purpose |
|-----------|---------|
| /home/crypto-data/yiimp | Main YiiMP directory |
| /home/crypto-data/yiimp/site/web | Web files |
| /home/crypto-data/yiimp/starts | Screen management scripts |
| /home/crypto-data/yiimp/site/backup | Database backups |
| /home/crypto-data/yiimp/site/configuration | Core configuration |
| /home/crypto-data/yiimp/site/crons | Cron job scripts |
| /home/crypto-data/yiimp/site/log | Log files |
| /home/crypto-data/yiimp/site/stratum | Stratum server files |

## Management Commands

### Screen Management
```bash
screen -list         # View all screens
screen -r [name]     # Access screen (main|loop2|blocks|debug)
ctrl+a+d             # Detach from current screen
```

### Service Control
```bash
screens start|stop|restart [service]   # Control specific services
yiimp                                  # View pool overview
motd                                   # Check system status
```

## DaemonBuilder

Built-in coin daemon compiler accessible via the `daemonbuilder` command. Features:
- Automated dependency handling
- Support for multiple compile options
- Custom port configuration

## Security Best Practices
1. Keep your system updated regularly
2. Use strong passwords for all services
3. Do not modify default file permissions
4. Regularly backup your data

## Support

For assistance:
- Open an issue on GitHub
- Join our Discord server

## Donation wallets if you want to support me Thank you

Donations appreciated:
- BTC: bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9
- BCH: qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87
- ETH: 0xdA929d4f03e1009Fc031210DDE03bC40ea66D044
- LTC: MC9xjhE7kmeBFMs4UmfAQyWuP99M49sCQp
- DOGE: DHNhm8FqNAQ1VTNwmCHAp3wfQ6PcfzN1nu
- SOLANA: 4Akj4XQXEKX4iPEd9A4ogXEPNrAsLm4wdATePz1XnyCu
- BEP-20: 0xdA929d4f03e1009Fc031210DDE03bC40ea66D044
- KASPA: kaspa:qrhfn2tl3ppc9qx448pgp6avv88gcav3dntw4p7h6v0ht3eac7pl6lkcjcy7r


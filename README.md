
# Yiimpool Yiimp Installer with DaemonBuilder

<p align="center">
  <img alt="Discord" src="https://img.shields.io/discord/904564600354254898?label=Discord">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/afiniel/yiimp_install_script">
  <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/afiniel/yiimp_install_script">
</p>

## Description

This installer provides an automated way to set up a full Yiimp mining pool on Ubuntu 18.04/20.04. Key features include:

- Automated installation and configuration of all required components
- Built-in DaemonBuilder for compiling coin daemons
- Multiple SSL configuration options (Let's Encrypt or self-signed)
- Support for both domain and subdomain setups
- Enhanced security features and server hardening
- Automatic stratum setup with autoexchange capability
- Web-based admin interface
- Built-in upgrade tools
- Comprehensive screen management for monitoring

## Requirements

- Fresh Ubuntu 18.04 or 20.04 installation
- Minimum 8GB RAM
- Clean domain or subdomain pointed to your VPS

## Quick Install

```bash
curl https://raw.githubusercontent.com/afiniel/Yiimpoolv1/master/install.sh | bash
```

The installer will guide you through configuration options including:
- Domain setup (main domain or subdomain)
- SSL certificate installation
- Database credentials
- Admin portal location
- Email settings
- Stratum configuration

## Post-Install

1. After installation completes, a server reboot is **required**
2. Upon first login after reboot, wait 1-2 minutes for services to start
3. Use the `motd` command to view your pool status
4. Access your admin panel at the configured URL

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

## Usage Commands

- View all screens: `screen -list`
- Access specific screen: `screen -r main|loop2|blocks|debug` 
- Detach from screen: `ctrl+a+d`
- Start/stop/restart services: `screens start|stop|restart main|loop2|blocks|debug`
- Pool overview: `yiimp`
- System status: `motd`

## DaemonBuilder

Built-in coin daemon compiler accessible via the `daemonbuilder` command. Features:
- Automated dependency handling
- Support for multiple coins
- Berkeley DB compilation
- Custom port configuration

## Support

For assistance:
- Open an issue on GitHub
- Join our Discord server

Donations appreciated:
- BTC: bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9
- BCH: qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87
- ETH: 0xdA929d4f03e1009Fc031210DDE03bC40ea66D044
- LTC: MC9xjhE7kmeBFMs4UmfAQyWuP99M49sCQp
- DOGE: DHNhm8FqNAQ1VTNwmCHAp3wfQ6PcfzN1nu
- SOLANA: 4Akj4XQXEKX4iPEd9A4ogXEPNrAsLm4wdATePz1XnyCu
- BEP-20: 0xdA929d4f03e1009Fc031210DDE03bC40ea66D044
- KASPA: kaspa:qrhfn2tl3ppc9qx448pgp6avv88gcav3dntw4p7h6v0ht3eac7pl6lkcjcy7r

## Security Notice

Default permissions are configured for security - avoid modifying directory/file permissions as this may cause system instability.

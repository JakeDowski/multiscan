# multiscan
Script for basic web-app pentesting

# MultiScan

A script I made for running Nmap, Gobuster and Nikto scans all at once, ideal for beginner CTFs.

## Installation

### Prerequisites

Ensure the following tools are installed on your system:

```bash
nmap
gobuster
nikto
```

### Install MultiScan

1. **Clone the repository:**
   ```bash
   git clone https://github.com/JakeDowski/multiscan.git
   cd multiscan
   ```

2. **Make the script executable:**
   ```bash
   chmod +x multiscan.sh
   ```

## Usage

```bash
./multiscan.sh -i <target> [OPTIONS]
```

**Options:**
- `-i, --ip` - Target IP address or domain (required)
- `-s, --speed` - Scan speed level 1-3 (default: 2)
- `--https` - Use HTTPS instead of HTTP
- `-h, --help` - Show help message

### Speed Levels

#### Speed 1 (Slow/Thorough)
- **Best for**: Comprehensive security assessments
- **Nmap**: Full aggressive scan with vulnerability scripts
- **Gobuster**: Large wordlist with extensive file extensions
- **Nikto**: All plugins with evasion techniques
- **DNS**: 20,000 subdomain wordlist

#### Speed 2 (Medium) - Default
- **Best for**: Balanced reconnaissance
- **Nmap**: Standard service and script scanning
- **Gobuster**: Medium wordlist with common extensions
- **Nikto**: Default plugin set
- **DNS**: 5,000 subdomain wordlist

#### Speed 3 (Fast)
- **Best for**: Quick assessments or time-sensitive scans
- **Nmap**: Basic service detection
- **Gobuster**: Small wordlist with essential extensions
- **Nikto**: Essential plugins only
- **DNS**: 1,000 subdomain wordlist

## Examples

### Basic Usage
```bash
# Quick scan of a domain (HTTP, medium speed)
./multiscan.sh -i example.com

# HTTPS scan with fast speed
./multiscan.sh -i example.com --https -s 3

# Thorough scan of an IP address
./multiscan.sh -i 192.168.1.100 -s 1

# Medium scan with HTTPS
./multiscan.sh --ip target.com --https --speed 2
```

### Global Usage (after installation)
```bash
multiscan -i example.com -s 1 --https
multiscan --ip 192.168.1.100 --speed 3
```

## Output Files

MultiScan generates separate output files for each scan type:

- `dir_results_speed[1-3].txt` - Directory enumeration results
- `dns_results_speed[1-3].txt` - DNS/subdomain enumeration results
- `nikto_results_speed[1-3].txt` - Vulnerability scan results

Example output files:
```
dir_results_speed2.txt
dns_results_speed2.txt
nikto_results_speed2.txt
```

## Sample Output

```
$ multiscan -i example.com -s 2

Using HTTP for example.com (default)
Medium speed scan (Level 2) selected
Starting nmap scan with speed level 2...
[Nmap results...]

STARTING DNS ENUMERATION
Target domain: example.com
Using DNS wordlist: /usr/share/wordlists/dnsrecon/subdomains-top1mil-5000.txt
DNS threads: 75
[DNS enumeration results...]

STARTING DIRECTORY ENUMERATION
Using directory wordlist: /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
Extensions: php,html,txt,js,jsp,asp
Threads: 50
[Directory enumeration results...]

STARTING NIKTO VULNERABILITY SCAN
Running standard scan with default plugins...
[Nikto vulnerability results...]

=== SCAN COMPLETE ===
Results saved to:
- Directory enumeration: dir_results_speed2.txt
- DNS enumeration: dns_results_speed2.txt
- Vulnerability scan: nikto_results_speed2.txt
```

## Wordlist Requirements

MultiScan expects the following wordlists to be available:

### Directory Enumeration
- `/usr/share/wordlists/dirb/common.txt` (fallback)
- `/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
- `/usr/share/wordlists/dirbuster/directory-list-2.3-big.txt`

### DNS Enumeration
- `/usr/share/wordlists/dnsrecon/subdomains-top1mil-1000.txt`
- `/usr/share/wordlists/dnsrecon/subdomains-top1mil-5000.txt`
- `/usr/share/wordlists/dnsrecon/subdomains-top1mil-20000.txt`

**Note**: If wordlists are not found, the script will attempt to use fallback options or skip that particular scan.

## Disclaimer

This tool is intended for authorized security testing and educational purposes only. Users are responsible for ensuring they have proper authorization before scanning any targets. The authors are not responsible for any misuse of this tool.

## Acknowledgments

- **Nmap** - Network exploration and security auditing
- **Gobuster** - Directory/file & DNS busting tool
- **Nikto** - Web server scanner
- **SecLists** - Collection of security testing wordlists

---

**Author**: Jake Lewandowski 
**Version**: 1.0  
**Last Updated**: 16/07/2025

#!/bin/bash

# Default values
USE_HTTPS=false
TARGET_IP=""
SPEED=2  # Default to medium speed

# Parse arguments manually
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            TARGET_IP="$2"
            shift 2
            ;;
        --https)
            USE_HTTPS=true
            shift
            ;;
        -s|--speed)
            SPEED="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -i <target_ip> [OPTIONS]"
            echo "  -i, --ip      Target IP address or domain [required]"
            echo "  --https       Use HTTPS instead of HTTP (default: HTTP)"
            echo "  -s, --speed   Scan speed level 1-3 (default: 2)"
            echo "                1 = Slow/thorough (large wordlists, aggressive scans, full Nikto)"
            echo "                2 = Medium speed (medium wordlists, standard scans, basic Nikto)"
            echo "                3 = Fast scan (small wordlists, basic scans, quick Nikto)"
            echo "  -h, --help    Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if required IP argument is provided
if [ -z "$TARGET_IP" ]; then
    echo "Error: -i (target IP/domain) is required"
    echo "Usage: $0 -i <target_ip> [OPTIONS]"
    exit 1
fi

# Validate speed level
if [ "$SPEED" -lt 1 ] || [ "$SPEED" -gt 3 ]; then
    echo "Error: Speed must be between 1-3"
    exit 1
fi

# Set protocol based on flag
if [ "$USE_HTTPS" = true ]; then
    echo "Using HTTPS for $TARGET_IP"
    PROTOCOL="https"
else
    echo "Using HTTP for $TARGET_IP (default)"
    PROTOCOL="http"
fi

# Set scan parameters based on speed level
case $SPEED in
    1)
        echo "Slow/thorough scan (Level 1) selected"
        NMAP_FLAGS="-sV -sC -A -O --script vuln"
        DIR_WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-big.txt"
        DNS_WORDLIST="/usr/share/wordlists/dnsrecon/subdomains-top1mil-20000.txt"
        EXTENSIONS="php,html,txt,js,jsp,asp,aspx,json,xml,bak,old,zip,tar,gz"
        THREADS=30
        DNS_THREADS=50
        # Nikto: Full comprehensive scan with all plugins
        NIKTO_FLAGS="-Plugins @@ALL -evasion 1,2,3,4 -Format txt"
        NIKTO_DESC="comprehensive scan with all plugins and evasion techniques"
        ;;
    2)
        echo "Medium speed scan (Level 2) selected"
        NMAP_FLAGS="-sV -sC"
        DIR_WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
        DNS_WORDLIST="/usr/share/wordlists/dnsrecon/subdomains-top1mil-5000.txt"
        EXTENSIONS="php,html,txt,js,jsp,asp"
        THREADS=50
        DNS_THREADS=75
        # Nikto: Standard scan with common plugins
        NIKTO_FLAGS="-Plugins @@DEFAULT -Format txt"
        NIKTO_DESC="standard scan with default plugins"
        ;;
    3)
        echo "Fast scan (Level 3) selected"
        NMAP_FLAGS="-sV"
        DIR_WORDLIST="/usr/share/wordlists/dirb/common.txt"
        DNS_WORDLIST="/usr/share/wordlists/dnsrecon/subdomains-top1mil-1000.txt"
        EXTENSIONS="php,html,txt"
        THREADS=100
        DNS_THREADS=100
        # Nikto: Quick scan with minimal plugins
        NIKTO_FLAGS="-Plugins @@FAST -no404 -Format txt"
        NIKTO_DESC="quick scan with essential plugins only"
        ;;
esac

# Extract domain name for DNS enumeration (in case IP was provided, try reverse lookup)
if [[ $TARGET_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "IP address detected. Attempting reverse DNS lookup..."
    DOMAIN=$(dig -x $TARGET_IP +short | head -1 | sed 's/\.$//')
    if [ -z "$DOMAIN" ]; then
        echo "Could not determine domain from IP. Skipping DNS enumeration."
        SKIP_DNS=true
    else
        echo "Domain found: $DOMAIN"
        SKIP_DNS=false
    fi
else
    DOMAIN=$TARGET_IP
    SKIP_DNS=false
fi

echo "Starting nmap scan with speed level $SPEED..."
nmap $NMAP_FLAGS $TARGET_IP

# DNS Enumeration
if [ "$SKIP_DNS" = false ]; then
    echo -e "\nSTARTING DNS ENUMERATION\n"
    echo "Target domain: $DOMAIN"
    echo "Using DNS wordlist: $DNS_WORDLIST"
    echo "DNS threads: $DNS_THREADS"
    
    # Check if DNS wordlist exists, fallback if not
    if [ ! -f "$DNS_WORDLIST" ]; then
        echo "Primary DNS wordlist not found, trying alternative..."
        if [ -f "/usr/share/wordlists/dirb/common.txt" ]; then
            DNS_WORDLIST="/usr/share/wordlists/dirb/common.txt"
            echo "Using fallback wordlist: $DNS_WORDLIST"
        else
            echo "No suitable DNS wordlist found. Skipping DNS enumeration."
            SKIP_DNS=true
        fi
    fi
    
    if [ "$SKIP_DNS" = false ]; then
        gobuster dns -d $DOMAIN -w $DNS_WORDLIST -t $DNS_THREADS -o dns_results_speed${SPEED}.txt
        echo "DNS enumeration complete! Results saved to dns_results_speed${SPEED}.txt"
    fi
else
    echo -e "\nSkipping DNS enumeration (no domain available)\n"
fi

echo -e "\nSTARTING DIRECTORY ENUMERATION\n"
echo "Using directory wordlist: $DIR_WORDLIST"
echo "Extensions: $EXTENSIONS"
echo "Threads: $THREADS"

gobuster dir -u $PROTOCOL://$TARGET_IP -w $DIR_WORDLIST -x $EXTENSIONS -t $THREADS -o dir_results_speed${SPEED}.txt

# Nikto Vulnerability Scan
echo -e "\nSTARTING NIKTO VULNERABILITY SCAN\n"
echo "Running $NIKTO_DESC..."

# Check if Nikto is installed
if command -v nikto &> /dev/null; then
    nikto -h $PROTOCOL://$TARGET_IP $NIKTO_FLAGS -o nikto_results_speed${SPEED}.txt
    echo "Nikto scan complete! Results saved to nikto_results_speed${SPEED}.txt"
else
    echo "Warning: Nikto not installed. Install with: sudo apt install nikto"
    echo "Skipping vulnerability scan..."
fi

echo -e "\n=== SCAN COMPLETE ==="
echo "Results saved to:"
echo "- Directory enumeration: dir_results_speed${SPEED}.txt"
if [ "$SKIP_DNS" = false ]; then
    echo "- DNS enumeration: dns_results_speed${SPEED}.txt"
fi
if command -v nikto &> /dev/null; then
    echo "- Vulnerability scan: nikto_results_speed${SPEED}.txt"
fi

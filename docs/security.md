# Security

TLS is terminated by `stunnel` inside the pod. Certificates are self-signed and stored on the network volume so they persist across restarts.

Certificates are trusted locally using `fetch-cert.sh`. The firewall allows only the IP specified by `HOME_IP` to connect:

```bash
sudo iptables -A INPUT -p tcp --dport 443 ! -s $HOME_IP -j DROP
sudo iptables -A INPUT -p tcp --dport 444 ! -s $HOME_IP -j DROP
```

Paperless-ngx 3.4.0 offline package for Windows 10 Docker Linux containers (amd64)

1. Create a NEW PUBLIC GitHub repository (do not put any company documents, passwords, or private data in it). Upload these files including .github/workflows/build-offline.yml.
2. GitHub -> Actions -> Build Paperless Offline AMD64 -> Run workflow.
3. Open your repo Releases -> Paperless-ngx 3.4.0 offline AMD64; download all images.part-* and configuration files on phone; copy into C:\Paperless on offline PC.
4. Ensure Docker Desktop runs in Linux container mode (docker info --format '{{.OSType}}' => linux).
5. PowerShell: cd C:\Paperless; powershell -ExecutionPolicy Bypass -File .\start.ps1
6. Open http://localhost:8000 and create administrator if prompted.

This configuration binds to localhost only. Do NOT expose to LAN until authentication, firewall/TLS, backups and access policy are ready.
The database and documents live in named Docker volumes. Back up volumes and .env separately.
If Docker is currently configured to Windows containers, it must be switched to Linux containers.
GitHub Actions runner requires network access to registries and Debian packages; offline PC does not.

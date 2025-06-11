# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Free5GC + UERANSIM handover simulation project that implements a containerized 5G core network with radio access network simulation. The architecture consists of:

- **Free5GC containers**: Complete 5G standalone core network functions (AMF, SMF, UPF, NRF, AUSF, NSSF, PCF, UDM, UDR, CHF, N3IWF, TNGF, NEF, WebUI)
- **UERANSIM container**: gNB (base station) and UE (user equipment) simulators
- **MongoDB**: Subscriber database backend

The project uses Docker Compose to orchestrate multiple containers with proper service dependencies and networking. Configuration files are mounted from the host system to containers for easy customization.

## Common Commands

### Basic Operations
- `make up` - Start all 5G services with docker-compose
- `make down` - Stop all services
- `make logs` - View live logs from all services
- `make clean` - Remove Docker images and cleanup

### Development Operations
- `docker-compose up -d` - Start services in detached mode
- `docker-compose restart <service>` - Restart specific service (e.g., `free5gc-amf`)
- `docker-compose logs -f <service>` - Follow logs for specific service
- `docker-compose exec <service> bash` - Access container shell

### Configuration Management
Configuration files are in `free5gc-compose/config/` and mounted to containers. Edit them directly on the host system - no rebuild required.

## Architecture Details

### Service Dependencies
The startup order is critical:
1. `db` (MongoDB) - Database backend
2. `free5gc-nrf` - Network Repository Function (service discovery)
3. Core network functions (`amf`, `ausf`, `nssf`, `pcf`, `smf`, `udm`, `udr`, `chf`, `nef`) - depends on NRF
4. `free5gc-upf` - User Plane Function (data forwarding)
5. `free5gc-webui` - Web management interface
6. `ueransim` - Radio access network simulation

### Network Configuration
- Docker bridge network: `10.100.200.0/24`
- Key services have fixed IPs:
  - AMF: `10.100.200.16` (NGAP interface for gNB connection)
  - N3IWF: `10.100.200.15` (non-3GPP access)
  - N3IWUE: `10.100.200.203` (WiFi UE simulator)

### Critical Capabilities
Services require specific Docker capabilities:
- UPF, N3IWF, TNGF, UERANSIM: `NET_ADMIN` (for GTP tunnels and network interfaces)
- UERANSIM, N3IWUE: `/dev/net/tun` device access (for TUN interface creation)

## Current Status

The project is incomplete and focuses on handover simulation between multiple gNBs. The main TODO items from the documentation:
- Modify docker-compose to run two gNB containers (`ueransim1`, `ueransim2`)
- Implement UE mobility simulation moving between gNBs
- Study existing handover implementation approaches

## Configuration Structure

Key configuration files are in `free5gc-compose/config/`:
- Network functions: `amfcfg.yaml`, `smfcfg.yaml`, `upfcfg.yaml`, etc.
- UERANSIM: `gnbcfg.yaml`, `uecfg.yaml`
- WebUI: `webuicfg.yaml`

Container hostnames are used for inter-service communication instead of IP addresses for service discovery.
# Implementation Plan: Free5GC + UERANSIM Container Demo

## Overview

This plan implements a containerized version of the free5gc + UERANSIM testing scenario based on the tutorial at https://free5gc.org/guide/5-install-ueransim/#7-testing-ueransim-against-free5gc. Unlike the tutorial which uses manual installation across two VMs, this implementation uses Docker Compose with separate containers for each component using pre-built .deb packages.

## Key Differences from Original Tutorial

### Original Tutorial Setup:
- Two separate VMs (free5gc VM: 192.168.56.101, ueransim VM: 192.168.56.102)  
- Manual source compilation and installation
- Configuration files in `~/free5gc/config/` and `~/UERANSIM/config/`

### Container Setup:
- Multi-container Docker Compose architecture
- Separate containers for MongoDB, free5gc core, gNB, and UE
- Pre-built .deb packages for installation
- Configuration files in standardized system paths:
  - **Free5GC configs**: `/etc/free5gc/`
  - **UERANSIM configs**: `/opt/ueransim/config/`
- Network simulation using Docker bridge networking

## Phase 1: Docker Image Preparation ✅

**Status: COMPLETED**

The implementation includes:
- **free5gc container** (Dockerfile.free5gc): All core network functions (AMF, SMF, UPF, NRF, AUSF, etc.)
- **ueransim container** (Dockerfile.ueransim): gNB and UE simulator components
- **mongodb container**: Subscriber data storage
- **docker-compose.yml**: Orchestrates all services with proper networking

### Configuration Structure ✅

**Host Configuration Files:**
- `config/free5gc/` - All free5gc network function configurations
  - `amfcfg.yaml`, `smfcfg.yaml`, `upfcfg.yaml`, `nrfcfg.yaml`, etc.
  - `webuicfg.yaml` - Web console configuration
  - Special configs: `multiAMF/`, `multiUPF/` for advanced scenarios
- `config/UERANSIM/` - UERANSIM configurations
  - `free5gc-gnb.yaml`, `free5gc-ue.yaml` - Default configurations for free5gc
  - `custom-gnb.yaml`, `custom-ue.yaml` - Customizable templates
  - `open5gs-gnb.yaml`, `open5gs-ue.yaml` - Alternative core network configs

**Container Mount Points:**
- Free5GC configs mounted to `/etc/free5gc/` in free5gc container
- UERANSIM configs mounted to `/opt/ueransim/config/` in ueransim containers
- Users can edit host files in `config/` directory and changes are reflected immediately

## Phase 2: Configuration Adaptation

### 2.1 Network Configuration Analysis

**Original Tutorial IPs:**
- free5gc VM: 192.168.56.101
- ueransim VM: 192.168.56.102

**Container Approach:**
- Use Docker bridge network (172.20.0.0/24) for inter-container communication
- Service discovery via container names (free5gc, ueransim-gnb, ueransim-ue)
- Expose ports: 38412 (NGAP), 8000 (WebUI), 2152/udp (GTP-U)

### 2.2 Configuration Management ✅

**Host-Based Configuration Editing:**
Users can directly edit configuration files in the `config/` directory:

- `config/free5gc/amfcfg.yaml` - Modify AMF settings
- `config/free5gc/smfcfg.yaml` - Modify SMF settings  
- `config/free5gc/upfcfg.yaml` - Modify UPF settings
- `config/UERANSIM/free5gc-gnb.yaml` - Modify gNB settings
- `config/UERANSIM/free5gc-ue.yaml` - Modify UE settings

**Key Configuration Points for Docker Networking:**
- Use container hostnames (`free5gc`, `ueransim-gnb`, `ueransim-ue`) instead of IP addresses
- Bind services to `0.0.0.0` for external accessibility within Docker network
- Reference other containers by their service names in docker-compose.yml

**Configuration Workflow:**
1. Copy example configs from source repositories (✅ completed)
2. Edit configs in `config/` directory on host system
3. Start containers with `make up` - configs are automatically mounted
4. Make runtime changes by editing host files - no container restart needed
5. For major changes, restart specific services: `docker-compose restart free5gc`

## Phase 3: Simulation Scripts

### 3.1 Core Script: `run-simulation.sh`

Create a main simulation script that:
1. Validates configuration files
2. Starts MongoDB
3. Starts free5gc core network functions in correct order
4. Starts UERANSIM gNB and UE
5. Provides logging and status monitoring

### 3.2 Configuration Management

**Option 1: Default Configuration**
- Use pre-configured files optimized for container environment
- Simple `docker run` command starts entire simulation

**Option 2: Custom Configuration**  
- Allow users to mount custom config directories
- Validation script checks configuration compatibility
- Template generation for easy customization

### 3.3 Script Structure

```bash
#!/bin/bash
# run-simulation.sh

# Configuration validation
validate_configs() {
    # Check required config files exist
    # Validate IP addresses and ports
    # Ensure consistency between free5gc and UERANSIM configs
}

# Start core network
start_free5gc() {
    # Start MongoDB
    # Start NRF (Network Repository Function) first
    # Start other NFs (AMF, SMF, UPF, etc.)
    # Start WebConsole
}

# Start radio access network simulation  
start_ueransim() {
    # Start gNB (base station simulator)
    # Start UE (user equipment simulator)
}

# Monitoring and logging
monitor_simulation() {
    # Real-time status of all processes
    # Log aggregation
    # Health checks
}
```

## Phase 4: User Interface Options

### 4.1 Basic Usage (Default Config)
```bash
make up
# Builds images and starts all services with docker-compose
```

### 4.2 Individual Operations
```bash
make build-all      # Build both Docker images
make up            # Start all services
make down          # Stop all services
make logs          # View service logs
make clean         # Remove images and cleanup
```

### 4.3 Custom Configuration
```bash
# Edit configurations directly on host
vim config/free5gc/amfcfg.yaml      # Modify AMF settings
vim config/UERANSIM/free5gc-gnb.yaml # Modify gNB settings

# Restart affected services to pick up changes
docker-compose restart free5gc
docker-compose restart ueransim-gnb
```

### 4.4 Development Mode
```bash
# Individual service control
docker-compose up mongodb free5gc    # Start core only
docker-compose up ueransim-gnb       # Add gNB
docker-compose up ueransim-ue        # Add UE
```

## Phase 5: Testing and Validation

### 5.1 Functional Tests
- [ ] All free5gc NFs start successfully
- [ ] MongoDB connects and initializes
- [ ] gNB registers with AMF
- [ ] UE attaches to network
- [ ] Data session establishment
- [ ] Internet connectivity through UPF

### 5.2 Integration Tests  
- [ ] WebConsole accessible on port 8000
- [ ] Registration procedure monitoring
- [ ] Session establishment logs
- [ ] Network interface creation (uesimtun0)

### 5.3 Performance Validation
- [ ] Memory usage within container limits
- [ ] CPU utilization monitoring  
- [ ] Network throughput testing

## Implementation Timeline

### Week 1: Configuration Adaptation
- [ ] Analyze default configs in .deb packages
- [ ] Create container-optimized config templates  
- [ ] Test individual component startup

### Week 2: Simulation Scripts
- [ ] Implement run-simulation.sh
- [ ] Add configuration validation
- [ ] Create monitoring and logging

### Week 3: User Interface
- [ ] Docker run options implementation
- [ ] Custom configuration mounting
- [ ] Documentation and examples

### Week 4: Testing and Polish
- [ ] Comprehensive testing suite
- [ ] Performance optimization
- [ ] User documentation
- [ ] Demo scenarios

## File Structure

```
free5gc-ueransim-demo/
├── Dockerfile.free5gc           # ✅ free5gc container image
├── Dockerfile.ueransim          # ✅ UERANSIM container image
├── docker-compose.yml          # ✅ Multi-container orchestration
├── Makefile                    # ✅ Build automation with docker-compose
├── PLAN.md                     # 📄 This implementation plan
├── free5gc-debian-packages/    # ✅ Submodule with free5gc .deb files
├── USRANSIM-debian-packages/   # ✅ Submodule with UERANSIM .deb files
├── config/                     # ✅ Host-editable configuration files
│   ├── free5gc/               # ✅ free5gc network function configs
│   │   ├── amfcfg.yaml        # ✅ AMF configuration
│   │   ├── smfcfg.yaml        # ✅ SMF configuration
│   │   ├── upfcfg.yaml        # ✅ UPF configuration
│   │   ├── nrfcfg.yaml        # ✅ NRF configuration
│   │   ├── webuicfg.yaml      # ✅ Web console configuration
│   │   ├── multiAMF/          # ✅ Multi-AMF scenario configs
│   │   └── multiUPF/          # ✅ Multi-UPF scenario configs
│   └── UERANSIM/              # ✅ UERANSIM radio simulator configs
│       ├── free5gc-gnb.yaml   # ✅ gNB configuration for free5gc
│       ├── free5gc-ue.yaml    # ✅ UE configuration for free5gc
│       ├── custom-gnb.yaml    # ✅ Customizable gNB template
│       └── custom-ue.yaml     # ✅ Customizable UE template
├── scripts/
│   ├── run-simulation.sh       # 🔄 Main simulation script
│   ├── validate-config.sh      # 🔄 Configuration validation
│   └── monitor.sh             # 🔄 Process monitoring
├── docs/
│   ├── USAGE.md              # 🔄 User guide
│   └── TROUBLESHOOTING.md    # 🔄 Common issues
└── tests/
    ├── integration-test.sh    # 🔄 Integration tests
    └── functional-test.sh     # 🔄 Functional tests
```

## Success Criteria

1. **Single Command Deployment**: Users can run the entire 5G simulation with `make up`
2. **Service Isolation**: Separate containers for database, core network, and radio components
3. **Configuration Flexibility**: Users can edit host-based configs in `config/` directory and changes are reflected in containers
4. **Monitoring Capability**: Real-time visibility into simulation status and logs via `make logs`
5. **Educational Value**: Clear documentation enabling learning about 5G network architecture
6. **Reproducibility**: Consistent results across different host environments

## Notes

- Privileged mode and NET_ADMIN capabilities required for GTP tunnel interface creation
- MongoDB data persists via Docker volumes between container restarts
- Port 8000 provides web-based monitoring and subscriber management
- Docker bridge networking enables realistic multi-node simulation
- Future enhancements could include multiple UE simulation and advanced scenarios
# Simulated Handover using Free5GC + UERANSIM

This repository provides the docker-compose environment for handover over 5G network using Free5GC + UERANSIM.

!! The project is not complete yet. You are free to contribute to our project. !!

## Usage

Clone this project and submodules.


```sh
git clone https://github.com/jerry73204/free5gc-handover-simulation.git
git submodule update --init --recursive
cd free5gc-handover-simulation
```

To start all 5G services,

```sh
make up
```

To stop all 5G services,

```sh
make down
```

To watch live logs,

```sh
make logs
```

## TODOs

- Modify `free5gc-compose/docker-compose-yaml` to run two gNBs. Currently, it has a single gNB container named `ueransim`. We may create two gNB containers named `ueransim{1,2}`.
- Simulate the UE activity that moves from `ueransim1` to `ueransim2`. There are several online discussions ([1](https://forum.free5gc.org/t/does-ueransim-support-different-ue-activities/1324), [2](https://github.com/aligungr/UERANSIM/issues/289), [3](https://free5gc.org/blog/20230705/1-free5gc-with-namespace/)) about this topic. The next step is to study them thoroughly and create a clean simulated environment.

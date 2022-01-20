```
sudo apt install -y git \
   && git clone https://github.com/mkrowiarz/fresh-unix-wsl2-setup.git \
   && cd fresh-unix-wsl2-setup \
   && chmod +x setup.sh \
   && sudo ./setup.sh
```

After that, make sure to shutdown WSL2 instance, so that `snapd` can start working properly.

```
wsl --shutdown
```

After re-logging into the WSL2 shell, you can install `snap` packages, for example:

```
sudo snap install phpstorm --classic
```

Credits:
* https://snapcraft.ninja/2020/07/29/systemd-snap-packages-wsl2/
* https://github.com/DamionGans/ubuntu-wsl2-systemd-script

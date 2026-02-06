== #emoji.rocket Getting Started <getting-started>

The setup script is designed for my dual-environment workflow:
*Windows* (#emoji.face.nausea) and *Arch Linux* via *WSL*. Since *Nushell* is
my shell of choice for both, the entire system is built around it.
With some minor changes, it should works on a bare Linux distro too.

=== Requirements

These are the requirements to run the setup script:

- (Win) #link("https://learn.microsoft.com/en-us/windows/wsl/install")[Windows Subsystem for Linux]
- (Win) #link("https://archlinux.org/download/")[Arch Linux WSL]
- (Win/Lin) #link("https://www.nushell.sh/book/installation.html")[Nushell] as the user's default shell
- (Win/Lin) #link("https://git-scm.com/install/")[Git] (base configuration; it will be further configured by the script)
- (Lin) #link("https://www.sudo.ws/")[sudo]. If you are the only user on the system, something like this should work just fine:
  ```sh
  echo "your_user_name ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/your_user_name > /dev/null
  ```
- (Lin) #link("https://github.com/Duncaen/OpenDoas")[doas] (optional, but it takes precedence over `sudo` if installed). If you are the only user on the system, something like this should work just fine:
  ```sh
  echo "permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} your_user_name" | sudo tee -a /etc/doas.conf > /dev/null
  ```

=== Installing

Clone the repository and fire up the engine:

```sh
git clone https://github.com/Ragnarokkr/dotfiles.git
./setup.nu
```

=== The Setup Workflow

The procedure is divided into *two phases* comprising *seven steps*:

- *Phase 1*: Preinstall and preconfig
  1. *Check*: Verifies that minimum requirements are met.
  2. *Preinstall*: Installs essential system-wide tools (e.g., `paru`, `unzip`).
  3. *Preconfig*: Initial configuration for the preinstalled tools.
  4. *Restart*: A mandatory pause. Shells or OS restarts ensure new binaries
    and environment variables are recognized.
- *Phase 2*: Install and config
  5. *Install*: Installs everything marked for general installation.
  6. *Config*: Applies the personalized configuration files.
  7. *Second Restart*: The final _bake_. Ensures all changes are active and stable.

#block(
  [[!TIP]
    You will be prompted for your user password (for `sudo`/`doas`) and occasionally
    for credentials (e.g., `Bitwarden` or `Age` encryption keys).]
)

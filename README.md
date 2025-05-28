# Nix Darwin Configuration

This repository contains my personal Nix configuration for macOS, using nix-darwin to manage system settings, packages, and services.

### Installing Nix

To install Nix, use the recommended graphical installer:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Installation

1. Clone this repository:

```bash
git clone https://github.com/Pingid/nix-darwin-config.git
cd nix-darwin-config
```

2. Run the setup script:

```bash
./setup.sh
```

3. Apply the configuration:

```bash
nix run nix-darwin -- switch --flake .
```

## Usage

### Common Commands

- **Update all packages and dependencies**

  ```bash
  nix flake update --commit-lock-file
  ```

- **Apply configuration changes**

  ```bash
  darwin-rebuild switch --flake .
  ```

- **Check configuration for errors**
  ```bash
  darwin-rebuild check --flake .
  ```

## Contributing

Feel free to fork, clone or open issues or submit pull requests for any improvements.

## License

MIT License

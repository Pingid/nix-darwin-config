# Created from guide found at https://nixcademy.com/posts/nix-on-macos/
{
  description = "Nix macos setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    # Homebrew installer & taps
    nix-homebrew.url   = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url   = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url   = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-core, homebrew-cask }:

  let
    config = import ./config.nix;
    systemType = config.systemType;
    hostname = config.hostname;
    username = config.username;
    homeDirectory = config.homeDirectory;
    email = config.email;
    name = config.name;

    configuration = { pkgs, ... }: {
      # Disable nix-darwin's Nix management
      nix.enable = false;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        git
        pkg-config
        openssl
        openssl.dev
      ];
      
      # Set environment variables for openssl
      environment.variables.PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      environment.variables.OPENSSL_DIR = "${pkgs.openssl.dev}";
      environment.variables.OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
      environment.variables.OPENSSL_LIB_DIR = "${pkgs.lib.getLib pkgs.openssl}/lib";
      environment.variables.OPENSSL_NO_VENDOR = "1";

      # Define user in nix-darwin
      users.users.${username} = {
        name = username;
        home = homeDirectory;
      };

      # # install brew-managed formulae
      # homebrew.enable = true;
      # homebrew.brews  = [ "pnpm" ];

      # Set primary user for system defaults
      system.primaryUser = username;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "big brother is watching";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = systemType;

      # Enable sudo-touchid for sudo authentication.
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  in
  {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        configuration
        {
          nix-homebrew = {
            enable       = true;
            enableRosetta= true;
            user         = username;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
          home-manager.users.${username} = { pkgs, ... }: {
            home.stateVersion = "24.11";

            home.packages = [
              pkgs.vim
              pkgs.git
              pkgs.wget
              pkgs.fnm
              pkgs.gh
              pkgs.htop
              pkgs.bun
              pkgs.deno
              pkgs.rustup
              pkgs.uv
              pkgs.poetry
              pkgs.awscli2
              pkgs.s5cmd
              pkgs.moreutils
              pkgs.neovim
              pkgs.delta
              pkgs.zoxide
              pkgs.pik
              pkgs.see-cat
              pkgs.ripgrep
              pkgs.broot
              pkgs.ollama
              pkgs.nixd
            ];

            home.file.".config/fish/conf.d/homebrew.fish".text =
              let
                # Homebrew’s bin directory for the current platform
                brewBin =
                  if systemType == "aarch64-darwin"
                  then "/opt/homebrew/bin"
                  else "/usr/local/bin";
              in
                ''
                  # add Homebrew to PATH only once
                  contains ${brewBin} $PATH
                    or set -gx PATH ${brewBin} $PATH
                '';

            home.file.".config/fish/conf.d/pkg-config.fish".text = ''
              set -x PKG_CONFIG_PATH ${pkgs.openssl.dev}/lib/pkgconfig
            '';
            # OPENSSL_DIR       = "${pkgs.openssl.dev}";
            # OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
            # # "getLib" gives you the runtime output's /lib folder:
            # OPENSSL_LIB_DIR   = "${pkgs.lib.getLib pkgs.openssl}/lib";
            # OPENSSL_NO_VENDOR = "1";
            home.file.".config/fish/conf.d/openssl.fish".text = ''
              set -x OPENSSL_DIR ${pkgs.openssl.dev};
              set -x OPENSSL_INCLUDE_DIR ${pkgs.openssl.dev}/include;
              set -x OPENSSL_LIB_DIR ${pkgs.lib.getLib pkgs.openssl}/lib;
              set -x OPENSSL_NO_VENDOR 1;
            '';

            home.file.".config/fish/conf.d/fnm.fish".text = ''
              fnm env --use-on-cd --shell fish | source
            '';
            home.file.".config/fish/conf.d/rustup.fish".text = ''
              set -x PATH $HOME/.cargo/bin $PATH
            '';
            home.file.".config/fish/conf.d/zoxide.fish".text = ''
              zoxide init fish | source
            '';
            home.file.".wezterm.lua".text = ''
              local wezterm = require 'wezterm'
              local config = {}

              config.default_prog = { "/run/current-system/sw/bin/fish" }  -- Replace with your shell path
              config.window_close_confirmation = "NeverPrompt"
              config.window_background_opacity = .8
              config.macos_window_background_blur = 100
              config.native_macos_fullscreen_mode = true
              config.use_fancy_tab_bar = false
              config.show_tabs_in_tab_bar = true
              config.show_new_tab_button_in_tab_bar = false
              config.keys = {
                  {
                      key = "k",
                      mods = "CMD",
                      action = wezterm.action.ClearScrollback "ScrollbackAndViewport",
                  },
              }

              return config
            '';
            home.file.".config/zed/settings.json".text = ''
              {
                "agent": {
                        "model_parameters": [],
                        "default_profile": "ask",
                        "version": "2"
                    },
                    "terminal": {
                        "shell": {
                        "program": "fish"
                        }
                    },
                    "base_keymap": "VSCode",
                    "ui_font_size": 14,
                    "buffer_font_size": 12,
                    "theme": {
                        "mode": "system",
                        "light": "GitHub Dark Default",
                        "dark": "One Dark"
                    }
                }
            '';
            programs.git = {
              enable = true;
              userEmail = "${email}";
              userName = "${name}";
              aliases = {
                # For push
                pf = "push --force-with-lease";
                # Add all changes to last commit and force push
                pa = "!git add . && git commit --amend --no-edit && git push --force-with-lease";
                # Pull with rebase and stash untracked files
                get = "!git stash push --include-untracked && git pull --rebase && git stash pop";
              };
              extraConfig = {
                init.defaultBranch = "main";
                push.autoSetupRemote = "true";
                push.default = "current";
                core.editor = "nvim";
                color.ui = "auto";
                pull.rebase = "true";
                core.fileMode = "false";
                push.forceWithLease = "true";

                # Use delta as the default pager
                core.pager = "delta";
                interactive.diffFilter = "delta --color-only";
                delta.navigate = "true";
                merge.conflictStyle = "zdiff3";
              };
            };
          };
        }
      ];
    };
  };
}

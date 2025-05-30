# Created from guide found at https://nixcademy.com/posts/nix-on-macos/
{
  description = "Nix macos setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:

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
      environment.systemPackages = [
        pkgs.git
      ];

      # Define user in nix-darwin
      users.users.${username} = {
        name = username;
        home = homeDirectory;
      };
      
      # Set primary user for system defaults
      system.primaryUser = username;
      
      # # Enable homebrew
      # homebrew.enable = true;
      # homebrew.casks = [{ name = "google-chrome"; }];

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
        configuration
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
            ];

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

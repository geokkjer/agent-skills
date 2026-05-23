{
  description = "Reproducible Elisp development environment - Emacs 30, native-comp, linters, deterministic";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };

        emacs = pkgs.emacs30.override {
          withNativeCompilation = true;
          withXinput2 = true;
        };

        elispPkgs = with pkgs.emacsPackages; [
          package-lint
          relint
          elisp-lint
          buttercup
          sly
          rainbow-mode
          helpful
          company
          ivy
        ];

        devTools = with pkgs; [
          git
          gnused
          gnutar
          gzip
          findutils
          coreutils
          ripgrep
          fd
          shellcheck
        ];

        emacsBin = "${emacs}/bin/emacs";

      in
      {
        devShells.default = pkgs.mkShell {
          name = "elisp-functional";

          packages = [ emacs elispPkgs devTools ];

          EMACS = emacsBin;
          EMACSDIR = "${emacs}/share/emacs";
          EMACSLOADPATH = "";

          shellHook = ''
            native_comp=$(
              ${emacsBin} -Q --batch \
                --eval '(kill-emacs (if (native-comp-available-p) 0 1))' \
                2>/dev/null && echo yes || echo no
            )

            sep() { printf "=========================================================\n"; }

            sep
            printf "  Elisp Development Environment\n"
            sep
            printf "  Emacs:  %s\n" "$(${emacsBin} --version | head -1)"
            printf "  Native: %s\n" "''${native_comp}"
            printf "  System: %s\n" "${system}"
            printf "\n"
            printf "  Run tests:   ert-runner (buttercup) or M-x ert\n"
            printf "  Lint:        emacs -batch -f package-lint-current-buffer\n"
            printf "  Regex check: emacs -batch -f relint-current-buffer\n"
            printf "\n"
            printf "  The Elisp functional programming skill is loaded.\n"
            printf "  Prefer seq-map, thread-last, and pcase over dolist and setq.\n"
            sep
          '';
        };

        packages.emacs-elisp-dev = pkgs.buildEnv {
          name = "emacs-elisp-dev";
          paths = [ emacs elispPkgs devTools ];
          meta.description = "Bundled Emacs 30 with Elisp development tools";
        };

        packages.emacs = emacs;
      }
    );
}

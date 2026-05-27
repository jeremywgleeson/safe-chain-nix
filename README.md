# safe-chain-nix

Nix package and Home Manager integration for [Aikido Safe Chain](https://github.com/AikidoSec/safe-chain).

This builds from the published npm source tarball for `@aikidosec/safe-chain`; it does not download the upstream platform release binaries.

## Use

Add the flake:

```nix
inputs.safe-chain-nix.url = "github:jeremywgleeson/safe-chain-nix";
```

Install only the CLI:

```nix
{
  imports = [ inputs.safe-chain-nix.homeModules.default ];

  programs.safe-chain.enable = true;
}
```

Opt into transparent package-manager wrappers:

```nix
{
  imports = [ inputs.safe-chain-nix.homeModules.default ];

  programs.safe-chain = {
    enable = true;
    integrationMode = "wrappers";
  };
}
```

Wrapper mode creates Home Manager managed shims for npm, npx, yarn, pnpm, pnpx, rush, rushx, bun, bunx, uv, uvx, pip, pip3, poetry, and pipx. Python itself is not wrapped by default because that affects every Python invocation; enable it explicitly when you want `python -m pip` interception:

```nix
programs.safe-chain.wrapPython = true;
```

The package is also available through the overlay:

```nix
nixpkgs.overlays = [ inputs.safe-chain-nix.overlays.default ];
environment.systemPackages = [ pkgs.safe-chain ];
```

## Updating

Updates are intended to require no manual maintenance:

- `.github/workflows/update-safe-chain.yml` checks the latest npm version daily.
- `scripts/update-safe-chain` updates the version, source hash, and npm dependency hash.
- The workflow opens a pull request after `nix flake check` passes.
- Dependabot keeps the GitHub Actions versions fresh.

Run the same update locally with:

```sh
nix develop --command scripts/update-safe-chain
```

## License

The Nix integration in this repository is MIT licensed. Safe Chain itself is developed by Aikido Security and is AGPL-3.0-or-later with commercial licensing available from upstream.

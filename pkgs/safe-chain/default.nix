{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_24,
}:

buildNpmPackage (finalAttrs: {
  pname = "safe-chain";
  version = "1.5.27";

  nodejs = nodejs_24;

  src = fetchurl {
    url = "https://registry.npmjs.org/@aikidosec/safe-chain/-/safe-chain-${finalAttrs.version}.tgz";
    hash = "sha256-FB2YmxjfVTtrdxddS8tRxR+PsEMZK1+apBlKPreaPH4=";
  };

  npmDepsHash = "sha256-+GADkzxEli1lrNsY8u0tNj+Q0p4amQxDGFwOOvH4OyU=";
  npmDepsFetcherVersion = 2;
  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  # The published tarball includes devDependency ranges that do not match its
  # shrinkwrap. Runtime dependencies are locked and sufficient for the CLI.
  postPatch = ''
    sed -i.bak '/  "devDependencies": {/,/  },/d' package.json
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/safe-chain --version | grep -F "${finalAttrs.version}"
    $out/bin/safe-chain help > /dev/null

    runHook postInstallCheck
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Package manager wrapper that checks npm and Python installs for malware";
    homepage = "https://github.com/AikidoSec/safe-chain";
    changelog = "https://github.com/AikidoSec/safe-chain/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    mainProgram = "safe-chain";
    platforms = nodejs_24.meta.platforms;
  };
})

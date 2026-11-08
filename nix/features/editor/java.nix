{ pkgs, ... }:
let
  lombok = pkgs.fetchurl {
    url = "https://projectlombok.org/downloads/lombok-1.18.44.jar";
    sha256 = "11mz6l8c1vvaswxx10az7q201dprmaamw67f4pxixfsqqgyipsf6";
  };

  springBootTools = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "vscode-spring-boot";
    version = "2.4.1";

    src = pkgs.fetchurl {
      url = "https://open-vsx.org/api/VMware/vscode-spring-boot/${version}/file/VMware.vscode-spring-boot-${version}.vsix";
      sha256 = "6971f2bbc513a944e7f907e48ec68f64848d689630d5616bf54ef0803349f6ed";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      unzip -q "$src" 'extension/jars/*.jar' -d .
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -r extension/jars "$out/jars"
    '';
  };

  springBundles = map (jar: "${springBootTools}/jars/${jar}") [
    "io.projectreactor.reactor-core.jar"
    "org.reactivestreams.reactive-streams.jar"
    "jdt-ls-commons.jar"
    "jdt-ls-extension.jar"
    "sts-gradle-tooling.jar"
  ];
in
{
  home.packages = [
    pkgs.jdk25_headless
    (pkgs.jdt-language-server.override { jdk25 = pkgs.jdk25_headless; })
  ];

  programs.helix.languages.language-server.jdtls = {
    command = "jdtls";
    args = [ "--jvm-arg=-javaagent:${lombok}" ];
    config.bundles = springBundles;
  };
}

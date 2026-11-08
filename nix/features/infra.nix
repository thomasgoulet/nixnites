{
  den,
  inputs,
  ...
}:
{
  den.aspects.infra = {
    includes = [
      (den.batteries.unfree [ "azure-cli" ])
    ];

    homeManager =
      { inputs', pkgs, ... }:
      let
        pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
      in
      {
        imports = [
          (inputs.import-tree ./infra)
        ];

        home.packages = [
          pkgs.argocd
          pkgs.dyff
          pkgs.hl-log-viewer
          pkgs.kubecolor
          pkgs.kubectl
          pkgs.kubelogin
          pkgs.kustomize
          pkgs.tenv

          (pkgs-stable.azure-cli.withExtensions [
            pkgs-stable.azure-cli.extensions.ssh
            pkgs-stable.azure-cli.extensions.azure-devops
          ])
        ];

        home.sessionVariables = {
          KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code";
        };
      };
  };
}

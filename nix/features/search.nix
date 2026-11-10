{ den, ... }:
{
  den.aspects.search = {
    nixos = { ... }: {
      services.searx = {
        enable = true;
        settings = {
          server = {
            port = 8888;
            bind_address = "127.0.0.1";
            secret_key = "not-so-secret-is-it";
          };
          engines = [
            {
              name = "brave";
              disabled = true;
            }
            {
              name = "nixos wiki";
              disabled = false;
            }
            {
              name = "wikidata";
              disabled = true;
            }
          ];
        };
      };
    };
  };
}

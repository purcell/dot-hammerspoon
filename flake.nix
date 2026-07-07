{
  description = "Hammerspoon config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];
    in
    {
      devShells = forAllSystems
        (system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          {
            default = pkgs.mkShell
              {
                buildInputs = with pkgs; [ lua luaformatter luaPackages.luacheck lua-language-server ];
                shellHook = ''
                  LUA_PATH=$LUA_PATH:/Applications/Hammerspoon.app/Contents/Resources/extensions
                  LUA_CPATH=$LUA_CPATH:/Applications/Hammerspoon.app/Contents/Resources/extensions
                  export LUA_PATH
                  export LUA_CPATH
                '';
              };
          });
    };
}

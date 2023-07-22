{
  description = "Hammerspoon config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }@inputs: {
    devShells."aarch64-darwin".default =
      let
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
      in
        pkgs.mkShell {
            buildInputs = with pkgs; [ lua luaPackages.luacheck lua-language-server ];
            shellHook = ''
              LUA_PATH=$LUA_PATH:/Applications/Hammerspoon.app/Contents/Resources/extensions
              LUA_CPATH=$LUA_CPATH:/Applications/Hammerspoon.app/Contents/Resources/extensions
              export LUA_PATH
              export LUA_CPATH
            '';

        };
  };
}

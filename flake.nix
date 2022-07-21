{ inputs =
    { make-shell.url = "github:ursi/nix-make-shell/1";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      npmlock2nix =
        { flake = false;
          url = "github:nix-community/npmlock2nix";
        };

      ps-tools.follows = "purs-nix/ps-tools";
      purs-nix.url = "github:purs-nix/purs-nix/ps-0.14";
      utils.url = "github:ursi/flake-utils/8";
    };

  outputs = { utils, ... }@inputs:
    with builtins;
    utils.apply-systems { inherit inputs; }
      ({ make-shell, pkgs, ps-tools, purs-nix, ... }:
         let
           l = p.lib; p = pkgs;
           npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };
           our-node = p.nodejs-14_x;
           ps = import ./purs.nix { inherit npmlock2nix our-node p; } purs-nix;
         in
         rec
         { packages =
             rec
             { default =
                 p.stdenv.mkDerivation
                   rec
                   { pname = "purescript-docs-search";
                     inherit (l.importJSON ./package.json) version;
                     src =
                       ps.modules."Docs.Search.Main".app
                         { name = pname; incremental = false; };

                     phases = [ "unpackPhase" "installPhase" ];

                     installPhase =
                       ''
                       mkdir lib

                       mv bin/${pname} lib
                       ln -rs lib/${pname} bin

                       ln -s ${
                         ps.modules."Docs.Search.App".bundle
                           { esbuild =
                               { minify = true;
                                 target = "es2016";
                               };

                             incremental = false;
                           }
                         } lib/docs-search-app.js

                       cp -r ./. $out
                       '';
                   };
             };

           bowers =
             toString
               (foldl'
                  (acc: dep:
                     if dep.purs-nix-info?bower-json
                     then [ ''--bower-jsons ${dep.purs-nix-info.bower-json}'' ] ++ acc
                     else acc
                  )
                  []
                  ps.dependencies
               );

           devShell =
             make-shell
               { packages =
                   with p;
                   [ esbuild
                     our-node
                     ps-tools.for-0_14.purescript
                     ps-tools.for-0_14.zephyr
                     ps-tools.for-0_14.purescript-language-server
                     spago

                     (ps.command
                        { bundle =
                            { esbuild.platform = "node";
                              esbuild.minify = true;
                              module = "Docs.Search.Main";
                            };

                          compile.codegen = "corefn,docs,js";
                        }
                     )

                     (ps.command
                        { name = "pn-app";

                          bundle =
                            { esbuild.outfile =
                                "output/Docs.Search.IndexBuilder/docs-search-app.js";

                              module = "Docs.Search.App";
                            };

                          compile.codegen = "corefn,docs,js";
                        }
                     )
                   ];

                 env.BOWERS = bowers;
                 aliases.build-index = "purs-nix run build-index $(echo $BOWERS)";
               };
         }
      );
}

{ inputs =
    { make-shell.url = "github:ursi/nix-make-shell/1";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      npmlock2nix =
        { flake = false;
          url = "github:nix-community/npmlock2nix";
        };

      ps-tools.follows = "purs-nix/ps-tools";
      purs-nix.url = "github:purs-nix/purs-nix/ps-0.15";
      utils.url = "github:ursi/flake-utils/8";
    };

  outputs = { utils, ... }@inputs:
    with builtins;
    utils.apply-systems
      { inherit inputs;
        systems = [ "x86_64-linux" "x86_64-darwin" ];
      }
      ({ make-shell, pkgs, ps-tools, system, ... }:
         let
           purs-nix =
             inputs.purs-nix
               { inherit system;
                 overlays = [ (import ./overlay.nix) ];
               };

           l = p.lib; p = pkgs;
           npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };
           our-node = p.nodejs-14_x;
           ps = import ./purs.nix { inherit npmlock2nix our-node p; } purs-nix;
           pname = "purescript-docs-search";
         in
         rec
         { packages =
             rec
             { default =
                 p.stdenv.mkDerivation
                   { inherit pname;
                     inherit (l.importJSON ./package.json) version;

                     src =
                       ps.app
                         { module = "Docs.Search.Main";
                           name = pname;
                         };

                     phases = [ "unpackPhase" "installPhase" ];

                     installPhase =
                       ''
                       mkdir lib

                       mv bin/${pname} lib
                       ln -rs lib/${pname} bin

                       ln -s ${
                         ps.bundle
                           { module = "Docs.Search.App";

                             esbuild =
                               { minify = true;
                                 target = "es2016";
                               };
                           }
                         } lib/docs-search-app.js

                       cp -r ./. $out
                       '';
                   };
             };

           devShell =
             let
               utils = import "${inputs.purs-nix}/utils.nix" p;

               bowers =
                 toString
                   (map
                      (dep:
                         let
                           bower-json =
                             let info = dep.purs-nix-info; in
                             toFile "${info.name}-bower.json"
                               (toJSON
                                  ({ inherit (info) name;

                                     dependencies =
                                       foldl'
                                         (acc: dep:
                                            acc // { ${utils.dep-name dep} = ""; }
                                         )
                                         {}
                                         info.dependencies;
                                   }
                                   // l.optionalAttrs (info?repo)
                                        { repository =
                                            { type = "git";
                                              url = info.repo;
                                            };
                                        }
                                  )
                               );
                         in
                         "--bower-jsons ${bower-json}"
                      )
                      ps.dependencies
                   );
             in
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

                 functions.build-index =
                   ''
                   # to compile the code and docs.json's in one go
                   purs-nix compile

                   purs-nix docs
                   pn-app bundle
                   nix build
                   result/bin/${pname} build-index $(echo $BOWERS)
                   '';
               };
         }
      );
}

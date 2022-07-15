with builtins;
{ npmlock2nix, our-node, p }:
{ build, ps-pkgs, purs, ... }:
  let l = p.lib; in
  purs
    { dependencies =
        with ps-pkgs;
        let
          html-parser-halogen =
            build
              { name = "html-parser-halogen";

                src.git =
                  { repo = "https://github.com/rnons/purescript-html-parser-halogen.git";
                    rev = "458e492e441fcf69a66911b7b64beea5849e0dad";
                  };

                info.dependencies = [ string-parsers halogen ];
              };

          string-parsers =
            build
              { name = "string-parsers";

                src.git =
                  { repo = "https://github.com/purescript-contrib/purescript-string-parsers.git";
                    rev = "6e0752ede167479c8d2b38e9a5a1524ecf3046a8";
                  };

                info =
                  { version = "5.0.1";

                    dependencies =
                      [ arrays
                        bifunctors
                        control
                        either
                        foldable-traversable
                        lists
                        maybe
                        prelude
                        strings
                        tailrec
                      ];
                  };
              };
        in
        [ aff
          aff-promise
          argonaut-codecs
          argonaut-core
          argonaut-generic
          arrays
          bower-json
          console
          control
          css
          effect
          either
          exceptions
          foldable-traversable
          foreign
          foreign-object
          halogen
          halogen-css
          halogen-subscriptions
          identity
          js-uri
          lists
          markdown-it

          (build
             { name = "markdown-it-halogen";

               src.git =
                 { repo = "https://github.com/nonbili/purescript-markdown-it-halogen.git";
                   rev = "08c9625015bf04214be14e45230e8ce12f3fa2bf";
                 };

               info.dependencies = [ markdown-it html-parser-halogen ];
             }
          )

          maybe
          newtype
          node-buffer
          node-fs
          node-fs-aff
          node-process
          node-readline
          optparse
          ordered-collections
          partial
          prelude
          profunctor
          profunctor-lenses

          (build
             { name = "search-trie";

               src.git =
                 { repo = "https://github.com/klntsky/purescript-search-trie.git";
                   rev = "e7f7f22486a1dba22171ec885dbc2149dc815119";
                 };

               info.dependencies =
                 [ prelude
                   arrays
                   ordered-collections
                   lists
                   foldable-traversable
                   bifunctors
                 ];
             }
          )

          string-parsers
          strings
          test-unit
          toppokki
          transformers
          tuples
          unfoldable
          web-dom
          web-events
          web-html
          web-storage
          web-uievents
        ];

      srcs = [ ./src ];

      foreign."Docs.Search.IndexBuilder".node_modules =
        npmlock2nix.node_modules
          { src =
              let
                new-pj =
                  l.pipe (l.importJSON ./package.json)
                    [ (pj:
                         pj
                         // { devDependencies =
                                { inherit (pj.devDependencies) glob; };
                            }
                      )

                      toJSON
                      (toFile "package.json")
                    ];
              in
              p.runCommand "patched-package.json" {}
                ''
                mkdir $out; cd $out

                # ln breaks when using --impure
                cp ${new-pj} package.json
                cp ${./package-lock.json} package-lock.json
                '';
          }
        + /node_modules;

      nodejs = our-node;
    }

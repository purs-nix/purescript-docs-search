with builtins;
{ npmlock2nix, our-node, p }:
{ build-set, ps-pkgs, purs, ... }:
  let l = p.lib; in
  purs
    { dependencies =
        let
          extra =
            build-set
              (self:
                 with removeAttrs ps-pkgs (attrNames self);
                 { html-parser-halogen =
                     { src.git =
                         { repo = "https://github.com/rnons/purescript-html-parser-halogen.git";
                           rev = "458e492e441fcf69a66911b7b64beea5849e0dad";
                           ref = "master";
                         };

                       info.dependencies = [ self.string-parsers halogen ];
                     };

                   markdown-it-halogen =
                     { src.git =
                         { repo = "https://github.com/nonbili/purescript-markdown-it-halogen.git";
                           rev = "08c9625015bf04214be14e45230e8ce12f3fa2bf";
                         };

                       info.dependencies = [ markdown-it self.html-parser-halogen ];
                     };

                   search-trie =
                     { src.git =
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
                     };

                   string-parsers =
                     { src.git =
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
                 }
              );
        in
        with ps-pkgs;
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
          extra.markdown-it-halogen
          extra.search-trie
          extra.string-parsers
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

      dir = ./.;

      foreign."Docs.Search.IndexBuilder".node_modules =
        npmlock2nix.node_modules { src = ./.; } + /node_modules;

      nodejs = our-node;
    }

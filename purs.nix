with builtins;
{ npmlock2nix, our-node, p }:
{ build, ps-pkgs, purs, ... }:
  let l = p.lib; in
  purs
    { dependencies =
        [ ps-pkgs.markdown-it-halogen
          ps-pkgs.search-trie
          ps-pkgs.string-parsers
          "aff"
          "aff-promise"
          "argonaut-codecs"
          "argonaut-core"
          "argonaut-generic"
          "arrays"
          "bower-json"
          "console"
          "control"
          "css"
          "effect"
          "either"
          "exceptions"
          "foldable-traversable"
          "foreign"
          "foreign-object"
          "halogen"
          "halogen-css"
          "halogen-subscriptions"
          "identity"
          "js-uri"
          "lists"
          "markdown-it"
          "maybe"
          "newtype"
          "node-buffer"
          "node-fs"
          "node-fs-aff"
          "node-process"
          "node-readline"
          "optparse"
          "ordered-collections"
          "partial"
          "prelude"
          "profunctor"
          "profunctor-lenses"
          "strings"
          "test-unit"
          "toppokki"
          "transformers"
          "tuples"
          "unfoldable"
          "web-dom"
          "web-events"
          "web-html"
          "web-storage"
          "web-uievents"
        ];

      dir = ./.;

      foreign."Docs.Search.IndexBuilder".node_modules =
        npmlock2nix.node_modules { src = ./.; } + /node_modules;

      nodejs = our-node;

      # setting this to something that doesn't exist so `purs-nix docs`
      # doesn't try to compile anything in `test`
      # `purs-nix docs` is required for manual testing purposes
      test = "ignore";
    }

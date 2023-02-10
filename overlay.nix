(self: _:
   { html-parser-halogen =
       { src.git =
           { repo = "https://github.com/rnons/purescript-html-parser-halogen.git";
             rev = "035a51d02ba9f8b70c3ffd9fe31a3f5bed19941c";
             ref = "master";
           };

         info.dependencies = [ "halogen" self.string-parsers ];
       };

     markdown-it-halogen =
       { src.git =
           { repo = "https://github.com/nonbili/purescript-markdown-it-halogen.git";
             rev = "08c9625015bf04214be14e45230e8ce12f3fa2bf";
           };

         info.dependencies = [ "markdown-it" self.html-parser-halogen ];
       };

     search-trie =
       { src.git =
           { repo = "https://github.com/klntsky/purescript-search-trie.git";
             rev = "e7f7f22486a1dba22171ec885dbc2149dc815119";
           };

         info.dependencies =
           [ "prelude"
             "arrays"
             "ordered-collections"
             "lists"
             "foldable-traversable"
             "bifunctors"
           ];
       };

     string-parsers =
       { src.git =
           { repo = "https://github.com/purescript-contrib/purescript-string-parsers.git";
             rev = "518038cec5e76a1509bab87685e0dae77462d9e1";
           };

         info =
           { version = "8.0.0";

             dependencies =
               [ "arrays"
                 "assert"
                 "bifunctors"
                 "console"
                 "control"
                 "effect"
                 "either"
                 "enums"
                 "foldable-traversable"
                 "lists"
                 "maybe"
                 "minibench"
                 "nonempty"
                 "partial"
                 "prelude"
                 "strings"
                 "tailrec"
                 "transformers"
                 "unfoldable"
               ];
           };
       };
   }
)


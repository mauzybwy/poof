;;; .dir-locals.el -*- lexical-binding: t; -*-

((elixir-ts-mode
  . ((lsp-elixir-project-dir . "apps/phx")
     (eglot-workspace-configuration
      . ((:elixirLS . (:projectDir "apps/phx"))))))
 )

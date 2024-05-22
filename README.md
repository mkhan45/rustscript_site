A server for my personal resume/portfolio, written completely in [RustScript](https://mkhan45.github.io/RustScript2)

<https://mikail-khan.com/>

___

This server relies on two RustScript helper libraries:
- <https://github.com/mkhan45/rustscript_toml/> - to parse the TOML files in the assets folder (i.e. the `parse_toml()` function)
- <https://github.com/mkhan45/rustscript_web> - for routing/HTML templating (i.e. `template_file_string()` and `serve_endpoints()`)

While `rustscript_web` handles all of the routing and a lot of HTTP setup, the actual HTTP(S) implementation is done through RustScript's `start_server()` and `start_server_ssl()` builtins, which leverage the [`ocaml-cohttp`](https://github.com/mirage/ocaml-cohttp) library.

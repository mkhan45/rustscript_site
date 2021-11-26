# Needs to be built in a folder with the following structure:
# .
# ├── Dockerfile
# ├── rustscript_site
# ├── rustscript_toml
# └── rustscript_web

FROM mkhan45/rustscript

COPY rustscript_toml rustscript_toml
COPY rustscript_web rustscript_web
COPY rustscript_site rustscript_site

WORKDIR rustscript_site
CMD bash -c "rustscript ../rustscript_web/web.rsc ../rustscript_toml/toml.rsc site.rsc"

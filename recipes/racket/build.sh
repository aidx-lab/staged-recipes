# Start with a minimal build without any packages.
# Avoid building any packages since they could potentially
# require a more recent version of the base language than
# is in the current source directory.
# Packages can be added once the package manager is configured
# to work for this particular version number.
cat > "$SRC_DIR/cpp-wrapper.sh" << 'EOF'
#!/bin/bash
x86_64-conda-linux-gnu-cpp "$@" | grep -v '^#pragma GCC diagnostic'
EOF
chmod +x "$SRC_DIR/cpp-wrapper.sh"

make unix-style CPUS="$CPU_COUNT" PREFIX="$PREFIX" PKGS="" \
  CPP="$SRC_DIR/cpp-wrapper.sh" \
  CFLAGS="${CFLAGS} -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-implicit-int -Wno-return-local-addr -std=gnu17"

# Set up the package manager.
# Following the steps show at
# https://github.com/jackfirth/racket-docker/blob/master/racket.Dockerfile
export PATH="$PATH:$PREFIX/bin"
raco setup
raco pkg config --set default-scope installation
raco pkg config --set catalogs                                         \
    "https://download.racket-lang.org/releases/$PKG_VERSION/catalog/"  \
    "https://pkg-build.racket-lang.org/server/built/catalog/"          \
    "https://pkgs.racket-lang.org"                                     \
    "https://planet-compats.racket-lang.org"
set positional-arguments
set shell := ["bash", "-cue"]
root_dir := `git rev-parse --show-toplevel`
flake_dir := root_dir / "tools/nix"
output_dir := root_dir / ".output"
build_dir := output_dir / "build"

# Default target if you do not specify a target.
default:
    just --list

# Enter the default Nix development shell and execute the command `"$@`.
develop *args:
    just nix-develop "default" "$@"

# Format the project.
format *args:
    "{{root_dir}}/tools/scripts/setup-config-files.sh"
    nix run --accept-flake-config {{flake_dir}}#treefmt -- "$@"

# Setup the project.
setup *args:
    cd "{{root_dir}}" && ./tools/scripts/setup.sh


# Enter the Nix `devShell` with name `$1` and execute the command `${@:2}` (default command is '$SHELL')
[private]
nix-develop *args:
    #!/usr/bin/env bash
    set -eu
    cd "{{root_dir}}"
    shell="$1"; shift 1;
    args=("$@") && [ "${#args[@]}" != 0 ] || args="$SHELL"
    nix develop --no-pure-eval --accept-flake-config \
        "{{flake_dir}}#$shell" --command "${args[@]}"

# Lint the project.
lint *args:
    ./tools/scripts/lint-rust.sh "$@"
    ./tools/scripts/lint-ub-rust.sh "$@"

# Build the project.
build *args:
    cargo build --target-dir "{{build_dir}}" "$@"

# Test the project.
test *args:
    cargo test "$@"

# Watch `cargo build|run|test ...` commands.
watch *args:
    cargo watch -x "$1" "${@:2}"

# Run an executable.
run *args:
    cargo run --target-dir "{{build_dir}}" "$@"

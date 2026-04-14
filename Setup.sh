#!/usr/bin/env bash
set -e

MODE=${1:-run}

ROOT_DIR=$(pwd)
KERNEL_DIR="$ROOT_DIR/kernel"
ISO_DIR="$ROOT_DIR/iso"
BUILD_DIR="$ROOT_DIR"

function clean() {
  echo "[CLEAN] Removing build artifacts..."
  rm -rf "$ISO_DIR"
  rm -f "$ROOT_DIR/axiom.iso"
  rm -f "$ROOT_DIR/boot.o"
  rm -f "$KERNEL_DIR/boot.o"

  cd "$KERNEL_DIR"
  cargo clean
  cd "$ROOT_DIR"
}

function build() {
  echo "[BUILD] Assembling boot.asm..."
  nasm -f elf64 boot.asm -o boot.o

  echo "[BUILD] Preparing kernel..."
  cp boot.o "$KERNEL_DIR/boot.o"

  echo "[BUILD] Building kernel..."
  cd "$KERNEL_DIR"

  env RUSTC_WRAPPER= cargo rustc \
    --target ../x86_64.json \
    -Z build-std=core \
    -Z build-std-features=compiler-builtins-mem \
    -Z json-target-spec \
    --release \
    -- \
    -C link-arg=boot.o \
    -C link-arg=-T../linker.ld

  cd "$ROOT_DIR"

  echo "[BUILD] Creating ISO structure..."
  rm -rf "$ISO_DIR"
  mkdir -p "$ISO_DIR/boot/grub"

  cp "$KERNEL_DIR/target/x86_64/release/kernel" "$ISO_DIR/boot/kernel"
  cp "$ROOT_DIR/boot/grub.cfg" "$ISO_DIR/boot/grub/"

  echo "[BUILD] Building ISO..."
  grub-mkrescue -o axiom.iso iso
}

function run() {
  echo "[RUN] Starting QEMU..."
  qemu-system-x86_64 -cdrom axiom.iso
}

# -------------------------
# Modes
# -------------------------

case "$MODE" in
clean)
  clean
  ;;
build)
  build
  ;;
run)
  build
  run
  ;;
rebuild)
  clean
  build
  run
  ;;
run-only)
  run
  ;;
*)
  echo "Usage:"
  echo "  ./setup.sh clean     # clean everything"
  echo "  ./setup.sh build     # build only"
  echo "  ./setup.sh run       # build + run (default)"
  echo "  ./setup.sh rebuild   # clean + build + run"
  echo "  ./setup.sh run-only  # run existing ISO"
  exit 1
  ;;
esac

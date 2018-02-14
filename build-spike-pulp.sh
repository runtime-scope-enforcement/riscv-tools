#! /bin/bash
#
# Script to build RISC-V ISA simulator using Pulpino memory map & proxy kernel.
# Tools will be installed to $RISCV.

. build.common

if [ ! -f "$RISCV/bin/riscv32-unknown-elf-gcc" ]
then
  echo "riscv32-unknown-elf-gcc doesn't appear to be installed; use the full-on build-rv32ima.sh"
  exit 1
fi

echo "Starting RISC-V Toolchain build process"

build_project riscv-fesvr --prefix=$RISCV

PROJECT=riscv-isa-sim
echo

if [ -e "$PROJECT/build" ]
then
  echo "Removing existing $PROJECT/build directory"
  rm -rf "$PROJECT/build"
fi

mkdir -p "$PROJECT/build"
cd "$PROJECT/build"

echo "Configuring project $PROJECT"
../configure PROGRAM_SUFFIX=-pulp \
  --prefix="$RISCV" --libdir="$RISCV/lib/spike-pulp" \
  --with-fesvr=$RISCV --with-isa=rv32ima --enable-pulpino > build.log

echo "Building project $PROJECT"
$MAKE >> build.log \

echo "Installing project $PROJECT"
$MAKE install >> build.log

cd - > /dev/null

CC= CXX= build_project riscv-pk --prefix=$RISCV --host=riscv32-unknown-elf

echo -e "\\nRISC-V Toolchain installation completed!"

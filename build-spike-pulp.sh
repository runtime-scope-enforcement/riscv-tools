#! /bin/bash
#
# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain.
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
../configure --prefix=$RISCV --with-fesvr=$RISCV --with-isa=rv32ima --enable-pulpino > build.log

echo "Building project $PROJECT"
$MAKE >> build.log \

echo "Installing project $PROJECT"
$MAKE install INSTALL_EXE="/usr/bin/install -c -m 755 --backup --suffix=-riscv" >> build.log

for file in spike spike-dasm termios-xspike xspike; do
  mv "$RISCV/bin/${file}" "$RISCV/bin/${file}-pulp" || exit $?
  if [ -f "$RISCV/bin/${file}-riscv" ]; then
    mv "$RISCV/bin/${file}-riscv" "$RISCV/bin/${file}" || exit $?
  fi
done

cd - > /dev/null

CC= CXX= build_project riscv-pk --prefix=$RISCV --host=riscv32-unknown-elf

echo -e "\\nRISC-V Toolchain installation completed!"

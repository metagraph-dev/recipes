#!/bin/bash
echo GIT HASH $git_hash
mkdir build
cd build
cmake -G Ninja $SRC_DIR/llvm \
   -DCMAKE_INSTALL_PREFIX=$PREFIX \
   -DLLVM_ENABLE_PROJECTS=mlir \
   -DLLVM_BUILD_EXAMPLES=ON \
   -DLLVM_INSTALL_UTILS=ON \
   -DLLVM_TARGETS_TO_BUILD="X86;NVPTX;AMDGPU" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON \
   -DLLVM_BUILD_LLVM_DYLIB=ON \
   -DPython3_EXECUTABLE=`which python`
#  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON

# temporary hack for macos
cp $PREFIX/lib/libtinfo* lib/

# verify MLIR works
cmake --build . --target check-mlir || true
# build everything else
cmake --build .
cmake --install .

rm -rf $PREFIX/examples
cp -a bin/llvm-lit $PREFIX/bin/
cp -a bin/FileCheck $PREFIX/bin/

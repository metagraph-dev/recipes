
# Environment Variables
export CC=clang
export CXX=clang++

# Update Submodules
git submodule update --init

# Configure Bazel
sed -i 's/check=True/check=False/' configure_bazel.py # TODO this is a hack
python3 configure_bazel.py

# Compile
bazel clean --expunge
env CONDA_BUILD_SYSROOT='' bazel build iree/... # TODO set CONDA_BUILD_SYSROOT in the right place
env CONDA_BUILD_SYSROOT='' cmake -G Ninja -B ../iree-build/ -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DIREE_BUILD_PYTHON_BINDINGS=ON -DIREE_BUILD_TENSORFLOW_COMPILER=ON .
env CONDA_BUILD_SYSROOT='' cmake --build ../iree-build/

# TODO These are supposed to do something, but it's unclear that they do.
$PYTHON ../iree-build/bindings/python/pyiree/rt/setup.py install
$PYTHON ../iree-build/bindings/python/pyiree/tools/tf/setup.py install
$PYTHON ../iree-build/bindings/python/pyiree/compiler2/setup.py install

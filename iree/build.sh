
# Environment Variables
export CC=clang
export CXX=clang++
export LD_LIBRARY_PATH=$BUILD_PREFIX/lib

# Update Submodules
git submodule update --init

# Configure Bazel
python3 configure_bazel.py

# Compile
IREE_BUILD_DIR=$(realpath ../iree-build)
bazel clean --expunge
bazel build iree/...
cmake -G Ninja -B $IREE_BUILD_DIR -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DIREE_BUILD_PYTHON_BINDINGS=ON -DIREE_BUILD_TENSORFLOW_COMPILER=ON . 
cmake --build $IREE_BUILD_DIR

# Replace symlinks with hard copies
harden_symlinks () {
    CURRENT_SEARCH_DIR=$1
    OVERALL_SEARCH_DIR=$2
    for LINK in $(find $CURRENT_SEARCH_DIR -type l)
    do
	TARGET=$(readlink $LINK)
	
	if ! [[ "${TARGET:0:1}" == / || "${TARGET:0:2}" == ~[/a-z] ]] # if TARGET is not an absolute path
	then
	    TARGET=$(realpath $LINK)
	fi
	
	TARGET_DIR=$(dirname $TARGET)
	
	if ! [[ "$TARGET_DIR" =~ ^$OVERALL_SEARCH_DIR.* ]] # if TARGET_DIR does not start with OVERALL_SEARCH_DIR, i.e. if TARGET_DIR points outside of OVERALL_SEARCH_DIR
	then
            rm $LINK
	    cp -r $TARGET $LINK
	    if [[ -d $LINK ]] # newly copied subdirectories can also contain symlinks
	    then
		harden_symlinks $LINK $OVERALL_SEARCH_DIR
	    fi
	fi
	
    done
}
PYIREE_DIR=$IREE_BUILD_DIR/bindings/python/pyiree
harden_symlinks $PYIREE_DIR $PYIREE_DIR

# Copy necessary files to site-packages
cp -r $PYIREE_DIR $SP_DIR


IP_ADDRESS=apple-tv.local

echo "Always clean up first!"
echo ""

make clean

echo "Making..."
echo ""

make

echo "Make Stage..."
echo ""

make stage

echo "Make Package"

make package

echo "Make Install..."

make install
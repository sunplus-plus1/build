echo "$0"

# // ECIES encryption of KAES :
# u32 eph_IV[3];         // ephemeral IV
# u32 eph_Kpub;          // ECIES: ephemeral publick key

OUT=build_keys

rm -rf $OUT
mkdir $OUT

echo "* gen eph_IV (12 bytes)"
IV_FILE=$OUT/eph_IV.bin
dd if=/dev/urandom of=$IV_FILE bs=1 count=12 2>/dev/null
ls -l $IV_FILE

echo ""
echo ""

echo "* gen eph_Kpub (32 bytes) / eph_Kpriv (32 bytes)"
GEN_ASYM_X_KEY=../tools/mkey_x25519
$GEN_ASYM_X_KEY
rm -f keys/*.csv
mv -f keys/ $OUT/ecies
echo ""
echo ""


echo ""
echo ""

echo "* gen KAES (32 bytes)"
KAES_FILE=$OUT/KAES.bin
dd if=/dev/urandom of=$KAES_FILE bs=1 count=32 2>/dev/null
ls -l $KAES_FILE

echo ""
echo ""

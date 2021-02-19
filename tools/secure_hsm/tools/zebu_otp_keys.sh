echo "ed pub:"
edkey=`hexdump -e '8/4 "0x%08x "' secure/otp_Sb_keys/ed_pub_0.bin`
echo "$edkey"

echo ""
echo "x priv:"
xkey=`hexdump -e '8/4 "0x%08x "' secure/otp_Device_keys/x_priv_0.bin`
echo "$xkey"
echo ""

i=0
for dword in $edkey ;do
	echo "unsigned int  ZEBU_FORCE_KEY_OTP$i = $dword ;"
	i=$((i+1))
done

for dword in $xkey ;do
	echo "unsigned int  ZEBU_FORCE_KEY_OTP$i = $dword ;"
	i=$((i+1))
done

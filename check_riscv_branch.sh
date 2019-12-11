check_is_ok()
{
	if [ $1 -ne 0 ]; then
		echo "####### please switch $2 branch to $3 manually ! #######"
		exit 1;
	fi
}

do_switch_L2_clean()
{
	git checkout $2;check_is_ok $? $1 $2; make clean;cd ../..;
}

do_switch_L2()
{
	git checkout $2;check_is_ok $? $1 $2; cd ../..;
}

do_switch_L1()
{
	git checkout $2;check_is_ok $? $1 $2; cd ..;
}

cd boot/iboot;	do_switch_L2 iboot riscv;
cd boot/xboot;	do_switch_L2 xboot riscv;
cd boot/uboot;	do_switch_L2 uboot riscv;
cd boot/opensbi;do_switch_L2 opensbi master;
cd linux/kernel;do_switch_L2_clean kernel kernel_5.4;
cd ipack;		do_switch_L1 ipack riscv;

#!/bin/bash - 

# This is the address of the sender
# the file ${HOME}/etc/myauth should contain your
# "uid:passwd" for the ST/ST-Ericsson systems
# on that form.
SMTPFROM="<gabriel.fernandez@foss.st.com>"
SMTPUSER="gabriel.fernandez@foss.st.com"

# This is how we get the mails onto the Internet

# You may need to install some perl modules for this to work.
# On Ubuntu/Debian:
# sudo apt-get install git-email
# sudo apt-get install libnet-smtp-ssl-perl
# sudo apt-get install libauthen-sasl-perl

case "$1" in
   "")
	  echo "Usage: $0 [--DCG_UPD_stlinux_kernel] [--3_14] [--pinctrl] --[pinctrl-st] --[pinctrl-stm32] [--kernel_stlinux] [--ST_PDI_LMS_KERNEL] [--Stlinux-devel] [--linus-gmail] [--stlinux] [--lkml] [--arm-linux] [--mfd] [--dma] [--spi-st] [--spi-pl022] [--parts] [--mmc-pl180] [--primedma] [--rtc] [--i2c] [--mtd]"
	  RETVAL=1
	  ;;
	--auto)
	#    TOTARGETS=`./scripts/get_maintainer.pl --separator=, --nogit --nogit-fallback --norolestats --nol` $2
	#    CCTARGETS="`pwd`/scripts/get_maintainer.pl --separator=, --nogit --nogit-fallback --norolestats --nol"

		# cmd='./scripts/get_maintainer.pl --separator=, --nogit --nogit-fallback --norolestats --nol'
		# cmd+=" $2"
		TOTARGETS=`get_maintainer --to $2`
		CCTARGETS=`get_maintainer --cc $2`
		# cmd="get_maintainer --to $2"
		# cmd="g_get_maintainer.sh --to $2"
		
		# TOTARGETS=`$cmd`
		# echo cmd=$cmd
		# echo $1 $2
		# g_get_maintainer.sh --to $2
		echo TOTARGETS=$TOTARGETS
		echo CCTARGETS=$CCTARGETS
		echo @@@@@@@@@@@@@@@@@@
		# read
		
	   ;;
   	--rcc_ups)
	   TOTARGETS="Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Rob Herring <robh+dt@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski+dt@linaro.org>, Conor Dooley <conor+dt@kernel.org>, Maxime Coquelin <mcoquelin.stm32@gmail.com>, Alexandre Torgue <alexandre.torgue@foss.st.com>, Philipp Zabel <p.zabel@pengutronix.de>, Gabriel Fernandez <gabriel.fernandez@foss.st.com>, Maxime Ripard <mripard@kernel.org>, Dan Carpenter <dan.carpenter@linaro.org>, "Uwe Kleine-König" <u.kleine-koenig@pengutronix.de>"
	   CCTARGETS="linux-clk@vger.kernel.org,devicetree@vger.kernel.org,linux-stm32@st-md-mailman.stormreply.com,linux-arm-kernel@lists.infradead.org,linux-kernel@vger.kernel.org"
	   ;;

	--stm32_int)
	   TOTARGETS="alexandre.torgue@foss.st.com, patrick.delaunay@foss.st.com loic.pallardy@foss.st.com"
	   CCTARGETS="gabriel.fernandez@foss.st.com"
	   ;;

	--test)
	   TOTARGETS="gabriel.fernandez@foss.st.com "
	   CCTARGETS="gabriel.fernandez@st.com"
	   ;;
esac




if [ "x${TOTARGETS}" == "x" ] ; then
	echo "No valid target destination."
	exit 1
fi

PATCHES=$2

if [ "x${PATCHES}" == "x" ] ; then
	echo "No patch given."
	exit 1
fi

# If it is a dir we probably want to send a
# summary as well
#if [ -d $2 ] ; then
#    echo "Directory of patches..."
#    COMPOSE="--annotate --compose"
#else
	COMPOSE=
#fi

echo -n "Check that git is available..."
which git > /dev/null ; \
if [ ! $? -eq 0 ] ; then \
	echo "" ; \
	echo "ERROR: git is not in PATH=$PATH!" ; \
	echo "You need to install git." ; \
	echo "ABORTING." ; \
	exit 1 ; \
else \
	echo "OK" ;\
fi

echo -n "Check that git send-email is available..."
if [ ! -x /usr/lib/git-core/git-send-email ] ; then \
	echo "" ; \
	echo "ERROR: git-send-email is not present!" ; \
	echo "You need to install some subpackage like git-email." ; \
	echo "ABORTING." ; \
	exit 1 ; \
else \
	echo "OK" ;\
fi

# Split TOTARGETS into separate --to arguments
SENDARGS=""
IFS=,
for target in ${TOTARGETS}
do
	SENDARGS="${SENDARGS} --to=\"$target\""
done

for target in ${CCTARGETS}
do
	SENDARGS="${SENDARGS} --cc=\"$target\""
done

for target in ${BCCTARGETS}
do
	SENDARGS="${SENDARGS} --bcc=\"$target\""
done

echo "Sending ${PATCHES} as a mail..."
SENDCOMMAND="git send-email --no-format-patch \
--from=\"${SMTPFROM}\" \
--confirm=always \
--batch-size=4 \
--relogin-delay=60 \
${SENDARGS} \
${COMPOSE} \
--smtp-debug \
${PATCHES}"

echo $SENDCOMMAND
echo "---------------------------------"

eval "${SENDCOMMAND}"


########################################################################
# This program is free software: you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 3 of the License, or    #
# (at your option) any later version.                                  #
########################################################################

#!/bin/bash

. /usr/local/etc/nightlytool/nightly_env

usage()
{
cat << EOF
usage: $0 options

File Integrity Monitoring Script:

OPTIONS:
   -m      mode of operation [all refresh product cortex host]
   -s      sandbox name
   -l      log LOG_PATH
   -t      target to compile
   -p      product to compile
EOF
}

update_sandbox()
{
	SBX_NAME=$1
	LOG_PATH=$2
	SBX_PATH=/ae/$SBX_NAME
	bash -l /ae/_tools/contract/ae_init_sandbox -e "/ae/_tools/contract/ae_refresh_sandbox -f mine-conflict" $SBX_NAME > $LOG_PATH/$SBX_NAME'-Refresh.log' 2>&1
}

compile_product()
{
	SBX_NAME=$1
	PRODUCT=$2
	TARGET=$3
	LOG_PATH=$4
	SBX_PATH=/ae/$SBX_NAME
	/ae/_tools/contract/ae_init_sandbox -e "cd $SBX_PATH/work && . ./setup $TARGET $PRODUCT && gmake ATLAS_UPDATE=AUTO clean all" $SBX_NAME > $LOG_PATH/$SBX_NAME'_'$PRODUCT'_all.log' 2>&1
}

compile_cortex()
{
	SBX_NAME=$1
	PRODUCT=$2
	TARGET=$3
	LOG_PATH=$4
	SBX_PATH=/ae/$SBX_NAME
	/ae/_tools/contract/ae_init_sandbox -e "cd $SBX_PATH/work && . ./setup $TARGET $PRODUCT && gmake ATLAS_UPDATE=AUTO clean all" $SBX_NAME > $LOG_PATH/$SBX_NAME'_'$PRODUCT'_cortex.log' 2>&1
}

compile_host()
{
	SBX_NAME=$1
	PRODUCT=$2
	TARGET=$3
	LOG_PATH=$4
	SBX_PATH=/ae/$SBX_NAME
	/ae/_tools/contract/ae_init_sandbox -e "cd $SBX_PATH/work && . ./setup $TARGET $PRODUCT && cd $SBX_PATH/bcd_views/qtfp/work && gmake PRODUCT=$PRODUCT PLATFORM=host-qt5 clean" $SBX_NAME >> $LOG_PATH/$SBX_NAME'_host_'$PRODUCT.log 2>&1
	/ae/_tools/contract/ae_init_sandbox -e "cd $SBX_PATH/work && . ./setup $TARGET $PRODUCT && cd $SBX_PATH/bcd_views/qtfp/work && gmake PRODUCT=$PRODUCT PLATFORM=host-qt5 tools -j10" $SBX_NAME >> $LOG_PATH/$SBX_NAME'_host_'$PRODUCT.log 2>&1
}

compile_host_cmake()
{
	SBX_NAME=$1
	PRODUCT=$2
	TARGET=$3
	LOG_PATH=$4
	SBX_PATH=/ae/$SBX_NAME
	#/ae/_tools/contract/ae_init_sandbox -e "cd $SBX_PATH/work && . ./setup $TARGET $PRODUCT && cd $SBX_PATH/bcd_views/qtfp/work/cmake && gmake PRODUCT=$PRODUCT PLATFORM=host-qt5 makefile -j24" $SBX_NAME >> $LOG_PATH/$SBX_NAME'_host_cmake_'$PRODUCT.log 2>&1
	/ae/_tools/contract/ae_init_sandbox -e "cd $SBX_PATH/work && . ./setup $TARGET $PRODUCT && cd $SBX_PATH/bcd_views/qtfp/work/cmake && gmake PRODUCT=$PRODUCT PLATFORM=host-qt5 -j24" $SBX_NAME >> $LOG_PATH/$SBX_NAME'_host_cmake_'$PRODUCT.log 2>&1
}

while getopts m:s:l:t:p: option
do
        case "${option}"
        in
                m) MODE=${OPTARG};;
                s) SANDBOX=${OPTARG};;
                l) LOG=${OPTARG};;
                t) TARGETMODE=$OPTARG;;
				p) TARGETPRODUCT=$OPTARG;;
        esac
done

if [ -z $SANDBOX ]; then
	usage
	exit -1
fi

if [ -z $LOG ]; then
	usage
	exit -1
fi

case "$MODE" in
	"all")     echo "Working in mode all"
			   if [ -z $TARGETMODE -o -z $TARGETPRODUCT ]; then
			 	usage
				exit -1
			   fi
			   update_sandbox $SANDBOX $LOG
			   compile_product $SANDBOX $TARGETPRODUCT $TARGETMODE $LOG
			   compile_host $SANDBOX $TARGETPRODUCT $TARGETMODE $LOG
		       ;;
	"refresh") echo "Working in mode refresh"
			   update_sandbox $SANDBOX $LOG
		       ;;
	"product") echo "Working in mode product"
			   if [ -z $TARGETMODE -o -z $TARGETPRODUCT ]; then
			 	usage
				exit -1
			   fi
			   compile_product $SANDBOX $TARGETPRODUCT $TARGETMODE $LOG
		   	   ;;
	"cortex")  echo "Working in mode cortex"
			   if [ -z $TARGETMODE -o -z $TARGETPRODUCT ]; then
			 	usage
				exit -1
			   fi
			   compile_cortex $SANDBOX $TARGETPRODUCT $TARGETMODE $LOG
		   	   ;;
	"host")    echo "Working in mode host"
			   if [ -z $TARGETMODE -o -z $TARGETPRODUCT ]; then
			 	usage
				exit -1
			   fi
			   compile_host $SANDBOX $TARGETPRODUCT $TARGETMODE $LOG
		       ;;
	"host_cmake")    echo "Working in mode host cmake"
			   if [ -z $TARGETMODE -o -z $TARGETPRODUCT ]; then
			 	usage
				exit -1
			   fi
			   compile_host_cmake $SANDBOX $TARGETPRODUCT $TARGETMODE $LOG
		       ;;
	*)         echo "Wrong mode"; usage; exit -1;
               ;;
esac

pushd /home/tcn/software/vanda/r48910/bin_pkg/centos7.5/sfx_qual_suite/ 
if [ $1 == "cl" ];then
sudo ./initcard.sh --blk --cl
elif [ $1 == "load" ]; then
sudo modprobe sfxv_bd_dev
fi
#sudo sh ./css-status.sh
popd

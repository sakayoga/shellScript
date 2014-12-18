#!/bin/sh
# Name          : periksa_nf_conntrack
# Version       : 0.1 (18/12/2014)
# By            : IGB Sakayoga K
# Purpose       : Memeriksa nilai nf_conntrack and conntrack usage untuk setiap openstack controller and compute node.
#                 Memeriksa tanggal terjadinya nf_conntrack table full, dropping packet.
# Depend        : autlogoin di setiap node, hanya dapat digunakan di node fuel.
# Created file  : ComputeControllerNodeList.nfo, Report.nfo

updateComputeControllerNodeList () {
 fuel node|grep -e compute -e controller|awk '{print $1" "$14}'|sort -k1,1n|sed -e 's/,//g' > ComputeControllerNodeList.nfo
 printf "Total `cat ComputeControllerNodeList.nfo|grep compute|wc -l` node Compute dan `cat ComputeControllerNodeList.nfo|grep controller|wc -l` node Controller\n"
}

runCheckNF () {
        [ ! -f ComputeControllerNodeList.nfo ] && updateComputeControllerNodeList
        checkNode="`cat ComputeControllerNodeList.nfo|grep $checkOptions|awk '{print $1}'`"
        printf ".---------------------------------------------------------------.\n"
        printf "|       node    |       max value       |       current value   |\n"
        printf "|---------------------------------------------------------------|\n"
        for nodeNumber in $checkNode
        do
            maxValue="`ssh node-$nodeNumber 'sysctl net.netfilter.nf_conntrack_max'|awk '{print $3}'`"
            curValue="`ssh node-$nodeNumber 'sysctl net.netfilter.nf_conntrack_count'|awk '{print $3}'`"
            printf "|   $nodeNumber     |       $maxValue               |               $curValue       |\n"
        done
        printf ".---------------------------------------------------------------.\n"
}

case $1 in
        update-list)
                updateComputeControllerNodeList
        ;;
        checknf)
                case $2 in
                        controller)
                                checkOptions="controller"
                                runCheckNF
                        ;;
                        compute)
                                checkOptions="compute"
                                runCheckNF
                        ;;
                        all)
                                checkOptions="-e compute -e controller"
                                runCheckNF
                        ;;
                        *)
                        printf "Penggunaan : $0 $1 [all|compute|controller]\n"
                        exit 1
                esac
        ;;
        *)
                printf "usage : $1 update-list|checknf [options]\n"
                exit 1
esac
exit 0

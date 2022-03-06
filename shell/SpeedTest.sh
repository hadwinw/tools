#!/usr/bin/env bash

trap _exit INT QUIT TERM

_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
}

_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
}

_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
}

_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
}

_exists() {
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

_exit() {
    _red "\nThe script has been terminated.\n"
    # clean up
    rm -fr speedtest speedtest.log
    exit 1
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

speed_test() {
    local nodeName="$2"
    ./speedtest --simple --server=$1 > speedtest.log 2>&1
    if [ $? -eq 0 ]; then
        local dl_speed=$(awk '/Download/{print $3" "$4}' speedtest.log)
        local up_speed=$(awk '/Upload/{print $3" "$4}' speedtest.log)
        local latency=$(awk '/Ping/{print $2" "$3}' speedtest.log)
        if [[ -n "${dl_speed}" && -n "${up_speed}" && -n "${latency}" ]]; then
            printf "\033[0;33m%-18s\033[0;32m%-18s\033[0;31m%-20s\033[0;36m%-12s\033[0m\n" " ${nodeName}" "${up_speed}" "${dl_speed}" "${latency}"
        fi
    fi
}

speed() {
    speed_test '1' 'Sydney, AU'
    speed_test '2' 'Melbourne, AU'
    speed_test '3' 'Sao Paulo, BR'
    speed_test '4' 'Vinhedo, BR'
    speed_test '5' 'Montreal, CA'
    speed_test '6' 'Toronto, CA'
    speed_test '7' 'Santiago, CL'
    speed_test '8' 'Marseille, FR'
    speed_test '9' 'Frankfurt, DE'
    speed_test '10' 'Hyderabad, IN'
    speed_test '11' 'Mumbai, IN'
    speed_test '12' 'Jerusalem, IL'
    speed_test '13' 'Milan, IT'
    speed_test '14' 'Osaka, JP'
    speed_test '15' 'Tokyo, JP'
    speed_test '16' 'Amsterdam, NL'
    speed_test '17' 'Jeddah, SA'
    speed_test '18' 'Singapore, SG'
    speed_test '19' 'Johannesburg, ZA'
    speed_test '20' 'Seoul, KR'
    speed_test '21' 'Chuncheon, KR'
    speed_test '22' 'Stockholm, SE'
    speed_test '23' 'Zurich, CH'
    speed_test '24' 'Abu Dhabi, AE'
    speed_test '25' 'Dubai, AE'
    speed_test '26' 'London, GB'
    speed_test '27' 'Cardiff, GB'
    speed_test '28' 'Ashburn, US'
    speed_test '29' 'Phoenix, US'
    speed_test '30' 'San Jose, US'
}

ipv4_info() {
    local organization="$(wget -q -T10 -O- ip.wjy.me/organization)"
    local location="$(wget -q -T10 -O- ip.wjy.me/location)"
    local region="$(wget -q -T10 -O- ip.wjy.me/region)"
    if [[ -n "$organization" ]]; then
        echo " Organization       : $(_blue "$organization")"
    fi
    if [[ -n "$location" ]]; then
        echo " Location           : $(_blue "$location")"
    fi
    if [[ -n "$region" ]]; then
        echo " Region             : $(_yellow "$region")"
    fi
    if [[ -z "$organization" ]]; then
        echo " Region             : $(_red "No ISP detected")"
    fi
}

install_speedtest() {
    if [ ! -e "speedtest" ]; then
        sys_bit=""
        local sysarch="$(uname -m)"
        if [ "${sysarch}" = "unknown" ] || [ "${sysarch}" = "" ]; then
            local sysarch="$(arch)"
        fi
        if [ "${sysarch}" = "x86_64" ]; then
            sys_bit="amd64"
        fi
        if [ "${sysarch}" = "i386" ] || [ "${sysarch}" = "i686" ]; then
            sys_bit="386"
        fi
        if [ "${sysarch}" = "armv8" ] || [ "${sysarch}" = "armv8l" ] || [ "${sysarch}" = "aarch64" ] || [ "${sysarch}" = "arm64" ]; then
            sys_bit="arm64"
        fi
        if [ "${sysarch}" = "armv7" ] || [ "${sysarch}" = "armv7l" ] || [ "${sysarch}" = "armv6" ]; then
            sys_bit="arm"
        fi
        [ -z "${sys_bit}" ] && _red "Error: Unsupported system architecture (${sysarch}).\n" && exit 1
        url="https://nmsl.tk/Software/librespeed-cli-linux-${sys_bit}"
        wget --no-check-certificate -q -T10 -O speedtest ${url}
        [ $? -ne 0 ] && _red "Error: Failed to download speedtest-cli.\n" && exit 1
        chmod +x speedtest
    fi
}

print_intro() {
    echo "---------------------------- SpeedTest.sh ----------------------------"
    echo " Version            : $(_green v2022-02-26)"
    echo " Usage              : $(_red 'bash <(wget -qO- nmsl.tk/Scripts/SpeedTest.sh)')"
}

print_end_time() {
    end_time=$(date +%s)
    time=$(( ${end_time} - ${start_time} ))
    if [ ${time} -gt 60 ]; then
        min=$(expr $time / 60)
        sec=$(expr $time % 60)
        echo " Finished in        : ${min} min ${sec} sec"
    else
        echo " Finished in        : ${time} sec"
    fi
    date_time=$(date '+%Y-%m-%d %H:%M:%S %Z')
    echo " Timestamp          : $date_time"
}

! _exists "wget" && _red "Error: wget command not found.\n" && exit 1
start_time=$(date +%s)
clear
print_intro
next
ipv4_info
next
install_speedtest && printf "%-18s%-18s%-20s%-12s\n" " Node Name" "Upload Speed" "Download Speed" "Latency"
speed && rm -fr speedtest speedtest.log 
next
print_end_time
next

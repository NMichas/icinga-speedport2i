#!/bin/bash

# Gather command-line parameters.
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h) hostname="$2"; shift 2;;
    -drw) downRateW="$2"; shift 2;;
    -drc) downRateC="$2"; shift 2;;
    -urw) upRateW="$2"; shift 2;;
    -urc) upRateC="$2"; shift 2;;
    -daw) downAttenuationW="$2"; shift 2;;
    -dac) downAttenuationC="$2"; shift 2;;
    -uaw) upAttenuationW="$2"; shift 2;;
    -uac) upAttenuationC="$2"; shift 2;;
    -dsw) downSNRW="$2"; shift 2;;
    -dsc) downSNRC="$2"; shift 2;;
    -usw) upSNRW="$2"; shift 2;;
    -usc) upSNRC="$2"; shift 2;;

    --hostname) echo "$1 requires an argument" >&2; exit 1;;
    --downRateW) echo "$1 requires an argument" >&2; exit 1;;
    --downRateC) echo "$1 requires an argument" >&2; exit 1;;
    --upRateW) echo "$1 requires an argument" >&2; exit 1;;
    --upRateC) echo "$1 requires an argument" >&2; exit 1;;
    --downAttenuationW) echo "$1 requires an argument" >&2; exit 1;;
    --downAttenuationC) echo "$1 requires an argument" >&2; exit 1;;
    --upAttenuationW) echo "$1 requires an argument" >&2; exit 1;;
    --upAttenuationC) echo "$1 requires an argument" >&2; exit 1;;
    --downSNRW) echo "$1 requires an argument" >&2; exit 1;;
    --downSNRC) echo "$1 requires an argument" >&2; exit 1;;
    --upSNRW) echo "$1 requires an argument" >&2; exit 1;;
    --upSNRC) echo "$1 requires an argument" >&2; exit 1;;
    -*) echo "unknown option: $1" >&2; exit 1;;
    *) echo "unrecognized argument: $1"; exit 1;;
  esac
done

# Get HTML exctract of the status page.
STATUS=$(curl -s http://$hostname/common_page/status_info_lua.lua)

# Scrape values.
Upstream_noise_margin=$(grep -Po "<ParaName>Upstream_noise_margin</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Upstream_current_rate=$(grep -Po "<ParaName>Upstream_current_rate</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Downstream_noise_margin=$(grep -Po "<ParaName>Downstream_noise_margin</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Downstream_current_rate=$(grep -Po "<ParaName>Downstream_current_rate</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
UpCrc_errors=$(grep -Po "<ParaName>UpCrc_errors</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Downstream_attenuation=$(grep -Po "<ParaName>Downstream_attenuation</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Fec_errors=$(grep -Po "<ParaName>Fec_errors</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
DownCrc_errors=$(grep -Po "<ParaName>DownCrc_errors</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Atuc_fec_errors=$(grep -Po "<ParaName>Atuc_fec_errors</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")
Upstream_attenuation=$(grep -Po "<ParaName>Upstream_attenuation</ParaName>.*?<ParaValue>\K(.*?)(?=</ParaValue>)" <<< "$STATUS")

# Scaling.
Upstream_noise_margin=`bc <<<"scale=1; $Upstream_noise_margin / 10"`
Downstream_noise_margin=`bc <<<"scale=1; $Downstream_noise_margin / 10"`
Downstream_attenuation=`bc <<<"scale=1; $Downstream_attenuation / 10"`
Upstream_attenuation=`bc <<<"scale=1; $Upstream_attenuation / 10"`

# Checks.
critical=0
if [[ -n $downRateC ]] && (( $critical==0 )) ; then
  critical=$(echo $Downstream_current_rate '<' $downRateC | bc -l)
fi
if [[ -n $upRateC ]] && (( $critical==0 )) ; then
  critical=$(echo $Upstream_current_rate '<' $upRateC | bc -l) 
fi
if [[ -n $downAttenuationC ]] && (( $critical==0 )) ; then
  critical=$(echo $Downstream_attenuation '<' $downAttenuationC | bc -l) 
fi
if [[ -n $upAttenuationC ]] && (( $critical==0 )) ; then
  critical=$(echo $Upstream_attenuation '<' $upAttenuationC | bc -l) 
fi

warning=0
if (( $critical==0 )); then
  if [[ -n $downRateW ]] && (( $warning==0 )) ; then
    warning=$(echo $Downstream_current_rate '<' $downRateW | bc -l) 
  fi
  if [[ -n $upRateW ]] && (( $warning==0 )) ; then
    warning=$(echo $Upstream_current_rate '<' $upRateW  | bc -l)
  fi
  if [[ -n $downAttenuationW ]] && (( $warning==0 )) ; then
    warning=$(echo $Downstream_attenuation '<' $downAttenuationW | bc -l)
  fi
  if [[ -n $upAttenuationW ]] && (( $warning==0 )) ; then
    warning=$(echo $Upstream_attenuation '<' $upAttenuationW | bc -l)
  fi
fi

# Generate output.
OUTPUT="OK"
if (( $warning==1 )); then
  OUTPUT="WARNING"
fi
if (( $critical==1 )); then
  OUTPUT="CRITICAL"
fi


OUTPUT="$OUTPUT | 
Upstream_noise_margin=$Upstream_noise_margin;$upSNRW;$upSNRC;0
Upstream_current_rate=$Upstream_current_rate;$upRateW;$upRateC;0
Downstream_noise_margin=$Downstream_noise_margin;$downSNRW;$downSNRC;0
Downstream_current_rate=$Downstream_current_rate;$downRateW;$downRateC;0
UpCrc_errors=$UpCrc_errors
Downstream_attenuation=$Downstream_attenuation;$downAttenuationW;$downAttenuationC;0
Fec_errors=$Fec_errors
DownCrc_errors=$DownCrc_errors
Atuc_fec_errors=$Atuc_fec_errors
Upstream_attenuation=$Upstream_attenuation;$upAttenuationW;$upAttenuationC;0"

# Output.
echo $OUTPUT

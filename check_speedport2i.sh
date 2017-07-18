#!/bin/bash
STATUS=$(curl -s http://$1/common_page/status_info_lua.lua )

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

OUTPUT="ok | 
Upstream_noise_margin=$Upstream_noise_margin
Upstream_current_rate=$Upstream_current_rate
Downstream_noise_margin=$Downstream_noise_margin
Downstream_current_rate=$Downstream_current_rate
UpCrc_errors=$UpCrc_errors
Downstream_attenuation=$Downstream_attenuation
Fec_errors=$Fec_errors
DownCrc_errors=$DownCrc_errors
Atuc_fec_errors=$Atuc_fec_errors
Upstream_attenuation=$Upstream_attenuation"

echo $OUTPUT

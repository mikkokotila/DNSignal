#!/bin/bash

N=0
while read DOMAIN
	do

	N=$(expr $N + 1)					
	INDEXKEY=$(echo $DOMAIN | colrm 3)

	LC_ALL=C grep -e "$DOMAIN" "$INDEXKEY" > "$DOMAIN".temp
	LC_ALL=C TOTALIP=$(cat $DOMAIN.temp | wc -l)
	LC_ALL=C UNIQUEIP=$(cat $DOMAIN.temp | sort -u | wc -l) 

	while read IP
		do
		LC_ALL=C grep -e "$IP" "$DOMAIN".temp > "$IP".temp
		LC_ALL=C cat "$IP".temp | wc -l >> spearman.temp
		rm "$IP.temp"
	done <dnsignal.ip

	paste spearman.temp spearman.control > data.csv
	SPEARMAN=$(./spearman.r | sed 1d | cut -d ' ' -f4 | head -1)
	rm spearman.temp
 	rm data.csv						
	rm "$DOMAIN".temp

	wget -q -O entropy.temp $DOMAIN -T 15 --tries=3
	ENTROPY=$(cat entropy.temp | tr ' ' '\n' | grep -E "^[a-z]{4,7}$" | sort -u | ./entropy.r | cut -d ' ' -f2)
	rm entropy.temp
			
	sudo t search all "$DOMAIN" -l > twitter.temp
	TWENTROPY=$(cut -d ' ' -f9- twitter.temp | ./entropy.r | cut -d ' ' -f2)
	TWTOTAL=$(cut -d ' ' -f8 twitter.temp | wc -l)
	TWUNIQUE=$(cut -d ' ' -f8 twitter.temp | sort -u | wc -l)
	LC_ALL=C cut -d ' ' -f8 twitter.temp | shuf -n 5 > handles.temp

	while read HANDLE
		do
		LC_ALL=C curl -s https://twitter.com/"$HANDLE" | grep data-is-compact | cut -d '>' -f2 | cut -d '<' -f1 | sed 2d | head -2 | tr '\n' '\t' >> network.temp
	done <handles.temp

	TWEETS=$(awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' network.temp)
	FOLLOWERS=$(awk '{ sum += $2; n++ } END { if (n > 0) print sum / n; }' network.temp)
	rm network.temp

	sudo curl https://www.mywot.com/en/scorecard/"$DOMAIN" -s -m 15 --retry 3 > wot.temp
	TRUST=$(grep "trustworthiness" wot.temp | tr ' ' '\n' | grep data-value | cut -d '"' -f2)
	VOTES=$(grep -e "span itemprop=" wot.temp | grep votes | cut -d '>' -f2 | cut -d '<' -f1)
	rm wot.temp
					
	USER_AGENT=$(shuf dnsignal.ua | head -1)
	PROXY=$(shuf dnsignal.proxy | head -1)
	sudo wget -O alexa.temp --user-agent="$USER_AGENT" http://www.alexa.com/siteinfo/"$DOMAIN" -q --proxy-user "username" --proxy-password "password" use_proxy=yes -e http_proxy="$PROXY" -T 15 --tries=3
	BOUNCE=$(grep -e "%  " alexa.temp | colrm 10 | tr -d ":[[:blank:]]:" | sed "s/%//" | head -1)
	SEARCH=$(grep -e "%  " alexa.temp | colrm 10 | tr -d ":[[:blank:]]:" | sed "s/%//" | tail -1)
	ALEXARANK=$(grep -e "  </strong>" alexa.temp | colrm 15 | tr -d ":[[:blank:]]:" | sed 's/,//g' | head -1)
	rm alexa.temp
					
	SOV=$(echo -e "scale=5; $TOTALIP / 23000" | bc)
	TWITTER=$(echo -e "scale=2; ($TWUNIQUE / $TWTOTAL) * 100" | bc)
	QUALITY=$(echo -e "scale=2; ($BOUNCE * $SEARCH) / 10" | bc)
	IPS=$(echo -e "scale=2; ($UNIQUEIP / $TOTALIP) * 100" | bc)
	RANK=$(echo -e "scale=2; ($ALEXARANK /$N) * 100" | bc)
	TRUST=$(echo -e "scale=2; ($TRUST * $VOTES) / 10000" | bc)
	TWUNIQ=$(echo -e "scale=2; ($TWTOTAL / $TWUNIQUE) * 5" | bc)
	TWSCORE=$(echo -e "scale=2; ($FOLLOWERS / $TWEETS) * 10" | bc)
	TWENTROPY=$(echo $TWENTROPY)
	ENTROPY=$(echo $ENTROPY)
	SPEARMAN=$(echo $SPEARMAN)
				
	echo -e "$DOMAIN,$SOV,$RANK,$IPS,$SPEARMAN,$TWSCORE,$TWENTROPY,$TWUNIQ,$TRUST,$ENTROPY,$QUALITY" | sed -e "s/,,/,na,/g" >> dnsignal.output

done <dnsignal.input

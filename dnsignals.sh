#!/bin/bash

## S C R A P I N G

user_agent()
{
	USER_AGENT=$(shuf dnsignals.ua | head -1) 
}

proxy()
{
	PROXY=$(shuf dnsignals.proxy | head -1)
}

## D A T A  C O L L E C T I O N (all are web scraper based)

similarweb_data(){

	curl -s http://www.similarweb.com/website/$DOMAIN | perl -0777 -MHTML::Strip -nlE 'say HTML::Strip->new->parse($_)' > similarweb.temp0
	cat similarweb.temp0 | tr -s ' ' | grep -v -e "^[[:blank:]]$" | tr '\n' '~' | sed 's/\%~/%,/g' | tr ',' '\n' | grep % | tr -s '~' | tr -d [[:blank:]] | rev | cut -d '~' -f1-2 | rev | cut -d '~' -f2 > similarweb.temp2
}

alexa_data(){
	sudo wget --user-agent="$USER_AGENT" http://www.alexa.com/siteinfo/"$DOMAIN" -q --proxy-user "2lk34jx0" --proxy-password "AXZmtolaxJcPnAZ5hkcLMfRzNTojs3YGehuOjsHjJz0=" use_proxy=yes -e http_proxy="$PROXY" -T 3 --tries=2
}

wot_data()
{
	sudo curl https://www.mywot.com/en/scorecard/"$DOMAIN" -s -m 3 --retry 2 > wotdata.temp
}

whois_data(){
	whois $DOMAIN > $DOMAIN.temp
}

# S C O R E S (similar web)

similarweb_country1(){
	head -2 similarweb.temp2 | tail -1
}
similarweb_country2(){
	head -3 similarweb.temp2 | tail -1
}
similarweb_country3(){
	head -4 similarweb.temp2 | tail -1
}
similarweb_country4(){
	head -5 similarweb.temp2 | tail -1
}
similarweb_country5(){
	head -6 similarweb.temp2 | tail -1
}

similarweb_social1(){
	head -18 similarweb.temp2 | tail -1
}

similarweb_social2(){
	head -19 similarweb.temp2 | tail -1
}

similarweb_social3(){
	head -20 similarweb.temp2 | tail -1
}

similarweb_social4(){
	head -21 similarweb.temp2 | tail -1
}

similarweb_social5(){
	head -22 similarweb.temp2 | tail -1
}

similarweb_direct(){
	head -7 similarweb.temp2 | tail -1
}
similarweb_referral(){
	head -8 similarweb.temp2 | tail -1
}
similarweb_email(){
	head -10 similarweb.temp2 | tail -1
}
similarweb_display(){
	head -10 similarweb.temp2 | tail -1
}
similarweb_search(){
	head -11 similarweb.temp2 | tail -1
}
similarweb_social(){
	head -10 similarweb.temp2 | tail -1
}

similarweb_organicsearch(){
	head -15 similarweb.temp2 | tail -1
}

similarweb_paidsearch(){
	head -16 similarweb.temp2 | tail -1
}

similarweb_bounce(){
	head -1 similarweb.temp
}

# S C O R E S (alexa)

alexa_topcountries(){
	grep -e "{title:" $DOMAIN | cut -d ':' -f3- | cut -d '"' -f1 | numsum
}

alexa_bouncerate(){
	grep -e "%  " $DOMAIN | colrm 10 | tr -d ":[[:blank:]]:" | head -1
}

alexa_searchvisits(){
	grep -e "%  " $DOMAIN | colrm 10 | tr -d ":[[:blank:]]:" | tail -1
}

alexa_rank(){
	grep -e "  </strong>" $DOMAIN | colrm 15 | tr -d ":[[:blank:]]:" | sed 's/,//g' | head -1
}

alexa_pageviews(){
	grep -e "  </strong>" $DOMAIN | colrm 15 | tr -d ":[[:blank:]]:" | head -4 | tail -1
}

alexa_timeonsite(){
	grep -e "  </strong>" $DOMAIN | colrm 15 | tr -d ":[[:blank:]]:" | head -5 | tail -1
}

alexa_topkeywords(){
	grep -e "topkeywordellipsis" $DOMAIN | cut -d '>' -f9 | cut -d '<' -f1 | numsum
}

alexa_inlinks(){
	grep "font-4 box1-r" $DOMAIN | cut -d '>' -f2 | cut -d '<' -f1 | sed 's/,//g'
}

alexa_loadspeed(){
	grep "loadspeed-panel-content" $DOMAIN | cut -d '(' -f2 | cut -d ')' -f1 | sed 's/[a-z]//g' | sed 's/\ S//'
}

alexa_males(){
	grep "Males are" $DOMAIN | cut -d '>' -f3 | cut -d '<' -f1 | sed 's/-represented//'
}

alexa_females(){
	grep "Females are" $DOMAIN | cut -d '>' -f3 | cut -d '<' -f1 | sed 's/-represented//'
}

wot_trust(){
	grep "trustworthiness" wotdata.temp | tr ' ' '\n' | grep data-value | cut -d '"' -f2
}

wot_childsafety(){
	grep "childsafety" wotdata.temp | tr ' ' '\n' | grep data-value | tr '"' '\n' | grep ^[0-9]
}

wot_votes(){
	grep -e "span itemprop=" wotdata.temp | grep votes | cut -d '>' -f2 | cut -d '<' -f1
}

whois_privacy(){
	NAME=$(grep "Registrant Name" $DOMAIN.temp | cut -d ' ' -f3-)
	PRIVATE=$(echo $NAME | grep -i -E '(protected|private|whois|guard)' | sed -E 's/[[:blank:]]//g')

	if [[ -z "$PRIVATE" ]]; then
		
		echo "false"
	else
		
		echo "true"
	fi
}

whois_years(){
	CREATED=$(grep "Creation Date" $DOMAIN.temp | head -1 | cut -d ' ' -f6-)
	WHOIS_Y=$(echo $CREATED | cut -d '-' -f3)
	YEAR=$(date +%Y)
	expr $YEAR - $WHOIS_Y 2>/dev/null
}

## P R O G R A M  S T A R T S

while read DOMAIN
	do

	# preparation
	user_agent
	proxy

	# data collection
	similarweb_data
	alexa_data
	wot_data
	whois_data

	# metrics
	SW_COUNTRY1=$(similarweb_country1)
	SW_COUNTRY2=$(similarweb_country2)
	SW_COUNTRY3=$(similarweb_country3)
	SW_COUNTRY4=$(similarweb_country4)
	SW_COUNTRY5=$(similarweb_country5)

	SW_SOCIAL1=$(similarweb_social1)
	SW_SOCIAL2=$(similarweb_social2)
	SW_SOCIAL3=$(similarweb_social3)
	SW_SOCIAL4=$(similarweb_social4)
	SW_SOCIAL5=$(similarweb_social5)

	SW_DIRECT=$(similarweb_direct)
	SW_REFERRAL=$(similarweb_referral)
	SW_EMAIL=$(similarweb_email)
	SW_DISPLAY=$(similarweb_display)
	SW_SEARCH=$(similarweb_search)
	SW_ORGANICSEARCH=$(similarweb_organicsearch)
	SW_PAIDSEARCH=$(similarweb_paidsearch)
	SW_BOUNCE=$(similarweb_bounce)

	ALEXA_TOPCOUNTRIES=$(alexa_topcountries)
	ALEXA_BOUNCERATE=$(alexa_bouncerate)
	ALEXA_SEARCHVISITS=$(alexa_searchvisits)
	ALEXA_RANK=$(alexa_rank)
	ALEXA_PAGEVIEWS=$(alexa_pageviews)
	ALEXA_TIMEONSITE=$(alexa_timeonsite)
	ALEXA_TOPKEYWORDS=$(alexa_topkeywords)
	ALEXA_INLINKS=$(alexa_inlinks)
	ALEXA_LOADSPEED=$(alexa_loadspeed)
	ALEXA_MALES=$(alexa_males)
	ALEXA_FEMALES=$(alexa_females)

	WOT_TRUST=$(wot_trust)
	WOT_CHILDSAFETY=$(wot_childsafety)
	WOT_VOTES=$(wot_votes)

	WHOIS_PRIVACY=$(whois_privacy)
	WHOIS_YEARS=$(whois_years)	

	OUTPUT=$(echo -e "$DOMAIN,$WHOIS_YEARS,$WHOIS_PRIVACY,$WOT_VOTES,$WOT_TRUST,$WOT_CHILDSAFETY,$ALEXA_MALES,$ALEXA_FEMALES,$ALEXA_LOADSPEED,$ALEXA_INLINKS,$ALEXA_TOPKEYWORDS,$ALEXA_TIMEONSITE,$ALEXA_PAGEVIEWS,$ALEXA_RANK,$ALEXA_SEARCHVISITS,$ALEXA_BOUNCERATE,$ALEXA_TOPCOUNTRIES,$SW_BOUNCE,$SW_PAIDSEARCH,$SW_ORGANICSEARCH,$SW_SEARCH,$SW_DISPLAY,$SW_EMAIL,$SW_REFERRAL,$SW_DIRECT,$SW_SOCIAL1,$SW_SOCIAL2,$SW_SOCIAL3,$SW_SOCIAL4,$SW_SOCIAL5,$SW_COUNTRY1,$SW_COUNTRY2,$SW_COUNTRY3,$SW_COUNTRY4,$SW_COUNTRY55")
	echo $OUTPUT | sed -e 's/[[:blank:]]//g' | sed -e "s/,,/,NA,/g" >> signals.output

rm *.temp
rm $DOMAIN

done <dnsignal.input

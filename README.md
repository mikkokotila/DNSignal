# DNSignals
### domain name signal taxonomy builder for domain based signal intelligence research

IMPORTANT NOTICE: Since having written these scripts, it came out that SimilarWeb was using spyware to collect its data. You can read more about that here:   

http://mweissbacher.com/blog/2016/03/31/these-chrome-extensions-spy-on-8-million-users/

Because I think this data is very useful for advertising fraud researchers, I've decided to still make it available. It is not a statement in support of SimilarWeb's business practices. 


####1) Depending on your distrution, you may need other things as well, but the two dependencies Ubuntu users will need are: 

    sudo apt-get install num-utils

    cpan \
    install HTML::Strip


####2) Configure your VPN settings

- change the VPN login information from the dnsignals.sh script 
- include your VPN servers in the dnsignals.proxy file 


####3) Create a list of domain names you want to scan

The domains you want to create the signals for goes in to dnsignals.input

####4) Run the script 

First the obvious: 

    chmod +x dnsignals.sh
    
If you have a lot of domains you want to scan, you probably want to start a TMUX install or something similar first, so you can have it run on the background. The script should be pretty stable, I've used it to scan 1,000,000 domains at one go without any issues. It takes time but works. When you are ready to go:

    ./dnsignals.sh


#### signal taxonomy (produced by dnsignals.sh) 

	SW_COUNTRY1		    share of traffic for 1st country		    percentile
	SW_COUNTRY2		    share of traffic for 2nd country		    percentile
	SW_COUNTRY3		    share of traffic for 3rd country		    percentile
	SW_COUNTRY4	    	share of traffic for 4th country		    percentile
	SW_COUNTRY5		    share of traffic for 5th country		    percentile

	SW_SOCIAL1		    share of traffic for 1st social site		percentile		
	SW_SOCIAL2		    share of traffic for 2nd social site		percentile
	SW_SOCIAL3		    share of traffic for 3rd social site		percentile
	SW_SOCIAL4		    share of traffic for 4th social site		percentile
	SW_SOCIAL5		    share of traffic for 5th social site		percentile

	SW_DIRECT		    share of traffic of direct traffic		    percentile
	SW_REFERRAL		    share of traffic of referral traffic		percentile
	SW_EMAIL		    share of traffic of email traffic		    percentile
	SW_DISPLAY		    share of traffic of display ad traffic		percentile
	SW_SEARCH		    share of traffic of search traffic		    percentile
	SW_ORGANICSEARCH	share of traffic of organic search traffic	percentile
	SW_PAIDSEARCH		share of traffic of paid search traffic		percentile
	SW_BOUNCE	        share of traffic of bounced traffic		    percentile

	ALEXA_TOPCOUNTRIES	share of top5 countries of all traffic		percentile
	ALEXA_BOUNCERATE	share of traffic of bounced traffic		    percentile
	ALEXA_SEARCHVISITS	share of traffic of search traffic		    percentile
	ALEXA_RANK		    global rank					                rank
	ALEXA_PAGEVIEWS		average pageviews				            decimal
	ALEXA_TIMEONSITE	average time on site				        time
	ALEXA_TOPKEYWORDS	share of top5 keywords of traffic		    percentile
	ALEXA_INLINKS		number of links leading to the site		    integer
	ALEXA_LOADSPEED		time it takes on average to load the page	time
	ALEXA_MALES		    affinity with male audiences			    category
	ALEXA_FEMALES		affinity with female audiences			    category

	WOT_TRUST		    user trust on the site				        integer
	WOT_CHILDSAFETY		user reviewed childsafety of the site		integer		
	WOT_VOTES		    number of votes the site received		    integer

	WHOIS_PRIVACY		the domain uses whois privacy			    boolean
	WHOIS_YEARS		    number of years from creation of domain		integer






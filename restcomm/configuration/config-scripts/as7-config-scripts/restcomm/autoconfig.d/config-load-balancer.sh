#! /bin/bash
##
## Description: Configures SIP Load Balancer
## Author     : Henrique Rosa (henrique.rosa@telestax.com)
## Author     : Pavel Slegr (pavel.slegr@telestax.com)
## Author     : Charles Roufay (charles.roufay@telestax.com)
##
## Last update: 22/03/2016
## Change Log: Move away from Telestax Proxy and configure LB from restcomm.conf
## FUNCTIONS
##
##
##
##
configSipStack() {
	lb_sipstack_file="$RESTCOMM_HOME/standalone/configuration/mss-sip-stack.properties"

     #delete additional connectors if any added to erlier run of the script.
    if  grep -q "## lb-configuration ##" $lb_sipstack_file
    then
          echo "Additional Connectors Created earlier, going to delete the connectors"
          sed '/## lb-configuration ##/,/## lb-configuration ##/d' $lb_sipstack_file > $lb_sipstack_file.bak
          mv $lb_sipstack_file.bak $lb_sipstack_file
    else
         echo "LB was not configured earlier"
    fi

    if [ "$ACTIVATE_LB" == "true" ] || [ "$ACTIVATE_LB" == "TRUE" ]; then
    if [ -z "$LB_INTERNAL_IP" ]; then
      		LB_INTERNAL_IP=$LB_PUBLIC_IP
		fi
      sed -e "/Mobicents Load Balancer/a\
         ## lb-configuration ##\n\
         gov.nist.javax.sip.PATCH_SIP_WEBSOCKETS_HEADERS=false\n\
         org.mobicents.ha.javax.sip.REACHABLE_CHECK=false\n\
         org.mobicents.ha.javax.sip.LoadBalancerHeartBeatingServiceClassName=org.mobicents.ha.javax.sip.MultiNetworkLoadBalancerHeartBeatingServiceImpl\n\
         ## lb-configuration ##"  $lb_sipstack_file > $lb_sipstack_file.bak

         mv $lb_sipstack_file.bak $lb_sipstack_file
        echo 'Load Balancer has been activated and mss-sip-stack.properties file updated'
    fi
}


configStandalone() {
	lb_standalone_file="$RESTCOMM_HOME/standalone/configuration/standalone-sip.xml"
	
	path_name='org.mobicents.ext'
	if [[ "$RUN_MODE" == *"-lb" ]]; then
		path_name="org.mobicents.ha.balancing.only"
	fi
	
	sed -e "s|subsystem xmlns=\"urn:org.mobicents:sip-servlets-as7:1.0\" application-router=\"configuration/dars/mobicents-dar.properties\" stack-properties=\"configuration/mss-sip-stack.properties\" path-name=\".*\" app-dispatcher-class=\"org.mobicents.servlet.sip.core.SipApplicationDispatcherImpl\" concurrency-control-mode=\"SipApplicationSession\" congestion-control-interval=\"-1\"|subsystem xmlns=\"urn:org.mobicents:sip-servlets-as7:1.0\" application-router=\"configuration/dars/mobicents-dar.properties\" stack-properties=\"configuration/mss-sip-stack.properties\" path-name=\"$path_name\" app-dispatcher-class=\"org.mobicents.servlet.sip.core.SipApplicationDispatcherImpl\" concurrency-control-mode=\"SipApplicationSession\" congestion-control-interval=\"-1\"|" $lb_standalone_file > $lb_standalone_file.bak
	mv -f $lb_standalone_file.bak lb_standalone_file
}



## MAIN
configSipStack 
#configStandalone



# The order of packages is significant as there are dependencies between
# the packages. Typically generated namespaces are used by other packages.
#PACKAGES = l3vpn l3vpnui
PACKAGES = sethostname

# The create-network argument to ncs-netsim
NETWORK = create-network packages/cisco-ios 1 c
#\
#		  create-network packages/cisco-iosxr 2 pe \
#		  create-network juniper-junos 1 pe \
#		  create-network cisco-iosxr 1 pe create-network cisco-iosxr 4 p

EMPTYFOLDER = state ncs-cdb logs

MKDIR = mkdir -p
GITEMPTYDIR = ~/bin/gitemptydir

NETSIM_DIR = netsim

all: build-all $(NETSIM_DIR)

build-all:
	for i in $(PACKAGES); do \
	  $(MAKE) -C packages/$${i}/src all || exit 1; \
	  done


fix-git-empty-dir:
	for i in $(PACKAGES); do \
	  ${MKDIR} packages/$${i}/load-dir ; \
	  ${MKDIR} packages/$${i}/shared-jar ; \
	  ${MKDIR} packages/$${i}/private-jar ; \
	  ${MKDIR} packages/$${i}/src/ncsc-out ; \
	  done
	for i in $(PACKAGES); do \
	  ${GITEMPTYDIR} packages/$${i}/load-dir ; \
	  ${GITEMPTYDIR} packages/$${i}/shared-jar ; \
	  ${GITEMPTYDIR} packages/$${i}/private-jar ; \
	  ${GITEMPTYDIR} packages/$${i}/src/ncsc-out ; \
	  done
	for i in $(EMPTYFOLDER); do \
	  ${MKDIR} $${i} ; \
	  done
	for i in $(EMPTYFOLDER); do \
	  ${GITEMPTYDIR} $${i} ; \
	  done

$(NETSIM_DIR): packages/cisco-ios
	#packages/cisco-iosxr packages/juniper-junos
	ncs-netsim --dir netsim $(NETWORK)
#	cp initial_data/ios.xml netsim/ce/ce0/cdb
	ncs-netsim ncs-xml-init > ncs-cdb/netsim_devices_init.xml


#Patch to add ios-stats
packages/cisco-ios:
	ln -s $(NCS_DIR)/packages/neds/cisco-ios packages/cisco-ios

#packages/juniper-junos:
#	ln -s $(NCS_DIR)/packages/neds/juniper-junos packages/juniper-junos

#packages/cisco-iosxr:
#	ln -s $(NCS_DIR)/packages/neds/cisco-iosxr packages/cisco-iosxr

clean:
	for i in $(PACKAGES); do \
	  $(MAKE) -C packages/$${i}/src clean || exit 1; \
	  done
	rm -rf netsim running.DB logs/* state/* ncs-cdb/*.cdb *.trace
	rm -f packages/cisco-ios
#	rm -f packages/juniper-junos
#	rm -f packages/cisco-iosxr
	rm -rf bin
	rm -rf ncs-cdb/*.xml


stop:
	-ncs-netsim stop
	-ncs --stop

start:
	ncs-netsim start
	ncs


reset:
	ncs-setup --reset


cli:
	ncs_cli -u admin



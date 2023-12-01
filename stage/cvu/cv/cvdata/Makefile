# Makefile for opsm/cv/cvdata
#
# Copyright (c) 1999, 2015, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#                  Makefile
#    DESCRIPTION
#        out header information
#    NOTES
#
#    Targets:
#    
#    MODIFIED   (MM/DD/YY)
#    iestrada    05/26/15 - call setup-sdxml in RDBMS label
#    iestrada    12/11/14 - proj 47212 software distribution
#    nvira       06/13/13 - add missing include
#    nvira       07/11/12 - add dirs to reference list
#    nvira       02/28/12 - bug fix 13777605
#    nvira       01/19/12 - add xsd validation for pluggable.xml
#    nvira       06/08/09 - update gen-sdxml target
#    shmubeen    03/24/09 - rename sw_config.xml to ora_software_cfg.xml
#    nvira       11/18/08 - pass macros file to software config generator
#    nvira       06/23/08 - rename gen-sdxml to setup-xml
#    nvira       06/17/08 - add target to verify prereq xml
#    nvira       04/03/08 - add target to generate cvu comp software xml config
#                           file

include $(SRCHOME)/opsm/opsm.mk
include $(SRCHOME)/opsm/cv/cvdata/cvdata.mk

DIR=$(SRCHOME)/opsm/cv/cvdata

SDXMLSCRIPT=$(SRCHOME)/opsm/misc/gen_sdxml.pl
MAPXMLXSD=$(SRCHOME)/buildtools/install/filemap.xsd
SDXMLFILE=$(DIR)/ora_software_cfg.xml
EXCLUDEFILE=$(DIR)/excludedFiles.txt
RELINKEDFILE=$(DIR)/relinkedFiles.txt
PLUGGABLEXMLXSD=$(SRCHOME)/cv/cvdata/pluggable.xsd
PLUGGABLEXML=$(SRCHOME)/cv/cvdata/pluggable.xml
CONFIGFILEPERMS=$(HASHOME)/install/crsconfig/crsconfig_fileperms.sbs
CONFIGDIRS=$(HASHOME)/install/crsconfig/crsconfig_dirs.sbs
CONFIGFILES=$(HASHOME)/install/crsconfig/crsconfig_files.sbs

DIRS= 

all: clean compile

compile: setup-sdxml verify-prereqxml verify-pluggablexml

clean:
	$(SILENT) $(RMF) $(SDXMLFILE)

#call ora_software_cfg.xml generator
setup-sdxml:
	$(SILENT) $(RMF) $(SDXMLFILE)
	$(PERL) $(SDXMLSCRIPT) -output $(SDXMLFILE) \
	-xsd $(MAPXMLXSD) -crsconfig_fileperms $(CONFIGFILEPERMS) \
	-crsconfig_dirs $(CONFIGDIRS) -crsconfig_files $(CONFIGFILES) \
	-exclude_list $(EXCLUDEFILE) -relinked_list $(RELINKEDFILE) 

verify-prereqxml:
	$(MAKE) -C 101/ verify-prereqxml
	$(MAKE) -C 102/ verify-prereqxml
	$(MAKE) -C 111/ verify-prereqxml
	$(MAKE) -C 112/ verify-prereqxml
	$(MAKE) -C 121/ verify-prereqxml

verify-pluggablexml:
	$(PERL) $(VERIFYPREREQXMLSCRIPT) $(PLUGGABLEXMLXSD) $(PLUGGABLEXML)

include $(SRCHOME)/buildtools/mkfile/node.mk

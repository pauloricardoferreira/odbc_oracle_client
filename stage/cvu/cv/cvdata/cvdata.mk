# Copyright (c) 2007, 2012, Oracle and/or its affiliates. All rights reserved. 

#
# NAME:          cvdata.mk
#
# DESCRIPTION:   It contains opsm definitions common on all platforms 
#                private to cvdata
# LOCATION:      $(SRCHOME)/opsm/cv/cvdata
# SCOPE:         local
# PORT SPECIFIC: no
#
#    MODIFIED   (MM/DD/YY)
#    nvira     02/28/12 - Fix bug 13695759


VERIFYPREREQXMLSCRIPT=$(SRCHOME)/opsm/misc/verify_prereqxml.pl
PREREQXMLXSD=$(SRCHOME)/cv/cvdata/prereq.xsd
CRSPREREQXML=crsinst_prereq.xml
DBCFGPREREQXML=dbcfg_prereq.xml
DBINSTPREREQXML=dbinst_prereq.xml
SIHASPREREQXML=sihainst_prereq.xml



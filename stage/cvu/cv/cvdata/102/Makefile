# Makefile for opsm/cv/cvdata
#
# Copyright (c) 1999, 2012, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#                  Makefile
#    DESCRIPTION
#       This file verifies prereq.xml schema consistency
#    NOTES
#
#    Targets:
#    
#    MODIFIED   (MM/DD/YY)
#    nvira       02/28/12 - creation

include $(SRCHOME)/opsm/opsm.mk
include $(SRCHOME)/opsm/cv/cvdata/cvdata.mk


verify-prereqxml:
	$(PERL) $(VERIFYPREREQXMLSCRIPT) $(PREREQXMLXSD) $(CRSPREREQXML)
	$(PERL) $(VERIFYPREREQXMLSCRIPT) $(PREREQXMLXSD) $(DBCFGPREREQXML)
	$(PERL) $(VERIFYPREREQXMLSCRIPT) $(PREREQXMLXSD) $(DBINSTPREREQXML)
	$(PERL) $(VERIFYPREREQXMLSCRIPT) $(PREREQXMLXSD) $(SIHASPREREQXML)

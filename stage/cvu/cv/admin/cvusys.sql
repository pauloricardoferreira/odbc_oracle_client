Rem
Rem $Header: opsm/cv/admin/cvusys.sql /main/3 2011/01/12 18:13:45 nvira Exp $
Rem
Rem cvusys.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      cvusys.sql - cvusys setup script
Rem
Rem    DESCRIPTION
Rem      cvusys and cvusapp creation and granting SELECT privileges 
Rem      on various tables used in cvu checks
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    agorla      09/28/10 - Created
Rem

DROP USER cvusys;
DROP ROLE cvusapp;

ACCEPT password  PROMPT 'Enter password for user cvusys ' HIDE

Rem *************************************
Rem Create user cvu sql.
Rem set verify off before 'create user' statement for not displaying 
Rem password for variable substitution 
Rem *****************************************

PROMPT 'Creating user cvusys...'
SET VERIFY OFF 
CREATE USER cvusys IDENTIFIED BY &password;
SET VERIFY ON
GRANT CREATE SESSION TO cvusys;

CREATE ROLE cvusapp;

GRANT cvusapp TO cvusys;

GRANT SELECT ON GV_$PARAMETER             TO cvusapp;
GRANT SELECT ON V_$PARAMETER              TO cvusapp;
GRANT SELECT ON GV_$INSTANCE              TO cvusapp;
GRANT SELECT ON DBA_OBJECTS               TO cvusapp;
GRANT SELECT ON DBA_ROLES                 TO cvusapp;
GRANT SELECT ON V_$TABLESPACE             TO cvusapp;
GRANT SELECT ON DBA_USERS                 TO cvusapp;
GRANT SELECT ON SYS.KOPM$                 TO cvusapp;
GRANT SELECT ON SYS.REGISTRY$             TO cvusapp;
GRANT SELECT ON V_$BACKUP                 TO cvusapp;
GRANT SELECT ON V_$DATAFILE               TO cvusapp;
GRANT SELECT ON V_$RECOVER_FILE           TO cvusapp;
GRANT SELECT ON DBA_2PC_PENDING           TO cvusapp;
GRANT SELECT ON SYS.OBJ$                  TO cvusapp;
GRANT SELECT ON SYS.KOTTD$                TO cvusapp;
GRANT SELECT ON SYS.COLTYPE$              TO cvusapp;
GRANT SELECT ON SYS.COL$                  TO cvusapp;
GRANT SELECT ON SYS.USER$                 TO cvusapp;
GRANT SELECT ON DBA_ROLE_PRIVS            TO cvusapp;
GRANT SELECT ON DBA_REGISTRY              TO cvusapp;
GRANT SELECT ON DBA_TABLES                TO cvusapp;
GRANT SELECT ON V_$SESSION                TO cvusapp;
GRANT SELECT ON V_$LOCK                   TO cvusapp;
GRANT SELECT ON DBA_JOBS                  TO cvusapp;
GRANT SELECT ON DBA_JOBS_RUNNING          TO cvusapp;
GRANT SELECT ON DBA_REFRESH_CHILDREN      TO cvusapp;
GRANT SELECT ON V_$DATABASE               TO cvusapp;
GRANT SELECT ON V_$LOG                    TO cvusapp;
GRANT SELECT ON DBA_TABLESPACES           TO cvusapp;
GRANT SELECT ON GV_$SYSSTAT               TO cvusapp;
GRANT SELECT ON GV_$CLUSTER_INTERCONNECTS TO cvusapp;
GRANT SELECT ON V_$ASM_DISK               TO cvusapp;
GRANT SELECT ON V_$SGASTAT                TO cvusapp;

FUNCTION apprtment()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"
  
  -- SET LOCK MODE TO WAIT   valid depending on database vendor  
 -- CLOSE WINDOW SCREEN
  OPEN WINDOW w1 WITH FORM "apprtment"

  MENU "Apprtment"
     COMMAND "find" 
      CALL query_dsg() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_dsg(1)
      ELSE
        MESSAGE "You must query first."
        -- hide the action when ON DIALOG available
       END IF
    COMMAND "previous"
      IF (query_ok) THEN
        CALL fetch_rel_dsg(-1)
      ELSE
        MESSAGE "You must query first."
      END IF
     COMMAND "Add"
      IF (inpupd_dsg("A")) THEN
        CALL insert_dsg()
      END IF
     COMMAND "Delete"
      IF (delete_check()) THEN
         CALL delete_dsg()
      END IF
      COMMAND "Modify" 
    IF inpupd_dsg("U") THEN
        CALL update_dsg()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
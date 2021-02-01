FUNCTION Owner()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"
  
  -- SET LOCK MODE TO WAIT   valid depending on database vendor  
  --CLOSE WINDOW SCREEN
  OPEN WINDOW w1 WITH FORM "Owner"

  MENU "Owner"
     COMMAND "find" 
      CALL query_ow() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_ow(1)
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
      IF (inpupd_ow("A")) THEN
        CALL insert_ow()
      END IF
     COMMAND "Delete"
      IF (delete_check_ow()) THEN
         CALL delete_ow()
      END IF
      COMMAND "Modify" 
    IF inpupd_dsg("U") THEN
        CALL update_ow()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
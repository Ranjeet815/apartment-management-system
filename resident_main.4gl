FUNCTION resident()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"
  
 
  --CLOSE WINDOW SCREEN
  OPEN WINDOW w1 WITH FORM "resident"

  MENU "Resident"
     COMMAND "find" 
      CALL query_rst() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_rst(1)
      ELSE
        MESSAGE "You must query first."
        -- hide the action when ON DIALOG available
       END IF
    COMMAND "previous"
      IF (query_ok) THEN
        CALL fetch_rel_rst(-1)
      ELSE
        MESSAGE "You must query first."
      END IF
     COMMAND "Add"
      IF (inpupd_rst("A")) THEN
        CALL insert_rst()
      END IF
     COMMAND "Delete"
      IF (delete_check_rst()) THEN
         CALL delete_rst()
      END IF
      COMMAND "Modify" 
    IF inpupd_rst("U") THEN
        CALL update_rst()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
FUNCTION helpdesk()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"
  
 --CLOSE WINDOW SCREEN
  OPEN WINDOW w1 WITH FORM "helpdesk"

  MENU "helpdesk"
     COMMAND "find" 
      CALL query_hpt() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_hpt(1)
      ELSE
        MESSAGE "You must query first."
        -- hide the action when ON DIALOG available
       END IF
    COMMAND "previous"
      IF (query_ok) THEN
        CALL fetch_rel_hpt(-1)
      ELSE
        MESSAGE "You must query first."
      END IF
     COMMAND "Add"
      IF (inpupd_hpt("A")) THEN
        CALL insert_hpt()
      END IF
     COMMAND "Delete"
      IF (delete_check_hpt()) THEN
         CALL delete_hpt()
      END IF
      COMMAND "Modify" 
    IF inpupd_hpt("U") THEN
        CALL update_hpt()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
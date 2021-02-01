FUNCTION association()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"
  
 
  --CLOSE WINDOW SCREEN
  OPEN WINDOW w1 WITH FORM "association"

  MENU "association"
     COMMAND "find" 
      CALL query_ass() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_ass(1)
      ELSE
        MESSAGE "You must query first."
        -- hide the action when ON DIALOG available
       END IF
    COMMAND "previous"
      IF (query_ok) THEN
        CALL fetch_rel_ass(-1)
      ELSE
        MESSAGE "You must query first."
      END IF
     COMMAND "Add"
      IF (inpupd_ass("A")) THEN
        CALL insert_ass()
      END IF
     COMMAND "Delete"
      IF (delete_check_ass()) THEN
         CALL delete_ass()
      END IF
      COMMAND "Modify" 
    IF inpupd_ass("U") THEN
        CALL update_ass()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
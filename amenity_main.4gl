FUNCTION amenity()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"

  OPEN WINDOW w1 WITH FORM "amenity"

  MENU "amenity"
     COMMAND "find" 
      CALL query_amy() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_amy(1)
      ELSE
        MESSAGE "You must query first."
        -- hide the action when ON DIALOG available
       END IF
    COMMAND "previous"
      IF (query_ok) THEN
        CALL fetch_rel_amy(-1)
      ELSE
        MESSAGE "You must query first."
      END IF
     COMMAND "Add"
      IF (inpupd_amy("A")) THEN
        CALL insert_amy()
      END IF
     COMMAND "Delete"
      IF (delete_check_amy()) THEN
         CALL delete_amy()
      END IF
      COMMAND "Modify" 
    IF inpupd_amy("U") THEN
        CALL update_amy()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
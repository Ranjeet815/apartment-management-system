FUNCTION payment()
DEFINE query_ok SMALLINT
DEFINE arr_index INT 

DEFER INTERRUPT
LET arr_index = 1
  CONNECT TO "aptapp"
  
  -- SET LOCK MODE TO WAIT   valid depending on database vendor  
 -- CLOSE WINDOW SCREEN
  OPEN WINDOW w1 WITH FORM "payment"

  MENU "Payments"
     COMMAND "find" 
      CALL query_pmt() RETURNING query_ok
    COMMAND "next"           
      IF (query_ok) THEN
        CALL fetch_rel_pmt(1)
      ELSE
        MESSAGE "You must query first."
        -- hide the action when ON DIALOG available
       END IF
    COMMAND "previous"
      IF (query_ok) THEN
        CALL fetch_rel_pmt(-1)
      ELSE
        MESSAGE "You must query first."
      END IF
     COMMAND "Add"
      IF (inpupd_pmt("A")) THEN
        CALL insert_pmt()
      END IF
     COMMAND "Delete"
      IF (delete_check_pmt()) THEN
         CALL delete_pmt()
      END IF
      COMMAND "Modify" 
    IF inpupd_pmt("U") THEN
        CALL update_pmt()
      END IF
      COMMAND "quit" 
      EXIT MENU
  END MENU
  
  CLOSE WINDOW w1
 
  DISCONNECT CURRENT

END FUNCTION 
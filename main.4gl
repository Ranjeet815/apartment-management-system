{GLOBALS 
 DEFINE password SMALLINT 
 
END GLOBALS}

MAIN
    CLOSE WINDOW SCREEN
    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP
--LET password = 12
 -- PROMPT "Please enter your Password: " FOR password ATTRIBUTES (INVISIBLE ) 
 -- IF password THEN
   -- DISPLAY "Enter your password." || password 
 -- ELSE
  --  DISPLAY "  enter correct password: "  
  --END IF

CALL ui.Interface.loadStyles("test")
   --CLOSE WINDOW SCREEN
    OPEN WINDOW apt_app WITH FORM "main" ATTRIBUTES(TEXT="Apprtment")

    
    MENU "Apprtment Management System"
        BEFORE MENU
    ON ACTION apprtment ATTRIBUTES(TEXT="Apprtment")
            CALL apprtment()

    ON ACTION Owner ATTRIBUTES(TEXT="Owner")
            CALL Owner()
            
    ON ACTION resident ATTRIBUTES(TEXT="Resident")
          CALL resident()
    
  ON ACTION payment ATTRIBUTES(TEXT="Payment")
          CALL payment()
            
     ON ACTION amenity ATTRIBUTES(TEXT="Amenity")
            CALL amenity()
     ON ACTION association ATTRIBUTES(TEXT="Association")
            CALL association()
            

    ON ACTION helpdesk ATTRIBUTES(TEXT="Helpdesk")
            CALL helpdesk()
        
            ON ACTION CANCEL
            
            EXIT MENU
           
CLOSE WINDOW apt_app
            
    END MENU
END MAIN
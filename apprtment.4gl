SCHEMA aptapp

DEFINE  dr_dsgrec RECORD
     block LIKE apprtment.block,
     floor LIKE apprtment.floor,
     unit_num LIKE apprtment.unit_num,
     zise_sqft DECIMAL (16, 2)
    END RECORD,
    work_dsgrec RECORD
    block LIKE apprtment.block,
     floor LIKE apprtment.floor,
     unit_num LIKE apprtment.unit_num,
     zise_sqft DECIMAL (16, 2)
    END RECORD

FUNCTION query_dsg()
  DEFINE cont_ok         SMALLINT,
         dsg_cnt    SMALLINT,
         where_clause STRING

  MESSAGE "Enter search apprtment criteria"
  LET cont_ok = FALSE
  LET int_flag = FALSE
  
  CONSTRUCT BY NAME where_clause ON apprtment.*
                             
  IF (int_flag) = TRUE THEN
    LET int_flag=FALSE
    CLEAR FORM
    LET cont_ok = FALSE
    MESSAGE "Canceled by user."
  ELSE      
    CALL get_dsg_cnt(where_clause)
           RETURNING dsg_cnt
    IF (dsg_cnt > 0) THEN
       MESSAGE dsg_cnt using "<<<<", " rows found."
       CALL dsg_select(where_clause)
          RETURNING cont_ok
    ELSE
       MESSAGE "No rows found."
       LET cont_ok = FALSE    
    END IF
  END IF
 
    IF (cont_ok) THEN
      CALL display_dsg()
    END IF
    
    RETURN cont_ok
 
END FUNCTION

FUNCTION get_dsg_cnt(p_where_clause)
  DEFINE p_where_clause   STRING,
         sql_text         STRING,
         dsg_cnt        SMALLINT
         
  
  LET sql_text = "SELECT COUNT(*) FROM apprtment WHERE " || p_where_clause CLIPPED
  
  WHENEVER ERROR CONTINUE
  PREPARE dsg_cnt_stmt FROM sql_text
  EXECUTE dsg_cnt_stmt INTO dsg_cnt
  FREE dsg_cnt_stmt
  WHENEVER ERROR STOP
  
  IF SQLCA.SQLCODE <> 0 THEN
    LET dsg_cnt = 0
    ERROR SQLERRMESSAGE
  END IF
  
  RETURN dsg_cnt
  
END FUNCTION
  
FUNCTION dsg_select(p_where_clause) 
  DEFINE p_where_clause  STRING,
         sql_text        STRING,
         fetch_ok        SMALLINT
 
  LET sql_text = "SELECT * FROM apprtment WHERE "  ||
        p_where_clause clipped 
  

  DECLARE dsg_curs SCROLL CURSOR WITH HOLD FROM sql_text  
  
  OPEN dsg_curs
  CALL fetch_dsg(1)        --fetch the first row
     RETURNING fetch_ok
  IF NOT (fetch_ok) THEN
     MESSAGE "no rows in table."   -- someone deleted the rows after we checked the count
  END IF
      
  RETURN fetch_ok
 
END FUNCTION
 


FUNCTION fetch_dsg (p_fetch_flag)
  DEFINE p_fetch_flag SMALLINT,
         fetch_ok     SMALLINT
         
   LET fetch_ok = TRUE
   WHENEVER ERROR CONTINUE
   IF p_fetch_flag = 1 THEN
     FETCH NEXT dsg_curs
       INTO dr_dsgrec.*
   ELSE
     FETCH PREVIOUS dsg_curs
       INTO dr_dsgrec.*
   END IF
   
  CASE
  WHEN (SQLCA.SQLCODE = 0)
      LET fetch_ok = TRUE
  WHEN (SQLCA.SQLCODE = NOTFOUND)
     LET fetch_ok = FALSE
  WHEN (SQLCA.SQLCODE < 0)
     LET fetch_ok = FALSE
     MESSAGE " Error ", SQLCA.SQLCODE USING "<<<<"
  END CASE
  
  RETURN fetch_ok
  
END FUNCTION



FUNCTION fetch_rel_dsg(p_fetch_flag)
  DEFINE p_fetch_flag SMALLINT,
         fetch_ok     SMALLINT
   
  MESSAGE " "       
  CALL fetch_dsg(p_fetch_flag)
    RETURNING fetch_ok
    
  IF (fetch_ok) THEN
    CALL display_dsg()
  ELSE
    IF (p_fetch_flag = 1) THEN
      MESSAGE "End of list"
    ELSE
      MESSAGE "Beginning of list"
    END IF
  END IF
    
 END FUNCTION
 




 FUNCTION display_dsg()
  DISPLAY BY NAME dr_dsgrec.*
END FUNCTION
 


 
 FUNCTION inpupd_dsg(au_flag)  
  DEFINE au_flag  CHAR(1),
         cont_ok  SMALLINT
        
  LET cont_ok = TRUE 
  INITIALIZE work_dsgrec.* TO NULL      
  
  IF (au_flag = "A") THEN  
    MESSAGE "Add a new apprtment "
    LET dr_dsgrec.* = work_dsgrec.*   -- this is an add, set program record to null 
  ELSE
    MESSAGE "Update apprtment"
    LET work_dsgrec.* = dr_dsgrec.*   -- this is an update, save original 
  END IF
   
  LET int_flag = FALSE
  
  INPUT BY NAME dr_dsgrec.* WITHOUT DEFAULTS ATTRIBUTE (UNBUFFERED) 
  
  BEFORE FIELD block
      IF au_flag = "U" THEN
    NEXT FIELD floor
    END IF
  
   ON CHANGE block   
      IF au_flag = "A" THEN
         WHENEVER ERROR CONTINUE 
         SELECT  block,
                 floor,
                 unit_num,
                 zise_sqft
               
            INTO dr_dsgrec.*
            FROM apprtment
            WHERE block = dr_dsgrec.block
          WHENEVER ERROR STOP     
          IF (SQLCA.SQLCODE = 0) THEN
             ERROR "apprtment number already in database."
             LET cont_ok = FALSE
             CALL display_dsg()
             EXIT INPUT
          END IF
      END IF      
      
ON CHANGE floor
     IF (dr_dsgrec.floor IS NULL) THEN
        ERROR "You must enter a apprtment name."
        NEXT FIELD floor
     END IF 
    
  END INPUT
 
  IF (int_flag) THEN
    LET int_flag = FALSE
    LET cont_ok = FALSE
    MESSAGE "Operation cancelled by user." 
    LET dr_dsgrec.* = work_dsgrec.* 
  END IF
       
  RETURN cont_ok
  
END FUNCTION


FUNCTION insert_dsg()

 WHENEVER ERROR CONTINUE   
 INSERT INTO apprtment (block,
                      floor,
                      unit_num,
                      zise_sqft)
                
                    
     VALUES (dr_dsgrec.*)
  WHENEVER ERROR STOP
  
  IF SQLCA.SQLCODE = 0 THEN
     MESSAGE "Row added"
  ELSE
     ERROR SQLERRMESSAGE
  END IF
     
                       
END FUNCTION

FUNCTION update_dsg()
  DEFINE l_dsgrec RECORD
  
      block LIKE apprtment.block,
       floor LIKE apprtment.floor,
       unit_num LIKE apprtment.unit_num,
       zise_sqft LIKE apprtment.zise_sqft
     
    END RECORD,
    matches INTEGER,
    cont_ok INTEGER
    
  LET matches = FALSE
  LET cont_ok = FALSE
       
  BEGIN WORK
  WHENEVER ERROR CONTINUE
  SELECT block,            --select the row to lock it
         floor,            
         unit_num,
         zise_sqft
                     
       
     INTO l_dsgrec.* FROM apprtment 
     WHERE block = dr_dsgrec.block FOR UPDATE
   WHENEVER ERROR STOP 
       
   IF SQLCA.SQLCODE = NOTFOUND THEN       
      ERROR "apprtment has been deleted"
      LET cont_ok = FALSE
    ELSE                      -- compare records
      IF l_dsgrec.* = work_dsgrec.* THEN
        LET matches = TRUE      
      ELSE
        LET matches = FALSE
      END IF
    
      IF matches = TRUE THEN     
        WHENEVER ERROR CONTINUE
        UPDATE apprtment SET  floor = dr_dsgrec.floor,
                               floor = dr_dsgrec.floor,
                               unit_num = dr_dsgrec.unit_num,
                               zise_sqft = dr_dsgrec.zise_sqft
                      WHERE block = dr_dsgrec.block
        WHENEVER ERROR STOP  
        IF SQLCA.SQLCODE = 0 THEN
            LET cont_ok = TRUE
            MESSAGE "Row updated"
        ELSE
           LET cont_ok = FALSE
           ERROR SQLERRMESSAGE
        END IF 
     ELSE
       LET cont_ok = FALSE
       LET dr_dsgrec.* = l_dsgrec.*      -- replace with latest values retrieved
       DISPLAY BY NAME dr_dsgrec.*         -- remove this for UNBUFFERED
       MESSAGE "Row updated by another user."
     END IF
  END IF
     
  IF cont_ok = TRUE
    THEN COMMIT WORK
  ELSE
      ROLLBACK WORK
  END IF
                    
END FUNCTION

FUNCTION delete_dsg()
  DEFINE del_ok SMALLINT
  
    WHENEVER ERROR CONTINUE
    DELETE FROM apprtment WHERE block = dr_dsgrec.block
    WHENEVER ERROR STOP
    IF SQLCA.SQLCODE = 0 THEN
       MESSAGE "Row deleted"
       INITIALIZE dr_dsgrec.* TO NULL
       DISPLAY BY NAME dr_dsgrec.* 
    ELSE
      ERROR SQLERRMESSAGE
    END IF 
 
 END FUNCTION   

FUNCTION delete_check()
  DEFINE del_ok SMALLINT,
         del_count SMALLINT
  
  LET del_ok = FALSE
    
  WHENEVER ERROR CONTINUE
  SELECT COUNT(*) INTO del_count FROM ORDERS 
    WHERE orders.block = dr_dsgrec.block
  WHENEVER ERROR STOP
  
  IF del_count > 0 THEN
    MESSAGE "Owner has orders and cannot be deleted"
    LET del_ok = FALSE
  ELSE
    MENU  "Delete" ATTRIBUTE ( STYLE="dialog", COMMENT="Delete the row?" )
    COMMAND "Yes"
      LET del_ok = TRUE
      EXIT MENU
    COMMAND "No"
      MESSAGE "Delete canceled"
      EXIT MENU
    END MENU
  END IF
    
  RETURN del_ok
  
END FUNCTION


FUNCTION clean_up()
 
   WHENEVER ERROR CONTINUE
    CLOSE dsg_curs
    FREE dsg_curs
   WHENEVER ERROR STOP
 
 END FUNCTION  
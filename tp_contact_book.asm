; multi-segment executable file template.

data segment
    ; add your data here!
    
    
    ;-------------------------CONTACT ARRAY-------------------------------------
    
    contact_array db 16*22 dup(0)   ; 10 bytes for name , 1 for $ , same for phone
    
    contact_counter db 0
    
    ;-------------------------BUFFER--------------------------------------------
    
    buffer db 11
           db 0
           db 11 dup('$')
    
    ;-------------------------TEMP ARRAY----------------------------------------
    
    temp1 db 11 dup('$')
    temp2 db 11 dup('$')
    
    ;-------------------------PROC MESSAGES-------------------------------------
       p_error db 13,10,"Phone contains a char !! , try again ...",13,10,'$' 
       p_error2 db 13,10,"Phone is less than 10 numbers !! , try again ...",13,10,'$'
    ;-------------------------ADD CONTACT
    
     enter_name db 13,10,"Enter name of contact",13,10,'$'
     enter_phone db 13,10,"Enter phone of contact",13,10,'$' 
     same db 13,10,"The contact already exist exiting ",13,10,'$'
     success  db 13,10,"The contact is added successfully ",13,10,'$'
     full db 13,10,"The contact book is full ",13,10,'$'
              
    
    ;-------------------------SEARCH CONTACT
    
     empty db 13,10,"Contact Book is empty",13,10,'$'
     n_found db 13,10,"Contact doesn't exist ",13,10,'$'
     s_msg db 13,10,"Enter the name to serch for : ",13,10,'$'
    ;-------------------------DISPLAY
     d_m db 13,10,"Contact name : $"
     d_m2 db 13,10,"Contact phone : $"
    
    ;-------------------------MODIFY
    
     mod db 13,10,"Contact modified successfully :",13,10,'$'
     num db 13,10,"Enter new phone number :",13,10,'$'
     mod2 db 13,10,"Enter the name of the contact you want to delete: ",13,10,'$'
    
    ;-------------------------DELETE
  
     del db 13,10,"Contact deleted successfully ",13,10,'$'
     del2 db 13,10,"Enter the name of the contact you want to delete: ",13,10,'$'
    
    ;-------------------------NEW LINE
    
    new db 13,10,'$'
    
    ;-------------------------menu messages-------------------------------------
    
    m1 db 13,10,"---------Contact Book--------------",13,10,'$'
    m2 db 13,10,"1. Add contact",13,10,'$'
    m3 db 13,10,"2. Search contatct",13,10,'$'
    m4 db 13,10,"3. Display all",13,10,'$'
    m5 db 13,10,"4. Modify contact",13,10,'$' 
    m6 db 13,10,"5. Delete contact",13,10,'$'
    m7 db 13,10,"6. EXIT ",13,10,'$'
    m8 db 13,10,"---------------------------------",13,10,'$' 
    err db 13,10,"Choice out of bounds, try again...",13,10,'$'
    pkey db 13,10,"press any key...$"
     
ends

stack segment
    dw   128  dup(0)
ends

code segment
    
RESET_BUFFER PROC ; reseting buffer for new input
    
    MOV AL,'$'
    MOV [buffer+1],0
    cld
    lea di,[buffer+2]
    mov cx,11
    rep stosb
    ret
    
endp RESET_BUFFER


READ_NAME PROC   ; reads the name and store it in temp1
    
     CALL RESET_BUFFER
          
     lea dx, buffer
     mov ah,10
     int 21h
     
     lea si, [buffer+2]
     lea di, temp1
     mov cx, 10
     
     rep movsb
     ret
     
endp READ_NAME


TREAT_NAME PROC   ; treating uppercase to make all of chars in lower case
    
     lea si,temp1 ; name stored in temp1
     
     treat:
     cmp [si],0dh  ; because our temp1 ends with ret (of enter key)
     je treated
     cmp [si],'$'  ; just in case 
     je treated
     
     cmp [si], 41h ; cheking if the char is an upper case letter
     jae upper_bound
     upper_bound:
     cmp [si], 5Ah
     jbe change_char
     jmp next
     
     change_char:
     mov ax, [si]  ; adding 20h to make it in lower case because 'a'-'A' = 20h
     add ax, 20h
     mov [si],ax
     next:    ; treating next char
     inc si
     jmp treat 
     
     treated:
     ret
endp TREAT_NAME





READ_PHONE PROC  
    
     CALL RESET_BUFFER  ; reset buffer for input
     
     read_number:
        lea dx, buffer  ; reading phone
        mov ah,10
        int 21h
 
        lea si,[buffer+2] ; where the phone starts
        mov cl,[buffer+1] ; counter of how much char was entered in buffer
        cmp cl,10 ; check if less than 10 numbers  
        jl not_complete
         
        mov ch,0
        
        
        
    verifie_digit:   ; verify that the phone number contains only digits
        cmp [si],'0'
        jb not_digit ; check if the this character is not a digit 
        cmp [si],'9'
        ja not_digit ; 
        inc si
        loop verifie_digit    
        jmp valid_number
        
        
    not_digit: ; Invalid character found
 
        lea dx,p_error ;message indicating that the number contains a character      
        mov ah,9
        int 21h
       
        jmp read_number
        
    not_complete: ; the phone number contains less than 10 digits
       
        lea dx,p_error2 ;message indicating that the number contains less than 10 digits
        mov ah,9
        int 21h
        
        jmp read_number  ;jump to enter the phone number again
        
              
    valid_number:
        lea si,[buffer+2]  ; copy number to temp2
        lea di, temp2   
        mov cx,10
        rep movsb
     ret
     
endp READ_PHONE


ADD_CONTACT PROC
     
    lea dx, enter_name ; message 
    mov ah,09h
    int 21h
    
    
    CALL READ_NAME ;then TEMP1 CONATIN THE NAME
    CALL TREAT_NAME
    mov cl,[contact_counter] ; INDEX
    mov ch,0
 
    cmp cl,16  ; check if contact book is full 
    je full_book
    
    cmp cl,0 ; if contact book is empty save at first position
    je first_contact 
    
    xor bx,bx  ; we will use bx as index
    
    WHILE: ;loop to find position for new contact ( sorting names alphabetically )
    
         cmp bl, [contact_counter] ; comparing to see if we reached the end
         jae at_end
         
         mov al,22 ; calculating offset
         mov ah,0
         mul bl  
         
         push bx ; pop last , saving our index
         
         mov bx,ax
          
         lea si,temp1 
         push si  ;pop second 
         
         lea di,[contact_array+bx] ; bx is offset of target position
         push di  ;pop first
         
         mov cx,10  ;compare names
         repe cmpsb
         je same_name ; if it is the same name 
         
         mov dl, [si-1] ; check last char in new contact if it is before or after the last char compared in the contact in the array 
         cmp dl, [di-1] ; -1 because cmpsb increments si di , even if not equal   
         
         
         jb first_order ; the position is of the current offset
         jmp compare_next ; position not in the current offset
         ;------------------------------------------------------------
         first_order:
         push bx
         ; calculate total bytes to shift
         mov bl, [contact_counter]
         mov al, 22
         mul bl
         mov cx, ax  ; total bytes used in array
         pop bx
         sub cx, bx  ; CX = bytes to shift (total - current position)
         mov bx, ax
    
         ; set up source and destination pointers
         lea si, [contact_array + bx -1 ] ; offset -1 last entered byte for last contact
         lea di, [contact_array + bx+ 21] ; where we should copy 
    
         ; shift memory down
         std           ; move backward
         rep movsb     ; shift all bytes down
         cld           ; restore forward direction
    
         ; now copy the new contact into the empty slot
         pop di              ; [contact_array+target]
         pop si              ; temp1 
         mov cx, 10
        rep movsb           ; Copy name
    
         mov [di], '$'   ; add $ to indicate end of name
         inc di
         push di         ; save position for entering phone later
    
         lea dx,enter_phone
         mov ah,09h
         int 21h
     
         call READ_PHONE ; phone is in temp2
         
         lea si, temp2
         pop di   ; position for phone
    
         mov cx, 10
         rep movsb           ; Copy phone
         mov [di], '$'
         pop bx
         jmp end_while
         
         compare_next:
         pop di
         pop si
         pop bx ; the fist one we pushed  
         inc bx ; inc index
         jmp WHILE 
         
         at_end:
         ; we reached the end
         mov al,22  ; calculate offset
         mov ah,0
         mul bl
         mov bx,ax
         
         lea si,temp1   ; move to memory
         lea di,[contact_array+bx]
         
         mov cx,10
         rep movsb 
         
         mov [di],'$' ; add $ to indicate end of name
         inc di
         push di ; position for phone
         
         lea dx,enter_phone
         mov ah,09h
         int 21h
          
         call READ_PHONE
         lea si, temp2
         pop di  ; restore phone position
         
         mov cx,10 ; copy to memory
         rep movsb
         MOV [di], '$'
         jmp end_while 
         
         same_name: 
         
         pop di
         pop si
         pop bx
         
         lea dx, same
         mov ah,9
         int 21h  
         
         jmp fin_1 
         
         full_book:
         lea dx, full
         mov ah,09h
         int 21h 
         jmp fin_1
         
         first_contact:  ; inserting at beggining of array
         lea si,temp1
         lea di,[contact_array]
         mov cx,10
         rep movsb

         mov [di],'$'  
         
         push di
         
         lea dx,enter_phone
         mov ah,09h
         int 21h
         
         Call READ_PHONE
         CALL RESET_BUFFER
         
         lea si,temp2
         pop di
         inc di 
         mov cx,10
         rep movsb
         
         mov [di],'$'
         
         jmp end_while      
         
         
         end_while: 
         ; increment contact counter
         inc contact_counter
         lea dx, success
         mov ah,9
         int 21h 
         
         fin_1:
         ret
endp ADD_CONTACT

DISPLAY PROC ; we push effective address first
    PUSH BP
    MOV BP,SP 
    
    MOV BX, [BP+4]  ; restore effective address of contact
    
    
    
    mov ah,09h
    lea dx,d_m   ; message
    int 21h 
    
    mov dx,bx   ; contact name
    int 21h  
    
    lea dx,new  ;new_line
    int 21h 
    
    lea dx,d_m2  ; phone _message
    int 21h 
    
    lea dx, [bx+11]   ; contatc phone
    int 21h
    
    pop bp     ;restore bp
    
    
    RET
    ENDP DISPLAY ; pop effective address after

SEARCH PROC 
     mov al,[contact_counter] ; check if our book is empty
     cmp al,0
     je empty_book
     
     lea dx, s_msg   ; search messsage
     mov ah,09h
     int 21h
     
     call READ_NAME ;temp1 contains name
     call TREAT_NAME; treat uppercase
     
     xor bx,bx  ; use bx as index like add_contact
     while2:    ;loop to find  contact
     
     cmp bl,[contact_counter] ; check if we reached the end
     je not_found
     
     push bx ; save index
     mul bl
     mov bx,ax ; our offset we don't care about initializing ax first time because bx = 0  
     
     lea si,temp1   ; comparing names
     lea di,[contact_array+bx]
     mov cx,10
     rep cmpsb
     
     je found
     ;compare next:
     mov al,22  ; initialize for multiplication
     mov ah,0
     xor dx,dx
     pop bx
     inc bl 
     jmp while2
     empty_book:
      lea dx, empty
      mov ah,09h
      int 21h
      jmp fin_2
     found:
     lea bx,[contact_array+bx]
     push bx
     call DISPLAY
     pop bx
     pop bx
     jmp fin_2
     not_found:
 
     lea dx,n_found
     mov ah,09h
     int 21h
     jmp fin_2
     
         
    fin_2:
    RET
ENDP SEARCH  

DELETE PROC 
    mov al,[contact_counter]
    CMP al,0
    JE empty_book2
    
    lea dx, del2
    mov ah,09h
    int 21h
    
    call READ_NAME
    CALL TREAT_NAME
    
    
     xor bx,bx  ; index
     while3:; loop to find name
     cmp bl,[contact_counter]; check if we reached the end
     je not_found2
     push bx   ; save index
     
     mul bl
     mov bx,ax ; offset
     lea si,temp1
     lea di,[contact_array+bx]
     mov cx,10
     rep cmpsb
     je found2
     ;compare next:
     mov al,22  ; intitiallize for mul
     mov ah,0
     xor dx,dx
     pop bx
     inc bl ; increment index
     jmp while3
     empty_book2:
      lea dx, empty
      mov ah,09h
      int 21h
      jmp fin_3
     found2:
     lea di,[contact_array+bx]      ; shifting contacts up 
     lea si,[contact_array+bx+22]
     
     ; calculating how many bytes to shift
      
     mov al, 22   
     mov ah,0
     xor dx,dx
     mul [contact_counter]
     mov cx, ax ;total bytes 
     sub cx,bx  ;total bytes - offset
     rep movsb  ; shift up
     dec byte ptr contact_counter; decrement our counter
     pop bx  ; pop index 
     
     lea dx,del
     mov ah,9
     int 21h
     
     jmp fin_3
     not_found2:
 
     lea dx,n_found
     mov ah,09h
     int 21h
     jmp fin_3
     fin_3:
    RET
ENDP DELETE


MODIFY PROC
    MOV AL, [contact_counter]
    cmp al,0 
    je empty_book3
    
    lea dx, mod2
    mov ah,09h
    int 21h
    
    call READ_NAME ;temp1 contains name
    CALL TREAT_NAME  ; treat uppercase
    
    xor bx,bx  ; index
     while4:  ; loop to find contact
     
     cmp bl,[contact_counter]
     je not_found3 
     
     push bx; save index 
     mul bl
     mov bx,ax ; offset
     lea si,temp1
     lea di,[contact_array+bx]
     mov cx,10
     rep cmpsb
     je found3
     ;compare next:
     mov al,22 ; intitiallize for mul
     mov ah,0
     xor dx,dx
     pop bx
     inc bl  ;increment index
     jmp while4
     empty_book3:
      lea dx, empty
      mov ah,09h
      int 21h
      jmp fin_4
     found3:
     lea dx,num   ; print message
     mov ah,9
     int 21h
     call READ_PHONE
     
     lea si,temp2
     lea di,[contact_array+bx+11]
     mov cx,10
     rep movsb
      
     pop bx ; pop index 
     
     lea dx,mod
     mov ah,9
     int 21h
     
     jmp fin_4
     not_found3:
 
     lea dx,n_found
     mov ah,09h
     int 21h
     jmp fin_4
     fin_4:
    RET
ENDP MODIFY
    
VIEW_ALL PROC
    mov al, [contact_counter]
    cmp al, 0
    je book_empty 
    jmp start_dis
    
    book_empty:
    lea dx, empty
    mov ah,09h
    int 21h
    jmp fin_5
    start_dis:
    xor bx,bx ; index
    dis_loop:
    cmp bl,[contact_counter] ; check if ew reached the end
    jae fin_4  
    
    xor ax,ax
    xor dx,dx
    mov al,22
    push bx ; save index
    mul bl
    mov bx,ax
    lea bx,[contact_array+bx] ; effective address of contact
    push bx  ;push address for display proc
    
    call DISPLAY
    
    lea dx, new
    mov ah,09h 
    int 21h
    
    POP bx  ; pop effective address
    pop bx ; pop index
    inc bx  ; increase index
    jmp dis_loop
    
    fin_5:
     ret
     endp VIEW_ALL
    
    
            
                  
                  
 
MAIN PROC
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    cld
    ; add your code here
    
    main_start:
       
    call MENU
    mov ah,1
    int 21h
    
    SUB AL,'0'
    
    cmp al,1
    jb ERROR 
    
    cmp al,6
    ja ERROR
    
    cmp al,1
    je case1
    
    cmp al,2
    je case2
    
    cmp al,3
    je case3
    
    cmp al,4
    je case4
    
    cmp al,5
    je case5
    
    cmp al,6
    je case6
    
    case1:
    call ADD_CONTACT
    CALL WAIT_P
    JMP main_start 
    
    case2:
    call SEARCH
    CALL WAIT_P
    JMP main_start
    
    case3:
    CALL VIEW_ALL
    CALL WAIT_P
    JMP main_start
    
    case4:
    CALL MODIFY
    CALL WAIT_P
    JMP main_start
    
    case5:
    CALL DELETE
    CALL WAIT_P
    JMP main_start
    
    case6:
    JMP exit
    
  
    ERROR:
    lea dx,err
    mov ah,9
    int 21h
    CALL WAIT_P
    jmp main_start
            
    
    
    
    
    exit:
    mov ax, 4c00h ; exit to operating system.
    int 21h
    ENDP MAIN    
ends 

WAIT_P PROC
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    ; wait for any key....    
    mov ah, 1
    int 21h
    RET
ENDP WAIT_P


MENU PROC    ; display menu
    MOV AH,9
    lea dx,m1
    int 21h
    lea dx, m2
    int 21h
    lea dx, m3
    int 21h
    lea dx, m4
    int 21h
    lea dx, m5
    int 21h
    lea dx, m6
    int 21h
    lea dx,m7
    int 21h
    lea dx,m8
    int 21h
    
    RET
    ENDP MENU

end MAIN ; set entry point and stop the assembler.

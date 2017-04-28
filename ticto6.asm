.model small
draw_row macro x ;draws rows of main grid
    local lr
    ; draws a line in row x from col 170 to col 472
    mov ah, 0ch
    mov al, 4
    mov cx, 170d
    mov dx, x
lr: 
    int 10h
    inc cx
    cmp cx, 472d
    jle lr
    endm

draw_col macro y ;draws columns of main grid
    local lc
    ; draws a line col y from row 0 to row 150
    mov ah, 0ch
    mov al, 4
    mov cx, y
    mov dx, 0d
lc: 
    int 10h
    inc dx
    cmp dx, 300d
    jle lc
    endm

draw_r_b macro s, t ;draws rows of box of given color
    local lrw
    ; draws a line in row p_row from col s to col t
    
    mov ah, 0ch
    mov cx, s
    mov dx, p_row
lrw: 
    int 10h
    inc cx
    cmp cx, t
    jle lrw
    endm

draw_c_b macro p, q ;draws columns of box of given color
    local lcw
    ; draws a line in col p_col from row p to row q
    mov ah, 0ch
    mov cx, p_col
    mov dx, p
lcw: 
    int 10h
    inc dx
    cmp dx, q
    jle lcw
    endm

draw_left_X macro m, n ;draws from the left of X from row m to n
    local crs1
    mov ah, 0ch
    mov bx, p_row
    mov dx, p_row
    add dx, 10d
    add bx, 90d    
crs1:
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    inc cx
    int 10h
    cmp dx, bx
    jle crs1
    endm

draw_right_X macro a, b ;draws from the right of X from row a, b
    local crs2
    mov ah, 0ch
    mov bx, p_row
    mov dx, p_row
    add dx, 10d
    add bx, 90d    
crs2:
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h    
    dec cx 
    int 10h
    cmp dx, bx
    jle crs2
    endm

.Stack 100h

.data
msg1 db "PLAYER $"
exclam db " WINS!!!!$"
msg2 db "MATCH DRAWN!!!!!$"

p_row dw 2
p_col dw 172d
r_index dw 0
c_index dw 0
color db 0
zer_row db 0
zer_col db 0
counter db 0
zero dw 1
x_counter dw 0
xctr dw 0
o_counter dw 0
player_value dw 1
winner_found dw 0
winner db 1
onedim_index dw 0
new_onedim_index dw 0
flag dw 9 dup(0)
score db 9 dup(0)

.code

main proc
    
    mov ax,@data
    mov ds,ax
    
    mov ax, 12h
    int 10h
    
    call draw_grid
    inc flag[0]
    mov color, 15d
    call draw_b
    
    call keystroke
    cmp winner_found, 1
    je call_printwinner    
    jne call_printdraw
    
    end_call_printwinner:
    ;getch
    mov ah, 0
    int 16h
    
    ;return to text mode
    mov ax, 3
    int 10h
    
    ;return to dos
    mov ah, 4ch
    int 21h 
    ret
    
    main endp

    
call_printwinner:
    cmp player_value, 1
    je inc_winner
    end_inc_winner:
    call printwinner
    jmp end_call_printwinner

inc_winner:
    inc winner
    jmp end_inc_winner
    
call_printdraw:
    call printdraw
    jmp end_call_printwinner

printwinner proc
    ;move cursor
    mov ah, 2
    mov dh, 0  ;row
    mov dl, 0  ;column
    int 10h
    
    ;write char
    mov si, 0
    mov cx, 1
    mov bl, 0001b
    mov color, bl
    ploop:
    mov ah, 9
    mov bl, color
    cmp msg1[si], " "    
    je make_black_1
    end_make_black_1:
    
    cmp msg1[si], "$"
    je endloop    
    mov al, msg1[si]
    int 10h
    inc si
    mov ah, 2
    inc dl
    int 10h
    inc color
    jmp ploop
    endloop:
    mov al, winner
    add al, '0'
    int 10h
    
    mov ah, 2
    inc dl
    int 10h
    
    mov si, 0
    eloop:    
    mov ah, 9
    mov bl, color
    cmp exclam[si], " "    
    je make_black_2
    end_make_black_2:
    
    cmp exclam[si], "$"
    je end_loop    
    mov al, exclam[si]
    int 10h
    inc color
    inc si
    mov ah, 2
    inc dl
    int 10h
    jmp eloop
    end_loop:
    
    ret
    printwinner endp

make_black_1:
    mov bl, 0
    ;dec color
    jmp end_make_black_1

make_black_2:
    mov bl, 0
    dec color
    jmp end_make_black_2

printdraw proc
    ;move crusor
    mov ah, 2
    mov dh, 0  ;row
    mov dl, 0  ;column
    int 10h
    
    ;write char
    mov si, 0
    mov cx, 1
    mov bl, 0001b
    mov color, bl
    
    dloop:
    mov bl, color
    cmp msg2[si], " "    
    je make_black_3
    end_make_black_3:
    
    mov ah, 9
    cmp msg2[si], "$"
    je enddloop    
    mov al, msg2[si]
    int 10h
    inc color
    inc si
    mov ah, 2
    inc dl
    int 10h
    jmp dloop
    enddloop:
        
    ret
    printdraw endp

make_black_3:
    mov bl, 0
    dec color
    jmp end_make_black_3

keystroke proc
    infinitely_finite:
    call find_winner
    cmp winner_found, 1
    je return
    call check_zero
    cmp zero, 0
    je return
       
    mov ah, 0   ;read keystroke function
    int 16h ;al=ASCII code or 0,
            ;ah=scan code
    
    or al, al ;al=0 (function key)? 
    jne playerInput ;no, character key
    
    cmp ah, 48h ;up arrow
    je gogo_up
        
    cmp ah, 4bh ;left arrow
    je gogo_left
    
    cmp ah, 4dh ;right arrow
    je gogo_right
    
    cmp ah, 50h ;down arrow
    je gogo_down
 
    go_end:
    jmp infinitely_finite
    
    playerInput:
    cmp al, 78h ;input=x?
    je playerInput_X ;yes
    
    cmp al, 6fh ;input=o?
    je playerInput_OO ;yes
    
    input_end:
    jmp infinitely_finite
    
    return:
    ret
    keystroke endp

playerInput_OO:
    jmp playerInput_O
    
gogo_up:
    jmp go_up
gogo_left:
    jmp go_left
gogo_right:
    jmp go_right
gogo_down:
    jmp go_down

playerInput_X:
    cmp player_value, 1
    jne input_end
    
    mov bx, onedim_index
    cmp score[bx], 0
    jne input_end
    mov score[bx], 'x'
    
    mov al, 1
    mov cx, p_col
    add cx, 25d
    
    left_x_loop:
    draw_left_X dx, bx
    sub cx, 40d    
    inc xctr
    cmp xctr, 5
    jl left_x_loop
    
    add cx, 40d
    mov xctr, 0
    
    right_x_loop:
    draw_right_X dx, bx
    add cx, 40d
    inc xctr
    cmp xctr, 5
    jl right_x_loop
    
    mov xctr, 0
    mov player_value, 2
    jmp input_end
    
playerInput_O:
    cmp player_value, 2
    jne input_end
    
    mov bx, onedim_index
    cmp score[bx], 0
    jne input_end
    mov score[bx], 'o'
    
    call draw_O
    mov player_value, 1
    jmp input_end
    
go_up:
    mov cx, onedim_index
    sub cx, 3
    cmp cx, 0
    jl add_nin
    
    end_add_nin:
    
    mov new_onedim_index, cx
    mov color, 4
    call draw_b
    mov di, onedim_index
    shl di, 1
    dec flag[di]
    
    mov cx, new_onedim_index
    shl cx,1
        
    mov di, cx
    inc flag[di]
    mov color, 15d
    call draw_b
    jmp go_end

add_nin:
    add cx, 9d
    jmp end_add_nin
    
go_left:
    mov cx, onedim_index
    sub cx, 1
    cmp cx, 0
    jl add_nin_1
    
    end_add_nin_1:
    
    mov new_onedim_index, cx
    mov color, 4
    call draw_b
    mov di, onedim_index
    shl di, 1
    dec flag[di]
    
    mov cx, new_onedim_index
    shl cx, 1
    
    mov di, cx
    inc flag[di]
    mov color, 15d
    call draw_b
    jmp go_end

add_nin_1:
    add cx, 9d
    jmp end_add_nin_1
    
go_right:
    mov cx, onedim_index
    add cx, 1
    cmp cx, 8d
    jg sub_nin
    
    end_sub_nin:
    
    mov new_onedim_index, cx
    mov color, 4
    call draw_b
    mov di, onedim_index
    shl di, 1
    dec flag[di]
    
    mov cx, new_onedim_index
    shl cx, 1
    
    mov di, cx
    inc flag[di]
    mov color, 15d
    call draw_b
    jmp go_end

sub_nin:
    sub cx, 9d
    jmp end_sub_nin
    
go_down:
    mov cx, onedim_index
    add cx, 3
    cmp cx, 8
    jg sub_nin_1
    
    end_sub_nin_1:
    
    mov new_onedim_index, cx
    mov color, 4
    call draw_b
    mov di, onedim_index
    shl di, 1
    dec flag[di]
    
    mov cx, new_onedim_index
    shl cx, 1
    
    mov di, cx
    inc flag[di]
    mov color, 15d
    call draw_b
    jmp go_end

sub_nin_1:
    sub cx, 9d
    jmp end_sub_nin_1

draw_O proc
    mov al, 1110b
    mov ah, 0ch
    mov cx, p_col
    add cx, 30d
    mov dx, p_row
    add dx, 10d
    mov counter, 0
    
    draw_0_row_up:
    draw_rth_row_up:
    int 10h
    inc cx
    inc zer_row
    cmp zer_row, 40d
    jl draw_rth_row_up
    mov zer_row, 0
    sub cx, 40d
    inc dx
    inc counter
    cmp counter, 5
    jl draw_0_row_up
    
    sub dx, 5
    add dx, 75d
    mov counter, 0
    mov zer_row, 0
    
    draw_0_row_down:
    draw_rth_row_down:
    int 10h
    inc cx
    inc zer_row
    cmp zer_row, 40d
    jl draw_rth_row_down
    mov zer_row, 0
    sub cx, 40d
    inc dx
    inc counter
    cmp counter, 5
    jl draw_0_row_down
    
    mov counter, 0
    mov zer_row, 0
    
    mov cx, p_col
    add cx, 20d
    mov dx, p_row
    add dx, 30d
    mov counter, 0
    
    draw_0_col_left:
    draw_rth_col_left:
    int 10h
    inc dx
    inc zer_col
    cmp zer_col, 40d
    jl draw_rth_col_left
    mov zer_col, 0
    sub dx, 40d
    inc cx
    inc counter
    cmp counter, 5
    jl draw_0_col_left
    
    sub cx, 5
    add cx, 56d
    mov counter, 0
    mov zer_col, 0
    
    draw_0_col_right:
    draw_rth_col_right:
    int 10h
    inc dx
    inc zer_col
    cmp zer_col, 40d
    jl draw_rth_col_right
    mov zer_col, 0
    sub dx, 40d
    inc cx
    inc counter
    cmp counter, 5
    jl draw_0_col_right
    
    sub cx, 5
    add cx, 80d
    mov counter, 0
    mov zer_col, 0
    
    mov cx, p_col
    add cx, 31d
    mov dx, p_row
    add dx, 10d
    mov counter, 0
    
    draw_0_crs_left_top:
    draw_rth_crs_left_top:
    int 10h
    dec cx
    int 10h    
    inc dx
    int 10h
    inc dx
    int 10h
    inc zer_col
    cmp zer_col, 10d
    jl draw_rth_crs_left_top
    mov zer_col, 0
    add cx, 10d
    sub dx, 20d
    inc dx
    inc counter
    cmp counter, 5
    jl draw_0_crs_left_top
    
    sub dx, 4
    add cx, 39d
    mov counter, 0
    mov zer_col, 0
    
    draw_0_crs_right_top:
    draw_rth_crs_right_top:
    int 10h
    inc cx
    int 10h
    inc dx
    int 10h
    inc dx
    int 10h
    cmp zer_col, 9d
    je end_drawing
    
    inc zer_col
    cmp zer_col, 10d
    jl draw_rth_crs_right_top
    end_drawing:
    mov zer_col, 0
    sub cx, 10d
    sub dx, 20d
    inc dx
    inc counter
    cmp counter, 5
    jl draw_0_crs_right_top
    
    sub dx, 5
    sub cx, 40d
    add dx, 78d
    mov counter, 0
    mov zer_col, 0
    
    draw_0_crs_left_down:
    draw_rth_crs_left_down:
    int 10h
    dec dx
    int 10h
    dec dx
    int 10h
    dec cx
    int 10h
    
    inc zer_col
    cmp zer_col, 10d
    jl draw_rth_crs_left_down
    mov zer_col, 0
    add cx, 10d
    add dx, 20d
    dec dx
    inc counter
    cmp counter, 5
    jl draw_0_crs_left_down
    
    add dx, 5
    add cx, 40d
    mov counter, 0
    mov zer_col, 0
    
    ;from here
    draw_0_crs_right_down:
    draw_rth_crs_right_down:
    int 10h
    inc cx
    int 10h    
    dec dx
    int 10h
    dec dx
    int 10h
    
    inc zer_col
    cmp zer_col, 10d
    jl draw_rth_crs_right_down
    mov zer_col, 0
    sub cx, 10d
    add dx, 20d
    dec dx
    inc counter
    cmp counter, 5
    jl draw_0_crs_right_down
    
    add dx, 5
    sub cx, 40d
    mov counter, 0
    mov zer_col, 0
    
    ret
    draw_O endp
    
check_zero proc
    mov di,0
    zloop:
    cmp score[di],0
    je end_zloop
    inc di  
    cmp di,8d
    jle zloop
    jmp setzero
    end_zloop:  
    mov zero, 1
    jmp set
    setzero:
    mov zero, 0
    
    set:    
    ret
    check_zero endp

inc_x macro si
    local inc_xx, endus
    
    cmp score[si], 'x'
    je inc_xx
    jne endus
    inc_xx:
    inc x_counter

    endus:
    endm 

inc_o macro si
    local inc_oo, endus
    
    cmp score[si], 'o'
    je inc_oo
    jne endus
    inc_oo:
    inc o_counter

    endus:
    endm 

check_012 proc
    inc_x 0        
    inc_x 1
    inc_x 2
    
    inc_o 0
    inc_o 1
    inc_o 2
    
    ret
    check_012 endp

check_345 proc
    inc_x 3        
    inc_x 4
    inc_x 5
    
    inc_o 3
    inc_o 4
    inc_o 5
    
    ret
    check_345 endp

check_678 proc
    inc_x 6        
    inc_x 7
    inc_x 8
    
    inc_o 6
    inc_o 7
    inc_o 8
    
    ret
    check_678 endp

check_036 proc
    inc_x 0        
    inc_x 3
    inc_x 6
    
    inc_o 0
    inc_o 3
    inc_o 6
    
    ret
    check_036 endp

check_147 proc
    inc_x 1        
    inc_x 4
    inc_x 7
    
    inc_o 1
    inc_o 4
    inc_o 7
    
    ret
    check_147 endp

check_258 proc
    inc_x 2        
    inc_x 5
    inc_x 8
    
    inc_o 2
    inc_o 5
    inc_o 8
    
    ret
    check_258 endp

check_048 proc
    inc_x 0        
    inc_x 4
    inc_x 8
    
    inc_o 0
    inc_o 4
    inc_o 8
    
    ret
    check_048 endp

check_246 proc
    inc_x 2        
    inc_x 4
    inc_x 6
    
    inc_o 2
    inc_o 4
    inc_o 6
    
    ret
    check_246 endp

find_winner proc
    call check_012
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    call check_345       
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    call check_678        
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    call check_036    
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    jmp usemethod

win_found:
    mov winner_found, 1
    jmp ret2key

    usemethod:
    call check_147
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    call check_258        
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    call check_048
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    call check_246        
    cmp x_counter, 3
    je win_found
    cmp o_counter, 3
    je win_found
    
    mov x_counter, 0
    mov o_counter, 0
    
    ret2key:
    ret
    find_winner endp

    
draw_grid proc
    
    mov bx, 0
    row_draw_loop:
    draw_row bx
    inc bx
    draw_row bx
    inc bx
    draw_row bx
    
    sub bx, 2
    add bx, 100d
    inc counter
    cmp counter, 4
    jl row_draw_loop
    
    mov counter, 0
    mov bx, 170d
    col_draw_loop:
    draw_col bx
    inc bx
    draw_col bx
    inc bx
    draw_col bx
    
    sub bx, 2
    add bx, 100d
    inc counter
    cmp counter, 4
    jl col_draw_loop
     
    ret
    draw_grid endp

check_one proc
    mov di,0
    oloop:
    cmp flag[di],1
    je end_oloop
    inc di  
    cmp di,16d
    jle oloop
    end_oloop:  
    shr di, 1
    mov onedim_index, di    
    mov ax, di
    mov bx, 3
    mov dx, 0
    div bx
    mov r_index,ax
    mov c_index,dx
    ret
    
    check_one endp

draw_b proc ;draws box in selected index of given color
    call check_one
    call index_to_pixel
    
    add p_row, 2
    add p_col, 2
    mov si, p_col
    mov bx, p_col
    add si, 98d
    
    mov al, color
    draw_r_b bx, si
    add p_row, 98d
    
    draw_r_b bx, si
    
    sub p_row, 98d
    mov bx, p_row
    mov si, p_row
    add si, 98d
    draw_c_b bx, si
    
    add p_col, 98d
    draw_c_b bx, si
    
    call check_one  ;restoring index
    call index_to_pixel ;and pixel of the selected box
    
    ret
    
    draw_b endp

index_to_pixel proc ;once gets an index, returns the left-top pixel of the box at that index
    mov ax, 100d
    
    mul r_index
    mov p_row, ax
    mov ax, 100d
    mul c_index
    add ax,170d
    mov p_col,ax
    
    ret
    index_to_pixel endp    

    end main

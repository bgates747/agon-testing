play_notes:

    ld hl,play_notes_cmd
    ld bc,play_notes_end-play_notes_cmd
    rst.lil $18
    ret
play_notes_cmd:

cmd0:
                db 23, 0, $85, 0, 3
frequency0:   dw 0 
              db 23, 0, $85, 0, 2
volume0:      db 0

             db 23, 0, $85, 0, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd1:
                db 23, 0, $85, 1, 3
frequency1:   dw 0 
              db 23, 0, $85, 1, 2
volume1:      db 0

             db 23, 0, $85, 1, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd2:
                db 23, 0, $85, 2, 3
frequency2:   dw 0 
              db 23, 0, $85, 2, 2
volume2:      db 0

             db 23, 0, $85, 2, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd3:
                db 23, 0, $85, 3, 3
frequency3:   dw 0 
              db 23, 0, $85, 3, 2
volume3:      db 0

             db 23, 0, $85, 3, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd4:
                db 23, 0, $85, 4, 3
frequency4:   dw 0 
              db 23, 0, $85, 4, 2
volume4:      db 0

             db 23, 0, $85, 4, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd5:
                db 23, 0, $85, 5, 3
frequency5:   dw 0 
              db 23, 0, $85, 5, 2
volume5:      db 0

             db 23, 0, $85, 5, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd6:
                db 23, 0, $85, 6, 3
frequency6:   dw 0 
              db 23, 0, $85, 6, 2
volume6:      db 0

             db 23, 0, $85, 6, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd7:
                db 23, 0, $85, 7, 3
frequency7:   dw 0 
              db 23, 0, $85, 7, 2
volume7:      db 0

             db 23, 0, $85, 7, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd8:
                db 23, 0, $85, 8, 3
frequency8:   dw 0 
              db 23, 0, $85, 8, 2
volume8:      db 0

             db 23, 0, $85, 8, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd9:
                db 23, 0, $85, 9, 3
frequency9:   dw 0 
              db 23, 0, $85, 9, 2
volume9:      db 0

             db 23, 0, $85, 9, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd10:
                db 23, 0, $85, 10, 3
frequency10:   dw 0 
              db 23, 0, $85, 10, 2
volume10:      db 0

             db 23, 0, $85, 10, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd11:
                db 23, 0, $85, 11, 3
frequency11:   dw 0 
              db 23, 0, $85, 11, 2
volume11:      db 0

             db 23, 0, $85, 11, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd12:
                db 23, 0, $85, 12, 3
frequency12:   dw 0 
              db 23, 0, $85, 12, 2
volume12:      db 0

             db 23, 0, $85, 12, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd13:
                db 23, 0, $85, 13, 3
frequency13:   dw 0 
              db 23, 0, $85, 13, 2
volume13:      db 0

             db 23, 0, $85, 13, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd14:
                db 23, 0, $85, 14, 3
frequency14:   dw 0 
              db 23, 0, $85, 14, 2
volume14:      db 0

             db 23, 0, $85, 14, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd15:
                db 23, 0, $85, 15, 3
frequency15:   dw 0 
              db 23, 0, $85, 15, 2
volume15:      db 0

             db 23, 0, $85, 15, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd16:
                db 23, 0, $85, 16, 3
frequency16:   dw 0 
              db 23, 0, $85, 16, 2
volume16:      db 0

             db 23, 0, $85, 16, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd17:
                db 23, 0, $85, 17, 3
frequency17:   dw 0 
              db 23, 0, $85, 17, 2
volume17:      db 0

             db 23, 0, $85, 17, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd18:
                db 23, 0, $85, 18, 3
frequency18:   dw 0 
              db 23, 0, $85, 18, 2
volume18:      db 0

             db 23, 0, $85, 18, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd19:
                db 23, 0, $85, 19, 3
frequency19:   dw 0 
              db 23, 0, $85, 19, 2
volume19:      db 0

             db 23, 0, $85, 19, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd20:
                db 23, 0, $85, 20, 3
frequency20:   dw 0 
              db 23, 0, $85, 20, 2
volume20:      db 0

             db 23, 0, $85, 20, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd21:
                db 23, 0, $85, 21, 3
frequency21:   dw 0 
              db 23, 0, $85, 21, 2
volume21:      db 0

             db 23, 0, $85, 21, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd22:
                db 23, 0, $85, 22, 3
frequency22:   dw 0 
              db 23, 0, $85, 22, 2
volume22:      db 0

             db 23, 0, $85, 22, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd23:
                db 23, 0, $85, 23, 3
frequency23:   dw 0 
              db 23, 0, $85, 23, 2
volume23:      db 0

             db 23, 0, $85, 23, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd24:
                db 23, 0, $85, 24, 3
frequency24:   dw 0 
              db 23, 0, $85, 24, 2
volume24:      db 0

             db 23, 0, $85, 24, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd25:
                db 23, 0, $85, 25, 3
frequency25:   dw 0 
              db 23, 0, $85, 25, 2
volume25:      db 0

             db 23, 0, $85, 25, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd26:
                db 23, 0, $85, 26, 3
frequency26:   dw 0 
              db 23, 0, $85, 26, 2
volume26:      db 0

             db 23, 0, $85, 26, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd27:
                db 23, 0, $85, 27, 3
frequency27:   dw 0 
              db 23, 0, $85, 27, 2
volume27:      db 0

             db 23, 0, $85, 27, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd28:
                db 23, 0, $85, 28, 3
frequency28:   dw 0 
              db 23, 0, $85, 28, 2
volume28:      db 0

             db 23, 0, $85, 28, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd29:
                db 23, 0, $85, 29, 3
frequency29:   dw 0 
              db 23, 0, $85, 29, 2
volume29:      db 0

             db 23, 0, $85, 29, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd30:
                db 23, 0, $85, 30, 3
frequency30:   dw 0 
              db 23, 0, $85, 30, 2
volume30:      db 0

             db 23, 0, $85, 30, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5
cmd31:
                db 23, 0, $85, 31, 3
frequency31:   dw 0 
              db 23, 0, $85, 31, 2
volume31:      db 0

             db 23, 0, $85, 31, 7,1
				db 2
				db %00000001
				dw 14
				dw 3
				dw 5
				dw -3
				dw 5

play_notes_end:
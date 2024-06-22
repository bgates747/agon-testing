   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=4
   30 model_indices%=6
   35 model_uvs%=4
   40 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   50 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   60 CLS
   70 REM --== INITIALIZATION ==--
   80 PRINT "Reading vertices"
   90 total_coords%=model_vertices%*3
  100 max_abs=-99999
  110 DIM vertices(total_coords%)
  120 FOR i%=0 TO total_coords%-1
  130   READ coord
  140   vertices(i%)=coord
  150   a=ABS(coord)
  160   IF a>max_abs THEN max_abs=a
  170 NEXT i%
  180 factor=32767 : REM factor=32767.0/max_abs
  190 PRINT "Max absolute value = ";max_abs
  200 PRINT "Factor = ";factor
  210 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  220 PRINT "Creating control structure"
  230 scene_width%=320: scene_height%=240
  240 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  250 f=32767.0/256.0
  260 distx=0*f: disty=0*f: distz=-20*f
  270 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
  280 pi2=PI*2.0: f=32767.0/pi2
  290 anglex=0.0*f
  300 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
  310 PRINT "Sending vertices using factor ";factor
  320 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  330 FOR i%=0 TO total_coords%-1
  340   val%=vertices(i%)*factor
  350   VDU val%;
  360   T%=TIME
  370   IF TIME-T%<1 GOTO 370
  380 NEXT i%
  390 PRINT "Reading and sending vertex indices"
  400 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indices%; : REM Set Mesh Vertex indices
  410 FOR i%=0 TO model_indices%-1
  420   READ val%
  430   VDU val%;
  440   T%=TIME
  450   IF TIME-T%<1 GOTO 450
  460 NEXT i%
  470 PRINT "Sending texture UV coordinates"
  472 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
  474 FOR i%=0 TO model_uvs%*2-1
  476   READ val%
  478   VDU val%*32767;
  480   T%=TIME
  482   IF TIME-T%<1 GOTO 480
  484 NEXT i%
  486 PRINT "Sending Texture Coordinate indices"
  488 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  490 FOR i%=0 TO model_indices%-1
  492   READ val%
  494   VDU val%;
  496   T%=TIME
  498   IF TIME-T%<1 GOTO 498
  500 NEXT i%
  530 PRINT "Creating texture bitmap"
  540 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  550 PRINT "Sending texture pixel data"
  552 VDU 23, 27, 1, 16; 16; 
  554 FOR i%=0 TO 16*4-1
  556   READ val%
  558   VDU val%;
  560   T%=TIME
  562   IF TIME-T%<1 GOTO 560
  564 NEXT i%
  570 PRINT "Create 3D object"
  580 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  590 PRINT "Scale object"
  600 scale=1.0*256.0
  610 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  620 PRINT "Create target bitmap"
  630 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  640 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  650 PRINT "Render 3D object"
  660 VDU 23, 0, &C3: REM Flip buffer
  670 rotatex=0.0: rotatey=0.0: rotatez=0.0
  680 factor=32767.0/pi2
  690 VDU 22, 136: REM 320x240x64 double-buffered
  700 VDU 23, 0, &C0, 0: REM Normal coordinates
  710 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  720 VDU 17,7+128 : REM set text background color to light gray
  730 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  740 inc=0.122718463
  750 REM --== MAIN LOOP ==--
  760 CLS
  770 REM incx=0.0:incy=0.0:incz=0.0
  775 incx=inc/2:incy=inc:incz=inc*2
  780 ON ERROR GOTO 1010 : REM used to prevent Escape key from stopping program
  790 A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
  800 PRINT "keycode ";A%
  810 IF A%=21 THEN incz=-inc :REM RIGHT.
  820 IF A%=8 THEN incz=inc :REM LEFT.
  830 IF A%=10 THEN incy=inc :REM DOWN.
  840 IF A%=11 THEN incy=-inc :REM UP.
  850 PRINT "rotate x=";rotatex
  860 PRINT "rotate y=";rotatey
  870 PRINT "rotate z=";rotatez
  880 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
  890 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
  900 VDU 23, 0, &C3: REM Flip buffer
  910 *FX 19
  920 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
  930 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
  940 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
  950 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
  960 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
  970 GOTO 760
 1000 REM -- EXIT PROGRAM --
 1010 VDU 22, 3: REM 640x240x64 single-buffered
 1020 VDU 23, 0, &C0, 0: REM Normal coordinates
 1030 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1040 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1050 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1060 CLS
 1070 END
 2000 REM -- VERTICES --
2010 DATA -1.000000, -1.000000, -0.000000
2020 DATA 1.000000, -1.000000, -0.000000
2030 DATA -1.000000, 1.000000, 0.000000
2040 DATA 1.000000, 1.000000, 0.000000
2050 REM -- FACE VERTEX INDICES --
2060 DATA 2, 1, 0
2070 DATA 2, 3, 1
2080 REM -- TEXTURE UV COORDINATES --
2090 DATA 0.000100, 0.000100
2100 DATA 0.999900, 0.999900
2110 DATA 0.000100, 0.999900
2120 DATA 0.999900, 0.000100
2130 REM -- TEXTURE VERTEX INDICES --
2140 DATA 0, 1, 2
2150 DATA 0, 3, 1
9999 REM -- TEXTURE BITMAP --
10000 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10010 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &FF &FF &55 &FF
10020 DATA &FF &FF &55 &FF &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10030 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10040 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10050 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &FF &FF &55 &FF
10060 DATA &FF &FF &55 &FF &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10070 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10080 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10090 DATA &00 &00 &00 &00 &00 &00 &00 &00 &FF &00 &00 &FF &FF &FF &55 &FF
10100 DATA &FF &FF &55 &FF &FF &00 &00 &FF &00 &00 &00 &00 &00 &00 &00 &00
10110 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10120 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10130 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &55 &FF &FF &55 &55 &FF
10140 DATA &FF &55 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00 &00 &00 &00 &00
10150 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10160 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10170 DATA &00 &00 &00 &00 &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF
10180 DATA &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF &00 &00 &00 &00
10190 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10200 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10210 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &55 &FF &FF &FF &55 &FF
10220 DATA &FF &FF &55 &FF &00 &00 &55 &FF &00 &00 &00 &00 &00 &00 &00 &00
10230 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10240 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10250 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &55 &FF &FF &55 &55 &FF
10260 DATA &FF &55 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00 &00 &00 &00 &00
10270 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10280 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10290 DATA &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF
10300 DATA &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF
10310 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10320 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10330 DATA &00 &00 &00 &00 &00 &00 &55 &FF &00 &00 &55 &FF &FF &FF &55 &FF
10340 DATA &FF &FF &55 &FF &00 &00 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00
10350 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10360 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10370 DATA &00 &00 &00 &00 &00 &00 &55 &FF &FF &00 &00 &FF &FF &FF &55 &FF
10380 DATA &FF &FF &55 &FF &FF &00 &00 &FF &00 &00 &55 &FF &00 &00 &00 &00
10390 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10400 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10410 DATA &00 &00 &00 &00 &00 &00 &55 &FF &FF &00 &00 &FF &FF &55 &55 &FF
10420 DATA &FF &55 &55 &FF &FF &00 &00 &FF &00 &00 &55 &FF &00 &00 &00 &00
10430 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10440 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10450 DATA &00 &00 &00 &00 &00 &00 &55 &FF &00 &00 &55 &FF &55 &55 &AA &FF
10460 DATA &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00
10470 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10480 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10490 DATA &00 &00 &55 &FF &00 &00 &55 &FF &55 &55 &AA &FF &AA &AA &FF &FF
10500 DATA &AA &AA &FF &FF &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &55 &FF
10510 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10520 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10530 DATA &00 &00 &55 &FF &55 &55 &AA &FF &AA &AA &FF &FF &AA &AA &FF &FF
10540 DATA &AA &AA &FF &FF &AA &AA &FF &FF &55 &55 &AA &FF &00 &00 &55 &FF
10550 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10560 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10570 DATA &00 &00 &00 &00 &00 &00 &55 &FF &55 &55 &AA &FF &AA &AA &FF &FF
10580 DATA &AA &AA &FF &FF &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &00 &00
10590 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10600 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
10610 DATA &00 &00 &00 &00 &00 &00 &55 &FF &55 &55 &AA &FF &55 &55 &AA &FF
10620 DATA &55 &55 &AA &FF &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &00 &00
10630 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 
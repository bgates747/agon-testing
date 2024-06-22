   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=4
   30 model_indices%=6
   40 model_uvs%=4
   50 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   60 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   70 CLS
   80 REM --== INITIALIZATION ==--
   90 PRINT "Reading vertices"
  100 total_coords%=model_vertices%*3
  110 max_abs=-99999
  120 DIM vertices(total_coords%)
  130 FOR i%=0 TO total_coords%-1
  140   READ coord
  150   vertices(i%)=coord
  160   a=ABS(coord)
  170   IF a>max_abs THEN max_abs=a
  180 NEXT i%
  190 factor=32767 : REM factor=32767.0/max_abs
  200 PRINT "Max absolute value = ";max_abs
  210 PRINT "Factor = ";factor
  220 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  230 PRINT "Creating control structure"
  240 scene_width%=320: scene_height%=240
  250 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  260 f=32767.0/256.0
  270 distx=0*f: disty=0*f: distz=-20*f
  280 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
  290 pi2=PI*2.0: f=32767.0/pi2
  300 anglex=0.0*f
  310 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
  320 PRINT "Sending vertices using factor ";factor
  330 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  340 FOR i%=0 TO total_coords%-1
  350   val%=vertices(i%)*factor
  360   VDU val%;
  370   T%=TIME
  380   IF TIME-T%<1 GOTO 380
  390 NEXT i%
  400 PRINT "Reading and sending vertex indices"
  410 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indices%; : REM Set Mesh Vertex indices
  420 FOR i%=0 TO model_indices%-1
  430   READ val%
  440   VDU val%;
  450   T%=TIME
  460   IF TIME-T%<1 GOTO 460
  470 NEXT i%
  480 PRINT "Sending texture UV coordinates"
  490 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
  495 total_uvs%=model_uvs%*2
  500 FOR i%=0 TO total_uvs%-1
  510   READ val%
  515   val%=val%*65535
  520   VDU val%;
  530   T%=TIME
  540   IF TIME-T%<1 GOTO 540
  550 NEXT i%
  560 PRINT "Sending Texture Coordinate indices"
  570 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  580 FOR i%=0 TO model_indices%-1
  590   READ val%
  600   VDU val%;
  610   T%=TIME
  620   IF TIME-T%<1 GOTO 620
  630 NEXT i%
  640 PRINT "Creating texture bitmap"
  650 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  660 PRINT "Sending texture pixel data"
  670 VDU 23, 27, 1, 16; 16; 
  680 FOR i%=0 TO 16*16*4-1
  690   READ val%
  700   VDU val%
  710   T%=TIME
  720   IF TIME-T%<1 GOTO 720
  730 NEXT i%
  740 PRINT "Create 3D object"
  750 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  760 PRINT "Scale object"
  770 scale=1.0*256.0
  780 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  790 PRINT "Create target bitmap"
  800 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  810 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  820 PRINT "Render 3D object"
  830 VDU 23, 0, &C3: REM Flip buffer
  840 rotatex=0.0: rotatey=0.0: rotatez=0.0
  850 factor=32767.0/pi2
  860 VDU 22, 136: REM 320x240x64 double-buffered
  870 VDU 23, 0, &C0, 0: REM Normal coordinates
  880 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  890 VDU 17,7+128 : REM set text background color to light gray
  900 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  910 inc=0.122718463
  920 REM --== MAIN LOOP ==--
  930 CLS
  940 REM incx=0.0:incy=0.0:incz=0.0
  950 incx=inc/2:incy=inc:incz=inc*2
  960 ON ERROR GOTO 1170 : REM used to prevent Escape key from stopping program
  970 A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
  980 PRINT "keycode ";A%
  990 IF A%=21 THEN incz=-inc :REM RIGHT.
 1000 IF A%=8 THEN incz=inc :REM LEFT.
 1010 IF A%=10 THEN incy=inc :REM DOWN.
 1020 IF A%=11 THEN incy=-inc :REM UP.
 1030 PRINT "rotate x=";rotatex
 1040 PRINT "rotate y=";rotatey
 1050 PRINT "rotate z=";rotatez
 1060 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
 1070 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
 1080 VDU 23, 0, &C3: REM Flip buffer
 1090 *FX 19
 1100 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
 1110 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
 1120 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
 1130 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
 1140 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
 1150 GOTO 930
 1160 REM -- EXIT PROGRAM --
 1170 VDU 22, 3: REM 640x240x64 single-buffered
 1180 VDU 23, 0, &C0, 0: REM Normal coordinates
 1190 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1200 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1210 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1220 CLS
 1230 END
 1240 REM -- VERTICES --
 1250 DATA -1.000000, -1.000000, -0.000000
 1260 DATA 1.000000, -1.000000, -0.000000
 1270 DATA -1.000000, 1.000000, 0.000000
 1280 DATA 1.000000, 1.000000, 0.000000
 1290 REM -- FACE VERTEX INDICES --
 1300 DATA 2, 1, 0
 1310 DATA 2, 3, 1
 1320 REM -- TEXTURE UV COORDINATES --
 1330 DATA 0.000100, 0.000100
 1340 DATA 0.999900, 0.999900
 1350 DATA 0.000100, 0.999900
 1360 DATA 0.999900, 0.000100
 1370 REM -- TEXTURE VERTEX INDICES --
 1380 DATA 0, 1, 2
 1390 DATA 0, 3, 1
 1400 REM -- TEXTURE BITMAP --
 1410 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1420 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &FF &FF &55 &FF
 1430 DATA &FF &FF &55 &FF &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1440 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1450 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1460 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &FF &FF &55 &FF
 1470 DATA &FF &FF &55 &FF &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1480 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1490 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1500 DATA &00 &00 &00 &00 &00 &00 &00 &00 &FF &00 &00 &FF &FF &FF &55 &FF
 1510 DATA &FF &FF &55 &FF &FF &00 &00 &FF &00 &00 &00 &00 &00 &00 &00 &00
 1520 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1530 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1540 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &55 &FF &FF &55 &55 &FF
 1550 DATA &FF &55 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00 &00 &00 &00 &00
 1560 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1570 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1580 DATA &00 &00 &00 &00 &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF
 1590 DATA &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF &00 &00 &00 &00
 1600 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1610 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1620 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &55 &FF &FF &FF &55 &FF
 1630 DATA &FF &FF &55 &FF &00 &00 &55 &FF &00 &00 &00 &00 &00 &00 &00 &00
 1640 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1650 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1660 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &55 &FF &FF &55 &55 &FF
 1670 DATA &FF &55 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00 &00 &00 &00 &00
 1680 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1690 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1700 DATA &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF
 1710 DATA &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF &FF &00 &00 &FF
 1720 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1730 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1740 DATA &00 &00 &00 &00 &00 &00 &55 &FF &00 &00 &55 &FF &FF &FF &55 &FF
 1750 DATA &FF &FF &55 &FF &00 &00 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00
 1760 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1770 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1780 DATA &00 &00 &00 &00 &00 &00 &55 &FF &FF &00 &00 &FF &FF &FF &55 &FF
 1790 DATA &FF &FF &55 &FF &FF &00 &00 &FF &00 &00 &55 &FF &00 &00 &00 &00
 1800 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1810 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1820 DATA &00 &00 &00 &00 &00 &00 &55 &FF &FF &00 &00 &FF &FF &55 &55 &FF
 1830 DATA &FF &55 &55 &FF &FF &00 &00 &FF &00 &00 &55 &FF &00 &00 &00 &00
 1840 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1850 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1860 DATA &00 &00 &00 &00 &00 &00 &55 &FF &00 &00 &55 &FF &55 &55 &AA &FF
 1870 DATA &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &55 &FF &00 &00 &00 &00
 1880 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1890 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1900 DATA &00 &00 &55 &FF &00 &00 &55 &FF &55 &55 &AA &FF &AA &AA &FF &FF
 1910 DATA &AA &AA &FF &FF &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &55 &FF
 1920 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1930 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1940 DATA &00 &00 &55 &FF &55 &55 &AA &FF &AA &AA &FF &FF &AA &AA &FF &FF
 1950 DATA &AA &AA &FF &FF &AA &AA &FF &FF &55 &55 &AA &FF &00 &00 &55 &FF
 1960 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1970 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 1980 DATA &00 &00 &00 &00 &00 &00 &55 &FF &55 &55 &AA &FF &AA &AA &FF &FF
 1990 DATA &AA &AA &FF &FF &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &00 &00
 2000 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 2010 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00
 2020 DATA &00 &00 &00 &00 &00 &00 &55 &FF &55 &55 &AA &FF &55 &55 &AA &FF
 2030 DATA &55 &55 &AA &FF &55 &55 &AA &FF &00 &00 &55 &FF &00 &00 &00 &00
 2040 DATA &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00 &00

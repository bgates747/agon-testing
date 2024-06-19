   10 REM Sample app to illustrate Pingo 3D on Agon
20 model_vertices%=13
30 model_indexes%=60
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
  180 factor=32767.0/max_abs
  190 PRINT "Max absolute value = ";max_abs
  200 PRINT "Factor = ";factor
  210 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  220 PRINT "Creating control structure"
  230 scene_width%=320: scene_height%=240
  240 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  250 f=32767.0/256.0
  260 distx=0*f: disty=0*f: distz=-25*f
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
  390 PRINT "Reading and sending vertex indexes"
  400 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indexes%; : REM Set Mesh Vertex Indexes
  410 FOR i%=0 TO model_indexes%-1
  420   READ val%
  430   VDU val%;
  440   T%=TIME
  450   IF TIME-T%<1 GOTO 450
  460 NEXT i%
  470 PRINT "Sending texture coordinate indexes"
  480 VDU 23,0, &A0, sid%; &49, 3, mid%; 1; 32768; 32768; : REM Define Texture Coordinates
  490 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indexes%; : REM Set Texture Coordinate Indexes
  500 FOR i%=0 TO model_indexes%-1
  510   VDU 0;
  520 NEXT i%
  530 PRINT "Creating texture bitmap"
  540 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  550 PRINT "Setting texture pixel"
  560 VDU 23, 27, 1, 1; 1; &55, &AA, &FF, &C0 : REM Set a pixel in the bitmap
  570 PRINT "Create 3D object"
  580 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  590 PRINT "Scale object"
  600 scale=6.0*256.0
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
  720 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
  730 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
  740 REM
  750 REM --== MAIN LOOP ==--
  760 CLS
  770 incx=0*PI/256.0: incy=0*PI/256.0: incz=0*PI/256.0
  780 REM ON ERROR GOTO 1010 : REM used to prevent Escape key from stopping program
  790 A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
  800 PRINT "keycode ";A%
  810 IF A%=21 THEN incz=-10*PI/256.0 :REM RIGHT.
  820 IF A%=8 THEN incz=10*PI/256.0 :REM LEFT.
  830 IF A%=10 THEN incy=10*PI/256.0 :REM DOWN.
  840 IF A%=11 THEN incy=-10*PI/256.0 :REM UP.
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
2010 DATA 1.00000000, -1.00000000, 1.00000000
2020 DATA 1.00000000, 1.00000000, 1.00000000
2030 DATA 1.00000000, -1.00000000, -1.00000000
2040 DATA 1.00000000, 1.00000000, -1.00000000
2050 DATA -1.00000000, -1.00000000, 1.00000000
2060 DATA -1.00000000, 1.00000000, 1.00000000
2070 DATA -1.00000000, -1.00000000, -1.00000000
2080 DATA -1.00000000, 1.00000000, -1.00000000
2090 DATA 0.00000000, -1.77569342, 0.00000000
2100 DATA 1.00000000, -1.00000000, 1.82435596
2110 DATA 1.00000000, 1.00000000, 1.82435596
2120 DATA -1.00000000, -1.00000000, 1.82435596
2130 DATA -1.00000000, 1.00000000, 1.82435596
2140 REM
2150 REM -- INDEXES --
2160 DATA 6, 2, 8
2170 DATA 2, 7, 3
2180 DATA 6, 5, 7
2190 DATA 1, 7, 5
2200 DATA 0, 11, 4
2210 DATA 5, 10, 1
2220 DATA 2, 0, 8
2230 DATA 0, 4, 8
2240 DATA 8, 4, 6
2250 DATA 1, 9, 0
2260 DATA 4, 12, 5
2270 DATA 12, 9, 10
2280 DATA 2, 6, 7
2290 DATA 6, 4, 5
2300 DATA 1, 3, 7
2310 DATA 0, 9, 11
2320 DATA 5, 12, 10
2330 DATA 1, 10, 9
2340 DATA 4, 11, 12
2350 DATA 12, 11, 9

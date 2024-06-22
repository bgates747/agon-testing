   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=4
   30 model_indices%=6
   40 model_uvs%=4
   45 texture_width%=2 : texture_height%=2
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
  190 factor=32767.0/max_abs
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
  500 total_uvs%=model_uvs%*2
  510 FOR i%=0 TO total_uvs%-1
  520   READ val%
  530   val%=val%*65535
  540   VDU val%;
  550   T%=TIME
  560   IF TIME-T%<1 GOTO 560
  570 NEXT i%
  580 PRINT "Sending Texture Coordinate indices"
  590 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  600 FOR i%=0 TO model_indices%-1
  610   READ val%
  620   VDU val%;
  630   T%=TIME
  640   IF TIME-T%<1 GOTO 640
  650 NEXT i%
  660 PRINT "Creating texture bitmap"
  670 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  680 PRINT "Sending texture pixel data"
  690 VDU 23, 27, 1, texture_width%; texture_height%; 
  700 FOR i%=0 TO texture_width%*texture_height%*4-1
  710   READ val%
  720   VDU val% : REM 8-bit integers for pixel data
  730   T%=TIME
  740   IF TIME-T%<1 GOTO 740
  750 NEXT i%
  760 PRINT "Create 3D object"
  770 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  780 PRINT "Scale object"
  790 scale=1.0*256.0
  800 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  810 PRINT "Create target bitmap"
  820 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  830 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  840 PRINT "Render 3D object"
  850 VDU 23, 0, &C3: REM Flip buffer
  860 rotatex=0.0: rotatey=0.0: rotatez=0.0
  870 factor=32767.0/pi2
  880 VDU 22, 136: REM 320x240x64 double-buffered
  890 VDU 23, 0, &C0, 0: REM Normal coordinates
  900 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  910 VDU 17,7+128 : REM set text background color to light gray
  920 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  930 inc=0.122718463
  940 REM --== MAIN LOOP ==--
  950 CLS
  960 REM incx=0.0:incy=0.0:incz=0.0
  970 incx=inc/2:incy=inc:incz=inc*2
  980 ON ERROR GOTO 1190 : REM so that Escape key exits gracefully
  990 REM A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
 1000 REM PRINT "keycode ";A%
 1010 REM IF A%=21 THEN incz=-inc :REM RIGHT.
 1020 REM IF A%=8 THEN incz=inc :REM LEFT.
 1030 REM IF A%=10 THEN incy=inc :REM DOWN.
 1040 REM IF A%=11 THEN incy=-inc :REM UP.
 1050 PRINT "rotate x=";rotatex
 1060 PRINT "rotate y=";rotatey
 1070 PRINT "rotate z=";rotatez
 1080 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
 1090 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
 1100 VDU 23, 0, &C3: REM Flip buffer
 1110 *FX 19
 1120 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
 1130 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
 1140 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
 1150 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
 1160 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
 1170 GOTO 950
 1180 REM -- EXIT PROGRAM --
 1190 VDU 22, 3: REM 640x240x64 single-buffered
 1200 VDU 23, 0, &C0, 0: REM Normal coordinates
 1210 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1220 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1230 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1240 CLS
 1250 END
2000 REM -- VERTICES --
2010 DATA -1.000000, 1.000000, -0.000000
2020 DATA 1.000000, 1.000000, -0.000000
2030 DATA -1.000000, -1.000000, 0.000000
2040 DATA 1.000000, -1.000000, 0.000000
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
2160 REM -- TEXTURE BITMAP --
2170 DATA 255,0,0,255
2180 DATA 0,0,255,255
2190 DATA 255,255,0,255
2200 DATA 0,255,0,255

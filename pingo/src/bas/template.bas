   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=4
   30 model_indices%=6
   40 model_uvs%=4
   50 texture_width%=2 : texture_height%=2
   60 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   70 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   80 CLS
   90 REM --== INITIALIZATION ==--
  100 PRINT "Reading vertices"
  110 total_coords%=model_vertices%*3
  120 max_abs=-99999
  130 DIM vertices(total_coords%)
  140 FOR i%=0 TO total_coords%-1
  150   READ coord
  160   vertices(i%)=coord
  170   a=ABS(coord)
  180   IF a>max_abs THEN max_abs=a
  190 NEXT i%
  200 factor=32767.0/max_abs
  210 PRINT "Max absolute value = ";max_abs
  220 PRINT "Factor = ";factor
  230 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  240 PRINT "Creating control structure"
  250 scene_width%=320: scene_height%=240
  260 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  270 f=32767.0/256.0
  280 distx=0*f: disty=0*f: distz=-5*f
  290 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
  300 pi2=PI*2.0: f=32767.0/pi2
  310 anglex=0.0*f
  320 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
  330 PRINT "Sending vertices using factor ";factor
  340 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  350 FOR i%=0 TO total_coords%-1
  360   val%=vertices(i%)*factor
  370   VDU val%;
  380   REM T%=TIME
  390   REM IF TIME-T%<1 GOTO 390
  400 NEXT i%
  410 PRINT "Reading and sending vertex indices"
  420 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indices%; : REM Set Mesh Vertex indices
  430 FOR i%=0 TO model_indices%-1
  440   READ val%
  450   VDU val%;
  460   REM T%=TIME
  470   REM IF TIME-T%<1 GOTO 470
  480 NEXT i%
  490 PRINT "Sending texture UV coordinates"
  500 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
  510 total_uvs%=model_uvs%*2
  520 FOR i%=0 TO total_uvs%-1
  530   READ val
  540   val%=INT(val*32766)+1
  550   VDU val%;
  560   REM T%=TIME
  570   REM IF TIME-T%<1 GOTO 570
  580 NEXT i%
  590 PRINT "Sending Texture Coordinate indices"
  600 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  610 FOR i%=0 TO model_indices%-1
  620   READ val%
  630   VDU val%;
  640   REM T%=TIME
  650   REM IF TIME-T%<1 GOTO 650
  660 NEXT i%
  670 PRINT "Creating texture bitmap"
  680 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  690 PRINT "Sending texture pixel data"
  700 VDU 23, 27, 1, texture_width%; texture_height%; 
  710 FOR i%=0 TO texture_width%*texture_height%*4-1
  720   READ val%
  730   VDU val% : REM 8-bit integers for pixel data
  740   REM T%=TIME
  750   REM IF TIME-T%<1 GOTO 750
  760 NEXT i%
  770 PRINT "Create 3D object"
  780 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  790 PRINT "Scale object"
  800 scale=1.0*256.0
  810 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  820 PRINT "Create target bitmap"
  830 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  840 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  850 PRINT "Render 3D object"
  860 VDU 23, 0, &C3: REM Flip buffer
  870 rotatex=0.0: rotatey=0.0: rotatez=0.0
  880 factor=32767.0/pi2
  890 VDU 22, 136: REM 320x240x64 double-buffered
  900 VDU 23, 0, &C0, 0: REM Normal coordinates
  910 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  920 VDU 17,7+128 : REM set text background color to light gray
  930 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  940 inc=0.122718463
  950 REM --== MAIN LOOP ==--
  960 CLS
  970 incx=0.0:incy=0.0:incz=inc
  980 REM incx=inc/2:incy=inc:incz=inc*2
  990 ON ERROR GOTO 1200 : REM so that Escape key exits gracefully
 1000 REM A%=INKEY(0) : REM GET KEYBOARD INPUT FROM PLAYER.
 1010 REM PRINT "keycode ";A%
 1020 REM IF A%=21 THEN incz=-inc :REM RIGHT.
 1030 REM IF A%=8 THEN incz=inc :REM LEFT.
 1040 REM IF A%=10 THEN incy=inc :REM DOWN.
 1050 REM IF A%=11 THEN incy=-inc :REM UP.
 1060 PRINT "rotate x=";rotatex
 1070 PRINT "rotate y=";rotatey
 1080 PRINT "rotate z=";rotatez
 1090 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
 1100 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
 1110 VDU 23, 0, &C3: REM Flip buffer
 1120 *FX 19
 1130 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
 1140 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
 1150 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
 1160 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
 1170 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
 1180 GOTO 960
 1190 REM -- EXIT PROGRAM --
 1200 VDU 22, 3: REM 640x240x64 single-buffered
 1210 VDU 23, 0, &C0, 0: REM Normal coordinates
 1220 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1230 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1240 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1250 CLS
 1260 END
   10 REM Sample app to illustrate Pingo 3D on Agon
20 model_vertices%=8
30 model_indexes%=36
   40 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
   50 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
   60 CLS
   70 REM -- CODE --
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
  680 incx=1*PI/256.0: incy=2*PI/256.0: incz=0.5*PI/256.0
  690 factor=32767.0/pi2
  700 VDU 22, 136: REM 320x240x64
  710 VDU 23, 0, &C0, 0: REM Normal coordinates
  720 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  730 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
  740 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
  750 CLG
  760 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
  770 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
  780 VDU 23, 0, &C3: REM Flip buffer
  790 *FX 19
  800 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
  810 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
  820 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
  830 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
  840 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
  850 GOTO 750
1000 REM -- VERTICES --
1010 DATA 1.00000000, 1.00000000, 1.00000000
1020 DATA 1.00000000, 1.00000000, -1.00000000
1030 DATA 1.00000000, -1.00000000, 1.00000000
1040 DATA 1.00000000, -1.00000000, -1.00000000
1050 DATA -1.00000000, 1.00000000, 1.00000000
1060 DATA -1.00000000, 1.00000000, -1.00000000
1070 DATA -1.00000000, -1.00000000, 1.00000000
1080 DATA -1.00000000, -1.00000000, -1.00000000
1090 REM
1100 REM -- INDEXES --
1110 DATA 4, 2, 0
1120 DATA 2, 7, 3
1130 DATA 6, 5, 7
1140 DATA 1, 7, 5
1150 DATA 0, 3, 1
1160 DATA 4, 1, 5
1170 DATA 4, 6, 2
1180 DATA 2, 6, 7
1190 DATA 6, 4, 5
1200 DATA 1, 3, 7
1210 DATA 0, 2, 3
1220 DATA 4, 0, 1

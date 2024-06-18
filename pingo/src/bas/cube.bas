10 REM teapot.bas
20 REM Sample app to illustrate Pingo 3D on Agon
30 REM
40 REM -- VERTICES --
50 model_vertices%=8
60 model_indexes%=36
70 DATA 1.00000000, 1.00000000, 1.00000000
80 DATA 1.00000000, 1.00000000, -1.00000000
90 DATA 1.00000000, -1.00000000, 1.00000000
100 DATA 1.00000000, -1.00000000, -1.00000000
110 DATA -1.00000000, 1.00000000, 1.00000000
120 DATA -1.00000000, 1.00000000, -1.00000000
130 DATA -1.00000000, -1.00000000, 1.00000000
140 DATA -1.00000000, -1.00000000, -1.00000000
160 REM
170 REM -- INDEXES --
180 DATA 4, 2, 0
190 DATA 2, 7, 3
200 DATA 6, 5, 7
210 DATA 1, 7, 5
220 DATA 0, 3, 1
230 DATA 4, 1, 5
240 DATA 4, 6, 2
250 DATA 2, 6, 7
260 DATA 6, 4, 5
270 DATA 1, 3, 7
280 DATA 0, 2, 3
290 DATA 4, 0, 1
2000 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
2010 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
6130 REM
6140 REM -- CODE --
6150 PRINT "Reading vertices"
6160 total_coords%=model_vertices%*3
6170 max_abs=-99999
6180 DIM vertices(total_coords%)
6190 FOR i%=0 TO total_coords%-1
6200   READ coord
6210   vertices(i%)=coord
6220   a=ABS(coord)
6230   IF a>max_abs THEN max_abs=a
6240 NEXT i%
6250 factor=32767.0/max_abs
6260 PRINT "Max absolute value = ";max_abs
6270 PRINT "Factor = ";factor
6280 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
6290 PRINT "Creating control structure"
6300 scene_width%=96: scene_height%=96
6310 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
6320 f=32767.0/256.0
6330 distx=0*f: disty=2*f: distz=-25*f
6340 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
6350 pi2=PI*2.0: f=32767.0/pi2
6360 anglex=-0.4*f
6370 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
6380 PRINT "Sending vertices using factor ";factor
6390 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
6400 FOR i%=0 TO total_coords%-1
6410   val%=vertices(i%)*factor
6420   VDU val%;
6430   T%=TIME
6440   IF TIME-T%<1 GOTO 6440
6450 NEXT i%
6460 PRINT "Reading and sending vertex indexes"
6470 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indexes%; : REM Set Mesh Vertex Indexes
6480 FOR i%=0 TO model_indexes%-1
6490   READ val%
6500   VDU val%;
6510   T%=TIME
6520   IF TIME-T%<1 GOTO 6520
6530 NEXT i%
6540 PRINT "Sending texture coordinate indexes"
6550 VDU 23,0, &A0, sid%; &49, 3, mid%; 1; 32768; 32768; : REM Define Texture Coordinates
6560 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indexes%; : REM Set Texture Coordinate Indexes
6570 FOR i%=0 TO model_indexes%-1
6580   VDU 0;
6590 NEXT i%
6600 PRINT "Creating texture bitmap"
6610 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
6620 PRINT "Setting texture pixel"
6630 VDU 23, 27, 1, 1; 1; &55, &AA, &FF, &C0 : REM Set a pixel in the bitmap
6640 PRINT "Create 3D object"
6650 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
6660 PRINT "Scale object"
6670 scale=6.0*256.0
6680 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
6690 PRINT "Create target bitmap"
6700 VDU 23, 27, 0, bmid2% : REM Select output bitmap
6710 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
6720 PRINT "Render 3D object"
6730 VDU 23, 0, &C3: REM Flip buffer
6740 rotatex=0.0: rotatey=0.0: rotatez=0.0
6750 REM incx=PI/16.0: incy=PI/32.0: incz=PI/64.0
6755 incx=1*PI/256.0: incy=0*PI/256.0: incz=0.5*PI/256.0
6760 factor=32767.0/pi2
6770 VDU 22, 136: REM 320x240x64
6780 VDU 23, 0, &C0, 0: REM Normal coordinates
6782 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
6784 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
6790 CLG
6800 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
6810 VDU 23, 27, 3, 50; 50; : REM Display output bitmap
6820 VDU 23, 0, &C3: REM Flip buffer
6830 *FX 19
6840 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
6850 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
6860 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
6870 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
6880 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
6890 GOTO 6790
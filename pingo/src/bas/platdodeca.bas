   10 REM teapot.bas
   20 REM Sample app to illustrate Pingo 3D on Agon
   30 REM
40 REM -- VERTICES --
50 model_vertices%=20
60 model_indexes%=60
100 DATA -1.00000000, -1.00000000, -1.00000000
110 DATA -1.00000000, -1.00000000, 1.00000000
120 DATA -1.00000000, 1.00000000, -1.00000000
130 DATA -1.00000000, 1.00000000, 1.00000000
140 DATA 1.00000000, -1.00000000, -1.00000000
150 DATA 1.00000000, -1.00000000, 1.00000000
160 DATA 1.00000000, 1.00000000, -1.00000000
170 DATA 1.00000000, 1.00000000, 1.00000000
180 DATA 0.00000000, -0.61803399, -1.61803399
190 DATA 0.00000000, -0.61803399, 1.61803399
200 DATA 0.00000000, 0.61803399, -1.61803399
210 DATA 0.00000000, 0.61803399, 1.61803399
220 DATA -0.61803399, -1.61803399, 0.00000000
230 DATA -0.61803399, 1.61803399, 0.00000000
240 DATA 0.61803399, -1.61803399, 0.00000000
250 DATA 0.61803399, 1.61803399, 0.00000000
260 DATA -1.61803399, 0.00000000, -0.61803399
270 DATA 1.61803399, 0.00000000, -0.61803399
280 DATA -1.61803399, 0.00000000, 0.61803399
290 DATA 1.61803399, 0.00000000, 0.61803399
240 REM
290 REM -- INDEXES --
300 DATA 0, 8, 10
310 DATA 8, 10, 2
320 DATA 10, 2, 16
330 DATA 2, 16, 0
340 DATA 16, 0, 8
350 DATA 0, 16, 18
360 DATA 16, 18, 4
370 DATA 18, 4, 12
380 DATA 4, 12, 0
390 DATA 12, 0, 16
400 DATA 0, 12, 13
410 DATA 12, 13, 1
420 DATA 13, 1, 8
430 DATA 1, 8, 0
440 DATA 8, 0, 12
450 DATA 1, 9, 11
460 DATA 9, 11, 3
470 DATA 11, 3, 13
480 DATA 3, 13, 1
490 DATA 13, 1, 9
500 DATA 1, 13, 12
510 DATA 13, 12, 4
520 DATA 12, 4, 9
530 DATA 4, 9, 1
540 DATA 9, 1, 13
550 DATA 2, 10, 11
560 DATA 10, 11, 3
570 DATA 11, 3, 14
580 DATA 3, 14, 2
590 DATA 14, 2, 10
600 DATA 2, 14, 15
610 DATA 14, 15, 6
620 DATA 15, 6, 16
630 DATA 6, 16, 2
640 DATA 16, 2, 14
650 DATA 3, 11, 9
660 DATA 11, 9, 5
670 DATA 9, 5, 15
680 DATA 5, 15, 3
690 DATA 15, 3, 11
700 DATA 4, 18, 17
710 DATA 18, 17, 6
720 DATA 17, 6, 12
730 DATA 6, 12, 4
740 DATA 12, 4, 18
750 DATA 5, 9, 4
760 DATA 9, 4, 18
770 DATA 4, 18, 19
780 DATA 18, 19, 5
790 DATA 19, 5, 9
800 DATA 5, 19, 17
810 DATA 19, 17, 6
820 DATA 17, 6, 15
830 DATA 6, 15, 5
840 DATA 15, 5, 19
850 DATA 6, 17, 18
860 DATA 17, 18, 4
870 DATA 18, 4, 16
880 DATA 4, 16, 6
890 DATA 16, 6, 17
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
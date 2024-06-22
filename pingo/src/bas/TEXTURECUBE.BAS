   10 REM pingocube.bas
   20 REM Sample app to illustrate Pingo 3D on Agon
   30 REM
   50 cube_vertices%=8
   60 cube_indexes%=36
   90 REM -- VERTICES --
  100 DATA -32767, 32767, 32767
  110 DATA  32767, 32767, 32767
  120 DATA -32767,-32767, 32767
  130 DATA  32767,-32767, 32767
  140 DATA -32767, 32767,-32767
  150 DATA  32767, 32767,-32767
  160 DATA -32767,-32767,-32767
  170 DATA  32767,-32767,-32767
  180 REM
  190 REM -- INDEXES --
  200 DATA 0,2,1
  210 DATA 1,2,3
  220 DATA 6,4,7
  230 DATA 7,4,5
  240 DATA 1,3,5
  250 DATA 5,3,7
  260 DATA 2,0,6
  270 DATA 6,0,4
  280 DATA 2,6,3
  290 DATA 3,6,7
  300 DATA 0,1,4
  310 DATA 4,1,5
  320 REM
  900 bmid1%=101: bmid2%=102
 1000 bitmap_x%=4
 1010 bitmap_y%=4
 1020 DATA &FF,&00,&00,&FF
 1030 DATA &FF,&00,&00,&FF
 1040 DATA &FF,&00,&00,&FF
 1050 DATA &FF,&00,&00,&FF
 1060 DATA &00,&FF,&00,&FF
 1070 DATA &00,&FF,&00,&FF
 1080 DATA &00,&FF,&00,&FF
 1090 DATA &00,&FF,&00,&FF
 1100 DATA &00,&00,&FF,&FF
 1110 DATA &00,&00,&FF,&FF
 1120 DATA &00,&00,&FF,&FF
 1130 DATA &00,&00,&FF,&FF
 1140 DATA &FF,&FF,&00,&FF
 1150 DATA &FF,&FF,&00,&FF
 1160 DATA &FF,&FF,&00,&FF
 1170 DATA &FF,&FF,&00,&FF
 1180 REM
 5000 total_pixels%=bitmap_x%*bitmap_y%*4
 5010 VDU 23, 27, 0, bmid1%: REM Create bitmap for texture
 5020 PRINT "Setting texture pixels"
 5025 RESTORE 1020
 5030 VDU 23, 27, 1, bitmap_x%; bitmap_y%; : REM Set bitmap pixels
 5040 FOR i%=0 TO total_pixels%-1
 5050   READ val%
 5055   PRINT val%;
 5060   VDU val%
 5070   T%=TIME
 5080   IF TIME-T%<1 GOTO 5080
 5090 NEXT i%
 5200 VDU 23, 27, 3, 0; 0;
 6130 REM
 6140 REM -- CODE --
 6150 PRINT "Reading vertices"
 6155 RESTORE 100
 6160 total_coords%=cube_vertices%*3
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
 6280 sid%=100: mid%=1: oid%=1:REM bmid1%=101:REM bmid2%=102
 6290 PRINT "Creating control structure"
 6300 scene_width%=96: scene_height%=96
 6310 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
 6320 f=32767.0/256.0
 6330 distx=0*f: disty=2*f: distz=-40*f
 6340 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
 6350 pi2=PI*2.0: f=32767.0/pi2
 6360 anglex=-0.4*f
 6370 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
 6380 PRINT "Sending vertices using factor ";factor
 6390 VDU 23,0, &A0, sid%; &49, 1, mid%; cube_vertices%; : REM Define Mesh Vertices
 6400 FOR i%=0 TO total_coords%-1
 6410   val%=vertices(i%)*factor
 6420   VDU val%;
 6430   T%=TIME
 6440   IF TIME-T%<1 GOTO 6440
 6450 NEXT i%
 6460 PRINT "Reading and sending vertex indexes"
 6465 RESTORE 200
 6470 VDU 23,0, &A0, sid%; &49, 2, mid%; cube_indexes%; : REM Set Mesh Vertex Indexes
 6480 FOR i%=0 TO cube_indexes%-1
 6490   READ val%
 6500   VDU val%;
 6510   T%=TIME
 6520   IF TIME-T%<1 GOTO 6520
 6530 NEXT i%
 6540 PRINT "Sending texture coordinate indexes"
 6550 VDU 23,0, &A0, sid%; &49, 3, mid%; 4; 1; 1; 1; 65534; 65534; 1; 65534; 65534; : REM Define Texture Coordinates
 6560 VDU 23,0, &A0, sid%; &49, 4, mid%; cube_indexes%; : REM Set Texture Coordinate Indexes
 6570 FOR i%=0 TO cube_indexes%-1
 6580   VDU i% MOD 4;
 6590 NEXT i%
 6600 PRINT "Creating texture bitmap"
 6610 REM VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
 6620 REM PRINT "Setting texture pixel"
 6630 REM VDU 23, 27, 1, 1; 1; &55, &AA, &FF, &C0 : REM Set a pixel in the bitmap
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
 6750 incx=PI/16.0: incy=PI/32.0: incz=PI/64.0
 6760 factor=32767.0/pi2
 6770 VDU 22, 136: REM 320x240x64
 6780 VDU 23, 0, &C0, 0: REM Normal coordinates
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

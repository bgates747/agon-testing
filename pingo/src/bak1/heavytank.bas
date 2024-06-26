   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=22
   30 model_indices%=108
   40 model_uvs%=37
   50 texture_width%=8 : texture_height%=8
   60 camf=32767.0/256.0
   70 camx=0.0*camf
   72 camy=0.0*camf
   74 camz=-10.0*camf
   80 pi2=PI*2.0: camanglef=32767.0/pi2
   90 camanglex=0.0*camanglef
  100 scale=1.0*256.0
  110 rotatex=0.75
  112 rotatey=0.0
  114 rotatez=0.0
  120 rfactor=32767.0/pi2
  130 inc=0.122718463
  140 incx=0.0
  142 incy=0.0
  144 incz=inc*0.5
  150 scene_width%=320: scene_height%=240
  160 VDU 17, 4+128 : REM SET TEXT BACKGROUND COLOR TO DARK BLUE
  170 VDU 18, 0, 4+128 : REM SET GFX BACKGROUND COLOR TO DARK BLUE
  180 CLS
  190 REM --== INITIALIZATION ==--
  200 PRINT "Reading vertices"
  210 total_coords%=model_vertices%*3
  220 max_abs=-99999
  230 DIM vertices(total_coords%)
  240 FOR i%=0 TO total_coords%-1
  250   READ coord
  260   vertices(i%)=coord
  270   a=ABS(coord)
  280   IF a>max_abs THEN max_abs=a
  290 NEXT i%
  300 factor=32767.0 :REM factor=32767.0/max_abs
  310 PRINT "Max absolute value = ";max_abs
  320 PRINT "Factor = ";factor
  330 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
  340 PRINT "Creating control structure"
  350 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
  360 PRINT "Setting camera translation distances"
  370 VDU 23,0, &A0, sid%; &49, 25, camx; camy; camz;
  380 PRINT "Set Camera X Rotation Angle"
  390 VDU 23,0, &A0, sid%; &49, 18, camanglex;
  400 PRINT "Sending vertices using factor ";factor
  410 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
  420 FOR i%=0 TO total_coords%-1
  430   val%=vertices(i%)*factor
  440   VDU val%;
  450   REM T%=TIME
  460   REM IF TIME-T%<1 GOTO 390
  470 NEXT i%
  480 PRINT "Reading and sending vertex indices"
  490 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indices%; : REM Set Mesh Vertex indices
  500 FOR i%=0 TO model_indices%-1
  510   READ val%
  520   VDU val%;
  530   REM T%=TIME
  540   REM IF TIME-T%<1 GOTO 470
  550 NEXT i%
  560 PRINT "Sending texture UV coordinates"
  570 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
  580 total_uvs%=model_uvs%*2
  590 FOR i%=0 TO total_uvs%-1
  600   READ val
  610   val%=INT(val*65535)
  620   VDU val%;
  630   REM T%=TIME
  640   REM IF TIME-T%<1 GOTO 570
  650 NEXT i%
  660 PRINT "Sending Texture Coordinate indices"
  670 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
  680 FOR i%=0 TO model_indices%-1
  690   READ val%
  700   VDU val%;
  710   REM T%=TIME
  720   REM IF TIME-T%<1 GOTO 650
  730 NEXT i%
  740 PRINT "Creating texture bitmap"
  750 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
  760 PRINT "Sending texture pixel data"
  770 VDU 23, 27, 1, texture_width%; texture_height%; 
  780 FOR i%=0 TO texture_width%*texture_height%*4-1
  790   READ val%
  800   VDU val% : REM 8-bit integers for pixel data
  810   REM T%=TIME
  820   REM IF TIME-T%<1 GOTO 750
  830 NEXT i%
  840 PRINT "Create 3D object"
  850 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
  860 PRINT "Scale object"
  870 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
  880 PRINT "Create target bitmap"
  890 VDU 23, 27, 0, bmid2% : REM Select output bitmap
  900 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
  910 PRINT "Render 3D object"
  920 VDU 23, 0, &C3: REM Flip buffer
  930 VDU 22, 136: REM 320x240x64 double-buffered
  940 VDU 23, 0, &C0, 0: REM Normal coordinates
  950 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
  960 VDU 17,7+128 : REM set text background color to light gray
  970 VDU 18, 0, 7+128 : REM set gfx background color to light gray
  980 REM --== MAIN LOOP ==--
  990 CLS
 1000 ON ERROR GOTO 1150 : REM so that Escape key exits gracefully
1005 PRINT "filename=pingo/src/bas/heavytank.bas"
 1010 PRINT "rotate x=";rotatex
 1020 PRINT "rotate y=";rotatey
 1030 PRINT "rotate z=";rotatez
 1040 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
 1050 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
 1060 VDU 23, 0, &C3: REM Flip buffer
 1070 *FX 19 : REM wait for vblank
 1080 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
 1090 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
 1100 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
 1110 rx=rotatex*rfactor: ry=rotatey*rfactor: rz=rotatez*rfactor
 1120 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
 1130 GOTO 990
 1140 REM -- EXIT PROGRAM --
 1150 VDU 22, 3: REM 640x240x64 single-buffered
 1160 VDU 23, 0, &C0, 0: REM Normal coordinates
 1170 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
 1180 VDU 17, 0+128 : REM SET TEXT BACKGROUND COLOR TO BLACK
 1190 VDU 18, 0, 0+128 : REM SET GFX BACKGROUND COLOR TO BLACK
 1200 CLS
 1210 END

2000 REM -- VERTICES --
2002 DATA 0.5, -1.0, -0.4
2004 DATA 0.4, -0.6, 0.0
2006 DATA 0.5, 1.0, -0.4
2008 DATA 0.4, 0.6, 0.0
2010 DATA -0.5, -1.0, -0.4
2012 DATA -0.4, -0.6, 0.0
2014 DATA -0.5, 1.0, -0.4
2016 DATA -0.4, 0.6, 0.0
2018 DATA -0.5, 0.0, -0.6
2020 DATA 0.3, 0.7, -1.0
2022 DATA -0.3, 0.7, -1.0
2024 DATA 0.3, 0.3, -1.0
2026 DATA -0.3, 0.3, -1.0
2028 DATA 0.5, 0.0, -0.6
2030 DATA -0.1, 0.3, -0.7
2032 DATA -0.1, 0.3, -0.9
2034 DATA -0.1, -1.0, -0.7
2036 DATA -0.1, -1.0, -0.9
2038 DATA 0.1, 0.3, -0.7
2040 DATA 0.1, 0.3, -0.9
2042 DATA 0.1, -1.0, -0.7
2044 DATA 0.1, -1.0, -0.9
2046 REM -- FACE VERTEX INDICES --
2048 DATA 6, 12, 8
2050 DATA 2, 7, 3
2052 DATA 6, 4, 5
2054 DATA 1, 7, 5
2056 DATA 0, 2, 3
2058 DATA 4, 1, 5
2060 DATA 4, 13, 0
2062 DATA 2, 10, 6
2064 DATA 9, 12, 10
2066 DATA 11, 8, 12
2068 DATA 10, 12, 6
2070 DATA 15, 16, 14
2072 DATA 17, 20, 16
2074 DATA 21, 18, 20
2076 DATA 19, 14, 18
2078 DATA 20, 14, 16
2080 DATA 17, 19, 21
2082 DATA 2, 11, 9
2084 DATA 13, 11, 2
2086 DATA 2, 6, 7
2088 DATA 5, 7, 6
2090 DATA 6, 8, 4
2092 DATA 1, 3, 7
2094 DATA 3, 1, 0
2096 DATA 0, 13, 2
2098 DATA 4, 0, 1
2100 DATA 4, 8, 13
2102 DATA 2, 9, 10
2104 DATA 9, 11, 12
2106 DATA 11, 13, 8
2108 DATA 15, 17, 16
2110 DATA 17, 21, 20
2112 DATA 21, 19, 18
2114 DATA 19, 15, 14
2116 DATA 20, 18, 14
2118 DATA 17, 15, 19
2120 REM -- TEXTURE UV COORDINATES --
2122 DATA 1.0, 0.875
2124 DATA 0.875, 0.875
2126 DATA 0.875, 0.75
2128 DATA 0.0, 0.875
2130 DATA 0.125, 0.75
2132 DATA 0.125, 0.875
2134 DATA 0.887702, 0.800449
2136 DATA 0.968277, 0.85899
2138 DATA 0.987299, 0.800449
2140 DATA 0.5, 0.125
2142 DATA 0.625, 0.0
2144 DATA 0.625, 0.125
2146 DATA 0.387702, 0.175449
2148 DATA 0.468277, 0.23399
2150 DATA 0.487298, 0.175449
2152 DATA 0.375, 1.0
2154 DATA 0.5, 0.875
2156 DATA 0.5, 1.0
2158 DATA 0.0, 0.25
2160 DATA 0.125, 0.125
2162 DATA 0.125, 0.25
2164 DATA 1.0, 0.75
2166 DATA 0.375, 0.25
2168 DATA 0.5, 0.25
2170 DATA 0.0, 0.5
2172 DATA 0.125, 0.375
2174 DATA 0.125, 0.5
2176 DATA 0.375, 0.125
2178 DATA 0.0, 0.75
2180 DATA 0.9375, 0.764268
2182 DATA 0.906723, 0.85899
2184 DATA 0.5, 0.0
2186 DATA 0.4375, 0.139268
2188 DATA 0.406723, 0.23399
2190 DATA 0.375, 0.875
2192 DATA 0.0, 0.125
2194 DATA 0.0, 0.375
2196 REM -- TEXTURE VERTEX INDICES --
2198 DATA 0, 1, 2
2200 DATA 3, 4, 5
2202 DATA 6, 7, 8
2204 DATA 9, 10, 11
2206 DATA 12, 13, 14
2208 DATA 15, 16, 17
2210 DATA 18, 19, 20
2212 DATA 3, 4, 5
2214 DATA 18, 19, 20
2216 DATA 15, 16, 17
2218 DATA 0, 1, 2
2220 DATA 1, 21, 0
2222 DATA 15, 16, 17
2224 DATA 22, 9, 23
2226 DATA 3, 4, 5
2228 DATA 9, 10, 11
2230 DATA 24, 25, 26
2232 DATA 23, 22, 27
2234 DATA 23, 22, 27
2236 DATA 3, 28, 4
2238 DATA 8, 29, 6
2240 DATA 6, 30, 7
2242 DATA 9, 31, 10
2244 DATA 14, 32, 12
2246 DATA 12, 33, 13
2248 DATA 15, 34, 16
2250 DATA 18, 35, 19
2252 DATA 3, 28, 4
2254 DATA 18, 35, 19
2256 DATA 15, 34, 16
2258 DATA 1, 2, 21
2260 DATA 15, 34, 16
2262 DATA 22, 27, 9
2264 DATA 3, 28, 4
2266 DATA 9, 31, 10
2268 DATA 24, 36, 25
2270 REM -- TEXTURE BITMAP --
2272 DATA 0,0,0,255,0,0,85,255,0,0,170,255,0,0,255,255
2274 DATA 0,85,0,255,0,85,85,255,0,85,170,255,0,85,255,255
2276 DATA 0,170,0,255,0,170,85,255,0,170,170,255,0,170,255,255
2278 DATA 0,255,0,255,0,255,85,255,0,255,170,255,0,255,255,255
2280 DATA 85,0,0,255,85,0,85,255,85,0,170,255,85,0,255,255
2282 DATA 85,85,0,255,85,85,85,255,85,85,170,255,85,85,255,255
2284 DATA 85,170,0,255,85,170,85,255,85,170,170,255,85,170,255,255
2286 DATA 85,255,0,255,85,255,85,255,85,255,170,255,85,255,255,255
2288 DATA 170,0,0,255,170,0,85,255,170,0,170,255,170,0,255,255
2290 DATA 170,85,0,255,170,85,85,255,170,85,170,255,170,85,255,255
2292 DATA 170,170,0,255,170,170,85,255,170,170,170,255,170,170,255,255
2294 DATA 170,255,0,255,170,255,85,255,170,255,170,255,170,255,255,255
2296 DATA 255,0,0,255,255,0,85,255,255,0,170,255,255,0,255,255
2298 DATA 255,85,0,255,255,85,85,255,255,85,170,255,255,85,255,255
2300 DATA 255,170,0,255,255,170,85,255,255,170,170,255,255,170,255,255
2302 DATA 255,255,0,255,255,255,85,255,255,255,170,255,255,255,255,255

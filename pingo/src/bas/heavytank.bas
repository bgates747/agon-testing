   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=22
   30 model_indices%=102
   40 model_uvs%=45
   50 texture_width%=8 : texture_height%=8
   60 camf=32767.0/256.0
   70 camx=0.0*camf
   72 camy=0.0*camf
   74 camz=-10.0*camf
   80 pi2=PI*2.0: camanglef=32767.0/pi2
   90 camanglex=0.0*camanglef
  100 scale=1.0*256.0
  110 rotatex=0.0: rotatey=0.0: rotatez=0.0
  120 rfactor=32767.0/pi2
  130 inc=0.122718463
  140 incx=inc/2
  142 incy=0.0
  144 incz=inc
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
2002 DATA -0.3, 0.0, 0.8
2004 DATA -0.5, 0.4, -1.0
2006 DATA -0.3, 0.0, -0.8
2008 DATA 0.3, 0.0, 0.8
2010 DATA 0.5, 0.4, -1.0
2012 DATA 0.3, 0.0, -0.8
2014 DATA -0.4, 0.4, 1.0
2016 DATA 0.4, 0.4, 1.0
2018 DATA 0.3, 1.0, 0.7
2020 DATA -0.3, 0.6, 0.0
2022 DATA 0.3, 0.6, 0.0
2024 DATA -0.3, 1.0, 0.7
2026 DATA -0.3, 1.0, 0.3
2028 DATA 0.3, 1.0, 0.3
2030 DATA 0.0, 0.8, 0.3
2032 DATA 0.1, 0.8, 0.3
2034 DATA 0.0, 0.9, 0.3
2036 DATA 0.1, 0.9, 0.3
2038 DATA 0.0, 0.8, -1.0
2040 DATA 0.1, 0.8, -1.0
2042 DATA 0.0, 0.9, -1.0
2044 DATA 0.1, 0.9, -1.0
2046 REM -- FACE VERTEX INDICES --
2048 DATA 6, 9, 1
2050 DATA 4, 10, 7
2052 DATA 11, 9, 6
2054 DATA 7, 11, 6
2056 DATA 10, 8, 7
2058 DATA 10, 13, 8
2060 DATA 18, 15, 14
2062 DATA 12, 9, 11
2064 DATA 18, 21, 19
2066 DATA 9, 13, 10
2068 DATA 20, 14, 16
2070 DATA 21, 16, 17
2072 DATA 19, 17, 15
2074 DATA 1, 10, 4
2076 DATA 3, 4, 7
2078 DATA 2, 4, 5
2080 DATA 0, 1, 2
2082 DATA 3, 6, 0
2084 DATA 11, 13, 12
2086 DATA 0, 5, 3
2088 DATA 7, 8, 11
2090 DATA 18, 19, 15
2092 DATA 18, 20, 21
2094 DATA 9, 12, 13
2096 DATA 20, 18, 14
2098 DATA 21, 20, 16
2100 DATA 19, 21, 17
2102 DATA 1, 9, 10
2104 DATA 3, 5, 4
2106 DATA 2, 1, 4
2108 DATA 0, 6, 1
2110 DATA 3, 7, 6
2112 DATA 11, 8, 13
2114 DATA 0, 2, 5
2116 REM -- TEXTURE UV COORDINATES --
2118 DATA 0.375, 0.375
2120 DATA 0.25, 0.375
2122 DATA 0.25, 0.25
2124 DATA 0.875, 0.875
2126 DATA 0.75, 0.875
2128 DATA 0.75, 0.75
2130 DATA 0.0, 0.625
2132 DATA 0.125, 0.5
2134 DATA 0.125, 0.625
2136 DATA 0.375, 0.25
2138 DATA 0.25, 0.125
2140 DATA 0.0, 0.375
2142 DATA 0.125, 0.25
2144 DATA 0.125, 0.375
2146 DATA 0.125, 1.0
2148 DATA 0.25, 0.875
2150 DATA 0.25, 1.0
2152 DATA 0.75, 1.0
2154 DATA 0.875, 1.0
2156 DATA 0.375, 0.75
2158 DATA 0.375, 0.875
2160 DATA 0.125, 0.75
2162 DATA 0.25, 0.625
2164 DATA 0.25, 0.75
2166 DATA 0.5, 0.25
2168 DATA 0.625, 0.125
2170 DATA 0.625, 0.25
2172 DATA 0.375, 0.125
2174 DATA 0.5, 0.125
2176 DATA 0.375, 1.0
2178 DATA 0.5, 0.875
2180 DATA 0.5, 1.0
2182 DATA 1.0, 0.875
2184 DATA 0.875, 0.75
2186 DATA 1.0, 0.75
2188 DATA 0.625, 0.75
2190 DATA 0.625, 0.875
2192 DATA 0.0, 0.25
2194 DATA 0.125, 0.125
2196 DATA 0.625, 0.0
2198 DATA 0.0, 0.5
2200 DATA 0.125, 0.875
2202 DATA 0.5, 0.75
2204 DATA 0.0, 0.125
2206 DATA 0.5, 0.0
2208 REM -- TEXTURE VERTEX INDICES --
2210 DATA 0, 1, 2
2212 DATA 0, 1, 2
2214 DATA 3, 4, 5
2216 DATA 6, 7, 8
2218 DATA 9, 2, 10
2220 DATA 0, 1, 2
2222 DATA 11, 12, 13
2224 DATA 0, 1, 2
2226 DATA 14, 15, 16
2228 DATA 17, 3, 18
2230 DATA 15, 19, 20
2232 DATA 11, 12, 13
2234 DATA 21, 22, 23
2236 DATA 24, 25, 26
2238 DATA 24, 27, 28
2240 DATA 29, 30, 31
2242 DATA 32, 33, 34
2244 DATA 30, 35, 36
2246 DATA 37, 38, 12
2248 DATA 28, 39, 25
2250 DATA 6, 40, 7
2252 DATA 11, 37, 12
2254 DATA 14, 41, 15
2256 DATA 17, 4, 3
2258 DATA 15, 23, 19
2260 DATA 11, 37, 12
2262 DATA 21, 8, 22
2264 DATA 24, 28, 25
2266 DATA 24, 9, 27
2268 DATA 29, 20, 30
2270 DATA 32, 3, 33
2272 DATA 30, 42, 35
2274 DATA 37, 43, 38
2276 DATA 28, 44, 39
2278 REM -- TEXTURE BITMAP --
2280 DATA 0,0,0,255,0,0,85,255,0,0,170,255,0,0,255,255
2282 DATA 0,85,0,255,0,85,85,255,0,85,170,255,0,85,255,255
2284 DATA 0,170,0,255,0,170,85,255,0,170,170,255,0,170,255,255
2286 DATA 0,255,0,255,0,255,85,255,0,255,170,255,0,255,255,255
2288 DATA 85,0,0,255,85,0,85,255,85,0,170,255,85,0,255,255
2290 DATA 85,85,0,255,85,85,85,255,85,85,170,255,85,85,255,255
2292 DATA 85,170,0,255,85,170,85,255,85,170,170,255,85,170,255,255
2294 DATA 85,255,0,255,85,255,85,255,85,255,170,255,85,255,255,255
2296 DATA 170,0,0,255,170,0,85,255,170,0,170,255,170,0,255,255
2298 DATA 170,85,0,255,170,85,85,255,170,85,170,255,170,85,255,255
2300 DATA 170,170,0,255,170,170,85,255,170,170,170,255,170,170,255,255
2302 DATA 170,255,0,255,170,255,85,255,170,255,170,255,170,255,255,255
2304 DATA 255,0,0,255,255,0,85,255,255,0,170,255,255,0,255,255
2306 DATA 255,85,0,255,255,85,85,255,255,85,170,255,255,85,255,255
2308 DATA 255,170,0,255,255,170,85,255,255,170,170,255,255,170,255,255
2310 DATA 255,255,0,255,255,255,85,255,255,255,170,255,255,255,255,255

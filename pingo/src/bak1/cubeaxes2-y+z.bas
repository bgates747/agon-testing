   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=9
   30 model_indices%=42
   40 model_uvs%=25
   50 texture_width%=32 : texture_height%=32
   60 camf=32767.0/256.0
   70 camx=0.0*camf
   72 camy=0.*camf
   74 camz=-4.0*camf
   80 pi2=PI*2.0: camanglef=32767.0/pi2
   90 camanglex=0.0*camanglef
  100 scale=1.0*256.0
  110 rotatex=0.0
  112 rotatey=0.0
  114 rotatez=0.0
  120 rfactor=32767.0/pi2
  130 inc=0.122718463
  140 incx=inc*0.0
  142 incy=inc*0.5
  144 incz=inc*0.0
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
1005 PRINT "filename=pingo/src/bas/cubeaxes2-y+z.bas"
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
2002 DATA -0.44, -0.5, 0.26
2004 DATA -0.25, -0.5, -0.5
2006 DATA -0.44, 0.5, 0.26
2008 DATA -0.25, 0.5, -0.5
2010 DATA 0.5, -0.5, 0.5
2012 DATA 0.25, -0.5, -0.5
2014 DATA 0.5, 0.5, 0.5
2016 DATA 0.25, 0.5, -0.5
2018 DATA 0.0, -1.0, 0.0
2020 REM -- FACE VERTEX INDICES --
2022 DATA 4, 2, 0
2024 DATA 2, 7, 3
2026 DATA 6, 5, 7
2028 DATA 1, 7, 5
2030 DATA 0, 3, 1
2032 DATA 4, 0, 8
2034 DATA 4, 8, 5
2036 DATA 5, 8, 1
2038 DATA 1, 8, 0
2040 DATA 4, 6, 2
2042 DATA 2, 6, 7
2044 DATA 6, 4, 5
2046 DATA 1, 3, 7
2048 DATA 0, 2, 3
2050 REM -- TEXTURE UV COORDINATES --
2052 DATA 0.0, 0.0
2054 DATA 0.3125, 0.3125
2056 DATA 0.0, 0.3125
2058 DATA 0.34375, 1.0
2060 DATA 0.65625, 0.6875
2062 DATA 0.65625, 1.0
2064 DATA 0.6875, 0.3125
2066 DATA 1.0, 0.0
2068 DATA 1.0, 0.3125
2070 DATA 1.0, 1.0
2072 DATA 0.6875, 0.6875
2074 DATA 1.0, 0.6875
2076 DATA 0.0, 1.0
2078 DATA 0.3125, 0.6875
2080 DATA 0.3125, 1.0
2082 DATA 0.34375, 0.3125
2084 DATA 0.34375, 0.0
2086 DATA 0.46875, 0.15625
2088 DATA 0.65625, 0.3125
2090 DATA 0.65625, 0.0
2092 DATA 0.3125, 0.0
2094 DATA 0.34375, 0.6875
2096 DATA 0.6875, 0.0
2098 DATA 0.6875, 1.0
2100 DATA 0.0, 0.6875
2102 REM -- TEXTURE VERTEX INDICES --
2104 DATA 0, 1, 2
2106 DATA 3, 4, 5
2108 DATA 6, 7, 8
2110 DATA 9, 10, 11
2112 DATA 12, 13, 14
2114 DATA 15, 16, 17
2116 DATA 15, 17, 18
2118 DATA 18, 17, 19
2120 DATA 19, 17, 16
2122 DATA 0, 20, 1
2124 DATA 3, 21, 4
2126 DATA 6, 22, 7
2128 DATA 9, 23, 10
2130 DATA 12, 24, 13
2132 REM -- TEXTURE BITMAP --
2134 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2136 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2138 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2140 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2142 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2144 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2146 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2148 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2150 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2152 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
2154 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2156 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
2158 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2160 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2162 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2164 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2166 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2168 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
2170 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2172 DATA 0,0,255,255,0,0,255,255,255,255,255,255,255,255,255,255
2174 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2176 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2178 DATA 0,255,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2180 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2182 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2184 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
2186 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2188 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
2190 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2192 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2194 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2196 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2198 DATA 85,0,0,255,255,255,255,255,255,255,255,255,85,0,0,255
2200 DATA 85,0,0,255,85,0,0,255,255,255,255,255,255,255,255,255
2202 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2204 DATA 255,255,255,255,255,255,255,255,0,0,255,255,0,0,255,255
2206 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2208 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2210 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2212 DATA 255,255,255,255,255,255,255,255,0,255,0,255,0,255,0,255
2214 DATA 85,0,0,255,85,0,0,255,85,0,0,255,255,255,255,255
2216 DATA 85,0,0,255,255,255,255,255,85,0,0,255,85,0,0,255
2218 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2220 DATA 255,255,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2222 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2224 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2226 DATA 0,255,0,255,0,255,0,255,0,255,0,255,255,255,255,255
2228 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2230 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2232 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
2234 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2236 DATA 255,255,255,255,0,0,255,255,0,0,255,255,255,255,255,255
2238 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2240 DATA 0,0,255,255,0,0,0,255,0,255,0,255,255,255,255,255
2242 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,255,0,255
2244 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2246 DATA 85,0,0,255,85,0,0,255,85,0,0,255,255,255,255,255
2248 DATA 85,0,0,255,255,255,255,255,85,0,0,255,85,0,0,255
2250 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2252 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2254 DATA 255,255,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2256 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2258 DATA 0,255,0,255,0,255,0,255,0,255,0,255,255,255,255,255
2260 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2262 DATA 85,0,0,255,255,255,255,255,255,255,255,255,85,0,0,255
2264 DATA 85,0,0,255,85,0,0,255,255,255,255,255,255,255,255,255
2266 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2268 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2270 DATA 0,0,255,255,255,255,255,255,255,255,255,255,0,0,255,255
2272 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2274 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2276 DATA 255,255,255,255,255,255,255,255,0,255,0,255,0,255,0,255
2278 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2280 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2282 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
2284 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2286 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2288 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
2290 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2292 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2294 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2296 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2298 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2300 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2302 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2304 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2306 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2308 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2310 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2312 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2314 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2316 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2318 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2320 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2322 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2324 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2326 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2328 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2330 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2332 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2334 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2336 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2338 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2340 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2342 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2344 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2346 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2348 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2350 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2352 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2354 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2356 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2358 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2360 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2362 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2364 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2366 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2368 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2370 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2372 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2374 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2376 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2378 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2380 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2382 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2384 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2386 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2388 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2390 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2392 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2394 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2396 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2398 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2400 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2402 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2404 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2406 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2408 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2410 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2412 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2414 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2416 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2418 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2420 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2422 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2424 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2426 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2428 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2430 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2432 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2434 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2436 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2438 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2440 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2442 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2444 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2446 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2448 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2450 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2452 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2454 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2456 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2458 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
2460 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2462 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2464 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
2466 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2468 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2470 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2472 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2474 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2476 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2478 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2480 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2482 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2484 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2486 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2488 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2490 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2492 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2494 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2496 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2498 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2500 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2502 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2504 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
2506 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2508 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
2510 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2512 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2514 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2516 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2518 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2520 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
2522 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2524 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
2526 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2528 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2530 DATA 255,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2532 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2534 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2536 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
2538 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2540 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
2542 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2544 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2546 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2548 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2550 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2552 DATA 0,85,0,255,0,85,0,255,255,255,255,255,255,255,255,255
2554 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2556 DATA 255,255,255,255,255,255,255,255,0,0,85,255,0,0,85,255
2558 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
2560 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,255,255,255
2562 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,0,0,255
2564 DATA 255,255,255,255,255,255,255,255,255,0,0,255,255,0,0,255
2566 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2568 DATA 0,85,0,255,255,255,255,255,0,85,0,255,0,85,0,255
2570 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2572 DATA 255,255,255,255,0,0,85,255,255,255,255,255,0,0,85,255
2574 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
2576 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2578 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,255,255,255
2580 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2582 DATA 0,85,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2584 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
2586 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2588 DATA 255,255,255,255,0,0,85,255,0,0,85,255,255,255,255,255
2590 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
2592 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2594 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2596 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2598 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2600 DATA 0,85,0,255,255,255,255,255,0,85,0,255,0,85,0,255
2602 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2604 DATA 255,255,255,255,0,0,85,255,0,0,85,255,0,0,85,255
2606 DATA 255,255,255,255,0,0,85,255,255,255,255,255,0,0,85,255
2608 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2610 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,255,255,255
2612 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2614 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2616 DATA 0,85,0,255,0,85,0,255,255,255,255,255,255,255,255,255
2618 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2620 DATA 255,255,255,255,0,0,85,255,0,0,85,255,0,0,85,255
2622 DATA 0,0,85,255,255,255,255,255,255,255,255,255,0,0,85,255
2624 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,255,255,255
2626 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,0,0,255
2628 DATA 255,255,255,255,255,255,255,255,255,0,0,255,255,0,0,255
2630 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2632 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2634 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
2636 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2638 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2640 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
2642 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2644 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
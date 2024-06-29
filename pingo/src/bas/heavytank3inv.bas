   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=30
   30 model_indices%=144
   40 model_uvs%=144
   50 texture_width%=32 : texture_height%=32
   60 camf=32767.0/256.0
   70 camx=0.0*camf
   72 camy=0.0*camf
   74 camz=-4.0*camf
   80 pi2=PI*2.0
   85 camanglef=32767.0/360
   90 camanglex=-10.0*camanglef
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
1005 PRINT "filename=pingo/src/bas/heavytank3inv.bas"
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
2002 DATA 0.5, 1.0, -0.4
2004 DATA 0.4, 0.6, 0.0
2006 DATA 0.5, -1.0, -0.4
2008 DATA 0.4, -0.6, 0.0
2010 DATA -0.5, 1.0, -0.4
2012 DATA -0.4, 0.6, 0.0
2014 DATA -0.5, -1.0, -0.4
2016 DATA -0.4, -0.6, 0.0
2018 DATA -0.5, 0.0, -0.6
2020 DATA 0.3, -0.7, -1.0
2022 DATA -0.3, -0.7, -1.0
2024 DATA 0.3, -0.3, -1.0
2026 DATA -0.3, -0.3, -1.0
2028 DATA 0.5, 0.0, -0.6
2030 DATA -0.1, -0.3, -0.7
2032 DATA -0.1, -0.3, -0.9
2034 DATA -0.1, 1.0, -0.7
2036 DATA -0.1, 1.0, -0.9
2038 DATA 0.1, -0.3, -0.7
2040 DATA 0.1, -0.3, -0.9
2042 DATA 0.1, 1.0, -0.7
2044 DATA 0.1, 1.0, -0.9
2046 DATA 0.65, -0.3, -0.35
2048 DATA 0.55, -0.3, -0.35
2050 DATA 0.65, 0.3, -0.35
2052 DATA 0.55, 0.3, -0.35
2054 DATA 0.65, -0.3, -0.45
2056 DATA 0.55, -0.3, -0.45
2058 DATA 0.65, 0.3, -0.45
2060 DATA 0.55, 0.3, -0.45
2062 REM -- FACE VERTEX INDICES --
2064 DATA 6, 12, 8
2066 DATA 2, 7, 3
2068 DATA 8, 4, 5
2070 DATA 1, 7, 5
2072 DATA 13, 2, 3
2074 DATA 4, 1, 5
2076 DATA 4, 13, 0
2078 DATA 2, 10, 6
2080 DATA 9, 12, 10
2082 DATA 11, 8, 12
2084 DATA 10, 12, 6
2086 DATA 15, 16, 14
2088 DATA 17, 20, 16
2090 DATA 21, 18, 20
2092 DATA 19, 14, 18
2094 DATA 20, 14, 16
2096 DATA 17, 19, 21
2098 DATA 2, 11, 9
2100 DATA 13, 11, 2
2102 DATA 23, 24, 22
2104 DATA 25, 28, 24
2106 DATA 29, 26, 28
2108 DATA 26, 23, 22
2110 DATA 28, 22, 24
2112 DATA 25, 27, 29
2114 DATA 2, 6, 7
2116 DATA 5, 7, 8
2118 DATA 7, 6, 8
2120 DATA 1, 3, 7
2122 DATA 3, 1, 13
2124 DATA 1, 0, 13
2126 DATA 4, 0, 1
2128 DATA 4, 8, 13
2130 DATA 2, 9, 10
2132 DATA 9, 11, 12
2134 DATA 11, 13, 8
2136 DATA 15, 17, 16
2138 DATA 17, 21, 20
2140 DATA 21, 19, 18
2142 DATA 19, 15, 14
2144 DATA 20, 18, 14
2146 DATA 17, 15, 19
2148 DATA 23, 25, 24
2150 DATA 25, 29, 28
2152 DATA 29, 27, 26
2154 DATA 26, 27, 23
2156 DATA 28, 26, 22
2158 DATA 25, 23, 27
2160 REM -- TEXTURE UV COORDINATES --
2162 DATA 0.304519, 0.862785
2164 DATA 0.200731, 0.692984
2166 DATA 0.15625, 0.806185
2168 DATA 0.986859, 0.519356
2170 DATA 0.729263, 0.633844
2172 DATA 0.958237, 0.633844
2174 DATA 0.15625, 0.806185
2176 DATA 0.007981, 0.862785
2178 DATA 0.067288, 0.975985
2180 DATA 0.992877, 0.990823
2182 DATA 0.692877, 0.690823
2184 DATA 0.692877, 0.990823
2186 DATA 0.839842, 0.124124
2188 DATA 0.689943, 0.182678
2190 DATA 0.749902, 0.299786
2192 DATA 0.30223, 0.524426
2194 DATA 0.066233, 0.629314
2196 DATA 0.276008, 0.629314
2198 DATA 0.007855, 0.004441
2200 DATA 0.300058, 0.296644
2202 DATA 0.300058, 0.004441
2204 DATA 0.986859, 0.519356
2206 DATA 0.757885, 0.347625
2208 DATA 0.700641, 0.519356
2210 DATA 0.309701, 0.283531
2212 DATA 0.017331, 0.055363
2214 DATA 0.017331, 0.283531
2216 DATA 0.092455, 0.367095
2218 DATA 0.30223, 0.471982
2220 DATA 0.249787, 0.367095
2222 DATA 0.260039, 0.692984
2224 DATA 0.200731, 0.692984
2226 DATA 0.304519, 0.862785
2228 DATA 0.200731, 0.721284
2230 DATA 0.007981, 0.777884
2232 DATA 0.200731, 0.777884
2234 DATA 0.197343, 0.393317
2236 DATA 0.144899, 0.44576
2238 DATA 0.197343, 0.44576
2240 DATA 0.989742, 0.036293
2242 DATA 0.794872, 0.094847
2244 DATA 0.989742, 0.094847
2246 DATA 0.660205, 0.391714
2248 DATA 0.482945, 0.214454
2250 DATA 0.482945, 0.391714
2252 DATA 0.838345, 0.747995
2254 DATA 0.661086, 0.570736
2256 DATA 0.661086, 0.747995
2258 DATA 0.124736, 0.004441
2260 DATA 0.183177, 0.384305
2262 DATA 0.183177, 0.004441
2264 DATA 0.689943, 0.182678
2266 DATA 0.794872, 0.007016
2268 DATA 0.734912, 0.007016
2270 DATA 0.839842, 0.124124
2272 DATA 0.794872, 0.007016
2274 DATA 0.689943, 0.182678
2276 DATA 0.68877, 0.692877
2278 DATA 0.98877, 0.992877
2280 DATA 0.98877, 0.692877
2282 DATA 0.308918, 0.652481
2284 DATA 0.008918, 0.352481
2286 DATA 0.008918, 0.652481
2288 DATA 0.007124, 0.0
2290 DATA 0.307123, 0.298911
2292 DATA 0.307123, 0.0
2294 DATA 0.69375, 0.65
2296 DATA 0.99375, 0.35
2298 DATA 0.69375, 0.35
2300 DATA 0.884812, 0.168039
2302 DATA 0.794872, 0.197316
2304 DATA 0.884812, 0.197316
2306 DATA 0.039097, 0.724236
2308 DATA 0.294143, 0.979282
2310 DATA 0.294143, 0.724236
2312 DATA 0.986859, 0.519356
2314 DATA 0.700641, 0.519356
2316 DATA 0.729263, 0.633844
2318 DATA 0.067288, 0.975985
2320 DATA 0.245212, 0.975985
2322 DATA 0.15625, 0.806185
2324 DATA 0.245212, 0.975985
2326 DATA 0.304519, 0.862785
2328 DATA 0.15625, 0.806185
2330 DATA 0.992877, 0.990823
2332 DATA 0.992877, 0.690823
2334 DATA 0.692877, 0.690823
2336 DATA 0.749902, 0.299786
2338 DATA 0.929782, 0.299786
2340 DATA 0.839842, 0.124124
2342 DATA 0.929782, 0.299786
2344 DATA 0.989742, 0.182678
2346 DATA 0.839842, 0.124124
2348 DATA 0.30223, 0.524426
2350 DATA 0.040011, 0.524426
2352 DATA 0.066233, 0.629314
2354 DATA 0.007855, 0.004441
2356 DATA 0.007855, 0.296644
2358 DATA 0.300058, 0.296644
2360 DATA 0.986859, 0.519356
2362 DATA 0.929615, 0.347625
2364 DATA 0.757885, 0.347625
2366 DATA 0.309701, 0.283531
2368 DATA 0.309701, 0.055363
2370 DATA 0.017331, 0.055363
2372 DATA 0.092455, 0.367095
2374 DATA 0.040011, 0.471982
2376 DATA 0.30223, 0.471982
2378 DATA 0.200731, 0.721284
2380 DATA 0.007981, 0.721284
2382 DATA 0.007981, 0.777884
2384 DATA 0.197343, 0.393317
2386 DATA 0.144899, 0.393317
2388 DATA 0.144899, 0.44576
2390 DATA 0.989742, 0.036293
2392 DATA 0.794872, 0.036293
2394 DATA 0.794872, 0.094847
2396 DATA 0.660205, 0.391714
2398 DATA 0.660205, 0.214454
2400 DATA 0.482945, 0.214454
2402 DATA 0.838345, 0.747995
2404 DATA 0.838345, 0.570736
2406 DATA 0.661086, 0.570736
2408 DATA 0.124736, 0.004441
2410 DATA 0.124736, 0.384305
2412 DATA 0.183177, 0.384305
2414 DATA 0.68877, 0.692877
2416 DATA 0.68877, 0.992877
2418 DATA 0.98877, 0.992877
2420 DATA 0.308918, 0.652481
2422 DATA 0.308918, 0.352481
2424 DATA 0.008918, 0.352481
2426 DATA 0.007124, 0.0
2428 DATA 0.007123, 0.298911
2430 DATA 0.307123, 0.298911
2432 DATA 0.69375, 0.65
2434 DATA 0.99375, 0.65
2436 DATA 0.99375, 0.35
2438 DATA 0.884812, 0.168039
2440 DATA 0.794872, 0.168039
2442 DATA 0.794872, 0.197316
2444 DATA 0.039097, 0.724236
2446 DATA 0.039097, 0.979282
2448 DATA 0.294143, 0.979282
2450 REM -- TEXTURE VERTEX INDICES --
2452 DATA 0, 1, 2
2454 DATA -1, -1, -1
2456 DATA -1, -1, -1
2458 DATA -1, -1, -1
2460 DATA -1, -1, -1
2462 DATA -1, -1, -1
2464 DATA -1, -1, -1
2466 DATA -1, -1, -1
2468 DATA -1, -1, -1
2470 DATA -1, -1, -1
2472 DATA 41, 42, 43
2474 DATA -1, -1, -1
2476 DATA -1, -1, -1
2478 DATA -1, -1, -1
2480 DATA -1, -1, -1
2482 DATA -1, -1, -1
2484 DATA -1, -1, -1
2486 DATA 68, 69, 70
2488 DATA 71, 72, 73
2490 DATA -1, -1, -1
2492 DATA -1, -1, -1
2494 DATA -1, -1, -1
2496 DATA -1, -1, -1
2498 DATA -1, -1, -1
2500 DATA -1, -1, -1
2502 DATA -1, -1, -1
2504 DATA -1, -1, -1
2506 DATA -1, -1, -1
2508 DATA -1, -1, -1
2510 DATA -1, -1, -1
2512 DATA -1, -1, -1
2514 DATA -1, -1, -1
2516 DATA -1, -1, -1
2518 DATA -1, -1, -1
2520 DATA -1, -1, -1
2522 DATA -1, -1, -1
2524 DATA -1, -1, -1
2526 DATA -1, -1, -1
2528 DATA -1, -1, -1
2530 DATA -1, -1, -1
2532 DATA -1, -1, -1
2534 DATA -1, -1, -1
2536 DATA -1, -1, -1
2538 DATA -1, -1, -1
2540 DATA -1, -1, -1
2542 DATA -1, -1, -1
2544 DATA -1, -1, -1
2546 DATA -1, -1, -1
2548 REM -- TEXTURE BITMAP --
2550 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2552 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2554 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2556 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2558 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2560 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2562 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2564 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2566 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2568 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2570 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2572 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2574 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2576 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2578 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2580 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2582 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2584 DATA 255,255,255,255,0,255,0,255,0,255,0,255,0,255,0,255
2586 DATA 255,255,255,255,0,255,0,255,0,0,0,255,255,255,255,255
2588 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2590 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2592 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2594 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2596 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2598 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2600 DATA 255,255,255,255,0,255,0,255,0,255,0,255,0,255,0,255
2602 DATA 255,255,255,255,0,255,0,255,0,0,0,255,255,255,255,255
2604 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2606 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2608 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2610 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2612 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2614 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2616 DATA 0,255,0,255,255,255,255,255,0,255,0,255,255,255,255,255
2618 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2620 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2622 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2624 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2626 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,255,255,255
2628 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,0,0,255
2630 DATA 0,255,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2632 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2634 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2636 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2638 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2640 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,255,255,255
2642 DATA 255,255,255,255,255,255,255,255,255,0,0,255,255,0,0,255
2644 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,0,0,255
2646 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2648 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2650 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2652 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2654 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2656 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2658 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,255,255,255
2660 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,0,0,255
2662 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2664 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2666 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2668 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2670 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2672 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2674 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2676 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2678 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2680 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
2682 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2684 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2686 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2688 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2690 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2692 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
2694 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2696 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
2698 DATA 0,255,0,255,0,255,0,255,0,0,0,255,255,255,255,255
2700 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2702 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2704 DATA 255,255,255,255,0,0,0,255,255,0,0,255,255,0,0,255
2706 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2708 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
2710 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2712 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2714 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2716 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2718 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2720 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2722 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2724 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2726 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2728 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2730 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2732 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2734 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2736 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2738 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2740 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2742 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2744 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2746 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2748 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2750 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2752 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2754 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2756 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2758 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2760 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2762 DATA 255,255,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2764 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2766 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2768 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2770 DATA 0,0,85,255,0,0,85,255,255,255,255,255,255,255,255,255
2772 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,0,85,255
2774 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2776 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2778 DATA 255,255,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2780 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2782 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2784 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2786 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2788 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
2790 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2792 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
2794 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2796 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2798 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2800 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2802 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2804 DATA 0,0,85,255,255,255,255,255,0,0,85,255,0,0,85,255
2806 DATA 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2808 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2810 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2812 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2814 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2816 DATA 170,170,170,255,0,0,0,255,0,0,85,255,255,255,255,255
2818 DATA 255,255,255,255,255,255,255,255,0,0,85,255,0,0,85,255
2820 DATA 255,255,255,255,0,0,85,255,0,0,85,255,0,0,85,255
2822 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
2824 DATA 0,0,255,255,255,255,255,255,0,0,255,255,0,0,255,255
2826 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2828 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2830 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2832 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2834 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
2836 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2838 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2840 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2842 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2844 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2846 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2848 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2850 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
2852 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2854 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2856 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
2858 DATA 255,255,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2860 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2862 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2864 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2866 DATA 0,0,85,255,0,0,85,255,255,255,255,255,255,255,255,255
2868 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,0,85,255
2870 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2872 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
2874 DATA 0,0,255,255,0,0,255,255,0,0,0,255,170,170,170,255
2876 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2878 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
2880 DATA 170,170,170,255,0,0,0,255,0,0,85,255,0,0,85,255
2882 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2884 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
2886 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2888 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2890 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2892 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2894 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2896 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2898 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2900 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
2902 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2904 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2906 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
2908 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2910 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2912 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
2914 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2916 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2918 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2920 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2922 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
2924 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2926 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2928 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
2930 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2932 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
2934 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2936 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
2938 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
2940 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2942 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2944 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
2946 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
2948 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
2950 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2952 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
2954 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
2956 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2958 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2960 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
2962 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
2964 DATA 0,85,0,255,0,85,0,255,255,255,255,255,0,85,0,255
2966 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
2968 DATA 85,0,0,255,255,255,255,255,85,0,0,255,255,255,255,255
2970 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
2972 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2974 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2976 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
2978 DATA 0,85,0,255,0,85,0,255,0,85,0,255,255,255,255,255
2980 DATA 0,85,0,255,255,255,255,255,0,85,0,255,0,85,0,255
2982 DATA 85,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255
2984 DATA 85,0,0,255,85,0,0,255,255,255,255,255,85,0,0,255
2986 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
2988 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2990 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
2992 DATA 85,85,85,255,0,0,0,255,0,85,0,255,255,255,255,255
2994 DATA 255,255,255,255,255,255,255,255,0,85,0,255,0,85,0,255
2996 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
2998 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3000 DATA 85,0,0,255,255,255,255,255,85,0,0,255,255,255,255,255
3002 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3004 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3006 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3008 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3010 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3012 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3014 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3016 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3018 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
3020 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3022 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3024 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3026 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3028 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3030 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3032 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3034 DATA 255,255,255,255,85,0,0,255,0,0,0,255,85,85,85,255
3036 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3038 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3040 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3042 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3044 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3046 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3048 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3050 DATA 85,0,0,255,85,0,0,255,0,0,0,255,85,85,85,255
3052 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3054 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3056 DATA 85,85,85,255,0,0,0,255,0,85,0,255,0,85,0,255
3058 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3060 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
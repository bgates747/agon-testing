   10 REM Sample app to illustrate Pingo 3D on Agon
   20 model_vertices%=174
   30 model_indices%=456
   40 model_uvs%=145
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
1005 PRINT "filename=pingo/src/bas/fighter+z+y.bas"
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
2002 DATA -0.092122, 0.116237, 0.395366
2004 DATA 0.003686, 0.179018, 0.284601
2006 DATA 0.011346, -0.031883, -0.842815
2008 DATA -0.452427, -0.012814, -0.715862
2010 DATA -0.108219, -0.075453, 0.395393
2012 DATA 0.002931, -0.076481, 0.395806
2014 DATA 0.001647, -0.075887, 0.584706
2016 DATA -0.151861, 0.062111, 0.39459
2018 DATA -0.213452, 9.9e-05, 0.542013
2020 DATA -0.890135, 9.9e-05, -1.151166
2022 DATA -0.724596, 0.013013, -0.95105
2024 DATA -0.926479, 9.9e-05, -1.139767
2026 DATA -0.00108, 9.9e-05, 0.986051
2028 DATA 0.000706, 0.0997, 0.723281
2030 DATA 0.012855, 0.061683, -1.064851
2032 DATA -0.006861, 9.9e-05, -1.292662
2034 DATA -0.996533, 9.9e-05, -0.98481
2036 DATA -0.998134, 9.9e-05, -1.026017
2038 DATA -0.529258, 9.9e-05, -0.998253
2040 DATA -0.484887, 9.9e-05, -1.001504
2042 DATA -0.344774, 0.016845, -0.847032
2044 DATA -0.107344, 9.9e-05, 0.775375
2046 DATA -0.066958, 0.0997, 0.574468
2048 DATA -0.151086, -0.01392, 0.394158
2050 DATA -0.724596, -0.012814, -0.95105
2052 DATA 0.000757, -0.01734, 0.715712
2054 DATA 0.012962, -0.029788, -1.080662
2056 DATA -0.790648, -0.012814, -0.845749
2058 DATA -0.415495, -0.012814, -0.819935
2060 DATA -0.06314, -0.07546, 0.577213
2062 DATA 0.012854, 0.01081, -1.064684
2064 DATA 0.012962, 0.066718, -1.080662
2066 DATA -0.415495, 0.013013, -0.819935
2068 DATA 0.012962, 0.005783, -1.080662
2070 DATA -0.483646, 0.01016, -0.877553
2072 DATA -0.708295, 0.010162, -0.972845
2074 DATA -0.800716, 0.002948, -1.084571
2076 DATA -0.547181, 0.00295, -0.977142
2078 DATA -0.758689, 0.011753, -0.946596
2080 DATA -0.796635, 0.01175, -0.886102
2082 DATA -0.963571, 0.001361, -1.031139
2084 DATA -0.921157, 0.001359, -1.098469
2086 DATA -0.014995, 0.004668, -1.094684
2088 DATA -0.402075, 0.011568, -0.859149
2090 DATA -0.452217, 0.001177, -0.99035
2092 DATA -0.029336, 0.001616, -1.247936
2094 DATA -0.483642, 0.020678, -0.878141
2096 DATA -0.708291, 0.02068, -0.973433
2098 DATA -0.547177, 0.013469, -0.977729
2100 DATA -0.800712, 0.013466, -1.085159
2102 DATA -0.758685, 0.022271, -0.947184
2104 DATA -0.796631, 0.022268, -0.886689
2106 DATA -0.921153, 0.011877, -1.099056
2108 DATA -0.963567, 0.011879, -1.031726
2110 DATA -0.014991, 0.015186, -1.095271
2112 DATA -0.402071, 0.022086, -0.859737
2114 DATA -0.029332, 0.012134, -1.248523
2116 DATA -0.452213, 0.011695, -0.990937
2118 DATA -0.122478, -0.07578, 0.27225
2120 DATA 0.003771, -0.076481, 0.272171
2122 DATA -0.19068, 0.052922, 0.270716
2124 DATA -0.261421, 9.9e-05, 0.388719
2126 DATA -0.189852, -0.013548, 0.271542
2128 DATA -0.120012, 0.093885, 0.252081
2130 DATA -0.112443, 0.099951, 0.290965
2132 DATA -0.133069, 0.086966, 0.27134
2134 DATA 0.004536, 0.173101, 0.159562
2136 DATA 0.004234, 0.175203, 0.203996
2138 DATA -0.071924, 0.274337, -0.213805
2140 DATA -0.169941, 0.426932, -0.562339
2142 DATA -0.03188, 0.150841, -0.127519
2144 DATA -0.006447, 0.157731, -0.640881
2146 DATA -0.004156, 0.172861, -0.146278
2148 DATA -0.105871, 0.280906, -0.782353
2150 DATA -0.216473, 0.473097, -1.08316
2152 DATA -0.028108, 0.143468, -0.645839
2154 DATA -0.087008, 0.260241, -0.213263
2156 DATA -0.085685, 0.296624, -0.787031
2158 DATA -0.083582, 0.294257, -0.776036
2160 DATA 0.004209, 0.174823, 0.288975
2162 DATA -0.091599, 0.112043, 0.39974
2164 DATA 0.002179, 0.154354, 0.587793
2166 DATA -0.066436, 0.095505, 0.578842
2168 DATA 0.001228, 0.095505, 0.727654
2170 DATA -0.11949, 0.08969, 0.256454
2172 DATA -0.111921, 0.095756, 0.295338
2174 DATA 0.005058, 0.168906, 0.163936
2176 DATA 0.004756, 0.171009, 0.208369
2178 DATA 0.007452, 0.152757, -0.269605
2180 DATA 0.007387, 0.153244, -0.260089
2182 DATA 0.011375, 0.120271, -0.847072
2184 DATA 0.011309, 0.121551, -0.837284
2186 DATA -0.220005, 0.013746, -0.261632
2188 DATA -0.223351, 0.013013, -0.271053
2190 DATA -0.449912, 0.013013, -0.710981
2192 DATA -0.450728, 0.013013, -0.720648
2194 DATA 0.007387, -0.076481, -0.260051
2196 DATA 0.007452, -0.07611, -0.269593
2198 DATA -0.188212, -0.0758, -0.270904
2200 DATA -0.184796, -0.076481, -0.261354
2202 DATA -0.468269, 9.9e-05, -0.272306
2204 DATA -0.473285, 9.9e-05, -0.28179
2206 DATA -0.36281, 0.013013, -0.272014
2208 DATA -0.357789, 0.013364, -0.262535
2210 DATA -0.787907, 0.013013, -0.850118
2212 DATA -0.786511, 0.013013, -0.840201
2214 DATA -0.794522, 0.01277, -0.848366
2216 DATA -0.794178, 0.012793, -0.848816
2218 DATA -0.791334, 0.012868, -0.850377
2220 DATA -0.357791, -0.012814, -0.262541
2222 DATA -0.362804, -0.012814, -0.272005
2224 DATA -0.79116, 0.005693, -0.850393
2226 DATA -0.787798, 0.005836, -0.850128
2228 DATA -0.78647, 0.005835, -0.840205
2230 DATA -0.794348, 0.005595, -0.848382
2232 DATA -0.794003, 0.005618, -0.848832
2234 DATA -0.218334, 0.006858, -0.261633
2236 DATA -0.222276, 0.005955, -0.270951
2238 DATA 0.007453, 0.145583, -0.269827
2240 DATA 0.007389, 0.14607, -0.260311
2242 DATA -0.449248, 0.005882, -0.710831
2244 DATA -0.450171, 0.005868, -0.720522
2246 DATA 0.011373, 0.1131, -0.846805
2248 DATA 0.011307, 0.11438, -0.837018
2250 DATA -0.187156, -0.068743, -0.271163
2252 DATA -0.184124, -0.06935, -0.261419
2254 DATA 0.007385, -0.06931, -0.259781
2256 DATA 0.00745, -0.068939, -0.269323
2258 DATA -0.462869, 7.8e-05, -0.274756
2260 DATA -0.467885, 7.4e-05, -0.28424
2262 DATA -0.36241, 0.005851, -0.272071
2264 DATA -0.357592, 0.006191, -0.26242
2266 DATA -0.356445, -0.00585, -0.263041
2268 DATA -0.361827, -0.005751, -0.272415
2270 DATA -0.215339, 0.016455, -0.284699
2272 DATA -0.42526, 0.021112, -0.699385
2274 DATA -0.006656, 0.114103, -0.812463
2276 DATA -0.007177, 0.148326, -0.284556
2278 DATA -0.217267, 0.024519, -0.284443
2280 DATA -0.427188, 0.029177, -0.699129
2282 DATA -0.009105, 0.15639, -0.2843
2284 DATA -0.008584, 0.122167, -0.812207
2286 DATA -0.002646, -0.076481, 0.578486
2288 DATA -0.002133, -0.076481, 0.400811
2290 DATA -0.101223, -0.076481, 0.400257
2292 DATA -0.063451, -0.076481, 0.57062
2294 DATA 0.007928, -0.076481, 0.400862
2296 DATA 0.006025, -0.076481, 0.578545
2298 DATA -0.002133, -0.082514, 0.400811
2300 DATA -0.002646, -0.082514, 0.578486
2302 DATA -0.063451, -0.082514, 0.57062
2304 DATA -0.101223, -0.082514, 0.400257
2306 DATA 0.006025, -0.082514, 0.578545
2308 DATA 0.007928, -0.082514, 0.400862
2310 DATA 0.000706, -0.012814, 0.723281
2312 DATA -0.069754, -0.075115, 0.566299
2314 DATA 0.001656, -0.076481, 0.583419
2316 DATA 0.000788, -0.016136, 0.711272
2318 DATA 0.001728, -0.053804, 0.572812
2320 DATA -0.06306, -0.052296, 0.565468
2322 DATA -0.122023, -0.076481, 0.271483
2324 DATA -0.107441, -0.076481, 0.395262
2326 DATA -0.066958, -0.076481, 0.574468
2328 DATA -0.151861, -0.012814, 0.39459
2330 DATA -0.19068, -0.012814, 0.270716
2332 DATA -0.148154, -0.010444, 0.393513
2334 DATA -0.105231, -0.072053, 0.39473
2336 DATA -0.119678, -0.072139, 0.271647
2338 DATA -0.066617, -0.071933, 0.565589
2340 DATA -0.187052, -0.009906, 0.270938
2342 DATA -0.452426, -0.034117, -0.715934
2344 DATA 0.011352, -0.046871, -0.843656
2346 DATA 0.012966, -0.033274, -1.081124
2348 DATA -0.415495, -0.029071, -0.819884
2350 REM -- FACE VERTEX INDICES --
2352 DATA 136, 141, 140, 137
2354 DATA 104, 95, 32, 10
2356 DATA 4, 166, 167, 58
2358 DATA 22, 82, 80, 0
2360 DATA 27, 24, 28, 3
2362 DATA 103, 100, 61, 60
2364 DATA 143, 148, 151, 144
2366 DATA 160, 164, 109, 99
2368 DATA 26, 172, 173, 28
2370 DATA 3, 170, 171, 2
2372 DATA 110, 27, 3, 98
2374 DATA 98, 3, 2, 97
2376 DATA 59, 160, 99, 96
2378 DATA 63, 92, 103, 60, 65
2380 DATA 63, 84, 86, 66
2382 DATA 102, 93, 94, 105
2384 DATA 13, 83, 82, 22
2386 DATA 7, 22, 0
2388 DATA 9, 11, 10
2390 DATA 108, 39, 40, 17, 107
2392 DATA 18, 32, 19
2394 DATA 9, 24, 11
2396 DATA 16, 17, 27
2398 DATA 18, 19, 28
2400 DATA 60, 61, 8, 7
2402 DATA 35, 47, 49, 36
2404 DATA 38, 50, 51, 39
2406 DATA 16, 27, 110, 101
2408 DATA 22, 21, 12, 13
2410 DATA 37, 48, 46, 34
2412 DATA 7, 8, 21, 22
2414 DATA 61, 164, 163, 8
2416 DATA 18, 28, 24, 9
2418 DATA 21, 162, 154, 12
2420 DATA 11, 24, 27, 17
2422 DATA 15, 26, 28, 19
2424 DATA 8, 163, 162, 21
2426 DATA 20, 32, 31, 14
2428 DATA 30, 33, 32, 20
2430 DATA 32, 34, 35, 10
2432 DATA 10, 35, 36, 9
2434 DATA 9, 36, 37, 18
2436 DATA 18, 37, 34, 32
2438 DATA 16, 106, 107, 17
2440 DATA 10, 38, 39, 108, 104
2442 DATA 17, 40, 41, 11
2444 DATA 11, 41, 38, 10
2446 DATA 33, 42, 43, 32
2448 DATA 32, 43, 44, 19
2450 DATA 19, 44, 45, 15
2452 DATA 15, 45, 42, 33
2454 DATA 46, 48, 49, 47
2456 DATA 50, 52, 53, 51
2458 DATA 54, 56, 57, 55
2460 DATA 42, 54, 55, 43
2462 DATA 41, 52, 50, 38
2464 DATA 36, 49, 48, 37
2466 DATA 45, 56, 54, 42
2468 DATA 39, 51, 53, 40
2470 DATA 43, 55, 57, 44
2472 DATA 40, 53, 52, 41
2474 DATA 44, 57, 56, 45
2476 DATA 34, 46, 47, 35
2478 DATA 106, 16, 101, 102, 105
2480 DATA 100, 109, 164, 61
2482 DATA 95, 90, 31, 32
2484 DATA 5, 161, 160, 59
2486 DATA 155, 168, 166, 4
2488 DATA 0, 64, 65, 60, 7
2490 DATA 63, 65, 64
2492 DATA 1, 67, 64, 0
2494 DATA 68, 72, 71, 78
2496 DATA 77, 74, 69, 68, 78
2498 DATA 68, 76, 70, 72
2500 DATA 73, 74, 77
2502 DATA 69, 76, 68
2504 DATA 76, 73, 75, 70
2506 DATA 59, 96, 126, 127, 97, 2, 171, 172, 26, 15, 33, 30, 14, 31, 90, 122, 123, 91, 88, 118, 119, 89, 66, 86, 87, 67, 1, 79, 81, 83, 13, 12, 154, 25, 157, 158, 6, 156, 147, 152, 153, 146, 5
2508 DATA 71, 75, 73, 78
2510 DATA 74, 73, 76, 69
2512 DATA 0, 80, 79, 1
2514 DATA 64, 85, 84, 63
2516 DATA 67, 87, 85, 64
2518 DATA 108, 111, 112, 104
2520 DATA 92, 116, 131, 103
2522 DATA 102, 130, 117, 93
2524 DATA 91, 123, 120, 94
2526 DATA 100, 128, 132, 109
2528 DATA 110, 133, 129, 101
2530 DATA 95, 121, 122, 90
2532 DATA 109, 132, 125, 99
2534 DATA 97, 127, 124, 98
2536 DATA 66, 89, 92, 63
2538 DATA 112, 111, 115, 114, 113
2540 DATA 117, 116, 119, 118
2542 DATA 121, 120, 123, 122
2544 DATA 125, 124, 127, 126
2546 DATA 129, 128, 131, 130
2548 DATA 133, 132, 128, 129
2550 DATA 130, 131, 116, 117
2552 DATA 120, 121, 112, 113
2554 DATA 124, 125, 132, 133
2556 DATA 101, 129, 130, 102
2558 DATA 105, 113, 114, 106
2560 DATA 103, 131, 128, 100
2562 DATA 94, 120, 113, 105
2564 DATA 106, 114, 115, 107
2566 DATA 104, 112, 121, 95
2568 DATA 107, 115, 111, 108
2570 DATA 93, 117, 118, 88
2572 DATA 99, 125, 126, 96
2574 DATA 98, 124, 133, 110
2576 DATA 89, 119, 116, 92
2578 DATA 93, 134, 135, 94
2580 DATA 94, 135, 136, 91
2582 DATA 91, 136, 137, 88
2584 DATA 88, 137, 134, 93
2586 DATA 138, 140, 141, 139
2588 DATA 137, 140, 138, 134
2590 DATA 135, 139, 141, 136
2592 DATA 134, 138, 139, 135
2594 DATA 156, 142, 143, 5
2596 DATA 5, 143, 144, 161
2598 DATA 161, 144, 145, 162
2600 DATA 162, 145, 142, 156
2602 DATA 5, 146, 147, 156
2604 DATA 149, 150, 151, 148
2606 DATA 146, 153, 152, 147
2608 DATA 142, 149, 148, 143
2610 DATA 144, 151, 150, 145
2612 DATA 145, 150, 149, 142
2614 DATA 25, 154, 162, 29
2616 DATA 29, 162, 156, 6
2618 DATA 159, 158, 157
2620 DATA 6, 158, 159, 29
2622 DATA 29, 159, 157, 25
2624 DATA 58, 160, 161, 4
2626 DATA 155, 162, 163, 23
2628 DATA 4, 161, 162, 155
2630 DATA 23, 163, 164, 62
2632 DATA 62, 164, 160, 58
2634 DATA 165, 166, 168
2636 DATA 166, 165, 169, 167
2638 DATA 62, 169, 165, 23
2640 DATA 23, 165, 168, 155
2642 DATA 58, 167, 169, 62
2644 DATA 170, 173, 172, 171
2646 DATA 28, 173, 170, 3
2648 DATA 20, 14, 30
2650 DATA 82, 83, 81
2652 DATA 81, 79, 80, 82
2654 DATA 84, 85, 87, 86
2656 REM -- TEXTURE UV COORDINATES --
2658 DATA 0.64172, 0.64172
2660 DATA 0.35828, 0.64172
2662 DATA 0.35828, 0.35828
2664 DATA 0.64172, 0.35828
2666 DATA 0.225478, 0.989873
2668 DATA 0.107022, 0.665483
2670 DATA 0.202497, 0.633365
2672 DATA 0.322969, 0.930939
2674 DATA 1.0, 0.650099
2676 DATA 0.683218, 0.650099
2678 DATA 0.683218, 0.3301
2680 DATA 1.0, 0.3301
2682 DATA 0.352365, 0.307997
2684 DATA 0.358629, 0.399698
2686 DATA -0.086273, 0.225706
2688 DATA -0.006538, 0.167435
2690 DATA 0.686421, 0.672775
2692 DATA 1.0, 0.672775
2694 DATA 1.0, 0.992775
2696 DATA 0.686421, 0.992775
2698 DATA 0.006227, 0.108867
2700 DATA 0.352157, 0.193673
2702 DATA -0.006791, 0.119632
2704 DATA -0.320492, 0.574354
2706 DATA -0.319211, 0.441014
2708 DATA 0.097793, 0.66455
2710 DATA 0.21602, 0.988382
2712 DATA 0.66, 0.66
2714 DATA 0.34, 0.66
2716 DATA 0.34, 0.34
2718 DATA 0.511672, 1.0
2720 DATA 0.5002, 1.0
2722 DATA 0.225671, 0.993153
2724 DATA 0.259741, 0.998785
2726 DATA 0.395765, 1.0
2728 DATA 0.390324, 1.0
2730 DATA 0.224134, 0.995848
2732 DATA 0.66, 0.34
2734 DATA 0.344063, 0.915699
2736 DATA 0.344624, 0.915704
2738 DATA 0.449978, 1.0
2740 DATA 0.449417, 1.0
2742 DATA 0.318174, 0.963462
2744 DATA 0.318735, 0.963468
2746 DATA 0.260303, 0.99879
2748 DATA 0.66581, 0.326337
2750 DATA 0.347001, 0.326337
2752 DATA 0.347001, 0.007528
2754 DATA 0.66581, 0.007528
2756 DATA 0.256506, 0.699427
2758 DATA 0.460803, 1.0
2760 DATA 0.665947, 0.611793
2762 DATA 0.679667, 0.639147
2764 DATA 0.449215, 1.0
2766 DATA 0.410847, 1.0
2768 DATA 1.0, 1.0
2770 DATA 0.0, 1.0
2772 DATA 0.0, 0.0
2774 DATA 1.0, 0.0
2776 DATA 0.257068, 0.699433
2778 DATA 0.351273, 0.761744
2780 DATA 0.461364, 1.0
2782 DATA 0.396327, 1.0
2784 DATA 0.680241, 0.639144
2786 DATA 0.830186, 0.653175
2788 DATA 0.578159, 1.0
2790 DATA 0.44979, 1.0
2792 DATA 0.5, 0.34
2794 DATA 0.347831, 0.450557
2796 DATA 0.405954, 0.629443
2798 DATA 0.594046, 0.629443
2800 DATA 0.652169, 0.450557
2802 DATA 0.313703, 1.0
2804 DATA 0.437398, 0.613346
2806 DATA 0.845878, 0.342178
2808 DATA 1.0, 0.334162
2810 DATA 0.973999, 0.019064
2812 DATA 0.736972, 0.019064
2814 DATA 0.695753, 0.334162
2816 DATA 0.176118, 1.0
2818 DATA 0.151487, 0.56727
2820 DATA 0.315302, 0.729983
2822 DATA 0.306514, 1.0
2824 DATA 1.0, 0.124535
2826 DATA 0.985121, 0.223999
2828 DATA 0.975671, 0.223986
2830 DATA 0.974878, 0.225726
2832 DATA 0.984325, 0.225738
2834 DATA 0.909335, 0.327932
2836 DATA 0.928703, 0.327846
2838 DATA 0.904539, 0.368701
2840 DATA 0.900081, 0.368691
2842 DATA 0.850927, 0.402275
2844 DATA 0.854288, 0.369384
2846 DATA 0.848187, 0.366764
2848 DATA 0.782002, 0.367781
2850 DATA 0.775072, 0.370584
2852 DATA 0.708985, 0.331073
2854 DATA 0.718569, 0.330911
2856 DATA 0.717048, 0.329213
2858 DATA 0.707457, 0.329373
2860 DATA 0.675394, 0.226957
2862 DATA 0.685302, 0.226959
2864 DATA 0.684803, 0.225189
2866 DATA 0.674889, 0.225185
2868 DATA 0.6544, 0.145196
2870 DATA 0.660519, 0.14436
2872 DATA 0.658309, 0.13567
2874 DATA 0.652175, 0.136508
2876 DATA 0.648109, 0.120638
2878 DATA 0.654271, 0.119795
2880 DATA 0.689104, 0.060125
2882 DATA 0.776753, 0.032452
2884 DATA 0.770501, 0.03331
2886 DATA 0.919889, -0.01901
2888 DATA 0.929897, 0.035078
2890 DATA 0.935987, 0.036676
2892 DATA 0.934165, 0.037553
2894 DATA 0.981915, 0.065742
2896 DATA 1.0, 0.063655
2898 DATA 1.0, 0.063916
2900 DATA 1.0, 0.064723
2902 DATA 1.0, 0.064796
2904 DATA 1.0, 0.099655
2906 DATA 1.0, 0.099605
2908 DATA 1.0, 0.100679
2910 DATA -0.077588, 0.208734
2912 DATA -0.022564, 0.829508
2914 DATA 0.31358, 1.0
2916 DATA 0.437137, 0.613348
2918 DATA 0.068943, 0.005861
2920 DATA 0.351779, 0.004999
2922 DATA 0.225489, 0.989769
2924 DATA 0.225689, 0.992987
2926 DATA 0.224152, 0.995681
2928 DATA 0.223717, 0.996003
2930 DATA 0.216024, 0.988343
2932 DATA 0.304097, 1.0
2934 DATA 0.427561, 0.613413
2936 DATA 0.09766, 0.663912
2938 DATA 0.106911, 0.664948
2940 DATA 0.304244, 1.0
2942 DATA 0.292898, 1.0
2944 DATA 0.403537, 0.630988
2946 DATA 0.427822, 0.613411
2948 REM -- TEXTURE VERTEX INDICES --
2950 DATA 0, 1, 2, 3
2952 DATA 4, 5, 6, 7
2954 DATA 0, 1, 2, 3
2956 DATA 0, 1, 2, 3
2958 DATA 8, 9, 10, 11
2960 DATA 12, 13, 14, 15
2962 DATA 8, 9, 10, 11
2964 DATA 8, 9, 10, 11
2966 DATA 0, 1, 2, 3
2968 DATA 8, 9, 10, 11
2970 DATA 8, 9, 10, 11
2972 DATA 16, 17, 18, 19
2974 DATA 8, 9, 10, 11
2976 DATA 20, 21, 12, 15, 22
2978 DATA 0, 1, 2, 3
2980 DATA 23, 24, 25, 26
2982 DATA 0, 1, 2, 3
2984 DATA 27, 28, 29
2986 DATA 30, 31, 7
2988 DATA 32, 33, 34, 35, 36
2990 DATA 0, 1, 2
2992 DATA 8, 9, 10
2994 DATA 8, 9, 10
2996 DATA 8, 9, 10
2998 DATA 27, 28, 29, 37
3000 DATA 38, 39, 40, 41
3002 DATA 42, 43, 44, 33
3004 DATA 8, 9, 10, 11
3006 DATA 45, 46, 47, 48
3008 DATA 0, 1, 2, 3
3010 DATA 27, 28, 29, 37
3012 DATA 8, 9, 10, 11
3014 DATA 8, 9, 10, 11
3016 DATA 8, 9, 10, 11
3018 DATA 8, 9, 10, 11
3020 DATA 8, 9, 10, 11
3022 DATA 8, 9, 10, 11
3024 DATA 8, 9, 10, 11
3026 DATA 0, 1, 2, 3
3028 DATA 6, 49, 38, 7
3030 DATA 7, 38, 41, 30
3032 DATA 8, 9, 10, 11
3034 DATA 0, 1, 2, 3
3036 DATA 8, 9, 10, 11
3038 DATA 7, 42, 33, 32, 4
3040 DATA 8, 9, 10, 11
3042 DATA 31, 50, 42, 7
3044 DATA 51, 52, 53, 54
3046 DATA 0, 1, 2, 3
3048 DATA 55, 56, 57, 58
3050 DATA 0, 1, 2, 3
3052 DATA 59, 60, 40, 39
3054 DATA 43, 61, 62, 44
3056 DATA 63, 64, 65, 66
3058 DATA 52, 63, 66, 53
3060 DATA 0, 1, 2, 3
3062 DATA 0, 1, 2, 3
3064 DATA 0, 1, 2, 3
3066 DATA 33, 44, 62, 34
3068 DATA 0, 1, 2, 3
3070 DATA 0, 1, 2, 3
3072 DATA 0, 1, 2, 3
3074 DATA 49, 59, 39, 38
3076 DATA 67, 68, 69, 70, 71
3078 DATA 8, 9, 10, 11
3080 DATA 72, 73, 51, 54
3082 DATA 8, 9, 10, 11
3084 DATA 0, 1, 2, 3
3086 DATA 67, 68, 69, 70, 71
3088 DATA 0, 1, 2
3090 DATA 0, 1, 2, 3
3092 DATA 0, 1, 2, 3
3094 DATA 74, 75, 76, 77, 78
3096 DATA 0, 1, 2, 3
3098 DATA 0, 1, 2
3100 DATA 0, 1, 2
3102 DATA 79, 80, 81, 82
3104 DATA 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125
3106 DATA 0, 1, 2, 3
3108 DATA 126, 80, 79, 127
3110 DATA 0, 1, 2, 3
3112 DATA 0, 1, 2, 3
3114 DATA 0, 1, 2, 3
3116 DATA 0, 1, 2, 3
3118 DATA 0, 1, 2, 3
3120 DATA 0, 1, 2, 3
3122 DATA 0, 1, 2, 3
3124 DATA 8, 9, 10, 11
3126 DATA 8, 9, 10, 11
3128 DATA 72, 128, 129, 73
3130 DATA 8, 9, 10, 11
3132 DATA 8, 9, 10, 11
3134 DATA 130, 131, 21, 20
3136 DATA 132, 133, 134, 135, 136
3138 DATA 0, 1, 2, 3
3140 DATA 128, 137, 138, 129
3142 DATA 8, 9, 10, 11
3144 DATA 0, 1, 2, 3
3146 DATA 8, 9, 10, 11
3148 DATA 0, 1, 2, 3
3150 DATA 139, 140, 132, 136
3152 DATA 8, 9, 10, 11
3154 DATA 8, 9, 10, 11
3156 DATA 0, 1, 2, 3
3158 DATA 0, 1, 2, 3
3160 DATA 25, 139, 136, 26
3162 DATA 0, 1, 2, 3
3164 DATA 0, 1, 2, 3
3166 DATA 0, 1, 2, 3
3168 DATA 0, 1, 2, 3
3170 DATA 0, 1, 2, 3
3172 DATA 8, 9, 10, 11
3174 DATA 0, 1, 2, 3
3176 DATA 0, 1, 2, 3
3178 DATA 141, 142, 143, 144
3180 DATA 0, 1, 2, 3
3182 DATA 0, 1, 2, 3
3184 DATA 27, 28, 29, 37
3186 DATA 0, 1, 2, 3
3188 DATA 0, 1, 2, 3
3190 DATA 0, 1, 2, 3
3192 DATA 8, 9, 10, 11
3194 DATA 8, 9, 10, 11
3196 DATA 8, 9, 10, 11
3198 DATA 8, 9, 10, 11
3200 DATA 8, 9, 10, 11
3202 DATA 8, 9, 10, 11
3204 DATA 8, 9, 10, 11
3206 DATA 8, 9, 10, 11
3208 DATA 0, 1, 2, 3
3210 DATA 0, 1, 2, 3
3212 DATA 8, 9, 10, 11
3214 DATA 8, 9, 10, 11
3216 DATA 8, 9, 10
3218 DATA 0, 1, 2, 3
3220 DATA 8, 9, 10, 11
3222 DATA 8, 9, 10, 11
3224 DATA 8, 9, 10, 11
3226 DATA 8, 9, 10, 11
3228 DATA 8, 9, 10, 11
3230 DATA 8, 9, 10, 11
3232 DATA 8, 9, 10
3234 DATA 8, 9, 10, 11
3236 DATA 8, 9, 10, 11
3238 DATA 8, 9, 10, 11
3240 DATA 0, 1, 2, 3
3242 DATA 8, 9, 10, 11
3244 DATA 0, 1, 2, 3
3246 DATA 0, 1, 2
3248 DATA 27, 28, 29
3250 DATA 27, 28, 29, 37
3252 DATA 27, 28, 29, 37
3254 REM -- TEXTURE BITMAP --
3256 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3258 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3260 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3262 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3264 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3266 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3268 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3270 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3272 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3274 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3276 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3278 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
3280 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3282 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3284 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
3286 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3288 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3290 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3292 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3294 DATA 0,0,255,255,0,0,255,255,255,255,255,255,255,255,255,255
3296 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3298 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3300 DATA 0,255,0,255,255,255,255,255,255,255,255,255,255,255,255,255
3302 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3304 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3306 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3308 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3310 DATA 0,0,255,255,0,0,255,255,0,0,255,255,255,255,255,255
3312 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3314 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3316 DATA 0,255,0,255,0,255,0,255,255,255,255,255,0,255,0,255
3318 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3320 DATA 85,0,0,255,255,255,255,255,255,255,255,255,85,0,0,255
3322 DATA 85,0,0,255,85,0,0,255,255,255,255,255,255,255,255,255
3324 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3326 DATA 255,255,255,255,255,255,255,255,0,0,255,255,0,0,255,255
3328 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3330 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3332 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3334 DATA 255,255,255,255,255,255,255,255,0,255,0,255,0,255,0,255
3336 DATA 85,0,0,255,85,0,0,255,85,0,0,255,255,255,255,255
3338 DATA 85,0,0,255,255,255,255,255,85,0,0,255,85,0,0,255
3340 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3342 DATA 255,255,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3344 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3346 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3348 DATA 0,255,0,255,0,255,0,255,0,255,0,255,255,255,255,255
3350 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3352 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3354 DATA 255,255,255,255,85,0,0,255,85,0,0,255,85,0,0,255
3356 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3358 DATA 255,255,255,255,0,0,255,255,0,0,255,255,255,255,255,255
3360 DATA 0,0,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3362 DATA 0,0,255,255,0,0,0,255,0,255,0,255,255,255,255,255
3364 DATA 255,255,255,255,255,255,255,255,255,255,255,255,0,255,0,255
3366 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3368 DATA 85,0,0,255,85,0,0,255,85,0,0,255,255,255,255,255
3370 DATA 85,0,0,255,255,255,255,255,85,0,0,255,85,0,0,255
3372 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3374 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3376 DATA 255,255,255,255,0,0,255,255,255,255,255,255,0,0,255,255
3378 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3380 DATA 0,255,0,255,0,255,0,255,0,255,0,255,255,255,255,255
3382 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3384 DATA 85,0,0,255,255,255,255,255,255,255,255,255,85,0,0,255
3386 DATA 85,0,0,255,85,0,0,255,255,255,255,255,255,255,255,255
3388 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3390 DATA 255,255,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3392 DATA 0,0,255,255,255,255,255,255,255,255,255,255,0,0,255,255
3394 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3396 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3398 DATA 255,255,255,255,255,255,255,255,0,255,0,255,0,255,0,255
3400 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3402 DATA 85,0,0,255,85,0,0,255,85,0,0,255,85,0,0,255
3404 DATA 85,0,0,255,85,0,0,255,0,0,0,255,0,0,255,255
3406 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3408 DATA 0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255
3410 DATA 0,0,255,255,0,0,0,255,0,255,0,255,0,255,0,255
3412 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3414 DATA 0,255,0,255,0,255,0,255,0,255,0,255,0,255,0,255
3416 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3418 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3420 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3422 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3424 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3426 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3428 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3430 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3432 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3434 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3436 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3438 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3440 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3442 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3444 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3446 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3448 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3450 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3452 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3454 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3456 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3458 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3460 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3462 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3464 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3466 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3468 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3470 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3472 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3474 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3476 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3478 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3480 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3482 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3484 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3486 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3488 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3490 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3492 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3494 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3496 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3498 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3500 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3502 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3504 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3506 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3508 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3510 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3512 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3514 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3516 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3518 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3520 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3522 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3524 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3526 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3528 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3530 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3532 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3534 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3536 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3538 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3540 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3542 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3544 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3546 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3548 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3550 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3552 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3554 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3556 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3558 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3560 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3562 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3564 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3566 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3568 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3570 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3572 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3574 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3576 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3578 DATA 85,85,85,255,85,85,85,255,85,85,85,255,85,85,85,255
3580 DATA 85,85,85,255,85,85,85,255,0,0,0,255,170,170,170,255
3582 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3584 DATA 170,170,170,255,170,170,170,255,170,170,170,255,170,170,170,255
3586 DATA 170,170,170,255,0,0,0,255,255,255,255,255,255,255,255,255
3588 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3590 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
3592 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3594 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3596 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3598 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3600 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3602 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3604 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3606 DATA 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
3608 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3610 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3612 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3614 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3616 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3618 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3620 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3622 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3624 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3626 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3628 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3630 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
3632 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3634 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3636 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
3638 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3640 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3642 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3644 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3646 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
3648 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3650 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3652 DATA 255,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255
3654 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3656 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3658 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3660 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3662 DATA 0,0,85,255,0,0,85,255,0,0,85,255,255,255,255,255
3664 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3666 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3668 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
3670 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3672 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3674 DATA 0,85,0,255,0,85,0,255,255,255,255,255,255,255,255,255
3676 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3678 DATA 255,255,255,255,255,255,255,255,0,0,85,255,0,0,85,255
3680 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
3682 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,255,255,255
3684 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,0,0,255
3686 DATA 255,255,255,255,255,255,255,255,255,0,0,255,255,0,0,255
3688 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3690 DATA 0,85,0,255,255,255,255,255,0,85,0,255,0,85,0,255
3692 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3694 DATA 255,255,255,255,0,0,85,255,255,255,255,255,0,0,85,255
3696 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
3698 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3700 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,255,255,255
3702 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3704 DATA 0,85,0,255,255,255,255,255,255,255,255,255,255,255,255,255
3706 DATA 255,255,255,255,0,85,0,255,0,85,0,255,0,85,0,255
3708 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3710 DATA 255,255,255,255,0,0,85,255,0,0,85,255,255,255,255,255
3712 DATA 0,0,85,255,0,0,85,255,255,255,255,255,0,0,85,255
3714 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3716 DATA 255,0,0,255,255,0,0,255,255,255,255,255,255,0,0,255
3718 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3720 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3722 DATA 0,85,0,255,255,255,255,255,0,85,0,255,0,85,0,255
3724 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3726 DATA 255,255,255,255,0,0,85,255,0,0,85,255,0,0,85,255
3728 DATA 255,255,255,255,0,0,85,255,255,255,255,255,0,0,85,255
3730 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3732 DATA 255,0,0,255,255,255,255,255,255,0,0,255,255,255,255,255
3734 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3736 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3738 DATA 0,85,0,255,0,85,0,255,255,255,255,255,255,255,255,255
3740 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3742 DATA 255,255,255,255,0,0,85,255,0,0,85,255,0,0,85,255
3744 DATA 0,0,85,255,255,255,255,255,255,255,255,255,0,0,85,255
3746 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,255,255,255
3748 DATA 255,255,255,255,255,0,0,255,255,0,0,255,255,0,0,255
3750 DATA 255,255,255,255,255,255,255,255,255,0,0,255,255,0,0,255
3752 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3754 DATA 0,85,0,255,0,85,0,255,0,85,0,255,0,85,0,255
3756 DATA 0,85,0,255,0,85,0,255,0,0,0,255,0,0,85,255
3758 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3760 DATA 0,0,85,255,0,0,85,255,0,0,85,255,0,0,85,255
3762 DATA 0,0,85,255,0,0,0,255,255,0,0,255,255,0,0,255
3764 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
3766 DATA 255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255
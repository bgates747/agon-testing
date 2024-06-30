sliced_vertices_n: equ 4
sliced_indices_n: equ 12
sliced_uvs_n: equ 10

; -- VERTICES --
sliced_vertices:
	dw 0, 0, 0
	dw 0, -32767, 0
	dw 0, 0, -32767
	dw 32767, 0, 0

; -- FACE VERTEX INDICES --
sliced_vertex_indices:
	dw 0, 2, 1
	dw 0, 3, 2
	dw 1, 3, 0
	dw 3, 1, 2

; -- TEXTURE UV COORDINATES --
sliced_uvs:
	dw 0, 32668
	dw 32668, 0
	dw 32668, 32668
	dw 65335, 32668
	dw 32668, 65335
	dw 32668, 32668
	dw 32668, 0
	dw 65335, 32668
	dw 32668, 32668
	dw 0, 32668

; -- TEXTURE VERTEX INDICES --
sliced_uv_indices:
	dw 0, 1, 2
	dw 3, 4, 5
	dw 6, 7, 8
	dw 4, 9, 5

	ld a, 0x20
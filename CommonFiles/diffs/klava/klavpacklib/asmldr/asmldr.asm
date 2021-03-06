.386p
.model flat, c
option casemap :none

;; ----------------------------------------------------------------------------

.code
align 4
asm_loader_begin dd offset loader_start
asm_loader_end   dd offset loader_end

public asm_loader_begin
public asm_loader_end

;; ----------------------------------------------------------------------------

LOADER_SECTION struc
	SectionRVA	dd ?
	PackedSize	dd ?
	UnpackedSize	dd ?
LOADER_SECTION ends

LZMAASM_WORKMEM_SIZE	equ 4000h

;; ----------------------------------------------------------------------------

.code
align 4
loader_start:
	push	eax
	pushfd
	pushad
	call	@@loader_delta_get
@@loader_delta_base:
	;; loader constant data here
	LoaderVersion		dw 1
	LoaderFlags		dw 0
	ImageBase		dd 0
	ModuleInstance		dd 0
	LoaderRVA		dd 0
	MaxPackedSize		dd 0
	HeaderDataRVA		dd 0
	HeaderDataPLen		dd 0
	HeaderDataULen		dd 0
	TLSDataRVA		dd 0
	TLSDataLen		dd 0
	TLSDataVal		dd 0
	OriginalEntryRVA	dd 0
	OriginalImportRVA	dd 0
	OriginalFixUpsRVA	dd 0
	OriginalFixUpsLen	dd 0
	Reserved		dd 4 dup(0)
	LoaderSection		LOADER_SECTION 16 dup(<>)

@@loader_delta_get:
	pop	ebp
	lea	ebx, [ebp - (@@loader_delta_base - loader_start)]
	sub	ebp, @@loader_delta_base
	sub	ebx, [ebp + LoaderRVA]
	mov	[ebp + ModuleInstance], ebx

	;; check for already loaded (dll)
	movzx	eax, byte ptr [ebp + FlagAlredyLoaded]
	test	eax, eax
	jnz	@@loader_done
	mov	[ebp + FlagAlredyLoaded], 1

	;; copy import table to local variables
	mov	esi, [ebx + 3Ch]
	add	esi, ebx				;; esi = ptr IMAGE_NT_HEADERS
	mov	[ebp + ptrPEHeader], esi
	mov	ecx, [esi + 80h]			;; ecx = import table rva
	mov	ecx, [ecx + ebx + 10h]			;; ecx = iat rva
	add	ecx, ebx
	mov	eax, [ecx]
	mov	edi, [ecx + 4]
	mov	[ebp + ptrGetModuleHandleA], eax
	mov	[ebp + ptrGetProcAddress], edi

	;; get kernel32.dll base
	lea	ecx, [ebp + szKernel32]
	push	ecx
	call	eax					;; eax = ptr GetModuleHandleA
	test	eax, eax
	mov	esi, eax
	jz	@@loader_error

	;; find needed api
	lea	eax, [ebp + szVirtualProtect]
	push	eax
	push	esi					;; esi = kernel32.dll instance
	call	edi					;; edi = ptr GetProcAddress
	test	eax, eax
	mov	[ebp + ptrVirtualProtect], eax
	jz	@@loader_error

	lea	eax, [ebp + szVirtualFree]
	push	eax
	push	esi
	call	edi
	test	eax, eax
	mov	[ebp + ptrVirtualFree], eax
	jz	@@loader_error

	lea	eax, [ebp + szVirtualAlloc]
	push	eax
	push	esi
	call	edi
	test	eax, eax
	mov	[ebp + ptrVirtualAlloc], eax
	jz	@@loader_error

	;; alloc lzma context and decomression buffer
	push	4					;; PAGE_READWRITE
	push	1000h					;; MEM_COMMIT
	mov	eax, dword ptr [ebp + MaxPackedSize]
	add	eax, LZMAASM_WORKMEM_SIZE
	push	eax
	push	0
	call	dword ptr [ebp + ptrVirtualAlloc]
	test	eax, eax
	mov	[ebp + ptrLzmaContext], eax
	lea	eax, [eax + LZMAASM_WORKMEM_SIZE]
	mov	[ebp + ptrPackMemBuffer], eax
	jz	@@loader_error

	;; deprotect header
	mov	esi, [ebp + HeaderDataULen]
	lea	edi, [ebp + dwOldHeaderProtect]
	push	edi
	push	4					;; PAGE_READWRITE
	push	esi
	push	dword ptr [ebp + ptrPEHeader]
	call	dword ptr [ebp + ptrVirtualProtect]
	test	eax, eax
	jz	@@loader_error

	;; unpack original header
	push	dword ptr [ebp + ptrLzmaContext]
	push	esi					;; USize
	push	dword ptr [ebp + ptrPEHeader]		;; UBuffer
	push	dword ptr [ebp + HeaderDataPLen]	;; PSize
	mov	eax, [ebp + HeaderDataRVA]
	add	eax, ebx
	push	eax					;; PBuffer
	call	lzma_decode_asm
	add	esp, 5*4
	test	eax, eax
	jnz	@@loader_error

	;; protect header back
	push	edi					;; edi = offset dwOldHeaderProtect
	push	dword ptr [edi]
	push	esi
	push	dword ptr [ebp + ptrPEHeader]
	call	dword ptr [ebp + ptrVirtualProtect]
	test	eax, eax
	jz	@@loader_error

	;; decompress sections
	assume	ebx: ptr LOADER_SECTION
	lea	ebx, [ebp + LoaderSection]

@@sections_unpack_loop:
	mov	esi, [ebx].SectionRVA
	test	esi, esi
	jz	@@sections_unpack_done
	add	esi, [ebp + ModuleInstance]

	;; copy packed data to temp buffer
	push	dword ptr [ebp + ptrLzmaContext]
	push	[ebx].UnpackedSize
	mov	edi, [ebp + ptrPackMemBuffer]
	mov	eax, [ebx].PackedSize
	mov	ecx, eax
	push	esi
	push	ecx
	push	edi
	shr	ecx, 2
	and	eax, 3
	rep movsd
	mov	ecx, eax
	rep movsb

	;; unpack buffer
	call	lzma_decode_asm
	add	esp, 5*4
	test	eax, eax
	jnz	@@loader_error
	add	ebx, size LOADER_SECTION
	jmp	@@sections_unpack_loop

@@sections_unpack_done:
	;; free work mem
	call	@@free_work_mem

	;; resolve fixups
	mov	ebx, [ebp + ModuleInstance]
	push	dword ptr [ebp + OriginalFixUpsLen]
	push	dword ptr [ebp + OriginalFixUpsRVA]
	push	dword ptr [ebp + ImageBase]
	push	ebx
	call	resolve_fixups_asm
	add	esp, 4*4
	test	eax, eax
	jnz	@@loader_error

	;; resolve import table
	push	dword ptr [ebp + ptrGetProcAddress]
	push	dword ptr [ebp + ptrGetModuleHandleA]
	push	dword ptr [ebp + OriginalImportRVA]
	push	ebx
	call	resolve_import_asm
	add	esp, 4*4
	test	eax, eax
	jnz	@@loader_error

	;; protect sections
	push	dword ptr [ebp + ptrVirtualProtect]
	push	dword ptr [ebp + ptrPEHeader]
	push	dword ptr [ebp + ModuleInstance]
	call	protect_sections_asm
	add	esp, 3*4
	test	eax, eax
	jnz	@@loader_error

@@loader_done:
	mov	eax, [ebp + OriginalEntryRVA]
	add	eax, ebx
	mov	[esp + 8*4 + 4], eax
	popad
	popfd
	retn

@@loader_error:
	call	@@free_work_mem
	mov	ebx, [ebp + ModuleInstance]
	mov	esi, dword ptr [ebx + 3Ch]
	movzx	eax, word ptr [ebx + esi + 5Eh]		;; eax = dll characteristics
	test	eax, 2000h
	jnz	@@loader_error_dll
	popad
	popfd
	pop	eax
	or	eax, -1
	retn

@@loader_error_dll:
	popad
	popfd
	pop	eax
	xor	eax, eax
	ret	12

align 4
@@free_work_mem:
	mov	eax, [ebp + ptrLzmaContext]
	test	eax, eax
	jz	@@free_work_mem_done
	push	8000h					;; MEM_RELEASE
	push	0
	push	eax
	call	dword ptr [ebp + ptrVirtualFree]
	xor	eax, eax
	mov	[ebp + ptrLzmaContext], eax
@@free_work_mem_done:
	retn

align 4
	;; loader variables here
	ptrGetModuleHandleA	dd 0
	ptrGetProcAddress	dd 0
	ptrVirtualProtect	dd 0
	ptrVirtualAlloc		dd 0
	ptrVirtualFree		dd 0
	ptrLzmaContext		dd 0
	ptrPackMemBuffer	dd 0
	dwOldHeaderProtect	dd 0
	ptrPEHeader		dd 0
	FlagAlredyLoaded	db 0

	;; loader strings
	szKernel32		db "kernel32.dll", 0
	szVirtualProtect	db "VirtualProtect", 0
	szVirtualAlloc		db "VirtualAlloc", 0
	szVirtualFree		db "VirtualFree", 0

align 4
include fixupsasm.inc
include importasm.inc
include protobj.inc
include lzmaasm.inc

loader_end:

;; ----------------------------------------------------------------------------

end

#define NEO_IN_ASM
#include "NeoSystemAsm.h"

	.arm
	.align 4
	.section .itcm
	
   .global neoCpuRead8
   .type neoCpuRead8, %function
neoCpuRead8:
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_READ8TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoCpuRead16
    .type neoCpuRead16, %function
neoCpuRead16:
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_READ16TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoCpuRead32
    .type neoCpuRead32, %function
neoCpuRead32:
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_READ32TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoDefaultRead8
    .type neoDefaultRead8, %function
neoDefaultRead8: //does a 16 bit read, and returns proper half
	str lr, [sp, #-4]!
	str r0, [sp, #-4]!
	
	and r2, r0, #0x00ff0000
	add lr, pc, #4
	add r3, r7, #NEO_READ16TABLE
	ldr pc, [r3, r2, lsr #14]
	
	ldr r1, [sp], #4 //restore address into r1
	tst r1, #0x01
	moveq r0, r0, lsr #8 //return high byte on even address
	andne r0, r0, #0x00ff //mask out high byte on odd address
	
	ldr pc, [sp], #4
	//bx lr
	
	.global neoDefaultRead32
    .type neoDefaultRead32, %function
neoDefaultRead32: //does back to back 16bit reads
	str lr, [sp, #-4]!
	str r0, [sp, #-4]!
	
	and r2, r0, #0x00ff0000
	add lr, pc, #4
	add r3, r7, #NEO_READ16TABLE
	ldr pc, [r3, r2, lsr #14]
	
	//store result and restore address
	swp r0, r0, [sp]
	add r0, r0, #2
	
	and r2, r0, #0x00ff0000
	add lr, pc, #4
	add r3, r7, #NEO_READ16TABLE
	ldr pc, [r3, r2, lsr #14]
	ldr r3, [sp], #4 //restore first result
	orr r0, r0, r3, lsl #16
	
	ldr pc, [sp], #4
	
	.global neoCpuWrite8
    .type neoCpuWrite8, %function
neoCpuWrite8:
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_WRITE8TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoCpuWrite16
    .type neoCpuWrite16, %function
neoCpuWrite16:
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_WRITE16TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoCpuWrite32
    .type neoCpuWrite32, %function
neoCpuWrite32:
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_WRITE32TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoDefaultWrite32
    .type neoDefaultWrite32, %function
neoDefaultWrite32: //does back to back 16bit writes
	stmdb sp!, {r0, r1, lr}
	mov r1, r1, lsr #16 //high word first
	
	and r2, r0, #0x00ff0000
	add lr, pc, #4
	add r3, r7, #NEO_WRITE16TABLE
	ldr pc, [r3, r2, lsr #14]
	
	ldmfd sp!, {r0, r1, lr}
	add r0, r0, #2
	//clear out high bits
	mov r1, r1, lsl #16 //low word second
	mov r1, r1, lsr #16
	
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_WRITE16TABLE
	ldr pc, [r3, r2, lsr #14]
	
	.global neoCpuCheckPc
    .type neoCpuCheckPc, %function
neoCpuCheckPc:
	ldr r2, [r7, #NEO_CPU_MEMBASE] //r2 = membase
	sub r0, r0, r2 //r0 = pc - membase (r0 = actual pc)
	and r2, r0, #0x00ff0000
	add r3, r7, #NEO_CHECKPCTABLE
	ldr pc, [r3, r2, lsr #14]
	
	.ltorg

//============================================================	
//rom
//============================================================	
	.global neoReadRom8
    .type neoReadRom8, %function
neoReadRom8:
	bic r0, r0, #0xff000000
	ldr r2, [r7, #NEO_ROM0]
	eor r0, r0, #1
	ldrb r0, [r2, r0]
	bx lr
	
	.global neoReadRom16
    .type neoReadRom16, %function
neoReadRom16:
	bic r0, r0, #0xff000000
	ldr r2, [r7, #NEO_ROM0]
	ldrh r0, [r2, r0]
	bx lr
	
	.global neoReadRom32
    .type neoReadRom32, %function
neoReadRom32:
	bic r0, r0, #0xff000000
	ldr r2, [r7, #NEO_ROM0]
	ldrh r1, [r2, r0]!
	ldrh r0, [r2, #2]
	add r0, r0, r1, lsl #16
	bx lr
	
	.global neoRomPc
    .type neoRomPc, %function
neoRomPc:
	bic r0, r0, #0xff000000
	ldr r2, [r7, #NEO_ROM0]
	add r0, r0, r2
	str r2, [r7, #NEO_CPU_MEMBASE]
	bx lr
	
	.global neoReadRom18
    .type neoReadRom18, %function
neoReadRom18:
	eor r0, r0, #1
	ldr r2, [r7, #NEO_ROM1]
	mov r0, r0, lsl #12
	ldrb r0, [r2, r0, lsr #12]
	bx lr
	
	.global neoReadRom116
    .type neoReadRom116, %function
neoReadRom116:
	mov r0, r0, lsl #12
	ldr r2, [r7, #NEO_ROM1]
	mov r0, r0, lsr #12
	ldrh r0, [r2, r0]
	bx lr
	
	.global neoReadRom132
    .type neoReadRom132, %function
neoReadRom132:
	mov r0, r0, lsl #12
	ldr r2, [r7, #NEO_ROM1]
	mov r0, r0, lsr #12
	ldrh r1, [r2, r0]!
	ldrh r0, [r2, #2]
	add r0, r0, r1, lsl #16
	bx lr
	
	.global neoRom1Pc
    .type neoRom1Pc, %function
neoRom1Pc:
	mov r0, r0, lsl #12
	ldr r2, [r7, #NEO_ROM1]
	sub r1, r2, #0x200000
	add r0, r2, r0, lsr #12
	str r1, [r7, #NEO_CPU_MEMBASE]
	bx lr
	
    .global neoReadRom08
    .type neoReadRom08, %function
neoReadRom08:
	eor r0, r0, #1
	ldr r2, [r7, #NEO_ROM0]
	mov r0, r0, lsl #12
	ldrb r0, [r2, r0, lsr #12]
	bx lr
	
	.global neoReadRom016
    .type neoReadRom016, %function
neoReadRom016:
	mov r0, r0, lsl #12
	ldr r2, [r7, #NEO_ROM0]
	mov r0, r0, lsr #12
	ldrh r0, [r2, r0]
	bx lr
	
	.global neoReadRom032
    .type neoReadRom032, %function
neoReadRom032:
	mov r0, r0, lsl #12
	ldr r2, [r7, #NEO_ROM0]
	mov r0, r0, lsr #12
	ldrh r1, [r2, r0]!
	ldrh r0, [r2, #2]
	add r0, r0, r1, lsl #16
	bx lr
	
	.global neoRom0Pc
    .type neoRom0Pc, %function
neoRom0Pc:
	mov r0, r0, lsl #12
	ldr r2, [r7, #NEO_ROM0]
	sub r1, r2, #0x200000
	add r0, r2, r0, lsr #12
	str r1, [r7, #NEO_CPU_MEMBASE]
	bx lr
	
	.ltorg
	
//============================================================	
//ram
//============================================================	
	.global neoReadRam8
    .type neoReadRam8, %function
neoReadRam8:
	eor r0, r0, #1
	ldr r2, [r7, #NEO_RAM]
	mov r0, r0, lsl #16
	ldrb r0, [r2, r0, lsr #16]
	bx lr
	
	.global neoReadRam16
    .type neoReadRam16, %function
neoReadRam16:
	mov r0, r0, lsl #16
	ldr r2, [r7, #NEO_RAM]
	mov r0, r0, lsr #16
	ldrh r0, [r2, r0]
	bx lr
	
	.global neoReadRam32
    .type neoReadRam32, %function
neoReadRam32:
	mov r0, r0, lsl #16
	ldr r2, [r7, #NEO_RAM]
	mov r0, r0, lsr #16
	ldrh r1, [r2, r0]!
	ldrh r0, [r2, #2]
	add r0, r0, r1, lsl #16
	bx lr
	
	.global neoWriteRam8
    .type neoWriteRam8, %function
neoWriteRam8:
	eor r0, r0, #1
	ldr r2, [r7, #NEO_RAM]
	mov r0, r0, lsl #16
	strb r1, [r2, r0, lsr #16]
	bx lr
	
	.global neoWriteRam16
    .type neoWriteRam16, %function
neoWriteRam16:
	mov r0, r0, lsl #16
	ldr r2, [r7, #NEO_RAM]
	mov r0, r0, lsr #16
	strh r1, [r2, r0]
	bx lr
	
	.global neoWriteRam32
    .type neoWriteRam32, %function
neoWriteRam32:
	mov r0, r0, lsl #16
	ldr r2, [r7, #NEO_RAM]
	mov r0, r0, lsr #16
	mov r1, r1, ror #16
	strh r1, [r2, r0]! //store high word
	mov r1, r1, ror #16
	strh r1, [r2, #2] //store low word
	bx lr
	
	.global neoRamPc
    .type neoRamPc, %function
neoRamPc:
	mov r0, r0, lsl #16
	ldr r2, [r7, #NEO_RAM]
	sub r1, r2, #0x100000
	add r0, r2, r0, lsr #16
	str r1, [r7, #NEO_CPU_MEMBASE]
	bx lr
	
	.ltorg
	
//============================================================	
//bios
//============================================================
	.global neoReadBios8
    .type neoReadBios8, %function
neoReadBios8:
	eor r0, r0, #1
	ldr r2, [r7, #NEO_BIOS]
	mov r0, r0, lsl #15
	ldrb r0, [r2, r0, lsr #15]
	bx lr
	
	.global neoReadBios16
    .type neoReadBios16, %function
neoReadBios16:
	mov r0, r0, lsl #15
	ldr r2, [r7, #NEO_BIOS]
	mov r0, r0, lsr #15
	ldrh r0, [r2, r0]
	bx lr
	
	.global neoReadBios32
    .type neoReadBios32, %function
neoReadBios32:
	mov r0, r0, lsl #15
	ldr r2, [r7, #NEO_BIOS]
	mov r0, r0, lsr #15
	ldrh r1, [r2, r0]!
	ldrh r0, [r2, #2]
	add r0, r0, r1, lsl #16
	bx lr
	
	.global neoBiosPc
    .type neoBiosPc, %function
neoBiosPc:
	mov r0, r0, lsl #15
	ldr r2, [r7, #NEO_BIOS]
	sub r1, r2, #0xc00000
	add r0, r2, r0, lsr #15
	str r1, [r7, #NEO_CPU_MEMBASE]
	bx lr
	
	//r0 is scanline
	//r1 is displaycounter
	//r2 is displaycontrol
	//r3 is irqpending
	.global neoCpuEvent
    .type neoCpuEvent, %function
neoCpuEvent:
	//reset program counter
	sub r4, r4, #2
	
	//increment scanline
	ldr r0, [r7, #NEO_SCANLINE]
	add r0, r0, #1
	str r0, [r7, #NEO_SCANLINE]
	
	//we return from cyclone run on scanline 264
	cmp r0, #264
	beq CycloneEndNoBack //return from cpu loop when scanline hits 264
	
	//load more values into reg
	ldr r1, [r7, #NEO_DISPLAYCOUNTER]
	ldr r2, [r7, #NEO_DISPLAYCONTROLMASK]
	ldr r3, [r7, #NEO_IRQPENDING]
	
	//decrement display counter (carry will be clear on underflow)
	subs r1, r1, #PIXELS_PER_SCANLINE
	bcs 0f
	
	//raster position match
	//check to see if reload display counter
	tst r2, #(1 << 7)
	ldrne r1, [r7, #NEO_DISPLAYCOUNTERLOAD]
	//irq2 is pending if enabled
	tst r2, #(1 << 4)
	orrne r3, r3, #2 
0:
	//check for vblank
	cmp r0, #248
	bne 0f
	
	//vblank
	//irq1 is pending
	orr r3, r3, #1
	
	//decrement frame counter (carry will be clear on underflow)
	ldrb r0, [r7, #NEO_FRAMECOUNTER]
	subs r0, r0, #1
	movcc r0, r2, lsr #8 //if frame counter < 0, reload from display control
	strb r0, [r7, #NEO_FRAMECOUNTER]
	
	//increment auto anim counter if frame counter < 0
	ldrcc r0, [r7, #NEO_AUTOANIMCOUNTER]
	addcc r0, r0, #1
	andcc r0, r0, #7
	strcc r0, [r7, #NEO_AUTOANIMCOUNTER]
	
	//reload display counter, if this bit is set
	tst r2, #(1 << 6)
	ldrne r1, [r7, #NEO_DISPLAYCOUNTERLOAD]
	
	stmdb sp!, {r0-r3}
	ldr r0, =neoVideoDrawFrame
	blx r0
	ldmia sp!, {r0-r3}
0:
	//store display counter
	str r1, [r7, #NEO_DISPLAYCOUNTER]
	//store irq pending
	str r3, [r7, #NEO_IRQPENDING]
	//switch(r3) {
	//case 0: r3 = 0;
	//case 1: r3 = 1;
	//case 2: r3 = 2;
	//case 3: r3 = 2;
	tst r3, #0x02 //test bit 2
	bicne r3, r3, #0x01 //if bit 2 is set, mask lower bit
	strb r3, [r7, #0x47] //store byte in cyclone irq pending field
	
	ldr r0, [r7, #NEO_DISPLAYCONTROL]
	str r0, [r7, #NEO_DISPLAYCONTROLMASK]
	
	//run for this many cycles
	ldr r0, [r7, #NEO_CPUCLOCKSPERSCANLINE]
	adds r5, r5, r0
	//goto next instruction
	b CycloneNextInterrupt
	
	.ltorg

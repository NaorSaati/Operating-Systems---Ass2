
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8c070713          	addi	a4,a4,-1856 # 80008910 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	bfe78793          	addi	a5,a5,-1026 # 80005c60 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc98f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	390080e7          	jalr	912(ra) # 800024ba <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7f4080e7          	jalr	2036(ra) # 800019b4 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	13c080e7          	jalr	316(ra) # 80002304 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e86080e7          	jalr	-378(ra) # 8000205c <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	252080e7          	jalr	594(ra) # 80002464 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	21e080e7          	jalr	542(ra) # 80002510 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c7a080e7          	jalr	-902(ra) # 800020c0 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	77078793          	addi	a5,a5,1904 # 80020be8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5c07a223          	sw	zero,1476(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	34f72823          	sw	a5,848(a4) # 800088d0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	554dad83          	lw	s11,1364(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	4fe50513          	addi	a0,a0,1278 # 80010af8 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3a050513          	addi	a0,a0,928 # 80010af8 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	38448493          	addi	s1,s1,900 # 80010af8 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	34450513          	addi	a0,a0,836 # 80010b18 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0d07a783          	lw	a5,208(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0a07b783          	ld	a5,160(a5) # 800088d8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0a073703          	ld	a4,160(a4) # 800088e0 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2b6a0a13          	addi	s4,s4,694 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	06e48493          	addi	s1,s1,110 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	06e98993          	addi	s3,s3,110 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	82c080e7          	jalr	-2004(ra) # 800020c0 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	24850513          	addi	a0,a0,584 # 80010b18 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	ff07a783          	lw	a5,-16(a5) # 800088d0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	ff673703          	ld	a4,-10(a4) # 800088e0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fe67b783          	ld	a5,-26(a5) # 800088d8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	21a98993          	addi	s3,s3,538 # 80010b18 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	fd248493          	addi	s1,s1,-46 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	fd290913          	addi	s2,s2,-46 # 800088e0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	73e080e7          	jalr	1854(ra) # 8000205c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	1e448493          	addi	s1,s1,484 # 80010b18 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	f8e7bc23          	sd	a4,-104(a5) # 800088e0 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	15e48493          	addi	s1,s1,350 # 80010b18 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	47478793          	addi	a5,a5,1140 # 80021e70 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	13490913          	addi	s2,s2,308 # 80010b50 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	3a250513          	addi	a0,a0,930 # 80021e70 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e28080e7          	jalr	-472(ra) # 80001998 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	df6080e7          	jalr	-522(ra) # 80001998 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	dea080e7          	jalr	-534(ra) # 80001998 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dd2080e7          	jalr	-558(ra) # 80001998 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d92080e7          	jalr	-622(ra) # 80001998 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d66080e7          	jalr	-666(ra) # 80001998 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd191>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b08080e7          	jalr	-1272(ra) # 80001988 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	aec080e7          	jalr	-1300(ra) # 80001988 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	794080e7          	jalr	1940(ra) # 80002652 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	dda080e7          	jalr	-550(ra) # 80005ca0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fdc080e7          	jalr	-36(ra) # 80001eaa <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	6f4080e7          	jalr	1780(ra) # 8000262a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	714080e7          	jalr	1812(ra) # 80002652 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	d44080e7          	jalr	-700(ra) # 80005c8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	d52080e7          	jalr	-686(ra) # 80005ca0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	ef2080e7          	jalr	-270(ra) # 80002e48 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	592080e7          	jalr	1426(ra) # 800034f0 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	538080e7          	jalr	1336(ra) # 8000449e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	e3a080e7          	jalr	-454(ra) # 80005da8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d16080e7          	jalr	-746(ra) # 80001c8c <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd187>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd190>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	13aa0a13          	addi	s4,s4,314 # 800169a0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	16848493          	addi	s1,s1,360
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	28850513          	addi	a0,a0,648 # 80010b70 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	28850513          	addi	a0,a0,648 # 80010b88 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	69048493          	addi	s1,s1,1680 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	06e98993          	addi	s3,s3,110 # 800169a0 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	16848493          	addi	s1,s1,360
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
  // taks 4:
  petersonlock_init(); 
    8000196c:	00005097          	auipc	ra,0x5
    80001970:	90c080e7          	jalr	-1780(ra) # 80006278 <petersonlock_init>
}
    80001974:	70e2                	ld	ra,56(sp)
    80001976:	7442                	ld	s0,48(sp)
    80001978:	74a2                	ld	s1,40(sp)
    8000197a:	7902                	ld	s2,32(sp)
    8000197c:	69e2                	ld	s3,24(sp)
    8000197e:	6a42                	ld	s4,16(sp)
    80001980:	6aa2                	ld	s5,8(sp)
    80001982:	6b02                	ld	s6,0(sp)
    80001984:	6121                	addi	sp,sp,64
    80001986:	8082                	ret

0000000080001988 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e422                	sd	s0,8(sp)
    8000198c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001990:	2501                	sext.w	a0,a0
    80001992:	6422                	ld	s0,8(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001998:	1141                	addi	sp,sp,-16
    8000199a:	e422                	sd	s0,8(sp)
    8000199c:	0800                	addi	s0,sp,16
    8000199e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a0:	2781                	sext.w	a5,a5
    800019a2:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a4:	0000f517          	auipc	a0,0xf
    800019a8:	1fc50513          	addi	a0,a0,508 # 80010ba0 <cpus>
    800019ac:	953e                	add	a0,a0,a5
    800019ae:	6422                	ld	s0,8(sp)
    800019b0:	0141                	addi	sp,sp,16
    800019b2:	8082                	ret

00000000800019b4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	1000                	addi	s0,sp,32
  push_off();
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	1cc080e7          	jalr	460(ra) # 80000b8a <push_off>
    800019c6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c8:	2781                	sext.w	a5,a5
    800019ca:	079e                	slli	a5,a5,0x7
    800019cc:	0000f717          	auipc	a4,0xf
    800019d0:	1a470713          	addi	a4,a4,420 # 80010b70 <pid_lock>
    800019d4:	97ba                	add	a5,a5,a4
    800019d6:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	252080e7          	jalr	594(ra) # 80000c2a <pop_off>
  return p;
}
    800019e0:	8526                	mv	a0,s1
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6105                	addi	sp,sp,32
    800019ea:	8082                	ret

00000000800019ec <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e406                	sd	ra,8(sp)
    800019f0:	e022                	sd	s0,0(sp)
    800019f2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	fc0080e7          	jalr	-64(ra) # 800019b4 <myproc>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	28e080e7          	jalr	654(ra) # 80000c8a <release>

  if (first) {
    80001a04:	00007797          	auipc	a5,0x7
    80001a08:	e5c7a783          	lw	a5,-420(a5) # 80008860 <first.1>
    80001a0c:	eb89                	bnez	a5,80001a1e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0e:	00001097          	auipc	ra,0x1
    80001a12:	c5c080e7          	jalr	-932(ra) # 8000266a <usertrapret>
}
    80001a16:	60a2                	ld	ra,8(sp)
    80001a18:	6402                	ld	s0,0(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret
    first = 0;
    80001a1e:	00007797          	auipc	a5,0x7
    80001a22:	e407a123          	sw	zero,-446(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a26:	4505                	li	a0,1
    80001a28:	00002097          	auipc	ra,0x2
    80001a2c:	a48080e7          	jalr	-1464(ra) # 80003470 <fsinit>
    80001a30:	bff9                	j	80001a0e <forkret+0x22>

0000000080001a32 <allocpid>:
{
    80001a32:	1101                	addi	sp,sp,-32
    80001a34:	ec06                	sd	ra,24(sp)
    80001a36:	e822                	sd	s0,16(sp)
    80001a38:	e426                	sd	s1,8(sp)
    80001a3a:	e04a                	sd	s2,0(sp)
    80001a3c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3e:	0000f917          	auipc	s2,0xf
    80001a42:	13290913          	addi	s2,s2,306 # 80010b70 <pid_lock>
    80001a46:	854a                	mv	a0,s2
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	18e080e7          	jalr	398(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a50:	00007797          	auipc	a5,0x7
    80001a54:	e1478793          	addi	a5,a5,-492 # 80008864 <nextpid>
    80001a58:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a5a:	0014871b          	addiw	a4,s1,1
    80001a5e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a60:	854a                	mv	a0,s2
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	228080e7          	jalr	552(ra) # 80000c8a <release>
}
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6902                	ld	s2,0(sp)
    80001a74:	6105                	addi	sp,sp,32
    80001a76:	8082                	ret

0000000080001a78 <proc_pagetable>:
{
    80001a78:	1101                	addi	sp,sp,-32
    80001a7a:	ec06                	sd	ra,24(sp)
    80001a7c:	e822                	sd	s0,16(sp)
    80001a7e:	e426                	sd	s1,8(sp)
    80001a80:	e04a                	sd	s2,0(sp)
    80001a82:	1000                	addi	s0,sp,32
    80001a84:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	8a2080e7          	jalr	-1886(ra) # 80001328 <uvmcreate>
    80001a8e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a90:	c121                	beqz	a0,80001ad0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a92:	4729                	li	a4,10
    80001a94:	00005697          	auipc	a3,0x5
    80001a98:	56c68693          	addi	a3,a3,1388 # 80007000 <_trampoline>
    80001a9c:	6605                	lui	a2,0x1
    80001a9e:	040005b7          	lui	a1,0x4000
    80001aa2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa4:	05b2                	slli	a1,a1,0xc
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5f8080e7          	jalr	1528(ra) # 8000109e <mappages>
    80001aae:	02054863          	bltz	a0,80001ade <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ab2:	4719                	li	a4,6
    80001ab4:	05893683          	ld	a3,88(s2)
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	020005b7          	lui	a1,0x2000
    80001abe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac0:	05b6                	slli	a1,a1,0xd
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	5da080e7          	jalr	1498(ra) # 8000109e <mappages>
    80001acc:	02054163          	bltz	a0,80001aee <proc_pagetable+0x76>
}
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	60e2                	ld	ra,24(sp)
    80001ad4:	6442                	ld	s0,16(sp)
    80001ad6:	64a2                	ld	s1,8(sp)
    80001ad8:	6902                	ld	s2,0(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret
    uvmfree(pagetable, 0);
    80001ade:	4581                	li	a1,0
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	00000097          	auipc	ra,0x0
    80001ae6:	a4c080e7          	jalr	-1460(ra) # 8000152e <uvmfree>
    return 0;
    80001aea:	4481                	li	s1,0
    80001aec:	b7d5                	j	80001ad0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	8526                	mv	a0,s1
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	768080e7          	jalr	1896(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b04:	4581                	li	a1,0
    80001b06:	8526                	mv	a0,s1
    80001b08:	00000097          	auipc	ra,0x0
    80001b0c:	a26080e7          	jalr	-1498(ra) # 8000152e <uvmfree>
    return 0;
    80001b10:	4481                	li	s1,0
    80001b12:	bf7d                	j	80001ad0 <proc_pagetable+0x58>

0000000080001b14 <proc_freepagetable>:
{
    80001b14:	1101                	addi	sp,sp,-32
    80001b16:	ec06                	sd	ra,24(sp)
    80001b18:	e822                	sd	s0,16(sp)
    80001b1a:	e426                	sd	s1,8(sp)
    80001b1c:	e04a                	sd	s2,0(sp)
    80001b1e:	1000                	addi	s0,sp,32
    80001b20:	84aa                	mv	s1,a0
    80001b22:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b24:	4681                	li	a3,0
    80001b26:	4605                	li	a2,1
    80001b28:	040005b7          	lui	a1,0x4000
    80001b2c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b2e:	05b2                	slli	a1,a1,0xc
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	734080e7          	jalr	1844(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	71e080e7          	jalr	1822(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	9dc080e7          	jalr	-1572(ra) # 8000152e <uvmfree>
}
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6902                	ld	s2,0(sp)
    80001b62:	6105                	addi	sp,sp,32
    80001b64:	8082                	ret

0000000080001b66 <freeproc>:
{
    80001b66:	1101                	addi	sp,sp,-32
    80001b68:	ec06                	sd	ra,24(sp)
    80001b6a:	e822                	sd	s0,16(sp)
    80001b6c:	e426                	sd	s1,8(sp)
    80001b6e:	1000                	addi	s0,sp,32
    80001b70:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b72:	6d28                	ld	a0,88(a0)
    80001b74:	c509                	beqz	a0,80001b7e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	e72080e7          	jalr	-398(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b7e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b82:	68a8                	ld	a0,80(s1)
    80001b84:	c511                	beqz	a0,80001b90 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b86:	64ac                	ld	a1,72(s1)
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	f8c080e7          	jalr	-116(ra) # 80001b14 <proc_freepagetable>
  p->pagetable = 0;
    80001b90:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b94:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b98:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bac:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb0:	0004ac23          	sw	zero,24(s1)
}
    80001bb4:	60e2                	ld	ra,24(sp)
    80001bb6:	6442                	ld	s0,16(sp)
    80001bb8:	64a2                	ld	s1,8(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret

0000000080001bbe <allocproc>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bca:	0000f497          	auipc	s1,0xf
    80001bce:	3d648493          	addi	s1,s1,982 # 80010fa0 <proc>
    80001bd2:	00015917          	auipc	s2,0x15
    80001bd6:	dce90913          	addi	s2,s2,-562 # 800169a0 <tickslock>
    acquire(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	ffa080e7          	jalr	-6(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001be4:	4c9c                	lw	a5,24(s1)
    80001be6:	cf81                	beqz	a5,80001bfe <allocproc+0x40>
      release(&p->lock);
    80001be8:	8526                	mv	a0,s1
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	0a0080e7          	jalr	160(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf2:	16848493          	addi	s1,s1,360
    80001bf6:	ff2492e3          	bne	s1,s2,80001bda <allocproc+0x1c>
  return 0;
    80001bfa:	4481                	li	s1,0
    80001bfc:	a889                	j	80001c4e <allocproc+0x90>
  p->pid = allocpid();
    80001bfe:	00000097          	auipc	ra,0x0
    80001c02:	e34080e7          	jalr	-460(ra) # 80001a32 <allocpid>
    80001c06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c08:	4785                	li	a5,1
    80001c0a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	eda080e7          	jalr	-294(ra) # 80000ae6 <kalloc>
    80001c14:	892a                	mv	s2,a0
    80001c16:	eca8                	sd	a0,88(s1)
    80001c18:	c131                	beqz	a0,80001c5c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	e5c080e7          	jalr	-420(ra) # 80001a78 <proc_pagetable>
    80001c24:	892a                	mv	s2,a0
    80001c26:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c28:	c531                	beqz	a0,80001c74 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c2a:	07000613          	li	a2,112
    80001c2e:	4581                	li	a1,0
    80001c30:	06048513          	addi	a0,s1,96
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	09e080e7          	jalr	158(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c3c:	00000797          	auipc	a5,0x0
    80001c40:	db078793          	addi	a5,a5,-592 # 800019ec <forkret>
    80001c44:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c46:	60bc                	ld	a5,64(s1)
    80001c48:	6705                	lui	a4,0x1
    80001c4a:	97ba                	add	a5,a5,a4
    80001c4c:	f4bc                	sd	a5,104(s1)
}
    80001c4e:	8526                	mv	a0,s1
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6902                	ld	s2,0(sp)
    80001c58:	6105                	addi	sp,sp,32
    80001c5a:	8082                	ret
    freeproc(p);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	00000097          	auipc	ra,0x0
    80001c62:	f08080e7          	jalr	-248(ra) # 80001b66 <freeproc>
    release(&p->lock);
    80001c66:	8526                	mv	a0,s1
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	022080e7          	jalr	34(ra) # 80000c8a <release>
    return 0;
    80001c70:	84ca                	mv	s1,s2
    80001c72:	bff1                	j	80001c4e <allocproc+0x90>
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ef0080e7          	jalr	-272(ra) # 80001b66 <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	b7d1                	j	80001c4e <allocproc+0x90>

0000000080001c8c <userinit>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c96:	00000097          	auipc	ra,0x0
    80001c9a:	f28080e7          	jalr	-216(ra) # 80001bbe <allocproc>
    80001c9e:	84aa                	mv	s1,a0
  initproc = p;
    80001ca0:	00007797          	auipc	a5,0x7
    80001ca4:	c4a7bc23          	sd	a0,-936(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca8:	03400613          	li	a2,52
    80001cac:	00007597          	auipc	a1,0x7
    80001cb0:	bc458593          	addi	a1,a1,-1084 # 80008870 <initcode>
    80001cb4:	6928                	ld	a0,80(a0)
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	6a0080e7          	jalr	1696(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cbe:	6785                	lui	a5,0x1
    80001cc0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cc2:	6cb8                	ld	a4,88(s1)
    80001cc4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc8:	6cb8                	ld	a4,88(s1)
    80001cca:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ccc:	4641                	li	a2,16
    80001cce:	00006597          	auipc	a1,0x6
    80001cd2:	53258593          	addi	a1,a1,1330 # 80008200 <digits+0x1c0>
    80001cd6:	15848513          	addi	a0,s1,344
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	142080e7          	jalr	322(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001ce2:	00006517          	auipc	a0,0x6
    80001ce6:	52e50513          	addi	a0,a0,1326 # 80008210 <digits+0x1d0>
    80001cea:	00002097          	auipc	ra,0x2
    80001cee:	1b0080e7          	jalr	432(ra) # 80003e9a <namei>
    80001cf2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf6:	478d                	li	a5,3
    80001cf8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	f8e080e7          	jalr	-114(ra) # 80000c8a <release>
}
    80001d04:	60e2                	ld	ra,24(sp)
    80001d06:	6442                	ld	s0,16(sp)
    80001d08:	64a2                	ld	s1,8(sp)
    80001d0a:	6105                	addi	sp,sp,32
    80001d0c:	8082                	ret

0000000080001d0e <growproc>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	e04a                	sd	s2,0(sp)
    80001d18:	1000                	addi	s0,sp,32
    80001d1a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d1c:	00000097          	auipc	ra,0x0
    80001d20:	c98080e7          	jalr	-872(ra) # 800019b4 <myproc>
    80001d24:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d26:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d28:	01204c63          	bgtz	s2,80001d40 <growproc+0x32>
  } else if(n < 0){
    80001d2c:	02094663          	bltz	s2,80001d58 <growproc+0x4a>
  p->sz = sz;
    80001d30:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d32:	4501                	li	a0,0
}
    80001d34:	60e2                	ld	ra,24(sp)
    80001d36:	6442                	ld	s0,16(sp)
    80001d38:	64a2                	ld	s1,8(sp)
    80001d3a:	6902                	ld	s2,0(sp)
    80001d3c:	6105                	addi	sp,sp,32
    80001d3e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d40:	4691                	li	a3,4
    80001d42:	00b90633          	add	a2,s2,a1
    80001d46:	6928                	ld	a0,80(a0)
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	6c8080e7          	jalr	1736(ra) # 80001410 <uvmalloc>
    80001d50:	85aa                	mv	a1,a0
    80001d52:	fd79                	bnez	a0,80001d30 <growproc+0x22>
      return -1;
    80001d54:	557d                	li	a0,-1
    80001d56:	bff9                	j	80001d34 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d58:	00b90633          	add	a2,s2,a1
    80001d5c:	6928                	ld	a0,80(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	66a080e7          	jalr	1642(ra) # 800013c8 <uvmdealloc>
    80001d66:	85aa                	mv	a1,a0
    80001d68:	b7e1                	j	80001d30 <growproc+0x22>

0000000080001d6a <fork>:
{
    80001d6a:	7139                	addi	sp,sp,-64
    80001d6c:	fc06                	sd	ra,56(sp)
    80001d6e:	f822                	sd	s0,48(sp)
    80001d70:	f426                	sd	s1,40(sp)
    80001d72:	f04a                	sd	s2,32(sp)
    80001d74:	ec4e                	sd	s3,24(sp)
    80001d76:	e852                	sd	s4,16(sp)
    80001d78:	e456                	sd	s5,8(sp)
    80001d7a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	c38080e7          	jalr	-968(ra) # 800019b4 <myproc>
    80001d84:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	e38080e7          	jalr	-456(ra) # 80001bbe <allocproc>
    80001d8e:	10050c63          	beqz	a0,80001ea6 <fork+0x13c>
    80001d92:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d94:	048ab603          	ld	a2,72(s5)
    80001d98:	692c                	ld	a1,80(a0)
    80001d9a:	050ab503          	ld	a0,80(s5)
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	7ca080e7          	jalr	1994(ra) # 80001568 <uvmcopy>
    80001da6:	04054863          	bltz	a0,80001df6 <fork+0x8c>
  np->sz = p->sz;
    80001daa:	048ab783          	ld	a5,72(s5)
    80001dae:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db2:	058ab683          	ld	a3,88(s5)
    80001db6:	87b6                	mv	a5,a3
    80001db8:	058a3703          	ld	a4,88(s4)
    80001dbc:	12068693          	addi	a3,a3,288
    80001dc0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dc4:	6788                	ld	a0,8(a5)
    80001dc6:	6b8c                	ld	a1,16(a5)
    80001dc8:	6f90                	ld	a2,24(a5)
    80001dca:	01073023          	sd	a6,0(a4)
    80001dce:	e708                	sd	a0,8(a4)
    80001dd0:	eb0c                	sd	a1,16(a4)
    80001dd2:	ef10                	sd	a2,24(a4)
    80001dd4:	02078793          	addi	a5,a5,32
    80001dd8:	02070713          	addi	a4,a4,32
    80001ddc:	fed792e3          	bne	a5,a3,80001dc0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de0:	058a3783          	ld	a5,88(s4)
    80001de4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de8:	0d0a8493          	addi	s1,s5,208
    80001dec:	0d0a0913          	addi	s2,s4,208
    80001df0:	150a8993          	addi	s3,s5,336
    80001df4:	a00d                	j	80001e16 <fork+0xac>
    freeproc(np);
    80001df6:	8552                	mv	a0,s4
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	d6e080e7          	jalr	-658(ra) # 80001b66 <freeproc>
    release(&np->lock);
    80001e00:	8552                	mv	a0,s4
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	e88080e7          	jalr	-376(ra) # 80000c8a <release>
    return -1;
    80001e0a:	597d                	li	s2,-1
    80001e0c:	a059                	j	80001e92 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e0e:	04a1                	addi	s1,s1,8
    80001e10:	0921                	addi	s2,s2,8
    80001e12:	01348b63          	beq	s1,s3,80001e28 <fork+0xbe>
    if(p->ofile[i])
    80001e16:	6088                	ld	a0,0(s1)
    80001e18:	d97d                	beqz	a0,80001e0e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1a:	00002097          	auipc	ra,0x2
    80001e1e:	716080e7          	jalr	1814(ra) # 80004530 <filedup>
    80001e22:	00a93023          	sd	a0,0(s2)
    80001e26:	b7e5                	j	80001e0e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e28:	150ab503          	ld	a0,336(s5)
    80001e2c:	00002097          	auipc	ra,0x2
    80001e30:	884080e7          	jalr	-1916(ra) # 800036b0 <idup>
    80001e34:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e38:	4641                	li	a2,16
    80001e3a:	158a8593          	addi	a1,s5,344
    80001e3e:	158a0513          	addi	a0,s4,344
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	fda080e7          	jalr	-38(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e4a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e4e:	8552                	mv	a0,s4
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	e3a080e7          	jalr	-454(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e58:	0000f497          	auipc	s1,0xf
    80001e5c:	d3048493          	addi	s1,s1,-720 # 80010b88 <wait_lock>
    80001e60:	8526                	mv	a0,s1
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	d74080e7          	jalr	-652(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e6a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	e1a080e7          	jalr	-486(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e78:	8552                	mv	a0,s4
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d5c080e7          	jalr	-676(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e82:	478d                	li	a5,3
    80001e84:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e88:	8552                	mv	a0,s4
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e00080e7          	jalr	-512(ra) # 80000c8a <release>
}
    80001e92:	854a                	mv	a0,s2
    80001e94:	70e2                	ld	ra,56(sp)
    80001e96:	7442                	ld	s0,48(sp)
    80001e98:	74a2                	ld	s1,40(sp)
    80001e9a:	7902                	ld	s2,32(sp)
    80001e9c:	69e2                	ld	s3,24(sp)
    80001e9e:	6a42                	ld	s4,16(sp)
    80001ea0:	6aa2                	ld	s5,8(sp)
    80001ea2:	6121                	addi	sp,sp,64
    80001ea4:	8082                	ret
    return -1;
    80001ea6:	597d                	li	s2,-1
    80001ea8:	b7ed                	j	80001e92 <fork+0x128>

0000000080001eaa <scheduler>:
{
    80001eaa:	7139                	addi	sp,sp,-64
    80001eac:	fc06                	sd	ra,56(sp)
    80001eae:	f822                	sd	s0,48(sp)
    80001eb0:	f426                	sd	s1,40(sp)
    80001eb2:	f04a                	sd	s2,32(sp)
    80001eb4:	ec4e                	sd	s3,24(sp)
    80001eb6:	e852                	sd	s4,16(sp)
    80001eb8:	e456                	sd	s5,8(sp)
    80001eba:	e05a                	sd	s6,0(sp)
    80001ebc:	0080                	addi	s0,sp,64
    80001ebe:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec2:	00779a93          	slli	s5,a5,0x7
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	caa70713          	addi	a4,a4,-854 # 80010b70 <pid_lock>
    80001ece:	9756                	add	a4,a4,s5
    80001ed0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	cd470713          	addi	a4,a4,-812 # 80010ba8 <cpus+0x8>
    80001edc:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ede:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee0:	4b11                	li	s6,4
        c->proc = p;
    80001ee2:	079e                	slli	a5,a5,0x7
    80001ee4:	0000fa17          	auipc	s4,0xf
    80001ee8:	c8ca0a13          	addi	s4,s4,-884 # 80010b70 <pid_lock>
    80001eec:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eee:	00015917          	auipc	s2,0x15
    80001ef2:	ab290913          	addi	s2,s2,-1358 # 800169a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efe:	10079073          	csrw	sstatus,a5
    80001f02:	0000f497          	auipc	s1,0xf
    80001f06:	09e48493          	addi	s1,s1,158 # 80010fa0 <proc>
    80001f0a:	a811                	j	80001f1e <scheduler+0x74>
      release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	d7c080e7          	jalr	-644(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	16848493          	addi	s1,s1,360
    80001f1a:	fd248ee3          	beq	s1,s2,80001ef6 <scheduler+0x4c>
      acquire(&p->lock);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	cb6080e7          	jalr	-842(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f28:	4c9c                	lw	a5,24(s1)
    80001f2a:	ff3791e3          	bne	a5,s3,80001f0c <scheduler+0x62>
        p->state = RUNNING;
    80001f2e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f32:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f36:	06048593          	addi	a1,s1,96
    80001f3a:	8556                	mv	a0,s5
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	684080e7          	jalr	1668(ra) # 800025c0 <swtch>
        c->proc = 0;
    80001f44:	020a3823          	sd	zero,48(s4)
    80001f48:	b7d1                	j	80001f0c <scheduler+0x62>

0000000080001f4a <sched>:
{
    80001f4a:	7179                	addi	sp,sp,-48
    80001f4c:	f406                	sd	ra,40(sp)
    80001f4e:	f022                	sd	s0,32(sp)
    80001f50:	ec26                	sd	s1,24(sp)
    80001f52:	e84a                	sd	s2,16(sp)
    80001f54:	e44e                	sd	s3,8(sp)
    80001f56:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	a5c080e7          	jalr	-1444(ra) # 800019b4 <myproc>
    80001f60:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	bfa080e7          	jalr	-1030(ra) # 80000b5c <holding>
    80001f6a:	c93d                	beqz	a0,80001fe0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f6e:	2781                	sext.w	a5,a5
    80001f70:	079e                	slli	a5,a5,0x7
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	bfe70713          	addi	a4,a4,-1026 # 80010b70 <pid_lock>
    80001f7a:	97ba                	add	a5,a5,a4
    80001f7c:	0a87a703          	lw	a4,168(a5)
    80001f80:	4785                	li	a5,1
    80001f82:	06f71763          	bne	a4,a5,80001ff0 <sched+0xa6>
  if(p->state == RUNNING)
    80001f86:	4c98                	lw	a4,24(s1)
    80001f88:	4791                	li	a5,4
    80001f8a:	06f70b63          	beq	a4,a5,80002000 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f94:	efb5                	bnez	a5,80002010 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f96:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f98:	0000f917          	auipc	s2,0xf
    80001f9c:	bd890913          	addi	s2,s2,-1064 # 80010b70 <pid_lock>
    80001fa0:	2781                	sext.w	a5,a5
    80001fa2:	079e                	slli	a5,a5,0x7
    80001fa4:	97ca                	add	a5,a5,s2
    80001fa6:	0ac7a983          	lw	s3,172(a5)
    80001faa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
    80001fb0:	0000f597          	auipc	a1,0xf
    80001fb4:	bf858593          	addi	a1,a1,-1032 # 80010ba8 <cpus+0x8>
    80001fb8:	95be                	add	a1,a1,a5
    80001fba:	06048513          	addi	a0,s1,96
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	602080e7          	jalr	1538(ra) # 800025c0 <swtch>
    80001fc6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc8:	2781                	sext.w	a5,a5
    80001fca:	079e                	slli	a5,a5,0x7
    80001fcc:	993e                	add	s2,s2,a5
    80001fce:	0b392623          	sw	s3,172(s2)
}
    80001fd2:	70a2                	ld	ra,40(sp)
    80001fd4:	7402                	ld	s0,32(sp)
    80001fd6:	64e2                	ld	s1,24(sp)
    80001fd8:	6942                	ld	s2,16(sp)
    80001fda:	69a2                	ld	s3,8(sp)
    80001fdc:	6145                	addi	sp,sp,48
    80001fde:	8082                	ret
    panic("sched p->lock");
    80001fe0:	00006517          	auipc	a0,0x6
    80001fe4:	23850513          	addi	a0,a0,568 # 80008218 <digits+0x1d8>
    80001fe8:	ffffe097          	auipc	ra,0xffffe
    80001fec:	558080e7          	jalr	1368(ra) # 80000540 <panic>
    panic("sched locks");
    80001ff0:	00006517          	auipc	a0,0x6
    80001ff4:	23850513          	addi	a0,a0,568 # 80008228 <digits+0x1e8>
    80001ff8:	ffffe097          	auipc	ra,0xffffe
    80001ffc:	548080e7          	jalr	1352(ra) # 80000540 <panic>
    panic("sched running");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	23850513          	addi	a0,a0,568 # 80008238 <digits+0x1f8>
    80002008:	ffffe097          	auipc	ra,0xffffe
    8000200c:	538080e7          	jalr	1336(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	23850513          	addi	a0,a0,568 # 80008248 <digits+0x208>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	528080e7          	jalr	1320(ra) # 80000540 <panic>

0000000080002020 <yield>:
{
    80002020:	1101                	addi	sp,sp,-32
    80002022:	ec06                	sd	ra,24(sp)
    80002024:	e822                	sd	s0,16(sp)
    80002026:	e426                	sd	s1,8(sp)
    80002028:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000202a:	00000097          	auipc	ra,0x0
    8000202e:	98a080e7          	jalr	-1654(ra) # 800019b4 <myproc>
    80002032:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	ba2080e7          	jalr	-1118(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000203c:	478d                	li	a5,3
    8000203e:	cc9c                	sw	a5,24(s1)
  sched();
    80002040:	00000097          	auipc	ra,0x0
    80002044:	f0a080e7          	jalr	-246(ra) # 80001f4a <sched>
  release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	c40080e7          	jalr	-960(ra) # 80000c8a <release>
}
    80002052:	60e2                	ld	ra,24(sp)
    80002054:	6442                	ld	s0,16(sp)
    80002056:	64a2                	ld	s1,8(sp)
    80002058:	6105                	addi	sp,sp,32
    8000205a:	8082                	ret

000000008000205c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	89aa                	mv	s3,a0
    8000206c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	946080e7          	jalr	-1722(ra) # 800019b4 <myproc>
    80002076:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	b5e080e7          	jalr	-1186(ra) # 80000bd6 <acquire>
  release(lk);
    80002080:	854a                	mv	a0,s2
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	c08080e7          	jalr	-1016(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000208a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000208e:	4789                	li	a5,2
    80002090:	cc9c                	sw	a5,24(s1)

  sched();
    80002092:	00000097          	auipc	ra,0x0
    80002096:	eb8080e7          	jalr	-328(ra) # 80001f4a <sched>

  // Tidy up.
  p->chan = 0;
    8000209a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	bea080e7          	jalr	-1046(ra) # 80000c8a <release>
  acquire(lk);
    800020a8:	854a                	mv	a0,s2
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b2c080e7          	jalr	-1236(ra) # 80000bd6 <acquire>
}
    800020b2:	70a2                	ld	ra,40(sp)
    800020b4:	7402                	ld	s0,32(sp)
    800020b6:	64e2                	ld	s1,24(sp)
    800020b8:	6942                	ld	s2,16(sp)
    800020ba:	69a2                	ld	s3,8(sp)
    800020bc:	6145                	addi	sp,sp,48
    800020be:	8082                	ret

00000000800020c0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020c0:	7139                	addi	sp,sp,-64
    800020c2:	fc06                	sd	ra,56(sp)
    800020c4:	f822                	sd	s0,48(sp)
    800020c6:	f426                	sd	s1,40(sp)
    800020c8:	f04a                	sd	s2,32(sp)
    800020ca:	ec4e                	sd	s3,24(sp)
    800020cc:	e852                	sd	s4,16(sp)
    800020ce:	e456                	sd	s5,8(sp)
    800020d0:	0080                	addi	s0,sp,64
    800020d2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020d4:	0000f497          	auipc	s1,0xf
    800020d8:	ecc48493          	addi	s1,s1,-308 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020dc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020de:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e0:	00015917          	auipc	s2,0x15
    800020e4:	8c090913          	addi	s2,s2,-1856 # 800169a0 <tickslock>
    800020e8:	a811                	j	800020fc <wakeup+0x3c>
      }
      release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	b9e080e7          	jalr	-1122(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f4:	16848493          	addi	s1,s1,360
    800020f8:	03248663          	beq	s1,s2,80002124 <wakeup+0x64>
    if(p != myproc()){
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	8b8080e7          	jalr	-1864(ra) # 800019b4 <myproc>
    80002104:	fea488e3          	beq	s1,a0,800020f4 <wakeup+0x34>
      acquire(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	acc080e7          	jalr	-1332(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002112:	4c9c                	lw	a5,24(s1)
    80002114:	fd379be3          	bne	a5,s3,800020ea <wakeup+0x2a>
    80002118:	709c                	ld	a5,32(s1)
    8000211a:	fd4798e3          	bne	a5,s4,800020ea <wakeup+0x2a>
        p->state = RUNNABLE;
    8000211e:	0154ac23          	sw	s5,24(s1)
    80002122:	b7e1                	j	800020ea <wakeup+0x2a>
    }
  }
}
    80002124:	70e2                	ld	ra,56(sp)
    80002126:	7442                	ld	s0,48(sp)
    80002128:	74a2                	ld	s1,40(sp)
    8000212a:	7902                	ld	s2,32(sp)
    8000212c:	69e2                	ld	s3,24(sp)
    8000212e:	6a42                	ld	s4,16(sp)
    80002130:	6aa2                	ld	s5,8(sp)
    80002132:	6121                	addi	sp,sp,64
    80002134:	8082                	ret

0000000080002136 <reparent>:
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	e84a                	sd	s2,16(sp)
    80002140:	e44e                	sd	s3,8(sp)
    80002142:	e052                	sd	s4,0(sp)
    80002144:	1800                	addi	s0,sp,48
    80002146:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002148:	0000f497          	auipc	s1,0xf
    8000214c:	e5848493          	addi	s1,s1,-424 # 80010fa0 <proc>
      pp->parent = initproc;
    80002150:	00006a17          	auipc	s4,0x6
    80002154:	7a8a0a13          	addi	s4,s4,1960 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002158:	00015997          	auipc	s3,0x15
    8000215c:	84898993          	addi	s3,s3,-1976 # 800169a0 <tickslock>
    80002160:	a029                	j	8000216a <reparent+0x34>
    80002162:	16848493          	addi	s1,s1,360
    80002166:	01348d63          	beq	s1,s3,80002180 <reparent+0x4a>
    if(pp->parent == p){
    8000216a:	7c9c                	ld	a5,56(s1)
    8000216c:	ff279be3          	bne	a5,s2,80002162 <reparent+0x2c>
      pp->parent = initproc;
    80002170:	000a3503          	ld	a0,0(s4)
    80002174:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	f4a080e7          	jalr	-182(ra) # 800020c0 <wakeup>
    8000217e:	b7d5                	j	80002162 <reparent+0x2c>
}
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6942                	ld	s2,16(sp)
    80002188:	69a2                	ld	s3,8(sp)
    8000218a:	6a02                	ld	s4,0(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret

0000000080002190 <exit>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	812080e7          	jalr	-2030(ra) # 800019b4 <myproc>
    800021aa:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ac:	00006797          	auipc	a5,0x6
    800021b0:	74c7b783          	ld	a5,1868(a5) # 800088f8 <initproc>
    800021b4:	0d050493          	addi	s1,a0,208
    800021b8:	15050913          	addi	s2,a0,336
    800021bc:	02a79363          	bne	a5,a0,800021e2 <exit+0x52>
    panic("init exiting");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	0a050513          	addi	a0,a0,160 # 80008260 <digits+0x220>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	378080e7          	jalr	888(ra) # 80000540 <panic>
      fileclose(f);
    800021d0:	00002097          	auipc	ra,0x2
    800021d4:	3b2080e7          	jalr	946(ra) # 80004582 <fileclose>
      p->ofile[fd] = 0;
    800021d8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021dc:	04a1                	addi	s1,s1,8
    800021de:	01248563          	beq	s1,s2,800021e8 <exit+0x58>
    if(p->ofile[fd]){
    800021e2:	6088                	ld	a0,0(s1)
    800021e4:	f575                	bnez	a0,800021d0 <exit+0x40>
    800021e6:	bfdd                	j	800021dc <exit+0x4c>
  begin_op();
    800021e8:	00002097          	auipc	ra,0x2
    800021ec:	ed2080e7          	jalr	-302(ra) # 800040ba <begin_op>
  iput(p->cwd);
    800021f0:	1509b503          	ld	a0,336(s3)
    800021f4:	00001097          	auipc	ra,0x1
    800021f8:	6b4080e7          	jalr	1716(ra) # 800038a8 <iput>
  end_op();
    800021fc:	00002097          	auipc	ra,0x2
    80002200:	f3c080e7          	jalr	-196(ra) # 80004138 <end_op>
  p->cwd = 0;
    80002204:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002208:	0000f497          	auipc	s1,0xf
    8000220c:	98048493          	addi	s1,s1,-1664 # 80010b88 <wait_lock>
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9c4080e7          	jalr	-1596(ra) # 80000bd6 <acquire>
  reparent(p);
    8000221a:	854e                	mv	a0,s3
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	f1a080e7          	jalr	-230(ra) # 80002136 <reparent>
  wakeup(p->parent);
    80002224:	0389b503          	ld	a0,56(s3)
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	e98080e7          	jalr	-360(ra) # 800020c0 <wakeup>
  acquire(&p->lock);
    80002230:	854e                	mv	a0,s3
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	9a4080e7          	jalr	-1628(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000223a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000223e:	4795                	li	a5,5
    80002240:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>
  sched();
    8000224e:	00000097          	auipc	ra,0x0
    80002252:	cfc080e7          	jalr	-772(ra) # 80001f4a <sched>
  panic("zombie exit");
    80002256:	00006517          	auipc	a0,0x6
    8000225a:	01a50513          	addi	a0,a0,26 # 80008270 <digits+0x230>
    8000225e:	ffffe097          	auipc	ra,0xffffe
    80002262:	2e2080e7          	jalr	738(ra) # 80000540 <panic>

0000000080002266 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002266:	7179                	addi	sp,sp,-48
    80002268:	f406                	sd	ra,40(sp)
    8000226a:	f022                	sd	s0,32(sp)
    8000226c:	ec26                	sd	s1,24(sp)
    8000226e:	e84a                	sd	s2,16(sp)
    80002270:	e44e                	sd	s3,8(sp)
    80002272:	1800                	addi	s0,sp,48
    80002274:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	d2a48493          	addi	s1,s1,-726 # 80010fa0 <proc>
    8000227e:	00014997          	auipc	s3,0x14
    80002282:	72298993          	addi	s3,s3,1826 # 800169a0 <tickslock>
    acquire(&p->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	94e080e7          	jalr	-1714(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002290:	589c                	lw	a5,48(s1)
    80002292:	01278d63          	beq	a5,s2,800022ac <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002296:	8526                	mv	a0,s1
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	9f2080e7          	jalr	-1550(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a0:	16848493          	addi	s1,s1,360
    800022a4:	ff3491e3          	bne	s1,s3,80002286 <kill+0x20>
  }
  return -1;
    800022a8:	557d                	li	a0,-1
    800022aa:	a829                	j	800022c4 <kill+0x5e>
      p->killed = 1;
    800022ac:	4785                	li	a5,1
    800022ae:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022b0:	4c98                	lw	a4,24(s1)
    800022b2:	4789                	li	a5,2
    800022b4:	00f70f63          	beq	a4,a5,800022d2 <kill+0x6c>
      release(&p->lock);
    800022b8:	8526                	mv	a0,s1
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	9d0080e7          	jalr	-1584(ra) # 80000c8a <release>
      return 0;
    800022c2:	4501                	li	a0,0
}
    800022c4:	70a2                	ld	ra,40(sp)
    800022c6:	7402                	ld	s0,32(sp)
    800022c8:	64e2                	ld	s1,24(sp)
    800022ca:	6942                	ld	s2,16(sp)
    800022cc:	69a2                	ld	s3,8(sp)
    800022ce:	6145                	addi	sp,sp,48
    800022d0:	8082                	ret
        p->state = RUNNABLE;
    800022d2:	478d                	li	a5,3
    800022d4:	cc9c                	sw	a5,24(s1)
    800022d6:	b7cd                	j	800022b8 <kill+0x52>

00000000800022d8 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	1000                	addi	s0,sp,32
    800022e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	8f2080e7          	jalr	-1806(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022ec:	4785                	li	a5,1
    800022ee:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	998080e7          	jalr	-1640(ra) # 80000c8a <release>
}
    800022fa:	60e2                	ld	ra,24(sp)
    800022fc:	6442                	ld	s0,16(sp)
    800022fe:	64a2                	ld	s1,8(sp)
    80002300:	6105                	addi	sp,sp,32
    80002302:	8082                	ret

0000000080002304 <killed>:

int
killed(struct proc *p)
{
    80002304:	1101                	addi	sp,sp,-32
    80002306:	ec06                	sd	ra,24(sp)
    80002308:	e822                	sd	s0,16(sp)
    8000230a:	e426                	sd	s1,8(sp)
    8000230c:	e04a                	sd	s2,0(sp)
    8000230e:	1000                	addi	s0,sp,32
    80002310:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	8c4080e7          	jalr	-1852(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000231a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	96a080e7          	jalr	-1686(ra) # 80000c8a <release>
  return k;
}
    80002328:	854a                	mv	a0,s2
    8000232a:	60e2                	ld	ra,24(sp)
    8000232c:	6442                	ld	s0,16(sp)
    8000232e:	64a2                	ld	s1,8(sp)
    80002330:	6902                	ld	s2,0(sp)
    80002332:	6105                	addi	sp,sp,32
    80002334:	8082                	ret

0000000080002336 <wait>:
{
    80002336:	715d                	addi	sp,sp,-80
    80002338:	e486                	sd	ra,72(sp)
    8000233a:	e0a2                	sd	s0,64(sp)
    8000233c:	fc26                	sd	s1,56(sp)
    8000233e:	f84a                	sd	s2,48(sp)
    80002340:	f44e                	sd	s3,40(sp)
    80002342:	f052                	sd	s4,32(sp)
    80002344:	ec56                	sd	s5,24(sp)
    80002346:	e85a                	sd	s6,16(sp)
    80002348:	e45e                	sd	s7,8(sp)
    8000234a:	e062                	sd	s8,0(sp)
    8000234c:	0880                	addi	s0,sp,80
    8000234e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	664080e7          	jalr	1636(ra) # 800019b4 <myproc>
    80002358:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000235a:	0000f517          	auipc	a0,0xf
    8000235e:	82e50513          	addi	a0,a0,-2002 # 80010b88 <wait_lock>
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	874080e7          	jalr	-1932(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000236a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000236c:	4a15                	li	s4,5
        havekids = 1;
    8000236e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002370:	00014997          	auipc	s3,0x14
    80002374:	63098993          	addi	s3,s3,1584 # 800169a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002378:	0000fc17          	auipc	s8,0xf
    8000237c:	810c0c13          	addi	s8,s8,-2032 # 80010b88 <wait_lock>
    havekids = 0;
    80002380:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002382:	0000f497          	auipc	s1,0xf
    80002386:	c1e48493          	addi	s1,s1,-994 # 80010fa0 <proc>
    8000238a:	a0bd                	j	800023f8 <wait+0xc2>
          pid = pp->pid;
    8000238c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002390:	000b0e63          	beqz	s6,800023ac <wait+0x76>
    80002394:	4691                	li	a3,4
    80002396:	02c48613          	addi	a2,s1,44
    8000239a:	85da                	mv	a1,s6
    8000239c:	05093503          	ld	a0,80(s2)
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	2cc080e7          	jalr	716(ra) # 8000166c <copyout>
    800023a8:	02054563          	bltz	a0,800023d2 <wait+0x9c>
          freeproc(pp);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	7b8080e7          	jalr	1976(ra) # 80001b66 <freeproc>
          release(&pp->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
          release(&wait_lock);
    800023c0:	0000e517          	auipc	a0,0xe
    800023c4:	7c850513          	addi	a0,a0,1992 # 80010b88 <wait_lock>
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	8c2080e7          	jalr	-1854(ra) # 80000c8a <release>
          return pid;
    800023d0:	a0b5                	j	8000243c <wait+0x106>
            release(&pp->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8b6080e7          	jalr	-1866(ra) # 80000c8a <release>
            release(&wait_lock);
    800023dc:	0000e517          	auipc	a0,0xe
    800023e0:	7ac50513          	addi	a0,a0,1964 # 80010b88 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a6080e7          	jalr	-1882(ra) # 80000c8a <release>
            return -1;
    800023ec:	59fd                	li	s3,-1
    800023ee:	a0b9                	j	8000243c <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f0:	16848493          	addi	s1,s1,360
    800023f4:	03348463          	beq	s1,s3,8000241c <wait+0xe6>
      if(pp->parent == p){
    800023f8:	7c9c                	ld	a5,56(s1)
    800023fa:	ff279be3          	bne	a5,s2,800023f0 <wait+0xba>
        acquire(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d6080e7          	jalr	2006(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	f94781e3          	beq	a5,s4,8000238c <wait+0x56>
        release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
        havekids = 1;
    80002418:	8756                	mv	a4,s5
    8000241a:	bfd9                	j	800023f0 <wait+0xba>
    if(!havekids || killed(p)){
    8000241c:	c719                	beqz	a4,8000242a <wait+0xf4>
    8000241e:	854a                	mv	a0,s2
    80002420:	00000097          	auipc	ra,0x0
    80002424:	ee4080e7          	jalr	-284(ra) # 80002304 <killed>
    80002428:	c51d                	beqz	a0,80002456 <wait+0x120>
      release(&wait_lock);
    8000242a:	0000e517          	auipc	a0,0xe
    8000242e:	75e50513          	addi	a0,a0,1886 # 80010b88 <wait_lock>
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      return -1;
    8000243a:	59fd                	li	s3,-1
}
    8000243c:	854e                	mv	a0,s3
    8000243e:	60a6                	ld	ra,72(sp)
    80002440:	6406                	ld	s0,64(sp)
    80002442:	74e2                	ld	s1,56(sp)
    80002444:	7942                	ld	s2,48(sp)
    80002446:	79a2                	ld	s3,40(sp)
    80002448:	7a02                	ld	s4,32(sp)
    8000244a:	6ae2                	ld	s5,24(sp)
    8000244c:	6b42                	ld	s6,16(sp)
    8000244e:	6ba2                	ld	s7,8(sp)
    80002450:	6c02                	ld	s8,0(sp)
    80002452:	6161                	addi	sp,sp,80
    80002454:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002456:	85e2                	mv	a1,s8
    80002458:	854a                	mv	a0,s2
    8000245a:	00000097          	auipc	ra,0x0
    8000245e:	c02080e7          	jalr	-1022(ra) # 8000205c <sleep>
    havekids = 0;
    80002462:	bf39                	j	80002380 <wait+0x4a>

0000000080002464 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002464:	7179                	addi	sp,sp,-48
    80002466:	f406                	sd	ra,40(sp)
    80002468:	f022                	sd	s0,32(sp)
    8000246a:	ec26                	sd	s1,24(sp)
    8000246c:	e84a                	sd	s2,16(sp)
    8000246e:	e44e                	sd	s3,8(sp)
    80002470:	e052                	sd	s4,0(sp)
    80002472:	1800                	addi	s0,sp,48
    80002474:	84aa                	mv	s1,a0
    80002476:	892e                	mv	s2,a1
    80002478:	89b2                	mv	s3,a2
    8000247a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	538080e7          	jalr	1336(ra) # 800019b4 <myproc>
  if(user_dst){
    80002484:	c08d                	beqz	s1,800024a6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002486:	86d2                	mv	a3,s4
    80002488:	864e                	mv	a2,s3
    8000248a:	85ca                	mv	a1,s2
    8000248c:	6928                	ld	a0,80(a0)
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	1de080e7          	jalr	478(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6a02                	ld	s4,0(sp)
    800024a2:	6145                	addi	sp,sp,48
    800024a4:	8082                	ret
    memmove((char *)dst, src, len);
    800024a6:	000a061b          	sext.w	a2,s4
    800024aa:	85ce                	mv	a1,s3
    800024ac:	854a                	mv	a0,s2
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	880080e7          	jalr	-1920(ra) # 80000d2e <memmove>
    return 0;
    800024b6:	8526                	mv	a0,s1
    800024b8:	bff9                	j	80002496 <either_copyout+0x32>

00000000800024ba <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ba:	7179                	addi	sp,sp,-48
    800024bc:	f406                	sd	ra,40(sp)
    800024be:	f022                	sd	s0,32(sp)
    800024c0:	ec26                	sd	s1,24(sp)
    800024c2:	e84a                	sd	s2,16(sp)
    800024c4:	e44e                	sd	s3,8(sp)
    800024c6:	e052                	sd	s4,0(sp)
    800024c8:	1800                	addi	s0,sp,48
    800024ca:	892a                	mv	s2,a0
    800024cc:	84ae                	mv	s1,a1
    800024ce:	89b2                	mv	s3,a2
    800024d0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	4e2080e7          	jalr	1250(ra) # 800019b4 <myproc>
  if(user_src){
    800024da:	c08d                	beqz	s1,800024fc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024dc:	86d2                	mv	a3,s4
    800024de:	864e                	mv	a2,s3
    800024e0:	85ca                	mv	a1,s2
    800024e2:	6928                	ld	a0,80(a0)
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	214080e7          	jalr	532(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ec:	70a2                	ld	ra,40(sp)
    800024ee:	7402                	ld	s0,32(sp)
    800024f0:	64e2                	ld	s1,24(sp)
    800024f2:	6942                	ld	s2,16(sp)
    800024f4:	69a2                	ld	s3,8(sp)
    800024f6:	6a02                	ld	s4,0(sp)
    800024f8:	6145                	addi	sp,sp,48
    800024fa:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fc:	000a061b          	sext.w	a2,s4
    80002500:	85ce                	mv	a1,s3
    80002502:	854a                	mv	a0,s2
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	82a080e7          	jalr	-2006(ra) # 80000d2e <memmove>
    return 0;
    8000250c:	8526                	mv	a0,s1
    8000250e:	bff9                	j	800024ec <either_copyin+0x32>

0000000080002510 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002510:	715d                	addi	sp,sp,-80
    80002512:	e486                	sd	ra,72(sp)
    80002514:	e0a2                	sd	s0,64(sp)
    80002516:	fc26                	sd	s1,56(sp)
    80002518:	f84a                	sd	s2,48(sp)
    8000251a:	f44e                	sd	s3,40(sp)
    8000251c:	f052                	sd	s4,32(sp)
    8000251e:	ec56                	sd	s5,24(sp)
    80002520:	e85a                	sd	s6,16(sp)
    80002522:	e45e                	sd	s7,8(sp)
    80002524:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002526:	00006517          	auipc	a0,0x6
    8000252a:	ba250513          	addi	a0,a0,-1118 # 800080c8 <digits+0x88>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	05c080e7          	jalr	92(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002536:	0000f497          	auipc	s1,0xf
    8000253a:	bc248493          	addi	s1,s1,-1086 # 800110f8 <proc+0x158>
    8000253e:	00014917          	auipc	s2,0x14
    80002542:	5ba90913          	addi	s2,s2,1466 # 80016af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002546:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002548:	00006997          	auipc	s3,0x6
    8000254c:	d3898993          	addi	s3,s3,-712 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002550:	00006a97          	auipc	s5,0x6
    80002554:	d38a8a93          	addi	s5,s5,-712 # 80008288 <digits+0x248>
    printf("\n");
    80002558:	00006a17          	auipc	s4,0x6
    8000255c:	b70a0a13          	addi	s4,s4,-1168 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002560:	00006b97          	auipc	s7,0x6
    80002564:	d68b8b93          	addi	s7,s7,-664 # 800082c8 <states.0>
    80002568:	a00d                	j	8000258a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000256a:	ed86a583          	lw	a1,-296(a3)
    8000256e:	8556                	mv	a0,s5
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	01a080e7          	jalr	26(ra) # 8000058a <printf>
    printf("\n");
    80002578:	8552                	mv	a0,s4
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	010080e7          	jalr	16(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002582:	16848493          	addi	s1,s1,360
    80002586:	03248263          	beq	s1,s2,800025aa <procdump+0x9a>
    if(p->state == UNUSED)
    8000258a:	86a6                	mv	a3,s1
    8000258c:	ec04a783          	lw	a5,-320(s1)
    80002590:	dbed                	beqz	a5,80002582 <procdump+0x72>
      state = "???";
    80002592:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	fcfb6be3          	bltu	s6,a5,8000256a <procdump+0x5a>
    80002598:	02079713          	slli	a4,a5,0x20
    8000259c:	01d75793          	srli	a5,a4,0x1d
    800025a0:	97de                	add	a5,a5,s7
    800025a2:	6390                	ld	a2,0(a5)
    800025a4:	f279                	bnez	a2,8000256a <procdump+0x5a>
      state = "???";
    800025a6:	864e                	mv	a2,s3
    800025a8:	b7c9                	j	8000256a <procdump+0x5a>
  }
}
    800025aa:	60a6                	ld	ra,72(sp)
    800025ac:	6406                	ld	s0,64(sp)
    800025ae:	74e2                	ld	s1,56(sp)
    800025b0:	7942                	ld	s2,48(sp)
    800025b2:	79a2                	ld	s3,40(sp)
    800025b4:	7a02                	ld	s4,32(sp)
    800025b6:	6ae2                	ld	s5,24(sp)
    800025b8:	6b42                	ld	s6,16(sp)
    800025ba:	6ba2                	ld	s7,8(sp)
    800025bc:	6161                	addi	sp,sp,80
    800025be:	8082                	ret

00000000800025c0 <swtch>:
    800025c0:	00153023          	sd	ra,0(a0)
    800025c4:	00253423          	sd	sp,8(a0)
    800025c8:	e900                	sd	s0,16(a0)
    800025ca:	ed04                	sd	s1,24(a0)
    800025cc:	03253023          	sd	s2,32(a0)
    800025d0:	03353423          	sd	s3,40(a0)
    800025d4:	03453823          	sd	s4,48(a0)
    800025d8:	03553c23          	sd	s5,56(a0)
    800025dc:	05653023          	sd	s6,64(a0)
    800025e0:	05753423          	sd	s7,72(a0)
    800025e4:	05853823          	sd	s8,80(a0)
    800025e8:	05953c23          	sd	s9,88(a0)
    800025ec:	07a53023          	sd	s10,96(a0)
    800025f0:	07b53423          	sd	s11,104(a0)
    800025f4:	0005b083          	ld	ra,0(a1)
    800025f8:	0085b103          	ld	sp,8(a1)
    800025fc:	6980                	ld	s0,16(a1)
    800025fe:	6d84                	ld	s1,24(a1)
    80002600:	0205b903          	ld	s2,32(a1)
    80002604:	0285b983          	ld	s3,40(a1)
    80002608:	0305ba03          	ld	s4,48(a1)
    8000260c:	0385ba83          	ld	s5,56(a1)
    80002610:	0405bb03          	ld	s6,64(a1)
    80002614:	0485bb83          	ld	s7,72(a1)
    80002618:	0505bc03          	ld	s8,80(a1)
    8000261c:	0585bc83          	ld	s9,88(a1)
    80002620:	0605bd03          	ld	s10,96(a1)
    80002624:	0685bd83          	ld	s11,104(a1)
    80002628:	8082                	ret

000000008000262a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000262a:	1141                	addi	sp,sp,-16
    8000262c:	e406                	sd	ra,8(sp)
    8000262e:	e022                	sd	s0,0(sp)
    80002630:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002632:	00006597          	auipc	a1,0x6
    80002636:	cc658593          	addi	a1,a1,-826 # 800082f8 <states.0+0x30>
    8000263a:	00014517          	auipc	a0,0x14
    8000263e:	36650513          	addi	a0,a0,870 # 800169a0 <tickslock>
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	504080e7          	jalr	1284(ra) # 80000b46 <initlock>
}
    8000264a:	60a2                	ld	ra,8(sp)
    8000264c:	6402                	ld	s0,0(sp)
    8000264e:	0141                	addi	sp,sp,16
    80002650:	8082                	ret

0000000080002652 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002652:	1141                	addi	sp,sp,-16
    80002654:	e422                	sd	s0,8(sp)
    80002656:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002658:	00003797          	auipc	a5,0x3
    8000265c:	57878793          	addi	a5,a5,1400 # 80005bd0 <kernelvec>
    80002660:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002664:	6422                	ld	s0,8(sp)
    80002666:	0141                	addi	sp,sp,16
    80002668:	8082                	ret

000000008000266a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000266a:	1141                	addi	sp,sp,-16
    8000266c:	e406                	sd	ra,8(sp)
    8000266e:	e022                	sd	s0,0(sp)
    80002670:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	342080e7          	jalr	834(ra) # 800019b4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002680:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002684:	00005697          	auipc	a3,0x5
    80002688:	97c68693          	addi	a3,a3,-1668 # 80007000 <_trampoline>
    8000268c:	00005717          	auipc	a4,0x5
    80002690:	97470713          	addi	a4,a4,-1676 # 80007000 <_trampoline>
    80002694:	8f15                	sub	a4,a4,a3
    80002696:	040007b7          	lui	a5,0x4000
    8000269a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000269c:	07b2                	slli	a5,a5,0xc
    8000269e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026a4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a6:	18002673          	csrr	a2,satp
    800026aa:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ac:	6d30                	ld	a2,88(a0)
    800026ae:	6138                	ld	a4,64(a0)
    800026b0:	6585                	lui	a1,0x1
    800026b2:	972e                	add	a4,a4,a1
    800026b4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026b6:	6d38                	ld	a4,88(a0)
    800026b8:	00000617          	auipc	a2,0x0
    800026bc:	13060613          	addi	a2,a2,304 # 800027e8 <usertrap>
    800026c0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c4:	8612                	mv	a2,tp
    800026c6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026cc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026da:	6f18                	ld	a4,24(a4)
    800026dc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e0:	6928                	ld	a0,80(a0)
    800026e2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026e4:	00005717          	auipc	a4,0x5
    800026e8:	9b870713          	addi	a4,a4,-1608 # 8000709c <userret>
    800026ec:	8f15                	sub	a4,a4,a3
    800026ee:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026f0:	577d                	li	a4,-1
    800026f2:	177e                	slli	a4,a4,0x3f
    800026f4:	8d59                	or	a0,a0,a4
    800026f6:	9782                	jalr	a5
}
    800026f8:	60a2                	ld	ra,8(sp)
    800026fa:	6402                	ld	s0,0(sp)
    800026fc:	0141                	addi	sp,sp,16
    800026fe:	8082                	ret

0000000080002700 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002700:	1101                	addi	sp,sp,-32
    80002702:	ec06                	sd	ra,24(sp)
    80002704:	e822                	sd	s0,16(sp)
    80002706:	e426                	sd	s1,8(sp)
    80002708:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000270a:	00014497          	auipc	s1,0x14
    8000270e:	29648493          	addi	s1,s1,662 # 800169a0 <tickslock>
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	4c2080e7          	jalr	1218(ra) # 80000bd6 <acquire>
  ticks++;
    8000271c:	00006517          	auipc	a0,0x6
    80002720:	1e450513          	addi	a0,a0,484 # 80008900 <ticks>
    80002724:	411c                	lw	a5,0(a0)
    80002726:	2785                	addiw	a5,a5,1
    80002728:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	996080e7          	jalr	-1642(ra) # 800020c0 <wakeup>
  release(&tickslock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	556080e7          	jalr	1366(ra) # 80000c8a <release>
}
    8000273c:	60e2                	ld	ra,24(sp)
    8000273e:	6442                	ld	s0,16(sp)
    80002740:	64a2                	ld	s1,8(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret

0000000080002746 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002746:	1101                	addi	sp,sp,-32
    80002748:	ec06                	sd	ra,24(sp)
    8000274a:	e822                	sd	s0,16(sp)
    8000274c:	e426                	sd	s1,8(sp)
    8000274e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002750:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002754:	00074d63          	bltz	a4,8000276e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002758:	57fd                	li	a5,-1
    8000275a:	17fe                	slli	a5,a5,0x3f
    8000275c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000275e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002760:	06f70363          	beq	a4,a5,800027c6 <devintr+0x80>
  }
}
    80002764:	60e2                	ld	ra,24(sp)
    80002766:	6442                	ld	s0,16(sp)
    80002768:	64a2                	ld	s1,8(sp)
    8000276a:	6105                	addi	sp,sp,32
    8000276c:	8082                	ret
     (scause & 0xff) == 9){
    8000276e:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002772:	46a5                	li	a3,9
    80002774:	fed792e3          	bne	a5,a3,80002758 <devintr+0x12>
    int irq = plic_claim();
    80002778:	00003097          	auipc	ra,0x3
    8000277c:	560080e7          	jalr	1376(ra) # 80005cd8 <plic_claim>
    80002780:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002782:	47a9                	li	a5,10
    80002784:	02f50763          	beq	a0,a5,800027b2 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002788:	4785                	li	a5,1
    8000278a:	02f50963          	beq	a0,a5,800027bc <devintr+0x76>
    return 1;
    8000278e:	4505                	li	a0,1
    } else if(irq){
    80002790:	d8f1                	beqz	s1,80002764 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002792:	85a6                	mv	a1,s1
    80002794:	00006517          	auipc	a0,0x6
    80002798:	b6c50513          	addi	a0,a0,-1172 # 80008300 <states.0+0x38>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	dee080e7          	jalr	-530(ra) # 8000058a <printf>
      plic_complete(irq);
    800027a4:	8526                	mv	a0,s1
    800027a6:	00003097          	auipc	ra,0x3
    800027aa:	556080e7          	jalr	1366(ra) # 80005cfc <plic_complete>
    return 1;
    800027ae:	4505                	li	a0,1
    800027b0:	bf55                	j	80002764 <devintr+0x1e>
      uartintr();
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	1e6080e7          	jalr	486(ra) # 80000998 <uartintr>
    800027ba:	b7ed                	j	800027a4 <devintr+0x5e>
      virtio_disk_intr();
    800027bc:	00004097          	auipc	ra,0x4
    800027c0:	a08080e7          	jalr	-1528(ra) # 800061c4 <virtio_disk_intr>
    800027c4:	b7c5                	j	800027a4 <devintr+0x5e>
    if(cpuid() == 0){
    800027c6:	fffff097          	auipc	ra,0xfffff
    800027ca:	1c2080e7          	jalr	450(ra) # 80001988 <cpuid>
    800027ce:	c901                	beqz	a0,800027de <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027d0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027d6:	14479073          	csrw	sip,a5
    return 2;
    800027da:	4509                	li	a0,2
    800027dc:	b761                	j	80002764 <devintr+0x1e>
      clockintr();
    800027de:	00000097          	auipc	ra,0x0
    800027e2:	f22080e7          	jalr	-222(ra) # 80002700 <clockintr>
    800027e6:	b7ed                	j	800027d0 <devintr+0x8a>

00000000800027e8 <usertrap>:
{
    800027e8:	1101                	addi	sp,sp,-32
    800027ea:	ec06                	sd	ra,24(sp)
    800027ec:	e822                	sd	s0,16(sp)
    800027ee:	e426                	sd	s1,8(sp)
    800027f0:	e04a                	sd	s2,0(sp)
    800027f2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027f8:	1007f793          	andi	a5,a5,256
    800027fc:	e3b1                	bnez	a5,80002840 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027fe:	00003797          	auipc	a5,0x3
    80002802:	3d278793          	addi	a5,a5,978 # 80005bd0 <kernelvec>
    80002806:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	1aa080e7          	jalr	426(ra) # 800019b4 <myproc>
    80002812:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002814:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002816:	14102773          	csrr	a4,sepc
    8000281a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002820:	47a1                	li	a5,8
    80002822:	02f70763          	beq	a4,a5,80002850 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002826:	00000097          	auipc	ra,0x0
    8000282a:	f20080e7          	jalr	-224(ra) # 80002746 <devintr>
    8000282e:	892a                	mv	s2,a0
    80002830:	c151                	beqz	a0,800028b4 <usertrap+0xcc>
  if(killed(p))
    80002832:	8526                	mv	a0,s1
    80002834:	00000097          	auipc	ra,0x0
    80002838:	ad0080e7          	jalr	-1328(ra) # 80002304 <killed>
    8000283c:	c929                	beqz	a0,8000288e <usertrap+0xa6>
    8000283e:	a099                	j	80002884 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002840:	00006517          	auipc	a0,0x6
    80002844:	ae050513          	addi	a0,a0,-1312 # 80008320 <states.0+0x58>
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	cf8080e7          	jalr	-776(ra) # 80000540 <panic>
    if(killed(p))
    80002850:	00000097          	auipc	ra,0x0
    80002854:	ab4080e7          	jalr	-1356(ra) # 80002304 <killed>
    80002858:	e921                	bnez	a0,800028a8 <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000285a:	6cb8                	ld	a4,88(s1)
    8000285c:	6f1c                	ld	a5,24(a4)
    8000285e:	0791                	addi	a5,a5,4
    80002860:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002862:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002866:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000286a:	10079073          	csrw	sstatus,a5
    syscall();
    8000286e:	00000097          	auipc	ra,0x0
    80002872:	2d4080e7          	jalr	724(ra) # 80002b42 <syscall>
  if(killed(p))
    80002876:	8526                	mv	a0,s1
    80002878:	00000097          	auipc	ra,0x0
    8000287c:	a8c080e7          	jalr	-1396(ra) # 80002304 <killed>
    80002880:	c911                	beqz	a0,80002894 <usertrap+0xac>
    80002882:	4901                	li	s2,0
    exit(-1);
    80002884:	557d                	li	a0,-1
    80002886:	00000097          	auipc	ra,0x0
    8000288a:	90a080e7          	jalr	-1782(ra) # 80002190 <exit>
  if(which_dev == 2)
    8000288e:	4789                	li	a5,2
    80002890:	04f90f63          	beq	s2,a5,800028ee <usertrap+0x106>
  usertrapret();
    80002894:	00000097          	auipc	ra,0x0
    80002898:	dd6080e7          	jalr	-554(ra) # 8000266a <usertrapret>
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6902                	ld	s2,0(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret
      exit(-1);
    800028a8:	557d                	li	a0,-1
    800028aa:	00000097          	auipc	ra,0x0
    800028ae:	8e6080e7          	jalr	-1818(ra) # 80002190 <exit>
    800028b2:	b765                	j	8000285a <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b8:	5890                	lw	a2,48(s1)
    800028ba:	00006517          	auipc	a0,0x6
    800028be:	a8650513          	addi	a0,a0,-1402 # 80008340 <states.0+0x78>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	cc8080e7          	jalr	-824(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ce:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d2:	00006517          	auipc	a0,0x6
    800028d6:	a9e50513          	addi	a0,a0,-1378 # 80008370 <states.0+0xa8>
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	cb0080e7          	jalr	-848(ra) # 8000058a <printf>
    setkilled(p);
    800028e2:	8526                	mv	a0,s1
    800028e4:	00000097          	auipc	ra,0x0
    800028e8:	9f4080e7          	jalr	-1548(ra) # 800022d8 <setkilled>
    800028ec:	b769                	j	80002876 <usertrap+0x8e>
    yield();
    800028ee:	fffff097          	auipc	ra,0xfffff
    800028f2:	732080e7          	jalr	1842(ra) # 80002020 <yield>
    800028f6:	bf79                	j	80002894 <usertrap+0xac>

00000000800028f8 <kerneltrap>:
{
    800028f8:	7179                	addi	sp,sp,-48
    800028fa:	f406                	sd	ra,40(sp)
    800028fc:	f022                	sd	s0,32(sp)
    800028fe:	ec26                	sd	s1,24(sp)
    80002900:	e84a                	sd	s2,16(sp)
    80002902:	e44e                	sd	s3,8(sp)
    80002904:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002906:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002912:	1004f793          	andi	a5,s1,256
    80002916:	cb85                	beqz	a5,80002946 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002918:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000291c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000291e:	ef85                	bnez	a5,80002956 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002920:	00000097          	auipc	ra,0x0
    80002924:	e26080e7          	jalr	-474(ra) # 80002746 <devintr>
    80002928:	cd1d                	beqz	a0,80002966 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292a:	4789                	li	a5,2
    8000292c:	06f50a63          	beq	a0,a5,800029a0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002930:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002934:	10049073          	csrw	sstatus,s1
}
    80002938:	70a2                	ld	ra,40(sp)
    8000293a:	7402                	ld	s0,32(sp)
    8000293c:	64e2                	ld	s1,24(sp)
    8000293e:	6942                	ld	s2,16(sp)
    80002940:	69a2                	ld	s3,8(sp)
    80002942:	6145                	addi	sp,sp,48
    80002944:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	a4a50513          	addi	a0,a0,-1462 # 80008390 <states.0+0xc8>
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	bf2080e7          	jalr	-1038(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002956:	00006517          	auipc	a0,0x6
    8000295a:	a6250513          	addi	a0,a0,-1438 # 800083b8 <states.0+0xf0>
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	be2080e7          	jalr	-1054(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002966:	85ce                	mv	a1,s3
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	a7050513          	addi	a0,a0,-1424 # 800083d8 <states.0+0x110>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	c1a080e7          	jalr	-998(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002978:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002980:	00006517          	auipc	a0,0x6
    80002984:	a6850513          	addi	a0,a0,-1432 # 800083e8 <states.0+0x120>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	c02080e7          	jalr	-1022(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002990:	00006517          	auipc	a0,0x6
    80002994:	a7050513          	addi	a0,a0,-1424 # 80008400 <states.0+0x138>
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	ba8080e7          	jalr	-1112(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	014080e7          	jalr	20(ra) # 800019b4 <myproc>
    800029a8:	d541                	beqz	a0,80002930 <kerneltrap+0x38>
    800029aa:	fffff097          	auipc	ra,0xfffff
    800029ae:	00a080e7          	jalr	10(ra) # 800019b4 <myproc>
    800029b2:	4d18                	lw	a4,24(a0)
    800029b4:	4791                	li	a5,4
    800029b6:	f6f71de3          	bne	a4,a5,80002930 <kerneltrap+0x38>
    yield();
    800029ba:	fffff097          	auipc	ra,0xfffff
    800029be:	666080e7          	jalr	1638(ra) # 80002020 <yield>
    800029c2:	b7bd                	j	80002930 <kerneltrap+0x38>

00000000800029c4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c4:	1101                	addi	sp,sp,-32
    800029c6:	ec06                	sd	ra,24(sp)
    800029c8:	e822                	sd	s0,16(sp)
    800029ca:	e426                	sd	s1,8(sp)
    800029cc:	1000                	addi	s0,sp,32
    800029ce:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d0:	fffff097          	auipc	ra,0xfffff
    800029d4:	fe4080e7          	jalr	-28(ra) # 800019b4 <myproc>
  switch (n) {
    800029d8:	4795                	li	a5,5
    800029da:	0497e163          	bltu	a5,s1,80002a1c <argraw+0x58>
    800029de:	048a                	slli	s1,s1,0x2
    800029e0:	00006717          	auipc	a4,0x6
    800029e4:	a5870713          	addi	a4,a4,-1448 # 80008438 <states.0+0x170>
    800029e8:	94ba                	add	s1,s1,a4
    800029ea:	409c                	lw	a5,0(s1)
    800029ec:	97ba                	add	a5,a5,a4
    800029ee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f0:	6d3c                	ld	a5,88(a0)
    800029f2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f4:	60e2                	ld	ra,24(sp)
    800029f6:	6442                	ld	s0,16(sp)
    800029f8:	64a2                	ld	s1,8(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret
    return p->trapframe->a1;
    800029fe:	6d3c                	ld	a5,88(a0)
    80002a00:	7fa8                	ld	a0,120(a5)
    80002a02:	bfcd                	j	800029f4 <argraw+0x30>
    return p->trapframe->a2;
    80002a04:	6d3c                	ld	a5,88(a0)
    80002a06:	63c8                	ld	a0,128(a5)
    80002a08:	b7f5                	j	800029f4 <argraw+0x30>
    return p->trapframe->a3;
    80002a0a:	6d3c                	ld	a5,88(a0)
    80002a0c:	67c8                	ld	a0,136(a5)
    80002a0e:	b7dd                	j	800029f4 <argraw+0x30>
    return p->trapframe->a4;
    80002a10:	6d3c                	ld	a5,88(a0)
    80002a12:	6bc8                	ld	a0,144(a5)
    80002a14:	b7c5                	j	800029f4 <argraw+0x30>
    return p->trapframe->a5;
    80002a16:	6d3c                	ld	a5,88(a0)
    80002a18:	6fc8                	ld	a0,152(a5)
    80002a1a:	bfe9                	j	800029f4 <argraw+0x30>
  panic("argraw");
    80002a1c:	00006517          	auipc	a0,0x6
    80002a20:	9f450513          	addi	a0,a0,-1548 # 80008410 <states.0+0x148>
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	b1c080e7          	jalr	-1252(ra) # 80000540 <panic>

0000000080002a2c <fetchaddr>:
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	e04a                	sd	s2,0(sp)
    80002a36:	1000                	addi	s0,sp,32
    80002a38:	84aa                	mv	s1,a0
    80002a3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	f78080e7          	jalr	-136(ra) # 800019b4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a44:	653c                	ld	a5,72(a0)
    80002a46:	02f4f863          	bgeu	s1,a5,80002a76 <fetchaddr+0x4a>
    80002a4a:	00848713          	addi	a4,s1,8
    80002a4e:	02e7e663          	bltu	a5,a4,80002a7a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a52:	46a1                	li	a3,8
    80002a54:	8626                	mv	a2,s1
    80002a56:	85ca                	mv	a1,s2
    80002a58:	6928                	ld	a0,80(a0)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	c9e080e7          	jalr	-866(ra) # 800016f8 <copyin>
    80002a62:	00a03533          	snez	a0,a0
    80002a66:	40a00533          	neg	a0,a0
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6902                	ld	s2,0(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret
    return -1;
    80002a76:	557d                	li	a0,-1
    80002a78:	bfcd                	j	80002a6a <fetchaddr+0x3e>
    80002a7a:	557d                	li	a0,-1
    80002a7c:	b7fd                	j	80002a6a <fetchaddr+0x3e>

0000000080002a7e <fetchstr>:
{
    80002a7e:	7179                	addi	sp,sp,-48
    80002a80:	f406                	sd	ra,40(sp)
    80002a82:	f022                	sd	s0,32(sp)
    80002a84:	ec26                	sd	s1,24(sp)
    80002a86:	e84a                	sd	s2,16(sp)
    80002a88:	e44e                	sd	s3,8(sp)
    80002a8a:	1800                	addi	s0,sp,48
    80002a8c:	892a                	mv	s2,a0
    80002a8e:	84ae                	mv	s1,a1
    80002a90:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	f22080e7          	jalr	-222(ra) # 800019b4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a9a:	86ce                	mv	a3,s3
    80002a9c:	864a                	mv	a2,s2
    80002a9e:	85a6                	mv	a1,s1
    80002aa0:	6928                	ld	a0,80(a0)
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	ce4080e7          	jalr	-796(ra) # 80001786 <copyinstr>
    80002aaa:	00054e63          	bltz	a0,80002ac6 <fetchstr+0x48>
  return strlen(buf);
    80002aae:	8526                	mv	a0,s1
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	39e080e7          	jalr	926(ra) # 80000e4e <strlen>
}
    80002ab8:	70a2                	ld	ra,40(sp)
    80002aba:	7402                	ld	s0,32(sp)
    80002abc:	64e2                	ld	s1,24(sp)
    80002abe:	6942                	ld	s2,16(sp)
    80002ac0:	69a2                	ld	s3,8(sp)
    80002ac2:	6145                	addi	sp,sp,48
    80002ac4:	8082                	ret
    return -1;
    80002ac6:	557d                	li	a0,-1
    80002ac8:	bfc5                	j	80002ab8 <fetchstr+0x3a>

0000000080002aca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	1000                	addi	s0,sp,32
    80002ad4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	eee080e7          	jalr	-274(ra) # 800029c4 <argraw>
    80002ade:	c088                	sw	a0,0(s1)
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret

0000000080002aea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002aea:	1101                	addi	sp,sp,-32
    80002aec:	ec06                	sd	ra,24(sp)
    80002aee:	e822                	sd	s0,16(sp)
    80002af0:	e426                	sd	s1,8(sp)
    80002af2:	1000                	addi	s0,sp,32
    80002af4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af6:	00000097          	auipc	ra,0x0
    80002afa:	ece080e7          	jalr	-306(ra) # 800029c4 <argraw>
    80002afe:	e088                	sd	a0,0(s1)
}
    80002b00:	60e2                	ld	ra,24(sp)
    80002b02:	6442                	ld	s0,16(sp)
    80002b04:	64a2                	ld	s1,8(sp)
    80002b06:	6105                	addi	sp,sp,32
    80002b08:	8082                	ret

0000000080002b0a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b0a:	7179                	addi	sp,sp,-48
    80002b0c:	f406                	sd	ra,40(sp)
    80002b0e:	f022                	sd	s0,32(sp)
    80002b10:	ec26                	sd	s1,24(sp)
    80002b12:	e84a                	sd	s2,16(sp)
    80002b14:	1800                	addi	s0,sp,48
    80002b16:	84ae                	mv	s1,a1
    80002b18:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b1a:	fd840593          	addi	a1,s0,-40
    80002b1e:	00000097          	auipc	ra,0x0
    80002b22:	fcc080e7          	jalr	-52(ra) # 80002aea <argaddr>
  return fetchstr(addr, buf, max);
    80002b26:	864a                	mv	a2,s2
    80002b28:	85a6                	mv	a1,s1
    80002b2a:	fd843503          	ld	a0,-40(s0)
    80002b2e:	00000097          	auipc	ra,0x0
    80002b32:	f50080e7          	jalr	-176(ra) # 80002a7e <fetchstr>
}
    80002b36:	70a2                	ld	ra,40(sp)
    80002b38:	7402                	ld	s0,32(sp)
    80002b3a:	64e2                	ld	s1,24(sp)
    80002b3c:	6942                	ld	s2,16(sp)
    80002b3e:	6145                	addi	sp,sp,48
    80002b40:	8082                	ret

0000000080002b42 <syscall>:
[SYS_peterson_destroy] sys_peterson_destroy,
};

void
syscall(void)
{
    80002b42:	1101                	addi	sp,sp,-32
    80002b44:	ec06                	sd	ra,24(sp)
    80002b46:	e822                	sd	s0,16(sp)
    80002b48:	e426                	sd	s1,8(sp)
    80002b4a:	e04a                	sd	s2,0(sp)
    80002b4c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	e66080e7          	jalr	-410(ra) # 800019b4 <myproc>
    80002b56:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b58:	05853903          	ld	s2,88(a0)
    80002b5c:	0a893783          	ld	a5,168(s2)
    80002b60:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b64:	37fd                	addiw	a5,a5,-1
    80002b66:	4761                	li	a4,24
    80002b68:	00f76f63          	bltu	a4,a5,80002b86 <syscall+0x44>
    80002b6c:	00369713          	slli	a4,a3,0x3
    80002b70:	00006797          	auipc	a5,0x6
    80002b74:	8e078793          	addi	a5,a5,-1824 # 80008450 <syscalls>
    80002b78:	97ba                	add	a5,a5,a4
    80002b7a:	639c                	ld	a5,0(a5)
    80002b7c:	c789                	beqz	a5,80002b86 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b7e:	9782                	jalr	a5
    80002b80:	06a93823          	sd	a0,112(s2)
    80002b84:	a839                	j	80002ba2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b86:	15848613          	addi	a2,s1,344
    80002b8a:	588c                	lw	a1,48(s1)
    80002b8c:	00006517          	auipc	a0,0x6
    80002b90:	88c50513          	addi	a0,a0,-1908 # 80008418 <states.0+0x150>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	9f6080e7          	jalr	-1546(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9c:	6cbc                	ld	a5,88(s1)
    80002b9e:	577d                	li	a4,-1
    80002ba0:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba2:	60e2                	ld	ra,24(sp)
    80002ba4:	6442                	ld	s0,16(sp)
    80002ba6:	64a2                	ld	s1,8(sp)
    80002ba8:	6902                	ld	s2,0(sp)
    80002baa:	6105                	addi	sp,sp,32
    80002bac:	8082                	ret

0000000080002bae <sys_exit>:
#include "petersonlock.h"


uint64
sys_exit(void)
{
    80002bae:	1101                	addi	sp,sp,-32
    80002bb0:	ec06                	sd	ra,24(sp)
    80002bb2:	e822                	sd	s0,16(sp)
    80002bb4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bb6:	fec40593          	addi	a1,s0,-20
    80002bba:	4501                	li	a0,0
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	f0e080e7          	jalr	-242(ra) # 80002aca <argint>
  exit(n);
    80002bc4:	fec42503          	lw	a0,-20(s0)
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	5c8080e7          	jalr	1480(ra) # 80002190 <exit>
  return 0;  // not reached
}
    80002bd0:	4501                	li	a0,0
    80002bd2:	60e2                	ld	ra,24(sp)
    80002bd4:	6442                	ld	s0,16(sp)
    80002bd6:	6105                	addi	sp,sp,32
    80002bd8:	8082                	ret

0000000080002bda <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bda:	1141                	addi	sp,sp,-16
    80002bdc:	e406                	sd	ra,8(sp)
    80002bde:	e022                	sd	s0,0(sp)
    80002be0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	dd2080e7          	jalr	-558(ra) # 800019b4 <myproc>
}
    80002bea:	5908                	lw	a0,48(a0)
    80002bec:	60a2                	ld	ra,8(sp)
    80002bee:	6402                	ld	s0,0(sp)
    80002bf0:	0141                	addi	sp,sp,16
    80002bf2:	8082                	ret

0000000080002bf4 <sys_fork>:

uint64
sys_fork(void)
{
    80002bf4:	1141                	addi	sp,sp,-16
    80002bf6:	e406                	sd	ra,8(sp)
    80002bf8:	e022                	sd	s0,0(sp)
    80002bfa:	0800                	addi	s0,sp,16
  return fork();
    80002bfc:	fffff097          	auipc	ra,0xfffff
    80002c00:	16e080e7          	jalr	366(ra) # 80001d6a <fork>
}
    80002c04:	60a2                	ld	ra,8(sp)
    80002c06:	6402                	ld	s0,0(sp)
    80002c08:	0141                	addi	sp,sp,16
    80002c0a:	8082                	ret

0000000080002c0c <sys_wait>:

uint64
sys_wait(void)
{
    80002c0c:	1101                	addi	sp,sp,-32
    80002c0e:	ec06                	sd	ra,24(sp)
    80002c10:	e822                	sd	s0,16(sp)
    80002c12:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c14:	fe840593          	addi	a1,s0,-24
    80002c18:	4501                	li	a0,0
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	ed0080e7          	jalr	-304(ra) # 80002aea <argaddr>
  return wait(p);
    80002c22:	fe843503          	ld	a0,-24(s0)
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	710080e7          	jalr	1808(ra) # 80002336 <wait>
}
    80002c2e:	60e2                	ld	ra,24(sp)
    80002c30:	6442                	ld	s0,16(sp)
    80002c32:	6105                	addi	sp,sp,32
    80002c34:	8082                	ret

0000000080002c36 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c36:	7179                	addi	sp,sp,-48
    80002c38:	f406                	sd	ra,40(sp)
    80002c3a:	f022                	sd	s0,32(sp)
    80002c3c:	ec26                	sd	s1,24(sp)
    80002c3e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c40:	fdc40593          	addi	a1,s0,-36
    80002c44:	4501                	li	a0,0
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	e84080e7          	jalr	-380(ra) # 80002aca <argint>
  addr = myproc()->sz;
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	d66080e7          	jalr	-666(ra) # 800019b4 <myproc>
    80002c56:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c58:	fdc42503          	lw	a0,-36(s0)
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	0b2080e7          	jalr	178(ra) # 80001d0e <growproc>
    80002c64:	00054863          	bltz	a0,80002c74 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c68:	8526                	mv	a0,s1
    80002c6a:	70a2                	ld	ra,40(sp)
    80002c6c:	7402                	ld	s0,32(sp)
    80002c6e:	64e2                	ld	s1,24(sp)
    80002c70:	6145                	addi	sp,sp,48
    80002c72:	8082                	ret
    return -1;
    80002c74:	54fd                	li	s1,-1
    80002c76:	bfcd                	j	80002c68 <sys_sbrk+0x32>

0000000080002c78 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c78:	7139                	addi	sp,sp,-64
    80002c7a:	fc06                	sd	ra,56(sp)
    80002c7c:	f822                	sd	s0,48(sp)
    80002c7e:	f426                	sd	s1,40(sp)
    80002c80:	f04a                	sd	s2,32(sp)
    80002c82:	ec4e                	sd	s3,24(sp)
    80002c84:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c86:	fcc40593          	addi	a1,s0,-52
    80002c8a:	4501                	li	a0,0
    80002c8c:	00000097          	auipc	ra,0x0
    80002c90:	e3e080e7          	jalr	-450(ra) # 80002aca <argint>
  acquire(&tickslock);
    80002c94:	00014517          	auipc	a0,0x14
    80002c98:	d0c50513          	addi	a0,a0,-756 # 800169a0 <tickslock>
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	f3a080e7          	jalr	-198(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002ca4:	00006917          	auipc	s2,0x6
    80002ca8:	c5c92903          	lw	s2,-932(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002cac:	fcc42783          	lw	a5,-52(s0)
    80002cb0:	cf9d                	beqz	a5,80002cee <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb2:	00014997          	auipc	s3,0x14
    80002cb6:	cee98993          	addi	s3,s3,-786 # 800169a0 <tickslock>
    80002cba:	00006497          	auipc	s1,0x6
    80002cbe:	c4648493          	addi	s1,s1,-954 # 80008900 <ticks>
    if(killed(myproc())){
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	cf2080e7          	jalr	-782(ra) # 800019b4 <myproc>
    80002cca:	fffff097          	auipc	ra,0xfffff
    80002cce:	63a080e7          	jalr	1594(ra) # 80002304 <killed>
    80002cd2:	ed15                	bnez	a0,80002d0e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cd4:	85ce                	mv	a1,s3
    80002cd6:	8526                	mv	a0,s1
    80002cd8:	fffff097          	auipc	ra,0xfffff
    80002cdc:	384080e7          	jalr	900(ra) # 8000205c <sleep>
  while(ticks - ticks0 < n){
    80002ce0:	409c                	lw	a5,0(s1)
    80002ce2:	412787bb          	subw	a5,a5,s2
    80002ce6:	fcc42703          	lw	a4,-52(s0)
    80002cea:	fce7ece3          	bltu	a5,a4,80002cc2 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cee:	00014517          	auipc	a0,0x14
    80002cf2:	cb250513          	addi	a0,a0,-846 # 800169a0 <tickslock>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	f94080e7          	jalr	-108(ra) # 80000c8a <release>
  return 0;
    80002cfe:	4501                	li	a0,0
}
    80002d00:	70e2                	ld	ra,56(sp)
    80002d02:	7442                	ld	s0,48(sp)
    80002d04:	74a2                	ld	s1,40(sp)
    80002d06:	7902                	ld	s2,32(sp)
    80002d08:	69e2                	ld	s3,24(sp)
    80002d0a:	6121                	addi	sp,sp,64
    80002d0c:	8082                	ret
      release(&tickslock);
    80002d0e:	00014517          	auipc	a0,0x14
    80002d12:	c9250513          	addi	a0,a0,-878 # 800169a0 <tickslock>
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	f74080e7          	jalr	-140(ra) # 80000c8a <release>
      return -1;
    80002d1e:	557d                	li	a0,-1
    80002d20:	b7c5                	j	80002d00 <sys_sleep+0x88>

0000000080002d22 <sys_kill>:

uint64
sys_kill(void)
{
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d2a:	fec40593          	addi	a1,s0,-20
    80002d2e:	4501                	li	a0,0
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	d9a080e7          	jalr	-614(ra) # 80002aca <argint>
  return kill(pid);
    80002d38:	fec42503          	lw	a0,-20(s0)
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	52a080e7          	jalr	1322(ra) # 80002266 <kill>
}
    80002d44:	60e2                	ld	ra,24(sp)
    80002d46:	6442                	ld	s0,16(sp)
    80002d48:	6105                	addi	sp,sp,32
    80002d4a:	8082                	ret

0000000080002d4c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d4c:	1101                	addi	sp,sp,-32
    80002d4e:	ec06                	sd	ra,24(sp)
    80002d50:	e822                	sd	s0,16(sp)
    80002d52:	e426                	sd	s1,8(sp)
    80002d54:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d56:	00014517          	auipc	a0,0x14
    80002d5a:	c4a50513          	addi	a0,a0,-950 # 800169a0 <tickslock>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	e78080e7          	jalr	-392(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d66:	00006497          	auipc	s1,0x6
    80002d6a:	b9a4a483          	lw	s1,-1126(s1) # 80008900 <ticks>
  release(&tickslock);
    80002d6e:	00014517          	auipc	a0,0x14
    80002d72:	c3250513          	addi	a0,a0,-974 # 800169a0 <tickslock>
    80002d76:	ffffe097          	auipc	ra,0xffffe
    80002d7a:	f14080e7          	jalr	-236(ra) # 80000c8a <release>
  return xticks;
}
    80002d7e:	02049513          	slli	a0,s1,0x20
    80002d82:	9101                	srli	a0,a0,0x20
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <sys_peterson_create>:

// ------------------------------------------------------------
//task4:
uint64
sys_peterson_create(void)
{
    80002d8e:	1141                	addi	sp,sp,-16
    80002d90:	e406                	sd	ra,8(sp)
    80002d92:	e022                	sd	s0,0(sp)
    80002d94:	0800                	addi	s0,sp,16
    return petersonlock_create();
    80002d96:	00003097          	auipc	ra,0x3
    80002d9a:	508080e7          	jalr	1288(ra) # 8000629e <petersonlock_create>
}
    80002d9e:	60a2                	ld	ra,8(sp)
    80002da0:	6402                	ld	s0,0(sp)
    80002da2:	0141                	addi	sp,sp,16
    80002da4:	8082                	ret

0000000080002da6 <sys_peterson_acquire>:

uint64
sys_peterson_acquire(void)
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	1000                	addi	s0,sp,32
    int lock_id, role;
    argint(0, &lock_id);
    80002dae:	fec40593          	addi	a1,s0,-20
    80002db2:	4501                	li	a0,0
    80002db4:	00000097          	auipc	ra,0x0
    80002db8:	d16080e7          	jalr	-746(ra) # 80002aca <argint>
    argint(1, &role);
    80002dbc:	fe840593          	addi	a1,s0,-24
    80002dc0:	4505                	li	a0,1
    80002dc2:	00000097          	auipc	ra,0x0
    80002dc6:	d08080e7          	jalr	-760(ra) # 80002aca <argint>
    return petersonlock_acquire(lock_id, role);
    80002dca:	fe842583          	lw	a1,-24(s0)
    80002dce:	fec42503          	lw	a0,-20(s0)
    80002dd2:	00003097          	auipc	ra,0x3
    80002dd6:	512080e7          	jalr	1298(ra) # 800062e4 <petersonlock_acquire>
}
    80002dda:	60e2                	ld	ra,24(sp)
    80002ddc:	6442                	ld	s0,16(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <sys_peterson_release>:

uint64
sys_peterson_release(void)
{
    80002de2:	1101                	addi	sp,sp,-32
    80002de4:	ec06                	sd	ra,24(sp)
    80002de6:	e822                	sd	s0,16(sp)
    80002de8:	1000                	addi	s0,sp,32
    int lock_id, role;
    argint(0, &lock_id);
    80002dea:	fec40593          	addi	a1,s0,-20
    80002dee:	4501                	li	a0,0
    80002df0:	00000097          	auipc	ra,0x0
    80002df4:	cda080e7          	jalr	-806(ra) # 80002aca <argint>
    argint(1, &role);
    80002df8:	fe840593          	addi	a1,s0,-24
    80002dfc:	4505                	li	a0,1
    80002dfe:	00000097          	auipc	ra,0x0
    80002e02:	ccc080e7          	jalr	-820(ra) # 80002aca <argint>
    return petersonlock_release(lock_id, role);
    80002e06:	fe842583          	lw	a1,-24(s0)
    80002e0a:	fec42503          	lw	a0,-20(s0)
    80002e0e:	00003097          	auipc	ra,0x3
    80002e12:	568080e7          	jalr	1384(ra) # 80006376 <petersonlock_release>
}
    80002e16:	60e2                	ld	ra,24(sp)
    80002e18:	6442                	ld	s0,16(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret

0000000080002e1e <sys_peterson_destroy>:

uint64
sys_peterson_destroy(void)
{
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	1000                	addi	s0,sp,32
    int lock_id;
    argint(0, &lock_id);
    80002e26:	fec40593          	addi	a1,s0,-20
    80002e2a:	4501                	li	a0,0
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	c9e080e7          	jalr	-866(ra) # 80002aca <argint>
    return petersonlock_destroy(lock_id);
    80002e34:	fec42503          	lw	a0,-20(s0)
    80002e38:	00003097          	auipc	ra,0x3
    80002e3c:	59c080e7          	jalr	1436(ra) # 800063d4 <petersonlock_destroy>
}
    80002e40:	60e2                	ld	ra,24(sp)
    80002e42:	6442                	ld	s0,16(sp)
    80002e44:	6105                	addi	sp,sp,32
    80002e46:	8082                	ret

0000000080002e48 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e48:	7179                	addi	sp,sp,-48
    80002e4a:	f406                	sd	ra,40(sp)
    80002e4c:	f022                	sd	s0,32(sp)
    80002e4e:	ec26                	sd	s1,24(sp)
    80002e50:	e84a                	sd	s2,16(sp)
    80002e52:	e44e                	sd	s3,8(sp)
    80002e54:	e052                	sd	s4,0(sp)
    80002e56:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e58:	00005597          	auipc	a1,0x5
    80002e5c:	6c858593          	addi	a1,a1,1736 # 80008520 <syscalls+0xd0>
    80002e60:	00014517          	auipc	a0,0x14
    80002e64:	b5850513          	addi	a0,a0,-1192 # 800169b8 <bcache>
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	cde080e7          	jalr	-802(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e70:	0001c797          	auipc	a5,0x1c
    80002e74:	b4878793          	addi	a5,a5,-1208 # 8001e9b8 <bcache+0x8000>
    80002e78:	0001c717          	auipc	a4,0x1c
    80002e7c:	da870713          	addi	a4,a4,-600 # 8001ec20 <bcache+0x8268>
    80002e80:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e84:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e88:	00014497          	auipc	s1,0x14
    80002e8c:	b4848493          	addi	s1,s1,-1208 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e90:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e92:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e94:	00005a17          	auipc	s4,0x5
    80002e98:	694a0a13          	addi	s4,s4,1684 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002e9c:	2b893783          	ld	a5,696(s2)
    80002ea0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ea2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ea6:	85d2                	mv	a1,s4
    80002ea8:	01048513          	addi	a0,s1,16
    80002eac:	00001097          	auipc	ra,0x1
    80002eb0:	4c8080e7          	jalr	1224(ra) # 80004374 <initsleeplock>
    bcache.head.next->prev = b;
    80002eb4:	2b893783          	ld	a5,696(s2)
    80002eb8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eba:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ebe:	45848493          	addi	s1,s1,1112
    80002ec2:	fd349de3          	bne	s1,s3,80002e9c <binit+0x54>
  }
}
    80002ec6:	70a2                	ld	ra,40(sp)
    80002ec8:	7402                	ld	s0,32(sp)
    80002eca:	64e2                	ld	s1,24(sp)
    80002ecc:	6942                	ld	s2,16(sp)
    80002ece:	69a2                	ld	s3,8(sp)
    80002ed0:	6a02                	ld	s4,0(sp)
    80002ed2:	6145                	addi	sp,sp,48
    80002ed4:	8082                	ret

0000000080002ed6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ed6:	7179                	addi	sp,sp,-48
    80002ed8:	f406                	sd	ra,40(sp)
    80002eda:	f022                	sd	s0,32(sp)
    80002edc:	ec26                	sd	s1,24(sp)
    80002ede:	e84a                	sd	s2,16(sp)
    80002ee0:	e44e                	sd	s3,8(sp)
    80002ee2:	1800                	addi	s0,sp,48
    80002ee4:	892a                	mv	s2,a0
    80002ee6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ee8:	00014517          	auipc	a0,0x14
    80002eec:	ad050513          	addi	a0,a0,-1328 # 800169b8 <bcache>
    80002ef0:	ffffe097          	auipc	ra,0xffffe
    80002ef4:	ce6080e7          	jalr	-794(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ef8:	0001c497          	auipc	s1,0x1c
    80002efc:	d784b483          	ld	s1,-648(s1) # 8001ec70 <bcache+0x82b8>
    80002f00:	0001c797          	auipc	a5,0x1c
    80002f04:	d2078793          	addi	a5,a5,-736 # 8001ec20 <bcache+0x8268>
    80002f08:	02f48f63          	beq	s1,a5,80002f46 <bread+0x70>
    80002f0c:	873e                	mv	a4,a5
    80002f0e:	a021                	j	80002f16 <bread+0x40>
    80002f10:	68a4                	ld	s1,80(s1)
    80002f12:	02e48a63          	beq	s1,a4,80002f46 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f16:	449c                	lw	a5,8(s1)
    80002f18:	ff279ce3          	bne	a5,s2,80002f10 <bread+0x3a>
    80002f1c:	44dc                	lw	a5,12(s1)
    80002f1e:	ff3799e3          	bne	a5,s3,80002f10 <bread+0x3a>
      b->refcnt++;
    80002f22:	40bc                	lw	a5,64(s1)
    80002f24:	2785                	addiw	a5,a5,1
    80002f26:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f28:	00014517          	auipc	a0,0x14
    80002f2c:	a9050513          	addi	a0,a0,-1392 # 800169b8 <bcache>
    80002f30:	ffffe097          	auipc	ra,0xffffe
    80002f34:	d5a080e7          	jalr	-678(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f38:	01048513          	addi	a0,s1,16
    80002f3c:	00001097          	auipc	ra,0x1
    80002f40:	472080e7          	jalr	1138(ra) # 800043ae <acquiresleep>
      return b;
    80002f44:	a8b9                	j	80002fa2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f46:	0001c497          	auipc	s1,0x1c
    80002f4a:	d224b483          	ld	s1,-734(s1) # 8001ec68 <bcache+0x82b0>
    80002f4e:	0001c797          	auipc	a5,0x1c
    80002f52:	cd278793          	addi	a5,a5,-814 # 8001ec20 <bcache+0x8268>
    80002f56:	00f48863          	beq	s1,a5,80002f66 <bread+0x90>
    80002f5a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f5c:	40bc                	lw	a5,64(s1)
    80002f5e:	cf81                	beqz	a5,80002f76 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f60:	64a4                	ld	s1,72(s1)
    80002f62:	fee49de3          	bne	s1,a4,80002f5c <bread+0x86>
  panic("bget: no buffers");
    80002f66:	00005517          	auipc	a0,0x5
    80002f6a:	5ca50513          	addi	a0,a0,1482 # 80008530 <syscalls+0xe0>
    80002f6e:	ffffd097          	auipc	ra,0xffffd
    80002f72:	5d2080e7          	jalr	1490(ra) # 80000540 <panic>
      b->dev = dev;
    80002f76:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f7a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f7e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f82:	4785                	li	a5,1
    80002f84:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f86:	00014517          	auipc	a0,0x14
    80002f8a:	a3250513          	addi	a0,a0,-1486 # 800169b8 <bcache>
    80002f8e:	ffffe097          	auipc	ra,0xffffe
    80002f92:	cfc080e7          	jalr	-772(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f96:	01048513          	addi	a0,s1,16
    80002f9a:	00001097          	auipc	ra,0x1
    80002f9e:	414080e7          	jalr	1044(ra) # 800043ae <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fa2:	409c                	lw	a5,0(s1)
    80002fa4:	cb89                	beqz	a5,80002fb6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fa6:	8526                	mv	a0,s1
    80002fa8:	70a2                	ld	ra,40(sp)
    80002faa:	7402                	ld	s0,32(sp)
    80002fac:	64e2                	ld	s1,24(sp)
    80002fae:	6942                	ld	s2,16(sp)
    80002fb0:	69a2                	ld	s3,8(sp)
    80002fb2:	6145                	addi	sp,sp,48
    80002fb4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fb6:	4581                	li	a1,0
    80002fb8:	8526                	mv	a0,s1
    80002fba:	00003097          	auipc	ra,0x3
    80002fbe:	fd8080e7          	jalr	-40(ra) # 80005f92 <virtio_disk_rw>
    b->valid = 1;
    80002fc2:	4785                	li	a5,1
    80002fc4:	c09c                	sw	a5,0(s1)
  return b;
    80002fc6:	b7c5                	j	80002fa6 <bread+0xd0>

0000000080002fc8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fc8:	1101                	addi	sp,sp,-32
    80002fca:	ec06                	sd	ra,24(sp)
    80002fcc:	e822                	sd	s0,16(sp)
    80002fce:	e426                	sd	s1,8(sp)
    80002fd0:	1000                	addi	s0,sp,32
    80002fd2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fd4:	0541                	addi	a0,a0,16
    80002fd6:	00001097          	auipc	ra,0x1
    80002fda:	472080e7          	jalr	1138(ra) # 80004448 <holdingsleep>
    80002fde:	cd01                	beqz	a0,80002ff6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fe0:	4585                	li	a1,1
    80002fe2:	8526                	mv	a0,s1
    80002fe4:	00003097          	auipc	ra,0x3
    80002fe8:	fae080e7          	jalr	-82(ra) # 80005f92 <virtio_disk_rw>
}
    80002fec:	60e2                	ld	ra,24(sp)
    80002fee:	6442                	ld	s0,16(sp)
    80002ff0:	64a2                	ld	s1,8(sp)
    80002ff2:	6105                	addi	sp,sp,32
    80002ff4:	8082                	ret
    panic("bwrite");
    80002ff6:	00005517          	auipc	a0,0x5
    80002ffa:	55250513          	addi	a0,a0,1362 # 80008548 <syscalls+0xf8>
    80002ffe:	ffffd097          	auipc	ra,0xffffd
    80003002:	542080e7          	jalr	1346(ra) # 80000540 <panic>

0000000080003006 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003006:	1101                	addi	sp,sp,-32
    80003008:	ec06                	sd	ra,24(sp)
    8000300a:	e822                	sd	s0,16(sp)
    8000300c:	e426                	sd	s1,8(sp)
    8000300e:	e04a                	sd	s2,0(sp)
    80003010:	1000                	addi	s0,sp,32
    80003012:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003014:	01050913          	addi	s2,a0,16
    80003018:	854a                	mv	a0,s2
    8000301a:	00001097          	auipc	ra,0x1
    8000301e:	42e080e7          	jalr	1070(ra) # 80004448 <holdingsleep>
    80003022:	c92d                	beqz	a0,80003094 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003024:	854a                	mv	a0,s2
    80003026:	00001097          	auipc	ra,0x1
    8000302a:	3de080e7          	jalr	990(ra) # 80004404 <releasesleep>

  acquire(&bcache.lock);
    8000302e:	00014517          	auipc	a0,0x14
    80003032:	98a50513          	addi	a0,a0,-1654 # 800169b8 <bcache>
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	ba0080e7          	jalr	-1120(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000303e:	40bc                	lw	a5,64(s1)
    80003040:	37fd                	addiw	a5,a5,-1
    80003042:	0007871b          	sext.w	a4,a5
    80003046:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003048:	eb05                	bnez	a4,80003078 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000304a:	68bc                	ld	a5,80(s1)
    8000304c:	64b8                	ld	a4,72(s1)
    8000304e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003050:	64bc                	ld	a5,72(s1)
    80003052:	68b8                	ld	a4,80(s1)
    80003054:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003056:	0001c797          	auipc	a5,0x1c
    8000305a:	96278793          	addi	a5,a5,-1694 # 8001e9b8 <bcache+0x8000>
    8000305e:	2b87b703          	ld	a4,696(a5)
    80003062:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003064:	0001c717          	auipc	a4,0x1c
    80003068:	bbc70713          	addi	a4,a4,-1092 # 8001ec20 <bcache+0x8268>
    8000306c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000306e:	2b87b703          	ld	a4,696(a5)
    80003072:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003074:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003078:	00014517          	auipc	a0,0x14
    8000307c:	94050513          	addi	a0,a0,-1728 # 800169b8 <bcache>
    80003080:	ffffe097          	auipc	ra,0xffffe
    80003084:	c0a080e7          	jalr	-1014(ra) # 80000c8a <release>
}
    80003088:	60e2                	ld	ra,24(sp)
    8000308a:	6442                	ld	s0,16(sp)
    8000308c:	64a2                	ld	s1,8(sp)
    8000308e:	6902                	ld	s2,0(sp)
    80003090:	6105                	addi	sp,sp,32
    80003092:	8082                	ret
    panic("brelse");
    80003094:	00005517          	auipc	a0,0x5
    80003098:	4bc50513          	addi	a0,a0,1212 # 80008550 <syscalls+0x100>
    8000309c:	ffffd097          	auipc	ra,0xffffd
    800030a0:	4a4080e7          	jalr	1188(ra) # 80000540 <panic>

00000000800030a4 <bpin>:

void
bpin(struct buf *b) {
    800030a4:	1101                	addi	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	e426                	sd	s1,8(sp)
    800030ac:	1000                	addi	s0,sp,32
    800030ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b0:	00014517          	auipc	a0,0x14
    800030b4:	90850513          	addi	a0,a0,-1784 # 800169b8 <bcache>
    800030b8:	ffffe097          	auipc	ra,0xffffe
    800030bc:	b1e080e7          	jalr	-1250(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800030c0:	40bc                	lw	a5,64(s1)
    800030c2:	2785                	addiw	a5,a5,1
    800030c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c6:	00014517          	auipc	a0,0x14
    800030ca:	8f250513          	addi	a0,a0,-1806 # 800169b8 <bcache>
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	bbc080e7          	jalr	-1092(ra) # 80000c8a <release>
}
    800030d6:	60e2                	ld	ra,24(sp)
    800030d8:	6442                	ld	s0,16(sp)
    800030da:	64a2                	ld	s1,8(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret

00000000800030e0 <bunpin>:

void
bunpin(struct buf *b) {
    800030e0:	1101                	addi	sp,sp,-32
    800030e2:	ec06                	sd	ra,24(sp)
    800030e4:	e822                	sd	s0,16(sp)
    800030e6:	e426                	sd	s1,8(sp)
    800030e8:	1000                	addi	s0,sp,32
    800030ea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030ec:	00014517          	auipc	a0,0x14
    800030f0:	8cc50513          	addi	a0,a0,-1844 # 800169b8 <bcache>
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	ae2080e7          	jalr	-1310(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030fc:	40bc                	lw	a5,64(s1)
    800030fe:	37fd                	addiw	a5,a5,-1
    80003100:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003102:	00014517          	auipc	a0,0x14
    80003106:	8b650513          	addi	a0,a0,-1866 # 800169b8 <bcache>
    8000310a:	ffffe097          	auipc	ra,0xffffe
    8000310e:	b80080e7          	jalr	-1152(ra) # 80000c8a <release>
}
    80003112:	60e2                	ld	ra,24(sp)
    80003114:	6442                	ld	s0,16(sp)
    80003116:	64a2                	ld	s1,8(sp)
    80003118:	6105                	addi	sp,sp,32
    8000311a:	8082                	ret

000000008000311c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000311c:	1101                	addi	sp,sp,-32
    8000311e:	ec06                	sd	ra,24(sp)
    80003120:	e822                	sd	s0,16(sp)
    80003122:	e426                	sd	s1,8(sp)
    80003124:	e04a                	sd	s2,0(sp)
    80003126:	1000                	addi	s0,sp,32
    80003128:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000312a:	00d5d59b          	srliw	a1,a1,0xd
    8000312e:	0001c797          	auipc	a5,0x1c
    80003132:	f667a783          	lw	a5,-154(a5) # 8001f094 <sb+0x1c>
    80003136:	9dbd                	addw	a1,a1,a5
    80003138:	00000097          	auipc	ra,0x0
    8000313c:	d9e080e7          	jalr	-610(ra) # 80002ed6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003140:	0074f713          	andi	a4,s1,7
    80003144:	4785                	li	a5,1
    80003146:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000314a:	14ce                	slli	s1,s1,0x33
    8000314c:	90d9                	srli	s1,s1,0x36
    8000314e:	00950733          	add	a4,a0,s1
    80003152:	05874703          	lbu	a4,88(a4)
    80003156:	00e7f6b3          	and	a3,a5,a4
    8000315a:	c69d                	beqz	a3,80003188 <bfree+0x6c>
    8000315c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000315e:	94aa                	add	s1,s1,a0
    80003160:	fff7c793          	not	a5,a5
    80003164:	8f7d                	and	a4,a4,a5
    80003166:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000316a:	00001097          	auipc	ra,0x1
    8000316e:	126080e7          	jalr	294(ra) # 80004290 <log_write>
  brelse(bp);
    80003172:	854a                	mv	a0,s2
    80003174:	00000097          	auipc	ra,0x0
    80003178:	e92080e7          	jalr	-366(ra) # 80003006 <brelse>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6902                	ld	s2,0(sp)
    80003184:	6105                	addi	sp,sp,32
    80003186:	8082                	ret
    panic("freeing free block");
    80003188:	00005517          	auipc	a0,0x5
    8000318c:	3d050513          	addi	a0,a0,976 # 80008558 <syscalls+0x108>
    80003190:	ffffd097          	auipc	ra,0xffffd
    80003194:	3b0080e7          	jalr	944(ra) # 80000540 <panic>

0000000080003198 <balloc>:
{
    80003198:	711d                	addi	sp,sp,-96
    8000319a:	ec86                	sd	ra,88(sp)
    8000319c:	e8a2                	sd	s0,80(sp)
    8000319e:	e4a6                	sd	s1,72(sp)
    800031a0:	e0ca                	sd	s2,64(sp)
    800031a2:	fc4e                	sd	s3,56(sp)
    800031a4:	f852                	sd	s4,48(sp)
    800031a6:	f456                	sd	s5,40(sp)
    800031a8:	f05a                	sd	s6,32(sp)
    800031aa:	ec5e                	sd	s7,24(sp)
    800031ac:	e862                	sd	s8,16(sp)
    800031ae:	e466                	sd	s9,8(sp)
    800031b0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031b2:	0001c797          	auipc	a5,0x1c
    800031b6:	eca7a783          	lw	a5,-310(a5) # 8001f07c <sb+0x4>
    800031ba:	cff5                	beqz	a5,800032b6 <balloc+0x11e>
    800031bc:	8baa                	mv	s7,a0
    800031be:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031c0:	0001cb17          	auipc	s6,0x1c
    800031c4:	eb8b0b13          	addi	s6,s6,-328 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031ca:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031cc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ce:	6c89                	lui	s9,0x2
    800031d0:	a061                	j	80003258 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031d2:	97ca                	add	a5,a5,s2
    800031d4:	8e55                	or	a2,a2,a3
    800031d6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031da:	854a                	mv	a0,s2
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	0b4080e7          	jalr	180(ra) # 80004290 <log_write>
        brelse(bp);
    800031e4:	854a                	mv	a0,s2
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	e20080e7          	jalr	-480(ra) # 80003006 <brelse>
  bp = bread(dev, bno);
    800031ee:	85a6                	mv	a1,s1
    800031f0:	855e                	mv	a0,s7
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	ce4080e7          	jalr	-796(ra) # 80002ed6 <bread>
    800031fa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031fc:	40000613          	li	a2,1024
    80003200:	4581                	li	a1,0
    80003202:	05850513          	addi	a0,a0,88
    80003206:	ffffe097          	auipc	ra,0xffffe
    8000320a:	acc080e7          	jalr	-1332(ra) # 80000cd2 <memset>
  log_write(bp);
    8000320e:	854a                	mv	a0,s2
    80003210:	00001097          	auipc	ra,0x1
    80003214:	080080e7          	jalr	128(ra) # 80004290 <log_write>
  brelse(bp);
    80003218:	854a                	mv	a0,s2
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	dec080e7          	jalr	-532(ra) # 80003006 <brelse>
}
    80003222:	8526                	mv	a0,s1
    80003224:	60e6                	ld	ra,88(sp)
    80003226:	6446                	ld	s0,80(sp)
    80003228:	64a6                	ld	s1,72(sp)
    8000322a:	6906                	ld	s2,64(sp)
    8000322c:	79e2                	ld	s3,56(sp)
    8000322e:	7a42                	ld	s4,48(sp)
    80003230:	7aa2                	ld	s5,40(sp)
    80003232:	7b02                	ld	s6,32(sp)
    80003234:	6be2                	ld	s7,24(sp)
    80003236:	6c42                	ld	s8,16(sp)
    80003238:	6ca2                	ld	s9,8(sp)
    8000323a:	6125                	addi	sp,sp,96
    8000323c:	8082                	ret
    brelse(bp);
    8000323e:	854a                	mv	a0,s2
    80003240:	00000097          	auipc	ra,0x0
    80003244:	dc6080e7          	jalr	-570(ra) # 80003006 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003248:	015c87bb          	addw	a5,s9,s5
    8000324c:	00078a9b          	sext.w	s5,a5
    80003250:	004b2703          	lw	a4,4(s6)
    80003254:	06eaf163          	bgeu	s5,a4,800032b6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003258:	41fad79b          	sraiw	a5,s5,0x1f
    8000325c:	0137d79b          	srliw	a5,a5,0x13
    80003260:	015787bb          	addw	a5,a5,s5
    80003264:	40d7d79b          	sraiw	a5,a5,0xd
    80003268:	01cb2583          	lw	a1,28(s6)
    8000326c:	9dbd                	addw	a1,a1,a5
    8000326e:	855e                	mv	a0,s7
    80003270:	00000097          	auipc	ra,0x0
    80003274:	c66080e7          	jalr	-922(ra) # 80002ed6 <bread>
    80003278:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000327a:	004b2503          	lw	a0,4(s6)
    8000327e:	000a849b          	sext.w	s1,s5
    80003282:	8762                	mv	a4,s8
    80003284:	faa4fde3          	bgeu	s1,a0,8000323e <balloc+0xa6>
      m = 1 << (bi % 8);
    80003288:	00777693          	andi	a3,a4,7
    8000328c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003290:	41f7579b          	sraiw	a5,a4,0x1f
    80003294:	01d7d79b          	srliw	a5,a5,0x1d
    80003298:	9fb9                	addw	a5,a5,a4
    8000329a:	4037d79b          	sraiw	a5,a5,0x3
    8000329e:	00f90633          	add	a2,s2,a5
    800032a2:	05864603          	lbu	a2,88(a2)
    800032a6:	00c6f5b3          	and	a1,a3,a2
    800032aa:	d585                	beqz	a1,800031d2 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ac:	2705                	addiw	a4,a4,1
    800032ae:	2485                	addiw	s1,s1,1
    800032b0:	fd471ae3          	bne	a4,s4,80003284 <balloc+0xec>
    800032b4:	b769                	j	8000323e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800032b6:	00005517          	auipc	a0,0x5
    800032ba:	2ba50513          	addi	a0,a0,698 # 80008570 <syscalls+0x120>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	2cc080e7          	jalr	716(ra) # 8000058a <printf>
  return 0;
    800032c6:	4481                	li	s1,0
    800032c8:	bfa9                	j	80003222 <balloc+0x8a>

00000000800032ca <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032ca:	7179                	addi	sp,sp,-48
    800032cc:	f406                	sd	ra,40(sp)
    800032ce:	f022                	sd	s0,32(sp)
    800032d0:	ec26                	sd	s1,24(sp)
    800032d2:	e84a                	sd	s2,16(sp)
    800032d4:	e44e                	sd	s3,8(sp)
    800032d6:	e052                	sd	s4,0(sp)
    800032d8:	1800                	addi	s0,sp,48
    800032da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032dc:	47ad                	li	a5,11
    800032de:	02b7e863          	bltu	a5,a1,8000330e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800032e2:	02059793          	slli	a5,a1,0x20
    800032e6:	01e7d593          	srli	a1,a5,0x1e
    800032ea:	00b504b3          	add	s1,a0,a1
    800032ee:	0504a903          	lw	s2,80(s1)
    800032f2:	06091e63          	bnez	s2,8000336e <bmap+0xa4>
      addr = balloc(ip->dev);
    800032f6:	4108                	lw	a0,0(a0)
    800032f8:	00000097          	auipc	ra,0x0
    800032fc:	ea0080e7          	jalr	-352(ra) # 80003198 <balloc>
    80003300:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003304:	06090563          	beqz	s2,8000336e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003308:	0524a823          	sw	s2,80(s1)
    8000330c:	a08d                	j	8000336e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000330e:	ff45849b          	addiw	s1,a1,-12
    80003312:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003316:	0ff00793          	li	a5,255
    8000331a:	08e7e563          	bltu	a5,a4,800033a4 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000331e:	08052903          	lw	s2,128(a0)
    80003322:	00091d63          	bnez	s2,8000333c <bmap+0x72>
      addr = balloc(ip->dev);
    80003326:	4108                	lw	a0,0(a0)
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	e70080e7          	jalr	-400(ra) # 80003198 <balloc>
    80003330:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003334:	02090d63          	beqz	s2,8000336e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003338:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000333c:	85ca                	mv	a1,s2
    8000333e:	0009a503          	lw	a0,0(s3)
    80003342:	00000097          	auipc	ra,0x0
    80003346:	b94080e7          	jalr	-1132(ra) # 80002ed6 <bread>
    8000334a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000334c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003350:	02049713          	slli	a4,s1,0x20
    80003354:	01e75593          	srli	a1,a4,0x1e
    80003358:	00b784b3          	add	s1,a5,a1
    8000335c:	0004a903          	lw	s2,0(s1)
    80003360:	02090063          	beqz	s2,80003380 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003364:	8552                	mv	a0,s4
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	ca0080e7          	jalr	-864(ra) # 80003006 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000336e:	854a                	mv	a0,s2
    80003370:	70a2                	ld	ra,40(sp)
    80003372:	7402                	ld	s0,32(sp)
    80003374:	64e2                	ld	s1,24(sp)
    80003376:	6942                	ld	s2,16(sp)
    80003378:	69a2                	ld	s3,8(sp)
    8000337a:	6a02                	ld	s4,0(sp)
    8000337c:	6145                	addi	sp,sp,48
    8000337e:	8082                	ret
      addr = balloc(ip->dev);
    80003380:	0009a503          	lw	a0,0(s3)
    80003384:	00000097          	auipc	ra,0x0
    80003388:	e14080e7          	jalr	-492(ra) # 80003198 <balloc>
    8000338c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003390:	fc090ae3          	beqz	s2,80003364 <bmap+0x9a>
        a[bn] = addr;
    80003394:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003398:	8552                	mv	a0,s4
    8000339a:	00001097          	auipc	ra,0x1
    8000339e:	ef6080e7          	jalr	-266(ra) # 80004290 <log_write>
    800033a2:	b7c9                	j	80003364 <bmap+0x9a>
  panic("bmap: out of range");
    800033a4:	00005517          	auipc	a0,0x5
    800033a8:	1e450513          	addi	a0,a0,484 # 80008588 <syscalls+0x138>
    800033ac:	ffffd097          	auipc	ra,0xffffd
    800033b0:	194080e7          	jalr	404(ra) # 80000540 <panic>

00000000800033b4 <iget>:
{
    800033b4:	7179                	addi	sp,sp,-48
    800033b6:	f406                	sd	ra,40(sp)
    800033b8:	f022                	sd	s0,32(sp)
    800033ba:	ec26                	sd	s1,24(sp)
    800033bc:	e84a                	sd	s2,16(sp)
    800033be:	e44e                	sd	s3,8(sp)
    800033c0:	e052                	sd	s4,0(sp)
    800033c2:	1800                	addi	s0,sp,48
    800033c4:	89aa                	mv	s3,a0
    800033c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033c8:	0001c517          	auipc	a0,0x1c
    800033cc:	cd050513          	addi	a0,a0,-816 # 8001f098 <itable>
    800033d0:	ffffe097          	auipc	ra,0xffffe
    800033d4:	806080e7          	jalr	-2042(ra) # 80000bd6 <acquire>
  empty = 0;
    800033d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033da:	0001c497          	auipc	s1,0x1c
    800033de:	cd648493          	addi	s1,s1,-810 # 8001f0b0 <itable+0x18>
    800033e2:	0001d697          	auipc	a3,0x1d
    800033e6:	75e68693          	addi	a3,a3,1886 # 80020b40 <log>
    800033ea:	a039                	j	800033f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ec:	02090b63          	beqz	s2,80003422 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033f0:	08848493          	addi	s1,s1,136
    800033f4:	02d48a63          	beq	s1,a3,80003428 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f8:	449c                	lw	a5,8(s1)
    800033fa:	fef059e3          	blez	a5,800033ec <iget+0x38>
    800033fe:	4098                	lw	a4,0(s1)
    80003400:	ff3716e3          	bne	a4,s3,800033ec <iget+0x38>
    80003404:	40d8                	lw	a4,4(s1)
    80003406:	ff4713e3          	bne	a4,s4,800033ec <iget+0x38>
      ip->ref++;
    8000340a:	2785                	addiw	a5,a5,1
    8000340c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000340e:	0001c517          	auipc	a0,0x1c
    80003412:	c8a50513          	addi	a0,a0,-886 # 8001f098 <itable>
    80003416:	ffffe097          	auipc	ra,0xffffe
    8000341a:	874080e7          	jalr	-1932(ra) # 80000c8a <release>
      return ip;
    8000341e:	8926                	mv	s2,s1
    80003420:	a03d                	j	8000344e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003422:	f7f9                	bnez	a5,800033f0 <iget+0x3c>
    80003424:	8926                	mv	s2,s1
    80003426:	b7e9                	j	800033f0 <iget+0x3c>
  if(empty == 0)
    80003428:	02090c63          	beqz	s2,80003460 <iget+0xac>
  ip->dev = dev;
    8000342c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003430:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003434:	4785                	li	a5,1
    80003436:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000343a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000343e:	0001c517          	auipc	a0,0x1c
    80003442:	c5a50513          	addi	a0,a0,-934 # 8001f098 <itable>
    80003446:	ffffe097          	auipc	ra,0xffffe
    8000344a:	844080e7          	jalr	-1980(ra) # 80000c8a <release>
}
    8000344e:	854a                	mv	a0,s2
    80003450:	70a2                	ld	ra,40(sp)
    80003452:	7402                	ld	s0,32(sp)
    80003454:	64e2                	ld	s1,24(sp)
    80003456:	6942                	ld	s2,16(sp)
    80003458:	69a2                	ld	s3,8(sp)
    8000345a:	6a02                	ld	s4,0(sp)
    8000345c:	6145                	addi	sp,sp,48
    8000345e:	8082                	ret
    panic("iget: no inodes");
    80003460:	00005517          	auipc	a0,0x5
    80003464:	14050513          	addi	a0,a0,320 # 800085a0 <syscalls+0x150>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	0d8080e7          	jalr	216(ra) # 80000540 <panic>

0000000080003470 <fsinit>:
fsinit(int dev) {
    80003470:	7179                	addi	sp,sp,-48
    80003472:	f406                	sd	ra,40(sp)
    80003474:	f022                	sd	s0,32(sp)
    80003476:	ec26                	sd	s1,24(sp)
    80003478:	e84a                	sd	s2,16(sp)
    8000347a:	e44e                	sd	s3,8(sp)
    8000347c:	1800                	addi	s0,sp,48
    8000347e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003480:	4585                	li	a1,1
    80003482:	00000097          	auipc	ra,0x0
    80003486:	a54080e7          	jalr	-1452(ra) # 80002ed6 <bread>
    8000348a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000348c:	0001c997          	auipc	s3,0x1c
    80003490:	bec98993          	addi	s3,s3,-1044 # 8001f078 <sb>
    80003494:	02000613          	li	a2,32
    80003498:	05850593          	addi	a1,a0,88
    8000349c:	854e                	mv	a0,s3
    8000349e:	ffffe097          	auipc	ra,0xffffe
    800034a2:	890080e7          	jalr	-1904(ra) # 80000d2e <memmove>
  brelse(bp);
    800034a6:	8526                	mv	a0,s1
    800034a8:	00000097          	auipc	ra,0x0
    800034ac:	b5e080e7          	jalr	-1186(ra) # 80003006 <brelse>
  if(sb.magic != FSMAGIC)
    800034b0:	0009a703          	lw	a4,0(s3)
    800034b4:	102037b7          	lui	a5,0x10203
    800034b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034bc:	02f71263          	bne	a4,a5,800034e0 <fsinit+0x70>
  initlog(dev, &sb);
    800034c0:	0001c597          	auipc	a1,0x1c
    800034c4:	bb858593          	addi	a1,a1,-1096 # 8001f078 <sb>
    800034c8:	854a                	mv	a0,s2
    800034ca:	00001097          	auipc	ra,0x1
    800034ce:	b4a080e7          	jalr	-1206(ra) # 80004014 <initlog>
}
    800034d2:	70a2                	ld	ra,40(sp)
    800034d4:	7402                	ld	s0,32(sp)
    800034d6:	64e2                	ld	s1,24(sp)
    800034d8:	6942                	ld	s2,16(sp)
    800034da:	69a2                	ld	s3,8(sp)
    800034dc:	6145                	addi	sp,sp,48
    800034de:	8082                	ret
    panic("invalid file system");
    800034e0:	00005517          	auipc	a0,0x5
    800034e4:	0d050513          	addi	a0,a0,208 # 800085b0 <syscalls+0x160>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	058080e7          	jalr	88(ra) # 80000540 <panic>

00000000800034f0 <iinit>:
{
    800034f0:	7179                	addi	sp,sp,-48
    800034f2:	f406                	sd	ra,40(sp)
    800034f4:	f022                	sd	s0,32(sp)
    800034f6:	ec26                	sd	s1,24(sp)
    800034f8:	e84a                	sd	s2,16(sp)
    800034fa:	e44e                	sd	s3,8(sp)
    800034fc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034fe:	00005597          	auipc	a1,0x5
    80003502:	0ca58593          	addi	a1,a1,202 # 800085c8 <syscalls+0x178>
    80003506:	0001c517          	auipc	a0,0x1c
    8000350a:	b9250513          	addi	a0,a0,-1134 # 8001f098 <itable>
    8000350e:	ffffd097          	auipc	ra,0xffffd
    80003512:	638080e7          	jalr	1592(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003516:	0001c497          	auipc	s1,0x1c
    8000351a:	baa48493          	addi	s1,s1,-1110 # 8001f0c0 <itable+0x28>
    8000351e:	0001d997          	auipc	s3,0x1d
    80003522:	63298993          	addi	s3,s3,1586 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003526:	00005917          	auipc	s2,0x5
    8000352a:	0aa90913          	addi	s2,s2,170 # 800085d0 <syscalls+0x180>
    8000352e:	85ca                	mv	a1,s2
    80003530:	8526                	mv	a0,s1
    80003532:	00001097          	auipc	ra,0x1
    80003536:	e42080e7          	jalr	-446(ra) # 80004374 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000353a:	08848493          	addi	s1,s1,136
    8000353e:	ff3498e3          	bne	s1,s3,8000352e <iinit+0x3e>
}
    80003542:	70a2                	ld	ra,40(sp)
    80003544:	7402                	ld	s0,32(sp)
    80003546:	64e2                	ld	s1,24(sp)
    80003548:	6942                	ld	s2,16(sp)
    8000354a:	69a2                	ld	s3,8(sp)
    8000354c:	6145                	addi	sp,sp,48
    8000354e:	8082                	ret

0000000080003550 <ialloc>:
{
    80003550:	715d                	addi	sp,sp,-80
    80003552:	e486                	sd	ra,72(sp)
    80003554:	e0a2                	sd	s0,64(sp)
    80003556:	fc26                	sd	s1,56(sp)
    80003558:	f84a                	sd	s2,48(sp)
    8000355a:	f44e                	sd	s3,40(sp)
    8000355c:	f052                	sd	s4,32(sp)
    8000355e:	ec56                	sd	s5,24(sp)
    80003560:	e85a                	sd	s6,16(sp)
    80003562:	e45e                	sd	s7,8(sp)
    80003564:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003566:	0001c717          	auipc	a4,0x1c
    8000356a:	b1e72703          	lw	a4,-1250(a4) # 8001f084 <sb+0xc>
    8000356e:	4785                	li	a5,1
    80003570:	04e7fa63          	bgeu	a5,a4,800035c4 <ialloc+0x74>
    80003574:	8aaa                	mv	s5,a0
    80003576:	8bae                	mv	s7,a1
    80003578:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000357a:	0001ca17          	auipc	s4,0x1c
    8000357e:	afea0a13          	addi	s4,s4,-1282 # 8001f078 <sb>
    80003582:	00048b1b          	sext.w	s6,s1
    80003586:	0044d593          	srli	a1,s1,0x4
    8000358a:	018a2783          	lw	a5,24(s4)
    8000358e:	9dbd                	addw	a1,a1,a5
    80003590:	8556                	mv	a0,s5
    80003592:	00000097          	auipc	ra,0x0
    80003596:	944080e7          	jalr	-1724(ra) # 80002ed6 <bread>
    8000359a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000359c:	05850993          	addi	s3,a0,88
    800035a0:	00f4f793          	andi	a5,s1,15
    800035a4:	079a                	slli	a5,a5,0x6
    800035a6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035a8:	00099783          	lh	a5,0(s3)
    800035ac:	c3a1                	beqz	a5,800035ec <ialloc+0x9c>
    brelse(bp);
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	a58080e7          	jalr	-1448(ra) # 80003006 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b6:	0485                	addi	s1,s1,1
    800035b8:	00ca2703          	lw	a4,12(s4)
    800035bc:	0004879b          	sext.w	a5,s1
    800035c0:	fce7e1e3          	bltu	a5,a4,80003582 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800035c4:	00005517          	auipc	a0,0x5
    800035c8:	01450513          	addi	a0,a0,20 # 800085d8 <syscalls+0x188>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	fbe080e7          	jalr	-66(ra) # 8000058a <printf>
  return 0;
    800035d4:	4501                	li	a0,0
}
    800035d6:	60a6                	ld	ra,72(sp)
    800035d8:	6406                	ld	s0,64(sp)
    800035da:	74e2                	ld	s1,56(sp)
    800035dc:	7942                	ld	s2,48(sp)
    800035de:	79a2                	ld	s3,40(sp)
    800035e0:	7a02                	ld	s4,32(sp)
    800035e2:	6ae2                	ld	s5,24(sp)
    800035e4:	6b42                	ld	s6,16(sp)
    800035e6:	6ba2                	ld	s7,8(sp)
    800035e8:	6161                	addi	sp,sp,80
    800035ea:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035ec:	04000613          	li	a2,64
    800035f0:	4581                	li	a1,0
    800035f2:	854e                	mv	a0,s3
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	6de080e7          	jalr	1758(ra) # 80000cd2 <memset>
      dip->type = type;
    800035fc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003600:	854a                	mv	a0,s2
    80003602:	00001097          	auipc	ra,0x1
    80003606:	c8e080e7          	jalr	-882(ra) # 80004290 <log_write>
      brelse(bp);
    8000360a:	854a                	mv	a0,s2
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	9fa080e7          	jalr	-1542(ra) # 80003006 <brelse>
      return iget(dev, inum);
    80003614:	85da                	mv	a1,s6
    80003616:	8556                	mv	a0,s5
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	d9c080e7          	jalr	-612(ra) # 800033b4 <iget>
    80003620:	bf5d                	j	800035d6 <ialloc+0x86>

0000000080003622 <iupdate>:
{
    80003622:	1101                	addi	sp,sp,-32
    80003624:	ec06                	sd	ra,24(sp)
    80003626:	e822                	sd	s0,16(sp)
    80003628:	e426                	sd	s1,8(sp)
    8000362a:	e04a                	sd	s2,0(sp)
    8000362c:	1000                	addi	s0,sp,32
    8000362e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003630:	415c                	lw	a5,4(a0)
    80003632:	0047d79b          	srliw	a5,a5,0x4
    80003636:	0001c597          	auipc	a1,0x1c
    8000363a:	a5a5a583          	lw	a1,-1446(a1) # 8001f090 <sb+0x18>
    8000363e:	9dbd                	addw	a1,a1,a5
    80003640:	4108                	lw	a0,0(a0)
    80003642:	00000097          	auipc	ra,0x0
    80003646:	894080e7          	jalr	-1900(ra) # 80002ed6 <bread>
    8000364a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000364c:	05850793          	addi	a5,a0,88
    80003650:	40d8                	lw	a4,4(s1)
    80003652:	8b3d                	andi	a4,a4,15
    80003654:	071a                	slli	a4,a4,0x6
    80003656:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003658:	04449703          	lh	a4,68(s1)
    8000365c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003660:	04649703          	lh	a4,70(s1)
    80003664:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003668:	04849703          	lh	a4,72(s1)
    8000366c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003670:	04a49703          	lh	a4,74(s1)
    80003674:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003678:	44f8                	lw	a4,76(s1)
    8000367a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000367c:	03400613          	li	a2,52
    80003680:	05048593          	addi	a1,s1,80
    80003684:	00c78513          	addi	a0,a5,12
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	6a6080e7          	jalr	1702(ra) # 80000d2e <memmove>
  log_write(bp);
    80003690:	854a                	mv	a0,s2
    80003692:	00001097          	auipc	ra,0x1
    80003696:	bfe080e7          	jalr	-1026(ra) # 80004290 <log_write>
  brelse(bp);
    8000369a:	854a                	mv	a0,s2
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	96a080e7          	jalr	-1686(ra) # 80003006 <brelse>
}
    800036a4:	60e2                	ld	ra,24(sp)
    800036a6:	6442                	ld	s0,16(sp)
    800036a8:	64a2                	ld	s1,8(sp)
    800036aa:	6902                	ld	s2,0(sp)
    800036ac:	6105                	addi	sp,sp,32
    800036ae:	8082                	ret

00000000800036b0 <idup>:
{
    800036b0:	1101                	addi	sp,sp,-32
    800036b2:	ec06                	sd	ra,24(sp)
    800036b4:	e822                	sd	s0,16(sp)
    800036b6:	e426                	sd	s1,8(sp)
    800036b8:	1000                	addi	s0,sp,32
    800036ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036bc:	0001c517          	auipc	a0,0x1c
    800036c0:	9dc50513          	addi	a0,a0,-1572 # 8001f098 <itable>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	512080e7          	jalr	1298(ra) # 80000bd6 <acquire>
  ip->ref++;
    800036cc:	449c                	lw	a5,8(s1)
    800036ce:	2785                	addiw	a5,a5,1
    800036d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036d2:	0001c517          	auipc	a0,0x1c
    800036d6:	9c650513          	addi	a0,a0,-1594 # 8001f098 <itable>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	5b0080e7          	jalr	1456(ra) # 80000c8a <release>
}
    800036e2:	8526                	mv	a0,s1
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	64a2                	ld	s1,8(sp)
    800036ea:	6105                	addi	sp,sp,32
    800036ec:	8082                	ret

00000000800036ee <ilock>:
{
    800036ee:	1101                	addi	sp,sp,-32
    800036f0:	ec06                	sd	ra,24(sp)
    800036f2:	e822                	sd	s0,16(sp)
    800036f4:	e426                	sd	s1,8(sp)
    800036f6:	e04a                	sd	s2,0(sp)
    800036f8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036fa:	c115                	beqz	a0,8000371e <ilock+0x30>
    800036fc:	84aa                	mv	s1,a0
    800036fe:	451c                	lw	a5,8(a0)
    80003700:	00f05f63          	blez	a5,8000371e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003704:	0541                	addi	a0,a0,16
    80003706:	00001097          	auipc	ra,0x1
    8000370a:	ca8080e7          	jalr	-856(ra) # 800043ae <acquiresleep>
  if(ip->valid == 0){
    8000370e:	40bc                	lw	a5,64(s1)
    80003710:	cf99                	beqz	a5,8000372e <ilock+0x40>
}
    80003712:	60e2                	ld	ra,24(sp)
    80003714:	6442                	ld	s0,16(sp)
    80003716:	64a2                	ld	s1,8(sp)
    80003718:	6902                	ld	s2,0(sp)
    8000371a:	6105                	addi	sp,sp,32
    8000371c:	8082                	ret
    panic("ilock");
    8000371e:	00005517          	auipc	a0,0x5
    80003722:	ed250513          	addi	a0,a0,-302 # 800085f0 <syscalls+0x1a0>
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	e1a080e7          	jalr	-486(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372e:	40dc                	lw	a5,4(s1)
    80003730:	0047d79b          	srliw	a5,a5,0x4
    80003734:	0001c597          	auipc	a1,0x1c
    80003738:	95c5a583          	lw	a1,-1700(a1) # 8001f090 <sb+0x18>
    8000373c:	9dbd                	addw	a1,a1,a5
    8000373e:	4088                	lw	a0,0(s1)
    80003740:	fffff097          	auipc	ra,0xfffff
    80003744:	796080e7          	jalr	1942(ra) # 80002ed6 <bread>
    80003748:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000374a:	05850593          	addi	a1,a0,88
    8000374e:	40dc                	lw	a5,4(s1)
    80003750:	8bbd                	andi	a5,a5,15
    80003752:	079a                	slli	a5,a5,0x6
    80003754:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003756:	00059783          	lh	a5,0(a1)
    8000375a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000375e:	00259783          	lh	a5,2(a1)
    80003762:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003766:	00459783          	lh	a5,4(a1)
    8000376a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000376e:	00659783          	lh	a5,6(a1)
    80003772:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003776:	459c                	lw	a5,8(a1)
    80003778:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000377a:	03400613          	li	a2,52
    8000377e:	05b1                	addi	a1,a1,12
    80003780:	05048513          	addi	a0,s1,80
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	5aa080e7          	jalr	1450(ra) # 80000d2e <memmove>
    brelse(bp);
    8000378c:	854a                	mv	a0,s2
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	878080e7          	jalr	-1928(ra) # 80003006 <brelse>
    ip->valid = 1;
    80003796:	4785                	li	a5,1
    80003798:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000379a:	04449783          	lh	a5,68(s1)
    8000379e:	fbb5                	bnez	a5,80003712 <ilock+0x24>
      panic("ilock: no type");
    800037a0:	00005517          	auipc	a0,0x5
    800037a4:	e5850513          	addi	a0,a0,-424 # 800085f8 <syscalls+0x1a8>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	d98080e7          	jalr	-616(ra) # 80000540 <panic>

00000000800037b0 <iunlock>:
{
    800037b0:	1101                	addi	sp,sp,-32
    800037b2:	ec06                	sd	ra,24(sp)
    800037b4:	e822                	sd	s0,16(sp)
    800037b6:	e426                	sd	s1,8(sp)
    800037b8:	e04a                	sd	s2,0(sp)
    800037ba:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037bc:	c905                	beqz	a0,800037ec <iunlock+0x3c>
    800037be:	84aa                	mv	s1,a0
    800037c0:	01050913          	addi	s2,a0,16
    800037c4:	854a                	mv	a0,s2
    800037c6:	00001097          	auipc	ra,0x1
    800037ca:	c82080e7          	jalr	-894(ra) # 80004448 <holdingsleep>
    800037ce:	cd19                	beqz	a0,800037ec <iunlock+0x3c>
    800037d0:	449c                	lw	a5,8(s1)
    800037d2:	00f05d63          	blez	a5,800037ec <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037d6:	854a                	mv	a0,s2
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	c2c080e7          	jalr	-980(ra) # 80004404 <releasesleep>
}
    800037e0:	60e2                	ld	ra,24(sp)
    800037e2:	6442                	ld	s0,16(sp)
    800037e4:	64a2                	ld	s1,8(sp)
    800037e6:	6902                	ld	s2,0(sp)
    800037e8:	6105                	addi	sp,sp,32
    800037ea:	8082                	ret
    panic("iunlock");
    800037ec:	00005517          	auipc	a0,0x5
    800037f0:	e1c50513          	addi	a0,a0,-484 # 80008608 <syscalls+0x1b8>
    800037f4:	ffffd097          	auipc	ra,0xffffd
    800037f8:	d4c080e7          	jalr	-692(ra) # 80000540 <panic>

00000000800037fc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037fc:	7179                	addi	sp,sp,-48
    800037fe:	f406                	sd	ra,40(sp)
    80003800:	f022                	sd	s0,32(sp)
    80003802:	ec26                	sd	s1,24(sp)
    80003804:	e84a                	sd	s2,16(sp)
    80003806:	e44e                	sd	s3,8(sp)
    80003808:	e052                	sd	s4,0(sp)
    8000380a:	1800                	addi	s0,sp,48
    8000380c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000380e:	05050493          	addi	s1,a0,80
    80003812:	08050913          	addi	s2,a0,128
    80003816:	a021                	j	8000381e <itrunc+0x22>
    80003818:	0491                	addi	s1,s1,4
    8000381a:	01248d63          	beq	s1,s2,80003834 <itrunc+0x38>
    if(ip->addrs[i]){
    8000381e:	408c                	lw	a1,0(s1)
    80003820:	dde5                	beqz	a1,80003818 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003822:	0009a503          	lw	a0,0(s3)
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	8f6080e7          	jalr	-1802(ra) # 8000311c <bfree>
      ip->addrs[i] = 0;
    8000382e:	0004a023          	sw	zero,0(s1)
    80003832:	b7dd                	j	80003818 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003834:	0809a583          	lw	a1,128(s3)
    80003838:	e185                	bnez	a1,80003858 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000383a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000383e:	854e                	mv	a0,s3
    80003840:	00000097          	auipc	ra,0x0
    80003844:	de2080e7          	jalr	-542(ra) # 80003622 <iupdate>
}
    80003848:	70a2                	ld	ra,40(sp)
    8000384a:	7402                	ld	s0,32(sp)
    8000384c:	64e2                	ld	s1,24(sp)
    8000384e:	6942                	ld	s2,16(sp)
    80003850:	69a2                	ld	s3,8(sp)
    80003852:	6a02                	ld	s4,0(sp)
    80003854:	6145                	addi	sp,sp,48
    80003856:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003858:	0009a503          	lw	a0,0(s3)
    8000385c:	fffff097          	auipc	ra,0xfffff
    80003860:	67a080e7          	jalr	1658(ra) # 80002ed6 <bread>
    80003864:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003866:	05850493          	addi	s1,a0,88
    8000386a:	45850913          	addi	s2,a0,1112
    8000386e:	a021                	j	80003876 <itrunc+0x7a>
    80003870:	0491                	addi	s1,s1,4
    80003872:	01248b63          	beq	s1,s2,80003888 <itrunc+0x8c>
      if(a[j])
    80003876:	408c                	lw	a1,0(s1)
    80003878:	dde5                	beqz	a1,80003870 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000387a:	0009a503          	lw	a0,0(s3)
    8000387e:	00000097          	auipc	ra,0x0
    80003882:	89e080e7          	jalr	-1890(ra) # 8000311c <bfree>
    80003886:	b7ed                	j	80003870 <itrunc+0x74>
    brelse(bp);
    80003888:	8552                	mv	a0,s4
    8000388a:	fffff097          	auipc	ra,0xfffff
    8000388e:	77c080e7          	jalr	1916(ra) # 80003006 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003892:	0809a583          	lw	a1,128(s3)
    80003896:	0009a503          	lw	a0,0(s3)
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	882080e7          	jalr	-1918(ra) # 8000311c <bfree>
    ip->addrs[NDIRECT] = 0;
    800038a2:	0809a023          	sw	zero,128(s3)
    800038a6:	bf51                	j	8000383a <itrunc+0x3e>

00000000800038a8 <iput>:
{
    800038a8:	1101                	addi	sp,sp,-32
    800038aa:	ec06                	sd	ra,24(sp)
    800038ac:	e822                	sd	s0,16(sp)
    800038ae:	e426                	sd	s1,8(sp)
    800038b0:	e04a                	sd	s2,0(sp)
    800038b2:	1000                	addi	s0,sp,32
    800038b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038b6:	0001b517          	auipc	a0,0x1b
    800038ba:	7e250513          	addi	a0,a0,2018 # 8001f098 <itable>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	318080e7          	jalr	792(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038c6:	4498                	lw	a4,8(s1)
    800038c8:	4785                	li	a5,1
    800038ca:	02f70363          	beq	a4,a5,800038f0 <iput+0x48>
  ip->ref--;
    800038ce:	449c                	lw	a5,8(s1)
    800038d0:	37fd                	addiw	a5,a5,-1
    800038d2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038d4:	0001b517          	auipc	a0,0x1b
    800038d8:	7c450513          	addi	a0,a0,1988 # 8001f098 <itable>
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	3ae080e7          	jalr	942(ra) # 80000c8a <release>
}
    800038e4:	60e2                	ld	ra,24(sp)
    800038e6:	6442                	ld	s0,16(sp)
    800038e8:	64a2                	ld	s1,8(sp)
    800038ea:	6902                	ld	s2,0(sp)
    800038ec:	6105                	addi	sp,sp,32
    800038ee:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038f0:	40bc                	lw	a5,64(s1)
    800038f2:	dff1                	beqz	a5,800038ce <iput+0x26>
    800038f4:	04a49783          	lh	a5,74(s1)
    800038f8:	fbf9                	bnez	a5,800038ce <iput+0x26>
    acquiresleep(&ip->lock);
    800038fa:	01048913          	addi	s2,s1,16
    800038fe:	854a                	mv	a0,s2
    80003900:	00001097          	auipc	ra,0x1
    80003904:	aae080e7          	jalr	-1362(ra) # 800043ae <acquiresleep>
    release(&itable.lock);
    80003908:	0001b517          	auipc	a0,0x1b
    8000390c:	79050513          	addi	a0,a0,1936 # 8001f098 <itable>
    80003910:	ffffd097          	auipc	ra,0xffffd
    80003914:	37a080e7          	jalr	890(ra) # 80000c8a <release>
    itrunc(ip);
    80003918:	8526                	mv	a0,s1
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	ee2080e7          	jalr	-286(ra) # 800037fc <itrunc>
    ip->type = 0;
    80003922:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003926:	8526                	mv	a0,s1
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	cfa080e7          	jalr	-774(ra) # 80003622 <iupdate>
    ip->valid = 0;
    80003930:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003934:	854a                	mv	a0,s2
    80003936:	00001097          	auipc	ra,0x1
    8000393a:	ace080e7          	jalr	-1330(ra) # 80004404 <releasesleep>
    acquire(&itable.lock);
    8000393e:	0001b517          	auipc	a0,0x1b
    80003942:	75a50513          	addi	a0,a0,1882 # 8001f098 <itable>
    80003946:	ffffd097          	auipc	ra,0xffffd
    8000394a:	290080e7          	jalr	656(ra) # 80000bd6 <acquire>
    8000394e:	b741                	j	800038ce <iput+0x26>

0000000080003950 <iunlockput>:
{
    80003950:	1101                	addi	sp,sp,-32
    80003952:	ec06                	sd	ra,24(sp)
    80003954:	e822                	sd	s0,16(sp)
    80003956:	e426                	sd	s1,8(sp)
    80003958:	1000                	addi	s0,sp,32
    8000395a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000395c:	00000097          	auipc	ra,0x0
    80003960:	e54080e7          	jalr	-428(ra) # 800037b0 <iunlock>
  iput(ip);
    80003964:	8526                	mv	a0,s1
    80003966:	00000097          	auipc	ra,0x0
    8000396a:	f42080e7          	jalr	-190(ra) # 800038a8 <iput>
}
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6105                	addi	sp,sp,32
    80003976:	8082                	ret

0000000080003978 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003978:	1141                	addi	sp,sp,-16
    8000397a:	e422                	sd	s0,8(sp)
    8000397c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000397e:	411c                	lw	a5,0(a0)
    80003980:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003982:	415c                	lw	a5,4(a0)
    80003984:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003986:	04451783          	lh	a5,68(a0)
    8000398a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000398e:	04a51783          	lh	a5,74(a0)
    80003992:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003996:	04c56783          	lwu	a5,76(a0)
    8000399a:	e99c                	sd	a5,16(a1)
}
    8000399c:	6422                	ld	s0,8(sp)
    8000399e:	0141                	addi	sp,sp,16
    800039a0:	8082                	ret

00000000800039a2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039a2:	457c                	lw	a5,76(a0)
    800039a4:	0ed7e963          	bltu	a5,a3,80003a96 <readi+0xf4>
{
    800039a8:	7159                	addi	sp,sp,-112
    800039aa:	f486                	sd	ra,104(sp)
    800039ac:	f0a2                	sd	s0,96(sp)
    800039ae:	eca6                	sd	s1,88(sp)
    800039b0:	e8ca                	sd	s2,80(sp)
    800039b2:	e4ce                	sd	s3,72(sp)
    800039b4:	e0d2                	sd	s4,64(sp)
    800039b6:	fc56                	sd	s5,56(sp)
    800039b8:	f85a                	sd	s6,48(sp)
    800039ba:	f45e                	sd	s7,40(sp)
    800039bc:	f062                	sd	s8,32(sp)
    800039be:	ec66                	sd	s9,24(sp)
    800039c0:	e86a                	sd	s10,16(sp)
    800039c2:	e46e                	sd	s11,8(sp)
    800039c4:	1880                	addi	s0,sp,112
    800039c6:	8b2a                	mv	s6,a0
    800039c8:	8bae                	mv	s7,a1
    800039ca:	8a32                	mv	s4,a2
    800039cc:	84b6                	mv	s1,a3
    800039ce:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039d0:	9f35                	addw	a4,a4,a3
    return 0;
    800039d2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039d4:	0ad76063          	bltu	a4,a3,80003a74 <readi+0xd2>
  if(off + n > ip->size)
    800039d8:	00e7f463          	bgeu	a5,a4,800039e0 <readi+0x3e>
    n = ip->size - off;
    800039dc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e0:	0a0a8963          	beqz	s5,80003a92 <readi+0xf0>
    800039e4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039e6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039ea:	5c7d                	li	s8,-1
    800039ec:	a82d                	j	80003a26 <readi+0x84>
    800039ee:	020d1d93          	slli	s11,s10,0x20
    800039f2:	020ddd93          	srli	s11,s11,0x20
    800039f6:	05890613          	addi	a2,s2,88
    800039fa:	86ee                	mv	a3,s11
    800039fc:	963a                	add	a2,a2,a4
    800039fe:	85d2                	mv	a1,s4
    80003a00:	855e                	mv	a0,s7
    80003a02:	fffff097          	auipc	ra,0xfffff
    80003a06:	a62080e7          	jalr	-1438(ra) # 80002464 <either_copyout>
    80003a0a:	05850d63          	beq	a0,s8,80003a64 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a0e:	854a                	mv	a0,s2
    80003a10:	fffff097          	auipc	ra,0xfffff
    80003a14:	5f6080e7          	jalr	1526(ra) # 80003006 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a18:	013d09bb          	addw	s3,s10,s3
    80003a1c:	009d04bb          	addw	s1,s10,s1
    80003a20:	9a6e                	add	s4,s4,s11
    80003a22:	0559f763          	bgeu	s3,s5,80003a70 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a26:	00a4d59b          	srliw	a1,s1,0xa
    80003a2a:	855a                	mv	a0,s6
    80003a2c:	00000097          	auipc	ra,0x0
    80003a30:	89e080e7          	jalr	-1890(ra) # 800032ca <bmap>
    80003a34:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a38:	cd85                	beqz	a1,80003a70 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a3a:	000b2503          	lw	a0,0(s6)
    80003a3e:	fffff097          	auipc	ra,0xfffff
    80003a42:	498080e7          	jalr	1176(ra) # 80002ed6 <bread>
    80003a46:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a48:	3ff4f713          	andi	a4,s1,1023
    80003a4c:	40ec87bb          	subw	a5,s9,a4
    80003a50:	413a86bb          	subw	a3,s5,s3
    80003a54:	8d3e                	mv	s10,a5
    80003a56:	2781                	sext.w	a5,a5
    80003a58:	0006861b          	sext.w	a2,a3
    80003a5c:	f8f679e3          	bgeu	a2,a5,800039ee <readi+0x4c>
    80003a60:	8d36                	mv	s10,a3
    80003a62:	b771                	j	800039ee <readi+0x4c>
      brelse(bp);
    80003a64:	854a                	mv	a0,s2
    80003a66:	fffff097          	auipc	ra,0xfffff
    80003a6a:	5a0080e7          	jalr	1440(ra) # 80003006 <brelse>
      tot = -1;
    80003a6e:	59fd                	li	s3,-1
  }
  return tot;
    80003a70:	0009851b          	sext.w	a0,s3
}
    80003a74:	70a6                	ld	ra,104(sp)
    80003a76:	7406                	ld	s0,96(sp)
    80003a78:	64e6                	ld	s1,88(sp)
    80003a7a:	6946                	ld	s2,80(sp)
    80003a7c:	69a6                	ld	s3,72(sp)
    80003a7e:	6a06                	ld	s4,64(sp)
    80003a80:	7ae2                	ld	s5,56(sp)
    80003a82:	7b42                	ld	s6,48(sp)
    80003a84:	7ba2                	ld	s7,40(sp)
    80003a86:	7c02                	ld	s8,32(sp)
    80003a88:	6ce2                	ld	s9,24(sp)
    80003a8a:	6d42                	ld	s10,16(sp)
    80003a8c:	6da2                	ld	s11,8(sp)
    80003a8e:	6165                	addi	sp,sp,112
    80003a90:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a92:	89d6                	mv	s3,s5
    80003a94:	bff1                	j	80003a70 <readi+0xce>
    return 0;
    80003a96:	4501                	li	a0,0
}
    80003a98:	8082                	ret

0000000080003a9a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a9a:	457c                	lw	a5,76(a0)
    80003a9c:	10d7e863          	bltu	a5,a3,80003bac <writei+0x112>
{
    80003aa0:	7159                	addi	sp,sp,-112
    80003aa2:	f486                	sd	ra,104(sp)
    80003aa4:	f0a2                	sd	s0,96(sp)
    80003aa6:	eca6                	sd	s1,88(sp)
    80003aa8:	e8ca                	sd	s2,80(sp)
    80003aaa:	e4ce                	sd	s3,72(sp)
    80003aac:	e0d2                	sd	s4,64(sp)
    80003aae:	fc56                	sd	s5,56(sp)
    80003ab0:	f85a                	sd	s6,48(sp)
    80003ab2:	f45e                	sd	s7,40(sp)
    80003ab4:	f062                	sd	s8,32(sp)
    80003ab6:	ec66                	sd	s9,24(sp)
    80003ab8:	e86a                	sd	s10,16(sp)
    80003aba:	e46e                	sd	s11,8(sp)
    80003abc:	1880                	addi	s0,sp,112
    80003abe:	8aaa                	mv	s5,a0
    80003ac0:	8bae                	mv	s7,a1
    80003ac2:	8a32                	mv	s4,a2
    80003ac4:	8936                	mv	s2,a3
    80003ac6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ac8:	00e687bb          	addw	a5,a3,a4
    80003acc:	0ed7e263          	bltu	a5,a3,80003bb0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ad0:	00043737          	lui	a4,0x43
    80003ad4:	0ef76063          	bltu	a4,a5,80003bb4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ad8:	0c0b0863          	beqz	s6,80003ba8 <writei+0x10e>
    80003adc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ade:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ae2:	5c7d                	li	s8,-1
    80003ae4:	a091                	j	80003b28 <writei+0x8e>
    80003ae6:	020d1d93          	slli	s11,s10,0x20
    80003aea:	020ddd93          	srli	s11,s11,0x20
    80003aee:	05848513          	addi	a0,s1,88
    80003af2:	86ee                	mv	a3,s11
    80003af4:	8652                	mv	a2,s4
    80003af6:	85de                	mv	a1,s7
    80003af8:	953a                	add	a0,a0,a4
    80003afa:	fffff097          	auipc	ra,0xfffff
    80003afe:	9c0080e7          	jalr	-1600(ra) # 800024ba <either_copyin>
    80003b02:	07850263          	beq	a0,s8,80003b66 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b06:	8526                	mv	a0,s1
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	788080e7          	jalr	1928(ra) # 80004290 <log_write>
    brelse(bp);
    80003b10:	8526                	mv	a0,s1
    80003b12:	fffff097          	auipc	ra,0xfffff
    80003b16:	4f4080e7          	jalr	1268(ra) # 80003006 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b1a:	013d09bb          	addw	s3,s10,s3
    80003b1e:	012d093b          	addw	s2,s10,s2
    80003b22:	9a6e                	add	s4,s4,s11
    80003b24:	0569f663          	bgeu	s3,s6,80003b70 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b28:	00a9559b          	srliw	a1,s2,0xa
    80003b2c:	8556                	mv	a0,s5
    80003b2e:	fffff097          	auipc	ra,0xfffff
    80003b32:	79c080e7          	jalr	1948(ra) # 800032ca <bmap>
    80003b36:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b3a:	c99d                	beqz	a1,80003b70 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b3c:	000aa503          	lw	a0,0(s5)
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	396080e7          	jalr	918(ra) # 80002ed6 <bread>
    80003b48:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b4a:	3ff97713          	andi	a4,s2,1023
    80003b4e:	40ec87bb          	subw	a5,s9,a4
    80003b52:	413b06bb          	subw	a3,s6,s3
    80003b56:	8d3e                	mv	s10,a5
    80003b58:	2781                	sext.w	a5,a5
    80003b5a:	0006861b          	sext.w	a2,a3
    80003b5e:	f8f674e3          	bgeu	a2,a5,80003ae6 <writei+0x4c>
    80003b62:	8d36                	mv	s10,a3
    80003b64:	b749                	j	80003ae6 <writei+0x4c>
      brelse(bp);
    80003b66:	8526                	mv	a0,s1
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	49e080e7          	jalr	1182(ra) # 80003006 <brelse>
  }

  if(off > ip->size)
    80003b70:	04caa783          	lw	a5,76(s5)
    80003b74:	0127f463          	bgeu	a5,s2,80003b7c <writei+0xe2>
    ip->size = off;
    80003b78:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b7c:	8556                	mv	a0,s5
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	aa4080e7          	jalr	-1372(ra) # 80003622 <iupdate>

  return tot;
    80003b86:	0009851b          	sext.w	a0,s3
}
    80003b8a:	70a6                	ld	ra,104(sp)
    80003b8c:	7406                	ld	s0,96(sp)
    80003b8e:	64e6                	ld	s1,88(sp)
    80003b90:	6946                	ld	s2,80(sp)
    80003b92:	69a6                	ld	s3,72(sp)
    80003b94:	6a06                	ld	s4,64(sp)
    80003b96:	7ae2                	ld	s5,56(sp)
    80003b98:	7b42                	ld	s6,48(sp)
    80003b9a:	7ba2                	ld	s7,40(sp)
    80003b9c:	7c02                	ld	s8,32(sp)
    80003b9e:	6ce2                	ld	s9,24(sp)
    80003ba0:	6d42                	ld	s10,16(sp)
    80003ba2:	6da2                	ld	s11,8(sp)
    80003ba4:	6165                	addi	sp,sp,112
    80003ba6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ba8:	89da                	mv	s3,s6
    80003baa:	bfc9                	j	80003b7c <writei+0xe2>
    return -1;
    80003bac:	557d                	li	a0,-1
}
    80003bae:	8082                	ret
    return -1;
    80003bb0:	557d                	li	a0,-1
    80003bb2:	bfe1                	j	80003b8a <writei+0xf0>
    return -1;
    80003bb4:	557d                	li	a0,-1
    80003bb6:	bfd1                	j	80003b8a <writei+0xf0>

0000000080003bb8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bb8:	1141                	addi	sp,sp,-16
    80003bba:	e406                	sd	ra,8(sp)
    80003bbc:	e022                	sd	s0,0(sp)
    80003bbe:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bc0:	4639                	li	a2,14
    80003bc2:	ffffd097          	auipc	ra,0xffffd
    80003bc6:	1e0080e7          	jalr	480(ra) # 80000da2 <strncmp>
}
    80003bca:	60a2                	ld	ra,8(sp)
    80003bcc:	6402                	ld	s0,0(sp)
    80003bce:	0141                	addi	sp,sp,16
    80003bd0:	8082                	ret

0000000080003bd2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bd2:	7139                	addi	sp,sp,-64
    80003bd4:	fc06                	sd	ra,56(sp)
    80003bd6:	f822                	sd	s0,48(sp)
    80003bd8:	f426                	sd	s1,40(sp)
    80003bda:	f04a                	sd	s2,32(sp)
    80003bdc:	ec4e                	sd	s3,24(sp)
    80003bde:	e852                	sd	s4,16(sp)
    80003be0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003be2:	04451703          	lh	a4,68(a0)
    80003be6:	4785                	li	a5,1
    80003be8:	00f71a63          	bne	a4,a5,80003bfc <dirlookup+0x2a>
    80003bec:	892a                	mv	s2,a0
    80003bee:	89ae                	mv	s3,a1
    80003bf0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf2:	457c                	lw	a5,76(a0)
    80003bf4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bf6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf8:	e79d                	bnez	a5,80003c26 <dirlookup+0x54>
    80003bfa:	a8a5                	j	80003c72 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bfc:	00005517          	auipc	a0,0x5
    80003c00:	a1450513          	addi	a0,a0,-1516 # 80008610 <syscalls+0x1c0>
    80003c04:	ffffd097          	auipc	ra,0xffffd
    80003c08:	93c080e7          	jalr	-1732(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003c0c:	00005517          	auipc	a0,0x5
    80003c10:	a1c50513          	addi	a0,a0,-1508 # 80008628 <syscalls+0x1d8>
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	92c080e7          	jalr	-1748(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c1c:	24c1                	addiw	s1,s1,16
    80003c1e:	04c92783          	lw	a5,76(s2)
    80003c22:	04f4f763          	bgeu	s1,a5,80003c70 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c26:	4741                	li	a4,16
    80003c28:	86a6                	mv	a3,s1
    80003c2a:	fc040613          	addi	a2,s0,-64
    80003c2e:	4581                	li	a1,0
    80003c30:	854a                	mv	a0,s2
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	d70080e7          	jalr	-656(ra) # 800039a2 <readi>
    80003c3a:	47c1                	li	a5,16
    80003c3c:	fcf518e3          	bne	a0,a5,80003c0c <dirlookup+0x3a>
    if(de.inum == 0)
    80003c40:	fc045783          	lhu	a5,-64(s0)
    80003c44:	dfe1                	beqz	a5,80003c1c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c46:	fc240593          	addi	a1,s0,-62
    80003c4a:	854e                	mv	a0,s3
    80003c4c:	00000097          	auipc	ra,0x0
    80003c50:	f6c080e7          	jalr	-148(ra) # 80003bb8 <namecmp>
    80003c54:	f561                	bnez	a0,80003c1c <dirlookup+0x4a>
      if(poff)
    80003c56:	000a0463          	beqz	s4,80003c5e <dirlookup+0x8c>
        *poff = off;
    80003c5a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c5e:	fc045583          	lhu	a1,-64(s0)
    80003c62:	00092503          	lw	a0,0(s2)
    80003c66:	fffff097          	auipc	ra,0xfffff
    80003c6a:	74e080e7          	jalr	1870(ra) # 800033b4 <iget>
    80003c6e:	a011                	j	80003c72 <dirlookup+0xa0>
  return 0;
    80003c70:	4501                	li	a0,0
}
    80003c72:	70e2                	ld	ra,56(sp)
    80003c74:	7442                	ld	s0,48(sp)
    80003c76:	74a2                	ld	s1,40(sp)
    80003c78:	7902                	ld	s2,32(sp)
    80003c7a:	69e2                	ld	s3,24(sp)
    80003c7c:	6a42                	ld	s4,16(sp)
    80003c7e:	6121                	addi	sp,sp,64
    80003c80:	8082                	ret

0000000080003c82 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c82:	711d                	addi	sp,sp,-96
    80003c84:	ec86                	sd	ra,88(sp)
    80003c86:	e8a2                	sd	s0,80(sp)
    80003c88:	e4a6                	sd	s1,72(sp)
    80003c8a:	e0ca                	sd	s2,64(sp)
    80003c8c:	fc4e                	sd	s3,56(sp)
    80003c8e:	f852                	sd	s4,48(sp)
    80003c90:	f456                	sd	s5,40(sp)
    80003c92:	f05a                	sd	s6,32(sp)
    80003c94:	ec5e                	sd	s7,24(sp)
    80003c96:	e862                	sd	s8,16(sp)
    80003c98:	e466                	sd	s9,8(sp)
    80003c9a:	e06a                	sd	s10,0(sp)
    80003c9c:	1080                	addi	s0,sp,96
    80003c9e:	84aa                	mv	s1,a0
    80003ca0:	8b2e                	mv	s6,a1
    80003ca2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ca4:	00054703          	lbu	a4,0(a0)
    80003ca8:	02f00793          	li	a5,47
    80003cac:	02f70363          	beq	a4,a5,80003cd2 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cb0:	ffffe097          	auipc	ra,0xffffe
    80003cb4:	d04080e7          	jalr	-764(ra) # 800019b4 <myproc>
    80003cb8:	15053503          	ld	a0,336(a0)
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	9f4080e7          	jalr	-1548(ra) # 800036b0 <idup>
    80003cc4:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cc6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cca:	4cb5                	li	s9,13
  len = path - s;
    80003ccc:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cce:	4c05                	li	s8,1
    80003cd0:	a87d                	j	80003d8e <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003cd2:	4585                	li	a1,1
    80003cd4:	4505                	li	a0,1
    80003cd6:	fffff097          	auipc	ra,0xfffff
    80003cda:	6de080e7          	jalr	1758(ra) # 800033b4 <iget>
    80003cde:	8a2a                	mv	s4,a0
    80003ce0:	b7dd                	j	80003cc6 <namex+0x44>
      iunlockput(ip);
    80003ce2:	8552                	mv	a0,s4
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	c6c080e7          	jalr	-916(ra) # 80003950 <iunlockput>
      return 0;
    80003cec:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cee:	8552                	mv	a0,s4
    80003cf0:	60e6                	ld	ra,88(sp)
    80003cf2:	6446                	ld	s0,80(sp)
    80003cf4:	64a6                	ld	s1,72(sp)
    80003cf6:	6906                	ld	s2,64(sp)
    80003cf8:	79e2                	ld	s3,56(sp)
    80003cfa:	7a42                	ld	s4,48(sp)
    80003cfc:	7aa2                	ld	s5,40(sp)
    80003cfe:	7b02                	ld	s6,32(sp)
    80003d00:	6be2                	ld	s7,24(sp)
    80003d02:	6c42                	ld	s8,16(sp)
    80003d04:	6ca2                	ld	s9,8(sp)
    80003d06:	6d02                	ld	s10,0(sp)
    80003d08:	6125                	addi	sp,sp,96
    80003d0a:	8082                	ret
      iunlock(ip);
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	aa2080e7          	jalr	-1374(ra) # 800037b0 <iunlock>
      return ip;
    80003d16:	bfe1                	j	80003cee <namex+0x6c>
      iunlockput(ip);
    80003d18:	8552                	mv	a0,s4
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	c36080e7          	jalr	-970(ra) # 80003950 <iunlockput>
      return 0;
    80003d22:	8a4e                	mv	s4,s3
    80003d24:	b7e9                	j	80003cee <namex+0x6c>
  len = path - s;
    80003d26:	40998633          	sub	a2,s3,s1
    80003d2a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d2e:	09acd863          	bge	s9,s10,80003dbe <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003d32:	4639                	li	a2,14
    80003d34:	85a6                	mv	a1,s1
    80003d36:	8556                	mv	a0,s5
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	ff6080e7          	jalr	-10(ra) # 80000d2e <memmove>
    80003d40:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d42:	0004c783          	lbu	a5,0(s1)
    80003d46:	01279763          	bne	a5,s2,80003d54 <namex+0xd2>
    path++;
    80003d4a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	ff278de3          	beq	a5,s2,80003d4a <namex+0xc8>
    ilock(ip);
    80003d54:	8552                	mv	a0,s4
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	998080e7          	jalr	-1640(ra) # 800036ee <ilock>
    if(ip->type != T_DIR){
    80003d5e:	044a1783          	lh	a5,68(s4)
    80003d62:	f98790e3          	bne	a5,s8,80003ce2 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d66:	000b0563          	beqz	s6,80003d70 <namex+0xee>
    80003d6a:	0004c783          	lbu	a5,0(s1)
    80003d6e:	dfd9                	beqz	a5,80003d0c <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d70:	865e                	mv	a2,s7
    80003d72:	85d6                	mv	a1,s5
    80003d74:	8552                	mv	a0,s4
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	e5c080e7          	jalr	-420(ra) # 80003bd2 <dirlookup>
    80003d7e:	89aa                	mv	s3,a0
    80003d80:	dd41                	beqz	a0,80003d18 <namex+0x96>
    iunlockput(ip);
    80003d82:	8552                	mv	a0,s4
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	bcc080e7          	jalr	-1076(ra) # 80003950 <iunlockput>
    ip = next;
    80003d8c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d8e:	0004c783          	lbu	a5,0(s1)
    80003d92:	01279763          	bne	a5,s2,80003da0 <namex+0x11e>
    path++;
    80003d96:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d98:	0004c783          	lbu	a5,0(s1)
    80003d9c:	ff278de3          	beq	a5,s2,80003d96 <namex+0x114>
  if(*path == 0)
    80003da0:	cb9d                	beqz	a5,80003dd6 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003da2:	0004c783          	lbu	a5,0(s1)
    80003da6:	89a6                	mv	s3,s1
  len = path - s;
    80003da8:	8d5e                	mv	s10,s7
    80003daa:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003dac:	01278963          	beq	a5,s2,80003dbe <namex+0x13c>
    80003db0:	dbbd                	beqz	a5,80003d26 <namex+0xa4>
    path++;
    80003db2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003db4:	0009c783          	lbu	a5,0(s3)
    80003db8:	ff279ce3          	bne	a5,s2,80003db0 <namex+0x12e>
    80003dbc:	b7ad                	j	80003d26 <namex+0xa4>
    memmove(name, s, len);
    80003dbe:	2601                	sext.w	a2,a2
    80003dc0:	85a6                	mv	a1,s1
    80003dc2:	8556                	mv	a0,s5
    80003dc4:	ffffd097          	auipc	ra,0xffffd
    80003dc8:	f6a080e7          	jalr	-150(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003dcc:	9d56                	add	s10,s10,s5
    80003dce:	000d0023          	sb	zero,0(s10)
    80003dd2:	84ce                	mv	s1,s3
    80003dd4:	b7bd                	j	80003d42 <namex+0xc0>
  if(nameiparent){
    80003dd6:	f00b0ce3          	beqz	s6,80003cee <namex+0x6c>
    iput(ip);
    80003dda:	8552                	mv	a0,s4
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	acc080e7          	jalr	-1332(ra) # 800038a8 <iput>
    return 0;
    80003de4:	4a01                	li	s4,0
    80003de6:	b721                	j	80003cee <namex+0x6c>

0000000080003de8 <dirlink>:
{
    80003de8:	7139                	addi	sp,sp,-64
    80003dea:	fc06                	sd	ra,56(sp)
    80003dec:	f822                	sd	s0,48(sp)
    80003dee:	f426                	sd	s1,40(sp)
    80003df0:	f04a                	sd	s2,32(sp)
    80003df2:	ec4e                	sd	s3,24(sp)
    80003df4:	e852                	sd	s4,16(sp)
    80003df6:	0080                	addi	s0,sp,64
    80003df8:	892a                	mv	s2,a0
    80003dfa:	8a2e                	mv	s4,a1
    80003dfc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dfe:	4601                	li	a2,0
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	dd2080e7          	jalr	-558(ra) # 80003bd2 <dirlookup>
    80003e08:	e93d                	bnez	a0,80003e7e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e0a:	04c92483          	lw	s1,76(s2)
    80003e0e:	c49d                	beqz	s1,80003e3c <dirlink+0x54>
    80003e10:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e12:	4741                	li	a4,16
    80003e14:	86a6                	mv	a3,s1
    80003e16:	fc040613          	addi	a2,s0,-64
    80003e1a:	4581                	li	a1,0
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	b84080e7          	jalr	-1148(ra) # 800039a2 <readi>
    80003e26:	47c1                	li	a5,16
    80003e28:	06f51163          	bne	a0,a5,80003e8a <dirlink+0xa2>
    if(de.inum == 0)
    80003e2c:	fc045783          	lhu	a5,-64(s0)
    80003e30:	c791                	beqz	a5,80003e3c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e32:	24c1                	addiw	s1,s1,16
    80003e34:	04c92783          	lw	a5,76(s2)
    80003e38:	fcf4ede3          	bltu	s1,a5,80003e12 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e3c:	4639                	li	a2,14
    80003e3e:	85d2                	mv	a1,s4
    80003e40:	fc240513          	addi	a0,s0,-62
    80003e44:	ffffd097          	auipc	ra,0xffffd
    80003e48:	f9a080e7          	jalr	-102(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003e4c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e50:	4741                	li	a4,16
    80003e52:	86a6                	mv	a3,s1
    80003e54:	fc040613          	addi	a2,s0,-64
    80003e58:	4581                	li	a1,0
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	c3e080e7          	jalr	-962(ra) # 80003a9a <writei>
    80003e64:	1541                	addi	a0,a0,-16
    80003e66:	00a03533          	snez	a0,a0
    80003e6a:	40a00533          	neg	a0,a0
}
    80003e6e:	70e2                	ld	ra,56(sp)
    80003e70:	7442                	ld	s0,48(sp)
    80003e72:	74a2                	ld	s1,40(sp)
    80003e74:	7902                	ld	s2,32(sp)
    80003e76:	69e2                	ld	s3,24(sp)
    80003e78:	6a42                	ld	s4,16(sp)
    80003e7a:	6121                	addi	sp,sp,64
    80003e7c:	8082                	ret
    iput(ip);
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	a2a080e7          	jalr	-1494(ra) # 800038a8 <iput>
    return -1;
    80003e86:	557d                	li	a0,-1
    80003e88:	b7dd                	j	80003e6e <dirlink+0x86>
      panic("dirlink read");
    80003e8a:	00004517          	auipc	a0,0x4
    80003e8e:	7ae50513          	addi	a0,a0,1966 # 80008638 <syscalls+0x1e8>
    80003e92:	ffffc097          	auipc	ra,0xffffc
    80003e96:	6ae080e7          	jalr	1710(ra) # 80000540 <panic>

0000000080003e9a <namei>:

struct inode*
namei(char *path)
{
    80003e9a:	1101                	addi	sp,sp,-32
    80003e9c:	ec06                	sd	ra,24(sp)
    80003e9e:	e822                	sd	s0,16(sp)
    80003ea0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ea2:	fe040613          	addi	a2,s0,-32
    80003ea6:	4581                	li	a1,0
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	dda080e7          	jalr	-550(ra) # 80003c82 <namex>
}
    80003eb0:	60e2                	ld	ra,24(sp)
    80003eb2:	6442                	ld	s0,16(sp)
    80003eb4:	6105                	addi	sp,sp,32
    80003eb6:	8082                	ret

0000000080003eb8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eb8:	1141                	addi	sp,sp,-16
    80003eba:	e406                	sd	ra,8(sp)
    80003ebc:	e022                	sd	s0,0(sp)
    80003ebe:	0800                	addi	s0,sp,16
    80003ec0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ec2:	4585                	li	a1,1
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	dbe080e7          	jalr	-578(ra) # 80003c82 <namex>
}
    80003ecc:	60a2                	ld	ra,8(sp)
    80003ece:	6402                	ld	s0,0(sp)
    80003ed0:	0141                	addi	sp,sp,16
    80003ed2:	8082                	ret

0000000080003ed4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ed4:	1101                	addi	sp,sp,-32
    80003ed6:	ec06                	sd	ra,24(sp)
    80003ed8:	e822                	sd	s0,16(sp)
    80003eda:	e426                	sd	s1,8(sp)
    80003edc:	e04a                	sd	s2,0(sp)
    80003ede:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ee0:	0001d917          	auipc	s2,0x1d
    80003ee4:	c6090913          	addi	s2,s2,-928 # 80020b40 <log>
    80003ee8:	01892583          	lw	a1,24(s2)
    80003eec:	02892503          	lw	a0,40(s2)
    80003ef0:	fffff097          	auipc	ra,0xfffff
    80003ef4:	fe6080e7          	jalr	-26(ra) # 80002ed6 <bread>
    80003ef8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003efa:	02c92683          	lw	a3,44(s2)
    80003efe:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f00:	02d05863          	blez	a3,80003f30 <write_head+0x5c>
    80003f04:	0001d797          	auipc	a5,0x1d
    80003f08:	c6c78793          	addi	a5,a5,-916 # 80020b70 <log+0x30>
    80003f0c:	05c50713          	addi	a4,a0,92
    80003f10:	36fd                	addiw	a3,a3,-1
    80003f12:	02069613          	slli	a2,a3,0x20
    80003f16:	01e65693          	srli	a3,a2,0x1e
    80003f1a:	0001d617          	auipc	a2,0x1d
    80003f1e:	c5a60613          	addi	a2,a2,-934 # 80020b74 <log+0x34>
    80003f22:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f24:	4390                	lw	a2,0(a5)
    80003f26:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f28:	0791                	addi	a5,a5,4
    80003f2a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003f2c:	fed79ce3          	bne	a5,a3,80003f24 <write_head+0x50>
  }
  bwrite(buf);
    80003f30:	8526                	mv	a0,s1
    80003f32:	fffff097          	auipc	ra,0xfffff
    80003f36:	096080e7          	jalr	150(ra) # 80002fc8 <bwrite>
  brelse(buf);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	0ca080e7          	jalr	202(ra) # 80003006 <brelse>
}
    80003f44:	60e2                	ld	ra,24(sp)
    80003f46:	6442                	ld	s0,16(sp)
    80003f48:	64a2                	ld	s1,8(sp)
    80003f4a:	6902                	ld	s2,0(sp)
    80003f4c:	6105                	addi	sp,sp,32
    80003f4e:	8082                	ret

0000000080003f50 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f50:	0001d797          	auipc	a5,0x1d
    80003f54:	c1c7a783          	lw	a5,-996(a5) # 80020b6c <log+0x2c>
    80003f58:	0af05d63          	blez	a5,80004012 <install_trans+0xc2>
{
    80003f5c:	7139                	addi	sp,sp,-64
    80003f5e:	fc06                	sd	ra,56(sp)
    80003f60:	f822                	sd	s0,48(sp)
    80003f62:	f426                	sd	s1,40(sp)
    80003f64:	f04a                	sd	s2,32(sp)
    80003f66:	ec4e                	sd	s3,24(sp)
    80003f68:	e852                	sd	s4,16(sp)
    80003f6a:	e456                	sd	s5,8(sp)
    80003f6c:	e05a                	sd	s6,0(sp)
    80003f6e:	0080                	addi	s0,sp,64
    80003f70:	8b2a                	mv	s6,a0
    80003f72:	0001da97          	auipc	s5,0x1d
    80003f76:	bfea8a93          	addi	s5,s5,-1026 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f7a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f7c:	0001d997          	auipc	s3,0x1d
    80003f80:	bc498993          	addi	s3,s3,-1084 # 80020b40 <log>
    80003f84:	a00d                	j	80003fa6 <install_trans+0x56>
    brelse(lbuf);
    80003f86:	854a                	mv	a0,s2
    80003f88:	fffff097          	auipc	ra,0xfffff
    80003f8c:	07e080e7          	jalr	126(ra) # 80003006 <brelse>
    brelse(dbuf);
    80003f90:	8526                	mv	a0,s1
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	074080e7          	jalr	116(ra) # 80003006 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f9a:	2a05                	addiw	s4,s4,1
    80003f9c:	0a91                	addi	s5,s5,4
    80003f9e:	02c9a783          	lw	a5,44(s3)
    80003fa2:	04fa5e63          	bge	s4,a5,80003ffe <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fa6:	0189a583          	lw	a1,24(s3)
    80003faa:	014585bb          	addw	a1,a1,s4
    80003fae:	2585                	addiw	a1,a1,1
    80003fb0:	0289a503          	lw	a0,40(s3)
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	f22080e7          	jalr	-222(ra) # 80002ed6 <bread>
    80003fbc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fbe:	000aa583          	lw	a1,0(s5)
    80003fc2:	0289a503          	lw	a0,40(s3)
    80003fc6:	fffff097          	auipc	ra,0xfffff
    80003fca:	f10080e7          	jalr	-240(ra) # 80002ed6 <bread>
    80003fce:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fd0:	40000613          	li	a2,1024
    80003fd4:	05890593          	addi	a1,s2,88
    80003fd8:	05850513          	addi	a0,a0,88
    80003fdc:	ffffd097          	auipc	ra,0xffffd
    80003fe0:	d52080e7          	jalr	-686(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	fffff097          	auipc	ra,0xfffff
    80003fea:	fe2080e7          	jalr	-30(ra) # 80002fc8 <bwrite>
    if(recovering == 0)
    80003fee:	f80b1ce3          	bnez	s6,80003f86 <install_trans+0x36>
      bunpin(dbuf);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	fffff097          	auipc	ra,0xfffff
    80003ff8:	0ec080e7          	jalr	236(ra) # 800030e0 <bunpin>
    80003ffc:	b769                	j	80003f86 <install_trans+0x36>
}
    80003ffe:	70e2                	ld	ra,56(sp)
    80004000:	7442                	ld	s0,48(sp)
    80004002:	74a2                	ld	s1,40(sp)
    80004004:	7902                	ld	s2,32(sp)
    80004006:	69e2                	ld	s3,24(sp)
    80004008:	6a42                	ld	s4,16(sp)
    8000400a:	6aa2                	ld	s5,8(sp)
    8000400c:	6b02                	ld	s6,0(sp)
    8000400e:	6121                	addi	sp,sp,64
    80004010:	8082                	ret
    80004012:	8082                	ret

0000000080004014 <initlog>:
{
    80004014:	7179                	addi	sp,sp,-48
    80004016:	f406                	sd	ra,40(sp)
    80004018:	f022                	sd	s0,32(sp)
    8000401a:	ec26                	sd	s1,24(sp)
    8000401c:	e84a                	sd	s2,16(sp)
    8000401e:	e44e                	sd	s3,8(sp)
    80004020:	1800                	addi	s0,sp,48
    80004022:	892a                	mv	s2,a0
    80004024:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004026:	0001d497          	auipc	s1,0x1d
    8000402a:	b1a48493          	addi	s1,s1,-1254 # 80020b40 <log>
    8000402e:	00004597          	auipc	a1,0x4
    80004032:	61a58593          	addi	a1,a1,1562 # 80008648 <syscalls+0x1f8>
    80004036:	8526                	mv	a0,s1
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	b0e080e7          	jalr	-1266(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004040:	0149a583          	lw	a1,20(s3)
    80004044:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004046:	0109a783          	lw	a5,16(s3)
    8000404a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000404c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004050:	854a                	mv	a0,s2
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	e84080e7          	jalr	-380(ra) # 80002ed6 <bread>
  log.lh.n = lh->n;
    8000405a:	4d34                	lw	a3,88(a0)
    8000405c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000405e:	02d05663          	blez	a3,8000408a <initlog+0x76>
    80004062:	05c50793          	addi	a5,a0,92
    80004066:	0001d717          	auipc	a4,0x1d
    8000406a:	b0a70713          	addi	a4,a4,-1270 # 80020b70 <log+0x30>
    8000406e:	36fd                	addiw	a3,a3,-1
    80004070:	02069613          	slli	a2,a3,0x20
    80004074:	01e65693          	srli	a3,a2,0x1e
    80004078:	06050613          	addi	a2,a0,96
    8000407c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000407e:	4390                	lw	a2,0(a5)
    80004080:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004082:	0791                	addi	a5,a5,4
    80004084:	0711                	addi	a4,a4,4
    80004086:	fed79ce3          	bne	a5,a3,8000407e <initlog+0x6a>
  brelse(buf);
    8000408a:	fffff097          	auipc	ra,0xfffff
    8000408e:	f7c080e7          	jalr	-132(ra) # 80003006 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004092:	4505                	li	a0,1
    80004094:	00000097          	auipc	ra,0x0
    80004098:	ebc080e7          	jalr	-324(ra) # 80003f50 <install_trans>
  log.lh.n = 0;
    8000409c:	0001d797          	auipc	a5,0x1d
    800040a0:	ac07a823          	sw	zero,-1328(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	e30080e7          	jalr	-464(ra) # 80003ed4 <write_head>
}
    800040ac:	70a2                	ld	ra,40(sp)
    800040ae:	7402                	ld	s0,32(sp)
    800040b0:	64e2                	ld	s1,24(sp)
    800040b2:	6942                	ld	s2,16(sp)
    800040b4:	69a2                	ld	s3,8(sp)
    800040b6:	6145                	addi	sp,sp,48
    800040b8:	8082                	ret

00000000800040ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040ba:	1101                	addi	sp,sp,-32
    800040bc:	ec06                	sd	ra,24(sp)
    800040be:	e822                	sd	s0,16(sp)
    800040c0:	e426                	sd	s1,8(sp)
    800040c2:	e04a                	sd	s2,0(sp)
    800040c4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040c6:	0001d517          	auipc	a0,0x1d
    800040ca:	a7a50513          	addi	a0,a0,-1414 # 80020b40 <log>
    800040ce:	ffffd097          	auipc	ra,0xffffd
    800040d2:	b08080e7          	jalr	-1272(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800040d6:	0001d497          	auipc	s1,0x1d
    800040da:	a6a48493          	addi	s1,s1,-1430 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040de:	4979                	li	s2,30
    800040e0:	a039                	j	800040ee <begin_op+0x34>
      sleep(&log, &log.lock);
    800040e2:	85a6                	mv	a1,s1
    800040e4:	8526                	mv	a0,s1
    800040e6:	ffffe097          	auipc	ra,0xffffe
    800040ea:	f76080e7          	jalr	-138(ra) # 8000205c <sleep>
    if(log.committing){
    800040ee:	50dc                	lw	a5,36(s1)
    800040f0:	fbed                	bnez	a5,800040e2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040f2:	5098                	lw	a4,32(s1)
    800040f4:	2705                	addiw	a4,a4,1
    800040f6:	0007069b          	sext.w	a3,a4
    800040fa:	0027179b          	slliw	a5,a4,0x2
    800040fe:	9fb9                	addw	a5,a5,a4
    80004100:	0017979b          	slliw	a5,a5,0x1
    80004104:	54d8                	lw	a4,44(s1)
    80004106:	9fb9                	addw	a5,a5,a4
    80004108:	00f95963          	bge	s2,a5,8000411a <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000410c:	85a6                	mv	a1,s1
    8000410e:	8526                	mv	a0,s1
    80004110:	ffffe097          	auipc	ra,0xffffe
    80004114:	f4c080e7          	jalr	-180(ra) # 8000205c <sleep>
    80004118:	bfd9                	j	800040ee <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000411a:	0001d517          	auipc	a0,0x1d
    8000411e:	a2650513          	addi	a0,a0,-1498 # 80020b40 <log>
    80004122:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	b66080e7          	jalr	-1178(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000412c:	60e2                	ld	ra,24(sp)
    8000412e:	6442                	ld	s0,16(sp)
    80004130:	64a2                	ld	s1,8(sp)
    80004132:	6902                	ld	s2,0(sp)
    80004134:	6105                	addi	sp,sp,32
    80004136:	8082                	ret

0000000080004138 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004138:	7139                	addi	sp,sp,-64
    8000413a:	fc06                	sd	ra,56(sp)
    8000413c:	f822                	sd	s0,48(sp)
    8000413e:	f426                	sd	s1,40(sp)
    80004140:	f04a                	sd	s2,32(sp)
    80004142:	ec4e                	sd	s3,24(sp)
    80004144:	e852                	sd	s4,16(sp)
    80004146:	e456                	sd	s5,8(sp)
    80004148:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000414a:	0001d497          	auipc	s1,0x1d
    8000414e:	9f648493          	addi	s1,s1,-1546 # 80020b40 <log>
    80004152:	8526                	mv	a0,s1
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	a82080e7          	jalr	-1406(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000415c:	509c                	lw	a5,32(s1)
    8000415e:	37fd                	addiw	a5,a5,-1
    80004160:	0007891b          	sext.w	s2,a5
    80004164:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004166:	50dc                	lw	a5,36(s1)
    80004168:	e7b9                	bnez	a5,800041b6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000416a:	04091e63          	bnez	s2,800041c6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000416e:	0001d497          	auipc	s1,0x1d
    80004172:	9d248493          	addi	s1,s1,-1582 # 80020b40 <log>
    80004176:	4785                	li	a5,1
    80004178:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000417a:	8526                	mv	a0,s1
    8000417c:	ffffd097          	auipc	ra,0xffffd
    80004180:	b0e080e7          	jalr	-1266(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004184:	54dc                	lw	a5,44(s1)
    80004186:	06f04763          	bgtz	a5,800041f4 <end_op+0xbc>
    acquire(&log.lock);
    8000418a:	0001d497          	auipc	s1,0x1d
    8000418e:	9b648493          	addi	s1,s1,-1610 # 80020b40 <log>
    80004192:	8526                	mv	a0,s1
    80004194:	ffffd097          	auipc	ra,0xffffd
    80004198:	a42080e7          	jalr	-1470(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000419c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041a0:	8526                	mv	a0,s1
    800041a2:	ffffe097          	auipc	ra,0xffffe
    800041a6:	f1e080e7          	jalr	-226(ra) # 800020c0 <wakeup>
    release(&log.lock);
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	ade080e7          	jalr	-1314(ra) # 80000c8a <release>
}
    800041b4:	a03d                	j	800041e2 <end_op+0xaa>
    panic("log.committing");
    800041b6:	00004517          	auipc	a0,0x4
    800041ba:	49a50513          	addi	a0,a0,1178 # 80008650 <syscalls+0x200>
    800041be:	ffffc097          	auipc	ra,0xffffc
    800041c2:	382080e7          	jalr	898(ra) # 80000540 <panic>
    wakeup(&log);
    800041c6:	0001d497          	auipc	s1,0x1d
    800041ca:	97a48493          	addi	s1,s1,-1670 # 80020b40 <log>
    800041ce:	8526                	mv	a0,s1
    800041d0:	ffffe097          	auipc	ra,0xffffe
    800041d4:	ef0080e7          	jalr	-272(ra) # 800020c0 <wakeup>
  release(&log.lock);
    800041d8:	8526                	mv	a0,s1
    800041da:	ffffd097          	auipc	ra,0xffffd
    800041de:	ab0080e7          	jalr	-1360(ra) # 80000c8a <release>
}
    800041e2:	70e2                	ld	ra,56(sp)
    800041e4:	7442                	ld	s0,48(sp)
    800041e6:	74a2                	ld	s1,40(sp)
    800041e8:	7902                	ld	s2,32(sp)
    800041ea:	69e2                	ld	s3,24(sp)
    800041ec:	6a42                	ld	s4,16(sp)
    800041ee:	6aa2                	ld	s5,8(sp)
    800041f0:	6121                	addi	sp,sp,64
    800041f2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f4:	0001da97          	auipc	s5,0x1d
    800041f8:	97ca8a93          	addi	s5,s5,-1668 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041fc:	0001da17          	auipc	s4,0x1d
    80004200:	944a0a13          	addi	s4,s4,-1724 # 80020b40 <log>
    80004204:	018a2583          	lw	a1,24(s4)
    80004208:	012585bb          	addw	a1,a1,s2
    8000420c:	2585                	addiw	a1,a1,1
    8000420e:	028a2503          	lw	a0,40(s4)
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	cc4080e7          	jalr	-828(ra) # 80002ed6 <bread>
    8000421a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000421c:	000aa583          	lw	a1,0(s5)
    80004220:	028a2503          	lw	a0,40(s4)
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	cb2080e7          	jalr	-846(ra) # 80002ed6 <bread>
    8000422c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000422e:	40000613          	li	a2,1024
    80004232:	05850593          	addi	a1,a0,88
    80004236:	05848513          	addi	a0,s1,88
    8000423a:	ffffd097          	auipc	ra,0xffffd
    8000423e:	af4080e7          	jalr	-1292(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004242:	8526                	mv	a0,s1
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	d84080e7          	jalr	-636(ra) # 80002fc8 <bwrite>
    brelse(from);
    8000424c:	854e                	mv	a0,s3
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	db8080e7          	jalr	-584(ra) # 80003006 <brelse>
    brelse(to);
    80004256:	8526                	mv	a0,s1
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	dae080e7          	jalr	-594(ra) # 80003006 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004260:	2905                	addiw	s2,s2,1
    80004262:	0a91                	addi	s5,s5,4
    80004264:	02ca2783          	lw	a5,44(s4)
    80004268:	f8f94ee3          	blt	s2,a5,80004204 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000426c:	00000097          	auipc	ra,0x0
    80004270:	c68080e7          	jalr	-920(ra) # 80003ed4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004274:	4501                	li	a0,0
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	cda080e7          	jalr	-806(ra) # 80003f50 <install_trans>
    log.lh.n = 0;
    8000427e:	0001d797          	auipc	a5,0x1d
    80004282:	8e07a723          	sw	zero,-1810(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004286:	00000097          	auipc	ra,0x0
    8000428a:	c4e080e7          	jalr	-946(ra) # 80003ed4 <write_head>
    8000428e:	bdf5                	j	8000418a <end_op+0x52>

0000000080004290 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004290:	1101                	addi	sp,sp,-32
    80004292:	ec06                	sd	ra,24(sp)
    80004294:	e822                	sd	s0,16(sp)
    80004296:	e426                	sd	s1,8(sp)
    80004298:	e04a                	sd	s2,0(sp)
    8000429a:	1000                	addi	s0,sp,32
    8000429c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000429e:	0001d917          	auipc	s2,0x1d
    800042a2:	8a290913          	addi	s2,s2,-1886 # 80020b40 <log>
    800042a6:	854a                	mv	a0,s2
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	92e080e7          	jalr	-1746(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042b0:	02c92603          	lw	a2,44(s2)
    800042b4:	47f5                	li	a5,29
    800042b6:	06c7c563          	blt	a5,a2,80004320 <log_write+0x90>
    800042ba:	0001d797          	auipc	a5,0x1d
    800042be:	8a27a783          	lw	a5,-1886(a5) # 80020b5c <log+0x1c>
    800042c2:	37fd                	addiw	a5,a5,-1
    800042c4:	04f65e63          	bge	a2,a5,80004320 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042c8:	0001d797          	auipc	a5,0x1d
    800042cc:	8987a783          	lw	a5,-1896(a5) # 80020b60 <log+0x20>
    800042d0:	06f05063          	blez	a5,80004330 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042d4:	4781                	li	a5,0
    800042d6:	06c05563          	blez	a2,80004340 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042da:	44cc                	lw	a1,12(s1)
    800042dc:	0001d717          	auipc	a4,0x1d
    800042e0:	89470713          	addi	a4,a4,-1900 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042e6:	4314                	lw	a3,0(a4)
    800042e8:	04b68c63          	beq	a3,a1,80004340 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042ec:	2785                	addiw	a5,a5,1
    800042ee:	0711                	addi	a4,a4,4
    800042f0:	fef61be3          	bne	a2,a5,800042e6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042f4:	0621                	addi	a2,a2,8
    800042f6:	060a                	slli	a2,a2,0x2
    800042f8:	0001d797          	auipc	a5,0x1d
    800042fc:	84878793          	addi	a5,a5,-1976 # 80020b40 <log>
    80004300:	97b2                	add	a5,a5,a2
    80004302:	44d8                	lw	a4,12(s1)
    80004304:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004306:	8526                	mv	a0,s1
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	d9c080e7          	jalr	-612(ra) # 800030a4 <bpin>
    log.lh.n++;
    80004310:	0001d717          	auipc	a4,0x1d
    80004314:	83070713          	addi	a4,a4,-2000 # 80020b40 <log>
    80004318:	575c                	lw	a5,44(a4)
    8000431a:	2785                	addiw	a5,a5,1
    8000431c:	d75c                	sw	a5,44(a4)
    8000431e:	a82d                	j	80004358 <log_write+0xc8>
    panic("too big a transaction");
    80004320:	00004517          	auipc	a0,0x4
    80004324:	34050513          	addi	a0,a0,832 # 80008660 <syscalls+0x210>
    80004328:	ffffc097          	auipc	ra,0xffffc
    8000432c:	218080e7          	jalr	536(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004330:	00004517          	auipc	a0,0x4
    80004334:	34850513          	addi	a0,a0,840 # 80008678 <syscalls+0x228>
    80004338:	ffffc097          	auipc	ra,0xffffc
    8000433c:	208080e7          	jalr	520(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004340:	00878693          	addi	a3,a5,8
    80004344:	068a                	slli	a3,a3,0x2
    80004346:	0001c717          	auipc	a4,0x1c
    8000434a:	7fa70713          	addi	a4,a4,2042 # 80020b40 <log>
    8000434e:	9736                	add	a4,a4,a3
    80004350:	44d4                	lw	a3,12(s1)
    80004352:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004354:	faf609e3          	beq	a2,a5,80004306 <log_write+0x76>
  }
  release(&log.lock);
    80004358:	0001c517          	auipc	a0,0x1c
    8000435c:	7e850513          	addi	a0,a0,2024 # 80020b40 <log>
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
}
    80004368:	60e2                	ld	ra,24(sp)
    8000436a:	6442                	ld	s0,16(sp)
    8000436c:	64a2                	ld	s1,8(sp)
    8000436e:	6902                	ld	s2,0(sp)
    80004370:	6105                	addi	sp,sp,32
    80004372:	8082                	ret

0000000080004374 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004374:	1101                	addi	sp,sp,-32
    80004376:	ec06                	sd	ra,24(sp)
    80004378:	e822                	sd	s0,16(sp)
    8000437a:	e426                	sd	s1,8(sp)
    8000437c:	e04a                	sd	s2,0(sp)
    8000437e:	1000                	addi	s0,sp,32
    80004380:	84aa                	mv	s1,a0
    80004382:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004384:	00004597          	auipc	a1,0x4
    80004388:	31458593          	addi	a1,a1,788 # 80008698 <syscalls+0x248>
    8000438c:	0521                	addi	a0,a0,8
    8000438e:	ffffc097          	auipc	ra,0xffffc
    80004392:	7b8080e7          	jalr	1976(ra) # 80000b46 <initlock>
  lk->name = name;
    80004396:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000439a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000439e:	0204a423          	sw	zero,40(s1)
}
    800043a2:	60e2                	ld	ra,24(sp)
    800043a4:	6442                	ld	s0,16(sp)
    800043a6:	64a2                	ld	s1,8(sp)
    800043a8:	6902                	ld	s2,0(sp)
    800043aa:	6105                	addi	sp,sp,32
    800043ac:	8082                	ret

00000000800043ae <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043ae:	1101                	addi	sp,sp,-32
    800043b0:	ec06                	sd	ra,24(sp)
    800043b2:	e822                	sd	s0,16(sp)
    800043b4:	e426                	sd	s1,8(sp)
    800043b6:	e04a                	sd	s2,0(sp)
    800043b8:	1000                	addi	s0,sp,32
    800043ba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043bc:	00850913          	addi	s2,a0,8
    800043c0:	854a                	mv	a0,s2
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	814080e7          	jalr	-2028(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800043ca:	409c                	lw	a5,0(s1)
    800043cc:	cb89                	beqz	a5,800043de <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043ce:	85ca                	mv	a1,s2
    800043d0:	8526                	mv	a0,s1
    800043d2:	ffffe097          	auipc	ra,0xffffe
    800043d6:	c8a080e7          	jalr	-886(ra) # 8000205c <sleep>
  while (lk->locked) {
    800043da:	409c                	lw	a5,0(s1)
    800043dc:	fbed                	bnez	a5,800043ce <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043de:	4785                	li	a5,1
    800043e0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	5d2080e7          	jalr	1490(ra) # 800019b4 <myproc>
    800043ea:	591c                	lw	a5,48(a0)
    800043ec:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043ee:	854a                	mv	a0,s2
    800043f0:	ffffd097          	auipc	ra,0xffffd
    800043f4:	89a080e7          	jalr	-1894(ra) # 80000c8a <release>
}
    800043f8:	60e2                	ld	ra,24(sp)
    800043fa:	6442                	ld	s0,16(sp)
    800043fc:	64a2                	ld	s1,8(sp)
    800043fe:	6902                	ld	s2,0(sp)
    80004400:	6105                	addi	sp,sp,32
    80004402:	8082                	ret

0000000080004404 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004404:	1101                	addi	sp,sp,-32
    80004406:	ec06                	sd	ra,24(sp)
    80004408:	e822                	sd	s0,16(sp)
    8000440a:	e426                	sd	s1,8(sp)
    8000440c:	e04a                	sd	s2,0(sp)
    8000440e:	1000                	addi	s0,sp,32
    80004410:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004412:	00850913          	addi	s2,a0,8
    80004416:	854a                	mv	a0,s2
    80004418:	ffffc097          	auipc	ra,0xffffc
    8000441c:	7be080e7          	jalr	1982(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004420:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004424:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004428:	8526                	mv	a0,s1
    8000442a:	ffffe097          	auipc	ra,0xffffe
    8000442e:	c96080e7          	jalr	-874(ra) # 800020c0 <wakeup>
  release(&lk->lk);
    80004432:	854a                	mv	a0,s2
    80004434:	ffffd097          	auipc	ra,0xffffd
    80004438:	856080e7          	jalr	-1962(ra) # 80000c8a <release>
}
    8000443c:	60e2                	ld	ra,24(sp)
    8000443e:	6442                	ld	s0,16(sp)
    80004440:	64a2                	ld	s1,8(sp)
    80004442:	6902                	ld	s2,0(sp)
    80004444:	6105                	addi	sp,sp,32
    80004446:	8082                	ret

0000000080004448 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004448:	7179                	addi	sp,sp,-48
    8000444a:	f406                	sd	ra,40(sp)
    8000444c:	f022                	sd	s0,32(sp)
    8000444e:	ec26                	sd	s1,24(sp)
    80004450:	e84a                	sd	s2,16(sp)
    80004452:	e44e                	sd	s3,8(sp)
    80004454:	1800                	addi	s0,sp,48
    80004456:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004458:	00850913          	addi	s2,a0,8
    8000445c:	854a                	mv	a0,s2
    8000445e:	ffffc097          	auipc	ra,0xffffc
    80004462:	778080e7          	jalr	1912(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004466:	409c                	lw	a5,0(s1)
    80004468:	ef99                	bnez	a5,80004486 <holdingsleep+0x3e>
    8000446a:	4481                	li	s1,0
  release(&lk->lk);
    8000446c:	854a                	mv	a0,s2
    8000446e:	ffffd097          	auipc	ra,0xffffd
    80004472:	81c080e7          	jalr	-2020(ra) # 80000c8a <release>
  return r;
}
    80004476:	8526                	mv	a0,s1
    80004478:	70a2                	ld	ra,40(sp)
    8000447a:	7402                	ld	s0,32(sp)
    8000447c:	64e2                	ld	s1,24(sp)
    8000447e:	6942                	ld	s2,16(sp)
    80004480:	69a2                	ld	s3,8(sp)
    80004482:	6145                	addi	sp,sp,48
    80004484:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004486:	0284a983          	lw	s3,40(s1)
    8000448a:	ffffd097          	auipc	ra,0xffffd
    8000448e:	52a080e7          	jalr	1322(ra) # 800019b4 <myproc>
    80004492:	5904                	lw	s1,48(a0)
    80004494:	413484b3          	sub	s1,s1,s3
    80004498:	0014b493          	seqz	s1,s1
    8000449c:	bfc1                	j	8000446c <holdingsleep+0x24>

000000008000449e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000449e:	1141                	addi	sp,sp,-16
    800044a0:	e406                	sd	ra,8(sp)
    800044a2:	e022                	sd	s0,0(sp)
    800044a4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044a6:	00004597          	auipc	a1,0x4
    800044aa:	20258593          	addi	a1,a1,514 # 800086a8 <syscalls+0x258>
    800044ae:	0001c517          	auipc	a0,0x1c
    800044b2:	7da50513          	addi	a0,a0,2010 # 80020c88 <ftable>
    800044b6:	ffffc097          	auipc	ra,0xffffc
    800044ba:	690080e7          	jalr	1680(ra) # 80000b46 <initlock>
}
    800044be:	60a2                	ld	ra,8(sp)
    800044c0:	6402                	ld	s0,0(sp)
    800044c2:	0141                	addi	sp,sp,16
    800044c4:	8082                	ret

00000000800044c6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044c6:	1101                	addi	sp,sp,-32
    800044c8:	ec06                	sd	ra,24(sp)
    800044ca:	e822                	sd	s0,16(sp)
    800044cc:	e426                	sd	s1,8(sp)
    800044ce:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044d0:	0001c517          	auipc	a0,0x1c
    800044d4:	7b850513          	addi	a0,a0,1976 # 80020c88 <ftable>
    800044d8:	ffffc097          	auipc	ra,0xffffc
    800044dc:	6fe080e7          	jalr	1790(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044e0:	0001c497          	auipc	s1,0x1c
    800044e4:	7c048493          	addi	s1,s1,1984 # 80020ca0 <ftable+0x18>
    800044e8:	0001d717          	auipc	a4,0x1d
    800044ec:	75870713          	addi	a4,a4,1880 # 80021c40 <disk>
    if(f->ref == 0){
    800044f0:	40dc                	lw	a5,4(s1)
    800044f2:	cf99                	beqz	a5,80004510 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044f4:	02848493          	addi	s1,s1,40
    800044f8:	fee49ce3          	bne	s1,a4,800044f0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044fc:	0001c517          	auipc	a0,0x1c
    80004500:	78c50513          	addi	a0,a0,1932 # 80020c88 <ftable>
    80004504:	ffffc097          	auipc	ra,0xffffc
    80004508:	786080e7          	jalr	1926(ra) # 80000c8a <release>
  return 0;
    8000450c:	4481                	li	s1,0
    8000450e:	a819                	j	80004524 <filealloc+0x5e>
      f->ref = 1;
    80004510:	4785                	li	a5,1
    80004512:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004514:	0001c517          	auipc	a0,0x1c
    80004518:	77450513          	addi	a0,a0,1908 # 80020c88 <ftable>
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	76e080e7          	jalr	1902(ra) # 80000c8a <release>
}
    80004524:	8526                	mv	a0,s1
    80004526:	60e2                	ld	ra,24(sp)
    80004528:	6442                	ld	s0,16(sp)
    8000452a:	64a2                	ld	s1,8(sp)
    8000452c:	6105                	addi	sp,sp,32
    8000452e:	8082                	ret

0000000080004530 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004530:	1101                	addi	sp,sp,-32
    80004532:	ec06                	sd	ra,24(sp)
    80004534:	e822                	sd	s0,16(sp)
    80004536:	e426                	sd	s1,8(sp)
    80004538:	1000                	addi	s0,sp,32
    8000453a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000453c:	0001c517          	auipc	a0,0x1c
    80004540:	74c50513          	addi	a0,a0,1868 # 80020c88 <ftable>
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	692080e7          	jalr	1682(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000454c:	40dc                	lw	a5,4(s1)
    8000454e:	02f05263          	blez	a5,80004572 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004552:	2785                	addiw	a5,a5,1
    80004554:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004556:	0001c517          	auipc	a0,0x1c
    8000455a:	73250513          	addi	a0,a0,1842 # 80020c88 <ftable>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	72c080e7          	jalr	1836(ra) # 80000c8a <release>
  return f;
}
    80004566:	8526                	mv	a0,s1
    80004568:	60e2                	ld	ra,24(sp)
    8000456a:	6442                	ld	s0,16(sp)
    8000456c:	64a2                	ld	s1,8(sp)
    8000456e:	6105                	addi	sp,sp,32
    80004570:	8082                	ret
    panic("filedup");
    80004572:	00004517          	auipc	a0,0x4
    80004576:	13e50513          	addi	a0,a0,318 # 800086b0 <syscalls+0x260>
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	fc6080e7          	jalr	-58(ra) # 80000540 <panic>

0000000080004582 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004582:	7139                	addi	sp,sp,-64
    80004584:	fc06                	sd	ra,56(sp)
    80004586:	f822                	sd	s0,48(sp)
    80004588:	f426                	sd	s1,40(sp)
    8000458a:	f04a                	sd	s2,32(sp)
    8000458c:	ec4e                	sd	s3,24(sp)
    8000458e:	e852                	sd	s4,16(sp)
    80004590:	e456                	sd	s5,8(sp)
    80004592:	0080                	addi	s0,sp,64
    80004594:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004596:	0001c517          	auipc	a0,0x1c
    8000459a:	6f250513          	addi	a0,a0,1778 # 80020c88 <ftable>
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	638080e7          	jalr	1592(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800045a6:	40dc                	lw	a5,4(s1)
    800045a8:	06f05163          	blez	a5,8000460a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045ac:	37fd                	addiw	a5,a5,-1
    800045ae:	0007871b          	sext.w	a4,a5
    800045b2:	c0dc                	sw	a5,4(s1)
    800045b4:	06e04363          	bgtz	a4,8000461a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045b8:	0004a903          	lw	s2,0(s1)
    800045bc:	0094ca83          	lbu	s5,9(s1)
    800045c0:	0104ba03          	ld	s4,16(s1)
    800045c4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045c8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045cc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045d0:	0001c517          	auipc	a0,0x1c
    800045d4:	6b850513          	addi	a0,a0,1720 # 80020c88 <ftable>
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	6b2080e7          	jalr	1714(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800045e0:	4785                	li	a5,1
    800045e2:	04f90d63          	beq	s2,a5,8000463c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045e6:	3979                	addiw	s2,s2,-2
    800045e8:	4785                	li	a5,1
    800045ea:	0527e063          	bltu	a5,s2,8000462a <fileclose+0xa8>
    begin_op();
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	acc080e7          	jalr	-1332(ra) # 800040ba <begin_op>
    iput(ff.ip);
    800045f6:	854e                	mv	a0,s3
    800045f8:	fffff097          	auipc	ra,0xfffff
    800045fc:	2b0080e7          	jalr	688(ra) # 800038a8 <iput>
    end_op();
    80004600:	00000097          	auipc	ra,0x0
    80004604:	b38080e7          	jalr	-1224(ra) # 80004138 <end_op>
    80004608:	a00d                	j	8000462a <fileclose+0xa8>
    panic("fileclose");
    8000460a:	00004517          	auipc	a0,0x4
    8000460e:	0ae50513          	addi	a0,a0,174 # 800086b8 <syscalls+0x268>
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	f2e080e7          	jalr	-210(ra) # 80000540 <panic>
    release(&ftable.lock);
    8000461a:	0001c517          	auipc	a0,0x1c
    8000461e:	66e50513          	addi	a0,a0,1646 # 80020c88 <ftable>
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	668080e7          	jalr	1640(ra) # 80000c8a <release>
  }
}
    8000462a:	70e2                	ld	ra,56(sp)
    8000462c:	7442                	ld	s0,48(sp)
    8000462e:	74a2                	ld	s1,40(sp)
    80004630:	7902                	ld	s2,32(sp)
    80004632:	69e2                	ld	s3,24(sp)
    80004634:	6a42                	ld	s4,16(sp)
    80004636:	6aa2                	ld	s5,8(sp)
    80004638:	6121                	addi	sp,sp,64
    8000463a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000463c:	85d6                	mv	a1,s5
    8000463e:	8552                	mv	a0,s4
    80004640:	00000097          	auipc	ra,0x0
    80004644:	34c080e7          	jalr	844(ra) # 8000498c <pipeclose>
    80004648:	b7cd                	j	8000462a <fileclose+0xa8>

000000008000464a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000464a:	715d                	addi	sp,sp,-80
    8000464c:	e486                	sd	ra,72(sp)
    8000464e:	e0a2                	sd	s0,64(sp)
    80004650:	fc26                	sd	s1,56(sp)
    80004652:	f84a                	sd	s2,48(sp)
    80004654:	f44e                	sd	s3,40(sp)
    80004656:	0880                	addi	s0,sp,80
    80004658:	84aa                	mv	s1,a0
    8000465a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000465c:	ffffd097          	auipc	ra,0xffffd
    80004660:	358080e7          	jalr	856(ra) # 800019b4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004664:	409c                	lw	a5,0(s1)
    80004666:	37f9                	addiw	a5,a5,-2
    80004668:	4705                	li	a4,1
    8000466a:	04f76763          	bltu	a4,a5,800046b8 <filestat+0x6e>
    8000466e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004670:	6c88                	ld	a0,24(s1)
    80004672:	fffff097          	auipc	ra,0xfffff
    80004676:	07c080e7          	jalr	124(ra) # 800036ee <ilock>
    stati(f->ip, &st);
    8000467a:	fb840593          	addi	a1,s0,-72
    8000467e:	6c88                	ld	a0,24(s1)
    80004680:	fffff097          	auipc	ra,0xfffff
    80004684:	2f8080e7          	jalr	760(ra) # 80003978 <stati>
    iunlock(f->ip);
    80004688:	6c88                	ld	a0,24(s1)
    8000468a:	fffff097          	auipc	ra,0xfffff
    8000468e:	126080e7          	jalr	294(ra) # 800037b0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004692:	46e1                	li	a3,24
    80004694:	fb840613          	addi	a2,s0,-72
    80004698:	85ce                	mv	a1,s3
    8000469a:	05093503          	ld	a0,80(s2)
    8000469e:	ffffd097          	auipc	ra,0xffffd
    800046a2:	fce080e7          	jalr	-50(ra) # 8000166c <copyout>
    800046a6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046aa:	60a6                	ld	ra,72(sp)
    800046ac:	6406                	ld	s0,64(sp)
    800046ae:	74e2                	ld	s1,56(sp)
    800046b0:	7942                	ld	s2,48(sp)
    800046b2:	79a2                	ld	s3,40(sp)
    800046b4:	6161                	addi	sp,sp,80
    800046b6:	8082                	ret
  return -1;
    800046b8:	557d                	li	a0,-1
    800046ba:	bfc5                	j	800046aa <filestat+0x60>

00000000800046bc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046bc:	7179                	addi	sp,sp,-48
    800046be:	f406                	sd	ra,40(sp)
    800046c0:	f022                	sd	s0,32(sp)
    800046c2:	ec26                	sd	s1,24(sp)
    800046c4:	e84a                	sd	s2,16(sp)
    800046c6:	e44e                	sd	s3,8(sp)
    800046c8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046ca:	00854783          	lbu	a5,8(a0)
    800046ce:	c3d5                	beqz	a5,80004772 <fileread+0xb6>
    800046d0:	84aa                	mv	s1,a0
    800046d2:	89ae                	mv	s3,a1
    800046d4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046d6:	411c                	lw	a5,0(a0)
    800046d8:	4705                	li	a4,1
    800046da:	04e78963          	beq	a5,a4,8000472c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046de:	470d                	li	a4,3
    800046e0:	04e78d63          	beq	a5,a4,8000473a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046e4:	4709                	li	a4,2
    800046e6:	06e79e63          	bne	a5,a4,80004762 <fileread+0xa6>
    ilock(f->ip);
    800046ea:	6d08                	ld	a0,24(a0)
    800046ec:	fffff097          	auipc	ra,0xfffff
    800046f0:	002080e7          	jalr	2(ra) # 800036ee <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046f4:	874a                	mv	a4,s2
    800046f6:	5094                	lw	a3,32(s1)
    800046f8:	864e                	mv	a2,s3
    800046fa:	4585                	li	a1,1
    800046fc:	6c88                	ld	a0,24(s1)
    800046fe:	fffff097          	auipc	ra,0xfffff
    80004702:	2a4080e7          	jalr	676(ra) # 800039a2 <readi>
    80004706:	892a                	mv	s2,a0
    80004708:	00a05563          	blez	a0,80004712 <fileread+0x56>
      f->off += r;
    8000470c:	509c                	lw	a5,32(s1)
    8000470e:	9fa9                	addw	a5,a5,a0
    80004710:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004712:	6c88                	ld	a0,24(s1)
    80004714:	fffff097          	auipc	ra,0xfffff
    80004718:	09c080e7          	jalr	156(ra) # 800037b0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000471c:	854a                	mv	a0,s2
    8000471e:	70a2                	ld	ra,40(sp)
    80004720:	7402                	ld	s0,32(sp)
    80004722:	64e2                	ld	s1,24(sp)
    80004724:	6942                	ld	s2,16(sp)
    80004726:	69a2                	ld	s3,8(sp)
    80004728:	6145                	addi	sp,sp,48
    8000472a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000472c:	6908                	ld	a0,16(a0)
    8000472e:	00000097          	auipc	ra,0x0
    80004732:	3c6080e7          	jalr	966(ra) # 80004af4 <piperead>
    80004736:	892a                	mv	s2,a0
    80004738:	b7d5                	j	8000471c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000473a:	02451783          	lh	a5,36(a0)
    8000473e:	03079693          	slli	a3,a5,0x30
    80004742:	92c1                	srli	a3,a3,0x30
    80004744:	4725                	li	a4,9
    80004746:	02d76863          	bltu	a4,a3,80004776 <fileread+0xba>
    8000474a:	0792                	slli	a5,a5,0x4
    8000474c:	0001c717          	auipc	a4,0x1c
    80004750:	49c70713          	addi	a4,a4,1180 # 80020be8 <devsw>
    80004754:	97ba                	add	a5,a5,a4
    80004756:	639c                	ld	a5,0(a5)
    80004758:	c38d                	beqz	a5,8000477a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000475a:	4505                	li	a0,1
    8000475c:	9782                	jalr	a5
    8000475e:	892a                	mv	s2,a0
    80004760:	bf75                	j	8000471c <fileread+0x60>
    panic("fileread");
    80004762:	00004517          	auipc	a0,0x4
    80004766:	f6650513          	addi	a0,a0,-154 # 800086c8 <syscalls+0x278>
    8000476a:	ffffc097          	auipc	ra,0xffffc
    8000476e:	dd6080e7          	jalr	-554(ra) # 80000540 <panic>
    return -1;
    80004772:	597d                	li	s2,-1
    80004774:	b765                	j	8000471c <fileread+0x60>
      return -1;
    80004776:	597d                	li	s2,-1
    80004778:	b755                	j	8000471c <fileread+0x60>
    8000477a:	597d                	li	s2,-1
    8000477c:	b745                	j	8000471c <fileread+0x60>

000000008000477e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000477e:	715d                	addi	sp,sp,-80
    80004780:	e486                	sd	ra,72(sp)
    80004782:	e0a2                	sd	s0,64(sp)
    80004784:	fc26                	sd	s1,56(sp)
    80004786:	f84a                	sd	s2,48(sp)
    80004788:	f44e                	sd	s3,40(sp)
    8000478a:	f052                	sd	s4,32(sp)
    8000478c:	ec56                	sd	s5,24(sp)
    8000478e:	e85a                	sd	s6,16(sp)
    80004790:	e45e                	sd	s7,8(sp)
    80004792:	e062                	sd	s8,0(sp)
    80004794:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004796:	00954783          	lbu	a5,9(a0)
    8000479a:	10078663          	beqz	a5,800048a6 <filewrite+0x128>
    8000479e:	892a                	mv	s2,a0
    800047a0:	8b2e                	mv	s6,a1
    800047a2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047a4:	411c                	lw	a5,0(a0)
    800047a6:	4705                	li	a4,1
    800047a8:	02e78263          	beq	a5,a4,800047cc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047ac:	470d                	li	a4,3
    800047ae:	02e78663          	beq	a5,a4,800047da <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047b2:	4709                	li	a4,2
    800047b4:	0ee79163          	bne	a5,a4,80004896 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047b8:	0ac05d63          	blez	a2,80004872 <filewrite+0xf4>
    int i = 0;
    800047bc:	4981                	li	s3,0
    800047be:	6b85                	lui	s7,0x1
    800047c0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047c4:	6c05                	lui	s8,0x1
    800047c6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047ca:	a861                	j	80004862 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047cc:	6908                	ld	a0,16(a0)
    800047ce:	00000097          	auipc	ra,0x0
    800047d2:	22e080e7          	jalr	558(ra) # 800049fc <pipewrite>
    800047d6:	8a2a                	mv	s4,a0
    800047d8:	a045                	j	80004878 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047da:	02451783          	lh	a5,36(a0)
    800047de:	03079693          	slli	a3,a5,0x30
    800047e2:	92c1                	srli	a3,a3,0x30
    800047e4:	4725                	li	a4,9
    800047e6:	0cd76263          	bltu	a4,a3,800048aa <filewrite+0x12c>
    800047ea:	0792                	slli	a5,a5,0x4
    800047ec:	0001c717          	auipc	a4,0x1c
    800047f0:	3fc70713          	addi	a4,a4,1020 # 80020be8 <devsw>
    800047f4:	97ba                	add	a5,a5,a4
    800047f6:	679c                	ld	a5,8(a5)
    800047f8:	cbdd                	beqz	a5,800048ae <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047fa:	4505                	li	a0,1
    800047fc:	9782                	jalr	a5
    800047fe:	8a2a                	mv	s4,a0
    80004800:	a8a5                	j	80004878 <filewrite+0xfa>
    80004802:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004806:	00000097          	auipc	ra,0x0
    8000480a:	8b4080e7          	jalr	-1868(ra) # 800040ba <begin_op>
      ilock(f->ip);
    8000480e:	01893503          	ld	a0,24(s2)
    80004812:	fffff097          	auipc	ra,0xfffff
    80004816:	edc080e7          	jalr	-292(ra) # 800036ee <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000481a:	8756                	mv	a4,s5
    8000481c:	02092683          	lw	a3,32(s2)
    80004820:	01698633          	add	a2,s3,s6
    80004824:	4585                	li	a1,1
    80004826:	01893503          	ld	a0,24(s2)
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	270080e7          	jalr	624(ra) # 80003a9a <writei>
    80004832:	84aa                	mv	s1,a0
    80004834:	00a05763          	blez	a0,80004842 <filewrite+0xc4>
        f->off += r;
    80004838:	02092783          	lw	a5,32(s2)
    8000483c:	9fa9                	addw	a5,a5,a0
    8000483e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004842:	01893503          	ld	a0,24(s2)
    80004846:	fffff097          	auipc	ra,0xfffff
    8000484a:	f6a080e7          	jalr	-150(ra) # 800037b0 <iunlock>
      end_op();
    8000484e:	00000097          	auipc	ra,0x0
    80004852:	8ea080e7          	jalr	-1814(ra) # 80004138 <end_op>

      if(r != n1){
    80004856:	009a9f63          	bne	s5,s1,80004874 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000485a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000485e:	0149db63          	bge	s3,s4,80004874 <filewrite+0xf6>
      int n1 = n - i;
    80004862:	413a04bb          	subw	s1,s4,s3
    80004866:	0004879b          	sext.w	a5,s1
    8000486a:	f8fbdce3          	bge	s7,a5,80004802 <filewrite+0x84>
    8000486e:	84e2                	mv	s1,s8
    80004870:	bf49                	j	80004802 <filewrite+0x84>
    int i = 0;
    80004872:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004874:	013a1f63          	bne	s4,s3,80004892 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004878:	8552                	mv	a0,s4
    8000487a:	60a6                	ld	ra,72(sp)
    8000487c:	6406                	ld	s0,64(sp)
    8000487e:	74e2                	ld	s1,56(sp)
    80004880:	7942                	ld	s2,48(sp)
    80004882:	79a2                	ld	s3,40(sp)
    80004884:	7a02                	ld	s4,32(sp)
    80004886:	6ae2                	ld	s5,24(sp)
    80004888:	6b42                	ld	s6,16(sp)
    8000488a:	6ba2                	ld	s7,8(sp)
    8000488c:	6c02                	ld	s8,0(sp)
    8000488e:	6161                	addi	sp,sp,80
    80004890:	8082                	ret
    ret = (i == n ? n : -1);
    80004892:	5a7d                	li	s4,-1
    80004894:	b7d5                	j	80004878 <filewrite+0xfa>
    panic("filewrite");
    80004896:	00004517          	auipc	a0,0x4
    8000489a:	e4250513          	addi	a0,a0,-446 # 800086d8 <syscalls+0x288>
    8000489e:	ffffc097          	auipc	ra,0xffffc
    800048a2:	ca2080e7          	jalr	-862(ra) # 80000540 <panic>
    return -1;
    800048a6:	5a7d                	li	s4,-1
    800048a8:	bfc1                	j	80004878 <filewrite+0xfa>
      return -1;
    800048aa:	5a7d                	li	s4,-1
    800048ac:	b7f1                	j	80004878 <filewrite+0xfa>
    800048ae:	5a7d                	li	s4,-1
    800048b0:	b7e1                	j	80004878 <filewrite+0xfa>

00000000800048b2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048b2:	7179                	addi	sp,sp,-48
    800048b4:	f406                	sd	ra,40(sp)
    800048b6:	f022                	sd	s0,32(sp)
    800048b8:	ec26                	sd	s1,24(sp)
    800048ba:	e84a                	sd	s2,16(sp)
    800048bc:	e44e                	sd	s3,8(sp)
    800048be:	e052                	sd	s4,0(sp)
    800048c0:	1800                	addi	s0,sp,48
    800048c2:	84aa                	mv	s1,a0
    800048c4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048c6:	0005b023          	sd	zero,0(a1)
    800048ca:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048ce:	00000097          	auipc	ra,0x0
    800048d2:	bf8080e7          	jalr	-1032(ra) # 800044c6 <filealloc>
    800048d6:	e088                	sd	a0,0(s1)
    800048d8:	c551                	beqz	a0,80004964 <pipealloc+0xb2>
    800048da:	00000097          	auipc	ra,0x0
    800048de:	bec080e7          	jalr	-1044(ra) # 800044c6 <filealloc>
    800048e2:	00aa3023          	sd	a0,0(s4)
    800048e6:	c92d                	beqz	a0,80004958 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	1fe080e7          	jalr	510(ra) # 80000ae6 <kalloc>
    800048f0:	892a                	mv	s2,a0
    800048f2:	c125                	beqz	a0,80004952 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048f4:	4985                	li	s3,1
    800048f6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048fa:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048fe:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004902:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004906:	00004597          	auipc	a1,0x4
    8000490a:	de258593          	addi	a1,a1,-542 # 800086e8 <syscalls+0x298>
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	238080e7          	jalr	568(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004916:	609c                	ld	a5,0(s1)
    80004918:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000491c:	609c                	ld	a5,0(s1)
    8000491e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004922:	609c                	ld	a5,0(s1)
    80004924:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004928:	609c                	ld	a5,0(s1)
    8000492a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000492e:	000a3783          	ld	a5,0(s4)
    80004932:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004936:	000a3783          	ld	a5,0(s4)
    8000493a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000493e:	000a3783          	ld	a5,0(s4)
    80004942:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004946:	000a3783          	ld	a5,0(s4)
    8000494a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000494e:	4501                	li	a0,0
    80004950:	a025                	j	80004978 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004952:	6088                	ld	a0,0(s1)
    80004954:	e501                	bnez	a0,8000495c <pipealloc+0xaa>
    80004956:	a039                	j	80004964 <pipealloc+0xb2>
    80004958:	6088                	ld	a0,0(s1)
    8000495a:	c51d                	beqz	a0,80004988 <pipealloc+0xd6>
    fileclose(*f0);
    8000495c:	00000097          	auipc	ra,0x0
    80004960:	c26080e7          	jalr	-986(ra) # 80004582 <fileclose>
  if(*f1)
    80004964:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004968:	557d                	li	a0,-1
  if(*f1)
    8000496a:	c799                	beqz	a5,80004978 <pipealloc+0xc6>
    fileclose(*f1);
    8000496c:	853e                	mv	a0,a5
    8000496e:	00000097          	auipc	ra,0x0
    80004972:	c14080e7          	jalr	-1004(ra) # 80004582 <fileclose>
  return -1;
    80004976:	557d                	li	a0,-1
}
    80004978:	70a2                	ld	ra,40(sp)
    8000497a:	7402                	ld	s0,32(sp)
    8000497c:	64e2                	ld	s1,24(sp)
    8000497e:	6942                	ld	s2,16(sp)
    80004980:	69a2                	ld	s3,8(sp)
    80004982:	6a02                	ld	s4,0(sp)
    80004984:	6145                	addi	sp,sp,48
    80004986:	8082                	ret
  return -1;
    80004988:	557d                	li	a0,-1
    8000498a:	b7fd                	j	80004978 <pipealloc+0xc6>

000000008000498c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000498c:	1101                	addi	sp,sp,-32
    8000498e:	ec06                	sd	ra,24(sp)
    80004990:	e822                	sd	s0,16(sp)
    80004992:	e426                	sd	s1,8(sp)
    80004994:	e04a                	sd	s2,0(sp)
    80004996:	1000                	addi	s0,sp,32
    80004998:	84aa                	mv	s1,a0
    8000499a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000499c:	ffffc097          	auipc	ra,0xffffc
    800049a0:	23a080e7          	jalr	570(ra) # 80000bd6 <acquire>
  if(writable){
    800049a4:	02090d63          	beqz	s2,800049de <pipeclose+0x52>
    pi->writeopen = 0;
    800049a8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049ac:	21848513          	addi	a0,s1,536
    800049b0:	ffffd097          	auipc	ra,0xffffd
    800049b4:	710080e7          	jalr	1808(ra) # 800020c0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049b8:	2204b783          	ld	a5,544(s1)
    800049bc:	eb95                	bnez	a5,800049f0 <pipeclose+0x64>
    release(&pi->lock);
    800049be:	8526                	mv	a0,s1
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	2ca080e7          	jalr	714(ra) # 80000c8a <release>
    kfree((char*)pi);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	01e080e7          	jalr	30(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    800049d2:	60e2                	ld	ra,24(sp)
    800049d4:	6442                	ld	s0,16(sp)
    800049d6:	64a2                	ld	s1,8(sp)
    800049d8:	6902                	ld	s2,0(sp)
    800049da:	6105                	addi	sp,sp,32
    800049dc:	8082                	ret
    pi->readopen = 0;
    800049de:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049e2:	21c48513          	addi	a0,s1,540
    800049e6:	ffffd097          	auipc	ra,0xffffd
    800049ea:	6da080e7          	jalr	1754(ra) # 800020c0 <wakeup>
    800049ee:	b7e9                	j	800049b8 <pipeclose+0x2c>
    release(&pi->lock);
    800049f0:	8526                	mv	a0,s1
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	298080e7          	jalr	664(ra) # 80000c8a <release>
}
    800049fa:	bfe1                	j	800049d2 <pipeclose+0x46>

00000000800049fc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049fc:	711d                	addi	sp,sp,-96
    800049fe:	ec86                	sd	ra,88(sp)
    80004a00:	e8a2                	sd	s0,80(sp)
    80004a02:	e4a6                	sd	s1,72(sp)
    80004a04:	e0ca                	sd	s2,64(sp)
    80004a06:	fc4e                	sd	s3,56(sp)
    80004a08:	f852                	sd	s4,48(sp)
    80004a0a:	f456                	sd	s5,40(sp)
    80004a0c:	f05a                	sd	s6,32(sp)
    80004a0e:	ec5e                	sd	s7,24(sp)
    80004a10:	e862                	sd	s8,16(sp)
    80004a12:	1080                	addi	s0,sp,96
    80004a14:	84aa                	mv	s1,a0
    80004a16:	8aae                	mv	s5,a1
    80004a18:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a1a:	ffffd097          	auipc	ra,0xffffd
    80004a1e:	f9a080e7          	jalr	-102(ra) # 800019b4 <myproc>
    80004a22:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a24:	8526                	mv	a0,s1
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  while(i < n){
    80004a2e:	0b405663          	blez	s4,80004ada <pipewrite+0xde>
  int i = 0;
    80004a32:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a34:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a36:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a3a:	21c48b93          	addi	s7,s1,540
    80004a3e:	a089                	j	80004a80 <pipewrite+0x84>
      release(&pi->lock);
    80004a40:	8526                	mv	a0,s1
    80004a42:	ffffc097          	auipc	ra,0xffffc
    80004a46:	248080e7          	jalr	584(ra) # 80000c8a <release>
      return -1;
    80004a4a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a4c:	854a                	mv	a0,s2
    80004a4e:	60e6                	ld	ra,88(sp)
    80004a50:	6446                	ld	s0,80(sp)
    80004a52:	64a6                	ld	s1,72(sp)
    80004a54:	6906                	ld	s2,64(sp)
    80004a56:	79e2                	ld	s3,56(sp)
    80004a58:	7a42                	ld	s4,48(sp)
    80004a5a:	7aa2                	ld	s5,40(sp)
    80004a5c:	7b02                	ld	s6,32(sp)
    80004a5e:	6be2                	ld	s7,24(sp)
    80004a60:	6c42                	ld	s8,16(sp)
    80004a62:	6125                	addi	sp,sp,96
    80004a64:	8082                	ret
      wakeup(&pi->nread);
    80004a66:	8562                	mv	a0,s8
    80004a68:	ffffd097          	auipc	ra,0xffffd
    80004a6c:	658080e7          	jalr	1624(ra) # 800020c0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a70:	85a6                	mv	a1,s1
    80004a72:	855e                	mv	a0,s7
    80004a74:	ffffd097          	auipc	ra,0xffffd
    80004a78:	5e8080e7          	jalr	1512(ra) # 8000205c <sleep>
  while(i < n){
    80004a7c:	07495063          	bge	s2,s4,80004adc <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a80:	2204a783          	lw	a5,544(s1)
    80004a84:	dfd5                	beqz	a5,80004a40 <pipewrite+0x44>
    80004a86:	854e                	mv	a0,s3
    80004a88:	ffffe097          	auipc	ra,0xffffe
    80004a8c:	87c080e7          	jalr	-1924(ra) # 80002304 <killed>
    80004a90:	f945                	bnez	a0,80004a40 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a92:	2184a783          	lw	a5,536(s1)
    80004a96:	21c4a703          	lw	a4,540(s1)
    80004a9a:	2007879b          	addiw	a5,a5,512
    80004a9e:	fcf704e3          	beq	a4,a5,80004a66 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aa2:	4685                	li	a3,1
    80004aa4:	01590633          	add	a2,s2,s5
    80004aa8:	faf40593          	addi	a1,s0,-81
    80004aac:	0509b503          	ld	a0,80(s3)
    80004ab0:	ffffd097          	auipc	ra,0xffffd
    80004ab4:	c48080e7          	jalr	-952(ra) # 800016f8 <copyin>
    80004ab8:	03650263          	beq	a0,s6,80004adc <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004abc:	21c4a783          	lw	a5,540(s1)
    80004ac0:	0017871b          	addiw	a4,a5,1
    80004ac4:	20e4ae23          	sw	a4,540(s1)
    80004ac8:	1ff7f793          	andi	a5,a5,511
    80004acc:	97a6                	add	a5,a5,s1
    80004ace:	faf44703          	lbu	a4,-81(s0)
    80004ad2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ad6:	2905                	addiw	s2,s2,1
    80004ad8:	b755                	j	80004a7c <pipewrite+0x80>
  int i = 0;
    80004ada:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004adc:	21848513          	addi	a0,s1,536
    80004ae0:	ffffd097          	auipc	ra,0xffffd
    80004ae4:	5e0080e7          	jalr	1504(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004ae8:	8526                	mv	a0,s1
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	1a0080e7          	jalr	416(ra) # 80000c8a <release>
  return i;
    80004af2:	bfa9                	j	80004a4c <pipewrite+0x50>

0000000080004af4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004af4:	715d                	addi	sp,sp,-80
    80004af6:	e486                	sd	ra,72(sp)
    80004af8:	e0a2                	sd	s0,64(sp)
    80004afa:	fc26                	sd	s1,56(sp)
    80004afc:	f84a                	sd	s2,48(sp)
    80004afe:	f44e                	sd	s3,40(sp)
    80004b00:	f052                	sd	s4,32(sp)
    80004b02:	ec56                	sd	s5,24(sp)
    80004b04:	e85a                	sd	s6,16(sp)
    80004b06:	0880                	addi	s0,sp,80
    80004b08:	84aa                	mv	s1,a0
    80004b0a:	892e                	mv	s2,a1
    80004b0c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b0e:	ffffd097          	auipc	ra,0xffffd
    80004b12:	ea6080e7          	jalr	-346(ra) # 800019b4 <myproc>
    80004b16:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b18:	8526                	mv	a0,s1
    80004b1a:	ffffc097          	auipc	ra,0xffffc
    80004b1e:	0bc080e7          	jalr	188(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b22:	2184a703          	lw	a4,536(s1)
    80004b26:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b2a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b2e:	02f71763          	bne	a4,a5,80004b5c <piperead+0x68>
    80004b32:	2244a783          	lw	a5,548(s1)
    80004b36:	c39d                	beqz	a5,80004b5c <piperead+0x68>
    if(killed(pr)){
    80004b38:	8552                	mv	a0,s4
    80004b3a:	ffffd097          	auipc	ra,0xffffd
    80004b3e:	7ca080e7          	jalr	1994(ra) # 80002304 <killed>
    80004b42:	e949                	bnez	a0,80004bd4 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b44:	85a6                	mv	a1,s1
    80004b46:	854e                	mv	a0,s3
    80004b48:	ffffd097          	auipc	ra,0xffffd
    80004b4c:	514080e7          	jalr	1300(ra) # 8000205c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b50:	2184a703          	lw	a4,536(s1)
    80004b54:	21c4a783          	lw	a5,540(s1)
    80004b58:	fcf70de3          	beq	a4,a5,80004b32 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b5c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b5e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b60:	05505463          	blez	s5,80004ba8 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b64:	2184a783          	lw	a5,536(s1)
    80004b68:	21c4a703          	lw	a4,540(s1)
    80004b6c:	02f70e63          	beq	a4,a5,80004ba8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b70:	0017871b          	addiw	a4,a5,1
    80004b74:	20e4ac23          	sw	a4,536(s1)
    80004b78:	1ff7f793          	andi	a5,a5,511
    80004b7c:	97a6                	add	a5,a5,s1
    80004b7e:	0187c783          	lbu	a5,24(a5)
    80004b82:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b86:	4685                	li	a3,1
    80004b88:	fbf40613          	addi	a2,s0,-65
    80004b8c:	85ca                	mv	a1,s2
    80004b8e:	050a3503          	ld	a0,80(s4)
    80004b92:	ffffd097          	auipc	ra,0xffffd
    80004b96:	ada080e7          	jalr	-1318(ra) # 8000166c <copyout>
    80004b9a:	01650763          	beq	a0,s6,80004ba8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b9e:	2985                	addiw	s3,s3,1
    80004ba0:	0905                	addi	s2,s2,1
    80004ba2:	fd3a91e3          	bne	s5,s3,80004b64 <piperead+0x70>
    80004ba6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ba8:	21c48513          	addi	a0,s1,540
    80004bac:	ffffd097          	auipc	ra,0xffffd
    80004bb0:	514080e7          	jalr	1300(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004bb4:	8526                	mv	a0,s1
    80004bb6:	ffffc097          	auipc	ra,0xffffc
    80004bba:	0d4080e7          	jalr	212(ra) # 80000c8a <release>
  return i;
}
    80004bbe:	854e                	mv	a0,s3
    80004bc0:	60a6                	ld	ra,72(sp)
    80004bc2:	6406                	ld	s0,64(sp)
    80004bc4:	74e2                	ld	s1,56(sp)
    80004bc6:	7942                	ld	s2,48(sp)
    80004bc8:	79a2                	ld	s3,40(sp)
    80004bca:	7a02                	ld	s4,32(sp)
    80004bcc:	6ae2                	ld	s5,24(sp)
    80004bce:	6b42                	ld	s6,16(sp)
    80004bd0:	6161                	addi	sp,sp,80
    80004bd2:	8082                	ret
      release(&pi->lock);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	ffffc097          	auipc	ra,0xffffc
    80004bda:	0b4080e7          	jalr	180(ra) # 80000c8a <release>
      return -1;
    80004bde:	59fd                	li	s3,-1
    80004be0:	bff9                	j	80004bbe <piperead+0xca>

0000000080004be2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004be2:	1141                	addi	sp,sp,-16
    80004be4:	e422                	sd	s0,8(sp)
    80004be6:	0800                	addi	s0,sp,16
    80004be8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bea:	8905                	andi	a0,a0,1
    80004bec:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004bee:	8b89                	andi	a5,a5,2
    80004bf0:	c399                	beqz	a5,80004bf6 <flags2perm+0x14>
      perm |= PTE_W;
    80004bf2:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bf6:	6422                	ld	s0,8(sp)
    80004bf8:	0141                	addi	sp,sp,16
    80004bfa:	8082                	ret

0000000080004bfc <exec>:

int
exec(char *path, char **argv)
{
    80004bfc:	de010113          	addi	sp,sp,-544
    80004c00:	20113c23          	sd	ra,536(sp)
    80004c04:	20813823          	sd	s0,528(sp)
    80004c08:	20913423          	sd	s1,520(sp)
    80004c0c:	21213023          	sd	s2,512(sp)
    80004c10:	ffce                	sd	s3,504(sp)
    80004c12:	fbd2                	sd	s4,496(sp)
    80004c14:	f7d6                	sd	s5,488(sp)
    80004c16:	f3da                	sd	s6,480(sp)
    80004c18:	efde                	sd	s7,472(sp)
    80004c1a:	ebe2                	sd	s8,464(sp)
    80004c1c:	e7e6                	sd	s9,456(sp)
    80004c1e:	e3ea                	sd	s10,448(sp)
    80004c20:	ff6e                	sd	s11,440(sp)
    80004c22:	1400                	addi	s0,sp,544
    80004c24:	892a                	mv	s2,a0
    80004c26:	dea43423          	sd	a0,-536(s0)
    80004c2a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c2e:	ffffd097          	auipc	ra,0xffffd
    80004c32:	d86080e7          	jalr	-634(ra) # 800019b4 <myproc>
    80004c36:	84aa                	mv	s1,a0

  begin_op();
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	482080e7          	jalr	1154(ra) # 800040ba <begin_op>

  if((ip = namei(path)) == 0){
    80004c40:	854a                	mv	a0,s2
    80004c42:	fffff097          	auipc	ra,0xfffff
    80004c46:	258080e7          	jalr	600(ra) # 80003e9a <namei>
    80004c4a:	c93d                	beqz	a0,80004cc0 <exec+0xc4>
    80004c4c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	aa0080e7          	jalr	-1376(ra) # 800036ee <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c56:	04000713          	li	a4,64
    80004c5a:	4681                	li	a3,0
    80004c5c:	e5040613          	addi	a2,s0,-432
    80004c60:	4581                	li	a1,0
    80004c62:	8556                	mv	a0,s5
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	d3e080e7          	jalr	-706(ra) # 800039a2 <readi>
    80004c6c:	04000793          	li	a5,64
    80004c70:	00f51a63          	bne	a0,a5,80004c84 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c74:	e5042703          	lw	a4,-432(s0)
    80004c78:	464c47b7          	lui	a5,0x464c4
    80004c7c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c80:	04f70663          	beq	a4,a5,80004ccc <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c84:	8556                	mv	a0,s5
    80004c86:	fffff097          	auipc	ra,0xfffff
    80004c8a:	cca080e7          	jalr	-822(ra) # 80003950 <iunlockput>
    end_op();
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	4aa080e7          	jalr	1194(ra) # 80004138 <end_op>
  }
  return -1;
    80004c96:	557d                	li	a0,-1
}
    80004c98:	21813083          	ld	ra,536(sp)
    80004c9c:	21013403          	ld	s0,528(sp)
    80004ca0:	20813483          	ld	s1,520(sp)
    80004ca4:	20013903          	ld	s2,512(sp)
    80004ca8:	79fe                	ld	s3,504(sp)
    80004caa:	7a5e                	ld	s4,496(sp)
    80004cac:	7abe                	ld	s5,488(sp)
    80004cae:	7b1e                	ld	s6,480(sp)
    80004cb0:	6bfe                	ld	s7,472(sp)
    80004cb2:	6c5e                	ld	s8,464(sp)
    80004cb4:	6cbe                	ld	s9,456(sp)
    80004cb6:	6d1e                	ld	s10,448(sp)
    80004cb8:	7dfa                	ld	s11,440(sp)
    80004cba:	22010113          	addi	sp,sp,544
    80004cbe:	8082                	ret
    end_op();
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	478080e7          	jalr	1144(ra) # 80004138 <end_op>
    return -1;
    80004cc8:	557d                	li	a0,-1
    80004cca:	b7f9                	j	80004c98 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ccc:	8526                	mv	a0,s1
    80004cce:	ffffd097          	auipc	ra,0xffffd
    80004cd2:	daa080e7          	jalr	-598(ra) # 80001a78 <proc_pagetable>
    80004cd6:	8b2a                	mv	s6,a0
    80004cd8:	d555                	beqz	a0,80004c84 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cda:	e7042783          	lw	a5,-400(s0)
    80004cde:	e8845703          	lhu	a4,-376(s0)
    80004ce2:	c735                	beqz	a4,80004d4e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ce4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ce6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004cea:	6a05                	lui	s4,0x1
    80004cec:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cf0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cf4:	6d85                	lui	s11,0x1
    80004cf6:	7d7d                	lui	s10,0xfffff
    80004cf8:	ac3d                	j	80004f36 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cfa:	00004517          	auipc	a0,0x4
    80004cfe:	9f650513          	addi	a0,a0,-1546 # 800086f0 <syscalls+0x2a0>
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	83e080e7          	jalr	-1986(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d0a:	874a                	mv	a4,s2
    80004d0c:	009c86bb          	addw	a3,s9,s1
    80004d10:	4581                	li	a1,0
    80004d12:	8556                	mv	a0,s5
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	c8e080e7          	jalr	-882(ra) # 800039a2 <readi>
    80004d1c:	2501                	sext.w	a0,a0
    80004d1e:	1aa91963          	bne	s2,a0,80004ed0 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004d22:	009d84bb          	addw	s1,s11,s1
    80004d26:	013d09bb          	addw	s3,s10,s3
    80004d2a:	1f74f663          	bgeu	s1,s7,80004f16 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004d2e:	02049593          	slli	a1,s1,0x20
    80004d32:	9181                	srli	a1,a1,0x20
    80004d34:	95e2                	add	a1,a1,s8
    80004d36:	855a                	mv	a0,s6
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	324080e7          	jalr	804(ra) # 8000105c <walkaddr>
    80004d40:	862a                	mv	a2,a0
    if(pa == 0)
    80004d42:	dd45                	beqz	a0,80004cfa <exec+0xfe>
      n = PGSIZE;
    80004d44:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d46:	fd49f2e3          	bgeu	s3,s4,80004d0a <exec+0x10e>
      n = sz - i;
    80004d4a:	894e                	mv	s2,s3
    80004d4c:	bf7d                	j	80004d0a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d4e:	4901                	li	s2,0
  iunlockput(ip);
    80004d50:	8556                	mv	a0,s5
    80004d52:	fffff097          	auipc	ra,0xfffff
    80004d56:	bfe080e7          	jalr	-1026(ra) # 80003950 <iunlockput>
  end_op();
    80004d5a:	fffff097          	auipc	ra,0xfffff
    80004d5e:	3de080e7          	jalr	990(ra) # 80004138 <end_op>
  p = myproc();
    80004d62:	ffffd097          	auipc	ra,0xffffd
    80004d66:	c52080e7          	jalr	-942(ra) # 800019b4 <myproc>
    80004d6a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d6c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d70:	6785                	lui	a5,0x1
    80004d72:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004d74:	97ca                	add	a5,a5,s2
    80004d76:	777d                	lui	a4,0xfffff
    80004d78:	8ff9                	and	a5,a5,a4
    80004d7a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d7e:	4691                	li	a3,4
    80004d80:	6609                	lui	a2,0x2
    80004d82:	963e                	add	a2,a2,a5
    80004d84:	85be                	mv	a1,a5
    80004d86:	855a                	mv	a0,s6
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	688080e7          	jalr	1672(ra) # 80001410 <uvmalloc>
    80004d90:	8c2a                	mv	s8,a0
  ip = 0;
    80004d92:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d94:	12050e63          	beqz	a0,80004ed0 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d98:	75f9                	lui	a1,0xffffe
    80004d9a:	95aa                	add	a1,a1,a0
    80004d9c:	855a                	mv	a0,s6
    80004d9e:	ffffd097          	auipc	ra,0xffffd
    80004da2:	89c080e7          	jalr	-1892(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004da6:	7afd                	lui	s5,0xfffff
    80004da8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004daa:	df043783          	ld	a5,-528(s0)
    80004dae:	6388                	ld	a0,0(a5)
    80004db0:	c925                	beqz	a0,80004e20 <exec+0x224>
    80004db2:	e9040993          	addi	s3,s0,-368
    80004db6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004dba:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dbc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	090080e7          	jalr	144(ra) # 80000e4e <strlen>
    80004dc6:	0015079b          	addiw	a5,a0,1
    80004dca:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dce:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004dd2:	13596663          	bltu	s2,s5,80004efe <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dd6:	df043d83          	ld	s11,-528(s0)
    80004dda:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004dde:	8552                	mv	a0,s4
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	06e080e7          	jalr	110(ra) # 80000e4e <strlen>
    80004de8:	0015069b          	addiw	a3,a0,1
    80004dec:	8652                	mv	a2,s4
    80004dee:	85ca                	mv	a1,s2
    80004df0:	855a                	mv	a0,s6
    80004df2:	ffffd097          	auipc	ra,0xffffd
    80004df6:	87a080e7          	jalr	-1926(ra) # 8000166c <copyout>
    80004dfa:	10054663          	bltz	a0,80004f06 <exec+0x30a>
    ustack[argc] = sp;
    80004dfe:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e02:	0485                	addi	s1,s1,1
    80004e04:	008d8793          	addi	a5,s11,8
    80004e08:	def43823          	sd	a5,-528(s0)
    80004e0c:	008db503          	ld	a0,8(s11)
    80004e10:	c911                	beqz	a0,80004e24 <exec+0x228>
    if(argc >= MAXARG)
    80004e12:	09a1                	addi	s3,s3,8
    80004e14:	fb3c95e3          	bne	s9,s3,80004dbe <exec+0x1c2>
  sz = sz1;
    80004e18:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e1c:	4a81                	li	s5,0
    80004e1e:	a84d                	j	80004ed0 <exec+0x2d4>
  sp = sz;
    80004e20:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e22:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e24:	00349793          	slli	a5,s1,0x3
    80004e28:	f9078793          	addi	a5,a5,-112
    80004e2c:	97a2                	add	a5,a5,s0
    80004e2e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e32:	00148693          	addi	a3,s1,1
    80004e36:	068e                	slli	a3,a3,0x3
    80004e38:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e3c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e40:	01597663          	bgeu	s2,s5,80004e4c <exec+0x250>
  sz = sz1;
    80004e44:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e48:	4a81                	li	s5,0
    80004e4a:	a059                	j	80004ed0 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e4c:	e9040613          	addi	a2,s0,-368
    80004e50:	85ca                	mv	a1,s2
    80004e52:	855a                	mv	a0,s6
    80004e54:	ffffd097          	auipc	ra,0xffffd
    80004e58:	818080e7          	jalr	-2024(ra) # 8000166c <copyout>
    80004e5c:	0a054963          	bltz	a0,80004f0e <exec+0x312>
  p->trapframe->a1 = sp;
    80004e60:	058bb783          	ld	a5,88(s7)
    80004e64:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e68:	de843783          	ld	a5,-536(s0)
    80004e6c:	0007c703          	lbu	a4,0(a5)
    80004e70:	cf11                	beqz	a4,80004e8c <exec+0x290>
    80004e72:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e74:	02f00693          	li	a3,47
    80004e78:	a039                	j	80004e86 <exec+0x28a>
      last = s+1;
    80004e7a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e7e:	0785                	addi	a5,a5,1
    80004e80:	fff7c703          	lbu	a4,-1(a5)
    80004e84:	c701                	beqz	a4,80004e8c <exec+0x290>
    if(*s == '/')
    80004e86:	fed71ce3          	bne	a4,a3,80004e7e <exec+0x282>
    80004e8a:	bfc5                	j	80004e7a <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e8c:	4641                	li	a2,16
    80004e8e:	de843583          	ld	a1,-536(s0)
    80004e92:	158b8513          	addi	a0,s7,344
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	f86080e7          	jalr	-122(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e9e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004ea2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004ea6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004eaa:	058bb783          	ld	a5,88(s7)
    80004eae:	e6843703          	ld	a4,-408(s0)
    80004eb2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eb4:	058bb783          	ld	a5,88(s7)
    80004eb8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ebc:	85ea                	mv	a1,s10
    80004ebe:	ffffd097          	auipc	ra,0xffffd
    80004ec2:	c56080e7          	jalr	-938(ra) # 80001b14 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ec6:	0004851b          	sext.w	a0,s1
    80004eca:	b3f9                	j	80004c98 <exec+0x9c>
    80004ecc:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ed0:	df843583          	ld	a1,-520(s0)
    80004ed4:	855a                	mv	a0,s6
    80004ed6:	ffffd097          	auipc	ra,0xffffd
    80004eda:	c3e080e7          	jalr	-962(ra) # 80001b14 <proc_freepagetable>
  if(ip){
    80004ede:	da0a93e3          	bnez	s5,80004c84 <exec+0x88>
  return -1;
    80004ee2:	557d                	li	a0,-1
    80004ee4:	bb55                	j	80004c98 <exec+0x9c>
    80004ee6:	df243c23          	sd	s2,-520(s0)
    80004eea:	b7dd                	j	80004ed0 <exec+0x2d4>
    80004eec:	df243c23          	sd	s2,-520(s0)
    80004ef0:	b7c5                	j	80004ed0 <exec+0x2d4>
    80004ef2:	df243c23          	sd	s2,-520(s0)
    80004ef6:	bfe9                	j	80004ed0 <exec+0x2d4>
    80004ef8:	df243c23          	sd	s2,-520(s0)
    80004efc:	bfd1                	j	80004ed0 <exec+0x2d4>
  sz = sz1;
    80004efe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f02:	4a81                	li	s5,0
    80004f04:	b7f1                	j	80004ed0 <exec+0x2d4>
  sz = sz1;
    80004f06:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f0a:	4a81                	li	s5,0
    80004f0c:	b7d1                	j	80004ed0 <exec+0x2d4>
  sz = sz1;
    80004f0e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f12:	4a81                	li	s5,0
    80004f14:	bf75                	j	80004ed0 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f16:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f1a:	e0843783          	ld	a5,-504(s0)
    80004f1e:	0017869b          	addiw	a3,a5,1
    80004f22:	e0d43423          	sd	a3,-504(s0)
    80004f26:	e0043783          	ld	a5,-512(s0)
    80004f2a:	0387879b          	addiw	a5,a5,56
    80004f2e:	e8845703          	lhu	a4,-376(s0)
    80004f32:	e0e6dfe3          	bge	a3,a4,80004d50 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f36:	2781                	sext.w	a5,a5
    80004f38:	e0f43023          	sd	a5,-512(s0)
    80004f3c:	03800713          	li	a4,56
    80004f40:	86be                	mv	a3,a5
    80004f42:	e1840613          	addi	a2,s0,-488
    80004f46:	4581                	li	a1,0
    80004f48:	8556                	mv	a0,s5
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	a58080e7          	jalr	-1448(ra) # 800039a2 <readi>
    80004f52:	03800793          	li	a5,56
    80004f56:	f6f51be3          	bne	a0,a5,80004ecc <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004f5a:	e1842783          	lw	a5,-488(s0)
    80004f5e:	4705                	li	a4,1
    80004f60:	fae79de3          	bne	a5,a4,80004f1a <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004f64:	e4043483          	ld	s1,-448(s0)
    80004f68:	e3843783          	ld	a5,-456(s0)
    80004f6c:	f6f4ede3          	bltu	s1,a5,80004ee6 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f70:	e2843783          	ld	a5,-472(s0)
    80004f74:	94be                	add	s1,s1,a5
    80004f76:	f6f4ebe3          	bltu	s1,a5,80004eec <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80004f7a:	de043703          	ld	a4,-544(s0)
    80004f7e:	8ff9                	and	a5,a5,a4
    80004f80:	fbad                	bnez	a5,80004ef2 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f82:	e1c42503          	lw	a0,-484(s0)
    80004f86:	00000097          	auipc	ra,0x0
    80004f8a:	c5c080e7          	jalr	-932(ra) # 80004be2 <flags2perm>
    80004f8e:	86aa                	mv	a3,a0
    80004f90:	8626                	mv	a2,s1
    80004f92:	85ca                	mv	a1,s2
    80004f94:	855a                	mv	a0,s6
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	47a080e7          	jalr	1146(ra) # 80001410 <uvmalloc>
    80004f9e:	dea43c23          	sd	a0,-520(s0)
    80004fa2:	d939                	beqz	a0,80004ef8 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fa4:	e2843c03          	ld	s8,-472(s0)
    80004fa8:	e2042c83          	lw	s9,-480(s0)
    80004fac:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fb0:	f60b83e3          	beqz	s7,80004f16 <exec+0x31a>
    80004fb4:	89de                	mv	s3,s7
    80004fb6:	4481                	li	s1,0
    80004fb8:	bb9d                	j	80004d2e <exec+0x132>

0000000080004fba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fba:	7179                	addi	sp,sp,-48
    80004fbc:	f406                	sd	ra,40(sp)
    80004fbe:	f022                	sd	s0,32(sp)
    80004fc0:	ec26                	sd	s1,24(sp)
    80004fc2:	e84a                	sd	s2,16(sp)
    80004fc4:	1800                	addi	s0,sp,48
    80004fc6:	892e                	mv	s2,a1
    80004fc8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fca:	fdc40593          	addi	a1,s0,-36
    80004fce:	ffffe097          	auipc	ra,0xffffe
    80004fd2:	afc080e7          	jalr	-1284(ra) # 80002aca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fd6:	fdc42703          	lw	a4,-36(s0)
    80004fda:	47bd                	li	a5,15
    80004fdc:	02e7eb63          	bltu	a5,a4,80005012 <argfd+0x58>
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	9d4080e7          	jalr	-1580(ra) # 800019b4 <myproc>
    80004fe8:	fdc42703          	lw	a4,-36(s0)
    80004fec:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd1aa>
    80004ff0:	078e                	slli	a5,a5,0x3
    80004ff2:	953e                	add	a0,a0,a5
    80004ff4:	611c                	ld	a5,0(a0)
    80004ff6:	c385                	beqz	a5,80005016 <argfd+0x5c>
    return -1;
  if(pfd)
    80004ff8:	00090463          	beqz	s2,80005000 <argfd+0x46>
    *pfd = fd;
    80004ffc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005000:	4501                	li	a0,0
  if(pf)
    80005002:	c091                	beqz	s1,80005006 <argfd+0x4c>
    *pf = f;
    80005004:	e09c                	sd	a5,0(s1)
}
    80005006:	70a2                	ld	ra,40(sp)
    80005008:	7402                	ld	s0,32(sp)
    8000500a:	64e2                	ld	s1,24(sp)
    8000500c:	6942                	ld	s2,16(sp)
    8000500e:	6145                	addi	sp,sp,48
    80005010:	8082                	ret
    return -1;
    80005012:	557d                	li	a0,-1
    80005014:	bfcd                	j	80005006 <argfd+0x4c>
    80005016:	557d                	li	a0,-1
    80005018:	b7fd                	j	80005006 <argfd+0x4c>

000000008000501a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000501a:	1101                	addi	sp,sp,-32
    8000501c:	ec06                	sd	ra,24(sp)
    8000501e:	e822                	sd	s0,16(sp)
    80005020:	e426                	sd	s1,8(sp)
    80005022:	1000                	addi	s0,sp,32
    80005024:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005026:	ffffd097          	auipc	ra,0xffffd
    8000502a:	98e080e7          	jalr	-1650(ra) # 800019b4 <myproc>
    8000502e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005030:	0d050793          	addi	a5,a0,208
    80005034:	4501                	li	a0,0
    80005036:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005038:	6398                	ld	a4,0(a5)
    8000503a:	cb19                	beqz	a4,80005050 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000503c:	2505                	addiw	a0,a0,1
    8000503e:	07a1                	addi	a5,a5,8
    80005040:	fed51ce3          	bne	a0,a3,80005038 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005044:	557d                	li	a0,-1
}
    80005046:	60e2                	ld	ra,24(sp)
    80005048:	6442                	ld	s0,16(sp)
    8000504a:	64a2                	ld	s1,8(sp)
    8000504c:	6105                	addi	sp,sp,32
    8000504e:	8082                	ret
      p->ofile[fd] = f;
    80005050:	01a50793          	addi	a5,a0,26
    80005054:	078e                	slli	a5,a5,0x3
    80005056:	963e                	add	a2,a2,a5
    80005058:	e204                	sd	s1,0(a2)
      return fd;
    8000505a:	b7f5                	j	80005046 <fdalloc+0x2c>

000000008000505c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000505c:	715d                	addi	sp,sp,-80
    8000505e:	e486                	sd	ra,72(sp)
    80005060:	e0a2                	sd	s0,64(sp)
    80005062:	fc26                	sd	s1,56(sp)
    80005064:	f84a                	sd	s2,48(sp)
    80005066:	f44e                	sd	s3,40(sp)
    80005068:	f052                	sd	s4,32(sp)
    8000506a:	ec56                	sd	s5,24(sp)
    8000506c:	e85a                	sd	s6,16(sp)
    8000506e:	0880                	addi	s0,sp,80
    80005070:	8b2e                	mv	s6,a1
    80005072:	89b2                	mv	s3,a2
    80005074:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005076:	fb040593          	addi	a1,s0,-80
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	e3e080e7          	jalr	-450(ra) # 80003eb8 <nameiparent>
    80005082:	84aa                	mv	s1,a0
    80005084:	14050f63          	beqz	a0,800051e2 <create+0x186>
    return 0;

  ilock(dp);
    80005088:	ffffe097          	auipc	ra,0xffffe
    8000508c:	666080e7          	jalr	1638(ra) # 800036ee <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005090:	4601                	li	a2,0
    80005092:	fb040593          	addi	a1,s0,-80
    80005096:	8526                	mv	a0,s1
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	b3a080e7          	jalr	-1222(ra) # 80003bd2 <dirlookup>
    800050a0:	8aaa                	mv	s5,a0
    800050a2:	c931                	beqz	a0,800050f6 <create+0x9a>
    iunlockput(dp);
    800050a4:	8526                	mv	a0,s1
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	8aa080e7          	jalr	-1878(ra) # 80003950 <iunlockput>
    ilock(ip);
    800050ae:	8556                	mv	a0,s5
    800050b0:	ffffe097          	auipc	ra,0xffffe
    800050b4:	63e080e7          	jalr	1598(ra) # 800036ee <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050b8:	000b059b          	sext.w	a1,s6
    800050bc:	4789                	li	a5,2
    800050be:	02f59563          	bne	a1,a5,800050e8 <create+0x8c>
    800050c2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd1d4>
    800050c6:	37f9                	addiw	a5,a5,-2
    800050c8:	17c2                	slli	a5,a5,0x30
    800050ca:	93c1                	srli	a5,a5,0x30
    800050cc:	4705                	li	a4,1
    800050ce:	00f76d63          	bltu	a4,a5,800050e8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050d2:	8556                	mv	a0,s5
    800050d4:	60a6                	ld	ra,72(sp)
    800050d6:	6406                	ld	s0,64(sp)
    800050d8:	74e2                	ld	s1,56(sp)
    800050da:	7942                	ld	s2,48(sp)
    800050dc:	79a2                	ld	s3,40(sp)
    800050de:	7a02                	ld	s4,32(sp)
    800050e0:	6ae2                	ld	s5,24(sp)
    800050e2:	6b42                	ld	s6,16(sp)
    800050e4:	6161                	addi	sp,sp,80
    800050e6:	8082                	ret
    iunlockput(ip);
    800050e8:	8556                	mv	a0,s5
    800050ea:	fffff097          	auipc	ra,0xfffff
    800050ee:	866080e7          	jalr	-1946(ra) # 80003950 <iunlockput>
    return 0;
    800050f2:	4a81                	li	s5,0
    800050f4:	bff9                	j	800050d2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050f6:	85da                	mv	a1,s6
    800050f8:	4088                	lw	a0,0(s1)
    800050fa:	ffffe097          	auipc	ra,0xffffe
    800050fe:	456080e7          	jalr	1110(ra) # 80003550 <ialloc>
    80005102:	8a2a                	mv	s4,a0
    80005104:	c539                	beqz	a0,80005152 <create+0xf6>
  ilock(ip);
    80005106:	ffffe097          	auipc	ra,0xffffe
    8000510a:	5e8080e7          	jalr	1512(ra) # 800036ee <ilock>
  ip->major = major;
    8000510e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005112:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005116:	4905                	li	s2,1
    80005118:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000511c:	8552                	mv	a0,s4
    8000511e:	ffffe097          	auipc	ra,0xffffe
    80005122:	504080e7          	jalr	1284(ra) # 80003622 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005126:	000b059b          	sext.w	a1,s6
    8000512a:	03258b63          	beq	a1,s2,80005160 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000512e:	004a2603          	lw	a2,4(s4)
    80005132:	fb040593          	addi	a1,s0,-80
    80005136:	8526                	mv	a0,s1
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	cb0080e7          	jalr	-848(ra) # 80003de8 <dirlink>
    80005140:	06054f63          	bltz	a0,800051be <create+0x162>
  iunlockput(dp);
    80005144:	8526                	mv	a0,s1
    80005146:	fffff097          	auipc	ra,0xfffff
    8000514a:	80a080e7          	jalr	-2038(ra) # 80003950 <iunlockput>
  return ip;
    8000514e:	8ad2                	mv	s5,s4
    80005150:	b749                	j	800050d2 <create+0x76>
    iunlockput(dp);
    80005152:	8526                	mv	a0,s1
    80005154:	ffffe097          	auipc	ra,0xffffe
    80005158:	7fc080e7          	jalr	2044(ra) # 80003950 <iunlockput>
    return 0;
    8000515c:	8ad2                	mv	s5,s4
    8000515e:	bf95                	j	800050d2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005160:	004a2603          	lw	a2,4(s4)
    80005164:	00003597          	auipc	a1,0x3
    80005168:	5ac58593          	addi	a1,a1,1452 # 80008710 <syscalls+0x2c0>
    8000516c:	8552                	mv	a0,s4
    8000516e:	fffff097          	auipc	ra,0xfffff
    80005172:	c7a080e7          	jalr	-902(ra) # 80003de8 <dirlink>
    80005176:	04054463          	bltz	a0,800051be <create+0x162>
    8000517a:	40d0                	lw	a2,4(s1)
    8000517c:	00003597          	auipc	a1,0x3
    80005180:	59c58593          	addi	a1,a1,1436 # 80008718 <syscalls+0x2c8>
    80005184:	8552                	mv	a0,s4
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	c62080e7          	jalr	-926(ra) # 80003de8 <dirlink>
    8000518e:	02054863          	bltz	a0,800051be <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005192:	004a2603          	lw	a2,4(s4)
    80005196:	fb040593          	addi	a1,s0,-80
    8000519a:	8526                	mv	a0,s1
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	c4c080e7          	jalr	-948(ra) # 80003de8 <dirlink>
    800051a4:	00054d63          	bltz	a0,800051be <create+0x162>
    dp->nlink++;  // for ".."
    800051a8:	04a4d783          	lhu	a5,74(s1)
    800051ac:	2785                	addiw	a5,a5,1
    800051ae:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051b2:	8526                	mv	a0,s1
    800051b4:	ffffe097          	auipc	ra,0xffffe
    800051b8:	46e080e7          	jalr	1134(ra) # 80003622 <iupdate>
    800051bc:	b761                	j	80005144 <create+0xe8>
  ip->nlink = 0;
    800051be:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800051c2:	8552                	mv	a0,s4
    800051c4:	ffffe097          	auipc	ra,0xffffe
    800051c8:	45e080e7          	jalr	1118(ra) # 80003622 <iupdate>
  iunlockput(ip);
    800051cc:	8552                	mv	a0,s4
    800051ce:	ffffe097          	auipc	ra,0xffffe
    800051d2:	782080e7          	jalr	1922(ra) # 80003950 <iunlockput>
  iunlockput(dp);
    800051d6:	8526                	mv	a0,s1
    800051d8:	ffffe097          	auipc	ra,0xffffe
    800051dc:	778080e7          	jalr	1912(ra) # 80003950 <iunlockput>
  return 0;
    800051e0:	bdcd                	j	800050d2 <create+0x76>
    return 0;
    800051e2:	8aaa                	mv	s5,a0
    800051e4:	b5fd                	j	800050d2 <create+0x76>

00000000800051e6 <sys_dup>:
{
    800051e6:	7179                	addi	sp,sp,-48
    800051e8:	f406                	sd	ra,40(sp)
    800051ea:	f022                	sd	s0,32(sp)
    800051ec:	ec26                	sd	s1,24(sp)
    800051ee:	e84a                	sd	s2,16(sp)
    800051f0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051f2:	fd840613          	addi	a2,s0,-40
    800051f6:	4581                	li	a1,0
    800051f8:	4501                	li	a0,0
    800051fa:	00000097          	auipc	ra,0x0
    800051fe:	dc0080e7          	jalr	-576(ra) # 80004fba <argfd>
    return -1;
    80005202:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005204:	02054363          	bltz	a0,8000522a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005208:	fd843903          	ld	s2,-40(s0)
    8000520c:	854a                	mv	a0,s2
    8000520e:	00000097          	auipc	ra,0x0
    80005212:	e0c080e7          	jalr	-500(ra) # 8000501a <fdalloc>
    80005216:	84aa                	mv	s1,a0
    return -1;
    80005218:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000521a:	00054863          	bltz	a0,8000522a <sys_dup+0x44>
  filedup(f);
    8000521e:	854a                	mv	a0,s2
    80005220:	fffff097          	auipc	ra,0xfffff
    80005224:	310080e7          	jalr	784(ra) # 80004530 <filedup>
  return fd;
    80005228:	87a6                	mv	a5,s1
}
    8000522a:	853e                	mv	a0,a5
    8000522c:	70a2                	ld	ra,40(sp)
    8000522e:	7402                	ld	s0,32(sp)
    80005230:	64e2                	ld	s1,24(sp)
    80005232:	6942                	ld	s2,16(sp)
    80005234:	6145                	addi	sp,sp,48
    80005236:	8082                	ret

0000000080005238 <sys_read>:
{
    80005238:	7179                	addi	sp,sp,-48
    8000523a:	f406                	sd	ra,40(sp)
    8000523c:	f022                	sd	s0,32(sp)
    8000523e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005240:	fd840593          	addi	a1,s0,-40
    80005244:	4505                	li	a0,1
    80005246:	ffffe097          	auipc	ra,0xffffe
    8000524a:	8a4080e7          	jalr	-1884(ra) # 80002aea <argaddr>
  argint(2, &n);
    8000524e:	fe440593          	addi	a1,s0,-28
    80005252:	4509                	li	a0,2
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	876080e7          	jalr	-1930(ra) # 80002aca <argint>
  if(argfd(0, 0, &f) < 0)
    8000525c:	fe840613          	addi	a2,s0,-24
    80005260:	4581                	li	a1,0
    80005262:	4501                	li	a0,0
    80005264:	00000097          	auipc	ra,0x0
    80005268:	d56080e7          	jalr	-682(ra) # 80004fba <argfd>
    8000526c:	87aa                	mv	a5,a0
    return -1;
    8000526e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005270:	0007cc63          	bltz	a5,80005288 <sys_read+0x50>
  return fileread(f, p, n);
    80005274:	fe442603          	lw	a2,-28(s0)
    80005278:	fd843583          	ld	a1,-40(s0)
    8000527c:	fe843503          	ld	a0,-24(s0)
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	43c080e7          	jalr	1084(ra) # 800046bc <fileread>
}
    80005288:	70a2                	ld	ra,40(sp)
    8000528a:	7402                	ld	s0,32(sp)
    8000528c:	6145                	addi	sp,sp,48
    8000528e:	8082                	ret

0000000080005290 <sys_write>:
{
    80005290:	7179                	addi	sp,sp,-48
    80005292:	f406                	sd	ra,40(sp)
    80005294:	f022                	sd	s0,32(sp)
    80005296:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005298:	fd840593          	addi	a1,s0,-40
    8000529c:	4505                	li	a0,1
    8000529e:	ffffe097          	auipc	ra,0xffffe
    800052a2:	84c080e7          	jalr	-1972(ra) # 80002aea <argaddr>
  argint(2, &n);
    800052a6:	fe440593          	addi	a1,s0,-28
    800052aa:	4509                	li	a0,2
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	81e080e7          	jalr	-2018(ra) # 80002aca <argint>
  if(argfd(0, 0, &f) < 0)
    800052b4:	fe840613          	addi	a2,s0,-24
    800052b8:	4581                	li	a1,0
    800052ba:	4501                	li	a0,0
    800052bc:	00000097          	auipc	ra,0x0
    800052c0:	cfe080e7          	jalr	-770(ra) # 80004fba <argfd>
    800052c4:	87aa                	mv	a5,a0
    return -1;
    800052c6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c8:	0007cc63          	bltz	a5,800052e0 <sys_write+0x50>
  return filewrite(f, p, n);
    800052cc:	fe442603          	lw	a2,-28(s0)
    800052d0:	fd843583          	ld	a1,-40(s0)
    800052d4:	fe843503          	ld	a0,-24(s0)
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	4a6080e7          	jalr	1190(ra) # 8000477e <filewrite>
}
    800052e0:	70a2                	ld	ra,40(sp)
    800052e2:	7402                	ld	s0,32(sp)
    800052e4:	6145                	addi	sp,sp,48
    800052e6:	8082                	ret

00000000800052e8 <sys_close>:
{
    800052e8:	1101                	addi	sp,sp,-32
    800052ea:	ec06                	sd	ra,24(sp)
    800052ec:	e822                	sd	s0,16(sp)
    800052ee:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052f0:	fe040613          	addi	a2,s0,-32
    800052f4:	fec40593          	addi	a1,s0,-20
    800052f8:	4501                	li	a0,0
    800052fa:	00000097          	auipc	ra,0x0
    800052fe:	cc0080e7          	jalr	-832(ra) # 80004fba <argfd>
    return -1;
    80005302:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005304:	02054463          	bltz	a0,8000532c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	6ac080e7          	jalr	1708(ra) # 800019b4 <myproc>
    80005310:	fec42783          	lw	a5,-20(s0)
    80005314:	07e9                	addi	a5,a5,26
    80005316:	078e                	slli	a5,a5,0x3
    80005318:	953e                	add	a0,a0,a5
    8000531a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000531e:	fe043503          	ld	a0,-32(s0)
    80005322:	fffff097          	auipc	ra,0xfffff
    80005326:	260080e7          	jalr	608(ra) # 80004582 <fileclose>
  return 0;
    8000532a:	4781                	li	a5,0
}
    8000532c:	853e                	mv	a0,a5
    8000532e:	60e2                	ld	ra,24(sp)
    80005330:	6442                	ld	s0,16(sp)
    80005332:	6105                	addi	sp,sp,32
    80005334:	8082                	ret

0000000080005336 <sys_fstat>:
{
    80005336:	1101                	addi	sp,sp,-32
    80005338:	ec06                	sd	ra,24(sp)
    8000533a:	e822                	sd	s0,16(sp)
    8000533c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000533e:	fe040593          	addi	a1,s0,-32
    80005342:	4505                	li	a0,1
    80005344:	ffffd097          	auipc	ra,0xffffd
    80005348:	7a6080e7          	jalr	1958(ra) # 80002aea <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000534c:	fe840613          	addi	a2,s0,-24
    80005350:	4581                	li	a1,0
    80005352:	4501                	li	a0,0
    80005354:	00000097          	auipc	ra,0x0
    80005358:	c66080e7          	jalr	-922(ra) # 80004fba <argfd>
    8000535c:	87aa                	mv	a5,a0
    return -1;
    8000535e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005360:	0007ca63          	bltz	a5,80005374 <sys_fstat+0x3e>
  return filestat(f, st);
    80005364:	fe043583          	ld	a1,-32(s0)
    80005368:	fe843503          	ld	a0,-24(s0)
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	2de080e7          	jalr	734(ra) # 8000464a <filestat>
}
    80005374:	60e2                	ld	ra,24(sp)
    80005376:	6442                	ld	s0,16(sp)
    80005378:	6105                	addi	sp,sp,32
    8000537a:	8082                	ret

000000008000537c <sys_link>:
{
    8000537c:	7169                	addi	sp,sp,-304
    8000537e:	f606                	sd	ra,296(sp)
    80005380:	f222                	sd	s0,288(sp)
    80005382:	ee26                	sd	s1,280(sp)
    80005384:	ea4a                	sd	s2,272(sp)
    80005386:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005388:	08000613          	li	a2,128
    8000538c:	ed040593          	addi	a1,s0,-304
    80005390:	4501                	li	a0,0
    80005392:	ffffd097          	auipc	ra,0xffffd
    80005396:	778080e7          	jalr	1912(ra) # 80002b0a <argstr>
    return -1;
    8000539a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000539c:	10054e63          	bltz	a0,800054b8 <sys_link+0x13c>
    800053a0:	08000613          	li	a2,128
    800053a4:	f5040593          	addi	a1,s0,-176
    800053a8:	4505                	li	a0,1
    800053aa:	ffffd097          	auipc	ra,0xffffd
    800053ae:	760080e7          	jalr	1888(ra) # 80002b0a <argstr>
    return -1;
    800053b2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053b4:	10054263          	bltz	a0,800054b8 <sys_link+0x13c>
  begin_op();
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	d02080e7          	jalr	-766(ra) # 800040ba <begin_op>
  if((ip = namei(old)) == 0){
    800053c0:	ed040513          	addi	a0,s0,-304
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	ad6080e7          	jalr	-1322(ra) # 80003e9a <namei>
    800053cc:	84aa                	mv	s1,a0
    800053ce:	c551                	beqz	a0,8000545a <sys_link+0xde>
  ilock(ip);
    800053d0:	ffffe097          	auipc	ra,0xffffe
    800053d4:	31e080e7          	jalr	798(ra) # 800036ee <ilock>
  if(ip->type == T_DIR){
    800053d8:	04449703          	lh	a4,68(s1)
    800053dc:	4785                	li	a5,1
    800053de:	08f70463          	beq	a4,a5,80005466 <sys_link+0xea>
  ip->nlink++;
    800053e2:	04a4d783          	lhu	a5,74(s1)
    800053e6:	2785                	addiw	a5,a5,1
    800053e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053ec:	8526                	mv	a0,s1
    800053ee:	ffffe097          	auipc	ra,0xffffe
    800053f2:	234080e7          	jalr	564(ra) # 80003622 <iupdate>
  iunlock(ip);
    800053f6:	8526                	mv	a0,s1
    800053f8:	ffffe097          	auipc	ra,0xffffe
    800053fc:	3b8080e7          	jalr	952(ra) # 800037b0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005400:	fd040593          	addi	a1,s0,-48
    80005404:	f5040513          	addi	a0,s0,-176
    80005408:	fffff097          	auipc	ra,0xfffff
    8000540c:	ab0080e7          	jalr	-1360(ra) # 80003eb8 <nameiparent>
    80005410:	892a                	mv	s2,a0
    80005412:	c935                	beqz	a0,80005486 <sys_link+0x10a>
  ilock(dp);
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	2da080e7          	jalr	730(ra) # 800036ee <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000541c:	00092703          	lw	a4,0(s2)
    80005420:	409c                	lw	a5,0(s1)
    80005422:	04f71d63          	bne	a4,a5,8000547c <sys_link+0x100>
    80005426:	40d0                	lw	a2,4(s1)
    80005428:	fd040593          	addi	a1,s0,-48
    8000542c:	854a                	mv	a0,s2
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	9ba080e7          	jalr	-1606(ra) # 80003de8 <dirlink>
    80005436:	04054363          	bltz	a0,8000547c <sys_link+0x100>
  iunlockput(dp);
    8000543a:	854a                	mv	a0,s2
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	514080e7          	jalr	1300(ra) # 80003950 <iunlockput>
  iput(ip);
    80005444:	8526                	mv	a0,s1
    80005446:	ffffe097          	auipc	ra,0xffffe
    8000544a:	462080e7          	jalr	1122(ra) # 800038a8 <iput>
  end_op();
    8000544e:	fffff097          	auipc	ra,0xfffff
    80005452:	cea080e7          	jalr	-790(ra) # 80004138 <end_op>
  return 0;
    80005456:	4781                	li	a5,0
    80005458:	a085                	j	800054b8 <sys_link+0x13c>
    end_op();
    8000545a:	fffff097          	auipc	ra,0xfffff
    8000545e:	cde080e7          	jalr	-802(ra) # 80004138 <end_op>
    return -1;
    80005462:	57fd                	li	a5,-1
    80005464:	a891                	j	800054b8 <sys_link+0x13c>
    iunlockput(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	4e8080e7          	jalr	1256(ra) # 80003950 <iunlockput>
    end_op();
    80005470:	fffff097          	auipc	ra,0xfffff
    80005474:	cc8080e7          	jalr	-824(ra) # 80004138 <end_op>
    return -1;
    80005478:	57fd                	li	a5,-1
    8000547a:	a83d                	j	800054b8 <sys_link+0x13c>
    iunlockput(dp);
    8000547c:	854a                	mv	a0,s2
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	4d2080e7          	jalr	1234(ra) # 80003950 <iunlockput>
  ilock(ip);
    80005486:	8526                	mv	a0,s1
    80005488:	ffffe097          	auipc	ra,0xffffe
    8000548c:	266080e7          	jalr	614(ra) # 800036ee <ilock>
  ip->nlink--;
    80005490:	04a4d783          	lhu	a5,74(s1)
    80005494:	37fd                	addiw	a5,a5,-1
    80005496:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000549a:	8526                	mv	a0,s1
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	186080e7          	jalr	390(ra) # 80003622 <iupdate>
  iunlockput(ip);
    800054a4:	8526                	mv	a0,s1
    800054a6:	ffffe097          	auipc	ra,0xffffe
    800054aa:	4aa080e7          	jalr	1194(ra) # 80003950 <iunlockput>
  end_op();
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	c8a080e7          	jalr	-886(ra) # 80004138 <end_op>
  return -1;
    800054b6:	57fd                	li	a5,-1
}
    800054b8:	853e                	mv	a0,a5
    800054ba:	70b2                	ld	ra,296(sp)
    800054bc:	7412                	ld	s0,288(sp)
    800054be:	64f2                	ld	s1,280(sp)
    800054c0:	6952                	ld	s2,272(sp)
    800054c2:	6155                	addi	sp,sp,304
    800054c4:	8082                	ret

00000000800054c6 <sys_unlink>:
{
    800054c6:	7151                	addi	sp,sp,-240
    800054c8:	f586                	sd	ra,232(sp)
    800054ca:	f1a2                	sd	s0,224(sp)
    800054cc:	eda6                	sd	s1,216(sp)
    800054ce:	e9ca                	sd	s2,208(sp)
    800054d0:	e5ce                	sd	s3,200(sp)
    800054d2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054d4:	08000613          	li	a2,128
    800054d8:	f3040593          	addi	a1,s0,-208
    800054dc:	4501                	li	a0,0
    800054de:	ffffd097          	auipc	ra,0xffffd
    800054e2:	62c080e7          	jalr	1580(ra) # 80002b0a <argstr>
    800054e6:	18054163          	bltz	a0,80005668 <sys_unlink+0x1a2>
  begin_op();
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	bd0080e7          	jalr	-1072(ra) # 800040ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054f2:	fb040593          	addi	a1,s0,-80
    800054f6:	f3040513          	addi	a0,s0,-208
    800054fa:	fffff097          	auipc	ra,0xfffff
    800054fe:	9be080e7          	jalr	-1602(ra) # 80003eb8 <nameiparent>
    80005502:	84aa                	mv	s1,a0
    80005504:	c979                	beqz	a0,800055da <sys_unlink+0x114>
  ilock(dp);
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	1e8080e7          	jalr	488(ra) # 800036ee <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000550e:	00003597          	auipc	a1,0x3
    80005512:	20258593          	addi	a1,a1,514 # 80008710 <syscalls+0x2c0>
    80005516:	fb040513          	addi	a0,s0,-80
    8000551a:	ffffe097          	auipc	ra,0xffffe
    8000551e:	69e080e7          	jalr	1694(ra) # 80003bb8 <namecmp>
    80005522:	14050a63          	beqz	a0,80005676 <sys_unlink+0x1b0>
    80005526:	00003597          	auipc	a1,0x3
    8000552a:	1f258593          	addi	a1,a1,498 # 80008718 <syscalls+0x2c8>
    8000552e:	fb040513          	addi	a0,s0,-80
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	686080e7          	jalr	1670(ra) # 80003bb8 <namecmp>
    8000553a:	12050e63          	beqz	a0,80005676 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000553e:	f2c40613          	addi	a2,s0,-212
    80005542:	fb040593          	addi	a1,s0,-80
    80005546:	8526                	mv	a0,s1
    80005548:	ffffe097          	auipc	ra,0xffffe
    8000554c:	68a080e7          	jalr	1674(ra) # 80003bd2 <dirlookup>
    80005550:	892a                	mv	s2,a0
    80005552:	12050263          	beqz	a0,80005676 <sys_unlink+0x1b0>
  ilock(ip);
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	198080e7          	jalr	408(ra) # 800036ee <ilock>
  if(ip->nlink < 1)
    8000555e:	04a91783          	lh	a5,74(s2)
    80005562:	08f05263          	blez	a5,800055e6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005566:	04491703          	lh	a4,68(s2)
    8000556a:	4785                	li	a5,1
    8000556c:	08f70563          	beq	a4,a5,800055f6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005570:	4641                	li	a2,16
    80005572:	4581                	li	a1,0
    80005574:	fc040513          	addi	a0,s0,-64
    80005578:	ffffb097          	auipc	ra,0xffffb
    8000557c:	75a080e7          	jalr	1882(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005580:	4741                	li	a4,16
    80005582:	f2c42683          	lw	a3,-212(s0)
    80005586:	fc040613          	addi	a2,s0,-64
    8000558a:	4581                	li	a1,0
    8000558c:	8526                	mv	a0,s1
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	50c080e7          	jalr	1292(ra) # 80003a9a <writei>
    80005596:	47c1                	li	a5,16
    80005598:	0af51563          	bne	a0,a5,80005642 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000559c:	04491703          	lh	a4,68(s2)
    800055a0:	4785                	li	a5,1
    800055a2:	0af70863          	beq	a4,a5,80005652 <sys_unlink+0x18c>
  iunlockput(dp);
    800055a6:	8526                	mv	a0,s1
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	3a8080e7          	jalr	936(ra) # 80003950 <iunlockput>
  ip->nlink--;
    800055b0:	04a95783          	lhu	a5,74(s2)
    800055b4:	37fd                	addiw	a5,a5,-1
    800055b6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055ba:	854a                	mv	a0,s2
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	066080e7          	jalr	102(ra) # 80003622 <iupdate>
  iunlockput(ip);
    800055c4:	854a                	mv	a0,s2
    800055c6:	ffffe097          	auipc	ra,0xffffe
    800055ca:	38a080e7          	jalr	906(ra) # 80003950 <iunlockput>
  end_op();
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	b6a080e7          	jalr	-1174(ra) # 80004138 <end_op>
  return 0;
    800055d6:	4501                	li	a0,0
    800055d8:	a84d                	j	8000568a <sys_unlink+0x1c4>
    end_op();
    800055da:	fffff097          	auipc	ra,0xfffff
    800055de:	b5e080e7          	jalr	-1186(ra) # 80004138 <end_op>
    return -1;
    800055e2:	557d                	li	a0,-1
    800055e4:	a05d                	j	8000568a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055e6:	00003517          	auipc	a0,0x3
    800055ea:	13a50513          	addi	a0,a0,314 # 80008720 <syscalls+0x2d0>
    800055ee:	ffffb097          	auipc	ra,0xffffb
    800055f2:	f52080e7          	jalr	-174(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055f6:	04c92703          	lw	a4,76(s2)
    800055fa:	02000793          	li	a5,32
    800055fe:	f6e7f9e3          	bgeu	a5,a4,80005570 <sys_unlink+0xaa>
    80005602:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005606:	4741                	li	a4,16
    80005608:	86ce                	mv	a3,s3
    8000560a:	f1840613          	addi	a2,s0,-232
    8000560e:	4581                	li	a1,0
    80005610:	854a                	mv	a0,s2
    80005612:	ffffe097          	auipc	ra,0xffffe
    80005616:	390080e7          	jalr	912(ra) # 800039a2 <readi>
    8000561a:	47c1                	li	a5,16
    8000561c:	00f51b63          	bne	a0,a5,80005632 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005620:	f1845783          	lhu	a5,-232(s0)
    80005624:	e7a1                	bnez	a5,8000566c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005626:	29c1                	addiw	s3,s3,16
    80005628:	04c92783          	lw	a5,76(s2)
    8000562c:	fcf9ede3          	bltu	s3,a5,80005606 <sys_unlink+0x140>
    80005630:	b781                	j	80005570 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005632:	00003517          	auipc	a0,0x3
    80005636:	10650513          	addi	a0,a0,262 # 80008738 <syscalls+0x2e8>
    8000563a:	ffffb097          	auipc	ra,0xffffb
    8000563e:	f06080e7          	jalr	-250(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005642:	00003517          	auipc	a0,0x3
    80005646:	10e50513          	addi	a0,a0,270 # 80008750 <syscalls+0x300>
    8000564a:	ffffb097          	auipc	ra,0xffffb
    8000564e:	ef6080e7          	jalr	-266(ra) # 80000540 <panic>
    dp->nlink--;
    80005652:	04a4d783          	lhu	a5,74(s1)
    80005656:	37fd                	addiw	a5,a5,-1
    80005658:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000565c:	8526                	mv	a0,s1
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	fc4080e7          	jalr	-60(ra) # 80003622 <iupdate>
    80005666:	b781                	j	800055a6 <sys_unlink+0xe0>
    return -1;
    80005668:	557d                	li	a0,-1
    8000566a:	a005                	j	8000568a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000566c:	854a                	mv	a0,s2
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	2e2080e7          	jalr	738(ra) # 80003950 <iunlockput>
  iunlockput(dp);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	2d8080e7          	jalr	728(ra) # 80003950 <iunlockput>
  end_op();
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	ab8080e7          	jalr	-1352(ra) # 80004138 <end_op>
  return -1;
    80005688:	557d                	li	a0,-1
}
    8000568a:	70ae                	ld	ra,232(sp)
    8000568c:	740e                	ld	s0,224(sp)
    8000568e:	64ee                	ld	s1,216(sp)
    80005690:	694e                	ld	s2,208(sp)
    80005692:	69ae                	ld	s3,200(sp)
    80005694:	616d                	addi	sp,sp,240
    80005696:	8082                	ret

0000000080005698 <sys_open>:

uint64
sys_open(void)
{
    80005698:	7131                	addi	sp,sp,-192
    8000569a:	fd06                	sd	ra,184(sp)
    8000569c:	f922                	sd	s0,176(sp)
    8000569e:	f526                	sd	s1,168(sp)
    800056a0:	f14a                	sd	s2,160(sp)
    800056a2:	ed4e                	sd	s3,152(sp)
    800056a4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056a6:	f4c40593          	addi	a1,s0,-180
    800056aa:	4505                	li	a0,1
    800056ac:	ffffd097          	auipc	ra,0xffffd
    800056b0:	41e080e7          	jalr	1054(ra) # 80002aca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056b4:	08000613          	li	a2,128
    800056b8:	f5040593          	addi	a1,s0,-176
    800056bc:	4501                	li	a0,0
    800056be:	ffffd097          	auipc	ra,0xffffd
    800056c2:	44c080e7          	jalr	1100(ra) # 80002b0a <argstr>
    800056c6:	87aa                	mv	a5,a0
    return -1;
    800056c8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056ca:	0a07c963          	bltz	a5,8000577c <sys_open+0xe4>

  begin_op();
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	9ec080e7          	jalr	-1556(ra) # 800040ba <begin_op>

  if(omode & O_CREATE){
    800056d6:	f4c42783          	lw	a5,-180(s0)
    800056da:	2007f793          	andi	a5,a5,512
    800056de:	cfc5                	beqz	a5,80005796 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056e0:	4681                	li	a3,0
    800056e2:	4601                	li	a2,0
    800056e4:	4589                	li	a1,2
    800056e6:	f5040513          	addi	a0,s0,-176
    800056ea:	00000097          	auipc	ra,0x0
    800056ee:	972080e7          	jalr	-1678(ra) # 8000505c <create>
    800056f2:	84aa                	mv	s1,a0
    if(ip == 0){
    800056f4:	c959                	beqz	a0,8000578a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056f6:	04449703          	lh	a4,68(s1)
    800056fa:	478d                	li	a5,3
    800056fc:	00f71763          	bne	a4,a5,8000570a <sys_open+0x72>
    80005700:	0464d703          	lhu	a4,70(s1)
    80005704:	47a5                	li	a5,9
    80005706:	0ce7ed63          	bltu	a5,a4,800057e0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	dbc080e7          	jalr	-580(ra) # 800044c6 <filealloc>
    80005712:	89aa                	mv	s3,a0
    80005714:	10050363          	beqz	a0,8000581a <sys_open+0x182>
    80005718:	00000097          	auipc	ra,0x0
    8000571c:	902080e7          	jalr	-1790(ra) # 8000501a <fdalloc>
    80005720:	892a                	mv	s2,a0
    80005722:	0e054763          	bltz	a0,80005810 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005726:	04449703          	lh	a4,68(s1)
    8000572a:	478d                	li	a5,3
    8000572c:	0cf70563          	beq	a4,a5,800057f6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005730:	4789                	li	a5,2
    80005732:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005736:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000573a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000573e:	f4c42783          	lw	a5,-180(s0)
    80005742:	0017c713          	xori	a4,a5,1
    80005746:	8b05                	andi	a4,a4,1
    80005748:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000574c:	0037f713          	andi	a4,a5,3
    80005750:	00e03733          	snez	a4,a4
    80005754:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005758:	4007f793          	andi	a5,a5,1024
    8000575c:	c791                	beqz	a5,80005768 <sys_open+0xd0>
    8000575e:	04449703          	lh	a4,68(s1)
    80005762:	4789                	li	a5,2
    80005764:	0af70063          	beq	a4,a5,80005804 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005768:	8526                	mv	a0,s1
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	046080e7          	jalr	70(ra) # 800037b0 <iunlock>
  end_op();
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	9c6080e7          	jalr	-1594(ra) # 80004138 <end_op>

  return fd;
    8000577a:	854a                	mv	a0,s2
}
    8000577c:	70ea                	ld	ra,184(sp)
    8000577e:	744a                	ld	s0,176(sp)
    80005780:	74aa                	ld	s1,168(sp)
    80005782:	790a                	ld	s2,160(sp)
    80005784:	69ea                	ld	s3,152(sp)
    80005786:	6129                	addi	sp,sp,192
    80005788:	8082                	ret
      end_op();
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	9ae080e7          	jalr	-1618(ra) # 80004138 <end_op>
      return -1;
    80005792:	557d                	li	a0,-1
    80005794:	b7e5                	j	8000577c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005796:	f5040513          	addi	a0,s0,-176
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	700080e7          	jalr	1792(ra) # 80003e9a <namei>
    800057a2:	84aa                	mv	s1,a0
    800057a4:	c905                	beqz	a0,800057d4 <sys_open+0x13c>
    ilock(ip);
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	f48080e7          	jalr	-184(ra) # 800036ee <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057ae:	04449703          	lh	a4,68(s1)
    800057b2:	4785                	li	a5,1
    800057b4:	f4f711e3          	bne	a4,a5,800056f6 <sys_open+0x5e>
    800057b8:	f4c42783          	lw	a5,-180(s0)
    800057bc:	d7b9                	beqz	a5,8000570a <sys_open+0x72>
      iunlockput(ip);
    800057be:	8526                	mv	a0,s1
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	190080e7          	jalr	400(ra) # 80003950 <iunlockput>
      end_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	970080e7          	jalr	-1680(ra) # 80004138 <end_op>
      return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	b76d                	j	8000577c <sys_open+0xe4>
      end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	964080e7          	jalr	-1692(ra) # 80004138 <end_op>
      return -1;
    800057dc:	557d                	li	a0,-1
    800057de:	bf79                	j	8000577c <sys_open+0xe4>
    iunlockput(ip);
    800057e0:	8526                	mv	a0,s1
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	16e080e7          	jalr	366(ra) # 80003950 <iunlockput>
    end_op();
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	94e080e7          	jalr	-1714(ra) # 80004138 <end_op>
    return -1;
    800057f2:	557d                	li	a0,-1
    800057f4:	b761                	j	8000577c <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057f6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057fa:	04649783          	lh	a5,70(s1)
    800057fe:	02f99223          	sh	a5,36(s3)
    80005802:	bf25                	j	8000573a <sys_open+0xa2>
    itrunc(ip);
    80005804:	8526                	mv	a0,s1
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	ff6080e7          	jalr	-10(ra) # 800037fc <itrunc>
    8000580e:	bfa9                	j	80005768 <sys_open+0xd0>
      fileclose(f);
    80005810:	854e                	mv	a0,s3
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	d70080e7          	jalr	-656(ra) # 80004582 <fileclose>
    iunlockput(ip);
    8000581a:	8526                	mv	a0,s1
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	134080e7          	jalr	308(ra) # 80003950 <iunlockput>
    end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	914080e7          	jalr	-1772(ra) # 80004138 <end_op>
    return -1;
    8000582c:	557d                	li	a0,-1
    8000582e:	b7b9                	j	8000577c <sys_open+0xe4>

0000000080005830 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005830:	7175                	addi	sp,sp,-144
    80005832:	e506                	sd	ra,136(sp)
    80005834:	e122                	sd	s0,128(sp)
    80005836:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	882080e7          	jalr	-1918(ra) # 800040ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005840:	08000613          	li	a2,128
    80005844:	f7040593          	addi	a1,s0,-144
    80005848:	4501                	li	a0,0
    8000584a:	ffffd097          	auipc	ra,0xffffd
    8000584e:	2c0080e7          	jalr	704(ra) # 80002b0a <argstr>
    80005852:	02054963          	bltz	a0,80005884 <sys_mkdir+0x54>
    80005856:	4681                	li	a3,0
    80005858:	4601                	li	a2,0
    8000585a:	4585                	li	a1,1
    8000585c:	f7040513          	addi	a0,s0,-144
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	7fc080e7          	jalr	2044(ra) # 8000505c <create>
    80005868:	cd11                	beqz	a0,80005884 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	0e6080e7          	jalr	230(ra) # 80003950 <iunlockput>
  end_op();
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	8c6080e7          	jalr	-1850(ra) # 80004138 <end_op>
  return 0;
    8000587a:	4501                	li	a0,0
}
    8000587c:	60aa                	ld	ra,136(sp)
    8000587e:	640a                	ld	s0,128(sp)
    80005880:	6149                	addi	sp,sp,144
    80005882:	8082                	ret
    end_op();
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	8b4080e7          	jalr	-1868(ra) # 80004138 <end_op>
    return -1;
    8000588c:	557d                	li	a0,-1
    8000588e:	b7fd                	j	8000587c <sys_mkdir+0x4c>

0000000080005890 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005890:	7135                	addi	sp,sp,-160
    80005892:	ed06                	sd	ra,152(sp)
    80005894:	e922                	sd	s0,144(sp)
    80005896:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	822080e7          	jalr	-2014(ra) # 800040ba <begin_op>
  argint(1, &major);
    800058a0:	f6c40593          	addi	a1,s0,-148
    800058a4:	4505                	li	a0,1
    800058a6:	ffffd097          	auipc	ra,0xffffd
    800058aa:	224080e7          	jalr	548(ra) # 80002aca <argint>
  argint(2, &minor);
    800058ae:	f6840593          	addi	a1,s0,-152
    800058b2:	4509                	li	a0,2
    800058b4:	ffffd097          	auipc	ra,0xffffd
    800058b8:	216080e7          	jalr	534(ra) # 80002aca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058bc:	08000613          	li	a2,128
    800058c0:	f7040593          	addi	a1,s0,-144
    800058c4:	4501                	li	a0,0
    800058c6:	ffffd097          	auipc	ra,0xffffd
    800058ca:	244080e7          	jalr	580(ra) # 80002b0a <argstr>
    800058ce:	02054b63          	bltz	a0,80005904 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058d2:	f6841683          	lh	a3,-152(s0)
    800058d6:	f6c41603          	lh	a2,-148(s0)
    800058da:	458d                	li	a1,3
    800058dc:	f7040513          	addi	a0,s0,-144
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	77c080e7          	jalr	1916(ra) # 8000505c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058e8:	cd11                	beqz	a0,80005904 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	066080e7          	jalr	102(ra) # 80003950 <iunlockput>
  end_op();
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	846080e7          	jalr	-1978(ra) # 80004138 <end_op>
  return 0;
    800058fa:	4501                	li	a0,0
}
    800058fc:	60ea                	ld	ra,152(sp)
    800058fe:	644a                	ld	s0,144(sp)
    80005900:	610d                	addi	sp,sp,160
    80005902:	8082                	ret
    end_op();
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	834080e7          	jalr	-1996(ra) # 80004138 <end_op>
    return -1;
    8000590c:	557d                	li	a0,-1
    8000590e:	b7fd                	j	800058fc <sys_mknod+0x6c>

0000000080005910 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005910:	7135                	addi	sp,sp,-160
    80005912:	ed06                	sd	ra,152(sp)
    80005914:	e922                	sd	s0,144(sp)
    80005916:	e526                	sd	s1,136(sp)
    80005918:	e14a                	sd	s2,128(sp)
    8000591a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000591c:	ffffc097          	auipc	ra,0xffffc
    80005920:	098080e7          	jalr	152(ra) # 800019b4 <myproc>
    80005924:	892a                	mv	s2,a0
  
  begin_op();
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	794080e7          	jalr	1940(ra) # 800040ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000592e:	08000613          	li	a2,128
    80005932:	f6040593          	addi	a1,s0,-160
    80005936:	4501                	li	a0,0
    80005938:	ffffd097          	auipc	ra,0xffffd
    8000593c:	1d2080e7          	jalr	466(ra) # 80002b0a <argstr>
    80005940:	04054b63          	bltz	a0,80005996 <sys_chdir+0x86>
    80005944:	f6040513          	addi	a0,s0,-160
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	552080e7          	jalr	1362(ra) # 80003e9a <namei>
    80005950:	84aa                	mv	s1,a0
    80005952:	c131                	beqz	a0,80005996 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	d9a080e7          	jalr	-614(ra) # 800036ee <ilock>
  if(ip->type != T_DIR){
    8000595c:	04449703          	lh	a4,68(s1)
    80005960:	4785                	li	a5,1
    80005962:	04f71063          	bne	a4,a5,800059a2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005966:	8526                	mv	a0,s1
    80005968:	ffffe097          	auipc	ra,0xffffe
    8000596c:	e48080e7          	jalr	-440(ra) # 800037b0 <iunlock>
  iput(p->cwd);
    80005970:	15093503          	ld	a0,336(s2)
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	f34080e7          	jalr	-204(ra) # 800038a8 <iput>
  end_op();
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	7bc080e7          	jalr	1980(ra) # 80004138 <end_op>
  p->cwd = ip;
    80005984:	14993823          	sd	s1,336(s2)
  return 0;
    80005988:	4501                	li	a0,0
}
    8000598a:	60ea                	ld	ra,152(sp)
    8000598c:	644a                	ld	s0,144(sp)
    8000598e:	64aa                	ld	s1,136(sp)
    80005990:	690a                	ld	s2,128(sp)
    80005992:	610d                	addi	sp,sp,160
    80005994:	8082                	ret
    end_op();
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	7a2080e7          	jalr	1954(ra) # 80004138 <end_op>
    return -1;
    8000599e:	557d                	li	a0,-1
    800059a0:	b7ed                	j	8000598a <sys_chdir+0x7a>
    iunlockput(ip);
    800059a2:	8526                	mv	a0,s1
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	fac080e7          	jalr	-84(ra) # 80003950 <iunlockput>
    end_op();
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	78c080e7          	jalr	1932(ra) # 80004138 <end_op>
    return -1;
    800059b4:	557d                	li	a0,-1
    800059b6:	bfd1                	j	8000598a <sys_chdir+0x7a>

00000000800059b8 <sys_exec>:

uint64
sys_exec(void)
{
    800059b8:	7145                	addi	sp,sp,-464
    800059ba:	e786                	sd	ra,456(sp)
    800059bc:	e3a2                	sd	s0,448(sp)
    800059be:	ff26                	sd	s1,440(sp)
    800059c0:	fb4a                	sd	s2,432(sp)
    800059c2:	f74e                	sd	s3,424(sp)
    800059c4:	f352                	sd	s4,416(sp)
    800059c6:	ef56                	sd	s5,408(sp)
    800059c8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059ca:	e3840593          	addi	a1,s0,-456
    800059ce:	4505                	li	a0,1
    800059d0:	ffffd097          	auipc	ra,0xffffd
    800059d4:	11a080e7          	jalr	282(ra) # 80002aea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059d8:	08000613          	li	a2,128
    800059dc:	f4040593          	addi	a1,s0,-192
    800059e0:	4501                	li	a0,0
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	128080e7          	jalr	296(ra) # 80002b0a <argstr>
    800059ea:	87aa                	mv	a5,a0
    return -1;
    800059ec:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800059ee:	0c07c363          	bltz	a5,80005ab4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800059f2:	10000613          	li	a2,256
    800059f6:	4581                	li	a1,0
    800059f8:	e4040513          	addi	a0,s0,-448
    800059fc:	ffffb097          	auipc	ra,0xffffb
    80005a00:	2d6080e7          	jalr	726(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a04:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a08:	89a6                	mv	s3,s1
    80005a0a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a0c:	02000a13          	li	s4,32
    80005a10:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a14:	00391513          	slli	a0,s2,0x3
    80005a18:	e3040593          	addi	a1,s0,-464
    80005a1c:	e3843783          	ld	a5,-456(s0)
    80005a20:	953e                	add	a0,a0,a5
    80005a22:	ffffd097          	auipc	ra,0xffffd
    80005a26:	00a080e7          	jalr	10(ra) # 80002a2c <fetchaddr>
    80005a2a:	02054a63          	bltz	a0,80005a5e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005a2e:	e3043783          	ld	a5,-464(s0)
    80005a32:	c3b9                	beqz	a5,80005a78 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a34:	ffffb097          	auipc	ra,0xffffb
    80005a38:	0b2080e7          	jalr	178(ra) # 80000ae6 <kalloc>
    80005a3c:	85aa                	mv	a1,a0
    80005a3e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a42:	cd11                	beqz	a0,80005a5e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a44:	6605                	lui	a2,0x1
    80005a46:	e3043503          	ld	a0,-464(s0)
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	034080e7          	jalr	52(ra) # 80002a7e <fetchstr>
    80005a52:	00054663          	bltz	a0,80005a5e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a56:	0905                	addi	s2,s2,1
    80005a58:	09a1                	addi	s3,s3,8
    80005a5a:	fb491be3          	bne	s2,s4,80005a10 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a5e:	f4040913          	addi	s2,s0,-192
    80005a62:	6088                	ld	a0,0(s1)
    80005a64:	c539                	beqz	a0,80005ab2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005a66:	ffffb097          	auipc	ra,0xffffb
    80005a6a:	f82080e7          	jalr	-126(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a6e:	04a1                	addi	s1,s1,8
    80005a70:	ff2499e3          	bne	s1,s2,80005a62 <sys_exec+0xaa>
  return -1;
    80005a74:	557d                	li	a0,-1
    80005a76:	a83d                	j	80005ab4 <sys_exec+0xfc>
      argv[i] = 0;
    80005a78:	0a8e                	slli	s5,s5,0x3
    80005a7a:	fc0a8793          	addi	a5,s5,-64
    80005a7e:	00878ab3          	add	s5,a5,s0
    80005a82:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a86:	e4040593          	addi	a1,s0,-448
    80005a8a:	f4040513          	addi	a0,s0,-192
    80005a8e:	fffff097          	auipc	ra,0xfffff
    80005a92:	16e080e7          	jalr	366(ra) # 80004bfc <exec>
    80005a96:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a98:	f4040993          	addi	s3,s0,-192
    80005a9c:	6088                	ld	a0,0(s1)
    80005a9e:	c901                	beqz	a0,80005aae <sys_exec+0xf6>
    kfree(argv[i]);
    80005aa0:	ffffb097          	auipc	ra,0xffffb
    80005aa4:	f48080e7          	jalr	-184(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aa8:	04a1                	addi	s1,s1,8
    80005aaa:	ff3499e3          	bne	s1,s3,80005a9c <sys_exec+0xe4>
  return ret;
    80005aae:	854a                	mv	a0,s2
    80005ab0:	a011                	j	80005ab4 <sys_exec+0xfc>
  return -1;
    80005ab2:	557d                	li	a0,-1
}
    80005ab4:	60be                	ld	ra,456(sp)
    80005ab6:	641e                	ld	s0,448(sp)
    80005ab8:	74fa                	ld	s1,440(sp)
    80005aba:	795a                	ld	s2,432(sp)
    80005abc:	79ba                	ld	s3,424(sp)
    80005abe:	7a1a                	ld	s4,416(sp)
    80005ac0:	6afa                	ld	s5,408(sp)
    80005ac2:	6179                	addi	sp,sp,464
    80005ac4:	8082                	ret

0000000080005ac6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ac6:	7139                	addi	sp,sp,-64
    80005ac8:	fc06                	sd	ra,56(sp)
    80005aca:	f822                	sd	s0,48(sp)
    80005acc:	f426                	sd	s1,40(sp)
    80005ace:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ad0:	ffffc097          	auipc	ra,0xffffc
    80005ad4:	ee4080e7          	jalr	-284(ra) # 800019b4 <myproc>
    80005ad8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ada:	fd840593          	addi	a1,s0,-40
    80005ade:	4501                	li	a0,0
    80005ae0:	ffffd097          	auipc	ra,0xffffd
    80005ae4:	00a080e7          	jalr	10(ra) # 80002aea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ae8:	fc840593          	addi	a1,s0,-56
    80005aec:	fd040513          	addi	a0,s0,-48
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	dc2080e7          	jalr	-574(ra) # 800048b2 <pipealloc>
    return -1;
    80005af8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005afa:	0c054463          	bltz	a0,80005bc2 <sys_pipe+0xfc>
  fd0 = -1;
    80005afe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b02:	fd043503          	ld	a0,-48(s0)
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	514080e7          	jalr	1300(ra) # 8000501a <fdalloc>
    80005b0e:	fca42223          	sw	a0,-60(s0)
    80005b12:	08054b63          	bltz	a0,80005ba8 <sys_pipe+0xe2>
    80005b16:	fc843503          	ld	a0,-56(s0)
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	500080e7          	jalr	1280(ra) # 8000501a <fdalloc>
    80005b22:	fca42023          	sw	a0,-64(s0)
    80005b26:	06054863          	bltz	a0,80005b96 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b2a:	4691                	li	a3,4
    80005b2c:	fc440613          	addi	a2,s0,-60
    80005b30:	fd843583          	ld	a1,-40(s0)
    80005b34:	68a8                	ld	a0,80(s1)
    80005b36:	ffffc097          	auipc	ra,0xffffc
    80005b3a:	b36080e7          	jalr	-1226(ra) # 8000166c <copyout>
    80005b3e:	02054063          	bltz	a0,80005b5e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b42:	4691                	li	a3,4
    80005b44:	fc040613          	addi	a2,s0,-64
    80005b48:	fd843583          	ld	a1,-40(s0)
    80005b4c:	0591                	addi	a1,a1,4
    80005b4e:	68a8                	ld	a0,80(s1)
    80005b50:	ffffc097          	auipc	ra,0xffffc
    80005b54:	b1c080e7          	jalr	-1252(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b58:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b5a:	06055463          	bgez	a0,80005bc2 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b5e:	fc442783          	lw	a5,-60(s0)
    80005b62:	07e9                	addi	a5,a5,26
    80005b64:	078e                	slli	a5,a5,0x3
    80005b66:	97a6                	add	a5,a5,s1
    80005b68:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b6c:	fc042783          	lw	a5,-64(s0)
    80005b70:	07e9                	addi	a5,a5,26
    80005b72:	078e                	slli	a5,a5,0x3
    80005b74:	94be                	add	s1,s1,a5
    80005b76:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b7a:	fd043503          	ld	a0,-48(s0)
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	a04080e7          	jalr	-1532(ra) # 80004582 <fileclose>
    fileclose(wf);
    80005b86:	fc843503          	ld	a0,-56(s0)
    80005b8a:	fffff097          	auipc	ra,0xfffff
    80005b8e:	9f8080e7          	jalr	-1544(ra) # 80004582 <fileclose>
    return -1;
    80005b92:	57fd                	li	a5,-1
    80005b94:	a03d                	j	80005bc2 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b96:	fc442783          	lw	a5,-60(s0)
    80005b9a:	0007c763          	bltz	a5,80005ba8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b9e:	07e9                	addi	a5,a5,26
    80005ba0:	078e                	slli	a5,a5,0x3
    80005ba2:	97a6                	add	a5,a5,s1
    80005ba4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ba8:	fd043503          	ld	a0,-48(s0)
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	9d6080e7          	jalr	-1578(ra) # 80004582 <fileclose>
    fileclose(wf);
    80005bb4:	fc843503          	ld	a0,-56(s0)
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	9ca080e7          	jalr	-1590(ra) # 80004582 <fileclose>
    return -1;
    80005bc0:	57fd                	li	a5,-1
}
    80005bc2:	853e                	mv	a0,a5
    80005bc4:	70e2                	ld	ra,56(sp)
    80005bc6:	7442                	ld	s0,48(sp)
    80005bc8:	74a2                	ld	s1,40(sp)
    80005bca:	6121                	addi	sp,sp,64
    80005bcc:	8082                	ret
	...

0000000080005bd0 <kernelvec>:
    80005bd0:	7111                	addi	sp,sp,-256
    80005bd2:	e006                	sd	ra,0(sp)
    80005bd4:	e40a                	sd	sp,8(sp)
    80005bd6:	e80e                	sd	gp,16(sp)
    80005bd8:	ec12                	sd	tp,24(sp)
    80005bda:	f016                	sd	t0,32(sp)
    80005bdc:	f41a                	sd	t1,40(sp)
    80005bde:	f81e                	sd	t2,48(sp)
    80005be0:	fc22                	sd	s0,56(sp)
    80005be2:	e0a6                	sd	s1,64(sp)
    80005be4:	e4aa                	sd	a0,72(sp)
    80005be6:	e8ae                	sd	a1,80(sp)
    80005be8:	ecb2                	sd	a2,88(sp)
    80005bea:	f0b6                	sd	a3,96(sp)
    80005bec:	f4ba                	sd	a4,104(sp)
    80005bee:	f8be                	sd	a5,112(sp)
    80005bf0:	fcc2                	sd	a6,120(sp)
    80005bf2:	e146                	sd	a7,128(sp)
    80005bf4:	e54a                	sd	s2,136(sp)
    80005bf6:	e94e                	sd	s3,144(sp)
    80005bf8:	ed52                	sd	s4,152(sp)
    80005bfa:	f156                	sd	s5,160(sp)
    80005bfc:	f55a                	sd	s6,168(sp)
    80005bfe:	f95e                	sd	s7,176(sp)
    80005c00:	fd62                	sd	s8,184(sp)
    80005c02:	e1e6                	sd	s9,192(sp)
    80005c04:	e5ea                	sd	s10,200(sp)
    80005c06:	e9ee                	sd	s11,208(sp)
    80005c08:	edf2                	sd	t3,216(sp)
    80005c0a:	f1f6                	sd	t4,224(sp)
    80005c0c:	f5fa                	sd	t5,232(sp)
    80005c0e:	f9fe                	sd	t6,240(sp)
    80005c10:	ce9fc0ef          	jal	ra,800028f8 <kerneltrap>
    80005c14:	6082                	ld	ra,0(sp)
    80005c16:	6122                	ld	sp,8(sp)
    80005c18:	61c2                	ld	gp,16(sp)
    80005c1a:	7282                	ld	t0,32(sp)
    80005c1c:	7322                	ld	t1,40(sp)
    80005c1e:	73c2                	ld	t2,48(sp)
    80005c20:	7462                	ld	s0,56(sp)
    80005c22:	6486                	ld	s1,64(sp)
    80005c24:	6526                	ld	a0,72(sp)
    80005c26:	65c6                	ld	a1,80(sp)
    80005c28:	6666                	ld	a2,88(sp)
    80005c2a:	7686                	ld	a3,96(sp)
    80005c2c:	7726                	ld	a4,104(sp)
    80005c2e:	77c6                	ld	a5,112(sp)
    80005c30:	7866                	ld	a6,120(sp)
    80005c32:	688a                	ld	a7,128(sp)
    80005c34:	692a                	ld	s2,136(sp)
    80005c36:	69ca                	ld	s3,144(sp)
    80005c38:	6a6a                	ld	s4,152(sp)
    80005c3a:	7a8a                	ld	s5,160(sp)
    80005c3c:	7b2a                	ld	s6,168(sp)
    80005c3e:	7bca                	ld	s7,176(sp)
    80005c40:	7c6a                	ld	s8,184(sp)
    80005c42:	6c8e                	ld	s9,192(sp)
    80005c44:	6d2e                	ld	s10,200(sp)
    80005c46:	6dce                	ld	s11,208(sp)
    80005c48:	6e6e                	ld	t3,216(sp)
    80005c4a:	7e8e                	ld	t4,224(sp)
    80005c4c:	7f2e                	ld	t5,232(sp)
    80005c4e:	7fce                	ld	t6,240(sp)
    80005c50:	6111                	addi	sp,sp,256
    80005c52:	10200073          	sret
    80005c56:	00000013          	nop
    80005c5a:	00000013          	nop
    80005c5e:	0001                	nop

0000000080005c60 <timervec>:
    80005c60:	34051573          	csrrw	a0,mscratch,a0
    80005c64:	e10c                	sd	a1,0(a0)
    80005c66:	e510                	sd	a2,8(a0)
    80005c68:	e914                	sd	a3,16(a0)
    80005c6a:	6d0c                	ld	a1,24(a0)
    80005c6c:	7110                	ld	a2,32(a0)
    80005c6e:	6194                	ld	a3,0(a1)
    80005c70:	96b2                	add	a3,a3,a2
    80005c72:	e194                	sd	a3,0(a1)
    80005c74:	4589                	li	a1,2
    80005c76:	14459073          	csrw	sip,a1
    80005c7a:	6914                	ld	a3,16(a0)
    80005c7c:	6510                	ld	a2,8(a0)
    80005c7e:	610c                	ld	a1,0(a0)
    80005c80:	34051573          	csrrw	a0,mscratch,a0
    80005c84:	30200073          	mret
	...

0000000080005c8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c8a:	1141                	addi	sp,sp,-16
    80005c8c:	e422                	sd	s0,8(sp)
    80005c8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c90:	0c0007b7          	lui	a5,0xc000
    80005c94:	4705                	li	a4,1
    80005c96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c98:	c3d8                	sw	a4,4(a5)
}
    80005c9a:	6422                	ld	s0,8(sp)
    80005c9c:	0141                	addi	sp,sp,16
    80005c9e:	8082                	ret

0000000080005ca0 <plicinithart>:

void
plicinithart(void)
{
    80005ca0:	1141                	addi	sp,sp,-16
    80005ca2:	e406                	sd	ra,8(sp)
    80005ca4:	e022                	sd	s0,0(sp)
    80005ca6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ca8:	ffffc097          	auipc	ra,0xffffc
    80005cac:	ce0080e7          	jalr	-800(ra) # 80001988 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cb0:	0085171b          	slliw	a4,a0,0x8
    80005cb4:	0c0027b7          	lui	a5,0xc002
    80005cb8:	97ba                	add	a5,a5,a4
    80005cba:	40200713          	li	a4,1026
    80005cbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cc2:	00d5151b          	slliw	a0,a0,0xd
    80005cc6:	0c2017b7          	lui	a5,0xc201
    80005cca:	97aa                	add	a5,a5,a0
    80005ccc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005cd0:	60a2                	ld	ra,8(sp)
    80005cd2:	6402                	ld	s0,0(sp)
    80005cd4:	0141                	addi	sp,sp,16
    80005cd6:	8082                	ret

0000000080005cd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cd8:	1141                	addi	sp,sp,-16
    80005cda:	e406                	sd	ra,8(sp)
    80005cdc:	e022                	sd	s0,0(sp)
    80005cde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ce0:	ffffc097          	auipc	ra,0xffffc
    80005ce4:	ca8080e7          	jalr	-856(ra) # 80001988 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ce8:	00d5151b          	slliw	a0,a0,0xd
    80005cec:	0c2017b7          	lui	a5,0xc201
    80005cf0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005cf2:	43c8                	lw	a0,4(a5)
    80005cf4:	60a2                	ld	ra,8(sp)
    80005cf6:	6402                	ld	s0,0(sp)
    80005cf8:	0141                	addi	sp,sp,16
    80005cfa:	8082                	ret

0000000080005cfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cfc:	1101                	addi	sp,sp,-32
    80005cfe:	ec06                	sd	ra,24(sp)
    80005d00:	e822                	sd	s0,16(sp)
    80005d02:	e426                	sd	s1,8(sp)
    80005d04:	1000                	addi	s0,sp,32
    80005d06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d08:	ffffc097          	auipc	ra,0xffffc
    80005d0c:	c80080e7          	jalr	-896(ra) # 80001988 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d10:	00d5151b          	slliw	a0,a0,0xd
    80005d14:	0c2017b7          	lui	a5,0xc201
    80005d18:	97aa                	add	a5,a5,a0
    80005d1a:	c3c4                	sw	s1,4(a5)
}
    80005d1c:	60e2                	ld	ra,24(sp)
    80005d1e:	6442                	ld	s0,16(sp)
    80005d20:	64a2                	ld	s1,8(sp)
    80005d22:	6105                	addi	sp,sp,32
    80005d24:	8082                	ret

0000000080005d26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d26:	1141                	addi	sp,sp,-16
    80005d28:	e406                	sd	ra,8(sp)
    80005d2a:	e022                	sd	s0,0(sp)
    80005d2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d2e:	479d                	li	a5,7
    80005d30:	04a7cc63          	blt	a5,a0,80005d88 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d34:	0001c797          	auipc	a5,0x1c
    80005d38:	f0c78793          	addi	a5,a5,-244 # 80021c40 <disk>
    80005d3c:	97aa                	add	a5,a5,a0
    80005d3e:	0187c783          	lbu	a5,24(a5)
    80005d42:	ebb9                	bnez	a5,80005d98 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d44:	00451693          	slli	a3,a0,0x4
    80005d48:	0001c797          	auipc	a5,0x1c
    80005d4c:	ef878793          	addi	a5,a5,-264 # 80021c40 <disk>
    80005d50:	6398                	ld	a4,0(a5)
    80005d52:	9736                	add	a4,a4,a3
    80005d54:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d58:	6398                	ld	a4,0(a5)
    80005d5a:	9736                	add	a4,a4,a3
    80005d5c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d60:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d64:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d68:	97aa                	add	a5,a5,a0
    80005d6a:	4705                	li	a4,1
    80005d6c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d70:	0001c517          	auipc	a0,0x1c
    80005d74:	ee850513          	addi	a0,a0,-280 # 80021c58 <disk+0x18>
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	348080e7          	jalr	840(ra) # 800020c0 <wakeup>
}
    80005d80:	60a2                	ld	ra,8(sp)
    80005d82:	6402                	ld	s0,0(sp)
    80005d84:	0141                	addi	sp,sp,16
    80005d86:	8082                	ret
    panic("free_desc 1");
    80005d88:	00003517          	auipc	a0,0x3
    80005d8c:	9d850513          	addi	a0,a0,-1576 # 80008760 <syscalls+0x310>
    80005d90:	ffffa097          	auipc	ra,0xffffa
    80005d94:	7b0080e7          	jalr	1968(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005d98:	00003517          	auipc	a0,0x3
    80005d9c:	9d850513          	addi	a0,a0,-1576 # 80008770 <syscalls+0x320>
    80005da0:	ffffa097          	auipc	ra,0xffffa
    80005da4:	7a0080e7          	jalr	1952(ra) # 80000540 <panic>

0000000080005da8 <virtio_disk_init>:
{
    80005da8:	1101                	addi	sp,sp,-32
    80005daa:	ec06                	sd	ra,24(sp)
    80005dac:	e822                	sd	s0,16(sp)
    80005dae:	e426                	sd	s1,8(sp)
    80005db0:	e04a                	sd	s2,0(sp)
    80005db2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005db4:	00003597          	auipc	a1,0x3
    80005db8:	9cc58593          	addi	a1,a1,-1588 # 80008780 <syscalls+0x330>
    80005dbc:	0001c517          	auipc	a0,0x1c
    80005dc0:	fac50513          	addi	a0,a0,-84 # 80021d68 <disk+0x128>
    80005dc4:	ffffb097          	auipc	ra,0xffffb
    80005dc8:	d82080e7          	jalr	-638(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dcc:	100017b7          	lui	a5,0x10001
    80005dd0:	4398                	lw	a4,0(a5)
    80005dd2:	2701                	sext.w	a4,a4
    80005dd4:	747277b7          	lui	a5,0x74727
    80005dd8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ddc:	14f71b63          	bne	a4,a5,80005f32 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005de0:	100017b7          	lui	a5,0x10001
    80005de4:	43dc                	lw	a5,4(a5)
    80005de6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005de8:	4709                	li	a4,2
    80005dea:	14e79463          	bne	a5,a4,80005f32 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dee:	100017b7          	lui	a5,0x10001
    80005df2:	479c                	lw	a5,8(a5)
    80005df4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005df6:	12e79e63          	bne	a5,a4,80005f32 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005dfa:	100017b7          	lui	a5,0x10001
    80005dfe:	47d8                	lw	a4,12(a5)
    80005e00:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e02:	554d47b7          	lui	a5,0x554d4
    80005e06:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e0a:	12f71463          	bne	a4,a5,80005f32 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e0e:	100017b7          	lui	a5,0x10001
    80005e12:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e16:	4705                	li	a4,1
    80005e18:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e1a:	470d                	li	a4,3
    80005e1c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e1e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e20:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e24:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc8ef>
    80005e28:	8f75                	and	a4,a4,a3
    80005e2a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e2c:	472d                	li	a4,11
    80005e2e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e30:	5bbc                	lw	a5,112(a5)
    80005e32:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e36:	8ba1                	andi	a5,a5,8
    80005e38:	10078563          	beqz	a5,80005f42 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e3c:	100017b7          	lui	a5,0x10001
    80005e40:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e44:	43fc                	lw	a5,68(a5)
    80005e46:	2781                	sext.w	a5,a5
    80005e48:	10079563          	bnez	a5,80005f52 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	5bdc                	lw	a5,52(a5)
    80005e52:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e54:	10078763          	beqz	a5,80005f62 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e58:	471d                	li	a4,7
    80005e5a:	10f77c63          	bgeu	a4,a5,80005f72 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e5e:	ffffb097          	auipc	ra,0xffffb
    80005e62:	c88080e7          	jalr	-888(ra) # 80000ae6 <kalloc>
    80005e66:	0001c497          	auipc	s1,0x1c
    80005e6a:	dda48493          	addi	s1,s1,-550 # 80021c40 <disk>
    80005e6e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e70:	ffffb097          	auipc	ra,0xffffb
    80005e74:	c76080e7          	jalr	-906(ra) # 80000ae6 <kalloc>
    80005e78:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e7a:	ffffb097          	auipc	ra,0xffffb
    80005e7e:	c6c080e7          	jalr	-916(ra) # 80000ae6 <kalloc>
    80005e82:	87aa                	mv	a5,a0
    80005e84:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e86:	6088                	ld	a0,0(s1)
    80005e88:	cd6d                	beqz	a0,80005f82 <virtio_disk_init+0x1da>
    80005e8a:	0001c717          	auipc	a4,0x1c
    80005e8e:	dbe73703          	ld	a4,-578(a4) # 80021c48 <disk+0x8>
    80005e92:	cb65                	beqz	a4,80005f82 <virtio_disk_init+0x1da>
    80005e94:	c7fd                	beqz	a5,80005f82 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005e96:	6605                	lui	a2,0x1
    80005e98:	4581                	li	a1,0
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	e38080e7          	jalr	-456(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ea2:	0001c497          	auipc	s1,0x1c
    80005ea6:	d9e48493          	addi	s1,s1,-610 # 80021c40 <disk>
    80005eaa:	6605                	lui	a2,0x1
    80005eac:	4581                	li	a1,0
    80005eae:	6488                	ld	a0,8(s1)
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	e22080e7          	jalr	-478(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005eb8:	6605                	lui	a2,0x1
    80005eba:	4581                	li	a1,0
    80005ebc:	6888                	ld	a0,16(s1)
    80005ebe:	ffffb097          	auipc	ra,0xffffb
    80005ec2:	e14080e7          	jalr	-492(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ec6:	100017b7          	lui	a5,0x10001
    80005eca:	4721                	li	a4,8
    80005ecc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ece:	4098                	lw	a4,0(s1)
    80005ed0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ed4:	40d8                	lw	a4,4(s1)
    80005ed6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005eda:	6498                	ld	a4,8(s1)
    80005edc:	0007069b          	sext.w	a3,a4
    80005ee0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005ee4:	9701                	srai	a4,a4,0x20
    80005ee6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005eea:	6898                	ld	a4,16(s1)
    80005eec:	0007069b          	sext.w	a3,a4
    80005ef0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ef4:	9701                	srai	a4,a4,0x20
    80005ef6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005efa:	4705                	li	a4,1
    80005efc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005efe:	00e48c23          	sb	a4,24(s1)
    80005f02:	00e48ca3          	sb	a4,25(s1)
    80005f06:	00e48d23          	sb	a4,26(s1)
    80005f0a:	00e48da3          	sb	a4,27(s1)
    80005f0e:	00e48e23          	sb	a4,28(s1)
    80005f12:	00e48ea3          	sb	a4,29(s1)
    80005f16:	00e48f23          	sb	a4,30(s1)
    80005f1a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f1e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f22:	0727a823          	sw	s2,112(a5)
}
    80005f26:	60e2                	ld	ra,24(sp)
    80005f28:	6442                	ld	s0,16(sp)
    80005f2a:	64a2                	ld	s1,8(sp)
    80005f2c:	6902                	ld	s2,0(sp)
    80005f2e:	6105                	addi	sp,sp,32
    80005f30:	8082                	ret
    panic("could not find virtio disk");
    80005f32:	00003517          	auipc	a0,0x3
    80005f36:	85e50513          	addi	a0,a0,-1954 # 80008790 <syscalls+0x340>
    80005f3a:	ffffa097          	auipc	ra,0xffffa
    80005f3e:	606080e7          	jalr	1542(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f42:	00003517          	auipc	a0,0x3
    80005f46:	86e50513          	addi	a0,a0,-1938 # 800087b0 <syscalls+0x360>
    80005f4a:	ffffa097          	auipc	ra,0xffffa
    80005f4e:	5f6080e7          	jalr	1526(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005f52:	00003517          	auipc	a0,0x3
    80005f56:	87e50513          	addi	a0,a0,-1922 # 800087d0 <syscalls+0x380>
    80005f5a:	ffffa097          	auipc	ra,0xffffa
    80005f5e:	5e6080e7          	jalr	1510(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80005f62:	00003517          	auipc	a0,0x3
    80005f66:	88e50513          	addi	a0,a0,-1906 # 800087f0 <syscalls+0x3a0>
    80005f6a:	ffffa097          	auipc	ra,0xffffa
    80005f6e:	5d6080e7          	jalr	1494(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	89e50513          	addi	a0,a0,-1890 # 80008810 <syscalls+0x3c0>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c6080e7          	jalr	1478(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	8ae50513          	addi	a0,a0,-1874 # 80008830 <syscalls+0x3e0>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b6080e7          	jalr	1462(ra) # 80000540 <panic>

0000000080005f92 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f92:	7119                	addi	sp,sp,-128
    80005f94:	fc86                	sd	ra,120(sp)
    80005f96:	f8a2                	sd	s0,112(sp)
    80005f98:	f4a6                	sd	s1,104(sp)
    80005f9a:	f0ca                	sd	s2,96(sp)
    80005f9c:	ecce                	sd	s3,88(sp)
    80005f9e:	e8d2                	sd	s4,80(sp)
    80005fa0:	e4d6                	sd	s5,72(sp)
    80005fa2:	e0da                	sd	s6,64(sp)
    80005fa4:	fc5e                	sd	s7,56(sp)
    80005fa6:	f862                	sd	s8,48(sp)
    80005fa8:	f466                	sd	s9,40(sp)
    80005faa:	f06a                	sd	s10,32(sp)
    80005fac:	ec6e                	sd	s11,24(sp)
    80005fae:	0100                	addi	s0,sp,128
    80005fb0:	8aaa                	mv	s5,a0
    80005fb2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fb4:	00c52d03          	lw	s10,12(a0)
    80005fb8:	001d1d1b          	slliw	s10,s10,0x1
    80005fbc:	1d02                	slli	s10,s10,0x20
    80005fbe:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005fc2:	0001c517          	auipc	a0,0x1c
    80005fc6:	da650513          	addi	a0,a0,-602 # 80021d68 <disk+0x128>
    80005fca:	ffffb097          	auipc	ra,0xffffb
    80005fce:	c0c080e7          	jalr	-1012(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005fd2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fd4:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fd6:	0001cb97          	auipc	s7,0x1c
    80005fda:	c6ab8b93          	addi	s7,s7,-918 # 80021c40 <disk>
  for(int i = 0; i < 3; i++){
    80005fde:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fe0:	0001cc97          	auipc	s9,0x1c
    80005fe4:	d88c8c93          	addi	s9,s9,-632 # 80021d68 <disk+0x128>
    80005fe8:	a08d                	j	8000604a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005fea:	00fb8733          	add	a4,s7,a5
    80005fee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ff2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ff4:	0207c563          	bltz	a5,8000601e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005ff8:	2905                	addiw	s2,s2,1
    80005ffa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ffc:	05690c63          	beq	s2,s6,80006054 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006000:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006002:	0001c717          	auipc	a4,0x1c
    80006006:	c3e70713          	addi	a4,a4,-962 # 80021c40 <disk>
    8000600a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000600c:	01874683          	lbu	a3,24(a4)
    80006010:	fee9                	bnez	a3,80005fea <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006012:	2785                	addiw	a5,a5,1
    80006014:	0705                	addi	a4,a4,1
    80006016:	fe979be3          	bne	a5,s1,8000600c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000601a:	57fd                	li	a5,-1
    8000601c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000601e:	01205d63          	blez	s2,80006038 <virtio_disk_rw+0xa6>
    80006022:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006024:	000a2503          	lw	a0,0(s4)
    80006028:	00000097          	auipc	ra,0x0
    8000602c:	cfe080e7          	jalr	-770(ra) # 80005d26 <free_desc>
      for(int j = 0; j < i; j++)
    80006030:	2d85                	addiw	s11,s11,1
    80006032:	0a11                	addi	s4,s4,4
    80006034:	ff2d98e3          	bne	s11,s2,80006024 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006038:	85e6                	mv	a1,s9
    8000603a:	0001c517          	auipc	a0,0x1c
    8000603e:	c1e50513          	addi	a0,a0,-994 # 80021c58 <disk+0x18>
    80006042:	ffffc097          	auipc	ra,0xffffc
    80006046:	01a080e7          	jalr	26(ra) # 8000205c <sleep>
  for(int i = 0; i < 3; i++){
    8000604a:	f8040a13          	addi	s4,s0,-128
{
    8000604e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006050:	894e                	mv	s2,s3
    80006052:	b77d                	j	80006000 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006054:	f8042503          	lw	a0,-128(s0)
    80006058:	00a50713          	addi	a4,a0,10
    8000605c:	0712                	slli	a4,a4,0x4

  if(write)
    8000605e:	0001c797          	auipc	a5,0x1c
    80006062:	be278793          	addi	a5,a5,-1054 # 80021c40 <disk>
    80006066:	00e786b3          	add	a3,a5,a4
    8000606a:	01803633          	snez	a2,s8
    8000606e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006070:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006074:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006078:	f6070613          	addi	a2,a4,-160
    8000607c:	6394                	ld	a3,0(a5)
    8000607e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006080:	00870593          	addi	a1,a4,8
    80006084:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006086:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006088:	0007b803          	ld	a6,0(a5)
    8000608c:	9642                	add	a2,a2,a6
    8000608e:	46c1                	li	a3,16
    80006090:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006092:	4585                	li	a1,1
    80006094:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006098:	f8442683          	lw	a3,-124(s0)
    8000609c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060a0:	0692                	slli	a3,a3,0x4
    800060a2:	9836                	add	a6,a6,a3
    800060a4:	058a8613          	addi	a2,s5,88
    800060a8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060ac:	0007b803          	ld	a6,0(a5)
    800060b0:	96c2                	add	a3,a3,a6
    800060b2:	40000613          	li	a2,1024
    800060b6:	c690                	sw	a2,8(a3)
  if(write)
    800060b8:	001c3613          	seqz	a2,s8
    800060bc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060c0:	00166613          	ori	a2,a2,1
    800060c4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060c8:	f8842603          	lw	a2,-120(s0)
    800060cc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060d0:	00250693          	addi	a3,a0,2
    800060d4:	0692                	slli	a3,a3,0x4
    800060d6:	96be                	add	a3,a3,a5
    800060d8:	58fd                	li	a7,-1
    800060da:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060de:	0612                	slli	a2,a2,0x4
    800060e0:	9832                	add	a6,a6,a2
    800060e2:	f9070713          	addi	a4,a4,-112
    800060e6:	973e                	add	a4,a4,a5
    800060e8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800060ec:	6398                	ld	a4,0(a5)
    800060ee:	9732                	add	a4,a4,a2
    800060f0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060f2:	4609                	li	a2,2
    800060f4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800060f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060fc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006100:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006104:	6794                	ld	a3,8(a5)
    80006106:	0026d703          	lhu	a4,2(a3)
    8000610a:	8b1d                	andi	a4,a4,7
    8000610c:	0706                	slli	a4,a4,0x1
    8000610e:	96ba                	add	a3,a3,a4
    80006110:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006114:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006118:	6798                	ld	a4,8(a5)
    8000611a:	00275783          	lhu	a5,2(a4)
    8000611e:	2785                	addiw	a5,a5,1
    80006120:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006124:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006130:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006134:	0001c917          	auipc	s2,0x1c
    80006138:	c3490913          	addi	s2,s2,-972 # 80021d68 <disk+0x128>
  while(b->disk == 1) {
    8000613c:	4485                	li	s1,1
    8000613e:	00b79c63          	bne	a5,a1,80006156 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006142:	85ca                	mv	a1,s2
    80006144:	8556                	mv	a0,s5
    80006146:	ffffc097          	auipc	ra,0xffffc
    8000614a:	f16080e7          	jalr	-234(ra) # 8000205c <sleep>
  while(b->disk == 1) {
    8000614e:	004aa783          	lw	a5,4(s5)
    80006152:	fe9788e3          	beq	a5,s1,80006142 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006156:	f8042903          	lw	s2,-128(s0)
    8000615a:	00290713          	addi	a4,s2,2
    8000615e:	0712                	slli	a4,a4,0x4
    80006160:	0001c797          	auipc	a5,0x1c
    80006164:	ae078793          	addi	a5,a5,-1312 # 80021c40 <disk>
    80006168:	97ba                	add	a5,a5,a4
    8000616a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000616e:	0001c997          	auipc	s3,0x1c
    80006172:	ad298993          	addi	s3,s3,-1326 # 80021c40 <disk>
    80006176:	00491713          	slli	a4,s2,0x4
    8000617a:	0009b783          	ld	a5,0(s3)
    8000617e:	97ba                	add	a5,a5,a4
    80006180:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006184:	854a                	mv	a0,s2
    80006186:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000618a:	00000097          	auipc	ra,0x0
    8000618e:	b9c080e7          	jalr	-1124(ra) # 80005d26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006192:	8885                	andi	s1,s1,1
    80006194:	f0ed                	bnez	s1,80006176 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006196:	0001c517          	auipc	a0,0x1c
    8000619a:	bd250513          	addi	a0,a0,-1070 # 80021d68 <disk+0x128>
    8000619e:	ffffb097          	auipc	ra,0xffffb
    800061a2:	aec080e7          	jalr	-1300(ra) # 80000c8a <release>
}
    800061a6:	70e6                	ld	ra,120(sp)
    800061a8:	7446                	ld	s0,112(sp)
    800061aa:	74a6                	ld	s1,104(sp)
    800061ac:	7906                	ld	s2,96(sp)
    800061ae:	69e6                	ld	s3,88(sp)
    800061b0:	6a46                	ld	s4,80(sp)
    800061b2:	6aa6                	ld	s5,72(sp)
    800061b4:	6b06                	ld	s6,64(sp)
    800061b6:	7be2                	ld	s7,56(sp)
    800061b8:	7c42                	ld	s8,48(sp)
    800061ba:	7ca2                	ld	s9,40(sp)
    800061bc:	7d02                	ld	s10,32(sp)
    800061be:	6de2                	ld	s11,24(sp)
    800061c0:	6109                	addi	sp,sp,128
    800061c2:	8082                	ret

00000000800061c4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061c4:	1101                	addi	sp,sp,-32
    800061c6:	ec06                	sd	ra,24(sp)
    800061c8:	e822                	sd	s0,16(sp)
    800061ca:	e426                	sd	s1,8(sp)
    800061cc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061ce:	0001c497          	auipc	s1,0x1c
    800061d2:	a7248493          	addi	s1,s1,-1422 # 80021c40 <disk>
    800061d6:	0001c517          	auipc	a0,0x1c
    800061da:	b9250513          	addi	a0,a0,-1134 # 80021d68 <disk+0x128>
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	9f8080e7          	jalr	-1544(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061e6:	10001737          	lui	a4,0x10001
    800061ea:	533c                	lw	a5,96(a4)
    800061ec:	8b8d                	andi	a5,a5,3
    800061ee:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061f0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061f4:	689c                	ld	a5,16(s1)
    800061f6:	0204d703          	lhu	a4,32(s1)
    800061fa:	0027d783          	lhu	a5,2(a5)
    800061fe:	04f70863          	beq	a4,a5,8000624e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006202:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006206:	6898                	ld	a4,16(s1)
    80006208:	0204d783          	lhu	a5,32(s1)
    8000620c:	8b9d                	andi	a5,a5,7
    8000620e:	078e                	slli	a5,a5,0x3
    80006210:	97ba                	add	a5,a5,a4
    80006212:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006214:	00278713          	addi	a4,a5,2
    80006218:	0712                	slli	a4,a4,0x4
    8000621a:	9726                	add	a4,a4,s1
    8000621c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006220:	e721                	bnez	a4,80006268 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006222:	0789                	addi	a5,a5,2
    80006224:	0792                	slli	a5,a5,0x4
    80006226:	97a6                	add	a5,a5,s1
    80006228:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000622a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000622e:	ffffc097          	auipc	ra,0xffffc
    80006232:	e92080e7          	jalr	-366(ra) # 800020c0 <wakeup>

    disk.used_idx += 1;
    80006236:	0204d783          	lhu	a5,32(s1)
    8000623a:	2785                	addiw	a5,a5,1
    8000623c:	17c2                	slli	a5,a5,0x30
    8000623e:	93c1                	srli	a5,a5,0x30
    80006240:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006244:	6898                	ld	a4,16(s1)
    80006246:	00275703          	lhu	a4,2(a4)
    8000624a:	faf71ce3          	bne	a4,a5,80006202 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000624e:	0001c517          	auipc	a0,0x1c
    80006252:	b1a50513          	addi	a0,a0,-1254 # 80021d68 <disk+0x128>
    80006256:	ffffb097          	auipc	ra,0xffffb
    8000625a:	a34080e7          	jalr	-1484(ra) # 80000c8a <release>
}
    8000625e:	60e2                	ld	ra,24(sp)
    80006260:	6442                	ld	s0,16(sp)
    80006262:	64a2                	ld	s1,8(sp)
    80006264:	6105                	addi	sp,sp,32
    80006266:	8082                	ret
      panic("virtio_disk_intr status");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	5e050513          	addi	a0,a0,1504 # 80008848 <syscalls+0x3f8>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2d0080e7          	jalr	720(ra) # 80000540 <panic>

0000000080006278 <petersonlock_init>:
#include "proc.h" // בשביל yield()

struct peterson_lock peterson_locks[MAX_PETERSON_LOCKS];

void
petersonlock_init() {
    80006278:	1141                	addi	sp,sp,-16
    8000627a:	e422                	sd	s0,8(sp)
    8000627c:	0800                	addi	s0,sp,16
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    8000627e:	0001c797          	auipc	a5,0x1c
    80006282:	b0278793          	addi	a5,a5,-1278 # 80021d80 <peterson_locks>
    80006286:	0001c717          	auipc	a4,0x1c
    8000628a:	bea70713          	addi	a4,a4,-1046 # 80021e70 <end>
        peterson_locks[i].active = 0;
    8000628e:	0007a023          	sw	zero,0(a5)
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    80006292:	07c1                	addi	a5,a5,16
    80006294:	fee79de3          	bne	a5,a4,8000628e <petersonlock_init+0x16>
    }
}
    80006298:	6422                	ld	s0,8(sp)
    8000629a:	0141                	addi	sp,sp,16
    8000629c:	8082                	ret

000000008000629e <petersonlock_create>:

int
petersonlock_create() {
    8000629e:	1141                	addi	sp,sp,-16
    800062a0:	e422                	sd	s0,8(sp)
    800062a2:	0800                	addi	s0,sp,16
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    800062a4:	0001c797          	auipc	a5,0x1c
    800062a8:	adc78793          	addi	a5,a5,-1316 # 80021d80 <peterson_locks>
    800062ac:	4501                	li	a0,0
    800062ae:	46bd                	li	a3,15
        if (peterson_locks[i].active == 0) {
    800062b0:	4398                	lw	a4,0(a5)
    800062b2:	cb09                	beqz	a4,800062c4 <petersonlock_create+0x26>
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    800062b4:	2505                	addiw	a0,a0,1
    800062b6:	07c1                	addi	a5,a5,16
    800062b8:	fed51ce3          	bne	a0,a3,800062b0 <petersonlock_create+0x12>
            peterson_locks[i].flag[1] = 0;
            peterson_locks[i].turn = 0;
            return i;
        }
    }
    return -1;
    800062bc:	557d                	li	a0,-1
}
    800062be:	6422                	ld	s0,8(sp)
    800062c0:	0141                	addi	sp,sp,16
    800062c2:	8082                	ret
            peterson_locks[i].active = 1;
    800062c4:	00451713          	slli	a4,a0,0x4
    800062c8:	0001c797          	auipc	a5,0x1c
    800062cc:	ab878793          	addi	a5,a5,-1352 # 80021d80 <peterson_locks>
    800062d0:	97ba                	add	a5,a5,a4
    800062d2:	4705                	li	a4,1
    800062d4:	c398                	sw	a4,0(a5)
            peterson_locks[i].flag[0] = 0;
    800062d6:	0007a223          	sw	zero,4(a5)
            peterson_locks[i].flag[1] = 0;
    800062da:	0007a423          	sw	zero,8(a5)
            peterson_locks[i].turn = 0;
    800062de:	0007a623          	sw	zero,12(a5)
            return i;
    800062e2:	bff1                	j	800062be <petersonlock_create+0x20>

00000000800062e4 <petersonlock_acquire>:

int
petersonlock_acquire(int lock_id, int role) {
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
    800062e4:	4739                	li	a4,14
    800062e6:	08a76463          	bltu	a4,a0,8000636e <petersonlock_acquire+0x8a>
    800062ea:	87aa                	mv	a5,a0
    800062ec:	00451693          	slli	a3,a0,0x4
    800062f0:	0001c717          	auipc	a4,0x1c
    800062f4:	a9070713          	addi	a4,a4,-1392 # 80021d80 <peterson_locks>
    800062f8:	9736                	add	a4,a4,a3
    800062fa:	4318                	lw	a4,0(a4)
    800062fc:	cb3d                	beqz	a4,80006372 <petersonlock_acquire+0x8e>
petersonlock_acquire(int lock_id, int role) {
    800062fe:	7179                	addi	sp,sp,-48
    80006300:	f406                	sd	ra,40(sp)
    80006302:	f022                	sd	s0,32(sp)
    80006304:	ec26                	sd	s1,24(sp)
    80006306:	e84a                	sd	s2,16(sp)
    80006308:	e44e                	sd	s3,8(sp)
    8000630a:	1800                	addi	s0,sp,48
        return -1;

    struct peterson_lock *lock = &peterson_locks[lock_id];
    int other = 1 - role;
    8000630c:	4605                	li	a2,1
    8000630e:	9e0d                	subw	a2,a2,a1
    80006310:	0006091b          	sext.w	s2,a2

    lock->flag[role] = 1;
    80006314:	0001c697          	auipc	a3,0x1c
    80006318:	a6c68693          	addi	a3,a3,-1428 # 80021d80 <peterson_locks>
    8000631c:	00251713          	slli	a4,a0,0x2
    80006320:	95ba                	add	a1,a1,a4
    80006322:	058a                	slli	a1,a1,0x2
    80006324:	95b6                	add	a1,a1,a3
    80006326:	4505                	li	a0,1
    80006328:	c1c8                	sw	a0,4(a1)
    __sync_synchronize();
    8000632a:	0ff0000f          	fence
    lock->turn = other;
    8000632e:	00479593          	slli	a1,a5,0x4
    80006332:	95b6                	add	a1,a1,a3
    80006334:	c5d0                	sw	a2,12(a1)
    __sync_synchronize();
    80006336:	0ff0000f          	fence

    while (lock->flag[other] && lock->turn == other) {
    8000633a:	974a                	add	a4,a4,s2
    8000633c:	070a                	slli	a4,a4,0x2
    8000633e:	96ba                	add	a3,a3,a4
    80006340:	42c8                	lw	a0,4(a3)
    80006342:	cd19                	beqz	a0,80006360 <petersonlock_acquire+0x7c>
    80006344:	89ae                	mv	s3,a1
    80006346:	84b6                	mv	s1,a3
    80006348:	00c9a783          	lw	a5,12(s3)
    8000634c:	01279963          	bne	a5,s2,8000635e <petersonlock_acquire+0x7a>
        yield();
    80006350:	ffffc097          	auipc	ra,0xffffc
    80006354:	cd0080e7          	jalr	-816(ra) # 80002020 <yield>
    while (lock->flag[other] && lock->turn == other) {
    80006358:	40c8                	lw	a0,4(s1)
    8000635a:	f57d                	bnez	a0,80006348 <petersonlock_acquire+0x64>
    8000635c:	a011                	j	80006360 <petersonlock_acquire+0x7c>
    }

    return 0;
    8000635e:	4501                	li	a0,0
}
    80006360:	70a2                	ld	ra,40(sp)
    80006362:	7402                	ld	s0,32(sp)
    80006364:	64e2                	ld	s1,24(sp)
    80006366:	6942                	ld	s2,16(sp)
    80006368:	69a2                	ld	s3,8(sp)
    8000636a:	6145                	addi	sp,sp,48
    8000636c:	8082                	ret
        return -1;
    8000636e:	557d                	li	a0,-1
    80006370:	8082                	ret
    80006372:	557d                	li	a0,-1
}
    80006374:	8082                	ret

0000000080006376 <petersonlock_release>:

int
petersonlock_release(int lock_id, int role) {
    80006376:	1141                	addi	sp,sp,-16
    80006378:	e422                	sd	s0,8(sp)
    8000637a:	0800                	addi	s0,sp,16
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
    8000637c:	4739                	li	a4,14
    8000637e:	04a76763          	bltu	a4,a0,800063cc <petersonlock_release+0x56>
    80006382:	00451693          	slli	a3,a0,0x4
    80006386:	0001c717          	auipc	a4,0x1c
    8000638a:	9fa70713          	addi	a4,a4,-1542 # 80021d80 <peterson_locks>
    8000638e:	9736                	add	a4,a4,a3
    80006390:	4318                	lw	a4,0(a4)
    80006392:	cf1d                	beqz	a4,800063d0 <petersonlock_release+0x5a>
        return -1;

    struct peterson_lock *lock = &peterson_locks[lock_id];

    __sync_synchronize();
    80006394:	0ff0000f          	fence
    lock->flag[role] = 0;
    80006398:	0001c697          	auipc	a3,0x1c
    8000639c:	9e868693          	addi	a3,a3,-1560 # 80021d80 <peterson_locks>
    800063a0:	00251793          	slli	a5,a0,0x2
    800063a4:	00b78733          	add	a4,a5,a1
    800063a8:	070a                	slli	a4,a4,0x2
    800063aa:	9736                	add	a4,a4,a3
    800063ac:	00072223          	sw	zero,4(a4)
    __sync_lock_release(&lock->flag[role]);
    800063b0:	0585                	addi	a1,a1,1
    800063b2:	97ae                	add	a5,a5,a1
    800063b4:	078a                	slli	a5,a5,0x2
    800063b6:	96be                	add	a3,a3,a5
    800063b8:	0f50000f          	fence	iorw,ow
    800063bc:	0806a02f          	amoswap.w	zero,zero,(a3)
    __sync_synchronize();
    800063c0:	0ff0000f          	fence

    return 0;
    800063c4:	4501                	li	a0,0
}
    800063c6:	6422                	ld	s0,8(sp)
    800063c8:	0141                	addi	sp,sp,16
    800063ca:	8082                	ret
        return -1;
    800063cc:	557d                	li	a0,-1
    800063ce:	bfe5                	j	800063c6 <petersonlock_release+0x50>
    800063d0:	557d                	li	a0,-1
    800063d2:	bfd5                	j	800063c6 <petersonlock_release+0x50>

00000000800063d4 <petersonlock_destroy>:

int
petersonlock_destroy(int lock_id) {
    800063d4:	1141                	addi	sp,sp,-16
    800063d6:	e422                	sd	s0,8(sp)
    800063d8:	0800                	addi	s0,sp,16
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
    800063da:	4739                	li	a4,14
    800063dc:	02a76763          	bltu	a4,a0,8000640a <petersonlock_destroy+0x36>
    800063e0:	00451693          	slli	a3,a0,0x4
    800063e4:	0001c717          	auipc	a4,0x1c
    800063e8:	99c70713          	addi	a4,a4,-1636 # 80021d80 <peterson_locks>
    800063ec:	9736                	add	a4,a4,a3
    800063ee:	4318                	lw	a4,0(a4)
    800063f0:	cf19                	beqz	a4,8000640e <petersonlock_destroy+0x3a>
        return -1;

    peterson_locks[lock_id].active = 0;
    800063f2:	0001c717          	auipc	a4,0x1c
    800063f6:	98e70713          	addi	a4,a4,-1650 # 80021d80 <peterson_locks>
    800063fa:	00d707b3          	add	a5,a4,a3
    800063fe:	0007a023          	sw	zero,0(a5)
    return 0;
    80006402:	4501                	li	a0,0
}
    80006404:	6422                	ld	s0,8(sp)
    80006406:	0141                	addi	sp,sp,16
    80006408:	8082                	ret
        return -1;
    8000640a:	557d                	li	a0,-1
    8000640c:	bfe5                	j	80006404 <petersonlock_destroy+0x30>
    8000640e:	557d                	li	a0,-1
    80006410:	bfd5                	j	80006404 <petersonlock_destroy+0x30>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...

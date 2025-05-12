
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a3010113          	addi	sp,sp,-1488 # 80008a30 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	89e70713          	addi	a4,a4,-1890 # 800088f0 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	bfc78793          	addi	a5,a5,-1028 # 80005c60 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc9af>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	38e080e7          	jalr	910(ra) # 800024ba <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
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
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

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
    8000018e:	8a650513          	addi	a0,a0,-1882 # 80010a30 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	89648493          	addi	s1,s1,-1898 # 80010a30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	92690913          	addi	s2,s2,-1754 # 80010ac8 <cons+0x98>
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
    8000022a:	80a50513          	addi	a0,a0,-2038 # 80010a30 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00010517          	auipc	a0,0x10
    80000240:	7f450513          	addi	a0,a0,2036 # 80010a30 <cons>
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
    80000276:	84f72b23          	sw	a5,-1962(a4) # 80010ac8 <cons+0x98>
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
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
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
    800002d0:	76450513          	addi	a0,a0,1892 # 80010a30 <cons>
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
    800002fe:	73650513          	addi	a0,a0,1846 # 80010a30 <cons>
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
    80000322:	71270713          	addi	a4,a4,1810 # 80010a30 <cons>
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
    8000034c:	6e878793          	addi	a5,a5,1768 # 80010a30 <cons>
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
    8000037a:	7527a783          	lw	a5,1874(a5) # 80010ac8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6a670713          	addi	a4,a4,1702 # 80010a30 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	69648493          	addi	s1,s1,1686 # 80010a30 <cons>
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
    800003da:	65a70713          	addi	a4,a4,1626 # 80010a30 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72223          	sw	a5,1764(a4) # 80010ad0 <cons+0xa0>
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
    80000416:	61e78793          	addi	a5,a5,1566 # 80010a30 <cons>
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
    8000043a:	68c7ab23          	sw	a2,1686(a5) # 80010acc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	68a50513          	addi	a0,a0,1674 # 80010ac8 <cons+0x98>
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
    80000464:	5d050513          	addi	a0,a0,1488 # 80010a30 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	75078793          	addi	a5,a5,1872 # 80020bc8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
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
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
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
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5a07a323          	sw	zero,1446(a5) # 80010af0 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	32f72923          	sw	a5,818(a4) # 800088b0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	536dad83          	lw	s11,1334(s11) # 80010af0 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	4e050513          	addi	a0,a0,1248 # 80010ad8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	38250513          	addi	a0,a0,898 # 80010ad8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	36648493          	addi	s1,s1,870 # 80010ad8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	32650513          	addi	a0,a0,806 # 80010af8 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0b27a783          	lw	a5,178(a5) # 800088b0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0827b783          	ld	a5,130(a5) # 800088b8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	08273703          	ld	a4,130(a4) # 800088c0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	298a0a13          	addi	s4,s4,664 # 80010af8 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	05048493          	addi	s1,s1,80 # 800088b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	05098993          	addi	s3,s3,80 # 800088c0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	82e080e7          	jalr	-2002(ra) # 800020c0 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	22a50513          	addi	a0,a0,554 # 80010af8 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fd27a783          	lw	a5,-46(a5) # 800088b0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fd873703          	ld	a4,-40(a4) # 800088c0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fc87b783          	ld	a5,-56(a5) # 800088b8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	1fc98993          	addi	s3,s3,508 # 80010af8 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fb448493          	addi	s1,s1,-76 # 800088b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fb490913          	addi	s2,s2,-76 # 800088c0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	740080e7          	jalr	1856(ra) # 8000205c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1c648493          	addi	s1,s1,454 # 80010af8 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f6e7bd23          	sd	a4,-134(a5) # 800088c0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	13c48493          	addi	s1,s1,316 # 80010af8 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00021797          	auipc	a5,0x21
    80000a02:	45278793          	addi	a5,a5,1106 # 80021e50 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	11290913          	addi	s2,s2,274 # 80010b30 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
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
    80000abe:	07650513          	addi	a0,a0,118 # 80010b30 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	38250513          	addi	a0,a0,898 # 80021e50 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
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
    80000af4:	04048493          	addi	s1,s1,64 # 80010b30 <kmem>
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
    80000b0c:	02850513          	addi	a0,a0,40 # 80010b30 <kmem>
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
    80000b38:	ffc50513          	addi	a0,a0,-4 # 80010b30 <kmem>
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
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

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
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

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
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

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
    80000cfc:	fff6069b          	addiw	a3,a2,-1
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
    80000d46:	0705                	addi	a4,a4,1
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
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
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
    80000e8c:	a4070713          	addi	a4,a4,-1472 # 800088c8 <started>
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
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	792080e7          	jalr	1938(ra) # 80002650 <trapinithart>
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
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
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
    80000f3a:	6f2080e7          	jalr	1778(ra) # 80002628 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	712080e7          	jalr	1810(ra) # 80002650 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	d44080e7          	jalr	-700(ra) # 80005c8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	d52080e7          	jalr	-686(ra) # 80005ca0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	ef0080e7          	jalr	-272(ra) # 80002e46 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	594080e7          	jalr	1428(ra) # 800034f2 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	532080e7          	jalr	1330(ra) # 80004498 <fileinit>
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
    80000f88:	94f72223          	sw	a5,-1724(a4) # 800088c8 <started>
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
    80000f9c:	9387b783          	ld	a5,-1736(a5) # 800088d0 <kernel_pagetable>
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
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
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
    80001016:	3a5d                	addiw	s4,s4,-9
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
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
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
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
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
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
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
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

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
    8000121e:	15fd                	addi	a1,a1,-1
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
    80001258:	66a7be23          	sd	a0,1660(a5) # 800088d0 <kernel_pagetable>
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
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
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
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
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
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

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
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
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
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
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
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
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
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
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
    80001850:	73448493          	addi	s1,s1,1844 # 80010f80 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	11aa0a13          	addi	s4,s4,282 # 80016980 <tickslock>
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
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

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
    800018ec:	26850513          	addi	a0,a0,616 # 80010b50 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	26850513          	addi	a0,a0,616 # 80010b68 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	67048493          	addi	s1,s1,1648 # 80010f80 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	04e98993          	addi	s3,s3,78 # 80016980 <tickslock>
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
    80001970:	910080e7          	jalr	-1776(ra) # 8000627c <petersonlock_init>
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
    800019a8:	1dc50513          	addi	a0,a0,476 # 80010b80 <cpus>
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
    800019d0:	18470713          	addi	a4,a4,388 # 80010b50 <pid_lock>
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
    80001a12:	c5a080e7          	jalr	-934(ra) # 80002668 <usertrapret>
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
    80001a2c:	a4a080e7          	jalr	-1462(ra) # 80003472 <fsinit>
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
    80001a42:	11290913          	addi	s2,s2,274 # 80010b50 <pid_lock>
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
    80001aa2:	15fd                	addi	a1,a1,-1
    80001aa4:	05b2                	slli	a1,a1,0xc
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5f8080e7          	jalr	1528(ra) # 8000109e <mappages>
    80001aae:	02054863          	bltz	a0,80001ade <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ab2:	4719                	li	a4,6
    80001ab4:	05893683          	ld	a3,88(s2)
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	020005b7          	lui	a1,0x2000
    80001abe:	15fd                	addi	a1,a1,-1
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
    80001ae6:	a4a080e7          	jalr	-1462(ra) # 8000152c <uvmfree>
    return 0;
    80001aea:	4481                	li	s1,0
    80001aec:	b7d5                	j	80001ad0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	8526                	mv	a0,s1
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	768080e7          	jalr	1896(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b04:	4581                	li	a1,0
    80001b06:	8526                	mv	a0,s1
    80001b08:	00000097          	auipc	ra,0x0
    80001b0c:	a24080e7          	jalr	-1500(ra) # 8000152c <uvmfree>
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
    80001b2c:	15fd                	addi	a1,a1,-1
    80001b2e:	05b2                	slli	a1,a1,0xc
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	734080e7          	jalr	1844(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	71e080e7          	jalr	1822(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	9da080e7          	jalr	-1574(ra) # 8000152c <uvmfree>
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
    80001b7a:	e74080e7          	jalr	-396(ra) # 800009ea <kfree>
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
    80001bce:	3b648493          	addi	s1,s1,950 # 80010f80 <proc>
    80001bd2:	00015917          	auipc	s2,0x15
    80001bd6:	dae90913          	addi	s2,s2,-594 # 80016980 <tickslock>
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
    80001ca4:	c2a7bc23          	sd	a0,-968(a5) # 800088d8 <initproc>
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
    80001cee:	1aa080e7          	jalr	426(ra) # 80003e94 <namei>
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
    80001da2:	7c6080e7          	jalr	1990(ra) # 80001564 <uvmcopy>
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
    80001e1e:	710080e7          	jalr	1808(ra) # 8000452a <filedup>
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
    80001e5c:	d1048493          	addi	s1,s1,-752 # 80010b68 <wait_lock>
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
    80001eca:	c8a70713          	addi	a4,a4,-886 # 80010b50 <pid_lock>
    80001ece:	9756                	add	a4,a4,s5
    80001ed0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	cb470713          	addi	a4,a4,-844 # 80010b88 <cpus+0x8>
    80001edc:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ede:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee0:	4b11                	li	s6,4
        c->proc = p;
    80001ee2:	079e                	slli	a5,a5,0x7
    80001ee4:	0000fa17          	auipc	s4,0xf
    80001ee8:	c6ca0a13          	addi	s4,s4,-916 # 80010b50 <pid_lock>
    80001eec:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eee:	00015917          	auipc	s2,0x15
    80001ef2:	a9290913          	addi	s2,s2,-1390 # 80016980 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efe:	10079073          	csrw	sstatus,a5
    80001f02:	0000f497          	auipc	s1,0xf
    80001f06:	07e48493          	addi	s1,s1,126 # 80010f80 <proc>
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
    80001f40:	682080e7          	jalr	1666(ra) # 800025be <swtch>
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
    80001f76:	bde70713          	addi	a4,a4,-1058 # 80010b50 <pid_lock>
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
    80001f9c:	bb890913          	addi	s2,s2,-1096 # 80010b50 <pid_lock>
    80001fa0:	2781                	sext.w	a5,a5
    80001fa2:	079e                	slli	a5,a5,0x7
    80001fa4:	97ca                	add	a5,a5,s2
    80001fa6:	0ac7a983          	lw	s3,172(a5)
    80001faa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
    80001fb0:	0000f597          	auipc	a1,0xf
    80001fb4:	bd858593          	addi	a1,a1,-1064 # 80010b88 <cpus+0x8>
    80001fb8:	95be                	add	a1,a1,a5
    80001fba:	06048513          	addi	a0,s1,96
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	600080e7          	jalr	1536(ra) # 800025be <swtch>
    80001fc6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc8:	2781                	sext.w	a5,a5
    80001fca:	079e                	slli	a5,a5,0x7
    80001fcc:	97ca                	add	a5,a5,s2
    80001fce:	0b37a623          	sw	s3,172(a5)
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
    80001fec:	556080e7          	jalr	1366(ra) # 8000053e <panic>
    panic("sched locks");
    80001ff0:	00006517          	auipc	a0,0x6
    80001ff4:	23850513          	addi	a0,a0,568 # 80008228 <digits+0x1e8>
    80001ff8:	ffffe097          	auipc	ra,0xffffe
    80001ffc:	546080e7          	jalr	1350(ra) # 8000053e <panic>
    panic("sched running");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	23850513          	addi	a0,a0,568 # 80008238 <digits+0x1f8>
    80002008:	ffffe097          	auipc	ra,0xffffe
    8000200c:	536080e7          	jalr	1334(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	23850513          	addi	a0,a0,568 # 80008248 <digits+0x208>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	526080e7          	jalr	1318(ra) # 8000053e <panic>

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
    800020d8:	eac48493          	addi	s1,s1,-340 # 80010f80 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020dc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020de:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e0:	00015917          	auipc	s2,0x15
    800020e4:	8a090913          	addi	s2,s2,-1888 # 80016980 <tickslock>
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
    8000214c:	e3848493          	addi	s1,s1,-456 # 80010f80 <proc>
      pp->parent = initproc;
    80002150:	00006a17          	auipc	s4,0x6
    80002154:	788a0a13          	addi	s4,s4,1928 # 800088d8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002158:	00015997          	auipc	s3,0x15
    8000215c:	82898993          	addi	s3,s3,-2008 # 80016980 <tickslock>
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
    800021b0:	72c7b783          	ld	a5,1836(a5) # 800088d8 <initproc>
    800021b4:	0d050493          	addi	s1,a0,208
    800021b8:	15050913          	addi	s2,a0,336
    800021bc:	02a79363          	bne	a5,a0,800021e2 <exit+0x52>
    panic("init exiting");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	0a050513          	addi	a0,a0,160 # 80008260 <digits+0x220>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	376080e7          	jalr	886(ra) # 8000053e <panic>
      fileclose(f);
    800021d0:	00002097          	auipc	ra,0x2
    800021d4:	3ac080e7          	jalr	940(ra) # 8000457c <fileclose>
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
    800021ec:	ec8080e7          	jalr	-312(ra) # 800040b0 <begin_op>
  iput(p->cwd);
    800021f0:	1509b503          	ld	a0,336(s3)
    800021f4:	00001097          	auipc	ra,0x1
    800021f8:	6b4080e7          	jalr	1716(ra) # 800038a8 <iput>
  end_op();
    800021fc:	00002097          	auipc	ra,0x2
    80002200:	f34080e7          	jalr	-204(ra) # 80004130 <end_op>
  p->cwd = 0;
    80002204:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002208:	0000f497          	auipc	s1,0xf
    8000220c:	96048493          	addi	s1,s1,-1696 # 80010b68 <wait_lock>
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
    80002262:	2e0080e7          	jalr	736(ra) # 8000053e <panic>

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
    8000227a:	d0a48493          	addi	s1,s1,-758 # 80010f80 <proc>
    8000227e:	00014997          	auipc	s3,0x14
    80002282:	70298993          	addi	s3,s3,1794 # 80016980 <tickslock>
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
    8000235e:	80e50513          	addi	a0,a0,-2034 # 80010b68 <wait_lock>
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
    80002374:	61098993          	addi	s3,s3,1552 # 80016980 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002378:	0000ec17          	auipc	s8,0xe
    8000237c:	7f0c0c13          	addi	s8,s8,2032 # 80010b68 <wait_lock>
    havekids = 0;
    80002380:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002382:	0000f497          	auipc	s1,0xf
    80002386:	bfe48493          	addi	s1,s1,-1026 # 80010f80 <proc>
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
    800023a4:	2c8080e7          	jalr	712(ra) # 80001668 <copyout>
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
    800023c4:	7a850513          	addi	a0,a0,1960 # 80010b68 <wait_lock>
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
    800023e0:	78c50513          	addi	a0,a0,1932 # 80010b68 <wait_lock>
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
    8000242e:	73e50513          	addi	a0,a0,1854 # 80010b68 <wait_lock>
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
    80002492:	1da080e7          	jalr	474(ra) # 80001668 <copyout>
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
    800024e8:	210080e7          	jalr	528(ra) # 800016f4 <copyin>
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
    80002532:	05a080e7          	jalr	90(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002536:	0000f497          	auipc	s1,0xf
    8000253a:	ba248493          	addi	s1,s1,-1118 # 800110d8 <proc+0x158>
    8000253e:	00014917          	auipc	s2,0x14
    80002542:	59a90913          	addi	s2,s2,1434 # 80016ad8 <bcache+0x140>
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
    80002574:	018080e7          	jalr	24(ra) # 80000588 <printf>
    printf("\n");
    80002578:	8552                	mv	a0,s4
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	00e080e7          	jalr	14(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002582:	16848493          	addi	s1,s1,360
    80002586:	03248163          	beq	s1,s2,800025a8 <procdump+0x98>
    if(p->state == UNUSED)
    8000258a:	86a6                	mv	a3,s1
    8000258c:	ec04a783          	lw	a5,-320(s1)
    80002590:	dbed                	beqz	a5,80002582 <procdump+0x72>
      state = "???";
    80002592:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	fcfb6be3          	bltu	s6,a5,8000256a <procdump+0x5a>
    80002598:	1782                	slli	a5,a5,0x20
    8000259a:	9381                	srli	a5,a5,0x20
    8000259c:	078e                	slli	a5,a5,0x3
    8000259e:	97de                	add	a5,a5,s7
    800025a0:	6390                	ld	a2,0(a5)
    800025a2:	f661                	bnez	a2,8000256a <procdump+0x5a>
      state = "???";
    800025a4:	864e                	mv	a2,s3
    800025a6:	b7d1                	j	8000256a <procdump+0x5a>
  }
}
    800025a8:	60a6                	ld	ra,72(sp)
    800025aa:	6406                	ld	s0,64(sp)
    800025ac:	74e2                	ld	s1,56(sp)
    800025ae:	7942                	ld	s2,48(sp)
    800025b0:	79a2                	ld	s3,40(sp)
    800025b2:	7a02                	ld	s4,32(sp)
    800025b4:	6ae2                	ld	s5,24(sp)
    800025b6:	6b42                	ld	s6,16(sp)
    800025b8:	6ba2                	ld	s7,8(sp)
    800025ba:	6161                	addi	sp,sp,80
    800025bc:	8082                	ret

00000000800025be <swtch>:
    800025be:	00153023          	sd	ra,0(a0)
    800025c2:	00253423          	sd	sp,8(a0)
    800025c6:	e900                	sd	s0,16(a0)
    800025c8:	ed04                	sd	s1,24(a0)
    800025ca:	03253023          	sd	s2,32(a0)
    800025ce:	03353423          	sd	s3,40(a0)
    800025d2:	03453823          	sd	s4,48(a0)
    800025d6:	03553c23          	sd	s5,56(a0)
    800025da:	05653023          	sd	s6,64(a0)
    800025de:	05753423          	sd	s7,72(a0)
    800025e2:	05853823          	sd	s8,80(a0)
    800025e6:	05953c23          	sd	s9,88(a0)
    800025ea:	07a53023          	sd	s10,96(a0)
    800025ee:	07b53423          	sd	s11,104(a0)
    800025f2:	0005b083          	ld	ra,0(a1)
    800025f6:	0085b103          	ld	sp,8(a1)
    800025fa:	6980                	ld	s0,16(a1)
    800025fc:	6d84                	ld	s1,24(a1)
    800025fe:	0205b903          	ld	s2,32(a1)
    80002602:	0285b983          	ld	s3,40(a1)
    80002606:	0305ba03          	ld	s4,48(a1)
    8000260a:	0385ba83          	ld	s5,56(a1)
    8000260e:	0405bb03          	ld	s6,64(a1)
    80002612:	0485bb83          	ld	s7,72(a1)
    80002616:	0505bc03          	ld	s8,80(a1)
    8000261a:	0585bc83          	ld	s9,88(a1)
    8000261e:	0605bd03          	ld	s10,96(a1)
    80002622:	0685bd83          	ld	s11,104(a1)
    80002626:	8082                	ret

0000000080002628 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002628:	1141                	addi	sp,sp,-16
    8000262a:	e406                	sd	ra,8(sp)
    8000262c:	e022                	sd	s0,0(sp)
    8000262e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002630:	00006597          	auipc	a1,0x6
    80002634:	cc858593          	addi	a1,a1,-824 # 800082f8 <states.0+0x30>
    80002638:	00014517          	auipc	a0,0x14
    8000263c:	34850513          	addi	a0,a0,840 # 80016980 <tickslock>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	506080e7          	jalr	1286(ra) # 80000b46 <initlock>
}
    80002648:	60a2                	ld	ra,8(sp)
    8000264a:	6402                	ld	s0,0(sp)
    8000264c:	0141                	addi	sp,sp,16
    8000264e:	8082                	ret

0000000080002650 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002650:	1141                	addi	sp,sp,-16
    80002652:	e422                	sd	s0,8(sp)
    80002654:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002656:	00003797          	auipc	a5,0x3
    8000265a:	57a78793          	addi	a5,a5,1402 # 80005bd0 <kernelvec>
    8000265e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002662:	6422                	ld	s0,8(sp)
    80002664:	0141                	addi	sp,sp,16
    80002666:	8082                	ret

0000000080002668 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002668:	1141                	addi	sp,sp,-16
    8000266a:	e406                	sd	ra,8(sp)
    8000266c:	e022                	sd	s0,0(sp)
    8000266e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	344080e7          	jalr	836(ra) # 800019b4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002678:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002682:	00005617          	auipc	a2,0x5
    80002686:	97e60613          	addi	a2,a2,-1666 # 80007000 <_trampoline>
    8000268a:	00005697          	auipc	a3,0x5
    8000268e:	97668693          	addi	a3,a3,-1674 # 80007000 <_trampoline>
    80002692:	8e91                	sub	a3,a3,a2
    80002694:	040007b7          	lui	a5,0x4000
    80002698:	17fd                	addi	a5,a5,-1
    8000269a:	07b2                	slli	a5,a5,0xc
    8000269c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000269e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026a2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a4:	180026f3          	csrr	a3,satp
    800026a8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026aa:	6d38                	ld	a4,88(a0)
    800026ac:	6134                	ld	a3,64(a0)
    800026ae:	6585                	lui	a1,0x1
    800026b0:	96ae                	add	a3,a3,a1
    800026b2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026b4:	6d38                	ld	a4,88(a0)
    800026b6:	00000697          	auipc	a3,0x0
    800026ba:	13068693          	addi	a3,a3,304 # 800027e6 <usertrap>
    800026be:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c2:	8692                	mv	a3,tp
    800026c4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026ca:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ce:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d8:	6f18                	ld	a4,24(a4)
    800026da:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026de:	6928                	ld	a0,80(a0)
    800026e0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026e2:	00005717          	auipc	a4,0x5
    800026e6:	9ba70713          	addi	a4,a4,-1606 # 8000709c <userret>
    800026ea:	8f11                	sub	a4,a4,a2
    800026ec:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026ee:	577d                	li	a4,-1
    800026f0:	177e                	slli	a4,a4,0x3f
    800026f2:	8d59                	or	a0,a0,a4
    800026f4:	9782                	jalr	a5
}
    800026f6:	60a2                	ld	ra,8(sp)
    800026f8:	6402                	ld	s0,0(sp)
    800026fa:	0141                	addi	sp,sp,16
    800026fc:	8082                	ret

00000000800026fe <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026fe:	1101                	addi	sp,sp,-32
    80002700:	ec06                	sd	ra,24(sp)
    80002702:	e822                	sd	s0,16(sp)
    80002704:	e426                	sd	s1,8(sp)
    80002706:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002708:	00014497          	auipc	s1,0x14
    8000270c:	27848493          	addi	s1,s1,632 # 80016980 <tickslock>
    80002710:	8526                	mv	a0,s1
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	4c4080e7          	jalr	1220(ra) # 80000bd6 <acquire>
  ticks++;
    8000271a:	00006517          	auipc	a0,0x6
    8000271e:	1c650513          	addi	a0,a0,454 # 800088e0 <ticks>
    80002722:	411c                	lw	a5,0(a0)
    80002724:	2785                	addiw	a5,a5,1
    80002726:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002728:	00000097          	auipc	ra,0x0
    8000272c:	998080e7          	jalr	-1640(ra) # 800020c0 <wakeup>
  release(&tickslock);
    80002730:	8526                	mv	a0,s1
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	558080e7          	jalr	1368(ra) # 80000c8a <release>
}
    8000273a:	60e2                	ld	ra,24(sp)
    8000273c:	6442                	ld	s0,16(sp)
    8000273e:	64a2                	ld	s1,8(sp)
    80002740:	6105                	addi	sp,sp,32
    80002742:	8082                	ret

0000000080002744 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002744:	1101                	addi	sp,sp,-32
    80002746:	ec06                	sd	ra,24(sp)
    80002748:	e822                	sd	s0,16(sp)
    8000274a:	e426                	sd	s1,8(sp)
    8000274c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000274e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002752:	00074d63          	bltz	a4,8000276c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002756:	57fd                	li	a5,-1
    80002758:	17fe                	slli	a5,a5,0x3f
    8000275a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000275c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000275e:	06f70363          	beq	a4,a5,800027c4 <devintr+0x80>
  }
}
    80002762:	60e2                	ld	ra,24(sp)
    80002764:	6442                	ld	s0,16(sp)
    80002766:	64a2                	ld	s1,8(sp)
    80002768:	6105                	addi	sp,sp,32
    8000276a:	8082                	ret
     (scause & 0xff) == 9){
    8000276c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002770:	46a5                	li	a3,9
    80002772:	fed792e3          	bne	a5,a3,80002756 <devintr+0x12>
    int irq = plic_claim();
    80002776:	00003097          	auipc	ra,0x3
    8000277a:	562080e7          	jalr	1378(ra) # 80005cd8 <plic_claim>
    8000277e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002780:	47a9                	li	a5,10
    80002782:	02f50763          	beq	a0,a5,800027b0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002786:	4785                	li	a5,1
    80002788:	02f50963          	beq	a0,a5,800027ba <devintr+0x76>
    return 1;
    8000278c:	4505                	li	a0,1
    } else if(irq){
    8000278e:	d8f1                	beqz	s1,80002762 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002790:	85a6                	mv	a1,s1
    80002792:	00006517          	auipc	a0,0x6
    80002796:	b6e50513          	addi	a0,a0,-1170 # 80008300 <states.0+0x38>
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	dee080e7          	jalr	-530(ra) # 80000588 <printf>
      plic_complete(irq);
    800027a2:	8526                	mv	a0,s1
    800027a4:	00003097          	auipc	ra,0x3
    800027a8:	558080e7          	jalr	1368(ra) # 80005cfc <plic_complete>
    return 1;
    800027ac:	4505                	li	a0,1
    800027ae:	bf55                	j	80002762 <devintr+0x1e>
      uartintr();
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	1ea080e7          	jalr	490(ra) # 8000099a <uartintr>
    800027b8:	b7ed                	j	800027a2 <devintr+0x5e>
      virtio_disk_intr();
    800027ba:	00004097          	auipc	ra,0x4
    800027be:	a0e080e7          	jalr	-1522(ra) # 800061c8 <virtio_disk_intr>
    800027c2:	b7c5                	j	800027a2 <devintr+0x5e>
    if(cpuid() == 0){
    800027c4:	fffff097          	auipc	ra,0xfffff
    800027c8:	1c4080e7          	jalr	452(ra) # 80001988 <cpuid>
    800027cc:	c901                	beqz	a0,800027dc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027ce:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027d4:	14479073          	csrw	sip,a5
    return 2;
    800027d8:	4509                	li	a0,2
    800027da:	b761                	j	80002762 <devintr+0x1e>
      clockintr();
    800027dc:	00000097          	auipc	ra,0x0
    800027e0:	f22080e7          	jalr	-222(ra) # 800026fe <clockintr>
    800027e4:	b7ed                	j	800027ce <devintr+0x8a>

00000000800027e6 <usertrap>:
{
    800027e6:	1101                	addi	sp,sp,-32
    800027e8:	ec06                	sd	ra,24(sp)
    800027ea:	e822                	sd	s0,16(sp)
    800027ec:	e426                	sd	s1,8(sp)
    800027ee:	e04a                	sd	s2,0(sp)
    800027f0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027f6:	1007f793          	andi	a5,a5,256
    800027fa:	e3b1                	bnez	a5,8000283e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027fc:	00003797          	auipc	a5,0x3
    80002800:	3d478793          	addi	a5,a5,980 # 80005bd0 <kernelvec>
    80002804:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002808:	fffff097          	auipc	ra,0xfffff
    8000280c:	1ac080e7          	jalr	428(ra) # 800019b4 <myproc>
    80002810:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002812:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002814:	14102773          	csrr	a4,sepc
    80002818:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000281e:	47a1                	li	a5,8
    80002820:	02f70763          	beq	a4,a5,8000284e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002824:	00000097          	auipc	ra,0x0
    80002828:	f20080e7          	jalr	-224(ra) # 80002744 <devintr>
    8000282c:	892a                	mv	s2,a0
    8000282e:	c151                	beqz	a0,800028b2 <usertrap+0xcc>
  if(killed(p))
    80002830:	8526                	mv	a0,s1
    80002832:	00000097          	auipc	ra,0x0
    80002836:	ad2080e7          	jalr	-1326(ra) # 80002304 <killed>
    8000283a:	c929                	beqz	a0,8000288c <usertrap+0xa6>
    8000283c:	a099                	j	80002882 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    8000283e:	00006517          	auipc	a0,0x6
    80002842:	ae250513          	addi	a0,a0,-1310 # 80008320 <states.0+0x58>
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	cf8080e7          	jalr	-776(ra) # 8000053e <panic>
    if(killed(p))
    8000284e:	00000097          	auipc	ra,0x0
    80002852:	ab6080e7          	jalr	-1354(ra) # 80002304 <killed>
    80002856:	e921                	bnez	a0,800028a6 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002858:	6cb8                	ld	a4,88(s1)
    8000285a:	6f1c                	ld	a5,24(a4)
    8000285c:	0791                	addi	a5,a5,4
    8000285e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002860:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002864:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002868:	10079073          	csrw	sstatus,a5
    syscall();
    8000286c:	00000097          	auipc	ra,0x0
    80002870:	2d4080e7          	jalr	724(ra) # 80002b40 <syscall>
  if(killed(p))
    80002874:	8526                	mv	a0,s1
    80002876:	00000097          	auipc	ra,0x0
    8000287a:	a8e080e7          	jalr	-1394(ra) # 80002304 <killed>
    8000287e:	c911                	beqz	a0,80002892 <usertrap+0xac>
    80002880:	4901                	li	s2,0
    exit(-1);
    80002882:	557d                	li	a0,-1
    80002884:	00000097          	auipc	ra,0x0
    80002888:	90c080e7          	jalr	-1780(ra) # 80002190 <exit>
  if(which_dev == 2)
    8000288c:	4789                	li	a5,2
    8000288e:	04f90f63          	beq	s2,a5,800028ec <usertrap+0x106>
  usertrapret();
    80002892:	00000097          	auipc	ra,0x0
    80002896:	dd6080e7          	jalr	-554(ra) # 80002668 <usertrapret>
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6902                	ld	s2,0(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret
      exit(-1);
    800028a6:	557d                	li	a0,-1
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	8e8080e7          	jalr	-1816(ra) # 80002190 <exit>
    800028b0:	b765                	j	80002858 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b6:	5890                	lw	a2,48(s1)
    800028b8:	00006517          	auipc	a0,0x6
    800028bc:	a8850513          	addi	a0,a0,-1400 # 80008340 <states.0+0x78>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	cc8080e7          	jalr	-824(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028cc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d0:	00006517          	auipc	a0,0x6
    800028d4:	aa050513          	addi	a0,a0,-1376 # 80008370 <states.0+0xa8>
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	cb0080e7          	jalr	-848(ra) # 80000588 <printf>
    setkilled(p);
    800028e0:	8526                	mv	a0,s1
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	9f6080e7          	jalr	-1546(ra) # 800022d8 <setkilled>
    800028ea:	b769                	j	80002874 <usertrap+0x8e>
    yield();
    800028ec:	fffff097          	auipc	ra,0xfffff
    800028f0:	734080e7          	jalr	1844(ra) # 80002020 <yield>
    800028f4:	bf79                	j	80002892 <usertrap+0xac>

00000000800028f6 <kerneltrap>:
{
    800028f6:	7179                	addi	sp,sp,-48
    800028f8:	f406                	sd	ra,40(sp)
    800028fa:	f022                	sd	s0,32(sp)
    800028fc:	ec26                	sd	s1,24(sp)
    800028fe:	e84a                	sd	s2,16(sp)
    80002900:	e44e                	sd	s3,8(sp)
    80002902:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002904:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002908:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002910:	1004f793          	andi	a5,s1,256
    80002914:	cb85                	beqz	a5,80002944 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002916:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000291a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000291c:	ef85                	bnez	a5,80002954 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	e26080e7          	jalr	-474(ra) # 80002744 <devintr>
    80002926:	cd1d                	beqz	a0,80002964 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002928:	4789                	li	a5,2
    8000292a:	06f50a63          	beq	a0,a5,8000299e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000292e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002932:	10049073          	csrw	sstatus,s1
}
    80002936:	70a2                	ld	ra,40(sp)
    80002938:	7402                	ld	s0,32(sp)
    8000293a:	64e2                	ld	s1,24(sp)
    8000293c:	6942                	ld	s2,16(sp)
    8000293e:	69a2                	ld	s3,8(sp)
    80002940:	6145                	addi	sp,sp,48
    80002942:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002944:	00006517          	auipc	a0,0x6
    80002948:	a4c50513          	addi	a0,a0,-1460 # 80008390 <states.0+0xc8>
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	bf2080e7          	jalr	-1038(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002954:	00006517          	auipc	a0,0x6
    80002958:	a6450513          	addi	a0,a0,-1436 # 800083b8 <states.0+0xf0>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	be2080e7          	jalr	-1054(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002964:	85ce                	mv	a1,s3
    80002966:	00006517          	auipc	a0,0x6
    8000296a:	a7250513          	addi	a0,a0,-1422 # 800083d8 <states.0+0x110>
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	c1a080e7          	jalr	-998(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002976:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000297e:	00006517          	auipc	a0,0x6
    80002982:	a6a50513          	addi	a0,a0,-1430 # 800083e8 <states.0+0x120>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	c02080e7          	jalr	-1022(ra) # 80000588 <printf>
    panic("kerneltrap");
    8000298e:	00006517          	auipc	a0,0x6
    80002992:	a7250513          	addi	a0,a0,-1422 # 80008400 <states.0+0x138>
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	ba8080e7          	jalr	-1112(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000299e:	fffff097          	auipc	ra,0xfffff
    800029a2:	016080e7          	jalr	22(ra) # 800019b4 <myproc>
    800029a6:	d541                	beqz	a0,8000292e <kerneltrap+0x38>
    800029a8:	fffff097          	auipc	ra,0xfffff
    800029ac:	00c080e7          	jalr	12(ra) # 800019b4 <myproc>
    800029b0:	4d18                	lw	a4,24(a0)
    800029b2:	4791                	li	a5,4
    800029b4:	f6f71de3          	bne	a4,a5,8000292e <kerneltrap+0x38>
    yield();
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	668080e7          	jalr	1640(ra) # 80002020 <yield>
    800029c0:	b7bd                	j	8000292e <kerneltrap+0x38>

00000000800029c2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c2:	1101                	addi	sp,sp,-32
    800029c4:	ec06                	sd	ra,24(sp)
    800029c6:	e822                	sd	s0,16(sp)
    800029c8:	e426                	sd	s1,8(sp)
    800029ca:	1000                	addi	s0,sp,32
    800029cc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029ce:	fffff097          	auipc	ra,0xfffff
    800029d2:	fe6080e7          	jalr	-26(ra) # 800019b4 <myproc>
  switch (n) {
    800029d6:	4795                	li	a5,5
    800029d8:	0497e163          	bltu	a5,s1,80002a1a <argraw+0x58>
    800029dc:	048a                	slli	s1,s1,0x2
    800029de:	00006717          	auipc	a4,0x6
    800029e2:	a5a70713          	addi	a4,a4,-1446 # 80008438 <states.0+0x170>
    800029e6:	94ba                	add	s1,s1,a4
    800029e8:	409c                	lw	a5,0(s1)
    800029ea:	97ba                	add	a5,a5,a4
    800029ec:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029ee:	6d3c                	ld	a5,88(a0)
    800029f0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f2:	60e2                	ld	ra,24(sp)
    800029f4:	6442                	ld	s0,16(sp)
    800029f6:	64a2                	ld	s1,8(sp)
    800029f8:	6105                	addi	sp,sp,32
    800029fa:	8082                	ret
    return p->trapframe->a1;
    800029fc:	6d3c                	ld	a5,88(a0)
    800029fe:	7fa8                	ld	a0,120(a5)
    80002a00:	bfcd                	j	800029f2 <argraw+0x30>
    return p->trapframe->a2;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	63c8                	ld	a0,128(a5)
    80002a06:	b7f5                	j	800029f2 <argraw+0x30>
    return p->trapframe->a3;
    80002a08:	6d3c                	ld	a5,88(a0)
    80002a0a:	67c8                	ld	a0,136(a5)
    80002a0c:	b7dd                	j	800029f2 <argraw+0x30>
    return p->trapframe->a4;
    80002a0e:	6d3c                	ld	a5,88(a0)
    80002a10:	6bc8                	ld	a0,144(a5)
    80002a12:	b7c5                	j	800029f2 <argraw+0x30>
    return p->trapframe->a5;
    80002a14:	6d3c                	ld	a5,88(a0)
    80002a16:	6fc8                	ld	a0,152(a5)
    80002a18:	bfe9                	j	800029f2 <argraw+0x30>
  panic("argraw");
    80002a1a:	00006517          	auipc	a0,0x6
    80002a1e:	9f650513          	addi	a0,a0,-1546 # 80008410 <states.0+0x148>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	b1c080e7          	jalr	-1252(ra) # 8000053e <panic>

0000000080002a2a <fetchaddr>:
{
    80002a2a:	1101                	addi	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	e04a                	sd	s2,0(sp)
    80002a34:	1000                	addi	s0,sp,32
    80002a36:	84aa                	mv	s1,a0
    80002a38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a3a:	fffff097          	auipc	ra,0xfffff
    80002a3e:	f7a080e7          	jalr	-134(ra) # 800019b4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a42:	653c                	ld	a5,72(a0)
    80002a44:	02f4f863          	bgeu	s1,a5,80002a74 <fetchaddr+0x4a>
    80002a48:	00848713          	addi	a4,s1,8
    80002a4c:	02e7e663          	bltu	a5,a4,80002a78 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a50:	46a1                	li	a3,8
    80002a52:	8626                	mv	a2,s1
    80002a54:	85ca                	mv	a1,s2
    80002a56:	6928                	ld	a0,80(a0)
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	c9c080e7          	jalr	-868(ra) # 800016f4 <copyin>
    80002a60:	00a03533          	snez	a0,a0
    80002a64:	40a00533          	neg	a0,a0
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6902                	ld	s2,0(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret
    return -1;
    80002a74:	557d                	li	a0,-1
    80002a76:	bfcd                	j	80002a68 <fetchaddr+0x3e>
    80002a78:	557d                	li	a0,-1
    80002a7a:	b7fd                	j	80002a68 <fetchaddr+0x3e>

0000000080002a7c <fetchstr>:
{
    80002a7c:	7179                	addi	sp,sp,-48
    80002a7e:	f406                	sd	ra,40(sp)
    80002a80:	f022                	sd	s0,32(sp)
    80002a82:	ec26                	sd	s1,24(sp)
    80002a84:	e84a                	sd	s2,16(sp)
    80002a86:	e44e                	sd	s3,8(sp)
    80002a88:	1800                	addi	s0,sp,48
    80002a8a:	892a                	mv	s2,a0
    80002a8c:	84ae                	mv	s1,a1
    80002a8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	f24080e7          	jalr	-220(ra) # 800019b4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a98:	86ce                	mv	a3,s3
    80002a9a:	864a                	mv	a2,s2
    80002a9c:	85a6                	mv	a1,s1
    80002a9e:	6928                	ld	a0,80(a0)
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	ce2080e7          	jalr	-798(ra) # 80001782 <copyinstr>
    80002aa8:	00054e63          	bltz	a0,80002ac4 <fetchstr+0x48>
  return strlen(buf);
    80002aac:	8526                	mv	a0,s1
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	3a0080e7          	jalr	928(ra) # 80000e4e <strlen>
}
    80002ab6:	70a2                	ld	ra,40(sp)
    80002ab8:	7402                	ld	s0,32(sp)
    80002aba:	64e2                	ld	s1,24(sp)
    80002abc:	6942                	ld	s2,16(sp)
    80002abe:	69a2                	ld	s3,8(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret
    return -1;
    80002ac4:	557d                	li	a0,-1
    80002ac6:	bfc5                	j	80002ab6 <fetchstr+0x3a>

0000000080002ac8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	1000                	addi	s0,sp,32
    80002ad2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad4:	00000097          	auipc	ra,0x0
    80002ad8:	eee080e7          	jalr	-274(ra) # 800029c2 <argraw>
    80002adc:	c088                	sw	a0,0(s1)
}
    80002ade:	60e2                	ld	ra,24(sp)
    80002ae0:	6442                	ld	s0,16(sp)
    80002ae2:	64a2                	ld	s1,8(sp)
    80002ae4:	6105                	addi	sp,sp,32
    80002ae6:	8082                	ret

0000000080002ae8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ae8:	1101                	addi	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	1000                	addi	s0,sp,32
    80002af2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	ece080e7          	jalr	-306(ra) # 800029c2 <argraw>
    80002afc:	e088                	sd	a0,0(s1)
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	64a2                	ld	s1,8(sp)
    80002b04:	6105                	addi	sp,sp,32
    80002b06:	8082                	ret

0000000080002b08 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b08:	7179                	addi	sp,sp,-48
    80002b0a:	f406                	sd	ra,40(sp)
    80002b0c:	f022                	sd	s0,32(sp)
    80002b0e:	ec26                	sd	s1,24(sp)
    80002b10:	e84a                	sd	s2,16(sp)
    80002b12:	1800                	addi	s0,sp,48
    80002b14:	84ae                	mv	s1,a1
    80002b16:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b18:	fd840593          	addi	a1,s0,-40
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	fcc080e7          	jalr	-52(ra) # 80002ae8 <argaddr>
  return fetchstr(addr, buf, max);
    80002b24:	864a                	mv	a2,s2
    80002b26:	85a6                	mv	a1,s1
    80002b28:	fd843503          	ld	a0,-40(s0)
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	f50080e7          	jalr	-176(ra) # 80002a7c <fetchstr>
}
    80002b34:	70a2                	ld	ra,40(sp)
    80002b36:	7402                	ld	s0,32(sp)
    80002b38:	64e2                	ld	s1,24(sp)
    80002b3a:	6942                	ld	s2,16(sp)
    80002b3c:	6145                	addi	sp,sp,48
    80002b3e:	8082                	ret

0000000080002b40 <syscall>:
[SYS_peterson_destroy] sys_peterson_destroy,
};

void
syscall(void)
{
    80002b40:	1101                	addi	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	e04a                	sd	s2,0(sp)
    80002b4a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	e68080e7          	jalr	-408(ra) # 800019b4 <myproc>
    80002b54:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b56:	05853903          	ld	s2,88(a0)
    80002b5a:	0a893783          	ld	a5,168(s2)
    80002b5e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b62:	37fd                	addiw	a5,a5,-1
    80002b64:	4761                	li	a4,24
    80002b66:	00f76f63          	bltu	a4,a5,80002b84 <syscall+0x44>
    80002b6a:	00369713          	slli	a4,a3,0x3
    80002b6e:	00006797          	auipc	a5,0x6
    80002b72:	8e278793          	addi	a5,a5,-1822 # 80008450 <syscalls>
    80002b76:	97ba                	add	a5,a5,a4
    80002b78:	639c                	ld	a5,0(a5)
    80002b7a:	c789                	beqz	a5,80002b84 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b7c:	9782                	jalr	a5
    80002b7e:	06a93823          	sd	a0,112(s2)
    80002b82:	a839                	j	80002ba0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b84:	15848613          	addi	a2,s1,344
    80002b88:	588c                	lw	a1,48(s1)
    80002b8a:	00006517          	auipc	a0,0x6
    80002b8e:	88e50513          	addi	a0,a0,-1906 # 80008418 <states.0+0x150>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	9f6080e7          	jalr	-1546(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9a:	6cbc                	ld	a5,88(s1)
    80002b9c:	577d                	li	a4,-1
    80002b9e:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba0:	60e2                	ld	ra,24(sp)
    80002ba2:	6442                	ld	s0,16(sp)
    80002ba4:	64a2                	ld	s1,8(sp)
    80002ba6:	6902                	ld	s2,0(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_exit>:
#include "petersonlock.h"


uint64
sys_exit(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bb4:	fec40593          	addi	a1,s0,-20
    80002bb8:	4501                	li	a0,0
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	f0e080e7          	jalr	-242(ra) # 80002ac8 <argint>
  exit(n);
    80002bc2:	fec42503          	lw	a0,-20(s0)
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	5ca080e7          	jalr	1482(ra) # 80002190 <exit>
  return 0;  // not reached
}
    80002bce:	4501                	li	a0,0
    80002bd0:	60e2                	ld	ra,24(sp)
    80002bd2:	6442                	ld	s0,16(sp)
    80002bd4:	6105                	addi	sp,sp,32
    80002bd6:	8082                	ret

0000000080002bd8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd8:	1141                	addi	sp,sp,-16
    80002bda:	e406                	sd	ra,8(sp)
    80002bdc:	e022                	sd	s0,0(sp)
    80002bde:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be0:	fffff097          	auipc	ra,0xfffff
    80002be4:	dd4080e7          	jalr	-556(ra) # 800019b4 <myproc>
}
    80002be8:	5908                	lw	a0,48(a0)
    80002bea:	60a2                	ld	ra,8(sp)
    80002bec:	6402                	ld	s0,0(sp)
    80002bee:	0141                	addi	sp,sp,16
    80002bf0:	8082                	ret

0000000080002bf2 <sys_fork>:

uint64
sys_fork(void)
{
    80002bf2:	1141                	addi	sp,sp,-16
    80002bf4:	e406                	sd	ra,8(sp)
    80002bf6:	e022                	sd	s0,0(sp)
    80002bf8:	0800                	addi	s0,sp,16
  return fork();
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	170080e7          	jalr	368(ra) # 80001d6a <fork>
}
    80002c02:	60a2                	ld	ra,8(sp)
    80002c04:	6402                	ld	s0,0(sp)
    80002c06:	0141                	addi	sp,sp,16
    80002c08:	8082                	ret

0000000080002c0a <sys_wait>:

uint64
sys_wait(void)
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c12:	fe840593          	addi	a1,s0,-24
    80002c16:	4501                	li	a0,0
    80002c18:	00000097          	auipc	ra,0x0
    80002c1c:	ed0080e7          	jalr	-304(ra) # 80002ae8 <argaddr>
  return wait(p);
    80002c20:	fe843503          	ld	a0,-24(s0)
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	712080e7          	jalr	1810(ra) # 80002336 <wait>
}
    80002c2c:	60e2                	ld	ra,24(sp)
    80002c2e:	6442                	ld	s0,16(sp)
    80002c30:	6105                	addi	sp,sp,32
    80002c32:	8082                	ret

0000000080002c34 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c34:	7179                	addi	sp,sp,-48
    80002c36:	f406                	sd	ra,40(sp)
    80002c38:	f022                	sd	s0,32(sp)
    80002c3a:	ec26                	sd	s1,24(sp)
    80002c3c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c3e:	fdc40593          	addi	a1,s0,-36
    80002c42:	4501                	li	a0,0
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	e84080e7          	jalr	-380(ra) # 80002ac8 <argint>
  addr = myproc()->sz;
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	d68080e7          	jalr	-664(ra) # 800019b4 <myproc>
    80002c54:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c56:	fdc42503          	lw	a0,-36(s0)
    80002c5a:	fffff097          	auipc	ra,0xfffff
    80002c5e:	0b4080e7          	jalr	180(ra) # 80001d0e <growproc>
    80002c62:	00054863          	bltz	a0,80002c72 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c66:	8526                	mv	a0,s1
    80002c68:	70a2                	ld	ra,40(sp)
    80002c6a:	7402                	ld	s0,32(sp)
    80002c6c:	64e2                	ld	s1,24(sp)
    80002c6e:	6145                	addi	sp,sp,48
    80002c70:	8082                	ret
    return -1;
    80002c72:	54fd                	li	s1,-1
    80002c74:	bfcd                	j	80002c66 <sys_sbrk+0x32>

0000000080002c76 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c76:	7139                	addi	sp,sp,-64
    80002c78:	fc06                	sd	ra,56(sp)
    80002c7a:	f822                	sd	s0,48(sp)
    80002c7c:	f426                	sd	s1,40(sp)
    80002c7e:	f04a                	sd	s2,32(sp)
    80002c80:	ec4e                	sd	s3,24(sp)
    80002c82:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c84:	fcc40593          	addi	a1,s0,-52
    80002c88:	4501                	li	a0,0
    80002c8a:	00000097          	auipc	ra,0x0
    80002c8e:	e3e080e7          	jalr	-450(ra) # 80002ac8 <argint>
  acquire(&tickslock);
    80002c92:	00014517          	auipc	a0,0x14
    80002c96:	cee50513          	addi	a0,a0,-786 # 80016980 <tickslock>
    80002c9a:	ffffe097          	auipc	ra,0xffffe
    80002c9e:	f3c080e7          	jalr	-196(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002ca2:	00006917          	auipc	s2,0x6
    80002ca6:	c3e92903          	lw	s2,-962(s2) # 800088e0 <ticks>
  while(ticks - ticks0 < n){
    80002caa:	fcc42783          	lw	a5,-52(s0)
    80002cae:	cf9d                	beqz	a5,80002cec <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb0:	00014997          	auipc	s3,0x14
    80002cb4:	cd098993          	addi	s3,s3,-816 # 80016980 <tickslock>
    80002cb8:	00006497          	auipc	s1,0x6
    80002cbc:	c2848493          	addi	s1,s1,-984 # 800088e0 <ticks>
    if(killed(myproc())){
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	cf4080e7          	jalr	-780(ra) # 800019b4 <myproc>
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	63c080e7          	jalr	1596(ra) # 80002304 <killed>
    80002cd0:	ed15                	bnez	a0,80002d0c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cd2:	85ce                	mv	a1,s3
    80002cd4:	8526                	mv	a0,s1
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	386080e7          	jalr	902(ra) # 8000205c <sleep>
  while(ticks - ticks0 < n){
    80002cde:	409c                	lw	a5,0(s1)
    80002ce0:	412787bb          	subw	a5,a5,s2
    80002ce4:	fcc42703          	lw	a4,-52(s0)
    80002ce8:	fce7ece3          	bltu	a5,a4,80002cc0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cec:	00014517          	auipc	a0,0x14
    80002cf0:	c9450513          	addi	a0,a0,-876 # 80016980 <tickslock>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
  return 0;
    80002cfc:	4501                	li	a0,0
}
    80002cfe:	70e2                	ld	ra,56(sp)
    80002d00:	7442                	ld	s0,48(sp)
    80002d02:	74a2                	ld	s1,40(sp)
    80002d04:	7902                	ld	s2,32(sp)
    80002d06:	69e2                	ld	s3,24(sp)
    80002d08:	6121                	addi	sp,sp,64
    80002d0a:	8082                	ret
      release(&tickslock);
    80002d0c:	00014517          	auipc	a0,0x14
    80002d10:	c7450513          	addi	a0,a0,-908 # 80016980 <tickslock>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	f76080e7          	jalr	-138(ra) # 80000c8a <release>
      return -1;
    80002d1c:	557d                	li	a0,-1
    80002d1e:	b7c5                	j	80002cfe <sys_sleep+0x88>

0000000080002d20 <sys_kill>:

uint64
sys_kill(void)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d28:	fec40593          	addi	a1,s0,-20
    80002d2c:	4501                	li	a0,0
    80002d2e:	00000097          	auipc	ra,0x0
    80002d32:	d9a080e7          	jalr	-614(ra) # 80002ac8 <argint>
  return kill(pid);
    80002d36:	fec42503          	lw	a0,-20(s0)
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	52c080e7          	jalr	1324(ra) # 80002266 <kill>
}
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d54:	00014517          	auipc	a0,0x14
    80002d58:	c2c50513          	addi	a0,a0,-980 # 80016980 <tickslock>
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	e7a080e7          	jalr	-390(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d64:	00006497          	auipc	s1,0x6
    80002d68:	b7c4a483          	lw	s1,-1156(s1) # 800088e0 <ticks>
  release(&tickslock);
    80002d6c:	00014517          	auipc	a0,0x14
    80002d70:	c1450513          	addi	a0,a0,-1004 # 80016980 <tickslock>
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	f16080e7          	jalr	-234(ra) # 80000c8a <release>
  return xticks;
}
    80002d7c:	02049513          	slli	a0,s1,0x20
    80002d80:	9101                	srli	a0,a0,0x20
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <sys_peterson_create>:

// ------------------------------------------------------------
//task4:
uint64
sys_peterson_create(void)
{
    80002d8c:	1141                	addi	sp,sp,-16
    80002d8e:	e406                	sd	ra,8(sp)
    80002d90:	e022                	sd	s0,0(sp)
    80002d92:	0800                	addi	s0,sp,16
    return petersonlock_create();
    80002d94:	00003097          	auipc	ra,0x3
    80002d98:	50e080e7          	jalr	1294(ra) # 800062a2 <petersonlock_create>
}
    80002d9c:	60a2                	ld	ra,8(sp)
    80002d9e:	6402                	ld	s0,0(sp)
    80002da0:	0141                	addi	sp,sp,16
    80002da2:	8082                	ret

0000000080002da4 <sys_peterson_acquire>:

uint64
sys_peterson_acquire(void)
{
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	1000                	addi	s0,sp,32
    int lock_id, role;
    argint(0, &lock_id);
    80002dac:	fec40593          	addi	a1,s0,-20
    80002db0:	4501                	li	a0,0
    80002db2:	00000097          	auipc	ra,0x0
    80002db6:	d16080e7          	jalr	-746(ra) # 80002ac8 <argint>
    argint(1, &role);
    80002dba:	fe840593          	addi	a1,s0,-24
    80002dbe:	4505                	li	a0,1
    80002dc0:	00000097          	auipc	ra,0x0
    80002dc4:	d08080e7          	jalr	-760(ra) # 80002ac8 <argint>
    return petersonlock_acquire(lock_id, role);
    80002dc8:	fe842583          	lw	a1,-24(s0)
    80002dcc:	fec42503          	lw	a0,-20(s0)
    80002dd0:	00003097          	auipc	ra,0x3
    80002dd4:	518080e7          	jalr	1304(ra) # 800062e8 <petersonlock_acquire>
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	6105                	addi	sp,sp,32
    80002dde:	8082                	ret

0000000080002de0 <sys_peterson_release>:

uint64
sys_peterson_release(void)
{
    80002de0:	1101                	addi	sp,sp,-32
    80002de2:	ec06                	sd	ra,24(sp)
    80002de4:	e822                	sd	s0,16(sp)
    80002de6:	1000                	addi	s0,sp,32
    int lock_id, role;
    argint(0, &lock_id);
    80002de8:	fec40593          	addi	a1,s0,-20
    80002dec:	4501                	li	a0,0
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	cda080e7          	jalr	-806(ra) # 80002ac8 <argint>
    argint(1, &role);
    80002df6:	fe840593          	addi	a1,s0,-24
    80002dfa:	4505                	li	a0,1
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	ccc080e7          	jalr	-820(ra) # 80002ac8 <argint>
    return petersonlock_release(lock_id, role);
    80002e04:	fe842583          	lw	a1,-24(s0)
    80002e08:	fec42503          	lw	a0,-20(s0)
    80002e0c:	00003097          	auipc	ra,0x3
    80002e10:	56e080e7          	jalr	1390(ra) # 8000637a <petersonlock_release>
}
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	6105                	addi	sp,sp,32
    80002e1a:	8082                	ret

0000000080002e1c <sys_peterson_destroy>:

uint64
sys_peterson_destroy(void)
{
    80002e1c:	1101                	addi	sp,sp,-32
    80002e1e:	ec06                	sd	ra,24(sp)
    80002e20:	e822                	sd	s0,16(sp)
    80002e22:	1000                	addi	s0,sp,32
    int lock_id;
    argint(0, &lock_id);
    80002e24:	fec40593          	addi	a1,s0,-20
    80002e28:	4501                	li	a0,0
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	c9e080e7          	jalr	-866(ra) # 80002ac8 <argint>
    return petersonlock_destroy(lock_id);
    80002e32:	fec42503          	lw	a0,-20(s0)
    80002e36:	00003097          	auipc	ra,0x3
    80002e3a:	590080e7          	jalr	1424(ra) # 800063c6 <petersonlock_destroy>
}
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	6105                	addi	sp,sp,32
    80002e44:	8082                	ret

0000000080002e46 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e46:	7179                	addi	sp,sp,-48
    80002e48:	f406                	sd	ra,40(sp)
    80002e4a:	f022                	sd	s0,32(sp)
    80002e4c:	ec26                	sd	s1,24(sp)
    80002e4e:	e84a                	sd	s2,16(sp)
    80002e50:	e44e                	sd	s3,8(sp)
    80002e52:	e052                	sd	s4,0(sp)
    80002e54:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e56:	00005597          	auipc	a1,0x5
    80002e5a:	6ca58593          	addi	a1,a1,1738 # 80008520 <syscalls+0xd0>
    80002e5e:	00014517          	auipc	a0,0x14
    80002e62:	b3a50513          	addi	a0,a0,-1222 # 80016998 <bcache>
    80002e66:	ffffe097          	auipc	ra,0xffffe
    80002e6a:	ce0080e7          	jalr	-800(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e6e:	0001c797          	auipc	a5,0x1c
    80002e72:	b2a78793          	addi	a5,a5,-1238 # 8001e998 <bcache+0x8000>
    80002e76:	0001c717          	auipc	a4,0x1c
    80002e7a:	d8a70713          	addi	a4,a4,-630 # 8001ec00 <bcache+0x8268>
    80002e7e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e82:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e86:	00014497          	auipc	s1,0x14
    80002e8a:	b2a48493          	addi	s1,s1,-1238 # 800169b0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e8e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e90:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e92:	00005a17          	auipc	s4,0x5
    80002e96:	696a0a13          	addi	s4,s4,1686 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002e9a:	2b893783          	ld	a5,696(s2)
    80002e9e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ea0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ea4:	85d2                	mv	a1,s4
    80002ea6:	01048513          	addi	a0,s1,16
    80002eaa:	00001097          	auipc	ra,0x1
    80002eae:	4c4080e7          	jalr	1220(ra) # 8000436e <initsleeplock>
    bcache.head.next->prev = b;
    80002eb2:	2b893783          	ld	a5,696(s2)
    80002eb6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eb8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ebc:	45848493          	addi	s1,s1,1112
    80002ec0:	fd349de3          	bne	s1,s3,80002e9a <binit+0x54>
  }
}
    80002ec4:	70a2                	ld	ra,40(sp)
    80002ec6:	7402                	ld	s0,32(sp)
    80002ec8:	64e2                	ld	s1,24(sp)
    80002eca:	6942                	ld	s2,16(sp)
    80002ecc:	69a2                	ld	s3,8(sp)
    80002ece:	6a02                	ld	s4,0(sp)
    80002ed0:	6145                	addi	sp,sp,48
    80002ed2:	8082                	ret

0000000080002ed4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ed4:	7179                	addi	sp,sp,-48
    80002ed6:	f406                	sd	ra,40(sp)
    80002ed8:	f022                	sd	s0,32(sp)
    80002eda:	ec26                	sd	s1,24(sp)
    80002edc:	e84a                	sd	s2,16(sp)
    80002ede:	e44e                	sd	s3,8(sp)
    80002ee0:	1800                	addi	s0,sp,48
    80002ee2:	892a                	mv	s2,a0
    80002ee4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ee6:	00014517          	auipc	a0,0x14
    80002eea:	ab250513          	addi	a0,a0,-1358 # 80016998 <bcache>
    80002eee:	ffffe097          	auipc	ra,0xffffe
    80002ef2:	ce8080e7          	jalr	-792(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ef6:	0001c497          	auipc	s1,0x1c
    80002efa:	d5a4b483          	ld	s1,-678(s1) # 8001ec50 <bcache+0x82b8>
    80002efe:	0001c797          	auipc	a5,0x1c
    80002f02:	d0278793          	addi	a5,a5,-766 # 8001ec00 <bcache+0x8268>
    80002f06:	02f48f63          	beq	s1,a5,80002f44 <bread+0x70>
    80002f0a:	873e                	mv	a4,a5
    80002f0c:	a021                	j	80002f14 <bread+0x40>
    80002f0e:	68a4                	ld	s1,80(s1)
    80002f10:	02e48a63          	beq	s1,a4,80002f44 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f14:	449c                	lw	a5,8(s1)
    80002f16:	ff279ce3          	bne	a5,s2,80002f0e <bread+0x3a>
    80002f1a:	44dc                	lw	a5,12(s1)
    80002f1c:	ff3799e3          	bne	a5,s3,80002f0e <bread+0x3a>
      b->refcnt++;
    80002f20:	40bc                	lw	a5,64(s1)
    80002f22:	2785                	addiw	a5,a5,1
    80002f24:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f26:	00014517          	auipc	a0,0x14
    80002f2a:	a7250513          	addi	a0,a0,-1422 # 80016998 <bcache>
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	d5c080e7          	jalr	-676(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f36:	01048513          	addi	a0,s1,16
    80002f3a:	00001097          	auipc	ra,0x1
    80002f3e:	46e080e7          	jalr	1134(ra) # 800043a8 <acquiresleep>
      return b;
    80002f42:	a8b9                	j	80002fa0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f44:	0001c497          	auipc	s1,0x1c
    80002f48:	d044b483          	ld	s1,-764(s1) # 8001ec48 <bcache+0x82b0>
    80002f4c:	0001c797          	auipc	a5,0x1c
    80002f50:	cb478793          	addi	a5,a5,-844 # 8001ec00 <bcache+0x8268>
    80002f54:	00f48863          	beq	s1,a5,80002f64 <bread+0x90>
    80002f58:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f5a:	40bc                	lw	a5,64(s1)
    80002f5c:	cf81                	beqz	a5,80002f74 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f5e:	64a4                	ld	s1,72(s1)
    80002f60:	fee49de3          	bne	s1,a4,80002f5a <bread+0x86>
  panic("bget: no buffers");
    80002f64:	00005517          	auipc	a0,0x5
    80002f68:	5cc50513          	addi	a0,a0,1484 # 80008530 <syscalls+0xe0>
    80002f6c:	ffffd097          	auipc	ra,0xffffd
    80002f70:	5d2080e7          	jalr	1490(ra) # 8000053e <panic>
      b->dev = dev;
    80002f74:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f78:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f7c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f80:	4785                	li	a5,1
    80002f82:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f84:	00014517          	auipc	a0,0x14
    80002f88:	a1450513          	addi	a0,a0,-1516 # 80016998 <bcache>
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	cfe080e7          	jalr	-770(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f94:	01048513          	addi	a0,s1,16
    80002f98:	00001097          	auipc	ra,0x1
    80002f9c:	410080e7          	jalr	1040(ra) # 800043a8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fa0:	409c                	lw	a5,0(s1)
    80002fa2:	cb89                	beqz	a5,80002fb4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fa4:	8526                	mv	a0,s1
    80002fa6:	70a2                	ld	ra,40(sp)
    80002fa8:	7402                	ld	s0,32(sp)
    80002faa:	64e2                	ld	s1,24(sp)
    80002fac:	6942                	ld	s2,16(sp)
    80002fae:	69a2                	ld	s3,8(sp)
    80002fb0:	6145                	addi	sp,sp,48
    80002fb2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fb4:	4581                	li	a1,0
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	00003097          	auipc	ra,0x3
    80002fbc:	fdc080e7          	jalr	-36(ra) # 80005f94 <virtio_disk_rw>
    b->valid = 1;
    80002fc0:	4785                	li	a5,1
    80002fc2:	c09c                	sw	a5,0(s1)
  return b;
    80002fc4:	b7c5                	j	80002fa4 <bread+0xd0>

0000000080002fc6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fc6:	1101                	addi	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	e426                	sd	s1,8(sp)
    80002fce:	1000                	addi	s0,sp,32
    80002fd0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fd2:	0541                	addi	a0,a0,16
    80002fd4:	00001097          	auipc	ra,0x1
    80002fd8:	46e080e7          	jalr	1134(ra) # 80004442 <holdingsleep>
    80002fdc:	cd01                	beqz	a0,80002ff4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fde:	4585                	li	a1,1
    80002fe0:	8526                	mv	a0,s1
    80002fe2:	00003097          	auipc	ra,0x3
    80002fe6:	fb2080e7          	jalr	-78(ra) # 80005f94 <virtio_disk_rw>
}
    80002fea:	60e2                	ld	ra,24(sp)
    80002fec:	6442                	ld	s0,16(sp)
    80002fee:	64a2                	ld	s1,8(sp)
    80002ff0:	6105                	addi	sp,sp,32
    80002ff2:	8082                	ret
    panic("bwrite");
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	55450513          	addi	a0,a0,1364 # 80008548 <syscalls+0xf8>
    80002ffc:	ffffd097          	auipc	ra,0xffffd
    80003000:	542080e7          	jalr	1346(ra) # 8000053e <panic>

0000000080003004 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	e426                	sd	s1,8(sp)
    8000300c:	e04a                	sd	s2,0(sp)
    8000300e:	1000                	addi	s0,sp,32
    80003010:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003012:	01050913          	addi	s2,a0,16
    80003016:	854a                	mv	a0,s2
    80003018:	00001097          	auipc	ra,0x1
    8000301c:	42a080e7          	jalr	1066(ra) # 80004442 <holdingsleep>
    80003020:	c92d                	beqz	a0,80003092 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003022:	854a                	mv	a0,s2
    80003024:	00001097          	auipc	ra,0x1
    80003028:	3da080e7          	jalr	986(ra) # 800043fe <releasesleep>

  acquire(&bcache.lock);
    8000302c:	00014517          	auipc	a0,0x14
    80003030:	96c50513          	addi	a0,a0,-1684 # 80016998 <bcache>
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	ba2080e7          	jalr	-1118(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000303c:	40bc                	lw	a5,64(s1)
    8000303e:	37fd                	addiw	a5,a5,-1
    80003040:	0007871b          	sext.w	a4,a5
    80003044:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003046:	eb05                	bnez	a4,80003076 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003048:	68bc                	ld	a5,80(s1)
    8000304a:	64b8                	ld	a4,72(s1)
    8000304c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000304e:	64bc                	ld	a5,72(s1)
    80003050:	68b8                	ld	a4,80(s1)
    80003052:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003054:	0001c797          	auipc	a5,0x1c
    80003058:	94478793          	addi	a5,a5,-1724 # 8001e998 <bcache+0x8000>
    8000305c:	2b87b703          	ld	a4,696(a5)
    80003060:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003062:	0001c717          	auipc	a4,0x1c
    80003066:	b9e70713          	addi	a4,a4,-1122 # 8001ec00 <bcache+0x8268>
    8000306a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000306c:	2b87b703          	ld	a4,696(a5)
    80003070:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003072:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003076:	00014517          	auipc	a0,0x14
    8000307a:	92250513          	addi	a0,a0,-1758 # 80016998 <bcache>
    8000307e:	ffffe097          	auipc	ra,0xffffe
    80003082:	c0c080e7          	jalr	-1012(ra) # 80000c8a <release>
}
    80003086:	60e2                	ld	ra,24(sp)
    80003088:	6442                	ld	s0,16(sp)
    8000308a:	64a2                	ld	s1,8(sp)
    8000308c:	6902                	ld	s2,0(sp)
    8000308e:	6105                	addi	sp,sp,32
    80003090:	8082                	ret
    panic("brelse");
    80003092:	00005517          	auipc	a0,0x5
    80003096:	4be50513          	addi	a0,a0,1214 # 80008550 <syscalls+0x100>
    8000309a:	ffffd097          	auipc	ra,0xffffd
    8000309e:	4a4080e7          	jalr	1188(ra) # 8000053e <panic>

00000000800030a2 <bpin>:

void
bpin(struct buf *b) {
    800030a2:	1101                	addi	sp,sp,-32
    800030a4:	ec06                	sd	ra,24(sp)
    800030a6:	e822                	sd	s0,16(sp)
    800030a8:	e426                	sd	s1,8(sp)
    800030aa:	1000                	addi	s0,sp,32
    800030ac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030ae:	00014517          	auipc	a0,0x14
    800030b2:	8ea50513          	addi	a0,a0,-1814 # 80016998 <bcache>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	b20080e7          	jalr	-1248(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800030be:	40bc                	lw	a5,64(s1)
    800030c0:	2785                	addiw	a5,a5,1
    800030c2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c4:	00014517          	auipc	a0,0x14
    800030c8:	8d450513          	addi	a0,a0,-1836 # 80016998 <bcache>
    800030cc:	ffffe097          	auipc	ra,0xffffe
    800030d0:	bbe080e7          	jalr	-1090(ra) # 80000c8a <release>
}
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6105                	addi	sp,sp,32
    800030dc:	8082                	ret

00000000800030de <bunpin>:

void
bunpin(struct buf *b) {
    800030de:	1101                	addi	sp,sp,-32
    800030e0:	ec06                	sd	ra,24(sp)
    800030e2:	e822                	sd	s0,16(sp)
    800030e4:	e426                	sd	s1,8(sp)
    800030e6:	1000                	addi	s0,sp,32
    800030e8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030ea:	00014517          	auipc	a0,0x14
    800030ee:	8ae50513          	addi	a0,a0,-1874 # 80016998 <bcache>
    800030f2:	ffffe097          	auipc	ra,0xffffe
    800030f6:	ae4080e7          	jalr	-1308(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030fa:	40bc                	lw	a5,64(s1)
    800030fc:	37fd                	addiw	a5,a5,-1
    800030fe:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003100:	00014517          	auipc	a0,0x14
    80003104:	89850513          	addi	a0,a0,-1896 # 80016998 <bcache>
    80003108:	ffffe097          	auipc	ra,0xffffe
    8000310c:	b82080e7          	jalr	-1150(ra) # 80000c8a <release>
}
    80003110:	60e2                	ld	ra,24(sp)
    80003112:	6442                	ld	s0,16(sp)
    80003114:	64a2                	ld	s1,8(sp)
    80003116:	6105                	addi	sp,sp,32
    80003118:	8082                	ret

000000008000311a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000311a:	1101                	addi	sp,sp,-32
    8000311c:	ec06                	sd	ra,24(sp)
    8000311e:	e822                	sd	s0,16(sp)
    80003120:	e426                	sd	s1,8(sp)
    80003122:	e04a                	sd	s2,0(sp)
    80003124:	1000                	addi	s0,sp,32
    80003126:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003128:	00d5d59b          	srliw	a1,a1,0xd
    8000312c:	0001c797          	auipc	a5,0x1c
    80003130:	f487a783          	lw	a5,-184(a5) # 8001f074 <sb+0x1c>
    80003134:	9dbd                	addw	a1,a1,a5
    80003136:	00000097          	auipc	ra,0x0
    8000313a:	d9e080e7          	jalr	-610(ra) # 80002ed4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000313e:	0074f713          	andi	a4,s1,7
    80003142:	4785                	li	a5,1
    80003144:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003148:	14ce                	slli	s1,s1,0x33
    8000314a:	90d9                	srli	s1,s1,0x36
    8000314c:	00950733          	add	a4,a0,s1
    80003150:	05874703          	lbu	a4,88(a4)
    80003154:	00e7f6b3          	and	a3,a5,a4
    80003158:	c69d                	beqz	a3,80003186 <bfree+0x6c>
    8000315a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000315c:	94aa                	add	s1,s1,a0
    8000315e:	fff7c793          	not	a5,a5
    80003162:	8ff9                	and	a5,a5,a4
    80003164:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	120080e7          	jalr	288(ra) # 80004288 <log_write>
  brelse(bp);
    80003170:	854a                	mv	a0,s2
    80003172:	00000097          	auipc	ra,0x0
    80003176:	e92080e7          	jalr	-366(ra) # 80003004 <brelse>
}
    8000317a:	60e2                	ld	ra,24(sp)
    8000317c:	6442                	ld	s0,16(sp)
    8000317e:	64a2                	ld	s1,8(sp)
    80003180:	6902                	ld	s2,0(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret
    panic("freeing free block");
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	3d250513          	addi	a0,a0,978 # 80008558 <syscalls+0x108>
    8000318e:	ffffd097          	auipc	ra,0xffffd
    80003192:	3b0080e7          	jalr	944(ra) # 8000053e <panic>

0000000080003196 <balloc>:
{
    80003196:	711d                	addi	sp,sp,-96
    80003198:	ec86                	sd	ra,88(sp)
    8000319a:	e8a2                	sd	s0,80(sp)
    8000319c:	e4a6                	sd	s1,72(sp)
    8000319e:	e0ca                	sd	s2,64(sp)
    800031a0:	fc4e                	sd	s3,56(sp)
    800031a2:	f852                	sd	s4,48(sp)
    800031a4:	f456                	sd	s5,40(sp)
    800031a6:	f05a                	sd	s6,32(sp)
    800031a8:	ec5e                	sd	s7,24(sp)
    800031aa:	e862                	sd	s8,16(sp)
    800031ac:	e466                	sd	s9,8(sp)
    800031ae:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031b0:	0001c797          	auipc	a5,0x1c
    800031b4:	eac7a783          	lw	a5,-340(a5) # 8001f05c <sb+0x4>
    800031b8:	10078163          	beqz	a5,800032ba <balloc+0x124>
    800031bc:	8baa                	mv	s7,a0
    800031be:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031c0:	0001cb17          	auipc	s6,0x1c
    800031c4:	e98b0b13          	addi	s6,s6,-360 # 8001f058 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031ca:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031cc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ce:	6c89                	lui	s9,0x2
    800031d0:	a061                	j	80003258 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031d2:	974a                	add	a4,a4,s2
    800031d4:	8fd5                	or	a5,a5,a3
    800031d6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800031da:	854a                	mv	a0,s2
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	0ac080e7          	jalr	172(ra) # 80004288 <log_write>
        brelse(bp);
    800031e4:	854a                	mv	a0,s2
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	e1e080e7          	jalr	-482(ra) # 80003004 <brelse>
  bp = bread(dev, bno);
    800031ee:	85a6                	mv	a1,s1
    800031f0:	855e                	mv	a0,s7
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	ce2080e7          	jalr	-798(ra) # 80002ed4 <bread>
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
    80003214:	078080e7          	jalr	120(ra) # 80004288 <log_write>
  brelse(bp);
    80003218:	854a                	mv	a0,s2
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	dea080e7          	jalr	-534(ra) # 80003004 <brelse>
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
    80003244:	dc4080e7          	jalr	-572(ra) # 80003004 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003248:	015c87bb          	addw	a5,s9,s5
    8000324c:	00078a9b          	sext.w	s5,a5
    80003250:	004b2703          	lw	a4,4(s6)
    80003254:	06eaf363          	bgeu	s5,a4,800032ba <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003258:	41fad79b          	sraiw	a5,s5,0x1f
    8000325c:	0137d79b          	srliw	a5,a5,0x13
    80003260:	015787bb          	addw	a5,a5,s5
    80003264:	40d7d79b          	sraiw	a5,a5,0xd
    80003268:	01cb2583          	lw	a1,28(s6)
    8000326c:	9dbd                	addw	a1,a1,a5
    8000326e:	855e                	mv	a0,s7
    80003270:	00000097          	auipc	ra,0x0
    80003274:	c64080e7          	jalr	-924(ra) # 80002ed4 <bread>
    80003278:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000327a:	004b2503          	lw	a0,4(s6)
    8000327e:	000a849b          	sext.w	s1,s5
    80003282:	8662                	mv	a2,s8
    80003284:	faa4fde3          	bgeu	s1,a0,8000323e <balloc+0xa8>
      m = 1 << (bi % 8);
    80003288:	41f6579b          	sraiw	a5,a2,0x1f
    8000328c:	01d7d69b          	srliw	a3,a5,0x1d
    80003290:	00c6873b          	addw	a4,a3,a2
    80003294:	00777793          	andi	a5,a4,7
    80003298:	9f95                	subw	a5,a5,a3
    8000329a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329e:	4037571b          	sraiw	a4,a4,0x3
    800032a2:	00e906b3          	add	a3,s2,a4
    800032a6:	0586c683          	lbu	a3,88(a3)
    800032aa:	00d7f5b3          	and	a1,a5,a3
    800032ae:	d195                	beqz	a1,800031d2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b0:	2605                	addiw	a2,a2,1
    800032b2:	2485                	addiw	s1,s1,1
    800032b4:	fd4618e3          	bne	a2,s4,80003284 <balloc+0xee>
    800032b8:	b759                	j	8000323e <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800032ba:	00005517          	auipc	a0,0x5
    800032be:	2b650513          	addi	a0,a0,694 # 80008570 <syscalls+0x120>
    800032c2:	ffffd097          	auipc	ra,0xffffd
    800032c6:	2c6080e7          	jalr	710(ra) # 80000588 <printf>
  return 0;
    800032ca:	4481                	li	s1,0
    800032cc:	bf99                	j	80003222 <balloc+0x8c>

00000000800032ce <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032ce:	7179                	addi	sp,sp,-48
    800032d0:	f406                	sd	ra,40(sp)
    800032d2:	f022                	sd	s0,32(sp)
    800032d4:	ec26                	sd	s1,24(sp)
    800032d6:	e84a                	sd	s2,16(sp)
    800032d8:	e44e                	sd	s3,8(sp)
    800032da:	e052                	sd	s4,0(sp)
    800032dc:	1800                	addi	s0,sp,48
    800032de:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032e0:	47ad                	li	a5,11
    800032e2:	02b7e763          	bltu	a5,a1,80003310 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800032e6:	02059493          	slli	s1,a1,0x20
    800032ea:	9081                	srli	s1,s1,0x20
    800032ec:	048a                	slli	s1,s1,0x2
    800032ee:	94aa                	add	s1,s1,a0
    800032f0:	0504a903          	lw	s2,80(s1)
    800032f4:	06091e63          	bnez	s2,80003370 <bmap+0xa2>
      addr = balloc(ip->dev);
    800032f8:	4108                	lw	a0,0(a0)
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	e9c080e7          	jalr	-356(ra) # 80003196 <balloc>
    80003302:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003306:	06090563          	beqz	s2,80003370 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000330a:	0524a823          	sw	s2,80(s1)
    8000330e:	a08d                	j	80003370 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003310:	ff45849b          	addiw	s1,a1,-12
    80003314:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003318:	0ff00793          	li	a5,255
    8000331c:	08e7e563          	bltu	a5,a4,800033a6 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003320:	08052903          	lw	s2,128(a0)
    80003324:	00091d63          	bnez	s2,8000333e <bmap+0x70>
      addr = balloc(ip->dev);
    80003328:	4108                	lw	a0,0(a0)
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	e6c080e7          	jalr	-404(ra) # 80003196 <balloc>
    80003332:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003336:	02090d63          	beqz	s2,80003370 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000333a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000333e:	85ca                	mv	a1,s2
    80003340:	0009a503          	lw	a0,0(s3)
    80003344:	00000097          	auipc	ra,0x0
    80003348:	b90080e7          	jalr	-1136(ra) # 80002ed4 <bread>
    8000334c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000334e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003352:	02049593          	slli	a1,s1,0x20
    80003356:	9181                	srli	a1,a1,0x20
    80003358:	058a                	slli	a1,a1,0x2
    8000335a:	00b784b3          	add	s1,a5,a1
    8000335e:	0004a903          	lw	s2,0(s1)
    80003362:	02090063          	beqz	s2,80003382 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003366:	8552                	mv	a0,s4
    80003368:	00000097          	auipc	ra,0x0
    8000336c:	c9c080e7          	jalr	-868(ra) # 80003004 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003370:	854a                	mv	a0,s2
    80003372:	70a2                	ld	ra,40(sp)
    80003374:	7402                	ld	s0,32(sp)
    80003376:	64e2                	ld	s1,24(sp)
    80003378:	6942                	ld	s2,16(sp)
    8000337a:	69a2                	ld	s3,8(sp)
    8000337c:	6a02                	ld	s4,0(sp)
    8000337e:	6145                	addi	sp,sp,48
    80003380:	8082                	ret
      addr = balloc(ip->dev);
    80003382:	0009a503          	lw	a0,0(s3)
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	e10080e7          	jalr	-496(ra) # 80003196 <balloc>
    8000338e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003392:	fc090ae3          	beqz	s2,80003366 <bmap+0x98>
        a[bn] = addr;
    80003396:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000339a:	8552                	mv	a0,s4
    8000339c:	00001097          	auipc	ra,0x1
    800033a0:	eec080e7          	jalr	-276(ra) # 80004288 <log_write>
    800033a4:	b7c9                	j	80003366 <bmap+0x98>
  panic("bmap: out of range");
    800033a6:	00005517          	auipc	a0,0x5
    800033aa:	1e250513          	addi	a0,a0,482 # 80008588 <syscalls+0x138>
    800033ae:	ffffd097          	auipc	ra,0xffffd
    800033b2:	190080e7          	jalr	400(ra) # 8000053e <panic>

00000000800033b6 <iget>:
{
    800033b6:	7179                	addi	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	e84a                	sd	s2,16(sp)
    800033c0:	e44e                	sd	s3,8(sp)
    800033c2:	e052                	sd	s4,0(sp)
    800033c4:	1800                	addi	s0,sp,48
    800033c6:	89aa                	mv	s3,a0
    800033c8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033ca:	0001c517          	auipc	a0,0x1c
    800033ce:	cae50513          	addi	a0,a0,-850 # 8001f078 <itable>
    800033d2:	ffffe097          	auipc	ra,0xffffe
    800033d6:	804080e7          	jalr	-2044(ra) # 80000bd6 <acquire>
  empty = 0;
    800033da:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033dc:	0001c497          	auipc	s1,0x1c
    800033e0:	cb448493          	addi	s1,s1,-844 # 8001f090 <itable+0x18>
    800033e4:	0001d697          	auipc	a3,0x1d
    800033e8:	73c68693          	addi	a3,a3,1852 # 80020b20 <log>
    800033ec:	a039                	j	800033fa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ee:	02090b63          	beqz	s2,80003424 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033f2:	08848493          	addi	s1,s1,136
    800033f6:	02d48a63          	beq	s1,a3,8000342a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033fa:	449c                	lw	a5,8(s1)
    800033fc:	fef059e3          	blez	a5,800033ee <iget+0x38>
    80003400:	4098                	lw	a4,0(s1)
    80003402:	ff3716e3          	bne	a4,s3,800033ee <iget+0x38>
    80003406:	40d8                	lw	a4,4(s1)
    80003408:	ff4713e3          	bne	a4,s4,800033ee <iget+0x38>
      ip->ref++;
    8000340c:	2785                	addiw	a5,a5,1
    8000340e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003410:	0001c517          	auipc	a0,0x1c
    80003414:	c6850513          	addi	a0,a0,-920 # 8001f078 <itable>
    80003418:	ffffe097          	auipc	ra,0xffffe
    8000341c:	872080e7          	jalr	-1934(ra) # 80000c8a <release>
      return ip;
    80003420:	8926                	mv	s2,s1
    80003422:	a03d                	j	80003450 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003424:	f7f9                	bnez	a5,800033f2 <iget+0x3c>
    80003426:	8926                	mv	s2,s1
    80003428:	b7e9                	j	800033f2 <iget+0x3c>
  if(empty == 0)
    8000342a:	02090c63          	beqz	s2,80003462 <iget+0xac>
  ip->dev = dev;
    8000342e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003432:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003436:	4785                	li	a5,1
    80003438:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000343c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003440:	0001c517          	auipc	a0,0x1c
    80003444:	c3850513          	addi	a0,a0,-968 # 8001f078 <itable>
    80003448:	ffffe097          	auipc	ra,0xffffe
    8000344c:	842080e7          	jalr	-1982(ra) # 80000c8a <release>
}
    80003450:	854a                	mv	a0,s2
    80003452:	70a2                	ld	ra,40(sp)
    80003454:	7402                	ld	s0,32(sp)
    80003456:	64e2                	ld	s1,24(sp)
    80003458:	6942                	ld	s2,16(sp)
    8000345a:	69a2                	ld	s3,8(sp)
    8000345c:	6a02                	ld	s4,0(sp)
    8000345e:	6145                	addi	sp,sp,48
    80003460:	8082                	ret
    panic("iget: no inodes");
    80003462:	00005517          	auipc	a0,0x5
    80003466:	13e50513          	addi	a0,a0,318 # 800085a0 <syscalls+0x150>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	0d4080e7          	jalr	212(ra) # 8000053e <panic>

0000000080003472 <fsinit>:
fsinit(int dev) {
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	1800                	addi	s0,sp,48
    80003480:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003482:	4585                	li	a1,1
    80003484:	00000097          	auipc	ra,0x0
    80003488:	a50080e7          	jalr	-1456(ra) # 80002ed4 <bread>
    8000348c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000348e:	0001c997          	auipc	s3,0x1c
    80003492:	bca98993          	addi	s3,s3,-1078 # 8001f058 <sb>
    80003496:	02000613          	li	a2,32
    8000349a:	05850593          	addi	a1,a0,88
    8000349e:	854e                	mv	a0,s3
    800034a0:	ffffe097          	auipc	ra,0xffffe
    800034a4:	88e080e7          	jalr	-1906(ra) # 80000d2e <memmove>
  brelse(bp);
    800034a8:	8526                	mv	a0,s1
    800034aa:	00000097          	auipc	ra,0x0
    800034ae:	b5a080e7          	jalr	-1190(ra) # 80003004 <brelse>
  if(sb.magic != FSMAGIC)
    800034b2:	0009a703          	lw	a4,0(s3)
    800034b6:	102037b7          	lui	a5,0x10203
    800034ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034be:	02f71263          	bne	a4,a5,800034e2 <fsinit+0x70>
  initlog(dev, &sb);
    800034c2:	0001c597          	auipc	a1,0x1c
    800034c6:	b9658593          	addi	a1,a1,-1130 # 8001f058 <sb>
    800034ca:	854a                	mv	a0,s2
    800034cc:	00001097          	auipc	ra,0x1
    800034d0:	b40080e7          	jalr	-1216(ra) # 8000400c <initlog>
}
    800034d4:	70a2                	ld	ra,40(sp)
    800034d6:	7402                	ld	s0,32(sp)
    800034d8:	64e2                	ld	s1,24(sp)
    800034da:	6942                	ld	s2,16(sp)
    800034dc:	69a2                	ld	s3,8(sp)
    800034de:	6145                	addi	sp,sp,48
    800034e0:	8082                	ret
    panic("invalid file system");
    800034e2:	00005517          	auipc	a0,0x5
    800034e6:	0ce50513          	addi	a0,a0,206 # 800085b0 <syscalls+0x160>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	054080e7          	jalr	84(ra) # 8000053e <panic>

00000000800034f2 <iinit>:
{
    800034f2:	7179                	addi	sp,sp,-48
    800034f4:	f406                	sd	ra,40(sp)
    800034f6:	f022                	sd	s0,32(sp)
    800034f8:	ec26                	sd	s1,24(sp)
    800034fa:	e84a                	sd	s2,16(sp)
    800034fc:	e44e                	sd	s3,8(sp)
    800034fe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003500:	00005597          	auipc	a1,0x5
    80003504:	0c858593          	addi	a1,a1,200 # 800085c8 <syscalls+0x178>
    80003508:	0001c517          	auipc	a0,0x1c
    8000350c:	b7050513          	addi	a0,a0,-1168 # 8001f078 <itable>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	636080e7          	jalr	1590(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003518:	0001c497          	auipc	s1,0x1c
    8000351c:	b8848493          	addi	s1,s1,-1144 # 8001f0a0 <itable+0x28>
    80003520:	0001d997          	auipc	s3,0x1d
    80003524:	61098993          	addi	s3,s3,1552 # 80020b30 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003528:	00005917          	auipc	s2,0x5
    8000352c:	0a890913          	addi	s2,s2,168 # 800085d0 <syscalls+0x180>
    80003530:	85ca                	mv	a1,s2
    80003532:	8526                	mv	a0,s1
    80003534:	00001097          	auipc	ra,0x1
    80003538:	e3a080e7          	jalr	-454(ra) # 8000436e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000353c:	08848493          	addi	s1,s1,136
    80003540:	ff3498e3          	bne	s1,s3,80003530 <iinit+0x3e>
}
    80003544:	70a2                	ld	ra,40(sp)
    80003546:	7402                	ld	s0,32(sp)
    80003548:	64e2                	ld	s1,24(sp)
    8000354a:	6942                	ld	s2,16(sp)
    8000354c:	69a2                	ld	s3,8(sp)
    8000354e:	6145                	addi	sp,sp,48
    80003550:	8082                	ret

0000000080003552 <ialloc>:
{
    80003552:	715d                	addi	sp,sp,-80
    80003554:	e486                	sd	ra,72(sp)
    80003556:	e0a2                	sd	s0,64(sp)
    80003558:	fc26                	sd	s1,56(sp)
    8000355a:	f84a                	sd	s2,48(sp)
    8000355c:	f44e                	sd	s3,40(sp)
    8000355e:	f052                	sd	s4,32(sp)
    80003560:	ec56                	sd	s5,24(sp)
    80003562:	e85a                	sd	s6,16(sp)
    80003564:	e45e                	sd	s7,8(sp)
    80003566:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003568:	0001c717          	auipc	a4,0x1c
    8000356c:	afc72703          	lw	a4,-1284(a4) # 8001f064 <sb+0xc>
    80003570:	4785                	li	a5,1
    80003572:	04e7fa63          	bgeu	a5,a4,800035c6 <ialloc+0x74>
    80003576:	8aaa                	mv	s5,a0
    80003578:	8bae                	mv	s7,a1
    8000357a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000357c:	0001ca17          	auipc	s4,0x1c
    80003580:	adca0a13          	addi	s4,s4,-1316 # 8001f058 <sb>
    80003584:	00048b1b          	sext.w	s6,s1
    80003588:	0044d793          	srli	a5,s1,0x4
    8000358c:	018a2583          	lw	a1,24(s4)
    80003590:	9dbd                	addw	a1,a1,a5
    80003592:	8556                	mv	a0,s5
    80003594:	00000097          	auipc	ra,0x0
    80003598:	940080e7          	jalr	-1728(ra) # 80002ed4 <bread>
    8000359c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000359e:	05850993          	addi	s3,a0,88
    800035a2:	00f4f793          	andi	a5,s1,15
    800035a6:	079a                	slli	a5,a5,0x6
    800035a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035aa:	00099783          	lh	a5,0(s3)
    800035ae:	c3a1                	beqz	a5,800035ee <ialloc+0x9c>
    brelse(bp);
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	a54080e7          	jalr	-1452(ra) # 80003004 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b8:	0485                	addi	s1,s1,1
    800035ba:	00ca2703          	lw	a4,12(s4)
    800035be:	0004879b          	sext.w	a5,s1
    800035c2:	fce7e1e3          	bltu	a5,a4,80003584 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800035c6:	00005517          	auipc	a0,0x5
    800035ca:	01250513          	addi	a0,a0,18 # 800085d8 <syscalls+0x188>
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	fba080e7          	jalr	-70(ra) # 80000588 <printf>
  return 0;
    800035d6:	4501                	li	a0,0
}
    800035d8:	60a6                	ld	ra,72(sp)
    800035da:	6406                	ld	s0,64(sp)
    800035dc:	74e2                	ld	s1,56(sp)
    800035de:	7942                	ld	s2,48(sp)
    800035e0:	79a2                	ld	s3,40(sp)
    800035e2:	7a02                	ld	s4,32(sp)
    800035e4:	6ae2                	ld	s5,24(sp)
    800035e6:	6b42                	ld	s6,16(sp)
    800035e8:	6ba2                	ld	s7,8(sp)
    800035ea:	6161                	addi	sp,sp,80
    800035ec:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035ee:	04000613          	li	a2,64
    800035f2:	4581                	li	a1,0
    800035f4:	854e                	mv	a0,s3
    800035f6:	ffffd097          	auipc	ra,0xffffd
    800035fa:	6dc080e7          	jalr	1756(ra) # 80000cd2 <memset>
      dip->type = type;
    800035fe:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003602:	854a                	mv	a0,s2
    80003604:	00001097          	auipc	ra,0x1
    80003608:	c84080e7          	jalr	-892(ra) # 80004288 <log_write>
      brelse(bp);
    8000360c:	854a                	mv	a0,s2
    8000360e:	00000097          	auipc	ra,0x0
    80003612:	9f6080e7          	jalr	-1546(ra) # 80003004 <brelse>
      return iget(dev, inum);
    80003616:	85da                	mv	a1,s6
    80003618:	8556                	mv	a0,s5
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	d9c080e7          	jalr	-612(ra) # 800033b6 <iget>
    80003622:	bf5d                	j	800035d8 <ialloc+0x86>

0000000080003624 <iupdate>:
{
    80003624:	1101                	addi	sp,sp,-32
    80003626:	ec06                	sd	ra,24(sp)
    80003628:	e822                	sd	s0,16(sp)
    8000362a:	e426                	sd	s1,8(sp)
    8000362c:	e04a                	sd	s2,0(sp)
    8000362e:	1000                	addi	s0,sp,32
    80003630:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003632:	415c                	lw	a5,4(a0)
    80003634:	0047d79b          	srliw	a5,a5,0x4
    80003638:	0001c597          	auipc	a1,0x1c
    8000363c:	a385a583          	lw	a1,-1480(a1) # 8001f070 <sb+0x18>
    80003640:	9dbd                	addw	a1,a1,a5
    80003642:	4108                	lw	a0,0(a0)
    80003644:	00000097          	auipc	ra,0x0
    80003648:	890080e7          	jalr	-1904(ra) # 80002ed4 <bread>
    8000364c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000364e:	05850793          	addi	a5,a0,88
    80003652:	40c8                	lw	a0,4(s1)
    80003654:	893d                	andi	a0,a0,15
    80003656:	051a                	slli	a0,a0,0x6
    80003658:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000365a:	04449703          	lh	a4,68(s1)
    8000365e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003662:	04649703          	lh	a4,70(s1)
    80003666:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000366a:	04849703          	lh	a4,72(s1)
    8000366e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003672:	04a49703          	lh	a4,74(s1)
    80003676:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000367a:	44f8                	lw	a4,76(s1)
    8000367c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000367e:	03400613          	li	a2,52
    80003682:	05048593          	addi	a1,s1,80
    80003686:	0531                	addi	a0,a0,12
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	6a6080e7          	jalr	1702(ra) # 80000d2e <memmove>
  log_write(bp);
    80003690:	854a                	mv	a0,s2
    80003692:	00001097          	auipc	ra,0x1
    80003696:	bf6080e7          	jalr	-1034(ra) # 80004288 <log_write>
  brelse(bp);
    8000369a:	854a                	mv	a0,s2
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	968080e7          	jalr	-1688(ra) # 80003004 <brelse>
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
    800036c0:	9bc50513          	addi	a0,a0,-1604 # 8001f078 <itable>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	512080e7          	jalr	1298(ra) # 80000bd6 <acquire>
  ip->ref++;
    800036cc:	449c                	lw	a5,8(s1)
    800036ce:	2785                	addiw	a5,a5,1
    800036d0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036d2:	0001c517          	auipc	a0,0x1c
    800036d6:	9a650513          	addi	a0,a0,-1626 # 8001f078 <itable>
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
    8000370a:	ca2080e7          	jalr	-862(ra) # 800043a8 <acquiresleep>
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
    8000372a:	e18080e7          	jalr	-488(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372e:	40dc                	lw	a5,4(s1)
    80003730:	0047d79b          	srliw	a5,a5,0x4
    80003734:	0001c597          	auipc	a1,0x1c
    80003738:	93c5a583          	lw	a1,-1732(a1) # 8001f070 <sb+0x18>
    8000373c:	9dbd                	addw	a1,a1,a5
    8000373e:	4088                	lw	a0,0(s1)
    80003740:	fffff097          	auipc	ra,0xfffff
    80003744:	794080e7          	jalr	1940(ra) # 80002ed4 <bread>
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
    80003792:	876080e7          	jalr	-1930(ra) # 80003004 <brelse>
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
    800037ac:	d96080e7          	jalr	-618(ra) # 8000053e <panic>

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
    800037ca:	c7c080e7          	jalr	-900(ra) # 80004442 <holdingsleep>
    800037ce:	cd19                	beqz	a0,800037ec <iunlock+0x3c>
    800037d0:	449c                	lw	a5,8(s1)
    800037d2:	00f05d63          	blez	a5,800037ec <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037d6:	854a                	mv	a0,s2
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	c26080e7          	jalr	-986(ra) # 800043fe <releasesleep>
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
    800037f8:	d4a080e7          	jalr	-694(ra) # 8000053e <panic>

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
    8000382a:	8f4080e7          	jalr	-1804(ra) # 8000311a <bfree>
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
    80003844:	de4080e7          	jalr	-540(ra) # 80003624 <iupdate>
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
    80003860:	678080e7          	jalr	1656(ra) # 80002ed4 <bread>
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
    80003882:	89c080e7          	jalr	-1892(ra) # 8000311a <bfree>
    80003886:	b7ed                	j	80003870 <itrunc+0x74>
    brelse(bp);
    80003888:	8552                	mv	a0,s4
    8000388a:	fffff097          	auipc	ra,0xfffff
    8000388e:	77a080e7          	jalr	1914(ra) # 80003004 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003892:	0809a583          	lw	a1,128(s3)
    80003896:	0009a503          	lw	a0,0(s3)
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	880080e7          	jalr	-1920(ra) # 8000311a <bfree>
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
    800038ba:	7c250513          	addi	a0,a0,1986 # 8001f078 <itable>
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
    800038d8:	7a450513          	addi	a0,a0,1956 # 8001f078 <itable>
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
    80003904:	aa8080e7          	jalr	-1368(ra) # 800043a8 <acquiresleep>
    release(&itable.lock);
    80003908:	0001b517          	auipc	a0,0x1b
    8000390c:	77050513          	addi	a0,a0,1904 # 8001f078 <itable>
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
    8000392c:	cfc080e7          	jalr	-772(ra) # 80003624 <iupdate>
    ip->valid = 0;
    80003930:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003934:	854a                	mv	a0,s2
    80003936:	00001097          	auipc	ra,0x1
    8000393a:	ac8080e7          	jalr	-1336(ra) # 800043fe <releasesleep>
    acquire(&itable.lock);
    8000393e:	0001b517          	auipc	a0,0x1b
    80003942:	73a50513          	addi	a0,a0,1850 # 8001f078 <itable>
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
    800039f6:	05890793          	addi	a5,s2,88
    800039fa:	86ee                	mv	a3,s11
    800039fc:	963e                	add	a2,a2,a5
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
    80003a14:	5f4080e7          	jalr	1524(ra) # 80003004 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a18:	013d09bb          	addw	s3,s10,s3
    80003a1c:	009d04bb          	addw	s1,s10,s1
    80003a20:	9a6e                	add	s4,s4,s11
    80003a22:	0559f763          	bgeu	s3,s5,80003a70 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a26:	00a4d59b          	srliw	a1,s1,0xa
    80003a2a:	855a                	mv	a0,s6
    80003a2c:	00000097          	auipc	ra,0x0
    80003a30:	8a2080e7          	jalr	-1886(ra) # 800032ce <bmap>
    80003a34:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a38:	cd85                	beqz	a1,80003a70 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a3a:	000b2503          	lw	a0,0(s6)
    80003a3e:	fffff097          	auipc	ra,0xfffff
    80003a42:	496080e7          	jalr	1174(ra) # 80002ed4 <bread>
    80003a46:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a48:	3ff4f613          	andi	a2,s1,1023
    80003a4c:	40cc87bb          	subw	a5,s9,a2
    80003a50:	413a873b          	subw	a4,s5,s3
    80003a54:	8d3e                	mv	s10,a5
    80003a56:	2781                	sext.w	a5,a5
    80003a58:	0007069b          	sext.w	a3,a4
    80003a5c:	f8f6f9e3          	bgeu	a3,a5,800039ee <readi+0x4c>
    80003a60:	8d3a                	mv	s10,a4
    80003a62:	b771                	j	800039ee <readi+0x4c>
      brelse(bp);
    80003a64:	854a                	mv	a0,s2
    80003a66:	fffff097          	auipc	ra,0xfffff
    80003a6a:	59e080e7          	jalr	1438(ra) # 80003004 <brelse>
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
    80003aee:	05848793          	addi	a5,s1,88
    80003af2:	86ee                	mv	a3,s11
    80003af4:	8652                	mv	a2,s4
    80003af6:	85de                	mv	a1,s7
    80003af8:	953e                	add	a0,a0,a5
    80003afa:	fffff097          	auipc	ra,0xfffff
    80003afe:	9c0080e7          	jalr	-1600(ra) # 800024ba <either_copyin>
    80003b02:	07850263          	beq	a0,s8,80003b66 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b06:	8526                	mv	a0,s1
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	780080e7          	jalr	1920(ra) # 80004288 <log_write>
    brelse(bp);
    80003b10:	8526                	mv	a0,s1
    80003b12:	fffff097          	auipc	ra,0xfffff
    80003b16:	4f2080e7          	jalr	1266(ra) # 80003004 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b1a:	013d09bb          	addw	s3,s10,s3
    80003b1e:	012d093b          	addw	s2,s10,s2
    80003b22:	9a6e                	add	s4,s4,s11
    80003b24:	0569f663          	bgeu	s3,s6,80003b70 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b28:	00a9559b          	srliw	a1,s2,0xa
    80003b2c:	8556                	mv	a0,s5
    80003b2e:	fffff097          	auipc	ra,0xfffff
    80003b32:	7a0080e7          	jalr	1952(ra) # 800032ce <bmap>
    80003b36:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b3a:	c99d                	beqz	a1,80003b70 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b3c:	000aa503          	lw	a0,0(s5)
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	394080e7          	jalr	916(ra) # 80002ed4 <bread>
    80003b48:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b4a:	3ff97513          	andi	a0,s2,1023
    80003b4e:	40ac87bb          	subw	a5,s9,a0
    80003b52:	413b073b          	subw	a4,s6,s3
    80003b56:	8d3e                	mv	s10,a5
    80003b58:	2781                	sext.w	a5,a5
    80003b5a:	0007069b          	sext.w	a3,a4
    80003b5e:	f8f6f4e3          	bgeu	a3,a5,80003ae6 <writei+0x4c>
    80003b62:	8d3a                	mv	s10,a4
    80003b64:	b749                	j	80003ae6 <writei+0x4c>
      brelse(bp);
    80003b66:	8526                	mv	a0,s1
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	49c080e7          	jalr	1180(ra) # 80003004 <brelse>
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
    80003b82:	aa6080e7          	jalr	-1370(ra) # 80003624 <iupdate>

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
    80003c08:	93a080e7          	jalr	-1734(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003c0c:	00005517          	auipc	a0,0x5
    80003c10:	a1c50513          	addi	a0,a0,-1508 # 80008628 <syscalls+0x1d8>
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	92a080e7          	jalr	-1750(ra) # 8000053e <panic>
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
    80003c6a:	750080e7          	jalr	1872(ra) # 800033b6 <iget>
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
    80003c9a:	1080                	addi	s0,sp,96
    80003c9c:	84aa                	mv	s1,a0
    80003c9e:	8aae                	mv	s5,a1
    80003ca0:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ca2:	00054703          	lbu	a4,0(a0)
    80003ca6:	02f00793          	li	a5,47
    80003caa:	02f70363          	beq	a4,a5,80003cd0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cae:	ffffe097          	auipc	ra,0xffffe
    80003cb2:	d06080e7          	jalr	-762(ra) # 800019b4 <myproc>
    80003cb6:	15053503          	ld	a0,336(a0)
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	9f6080e7          	jalr	-1546(ra) # 800036b0 <idup>
    80003cc2:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cc4:	02f00913          	li	s2,47
  len = path - s;
    80003cc8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003cca:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ccc:	4b85                	li	s7,1
    80003cce:	a865                	j	80003d86 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003cd0:	4585                	li	a1,1
    80003cd2:	4505                	li	a0,1
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	6e2080e7          	jalr	1762(ra) # 800033b6 <iget>
    80003cdc:	89aa                	mv	s3,a0
    80003cde:	b7dd                	j	80003cc4 <namex+0x42>
      iunlockput(ip);
    80003ce0:	854e                	mv	a0,s3
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	c6e080e7          	jalr	-914(ra) # 80003950 <iunlockput>
      return 0;
    80003cea:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cec:	854e                	mv	a0,s3
    80003cee:	60e6                	ld	ra,88(sp)
    80003cf0:	6446                	ld	s0,80(sp)
    80003cf2:	64a6                	ld	s1,72(sp)
    80003cf4:	6906                	ld	s2,64(sp)
    80003cf6:	79e2                	ld	s3,56(sp)
    80003cf8:	7a42                	ld	s4,48(sp)
    80003cfa:	7aa2                	ld	s5,40(sp)
    80003cfc:	7b02                	ld	s6,32(sp)
    80003cfe:	6be2                	ld	s7,24(sp)
    80003d00:	6c42                	ld	s8,16(sp)
    80003d02:	6ca2                	ld	s9,8(sp)
    80003d04:	6125                	addi	sp,sp,96
    80003d06:	8082                	ret
      iunlock(ip);
    80003d08:	854e                	mv	a0,s3
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	aa6080e7          	jalr	-1370(ra) # 800037b0 <iunlock>
      return ip;
    80003d12:	bfe9                	j	80003cec <namex+0x6a>
      iunlockput(ip);
    80003d14:	854e                	mv	a0,s3
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	c3a080e7          	jalr	-966(ra) # 80003950 <iunlockput>
      return 0;
    80003d1e:	89e6                	mv	s3,s9
    80003d20:	b7f1                	j	80003cec <namex+0x6a>
  len = path - s;
    80003d22:	40b48633          	sub	a2,s1,a1
    80003d26:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d2a:	099c5463          	bge	s8,s9,80003db2 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d2e:	4639                	li	a2,14
    80003d30:	8552                	mv	a0,s4
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	ffc080e7          	jalr	-4(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003d3a:	0004c783          	lbu	a5,0(s1)
    80003d3e:	01279763          	bne	a5,s2,80003d4c <namex+0xca>
    path++;
    80003d42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d44:	0004c783          	lbu	a5,0(s1)
    80003d48:	ff278de3          	beq	a5,s2,80003d42 <namex+0xc0>
    ilock(ip);
    80003d4c:	854e                	mv	a0,s3
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	9a0080e7          	jalr	-1632(ra) # 800036ee <ilock>
    if(ip->type != T_DIR){
    80003d56:	04499783          	lh	a5,68(s3)
    80003d5a:	f97793e3          	bne	a5,s7,80003ce0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d5e:	000a8563          	beqz	s5,80003d68 <namex+0xe6>
    80003d62:	0004c783          	lbu	a5,0(s1)
    80003d66:	d3cd                	beqz	a5,80003d08 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d68:	865a                	mv	a2,s6
    80003d6a:	85d2                	mv	a1,s4
    80003d6c:	854e                	mv	a0,s3
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	e64080e7          	jalr	-412(ra) # 80003bd2 <dirlookup>
    80003d76:	8caa                	mv	s9,a0
    80003d78:	dd51                	beqz	a0,80003d14 <namex+0x92>
    iunlockput(ip);
    80003d7a:	854e                	mv	a0,s3
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	bd4080e7          	jalr	-1068(ra) # 80003950 <iunlockput>
    ip = next;
    80003d84:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d86:	0004c783          	lbu	a5,0(s1)
    80003d8a:	05279763          	bne	a5,s2,80003dd8 <namex+0x156>
    path++;
    80003d8e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d90:	0004c783          	lbu	a5,0(s1)
    80003d94:	ff278de3          	beq	a5,s2,80003d8e <namex+0x10c>
  if(*path == 0)
    80003d98:	c79d                	beqz	a5,80003dc6 <namex+0x144>
    path++;
    80003d9a:	85a6                	mv	a1,s1
  len = path - s;
    80003d9c:	8cda                	mv	s9,s6
    80003d9e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003da0:	01278963          	beq	a5,s2,80003db2 <namex+0x130>
    80003da4:	dfbd                	beqz	a5,80003d22 <namex+0xa0>
    path++;
    80003da6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003da8:	0004c783          	lbu	a5,0(s1)
    80003dac:	ff279ce3          	bne	a5,s2,80003da4 <namex+0x122>
    80003db0:	bf8d                	j	80003d22 <namex+0xa0>
    memmove(name, s, len);
    80003db2:	2601                	sext.w	a2,a2
    80003db4:	8552                	mv	a0,s4
    80003db6:	ffffd097          	auipc	ra,0xffffd
    80003dba:	f78080e7          	jalr	-136(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003dbe:	9cd2                	add	s9,s9,s4
    80003dc0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dc4:	bf9d                	j	80003d3a <namex+0xb8>
  if(nameiparent){
    80003dc6:	f20a83e3          	beqz	s5,80003cec <namex+0x6a>
    iput(ip);
    80003dca:	854e                	mv	a0,s3
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	adc080e7          	jalr	-1316(ra) # 800038a8 <iput>
    return 0;
    80003dd4:	4981                	li	s3,0
    80003dd6:	bf19                	j	80003cec <namex+0x6a>
  if(*path == 0)
    80003dd8:	d7fd                	beqz	a5,80003dc6 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003dda:	0004c783          	lbu	a5,0(s1)
    80003dde:	85a6                	mv	a1,s1
    80003de0:	b7d1                	j	80003da4 <namex+0x122>

0000000080003de2 <dirlink>:
{
    80003de2:	7139                	addi	sp,sp,-64
    80003de4:	fc06                	sd	ra,56(sp)
    80003de6:	f822                	sd	s0,48(sp)
    80003de8:	f426                	sd	s1,40(sp)
    80003dea:	f04a                	sd	s2,32(sp)
    80003dec:	ec4e                	sd	s3,24(sp)
    80003dee:	e852                	sd	s4,16(sp)
    80003df0:	0080                	addi	s0,sp,64
    80003df2:	892a                	mv	s2,a0
    80003df4:	8a2e                	mv	s4,a1
    80003df6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003df8:	4601                	li	a2,0
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	dd8080e7          	jalr	-552(ra) # 80003bd2 <dirlookup>
    80003e02:	e93d                	bnez	a0,80003e78 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e04:	04c92483          	lw	s1,76(s2)
    80003e08:	c49d                	beqz	s1,80003e36 <dirlink+0x54>
    80003e0a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e0c:	4741                	li	a4,16
    80003e0e:	86a6                	mv	a3,s1
    80003e10:	fc040613          	addi	a2,s0,-64
    80003e14:	4581                	li	a1,0
    80003e16:	854a                	mv	a0,s2
    80003e18:	00000097          	auipc	ra,0x0
    80003e1c:	b8a080e7          	jalr	-1142(ra) # 800039a2 <readi>
    80003e20:	47c1                	li	a5,16
    80003e22:	06f51163          	bne	a0,a5,80003e84 <dirlink+0xa2>
    if(de.inum == 0)
    80003e26:	fc045783          	lhu	a5,-64(s0)
    80003e2a:	c791                	beqz	a5,80003e36 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2c:	24c1                	addiw	s1,s1,16
    80003e2e:	04c92783          	lw	a5,76(s2)
    80003e32:	fcf4ede3          	bltu	s1,a5,80003e0c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e36:	4639                	li	a2,14
    80003e38:	85d2                	mv	a1,s4
    80003e3a:	fc240513          	addi	a0,s0,-62
    80003e3e:	ffffd097          	auipc	ra,0xffffd
    80003e42:	fa0080e7          	jalr	-96(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003e46:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e4a:	4741                	li	a4,16
    80003e4c:	86a6                	mv	a3,s1
    80003e4e:	fc040613          	addi	a2,s0,-64
    80003e52:	4581                	li	a1,0
    80003e54:	854a                	mv	a0,s2
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	c44080e7          	jalr	-956(ra) # 80003a9a <writei>
    80003e5e:	1541                	addi	a0,a0,-16
    80003e60:	00a03533          	snez	a0,a0
    80003e64:	40a00533          	neg	a0,a0
}
    80003e68:	70e2                	ld	ra,56(sp)
    80003e6a:	7442                	ld	s0,48(sp)
    80003e6c:	74a2                	ld	s1,40(sp)
    80003e6e:	7902                	ld	s2,32(sp)
    80003e70:	69e2                	ld	s3,24(sp)
    80003e72:	6a42                	ld	s4,16(sp)
    80003e74:	6121                	addi	sp,sp,64
    80003e76:	8082                	ret
    iput(ip);
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	a30080e7          	jalr	-1488(ra) # 800038a8 <iput>
    return -1;
    80003e80:	557d                	li	a0,-1
    80003e82:	b7dd                	j	80003e68 <dirlink+0x86>
      panic("dirlink read");
    80003e84:	00004517          	auipc	a0,0x4
    80003e88:	7b450513          	addi	a0,a0,1972 # 80008638 <syscalls+0x1e8>
    80003e8c:	ffffc097          	auipc	ra,0xffffc
    80003e90:	6b2080e7          	jalr	1714(ra) # 8000053e <panic>

0000000080003e94 <namei>:

struct inode*
namei(char *path)
{
    80003e94:	1101                	addi	sp,sp,-32
    80003e96:	ec06                	sd	ra,24(sp)
    80003e98:	e822                	sd	s0,16(sp)
    80003e9a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e9c:	fe040613          	addi	a2,s0,-32
    80003ea0:	4581                	li	a1,0
    80003ea2:	00000097          	auipc	ra,0x0
    80003ea6:	de0080e7          	jalr	-544(ra) # 80003c82 <namex>
}
    80003eaa:	60e2                	ld	ra,24(sp)
    80003eac:	6442                	ld	s0,16(sp)
    80003eae:	6105                	addi	sp,sp,32
    80003eb0:	8082                	ret

0000000080003eb2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eb2:	1141                	addi	sp,sp,-16
    80003eb4:	e406                	sd	ra,8(sp)
    80003eb6:	e022                	sd	s0,0(sp)
    80003eb8:	0800                	addi	s0,sp,16
    80003eba:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ebc:	4585                	li	a1,1
    80003ebe:	00000097          	auipc	ra,0x0
    80003ec2:	dc4080e7          	jalr	-572(ra) # 80003c82 <namex>
}
    80003ec6:	60a2                	ld	ra,8(sp)
    80003ec8:	6402                	ld	s0,0(sp)
    80003eca:	0141                	addi	sp,sp,16
    80003ecc:	8082                	ret

0000000080003ece <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ece:	1101                	addi	sp,sp,-32
    80003ed0:	ec06                	sd	ra,24(sp)
    80003ed2:	e822                	sd	s0,16(sp)
    80003ed4:	e426                	sd	s1,8(sp)
    80003ed6:	e04a                	sd	s2,0(sp)
    80003ed8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003eda:	0001d917          	auipc	s2,0x1d
    80003ede:	c4690913          	addi	s2,s2,-954 # 80020b20 <log>
    80003ee2:	01892583          	lw	a1,24(s2)
    80003ee6:	02892503          	lw	a0,40(s2)
    80003eea:	fffff097          	auipc	ra,0xfffff
    80003eee:	fea080e7          	jalr	-22(ra) # 80002ed4 <bread>
    80003ef2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ef4:	02c92683          	lw	a3,44(s2)
    80003ef8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003efa:	02d05763          	blez	a3,80003f28 <write_head+0x5a>
    80003efe:	0001d797          	auipc	a5,0x1d
    80003f02:	c5278793          	addi	a5,a5,-942 # 80020b50 <log+0x30>
    80003f06:	05c50713          	addi	a4,a0,92
    80003f0a:	36fd                	addiw	a3,a3,-1
    80003f0c:	1682                	slli	a3,a3,0x20
    80003f0e:	9281                	srli	a3,a3,0x20
    80003f10:	068a                	slli	a3,a3,0x2
    80003f12:	0001d617          	auipc	a2,0x1d
    80003f16:	c4260613          	addi	a2,a2,-958 # 80020b54 <log+0x34>
    80003f1a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f1c:	4390                	lw	a2,0(a5)
    80003f1e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f20:	0791                	addi	a5,a5,4
    80003f22:	0711                	addi	a4,a4,4
    80003f24:	fed79ce3          	bne	a5,a3,80003f1c <write_head+0x4e>
  }
  bwrite(buf);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	09c080e7          	jalr	156(ra) # 80002fc6 <bwrite>
  brelse(buf);
    80003f32:	8526                	mv	a0,s1
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	0d0080e7          	jalr	208(ra) # 80003004 <brelse>
}
    80003f3c:	60e2                	ld	ra,24(sp)
    80003f3e:	6442                	ld	s0,16(sp)
    80003f40:	64a2                	ld	s1,8(sp)
    80003f42:	6902                	ld	s2,0(sp)
    80003f44:	6105                	addi	sp,sp,32
    80003f46:	8082                	ret

0000000080003f48 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f48:	0001d797          	auipc	a5,0x1d
    80003f4c:	c047a783          	lw	a5,-1020(a5) # 80020b4c <log+0x2c>
    80003f50:	0af05d63          	blez	a5,8000400a <install_trans+0xc2>
{
    80003f54:	7139                	addi	sp,sp,-64
    80003f56:	fc06                	sd	ra,56(sp)
    80003f58:	f822                	sd	s0,48(sp)
    80003f5a:	f426                	sd	s1,40(sp)
    80003f5c:	f04a                	sd	s2,32(sp)
    80003f5e:	ec4e                	sd	s3,24(sp)
    80003f60:	e852                	sd	s4,16(sp)
    80003f62:	e456                	sd	s5,8(sp)
    80003f64:	e05a                	sd	s6,0(sp)
    80003f66:	0080                	addi	s0,sp,64
    80003f68:	8b2a                	mv	s6,a0
    80003f6a:	0001da97          	auipc	s5,0x1d
    80003f6e:	be6a8a93          	addi	s5,s5,-1050 # 80020b50 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f72:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f74:	0001d997          	auipc	s3,0x1d
    80003f78:	bac98993          	addi	s3,s3,-1108 # 80020b20 <log>
    80003f7c:	a00d                	j	80003f9e <install_trans+0x56>
    brelse(lbuf);
    80003f7e:	854a                	mv	a0,s2
    80003f80:	fffff097          	auipc	ra,0xfffff
    80003f84:	084080e7          	jalr	132(ra) # 80003004 <brelse>
    brelse(dbuf);
    80003f88:	8526                	mv	a0,s1
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	07a080e7          	jalr	122(ra) # 80003004 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f92:	2a05                	addiw	s4,s4,1
    80003f94:	0a91                	addi	s5,s5,4
    80003f96:	02c9a783          	lw	a5,44(s3)
    80003f9a:	04fa5e63          	bge	s4,a5,80003ff6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f9e:	0189a583          	lw	a1,24(s3)
    80003fa2:	014585bb          	addw	a1,a1,s4
    80003fa6:	2585                	addiw	a1,a1,1
    80003fa8:	0289a503          	lw	a0,40(s3)
    80003fac:	fffff097          	auipc	ra,0xfffff
    80003fb0:	f28080e7          	jalr	-216(ra) # 80002ed4 <bread>
    80003fb4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fb6:	000aa583          	lw	a1,0(s5)
    80003fba:	0289a503          	lw	a0,40(s3)
    80003fbe:	fffff097          	auipc	ra,0xfffff
    80003fc2:	f16080e7          	jalr	-234(ra) # 80002ed4 <bread>
    80003fc6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fc8:	40000613          	li	a2,1024
    80003fcc:	05890593          	addi	a1,s2,88
    80003fd0:	05850513          	addi	a0,a0,88
    80003fd4:	ffffd097          	auipc	ra,0xffffd
    80003fd8:	d5a080e7          	jalr	-678(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fdc:	8526                	mv	a0,s1
    80003fde:	fffff097          	auipc	ra,0xfffff
    80003fe2:	fe8080e7          	jalr	-24(ra) # 80002fc6 <bwrite>
    if(recovering == 0)
    80003fe6:	f80b1ce3          	bnez	s6,80003f7e <install_trans+0x36>
      bunpin(dbuf);
    80003fea:	8526                	mv	a0,s1
    80003fec:	fffff097          	auipc	ra,0xfffff
    80003ff0:	0f2080e7          	jalr	242(ra) # 800030de <bunpin>
    80003ff4:	b769                	j	80003f7e <install_trans+0x36>
}
    80003ff6:	70e2                	ld	ra,56(sp)
    80003ff8:	7442                	ld	s0,48(sp)
    80003ffa:	74a2                	ld	s1,40(sp)
    80003ffc:	7902                	ld	s2,32(sp)
    80003ffe:	69e2                	ld	s3,24(sp)
    80004000:	6a42                	ld	s4,16(sp)
    80004002:	6aa2                	ld	s5,8(sp)
    80004004:	6b02                	ld	s6,0(sp)
    80004006:	6121                	addi	sp,sp,64
    80004008:	8082                	ret
    8000400a:	8082                	ret

000000008000400c <initlog>:
{
    8000400c:	7179                	addi	sp,sp,-48
    8000400e:	f406                	sd	ra,40(sp)
    80004010:	f022                	sd	s0,32(sp)
    80004012:	ec26                	sd	s1,24(sp)
    80004014:	e84a                	sd	s2,16(sp)
    80004016:	e44e                	sd	s3,8(sp)
    80004018:	1800                	addi	s0,sp,48
    8000401a:	892a                	mv	s2,a0
    8000401c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000401e:	0001d497          	auipc	s1,0x1d
    80004022:	b0248493          	addi	s1,s1,-1278 # 80020b20 <log>
    80004026:	00004597          	auipc	a1,0x4
    8000402a:	62258593          	addi	a1,a1,1570 # 80008648 <syscalls+0x1f8>
    8000402e:	8526                	mv	a0,s1
    80004030:	ffffd097          	auipc	ra,0xffffd
    80004034:	b16080e7          	jalr	-1258(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004038:	0149a583          	lw	a1,20(s3)
    8000403c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000403e:	0109a783          	lw	a5,16(s3)
    80004042:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004044:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004048:	854a                	mv	a0,s2
    8000404a:	fffff097          	auipc	ra,0xfffff
    8000404e:	e8a080e7          	jalr	-374(ra) # 80002ed4 <bread>
  log.lh.n = lh->n;
    80004052:	4d34                	lw	a3,88(a0)
    80004054:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004056:	02d05563          	blez	a3,80004080 <initlog+0x74>
    8000405a:	05c50793          	addi	a5,a0,92
    8000405e:	0001d717          	auipc	a4,0x1d
    80004062:	af270713          	addi	a4,a4,-1294 # 80020b50 <log+0x30>
    80004066:	36fd                	addiw	a3,a3,-1
    80004068:	1682                	slli	a3,a3,0x20
    8000406a:	9281                	srli	a3,a3,0x20
    8000406c:	068a                	slli	a3,a3,0x2
    8000406e:	06050613          	addi	a2,a0,96
    80004072:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004074:	4390                	lw	a2,0(a5)
    80004076:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004078:	0791                	addi	a5,a5,4
    8000407a:	0711                	addi	a4,a4,4
    8000407c:	fed79ce3          	bne	a5,a3,80004074 <initlog+0x68>
  brelse(buf);
    80004080:	fffff097          	auipc	ra,0xfffff
    80004084:	f84080e7          	jalr	-124(ra) # 80003004 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004088:	4505                	li	a0,1
    8000408a:	00000097          	auipc	ra,0x0
    8000408e:	ebe080e7          	jalr	-322(ra) # 80003f48 <install_trans>
  log.lh.n = 0;
    80004092:	0001d797          	auipc	a5,0x1d
    80004096:	aa07ad23          	sw	zero,-1350(a5) # 80020b4c <log+0x2c>
  write_head(); // clear the log
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	e34080e7          	jalr	-460(ra) # 80003ece <write_head>
}
    800040a2:	70a2                	ld	ra,40(sp)
    800040a4:	7402                	ld	s0,32(sp)
    800040a6:	64e2                	ld	s1,24(sp)
    800040a8:	6942                	ld	s2,16(sp)
    800040aa:	69a2                	ld	s3,8(sp)
    800040ac:	6145                	addi	sp,sp,48
    800040ae:	8082                	ret

00000000800040b0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040b0:	1101                	addi	sp,sp,-32
    800040b2:	ec06                	sd	ra,24(sp)
    800040b4:	e822                	sd	s0,16(sp)
    800040b6:	e426                	sd	s1,8(sp)
    800040b8:	e04a                	sd	s2,0(sp)
    800040ba:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040bc:	0001d517          	auipc	a0,0x1d
    800040c0:	a6450513          	addi	a0,a0,-1436 # 80020b20 <log>
    800040c4:	ffffd097          	auipc	ra,0xffffd
    800040c8:	b12080e7          	jalr	-1262(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800040cc:	0001d497          	auipc	s1,0x1d
    800040d0:	a5448493          	addi	s1,s1,-1452 # 80020b20 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040d4:	4979                	li	s2,30
    800040d6:	a039                	j	800040e4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800040d8:	85a6                	mv	a1,s1
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffe097          	auipc	ra,0xffffe
    800040e0:	f80080e7          	jalr	-128(ra) # 8000205c <sleep>
    if(log.committing){
    800040e4:	50dc                	lw	a5,36(s1)
    800040e6:	fbed                	bnez	a5,800040d8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040e8:	509c                	lw	a5,32(s1)
    800040ea:	0017871b          	addiw	a4,a5,1
    800040ee:	0007069b          	sext.w	a3,a4
    800040f2:	0027179b          	slliw	a5,a4,0x2
    800040f6:	9fb9                	addw	a5,a5,a4
    800040f8:	0017979b          	slliw	a5,a5,0x1
    800040fc:	54d8                	lw	a4,44(s1)
    800040fe:	9fb9                	addw	a5,a5,a4
    80004100:	00f95963          	bge	s2,a5,80004112 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004104:	85a6                	mv	a1,s1
    80004106:	8526                	mv	a0,s1
    80004108:	ffffe097          	auipc	ra,0xffffe
    8000410c:	f54080e7          	jalr	-172(ra) # 8000205c <sleep>
    80004110:	bfd1                	j	800040e4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004112:	0001d517          	auipc	a0,0x1d
    80004116:	a0e50513          	addi	a0,a0,-1522 # 80020b20 <log>
    8000411a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000411c:	ffffd097          	auipc	ra,0xffffd
    80004120:	b6e080e7          	jalr	-1170(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004124:	60e2                	ld	ra,24(sp)
    80004126:	6442                	ld	s0,16(sp)
    80004128:	64a2                	ld	s1,8(sp)
    8000412a:	6902                	ld	s2,0(sp)
    8000412c:	6105                	addi	sp,sp,32
    8000412e:	8082                	ret

0000000080004130 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004130:	7139                	addi	sp,sp,-64
    80004132:	fc06                	sd	ra,56(sp)
    80004134:	f822                	sd	s0,48(sp)
    80004136:	f426                	sd	s1,40(sp)
    80004138:	f04a                	sd	s2,32(sp)
    8000413a:	ec4e                	sd	s3,24(sp)
    8000413c:	e852                	sd	s4,16(sp)
    8000413e:	e456                	sd	s5,8(sp)
    80004140:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004142:	0001d497          	auipc	s1,0x1d
    80004146:	9de48493          	addi	s1,s1,-1570 # 80020b20 <log>
    8000414a:	8526                	mv	a0,s1
    8000414c:	ffffd097          	auipc	ra,0xffffd
    80004150:	a8a080e7          	jalr	-1398(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004154:	509c                	lw	a5,32(s1)
    80004156:	37fd                	addiw	a5,a5,-1
    80004158:	0007891b          	sext.w	s2,a5
    8000415c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000415e:	50dc                	lw	a5,36(s1)
    80004160:	e7b9                	bnez	a5,800041ae <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004162:	04091e63          	bnez	s2,800041be <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004166:	0001d497          	auipc	s1,0x1d
    8000416a:	9ba48493          	addi	s1,s1,-1606 # 80020b20 <log>
    8000416e:	4785                	li	a5,1
    80004170:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004172:	8526                	mv	a0,s1
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	b16080e7          	jalr	-1258(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000417c:	54dc                	lw	a5,44(s1)
    8000417e:	06f04763          	bgtz	a5,800041ec <end_op+0xbc>
    acquire(&log.lock);
    80004182:	0001d497          	auipc	s1,0x1d
    80004186:	99e48493          	addi	s1,s1,-1634 # 80020b20 <log>
    8000418a:	8526                	mv	a0,s1
    8000418c:	ffffd097          	auipc	ra,0xffffd
    80004190:	a4a080e7          	jalr	-1462(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004194:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004198:	8526                	mv	a0,s1
    8000419a:	ffffe097          	auipc	ra,0xffffe
    8000419e:	f26080e7          	jalr	-218(ra) # 800020c0 <wakeup>
    release(&log.lock);
    800041a2:	8526                	mv	a0,s1
    800041a4:	ffffd097          	auipc	ra,0xffffd
    800041a8:	ae6080e7          	jalr	-1306(ra) # 80000c8a <release>
}
    800041ac:	a03d                	j	800041da <end_op+0xaa>
    panic("log.committing");
    800041ae:	00004517          	auipc	a0,0x4
    800041b2:	4a250513          	addi	a0,a0,1186 # 80008650 <syscalls+0x200>
    800041b6:	ffffc097          	auipc	ra,0xffffc
    800041ba:	388080e7          	jalr	904(ra) # 8000053e <panic>
    wakeup(&log);
    800041be:	0001d497          	auipc	s1,0x1d
    800041c2:	96248493          	addi	s1,s1,-1694 # 80020b20 <log>
    800041c6:	8526                	mv	a0,s1
    800041c8:	ffffe097          	auipc	ra,0xffffe
    800041cc:	ef8080e7          	jalr	-264(ra) # 800020c0 <wakeup>
  release(&log.lock);
    800041d0:	8526                	mv	a0,s1
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	ab8080e7          	jalr	-1352(ra) # 80000c8a <release>
}
    800041da:	70e2                	ld	ra,56(sp)
    800041dc:	7442                	ld	s0,48(sp)
    800041de:	74a2                	ld	s1,40(sp)
    800041e0:	7902                	ld	s2,32(sp)
    800041e2:	69e2                	ld	s3,24(sp)
    800041e4:	6a42                	ld	s4,16(sp)
    800041e6:	6aa2                	ld	s5,8(sp)
    800041e8:	6121                	addi	sp,sp,64
    800041ea:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ec:	0001da97          	auipc	s5,0x1d
    800041f0:	964a8a93          	addi	s5,s5,-1692 # 80020b50 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041f4:	0001da17          	auipc	s4,0x1d
    800041f8:	92ca0a13          	addi	s4,s4,-1748 # 80020b20 <log>
    800041fc:	018a2583          	lw	a1,24(s4)
    80004200:	012585bb          	addw	a1,a1,s2
    80004204:	2585                	addiw	a1,a1,1
    80004206:	028a2503          	lw	a0,40(s4)
    8000420a:	fffff097          	auipc	ra,0xfffff
    8000420e:	cca080e7          	jalr	-822(ra) # 80002ed4 <bread>
    80004212:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004214:	000aa583          	lw	a1,0(s5)
    80004218:	028a2503          	lw	a0,40(s4)
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	cb8080e7          	jalr	-840(ra) # 80002ed4 <bread>
    80004224:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004226:	40000613          	li	a2,1024
    8000422a:	05850593          	addi	a1,a0,88
    8000422e:	05848513          	addi	a0,s1,88
    80004232:	ffffd097          	auipc	ra,0xffffd
    80004236:	afc080e7          	jalr	-1284(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000423a:	8526                	mv	a0,s1
    8000423c:	fffff097          	auipc	ra,0xfffff
    80004240:	d8a080e7          	jalr	-630(ra) # 80002fc6 <bwrite>
    brelse(from);
    80004244:	854e                	mv	a0,s3
    80004246:	fffff097          	auipc	ra,0xfffff
    8000424a:	dbe080e7          	jalr	-578(ra) # 80003004 <brelse>
    brelse(to);
    8000424e:	8526                	mv	a0,s1
    80004250:	fffff097          	auipc	ra,0xfffff
    80004254:	db4080e7          	jalr	-588(ra) # 80003004 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004258:	2905                	addiw	s2,s2,1
    8000425a:	0a91                	addi	s5,s5,4
    8000425c:	02ca2783          	lw	a5,44(s4)
    80004260:	f8f94ee3          	blt	s2,a5,800041fc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004264:	00000097          	auipc	ra,0x0
    80004268:	c6a080e7          	jalr	-918(ra) # 80003ece <write_head>
    install_trans(0); // Now install writes to home locations
    8000426c:	4501                	li	a0,0
    8000426e:	00000097          	auipc	ra,0x0
    80004272:	cda080e7          	jalr	-806(ra) # 80003f48 <install_trans>
    log.lh.n = 0;
    80004276:	0001d797          	auipc	a5,0x1d
    8000427a:	8c07ab23          	sw	zero,-1834(a5) # 80020b4c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000427e:	00000097          	auipc	ra,0x0
    80004282:	c50080e7          	jalr	-944(ra) # 80003ece <write_head>
    80004286:	bdf5                	j	80004182 <end_op+0x52>

0000000080004288 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004288:	1101                	addi	sp,sp,-32
    8000428a:	ec06                	sd	ra,24(sp)
    8000428c:	e822                	sd	s0,16(sp)
    8000428e:	e426                	sd	s1,8(sp)
    80004290:	e04a                	sd	s2,0(sp)
    80004292:	1000                	addi	s0,sp,32
    80004294:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004296:	0001d917          	auipc	s2,0x1d
    8000429a:	88a90913          	addi	s2,s2,-1910 # 80020b20 <log>
    8000429e:	854a                	mv	a0,s2
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	936080e7          	jalr	-1738(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042a8:	02c92603          	lw	a2,44(s2)
    800042ac:	47f5                	li	a5,29
    800042ae:	06c7c563          	blt	a5,a2,80004318 <log_write+0x90>
    800042b2:	0001d797          	auipc	a5,0x1d
    800042b6:	88a7a783          	lw	a5,-1910(a5) # 80020b3c <log+0x1c>
    800042ba:	37fd                	addiw	a5,a5,-1
    800042bc:	04f65e63          	bge	a2,a5,80004318 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042c0:	0001d797          	auipc	a5,0x1d
    800042c4:	8807a783          	lw	a5,-1920(a5) # 80020b40 <log+0x20>
    800042c8:	06f05063          	blez	a5,80004328 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042cc:	4781                	li	a5,0
    800042ce:	06c05563          	blez	a2,80004338 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042d2:	44cc                	lw	a1,12(s1)
    800042d4:	0001d717          	auipc	a4,0x1d
    800042d8:	87c70713          	addi	a4,a4,-1924 # 80020b50 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042dc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042de:	4314                	lw	a3,0(a4)
    800042e0:	04b68c63          	beq	a3,a1,80004338 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042e4:	2785                	addiw	a5,a5,1
    800042e6:	0711                	addi	a4,a4,4
    800042e8:	fef61be3          	bne	a2,a5,800042de <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042ec:	0621                	addi	a2,a2,8
    800042ee:	060a                	slli	a2,a2,0x2
    800042f0:	0001d797          	auipc	a5,0x1d
    800042f4:	83078793          	addi	a5,a5,-2000 # 80020b20 <log>
    800042f8:	963e                	add	a2,a2,a5
    800042fa:	44dc                	lw	a5,12(s1)
    800042fc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042fe:	8526                	mv	a0,s1
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	da2080e7          	jalr	-606(ra) # 800030a2 <bpin>
    log.lh.n++;
    80004308:	0001d717          	auipc	a4,0x1d
    8000430c:	81870713          	addi	a4,a4,-2024 # 80020b20 <log>
    80004310:	575c                	lw	a5,44(a4)
    80004312:	2785                	addiw	a5,a5,1
    80004314:	d75c                	sw	a5,44(a4)
    80004316:	a835                	j	80004352 <log_write+0xca>
    panic("too big a transaction");
    80004318:	00004517          	auipc	a0,0x4
    8000431c:	34850513          	addi	a0,a0,840 # 80008660 <syscalls+0x210>
    80004320:	ffffc097          	auipc	ra,0xffffc
    80004324:	21e080e7          	jalr	542(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004328:	00004517          	auipc	a0,0x4
    8000432c:	35050513          	addi	a0,a0,848 # 80008678 <syscalls+0x228>
    80004330:	ffffc097          	auipc	ra,0xffffc
    80004334:	20e080e7          	jalr	526(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004338:	00878713          	addi	a4,a5,8
    8000433c:	00271693          	slli	a3,a4,0x2
    80004340:	0001c717          	auipc	a4,0x1c
    80004344:	7e070713          	addi	a4,a4,2016 # 80020b20 <log>
    80004348:	9736                	add	a4,a4,a3
    8000434a:	44d4                	lw	a3,12(s1)
    8000434c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000434e:	faf608e3          	beq	a2,a5,800042fe <log_write+0x76>
  }
  release(&log.lock);
    80004352:	0001c517          	auipc	a0,0x1c
    80004356:	7ce50513          	addi	a0,a0,1998 # 80020b20 <log>
    8000435a:	ffffd097          	auipc	ra,0xffffd
    8000435e:	930080e7          	jalr	-1744(ra) # 80000c8a <release>
}
    80004362:	60e2                	ld	ra,24(sp)
    80004364:	6442                	ld	s0,16(sp)
    80004366:	64a2                	ld	s1,8(sp)
    80004368:	6902                	ld	s2,0(sp)
    8000436a:	6105                	addi	sp,sp,32
    8000436c:	8082                	ret

000000008000436e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000436e:	1101                	addi	sp,sp,-32
    80004370:	ec06                	sd	ra,24(sp)
    80004372:	e822                	sd	s0,16(sp)
    80004374:	e426                	sd	s1,8(sp)
    80004376:	e04a                	sd	s2,0(sp)
    80004378:	1000                	addi	s0,sp,32
    8000437a:	84aa                	mv	s1,a0
    8000437c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000437e:	00004597          	auipc	a1,0x4
    80004382:	31a58593          	addi	a1,a1,794 # 80008698 <syscalls+0x248>
    80004386:	0521                	addi	a0,a0,8
    80004388:	ffffc097          	auipc	ra,0xffffc
    8000438c:	7be080e7          	jalr	1982(ra) # 80000b46 <initlock>
  lk->name = name;
    80004390:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004394:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004398:	0204a423          	sw	zero,40(s1)
}
    8000439c:	60e2                	ld	ra,24(sp)
    8000439e:	6442                	ld	s0,16(sp)
    800043a0:	64a2                	ld	s1,8(sp)
    800043a2:	6902                	ld	s2,0(sp)
    800043a4:	6105                	addi	sp,sp,32
    800043a6:	8082                	ret

00000000800043a8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043a8:	1101                	addi	sp,sp,-32
    800043aa:	ec06                	sd	ra,24(sp)
    800043ac:	e822                	sd	s0,16(sp)
    800043ae:	e426                	sd	s1,8(sp)
    800043b0:	e04a                	sd	s2,0(sp)
    800043b2:	1000                	addi	s0,sp,32
    800043b4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043b6:	00850913          	addi	s2,a0,8
    800043ba:	854a                	mv	a0,s2
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	81a080e7          	jalr	-2022(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800043c4:	409c                	lw	a5,0(s1)
    800043c6:	cb89                	beqz	a5,800043d8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043c8:	85ca                	mv	a1,s2
    800043ca:	8526                	mv	a0,s1
    800043cc:	ffffe097          	auipc	ra,0xffffe
    800043d0:	c90080e7          	jalr	-880(ra) # 8000205c <sleep>
  while (lk->locked) {
    800043d4:	409c                	lw	a5,0(s1)
    800043d6:	fbed                	bnez	a5,800043c8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043d8:	4785                	li	a5,1
    800043da:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	5d8080e7          	jalr	1496(ra) # 800019b4 <myproc>
    800043e4:	591c                	lw	a5,48(a0)
    800043e6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043e8:	854a                	mv	a0,s2
    800043ea:	ffffd097          	auipc	ra,0xffffd
    800043ee:	8a0080e7          	jalr	-1888(ra) # 80000c8a <release>
}
    800043f2:	60e2                	ld	ra,24(sp)
    800043f4:	6442                	ld	s0,16(sp)
    800043f6:	64a2                	ld	s1,8(sp)
    800043f8:	6902                	ld	s2,0(sp)
    800043fa:	6105                	addi	sp,sp,32
    800043fc:	8082                	ret

00000000800043fe <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043fe:	1101                	addi	sp,sp,-32
    80004400:	ec06                	sd	ra,24(sp)
    80004402:	e822                	sd	s0,16(sp)
    80004404:	e426                	sd	s1,8(sp)
    80004406:	e04a                	sd	s2,0(sp)
    80004408:	1000                	addi	s0,sp,32
    8000440a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000440c:	00850913          	addi	s2,a0,8
    80004410:	854a                	mv	a0,s2
    80004412:	ffffc097          	auipc	ra,0xffffc
    80004416:	7c4080e7          	jalr	1988(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000441a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000441e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004422:	8526                	mv	a0,s1
    80004424:	ffffe097          	auipc	ra,0xffffe
    80004428:	c9c080e7          	jalr	-868(ra) # 800020c0 <wakeup>
  release(&lk->lk);
    8000442c:	854a                	mv	a0,s2
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	85c080e7          	jalr	-1956(ra) # 80000c8a <release>
}
    80004436:	60e2                	ld	ra,24(sp)
    80004438:	6442                	ld	s0,16(sp)
    8000443a:	64a2                	ld	s1,8(sp)
    8000443c:	6902                	ld	s2,0(sp)
    8000443e:	6105                	addi	sp,sp,32
    80004440:	8082                	ret

0000000080004442 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004442:	7179                	addi	sp,sp,-48
    80004444:	f406                	sd	ra,40(sp)
    80004446:	f022                	sd	s0,32(sp)
    80004448:	ec26                	sd	s1,24(sp)
    8000444a:	e84a                	sd	s2,16(sp)
    8000444c:	e44e                	sd	s3,8(sp)
    8000444e:	1800                	addi	s0,sp,48
    80004450:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004452:	00850913          	addi	s2,a0,8
    80004456:	854a                	mv	a0,s2
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	77e080e7          	jalr	1918(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004460:	409c                	lw	a5,0(s1)
    80004462:	ef99                	bnez	a5,80004480 <holdingsleep+0x3e>
    80004464:	4481                	li	s1,0
  release(&lk->lk);
    80004466:	854a                	mv	a0,s2
    80004468:	ffffd097          	auipc	ra,0xffffd
    8000446c:	822080e7          	jalr	-2014(ra) # 80000c8a <release>
  return r;
}
    80004470:	8526                	mv	a0,s1
    80004472:	70a2                	ld	ra,40(sp)
    80004474:	7402                	ld	s0,32(sp)
    80004476:	64e2                	ld	s1,24(sp)
    80004478:	6942                	ld	s2,16(sp)
    8000447a:	69a2                	ld	s3,8(sp)
    8000447c:	6145                	addi	sp,sp,48
    8000447e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004480:	0284a983          	lw	s3,40(s1)
    80004484:	ffffd097          	auipc	ra,0xffffd
    80004488:	530080e7          	jalr	1328(ra) # 800019b4 <myproc>
    8000448c:	5904                	lw	s1,48(a0)
    8000448e:	413484b3          	sub	s1,s1,s3
    80004492:	0014b493          	seqz	s1,s1
    80004496:	bfc1                	j	80004466 <holdingsleep+0x24>

0000000080004498 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004498:	1141                	addi	sp,sp,-16
    8000449a:	e406                	sd	ra,8(sp)
    8000449c:	e022                	sd	s0,0(sp)
    8000449e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044a0:	00004597          	auipc	a1,0x4
    800044a4:	20858593          	addi	a1,a1,520 # 800086a8 <syscalls+0x258>
    800044a8:	0001c517          	auipc	a0,0x1c
    800044ac:	7c050513          	addi	a0,a0,1984 # 80020c68 <ftable>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	696080e7          	jalr	1686(ra) # 80000b46 <initlock>
}
    800044b8:	60a2                	ld	ra,8(sp)
    800044ba:	6402                	ld	s0,0(sp)
    800044bc:	0141                	addi	sp,sp,16
    800044be:	8082                	ret

00000000800044c0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044c0:	1101                	addi	sp,sp,-32
    800044c2:	ec06                	sd	ra,24(sp)
    800044c4:	e822                	sd	s0,16(sp)
    800044c6:	e426                	sd	s1,8(sp)
    800044c8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044ca:	0001c517          	auipc	a0,0x1c
    800044ce:	79e50513          	addi	a0,a0,1950 # 80020c68 <ftable>
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	704080e7          	jalr	1796(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044da:	0001c497          	auipc	s1,0x1c
    800044de:	7a648493          	addi	s1,s1,1958 # 80020c80 <ftable+0x18>
    800044e2:	0001d717          	auipc	a4,0x1d
    800044e6:	73e70713          	addi	a4,a4,1854 # 80021c20 <disk>
    if(f->ref == 0){
    800044ea:	40dc                	lw	a5,4(s1)
    800044ec:	cf99                	beqz	a5,8000450a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ee:	02848493          	addi	s1,s1,40
    800044f2:	fee49ce3          	bne	s1,a4,800044ea <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044f6:	0001c517          	auipc	a0,0x1c
    800044fa:	77250513          	addi	a0,a0,1906 # 80020c68 <ftable>
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	78c080e7          	jalr	1932(ra) # 80000c8a <release>
  return 0;
    80004506:	4481                	li	s1,0
    80004508:	a819                	j	8000451e <filealloc+0x5e>
      f->ref = 1;
    8000450a:	4785                	li	a5,1
    8000450c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000450e:	0001c517          	auipc	a0,0x1c
    80004512:	75a50513          	addi	a0,a0,1882 # 80020c68 <ftable>
    80004516:	ffffc097          	auipc	ra,0xffffc
    8000451a:	774080e7          	jalr	1908(ra) # 80000c8a <release>
}
    8000451e:	8526                	mv	a0,s1
    80004520:	60e2                	ld	ra,24(sp)
    80004522:	6442                	ld	s0,16(sp)
    80004524:	64a2                	ld	s1,8(sp)
    80004526:	6105                	addi	sp,sp,32
    80004528:	8082                	ret

000000008000452a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000452a:	1101                	addi	sp,sp,-32
    8000452c:	ec06                	sd	ra,24(sp)
    8000452e:	e822                	sd	s0,16(sp)
    80004530:	e426                	sd	s1,8(sp)
    80004532:	1000                	addi	s0,sp,32
    80004534:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004536:	0001c517          	auipc	a0,0x1c
    8000453a:	73250513          	addi	a0,a0,1842 # 80020c68 <ftable>
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	698080e7          	jalr	1688(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004546:	40dc                	lw	a5,4(s1)
    80004548:	02f05263          	blez	a5,8000456c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000454c:	2785                	addiw	a5,a5,1
    8000454e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004550:	0001c517          	auipc	a0,0x1c
    80004554:	71850513          	addi	a0,a0,1816 # 80020c68 <ftable>
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	732080e7          	jalr	1842(ra) # 80000c8a <release>
  return f;
}
    80004560:	8526                	mv	a0,s1
    80004562:	60e2                	ld	ra,24(sp)
    80004564:	6442                	ld	s0,16(sp)
    80004566:	64a2                	ld	s1,8(sp)
    80004568:	6105                	addi	sp,sp,32
    8000456a:	8082                	ret
    panic("filedup");
    8000456c:	00004517          	auipc	a0,0x4
    80004570:	14450513          	addi	a0,a0,324 # 800086b0 <syscalls+0x260>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	fca080e7          	jalr	-54(ra) # 8000053e <panic>

000000008000457c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000457c:	7139                	addi	sp,sp,-64
    8000457e:	fc06                	sd	ra,56(sp)
    80004580:	f822                	sd	s0,48(sp)
    80004582:	f426                	sd	s1,40(sp)
    80004584:	f04a                	sd	s2,32(sp)
    80004586:	ec4e                	sd	s3,24(sp)
    80004588:	e852                	sd	s4,16(sp)
    8000458a:	e456                	sd	s5,8(sp)
    8000458c:	0080                	addi	s0,sp,64
    8000458e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004590:	0001c517          	auipc	a0,0x1c
    80004594:	6d850513          	addi	a0,a0,1752 # 80020c68 <ftable>
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	63e080e7          	jalr	1598(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800045a0:	40dc                	lw	a5,4(s1)
    800045a2:	06f05163          	blez	a5,80004604 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045a6:	37fd                	addiw	a5,a5,-1
    800045a8:	0007871b          	sext.w	a4,a5
    800045ac:	c0dc                	sw	a5,4(s1)
    800045ae:	06e04363          	bgtz	a4,80004614 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045b2:	0004a903          	lw	s2,0(s1)
    800045b6:	0094ca83          	lbu	s5,9(s1)
    800045ba:	0104ba03          	ld	s4,16(s1)
    800045be:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045c2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045c6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045ca:	0001c517          	auipc	a0,0x1c
    800045ce:	69e50513          	addi	a0,a0,1694 # 80020c68 <ftable>
    800045d2:	ffffc097          	auipc	ra,0xffffc
    800045d6:	6b8080e7          	jalr	1720(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800045da:	4785                	li	a5,1
    800045dc:	04f90d63          	beq	s2,a5,80004636 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045e0:	3979                	addiw	s2,s2,-2
    800045e2:	4785                	li	a5,1
    800045e4:	0527e063          	bltu	a5,s2,80004624 <fileclose+0xa8>
    begin_op();
    800045e8:	00000097          	auipc	ra,0x0
    800045ec:	ac8080e7          	jalr	-1336(ra) # 800040b0 <begin_op>
    iput(ff.ip);
    800045f0:	854e                	mv	a0,s3
    800045f2:	fffff097          	auipc	ra,0xfffff
    800045f6:	2b6080e7          	jalr	694(ra) # 800038a8 <iput>
    end_op();
    800045fa:	00000097          	auipc	ra,0x0
    800045fe:	b36080e7          	jalr	-1226(ra) # 80004130 <end_op>
    80004602:	a00d                	j	80004624 <fileclose+0xa8>
    panic("fileclose");
    80004604:	00004517          	auipc	a0,0x4
    80004608:	0b450513          	addi	a0,a0,180 # 800086b8 <syscalls+0x268>
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	f32080e7          	jalr	-206(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004614:	0001c517          	auipc	a0,0x1c
    80004618:	65450513          	addi	a0,a0,1620 # 80020c68 <ftable>
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	66e080e7          	jalr	1646(ra) # 80000c8a <release>
  }
}
    80004624:	70e2                	ld	ra,56(sp)
    80004626:	7442                	ld	s0,48(sp)
    80004628:	74a2                	ld	s1,40(sp)
    8000462a:	7902                	ld	s2,32(sp)
    8000462c:	69e2                	ld	s3,24(sp)
    8000462e:	6a42                	ld	s4,16(sp)
    80004630:	6aa2                	ld	s5,8(sp)
    80004632:	6121                	addi	sp,sp,64
    80004634:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004636:	85d6                	mv	a1,s5
    80004638:	8552                	mv	a0,s4
    8000463a:	00000097          	auipc	ra,0x0
    8000463e:	34c080e7          	jalr	844(ra) # 80004986 <pipeclose>
    80004642:	b7cd                	j	80004624 <fileclose+0xa8>

0000000080004644 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004644:	715d                	addi	sp,sp,-80
    80004646:	e486                	sd	ra,72(sp)
    80004648:	e0a2                	sd	s0,64(sp)
    8000464a:	fc26                	sd	s1,56(sp)
    8000464c:	f84a                	sd	s2,48(sp)
    8000464e:	f44e                	sd	s3,40(sp)
    80004650:	0880                	addi	s0,sp,80
    80004652:	84aa                	mv	s1,a0
    80004654:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004656:	ffffd097          	auipc	ra,0xffffd
    8000465a:	35e080e7          	jalr	862(ra) # 800019b4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000465e:	409c                	lw	a5,0(s1)
    80004660:	37f9                	addiw	a5,a5,-2
    80004662:	4705                	li	a4,1
    80004664:	04f76763          	bltu	a4,a5,800046b2 <filestat+0x6e>
    80004668:	892a                	mv	s2,a0
    ilock(f->ip);
    8000466a:	6c88                	ld	a0,24(s1)
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	082080e7          	jalr	130(ra) # 800036ee <ilock>
    stati(f->ip, &st);
    80004674:	fb840593          	addi	a1,s0,-72
    80004678:	6c88                	ld	a0,24(s1)
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	2fe080e7          	jalr	766(ra) # 80003978 <stati>
    iunlock(f->ip);
    80004682:	6c88                	ld	a0,24(s1)
    80004684:	fffff097          	auipc	ra,0xfffff
    80004688:	12c080e7          	jalr	300(ra) # 800037b0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000468c:	46e1                	li	a3,24
    8000468e:	fb840613          	addi	a2,s0,-72
    80004692:	85ce                	mv	a1,s3
    80004694:	05093503          	ld	a0,80(s2)
    80004698:	ffffd097          	auipc	ra,0xffffd
    8000469c:	fd0080e7          	jalr	-48(ra) # 80001668 <copyout>
    800046a0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046a4:	60a6                	ld	ra,72(sp)
    800046a6:	6406                	ld	s0,64(sp)
    800046a8:	74e2                	ld	s1,56(sp)
    800046aa:	7942                	ld	s2,48(sp)
    800046ac:	79a2                	ld	s3,40(sp)
    800046ae:	6161                	addi	sp,sp,80
    800046b0:	8082                	ret
  return -1;
    800046b2:	557d                	li	a0,-1
    800046b4:	bfc5                	j	800046a4 <filestat+0x60>

00000000800046b6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046b6:	7179                	addi	sp,sp,-48
    800046b8:	f406                	sd	ra,40(sp)
    800046ba:	f022                	sd	s0,32(sp)
    800046bc:	ec26                	sd	s1,24(sp)
    800046be:	e84a                	sd	s2,16(sp)
    800046c0:	e44e                	sd	s3,8(sp)
    800046c2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046c4:	00854783          	lbu	a5,8(a0)
    800046c8:	c3d5                	beqz	a5,8000476c <fileread+0xb6>
    800046ca:	84aa                	mv	s1,a0
    800046cc:	89ae                	mv	s3,a1
    800046ce:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046d0:	411c                	lw	a5,0(a0)
    800046d2:	4705                	li	a4,1
    800046d4:	04e78963          	beq	a5,a4,80004726 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046d8:	470d                	li	a4,3
    800046da:	04e78d63          	beq	a5,a4,80004734 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046de:	4709                	li	a4,2
    800046e0:	06e79e63          	bne	a5,a4,8000475c <fileread+0xa6>
    ilock(f->ip);
    800046e4:	6d08                	ld	a0,24(a0)
    800046e6:	fffff097          	auipc	ra,0xfffff
    800046ea:	008080e7          	jalr	8(ra) # 800036ee <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046ee:	874a                	mv	a4,s2
    800046f0:	5094                	lw	a3,32(s1)
    800046f2:	864e                	mv	a2,s3
    800046f4:	4585                	li	a1,1
    800046f6:	6c88                	ld	a0,24(s1)
    800046f8:	fffff097          	auipc	ra,0xfffff
    800046fc:	2aa080e7          	jalr	682(ra) # 800039a2 <readi>
    80004700:	892a                	mv	s2,a0
    80004702:	00a05563          	blez	a0,8000470c <fileread+0x56>
      f->off += r;
    80004706:	509c                	lw	a5,32(s1)
    80004708:	9fa9                	addw	a5,a5,a0
    8000470a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000470c:	6c88                	ld	a0,24(s1)
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	0a2080e7          	jalr	162(ra) # 800037b0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004716:	854a                	mv	a0,s2
    80004718:	70a2                	ld	ra,40(sp)
    8000471a:	7402                	ld	s0,32(sp)
    8000471c:	64e2                	ld	s1,24(sp)
    8000471e:	6942                	ld	s2,16(sp)
    80004720:	69a2                	ld	s3,8(sp)
    80004722:	6145                	addi	sp,sp,48
    80004724:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004726:	6908                	ld	a0,16(a0)
    80004728:	00000097          	auipc	ra,0x0
    8000472c:	3c6080e7          	jalr	966(ra) # 80004aee <piperead>
    80004730:	892a                	mv	s2,a0
    80004732:	b7d5                	j	80004716 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004734:	02451783          	lh	a5,36(a0)
    80004738:	03079693          	slli	a3,a5,0x30
    8000473c:	92c1                	srli	a3,a3,0x30
    8000473e:	4725                	li	a4,9
    80004740:	02d76863          	bltu	a4,a3,80004770 <fileread+0xba>
    80004744:	0792                	slli	a5,a5,0x4
    80004746:	0001c717          	auipc	a4,0x1c
    8000474a:	48270713          	addi	a4,a4,1154 # 80020bc8 <devsw>
    8000474e:	97ba                	add	a5,a5,a4
    80004750:	639c                	ld	a5,0(a5)
    80004752:	c38d                	beqz	a5,80004774 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004754:	4505                	li	a0,1
    80004756:	9782                	jalr	a5
    80004758:	892a                	mv	s2,a0
    8000475a:	bf75                	j	80004716 <fileread+0x60>
    panic("fileread");
    8000475c:	00004517          	auipc	a0,0x4
    80004760:	f6c50513          	addi	a0,a0,-148 # 800086c8 <syscalls+0x278>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	dda080e7          	jalr	-550(ra) # 8000053e <panic>
    return -1;
    8000476c:	597d                	li	s2,-1
    8000476e:	b765                	j	80004716 <fileread+0x60>
      return -1;
    80004770:	597d                	li	s2,-1
    80004772:	b755                	j	80004716 <fileread+0x60>
    80004774:	597d                	li	s2,-1
    80004776:	b745                	j	80004716 <fileread+0x60>

0000000080004778 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004778:	715d                	addi	sp,sp,-80
    8000477a:	e486                	sd	ra,72(sp)
    8000477c:	e0a2                	sd	s0,64(sp)
    8000477e:	fc26                	sd	s1,56(sp)
    80004780:	f84a                	sd	s2,48(sp)
    80004782:	f44e                	sd	s3,40(sp)
    80004784:	f052                	sd	s4,32(sp)
    80004786:	ec56                	sd	s5,24(sp)
    80004788:	e85a                	sd	s6,16(sp)
    8000478a:	e45e                	sd	s7,8(sp)
    8000478c:	e062                	sd	s8,0(sp)
    8000478e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004790:	00954783          	lbu	a5,9(a0)
    80004794:	10078663          	beqz	a5,800048a0 <filewrite+0x128>
    80004798:	892a                	mv	s2,a0
    8000479a:	8aae                	mv	s5,a1
    8000479c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000479e:	411c                	lw	a5,0(a0)
    800047a0:	4705                	li	a4,1
    800047a2:	02e78263          	beq	a5,a4,800047c6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047a6:	470d                	li	a4,3
    800047a8:	02e78663          	beq	a5,a4,800047d4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047ac:	4709                	li	a4,2
    800047ae:	0ee79163          	bne	a5,a4,80004890 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047b2:	0ac05d63          	blez	a2,8000486c <filewrite+0xf4>
    int i = 0;
    800047b6:	4981                	li	s3,0
    800047b8:	6b05                	lui	s6,0x1
    800047ba:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800047be:	6b85                	lui	s7,0x1
    800047c0:	c00b8b9b          	addiw	s7,s7,-1024
    800047c4:	a861                	j	8000485c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047c6:	6908                	ld	a0,16(a0)
    800047c8:	00000097          	auipc	ra,0x0
    800047cc:	22e080e7          	jalr	558(ra) # 800049f6 <pipewrite>
    800047d0:	8a2a                	mv	s4,a0
    800047d2:	a045                	j	80004872 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047d4:	02451783          	lh	a5,36(a0)
    800047d8:	03079693          	slli	a3,a5,0x30
    800047dc:	92c1                	srli	a3,a3,0x30
    800047de:	4725                	li	a4,9
    800047e0:	0cd76263          	bltu	a4,a3,800048a4 <filewrite+0x12c>
    800047e4:	0792                	slli	a5,a5,0x4
    800047e6:	0001c717          	auipc	a4,0x1c
    800047ea:	3e270713          	addi	a4,a4,994 # 80020bc8 <devsw>
    800047ee:	97ba                	add	a5,a5,a4
    800047f0:	679c                	ld	a5,8(a5)
    800047f2:	cbdd                	beqz	a5,800048a8 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047f4:	4505                	li	a0,1
    800047f6:	9782                	jalr	a5
    800047f8:	8a2a                	mv	s4,a0
    800047fa:	a8a5                	j	80004872 <filewrite+0xfa>
    800047fc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004800:	00000097          	auipc	ra,0x0
    80004804:	8b0080e7          	jalr	-1872(ra) # 800040b0 <begin_op>
      ilock(f->ip);
    80004808:	01893503          	ld	a0,24(s2)
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	ee2080e7          	jalr	-286(ra) # 800036ee <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004814:	8762                	mv	a4,s8
    80004816:	02092683          	lw	a3,32(s2)
    8000481a:	01598633          	add	a2,s3,s5
    8000481e:	4585                	li	a1,1
    80004820:	01893503          	ld	a0,24(s2)
    80004824:	fffff097          	auipc	ra,0xfffff
    80004828:	276080e7          	jalr	630(ra) # 80003a9a <writei>
    8000482c:	84aa                	mv	s1,a0
    8000482e:	00a05763          	blez	a0,8000483c <filewrite+0xc4>
        f->off += r;
    80004832:	02092783          	lw	a5,32(s2)
    80004836:	9fa9                	addw	a5,a5,a0
    80004838:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000483c:	01893503          	ld	a0,24(s2)
    80004840:	fffff097          	auipc	ra,0xfffff
    80004844:	f70080e7          	jalr	-144(ra) # 800037b0 <iunlock>
      end_op();
    80004848:	00000097          	auipc	ra,0x0
    8000484c:	8e8080e7          	jalr	-1816(ra) # 80004130 <end_op>

      if(r != n1){
    80004850:	009c1f63          	bne	s8,s1,8000486e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004854:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004858:	0149db63          	bge	s3,s4,8000486e <filewrite+0xf6>
      int n1 = n - i;
    8000485c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004860:	84be                	mv	s1,a5
    80004862:	2781                	sext.w	a5,a5
    80004864:	f8fb5ce3          	bge	s6,a5,800047fc <filewrite+0x84>
    80004868:	84de                	mv	s1,s7
    8000486a:	bf49                	j	800047fc <filewrite+0x84>
    int i = 0;
    8000486c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000486e:	013a1f63          	bne	s4,s3,8000488c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004872:	8552                	mv	a0,s4
    80004874:	60a6                	ld	ra,72(sp)
    80004876:	6406                	ld	s0,64(sp)
    80004878:	74e2                	ld	s1,56(sp)
    8000487a:	7942                	ld	s2,48(sp)
    8000487c:	79a2                	ld	s3,40(sp)
    8000487e:	7a02                	ld	s4,32(sp)
    80004880:	6ae2                	ld	s5,24(sp)
    80004882:	6b42                	ld	s6,16(sp)
    80004884:	6ba2                	ld	s7,8(sp)
    80004886:	6c02                	ld	s8,0(sp)
    80004888:	6161                	addi	sp,sp,80
    8000488a:	8082                	ret
    ret = (i == n ? n : -1);
    8000488c:	5a7d                	li	s4,-1
    8000488e:	b7d5                	j	80004872 <filewrite+0xfa>
    panic("filewrite");
    80004890:	00004517          	auipc	a0,0x4
    80004894:	e4850513          	addi	a0,a0,-440 # 800086d8 <syscalls+0x288>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	ca6080e7          	jalr	-858(ra) # 8000053e <panic>
    return -1;
    800048a0:	5a7d                	li	s4,-1
    800048a2:	bfc1                	j	80004872 <filewrite+0xfa>
      return -1;
    800048a4:	5a7d                	li	s4,-1
    800048a6:	b7f1                	j	80004872 <filewrite+0xfa>
    800048a8:	5a7d                	li	s4,-1
    800048aa:	b7e1                	j	80004872 <filewrite+0xfa>

00000000800048ac <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048ac:	7179                	addi	sp,sp,-48
    800048ae:	f406                	sd	ra,40(sp)
    800048b0:	f022                	sd	s0,32(sp)
    800048b2:	ec26                	sd	s1,24(sp)
    800048b4:	e84a                	sd	s2,16(sp)
    800048b6:	e44e                	sd	s3,8(sp)
    800048b8:	e052                	sd	s4,0(sp)
    800048ba:	1800                	addi	s0,sp,48
    800048bc:	84aa                	mv	s1,a0
    800048be:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048c0:	0005b023          	sd	zero,0(a1)
    800048c4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048c8:	00000097          	auipc	ra,0x0
    800048cc:	bf8080e7          	jalr	-1032(ra) # 800044c0 <filealloc>
    800048d0:	e088                	sd	a0,0(s1)
    800048d2:	c551                	beqz	a0,8000495e <pipealloc+0xb2>
    800048d4:	00000097          	auipc	ra,0x0
    800048d8:	bec080e7          	jalr	-1044(ra) # 800044c0 <filealloc>
    800048dc:	00aa3023          	sd	a0,0(s4)
    800048e0:	c92d                	beqz	a0,80004952 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	204080e7          	jalr	516(ra) # 80000ae6 <kalloc>
    800048ea:	892a                	mv	s2,a0
    800048ec:	c125                	beqz	a0,8000494c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048ee:	4985                	li	s3,1
    800048f0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048f4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048f8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048fc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004900:	00004597          	auipc	a1,0x4
    80004904:	de858593          	addi	a1,a1,-536 # 800086e8 <syscalls+0x298>
    80004908:	ffffc097          	auipc	ra,0xffffc
    8000490c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004910:	609c                	ld	a5,0(s1)
    80004912:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004916:	609c                	ld	a5,0(s1)
    80004918:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000491c:	609c                	ld	a5,0(s1)
    8000491e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004922:	609c                	ld	a5,0(s1)
    80004924:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004928:	000a3783          	ld	a5,0(s4)
    8000492c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004930:	000a3783          	ld	a5,0(s4)
    80004934:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004938:	000a3783          	ld	a5,0(s4)
    8000493c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004940:	000a3783          	ld	a5,0(s4)
    80004944:	0127b823          	sd	s2,16(a5)
  return 0;
    80004948:	4501                	li	a0,0
    8000494a:	a025                	j	80004972 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000494c:	6088                	ld	a0,0(s1)
    8000494e:	e501                	bnez	a0,80004956 <pipealloc+0xaa>
    80004950:	a039                	j	8000495e <pipealloc+0xb2>
    80004952:	6088                	ld	a0,0(s1)
    80004954:	c51d                	beqz	a0,80004982 <pipealloc+0xd6>
    fileclose(*f0);
    80004956:	00000097          	auipc	ra,0x0
    8000495a:	c26080e7          	jalr	-986(ra) # 8000457c <fileclose>
  if(*f1)
    8000495e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004962:	557d                	li	a0,-1
  if(*f1)
    80004964:	c799                	beqz	a5,80004972 <pipealloc+0xc6>
    fileclose(*f1);
    80004966:	853e                	mv	a0,a5
    80004968:	00000097          	auipc	ra,0x0
    8000496c:	c14080e7          	jalr	-1004(ra) # 8000457c <fileclose>
  return -1;
    80004970:	557d                	li	a0,-1
}
    80004972:	70a2                	ld	ra,40(sp)
    80004974:	7402                	ld	s0,32(sp)
    80004976:	64e2                	ld	s1,24(sp)
    80004978:	6942                	ld	s2,16(sp)
    8000497a:	69a2                	ld	s3,8(sp)
    8000497c:	6a02                	ld	s4,0(sp)
    8000497e:	6145                	addi	sp,sp,48
    80004980:	8082                	ret
  return -1;
    80004982:	557d                	li	a0,-1
    80004984:	b7fd                	j	80004972 <pipealloc+0xc6>

0000000080004986 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004986:	1101                	addi	sp,sp,-32
    80004988:	ec06                	sd	ra,24(sp)
    8000498a:	e822                	sd	s0,16(sp)
    8000498c:	e426                	sd	s1,8(sp)
    8000498e:	e04a                	sd	s2,0(sp)
    80004990:	1000                	addi	s0,sp,32
    80004992:	84aa                	mv	s1,a0
    80004994:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	240080e7          	jalr	576(ra) # 80000bd6 <acquire>
  if(writable){
    8000499e:	02090d63          	beqz	s2,800049d8 <pipeclose+0x52>
    pi->writeopen = 0;
    800049a2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049a6:	21848513          	addi	a0,s1,536
    800049aa:	ffffd097          	auipc	ra,0xffffd
    800049ae:	716080e7          	jalr	1814(ra) # 800020c0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049b2:	2204b783          	ld	a5,544(s1)
    800049b6:	eb95                	bnez	a5,800049ea <pipeclose+0x64>
    release(&pi->lock);
    800049b8:	8526                	mv	a0,s1
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	2d0080e7          	jalr	720(ra) # 80000c8a <release>
    kfree((char*)pi);
    800049c2:	8526                	mv	a0,s1
    800049c4:	ffffc097          	auipc	ra,0xffffc
    800049c8:	026080e7          	jalr	38(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    800049cc:	60e2                	ld	ra,24(sp)
    800049ce:	6442                	ld	s0,16(sp)
    800049d0:	64a2                	ld	s1,8(sp)
    800049d2:	6902                	ld	s2,0(sp)
    800049d4:	6105                	addi	sp,sp,32
    800049d6:	8082                	ret
    pi->readopen = 0;
    800049d8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049dc:	21c48513          	addi	a0,s1,540
    800049e0:	ffffd097          	auipc	ra,0xffffd
    800049e4:	6e0080e7          	jalr	1760(ra) # 800020c0 <wakeup>
    800049e8:	b7e9                	j	800049b2 <pipeclose+0x2c>
    release(&pi->lock);
    800049ea:	8526                	mv	a0,s1
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	29e080e7          	jalr	670(ra) # 80000c8a <release>
}
    800049f4:	bfe1                	j	800049cc <pipeclose+0x46>

00000000800049f6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049f6:	711d                	addi	sp,sp,-96
    800049f8:	ec86                	sd	ra,88(sp)
    800049fa:	e8a2                	sd	s0,80(sp)
    800049fc:	e4a6                	sd	s1,72(sp)
    800049fe:	e0ca                	sd	s2,64(sp)
    80004a00:	fc4e                	sd	s3,56(sp)
    80004a02:	f852                	sd	s4,48(sp)
    80004a04:	f456                	sd	s5,40(sp)
    80004a06:	f05a                	sd	s6,32(sp)
    80004a08:	ec5e                	sd	s7,24(sp)
    80004a0a:	e862                	sd	s8,16(sp)
    80004a0c:	1080                	addi	s0,sp,96
    80004a0e:	84aa                	mv	s1,a0
    80004a10:	8aae                	mv	s5,a1
    80004a12:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a14:	ffffd097          	auipc	ra,0xffffd
    80004a18:	fa0080e7          	jalr	-96(ra) # 800019b4 <myproc>
    80004a1c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	1b6080e7          	jalr	438(ra) # 80000bd6 <acquire>
  while(i < n){
    80004a28:	0b405663          	blez	s4,80004ad4 <pipewrite+0xde>
  int i = 0;
    80004a2c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a2e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a30:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a34:	21c48b93          	addi	s7,s1,540
    80004a38:	a089                	j	80004a7a <pipewrite+0x84>
      release(&pi->lock);
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
      return -1;
    80004a44:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a46:	854a                	mv	a0,s2
    80004a48:	60e6                	ld	ra,88(sp)
    80004a4a:	6446                	ld	s0,80(sp)
    80004a4c:	64a6                	ld	s1,72(sp)
    80004a4e:	6906                	ld	s2,64(sp)
    80004a50:	79e2                	ld	s3,56(sp)
    80004a52:	7a42                	ld	s4,48(sp)
    80004a54:	7aa2                	ld	s5,40(sp)
    80004a56:	7b02                	ld	s6,32(sp)
    80004a58:	6be2                	ld	s7,24(sp)
    80004a5a:	6c42                	ld	s8,16(sp)
    80004a5c:	6125                	addi	sp,sp,96
    80004a5e:	8082                	ret
      wakeup(&pi->nread);
    80004a60:	8562                	mv	a0,s8
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	65e080e7          	jalr	1630(ra) # 800020c0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a6a:	85a6                	mv	a1,s1
    80004a6c:	855e                	mv	a0,s7
    80004a6e:	ffffd097          	auipc	ra,0xffffd
    80004a72:	5ee080e7          	jalr	1518(ra) # 8000205c <sleep>
  while(i < n){
    80004a76:	07495063          	bge	s2,s4,80004ad6 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a7a:	2204a783          	lw	a5,544(s1)
    80004a7e:	dfd5                	beqz	a5,80004a3a <pipewrite+0x44>
    80004a80:	854e                	mv	a0,s3
    80004a82:	ffffe097          	auipc	ra,0xffffe
    80004a86:	882080e7          	jalr	-1918(ra) # 80002304 <killed>
    80004a8a:	f945                	bnez	a0,80004a3a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a8c:	2184a783          	lw	a5,536(s1)
    80004a90:	21c4a703          	lw	a4,540(s1)
    80004a94:	2007879b          	addiw	a5,a5,512
    80004a98:	fcf704e3          	beq	a4,a5,80004a60 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a9c:	4685                	li	a3,1
    80004a9e:	01590633          	add	a2,s2,s5
    80004aa2:	faf40593          	addi	a1,s0,-81
    80004aa6:	0509b503          	ld	a0,80(s3)
    80004aaa:	ffffd097          	auipc	ra,0xffffd
    80004aae:	c4a080e7          	jalr	-950(ra) # 800016f4 <copyin>
    80004ab2:	03650263          	beq	a0,s6,80004ad6 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ab6:	21c4a783          	lw	a5,540(s1)
    80004aba:	0017871b          	addiw	a4,a5,1
    80004abe:	20e4ae23          	sw	a4,540(s1)
    80004ac2:	1ff7f793          	andi	a5,a5,511
    80004ac6:	97a6                	add	a5,a5,s1
    80004ac8:	faf44703          	lbu	a4,-81(s0)
    80004acc:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ad0:	2905                	addiw	s2,s2,1
    80004ad2:	b755                	j	80004a76 <pipewrite+0x80>
  int i = 0;
    80004ad4:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ad6:	21848513          	addi	a0,s1,536
    80004ada:	ffffd097          	auipc	ra,0xffffd
    80004ade:	5e6080e7          	jalr	1510(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004ae2:	8526                	mv	a0,s1
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	1a6080e7          	jalr	422(ra) # 80000c8a <release>
  return i;
    80004aec:	bfa9                	j	80004a46 <pipewrite+0x50>

0000000080004aee <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004aee:	715d                	addi	sp,sp,-80
    80004af0:	e486                	sd	ra,72(sp)
    80004af2:	e0a2                	sd	s0,64(sp)
    80004af4:	fc26                	sd	s1,56(sp)
    80004af6:	f84a                	sd	s2,48(sp)
    80004af8:	f44e                	sd	s3,40(sp)
    80004afa:	f052                	sd	s4,32(sp)
    80004afc:	ec56                	sd	s5,24(sp)
    80004afe:	e85a                	sd	s6,16(sp)
    80004b00:	0880                	addi	s0,sp,80
    80004b02:	84aa                	mv	s1,a0
    80004b04:	892e                	mv	s2,a1
    80004b06:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b08:	ffffd097          	auipc	ra,0xffffd
    80004b0c:	eac080e7          	jalr	-340(ra) # 800019b4 <myproc>
    80004b10:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b12:	8526                	mv	a0,s1
    80004b14:	ffffc097          	auipc	ra,0xffffc
    80004b18:	0c2080e7          	jalr	194(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b1c:	2184a703          	lw	a4,536(s1)
    80004b20:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b24:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b28:	02f71763          	bne	a4,a5,80004b56 <piperead+0x68>
    80004b2c:	2244a783          	lw	a5,548(s1)
    80004b30:	c39d                	beqz	a5,80004b56 <piperead+0x68>
    if(killed(pr)){
    80004b32:	8552                	mv	a0,s4
    80004b34:	ffffd097          	auipc	ra,0xffffd
    80004b38:	7d0080e7          	jalr	2000(ra) # 80002304 <killed>
    80004b3c:	e941                	bnez	a0,80004bcc <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b3e:	85a6                	mv	a1,s1
    80004b40:	854e                	mv	a0,s3
    80004b42:	ffffd097          	auipc	ra,0xffffd
    80004b46:	51a080e7          	jalr	1306(ra) # 8000205c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b4a:	2184a703          	lw	a4,536(s1)
    80004b4e:	21c4a783          	lw	a5,540(s1)
    80004b52:	fcf70de3          	beq	a4,a5,80004b2c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b56:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b58:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b5a:	05505363          	blez	s5,80004ba0 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004b5e:	2184a783          	lw	a5,536(s1)
    80004b62:	21c4a703          	lw	a4,540(s1)
    80004b66:	02f70d63          	beq	a4,a5,80004ba0 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b6a:	0017871b          	addiw	a4,a5,1
    80004b6e:	20e4ac23          	sw	a4,536(s1)
    80004b72:	1ff7f793          	andi	a5,a5,511
    80004b76:	97a6                	add	a5,a5,s1
    80004b78:	0187c783          	lbu	a5,24(a5)
    80004b7c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b80:	4685                	li	a3,1
    80004b82:	fbf40613          	addi	a2,s0,-65
    80004b86:	85ca                	mv	a1,s2
    80004b88:	050a3503          	ld	a0,80(s4)
    80004b8c:	ffffd097          	auipc	ra,0xffffd
    80004b90:	adc080e7          	jalr	-1316(ra) # 80001668 <copyout>
    80004b94:	01650663          	beq	a0,s6,80004ba0 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b98:	2985                	addiw	s3,s3,1
    80004b9a:	0905                	addi	s2,s2,1
    80004b9c:	fd3a91e3          	bne	s5,s3,80004b5e <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ba0:	21c48513          	addi	a0,s1,540
    80004ba4:	ffffd097          	auipc	ra,0xffffd
    80004ba8:	51c080e7          	jalr	1308(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	0dc080e7          	jalr	220(ra) # 80000c8a <release>
  return i;
}
    80004bb6:	854e                	mv	a0,s3
    80004bb8:	60a6                	ld	ra,72(sp)
    80004bba:	6406                	ld	s0,64(sp)
    80004bbc:	74e2                	ld	s1,56(sp)
    80004bbe:	7942                	ld	s2,48(sp)
    80004bc0:	79a2                	ld	s3,40(sp)
    80004bc2:	7a02                	ld	s4,32(sp)
    80004bc4:	6ae2                	ld	s5,24(sp)
    80004bc6:	6b42                	ld	s6,16(sp)
    80004bc8:	6161                	addi	sp,sp,80
    80004bca:	8082                	ret
      release(&pi->lock);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	0bc080e7          	jalr	188(ra) # 80000c8a <release>
      return -1;
    80004bd6:	59fd                	li	s3,-1
    80004bd8:	bff9                	j	80004bb6 <piperead+0xc8>

0000000080004bda <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004bda:	1141                	addi	sp,sp,-16
    80004bdc:	e422                	sd	s0,8(sp)
    80004bde:	0800                	addi	s0,sp,16
    80004be0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004be2:	8905                	andi	a0,a0,1
    80004be4:	c111                	beqz	a0,80004be8 <flags2perm+0xe>
      perm = PTE_X;
    80004be6:	4521                	li	a0,8
    if(flags & 0x2)
    80004be8:	8b89                	andi	a5,a5,2
    80004bea:	c399                	beqz	a5,80004bf0 <flags2perm+0x16>
      perm |= PTE_W;
    80004bec:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bf0:	6422                	ld	s0,8(sp)
    80004bf2:	0141                	addi	sp,sp,16
    80004bf4:	8082                	ret

0000000080004bf6 <exec>:

int
exec(char *path, char **argv)
{
    80004bf6:	de010113          	addi	sp,sp,-544
    80004bfa:	20113c23          	sd	ra,536(sp)
    80004bfe:	20813823          	sd	s0,528(sp)
    80004c02:	20913423          	sd	s1,520(sp)
    80004c06:	21213023          	sd	s2,512(sp)
    80004c0a:	ffce                	sd	s3,504(sp)
    80004c0c:	fbd2                	sd	s4,496(sp)
    80004c0e:	f7d6                	sd	s5,488(sp)
    80004c10:	f3da                	sd	s6,480(sp)
    80004c12:	efde                	sd	s7,472(sp)
    80004c14:	ebe2                	sd	s8,464(sp)
    80004c16:	e7e6                	sd	s9,456(sp)
    80004c18:	e3ea                	sd	s10,448(sp)
    80004c1a:	ff6e                	sd	s11,440(sp)
    80004c1c:	1400                	addi	s0,sp,544
    80004c1e:	892a                	mv	s2,a0
    80004c20:	dea43423          	sd	a0,-536(s0)
    80004c24:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c28:	ffffd097          	auipc	ra,0xffffd
    80004c2c:	d8c080e7          	jalr	-628(ra) # 800019b4 <myproc>
    80004c30:	84aa                	mv	s1,a0

  begin_op();
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	47e080e7          	jalr	1150(ra) # 800040b0 <begin_op>

  if((ip = namei(path)) == 0){
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	fffff097          	auipc	ra,0xfffff
    80004c40:	258080e7          	jalr	600(ra) # 80003e94 <namei>
    80004c44:	c93d                	beqz	a0,80004cba <exec+0xc4>
    80004c46:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	aa6080e7          	jalr	-1370(ra) # 800036ee <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c50:	04000713          	li	a4,64
    80004c54:	4681                	li	a3,0
    80004c56:	e5040613          	addi	a2,s0,-432
    80004c5a:	4581                	li	a1,0
    80004c5c:	8556                	mv	a0,s5
    80004c5e:	fffff097          	auipc	ra,0xfffff
    80004c62:	d44080e7          	jalr	-700(ra) # 800039a2 <readi>
    80004c66:	04000793          	li	a5,64
    80004c6a:	00f51a63          	bne	a0,a5,80004c7e <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c6e:	e5042703          	lw	a4,-432(s0)
    80004c72:	464c47b7          	lui	a5,0x464c4
    80004c76:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c7a:	04f70663          	beq	a4,a5,80004cc6 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c7e:	8556                	mv	a0,s5
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	cd0080e7          	jalr	-816(ra) # 80003950 <iunlockput>
    end_op();
    80004c88:	fffff097          	auipc	ra,0xfffff
    80004c8c:	4a8080e7          	jalr	1192(ra) # 80004130 <end_op>
  }
  return -1;
    80004c90:	557d                	li	a0,-1
}
    80004c92:	21813083          	ld	ra,536(sp)
    80004c96:	21013403          	ld	s0,528(sp)
    80004c9a:	20813483          	ld	s1,520(sp)
    80004c9e:	20013903          	ld	s2,512(sp)
    80004ca2:	79fe                	ld	s3,504(sp)
    80004ca4:	7a5e                	ld	s4,496(sp)
    80004ca6:	7abe                	ld	s5,488(sp)
    80004ca8:	7b1e                	ld	s6,480(sp)
    80004caa:	6bfe                	ld	s7,472(sp)
    80004cac:	6c5e                	ld	s8,464(sp)
    80004cae:	6cbe                	ld	s9,456(sp)
    80004cb0:	6d1e                	ld	s10,448(sp)
    80004cb2:	7dfa                	ld	s11,440(sp)
    80004cb4:	22010113          	addi	sp,sp,544
    80004cb8:	8082                	ret
    end_op();
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	476080e7          	jalr	1142(ra) # 80004130 <end_op>
    return -1;
    80004cc2:	557d                	li	a0,-1
    80004cc4:	b7f9                	j	80004c92 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	ffffd097          	auipc	ra,0xffffd
    80004ccc:	db0080e7          	jalr	-592(ra) # 80001a78 <proc_pagetable>
    80004cd0:	8b2a                	mv	s6,a0
    80004cd2:	d555                	beqz	a0,80004c7e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cd4:	e7042783          	lw	a5,-400(s0)
    80004cd8:	e8845703          	lhu	a4,-376(s0)
    80004cdc:	c735                	beqz	a4,80004d48 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cde:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ce0:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004ce4:	6a05                	lui	s4,0x1
    80004ce6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cea:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cee:	6d85                	lui	s11,0x1
    80004cf0:	7d7d                	lui	s10,0xfffff
    80004cf2:	a481                	j	80004f32 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cf4:	00004517          	auipc	a0,0x4
    80004cf8:	9fc50513          	addi	a0,a0,-1540 # 800086f0 <syscalls+0x2a0>
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	842080e7          	jalr	-1982(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d04:	874a                	mv	a4,s2
    80004d06:	009c86bb          	addw	a3,s9,s1
    80004d0a:	4581                	li	a1,0
    80004d0c:	8556                	mv	a0,s5
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	c94080e7          	jalr	-876(ra) # 800039a2 <readi>
    80004d16:	2501                	sext.w	a0,a0
    80004d18:	1aa91a63          	bne	s2,a0,80004ecc <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004d1c:	009d84bb          	addw	s1,s11,s1
    80004d20:	013d09bb          	addw	s3,s10,s3
    80004d24:	1f74f763          	bgeu	s1,s7,80004f12 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004d28:	02049593          	slli	a1,s1,0x20
    80004d2c:	9181                	srli	a1,a1,0x20
    80004d2e:	95e2                	add	a1,a1,s8
    80004d30:	855a                	mv	a0,s6
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	32a080e7          	jalr	810(ra) # 8000105c <walkaddr>
    80004d3a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d3c:	dd45                	beqz	a0,80004cf4 <exec+0xfe>
      n = PGSIZE;
    80004d3e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d40:	fd49f2e3          	bgeu	s3,s4,80004d04 <exec+0x10e>
      n = sz - i;
    80004d44:	894e                	mv	s2,s3
    80004d46:	bf7d                	j	80004d04 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d48:	4901                	li	s2,0
  iunlockput(ip);
    80004d4a:	8556                	mv	a0,s5
    80004d4c:	fffff097          	auipc	ra,0xfffff
    80004d50:	c04080e7          	jalr	-1020(ra) # 80003950 <iunlockput>
  end_op();
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	3dc080e7          	jalr	988(ra) # 80004130 <end_op>
  p = myproc();
    80004d5c:	ffffd097          	auipc	ra,0xffffd
    80004d60:	c58080e7          	jalr	-936(ra) # 800019b4 <myproc>
    80004d64:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d66:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d6a:	6785                	lui	a5,0x1
    80004d6c:	17fd                	addi	a5,a5,-1
    80004d6e:	993e                	add	s2,s2,a5
    80004d70:	77fd                	lui	a5,0xfffff
    80004d72:	00f977b3          	and	a5,s2,a5
    80004d76:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d7a:	4691                	li	a3,4
    80004d7c:	6609                	lui	a2,0x2
    80004d7e:	963e                	add	a2,a2,a5
    80004d80:	85be                	mv	a1,a5
    80004d82:	855a                	mv	a0,s6
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	68c080e7          	jalr	1676(ra) # 80001410 <uvmalloc>
    80004d8c:	8c2a                	mv	s8,a0
  ip = 0;
    80004d8e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d90:	12050e63          	beqz	a0,80004ecc <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d94:	75f9                	lui	a1,0xffffe
    80004d96:	95aa                	add	a1,a1,a0
    80004d98:	855a                	mv	a0,s6
    80004d9a:	ffffd097          	auipc	ra,0xffffd
    80004d9e:	89c080e7          	jalr	-1892(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004da2:	7afd                	lui	s5,0xfffff
    80004da4:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004da6:	df043783          	ld	a5,-528(s0)
    80004daa:	6388                	ld	a0,0(a5)
    80004dac:	c925                	beqz	a0,80004e1c <exec+0x226>
    80004dae:	e9040993          	addi	s3,s0,-368
    80004db2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004db6:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004db8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dba:	ffffc097          	auipc	ra,0xffffc
    80004dbe:	094080e7          	jalr	148(ra) # 80000e4e <strlen>
    80004dc2:	0015079b          	addiw	a5,a0,1
    80004dc6:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dca:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004dce:	13596663          	bltu	s2,s5,80004efa <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dd2:	df043d83          	ld	s11,-528(s0)
    80004dd6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004dda:	8552                	mv	a0,s4
    80004ddc:	ffffc097          	auipc	ra,0xffffc
    80004de0:	072080e7          	jalr	114(ra) # 80000e4e <strlen>
    80004de4:	0015069b          	addiw	a3,a0,1
    80004de8:	8652                	mv	a2,s4
    80004dea:	85ca                	mv	a1,s2
    80004dec:	855a                	mv	a0,s6
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	87a080e7          	jalr	-1926(ra) # 80001668 <copyout>
    80004df6:	10054663          	bltz	a0,80004f02 <exec+0x30c>
    ustack[argc] = sp;
    80004dfa:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dfe:	0485                	addi	s1,s1,1
    80004e00:	008d8793          	addi	a5,s11,8
    80004e04:	def43823          	sd	a5,-528(s0)
    80004e08:	008db503          	ld	a0,8(s11)
    80004e0c:	c911                	beqz	a0,80004e20 <exec+0x22a>
    if(argc >= MAXARG)
    80004e0e:	09a1                	addi	s3,s3,8
    80004e10:	fb3c95e3          	bne	s9,s3,80004dba <exec+0x1c4>
  sz = sz1;
    80004e14:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e18:	4a81                	li	s5,0
    80004e1a:	a84d                	j	80004ecc <exec+0x2d6>
  sp = sz;
    80004e1c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e1e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e20:	00349793          	slli	a5,s1,0x3
    80004e24:	f9040713          	addi	a4,s0,-112
    80004e28:	97ba                	add	a5,a5,a4
    80004e2a:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdd0b0>
  sp -= (argc+1) * sizeof(uint64);
    80004e2e:	00148693          	addi	a3,s1,1
    80004e32:	068e                	slli	a3,a3,0x3
    80004e34:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e38:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e3c:	01597663          	bgeu	s2,s5,80004e48 <exec+0x252>
  sz = sz1;
    80004e40:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e44:	4a81                	li	s5,0
    80004e46:	a059                	j	80004ecc <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e48:	e9040613          	addi	a2,s0,-368
    80004e4c:	85ca                	mv	a1,s2
    80004e4e:	855a                	mv	a0,s6
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	818080e7          	jalr	-2024(ra) # 80001668 <copyout>
    80004e58:	0a054963          	bltz	a0,80004f0a <exec+0x314>
  p->trapframe->a1 = sp;
    80004e5c:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004e60:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e64:	de843783          	ld	a5,-536(s0)
    80004e68:	0007c703          	lbu	a4,0(a5)
    80004e6c:	cf11                	beqz	a4,80004e88 <exec+0x292>
    80004e6e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e70:	02f00693          	li	a3,47
    80004e74:	a039                	j	80004e82 <exec+0x28c>
      last = s+1;
    80004e76:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e7a:	0785                	addi	a5,a5,1
    80004e7c:	fff7c703          	lbu	a4,-1(a5)
    80004e80:	c701                	beqz	a4,80004e88 <exec+0x292>
    if(*s == '/')
    80004e82:	fed71ce3          	bne	a4,a3,80004e7a <exec+0x284>
    80004e86:	bfc5                	j	80004e76 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e88:	4641                	li	a2,16
    80004e8a:	de843583          	ld	a1,-536(s0)
    80004e8e:	158b8513          	addi	a0,s7,344
    80004e92:	ffffc097          	auipc	ra,0xffffc
    80004e96:	f8a080e7          	jalr	-118(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e9a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e9e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004ea2:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ea6:	058bb783          	ld	a5,88(s7)
    80004eaa:	e6843703          	ld	a4,-408(s0)
    80004eae:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eb0:	058bb783          	ld	a5,88(s7)
    80004eb4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eb8:	85ea                	mv	a1,s10
    80004eba:	ffffd097          	auipc	ra,0xffffd
    80004ebe:	c5a080e7          	jalr	-934(ra) # 80001b14 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ec2:	0004851b          	sext.w	a0,s1
    80004ec6:	b3f1                	j	80004c92 <exec+0x9c>
    80004ec8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ecc:	df843583          	ld	a1,-520(s0)
    80004ed0:	855a                	mv	a0,s6
    80004ed2:	ffffd097          	auipc	ra,0xffffd
    80004ed6:	c42080e7          	jalr	-958(ra) # 80001b14 <proc_freepagetable>
  if(ip){
    80004eda:	da0a92e3          	bnez	s5,80004c7e <exec+0x88>
  return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	bb4d                	j	80004c92 <exec+0x9c>
    80004ee2:	df243c23          	sd	s2,-520(s0)
    80004ee6:	b7dd                	j	80004ecc <exec+0x2d6>
    80004ee8:	df243c23          	sd	s2,-520(s0)
    80004eec:	b7c5                	j	80004ecc <exec+0x2d6>
    80004eee:	df243c23          	sd	s2,-520(s0)
    80004ef2:	bfe9                	j	80004ecc <exec+0x2d6>
    80004ef4:	df243c23          	sd	s2,-520(s0)
    80004ef8:	bfd1                	j	80004ecc <exec+0x2d6>
  sz = sz1;
    80004efa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004efe:	4a81                	li	s5,0
    80004f00:	b7f1                	j	80004ecc <exec+0x2d6>
  sz = sz1;
    80004f02:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f06:	4a81                	li	s5,0
    80004f08:	b7d1                	j	80004ecc <exec+0x2d6>
  sz = sz1;
    80004f0a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f0e:	4a81                	li	s5,0
    80004f10:	bf75                	j	80004ecc <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f12:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f16:	e0843783          	ld	a5,-504(s0)
    80004f1a:	0017869b          	addiw	a3,a5,1
    80004f1e:	e0d43423          	sd	a3,-504(s0)
    80004f22:	e0043783          	ld	a5,-512(s0)
    80004f26:	0387879b          	addiw	a5,a5,56
    80004f2a:	e8845703          	lhu	a4,-376(s0)
    80004f2e:	e0e6dee3          	bge	a3,a4,80004d4a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f32:	2781                	sext.w	a5,a5
    80004f34:	e0f43023          	sd	a5,-512(s0)
    80004f38:	03800713          	li	a4,56
    80004f3c:	86be                	mv	a3,a5
    80004f3e:	e1840613          	addi	a2,s0,-488
    80004f42:	4581                	li	a1,0
    80004f44:	8556                	mv	a0,s5
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	a5c080e7          	jalr	-1444(ra) # 800039a2 <readi>
    80004f4e:	03800793          	li	a5,56
    80004f52:	f6f51be3          	bne	a0,a5,80004ec8 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80004f56:	e1842783          	lw	a5,-488(s0)
    80004f5a:	4705                	li	a4,1
    80004f5c:	fae79de3          	bne	a5,a4,80004f16 <exec+0x320>
    if(ph.memsz < ph.filesz)
    80004f60:	e4043483          	ld	s1,-448(s0)
    80004f64:	e3843783          	ld	a5,-456(s0)
    80004f68:	f6f4ede3          	bltu	s1,a5,80004ee2 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f6c:	e2843783          	ld	a5,-472(s0)
    80004f70:	94be                	add	s1,s1,a5
    80004f72:	f6f4ebe3          	bltu	s1,a5,80004ee8 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80004f76:	de043703          	ld	a4,-544(s0)
    80004f7a:	8ff9                	and	a5,a5,a4
    80004f7c:	fbad                	bnez	a5,80004eee <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f7e:	e1c42503          	lw	a0,-484(s0)
    80004f82:	00000097          	auipc	ra,0x0
    80004f86:	c58080e7          	jalr	-936(ra) # 80004bda <flags2perm>
    80004f8a:	86aa                	mv	a3,a0
    80004f8c:	8626                	mv	a2,s1
    80004f8e:	85ca                	mv	a1,s2
    80004f90:	855a                	mv	a0,s6
    80004f92:	ffffc097          	auipc	ra,0xffffc
    80004f96:	47e080e7          	jalr	1150(ra) # 80001410 <uvmalloc>
    80004f9a:	dea43c23          	sd	a0,-520(s0)
    80004f9e:	d939                	beqz	a0,80004ef4 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fa0:	e2843c03          	ld	s8,-472(s0)
    80004fa4:	e2042c83          	lw	s9,-480(s0)
    80004fa8:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fac:	f60b83e3          	beqz	s7,80004f12 <exec+0x31c>
    80004fb0:	89de                	mv	s3,s7
    80004fb2:	4481                	li	s1,0
    80004fb4:	bb95                	j	80004d28 <exec+0x132>

0000000080004fb6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fb6:	7179                	addi	sp,sp,-48
    80004fb8:	f406                	sd	ra,40(sp)
    80004fba:	f022                	sd	s0,32(sp)
    80004fbc:	ec26                	sd	s1,24(sp)
    80004fbe:	e84a                	sd	s2,16(sp)
    80004fc0:	1800                	addi	s0,sp,48
    80004fc2:	892e                	mv	s2,a1
    80004fc4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fc6:	fdc40593          	addi	a1,s0,-36
    80004fca:	ffffe097          	auipc	ra,0xffffe
    80004fce:	afe080e7          	jalr	-1282(ra) # 80002ac8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fd2:	fdc42703          	lw	a4,-36(s0)
    80004fd6:	47bd                	li	a5,15
    80004fd8:	02e7eb63          	bltu	a5,a4,8000500e <argfd+0x58>
    80004fdc:	ffffd097          	auipc	ra,0xffffd
    80004fe0:	9d8080e7          	jalr	-1576(ra) # 800019b4 <myproc>
    80004fe4:	fdc42703          	lw	a4,-36(s0)
    80004fe8:	01a70793          	addi	a5,a4,26
    80004fec:	078e                	slli	a5,a5,0x3
    80004fee:	953e                	add	a0,a0,a5
    80004ff0:	611c                	ld	a5,0(a0)
    80004ff2:	c385                	beqz	a5,80005012 <argfd+0x5c>
    return -1;
  if(pfd)
    80004ff4:	00090463          	beqz	s2,80004ffc <argfd+0x46>
    *pfd = fd;
    80004ff8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ffc:	4501                	li	a0,0
  if(pf)
    80004ffe:	c091                	beqz	s1,80005002 <argfd+0x4c>
    *pf = f;
    80005000:	e09c                	sd	a5,0(s1)
}
    80005002:	70a2                	ld	ra,40(sp)
    80005004:	7402                	ld	s0,32(sp)
    80005006:	64e2                	ld	s1,24(sp)
    80005008:	6942                	ld	s2,16(sp)
    8000500a:	6145                	addi	sp,sp,48
    8000500c:	8082                	ret
    return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	bfcd                	j	80005002 <argfd+0x4c>
    80005012:	557d                	li	a0,-1
    80005014:	b7fd                	j	80005002 <argfd+0x4c>

0000000080005016 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005016:	1101                	addi	sp,sp,-32
    80005018:	ec06                	sd	ra,24(sp)
    8000501a:	e822                	sd	s0,16(sp)
    8000501c:	e426                	sd	s1,8(sp)
    8000501e:	1000                	addi	s0,sp,32
    80005020:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005022:	ffffd097          	auipc	ra,0xffffd
    80005026:	992080e7          	jalr	-1646(ra) # 800019b4 <myproc>
    8000502a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000502c:	0d050793          	addi	a5,a0,208
    80005030:	4501                	li	a0,0
    80005032:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005034:	6398                	ld	a4,0(a5)
    80005036:	cb19                	beqz	a4,8000504c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005038:	2505                	addiw	a0,a0,1
    8000503a:	07a1                	addi	a5,a5,8
    8000503c:	fed51ce3          	bne	a0,a3,80005034 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005040:	557d                	li	a0,-1
}
    80005042:	60e2                	ld	ra,24(sp)
    80005044:	6442                	ld	s0,16(sp)
    80005046:	64a2                	ld	s1,8(sp)
    80005048:	6105                	addi	sp,sp,32
    8000504a:	8082                	ret
      p->ofile[fd] = f;
    8000504c:	01a50793          	addi	a5,a0,26
    80005050:	078e                	slli	a5,a5,0x3
    80005052:	963e                	add	a2,a2,a5
    80005054:	e204                	sd	s1,0(a2)
      return fd;
    80005056:	b7f5                	j	80005042 <fdalloc+0x2c>

0000000080005058 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005058:	715d                	addi	sp,sp,-80
    8000505a:	e486                	sd	ra,72(sp)
    8000505c:	e0a2                	sd	s0,64(sp)
    8000505e:	fc26                	sd	s1,56(sp)
    80005060:	f84a                	sd	s2,48(sp)
    80005062:	f44e                	sd	s3,40(sp)
    80005064:	f052                	sd	s4,32(sp)
    80005066:	ec56                	sd	s5,24(sp)
    80005068:	e85a                	sd	s6,16(sp)
    8000506a:	0880                	addi	s0,sp,80
    8000506c:	8b2e                	mv	s6,a1
    8000506e:	89b2                	mv	s3,a2
    80005070:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005072:	fb040593          	addi	a1,s0,-80
    80005076:	fffff097          	auipc	ra,0xfffff
    8000507a:	e3c080e7          	jalr	-452(ra) # 80003eb2 <nameiparent>
    8000507e:	84aa                	mv	s1,a0
    80005080:	14050f63          	beqz	a0,800051de <create+0x186>
    return 0;

  ilock(dp);
    80005084:	ffffe097          	auipc	ra,0xffffe
    80005088:	66a080e7          	jalr	1642(ra) # 800036ee <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000508c:	4601                	li	a2,0
    8000508e:	fb040593          	addi	a1,s0,-80
    80005092:	8526                	mv	a0,s1
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	b3e080e7          	jalr	-1218(ra) # 80003bd2 <dirlookup>
    8000509c:	8aaa                	mv	s5,a0
    8000509e:	c931                	beqz	a0,800050f2 <create+0x9a>
    iunlockput(dp);
    800050a0:	8526                	mv	a0,s1
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	8ae080e7          	jalr	-1874(ra) # 80003950 <iunlockput>
    ilock(ip);
    800050aa:	8556                	mv	a0,s5
    800050ac:	ffffe097          	auipc	ra,0xffffe
    800050b0:	642080e7          	jalr	1602(ra) # 800036ee <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050b4:	000b059b          	sext.w	a1,s6
    800050b8:	4789                	li	a5,2
    800050ba:	02f59563          	bne	a1,a5,800050e4 <create+0x8c>
    800050be:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd1f4>
    800050c2:	37f9                	addiw	a5,a5,-2
    800050c4:	17c2                	slli	a5,a5,0x30
    800050c6:	93c1                	srli	a5,a5,0x30
    800050c8:	4705                	li	a4,1
    800050ca:	00f76d63          	bltu	a4,a5,800050e4 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050ce:	8556                	mv	a0,s5
    800050d0:	60a6                	ld	ra,72(sp)
    800050d2:	6406                	ld	s0,64(sp)
    800050d4:	74e2                	ld	s1,56(sp)
    800050d6:	7942                	ld	s2,48(sp)
    800050d8:	79a2                	ld	s3,40(sp)
    800050da:	7a02                	ld	s4,32(sp)
    800050dc:	6ae2                	ld	s5,24(sp)
    800050de:	6b42                	ld	s6,16(sp)
    800050e0:	6161                	addi	sp,sp,80
    800050e2:	8082                	ret
    iunlockput(ip);
    800050e4:	8556                	mv	a0,s5
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	86a080e7          	jalr	-1942(ra) # 80003950 <iunlockput>
    return 0;
    800050ee:	4a81                	li	s5,0
    800050f0:	bff9                	j	800050ce <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050f2:	85da                	mv	a1,s6
    800050f4:	4088                	lw	a0,0(s1)
    800050f6:	ffffe097          	auipc	ra,0xffffe
    800050fa:	45c080e7          	jalr	1116(ra) # 80003552 <ialloc>
    800050fe:	8a2a                	mv	s4,a0
    80005100:	c539                	beqz	a0,8000514e <create+0xf6>
  ilock(ip);
    80005102:	ffffe097          	auipc	ra,0xffffe
    80005106:	5ec080e7          	jalr	1516(ra) # 800036ee <ilock>
  ip->major = major;
    8000510a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000510e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005112:	4905                	li	s2,1
    80005114:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005118:	8552                	mv	a0,s4
    8000511a:	ffffe097          	auipc	ra,0xffffe
    8000511e:	50a080e7          	jalr	1290(ra) # 80003624 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005122:	000b059b          	sext.w	a1,s6
    80005126:	03258b63          	beq	a1,s2,8000515c <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000512a:	004a2603          	lw	a2,4(s4)
    8000512e:	fb040593          	addi	a1,s0,-80
    80005132:	8526                	mv	a0,s1
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	cae080e7          	jalr	-850(ra) # 80003de2 <dirlink>
    8000513c:	06054f63          	bltz	a0,800051ba <create+0x162>
  iunlockput(dp);
    80005140:	8526                	mv	a0,s1
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	80e080e7          	jalr	-2034(ra) # 80003950 <iunlockput>
  return ip;
    8000514a:	8ad2                	mv	s5,s4
    8000514c:	b749                	j	800050ce <create+0x76>
    iunlockput(dp);
    8000514e:	8526                	mv	a0,s1
    80005150:	fffff097          	auipc	ra,0xfffff
    80005154:	800080e7          	jalr	-2048(ra) # 80003950 <iunlockput>
    return 0;
    80005158:	8ad2                	mv	s5,s4
    8000515a:	bf95                	j	800050ce <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000515c:	004a2603          	lw	a2,4(s4)
    80005160:	00003597          	auipc	a1,0x3
    80005164:	5b058593          	addi	a1,a1,1456 # 80008710 <syscalls+0x2c0>
    80005168:	8552                	mv	a0,s4
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	c78080e7          	jalr	-904(ra) # 80003de2 <dirlink>
    80005172:	04054463          	bltz	a0,800051ba <create+0x162>
    80005176:	40d0                	lw	a2,4(s1)
    80005178:	00003597          	auipc	a1,0x3
    8000517c:	5a058593          	addi	a1,a1,1440 # 80008718 <syscalls+0x2c8>
    80005180:	8552                	mv	a0,s4
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	c60080e7          	jalr	-928(ra) # 80003de2 <dirlink>
    8000518a:	02054863          	bltz	a0,800051ba <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000518e:	004a2603          	lw	a2,4(s4)
    80005192:	fb040593          	addi	a1,s0,-80
    80005196:	8526                	mv	a0,s1
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	c4a080e7          	jalr	-950(ra) # 80003de2 <dirlink>
    800051a0:	00054d63          	bltz	a0,800051ba <create+0x162>
    dp->nlink++;  // for ".."
    800051a4:	04a4d783          	lhu	a5,74(s1)
    800051a8:	2785                	addiw	a5,a5,1
    800051aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051ae:	8526                	mv	a0,s1
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	474080e7          	jalr	1140(ra) # 80003624 <iupdate>
    800051b8:	b761                	j	80005140 <create+0xe8>
  ip->nlink = 0;
    800051ba:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800051be:	8552                	mv	a0,s4
    800051c0:	ffffe097          	auipc	ra,0xffffe
    800051c4:	464080e7          	jalr	1124(ra) # 80003624 <iupdate>
  iunlockput(ip);
    800051c8:	8552                	mv	a0,s4
    800051ca:	ffffe097          	auipc	ra,0xffffe
    800051ce:	786080e7          	jalr	1926(ra) # 80003950 <iunlockput>
  iunlockput(dp);
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffe097          	auipc	ra,0xffffe
    800051d8:	77c080e7          	jalr	1916(ra) # 80003950 <iunlockput>
  return 0;
    800051dc:	bdcd                	j	800050ce <create+0x76>
    return 0;
    800051de:	8aaa                	mv	s5,a0
    800051e0:	b5fd                	j	800050ce <create+0x76>

00000000800051e2 <sys_dup>:
{
    800051e2:	7179                	addi	sp,sp,-48
    800051e4:	f406                	sd	ra,40(sp)
    800051e6:	f022                	sd	s0,32(sp)
    800051e8:	ec26                	sd	s1,24(sp)
    800051ea:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051ec:	fd840613          	addi	a2,s0,-40
    800051f0:	4581                	li	a1,0
    800051f2:	4501                	li	a0,0
    800051f4:	00000097          	auipc	ra,0x0
    800051f8:	dc2080e7          	jalr	-574(ra) # 80004fb6 <argfd>
    return -1;
    800051fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051fe:	02054363          	bltz	a0,80005224 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005202:	fd843503          	ld	a0,-40(s0)
    80005206:	00000097          	auipc	ra,0x0
    8000520a:	e10080e7          	jalr	-496(ra) # 80005016 <fdalloc>
    8000520e:	84aa                	mv	s1,a0
    return -1;
    80005210:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005212:	00054963          	bltz	a0,80005224 <sys_dup+0x42>
  filedup(f);
    80005216:	fd843503          	ld	a0,-40(s0)
    8000521a:	fffff097          	auipc	ra,0xfffff
    8000521e:	310080e7          	jalr	784(ra) # 8000452a <filedup>
  return fd;
    80005222:	87a6                	mv	a5,s1
}
    80005224:	853e                	mv	a0,a5
    80005226:	70a2                	ld	ra,40(sp)
    80005228:	7402                	ld	s0,32(sp)
    8000522a:	64e2                	ld	s1,24(sp)
    8000522c:	6145                	addi	sp,sp,48
    8000522e:	8082                	ret

0000000080005230 <sys_read>:
{
    80005230:	7179                	addi	sp,sp,-48
    80005232:	f406                	sd	ra,40(sp)
    80005234:	f022                	sd	s0,32(sp)
    80005236:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005238:	fd840593          	addi	a1,s0,-40
    8000523c:	4505                	li	a0,1
    8000523e:	ffffe097          	auipc	ra,0xffffe
    80005242:	8aa080e7          	jalr	-1878(ra) # 80002ae8 <argaddr>
  argint(2, &n);
    80005246:	fe440593          	addi	a1,s0,-28
    8000524a:	4509                	li	a0,2
    8000524c:	ffffe097          	auipc	ra,0xffffe
    80005250:	87c080e7          	jalr	-1924(ra) # 80002ac8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005254:	fe840613          	addi	a2,s0,-24
    80005258:	4581                	li	a1,0
    8000525a:	4501                	li	a0,0
    8000525c:	00000097          	auipc	ra,0x0
    80005260:	d5a080e7          	jalr	-678(ra) # 80004fb6 <argfd>
    80005264:	87aa                	mv	a5,a0
    return -1;
    80005266:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005268:	0007cc63          	bltz	a5,80005280 <sys_read+0x50>
  return fileread(f, p, n);
    8000526c:	fe442603          	lw	a2,-28(s0)
    80005270:	fd843583          	ld	a1,-40(s0)
    80005274:	fe843503          	ld	a0,-24(s0)
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	43e080e7          	jalr	1086(ra) # 800046b6 <fileread>
}
    80005280:	70a2                	ld	ra,40(sp)
    80005282:	7402                	ld	s0,32(sp)
    80005284:	6145                	addi	sp,sp,48
    80005286:	8082                	ret

0000000080005288 <sys_write>:
{
    80005288:	7179                	addi	sp,sp,-48
    8000528a:	f406                	sd	ra,40(sp)
    8000528c:	f022                	sd	s0,32(sp)
    8000528e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005290:	fd840593          	addi	a1,s0,-40
    80005294:	4505                	li	a0,1
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	852080e7          	jalr	-1966(ra) # 80002ae8 <argaddr>
  argint(2, &n);
    8000529e:	fe440593          	addi	a1,s0,-28
    800052a2:	4509                	li	a0,2
    800052a4:	ffffe097          	auipc	ra,0xffffe
    800052a8:	824080e7          	jalr	-2012(ra) # 80002ac8 <argint>
  if(argfd(0, 0, &f) < 0)
    800052ac:	fe840613          	addi	a2,s0,-24
    800052b0:	4581                	li	a1,0
    800052b2:	4501                	li	a0,0
    800052b4:	00000097          	auipc	ra,0x0
    800052b8:	d02080e7          	jalr	-766(ra) # 80004fb6 <argfd>
    800052bc:	87aa                	mv	a5,a0
    return -1;
    800052be:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c0:	0007cc63          	bltz	a5,800052d8 <sys_write+0x50>
  return filewrite(f, p, n);
    800052c4:	fe442603          	lw	a2,-28(s0)
    800052c8:	fd843583          	ld	a1,-40(s0)
    800052cc:	fe843503          	ld	a0,-24(s0)
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	4a8080e7          	jalr	1192(ra) # 80004778 <filewrite>
}
    800052d8:	70a2                	ld	ra,40(sp)
    800052da:	7402                	ld	s0,32(sp)
    800052dc:	6145                	addi	sp,sp,48
    800052de:	8082                	ret

00000000800052e0 <sys_close>:
{
    800052e0:	1101                	addi	sp,sp,-32
    800052e2:	ec06                	sd	ra,24(sp)
    800052e4:	e822                	sd	s0,16(sp)
    800052e6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052e8:	fe040613          	addi	a2,s0,-32
    800052ec:	fec40593          	addi	a1,s0,-20
    800052f0:	4501                	li	a0,0
    800052f2:	00000097          	auipc	ra,0x0
    800052f6:	cc4080e7          	jalr	-828(ra) # 80004fb6 <argfd>
    return -1;
    800052fa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052fc:	02054463          	bltz	a0,80005324 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005300:	ffffc097          	auipc	ra,0xffffc
    80005304:	6b4080e7          	jalr	1716(ra) # 800019b4 <myproc>
    80005308:	fec42783          	lw	a5,-20(s0)
    8000530c:	07e9                	addi	a5,a5,26
    8000530e:	078e                	slli	a5,a5,0x3
    80005310:	97aa                	add	a5,a5,a0
    80005312:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005316:	fe043503          	ld	a0,-32(s0)
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	262080e7          	jalr	610(ra) # 8000457c <fileclose>
  return 0;
    80005322:	4781                	li	a5,0
}
    80005324:	853e                	mv	a0,a5
    80005326:	60e2                	ld	ra,24(sp)
    80005328:	6442                	ld	s0,16(sp)
    8000532a:	6105                	addi	sp,sp,32
    8000532c:	8082                	ret

000000008000532e <sys_fstat>:
{
    8000532e:	1101                	addi	sp,sp,-32
    80005330:	ec06                	sd	ra,24(sp)
    80005332:	e822                	sd	s0,16(sp)
    80005334:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005336:	fe040593          	addi	a1,s0,-32
    8000533a:	4505                	li	a0,1
    8000533c:	ffffd097          	auipc	ra,0xffffd
    80005340:	7ac080e7          	jalr	1964(ra) # 80002ae8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005344:	fe840613          	addi	a2,s0,-24
    80005348:	4581                	li	a1,0
    8000534a:	4501                	li	a0,0
    8000534c:	00000097          	auipc	ra,0x0
    80005350:	c6a080e7          	jalr	-918(ra) # 80004fb6 <argfd>
    80005354:	87aa                	mv	a5,a0
    return -1;
    80005356:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005358:	0007ca63          	bltz	a5,8000536c <sys_fstat+0x3e>
  return filestat(f, st);
    8000535c:	fe043583          	ld	a1,-32(s0)
    80005360:	fe843503          	ld	a0,-24(s0)
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	2e0080e7          	jalr	736(ra) # 80004644 <filestat>
}
    8000536c:	60e2                	ld	ra,24(sp)
    8000536e:	6442                	ld	s0,16(sp)
    80005370:	6105                	addi	sp,sp,32
    80005372:	8082                	ret

0000000080005374 <sys_link>:
{
    80005374:	7169                	addi	sp,sp,-304
    80005376:	f606                	sd	ra,296(sp)
    80005378:	f222                	sd	s0,288(sp)
    8000537a:	ee26                	sd	s1,280(sp)
    8000537c:	ea4a                	sd	s2,272(sp)
    8000537e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005380:	08000613          	li	a2,128
    80005384:	ed040593          	addi	a1,s0,-304
    80005388:	4501                	li	a0,0
    8000538a:	ffffd097          	auipc	ra,0xffffd
    8000538e:	77e080e7          	jalr	1918(ra) # 80002b08 <argstr>
    return -1;
    80005392:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005394:	10054e63          	bltz	a0,800054b0 <sys_link+0x13c>
    80005398:	08000613          	li	a2,128
    8000539c:	f5040593          	addi	a1,s0,-176
    800053a0:	4505                	li	a0,1
    800053a2:	ffffd097          	auipc	ra,0xffffd
    800053a6:	766080e7          	jalr	1894(ra) # 80002b08 <argstr>
    return -1;
    800053aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ac:	10054263          	bltz	a0,800054b0 <sys_link+0x13c>
  begin_op();
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	d00080e7          	jalr	-768(ra) # 800040b0 <begin_op>
  if((ip = namei(old)) == 0){
    800053b8:	ed040513          	addi	a0,s0,-304
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	ad8080e7          	jalr	-1320(ra) # 80003e94 <namei>
    800053c4:	84aa                	mv	s1,a0
    800053c6:	c551                	beqz	a0,80005452 <sys_link+0xde>
  ilock(ip);
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	326080e7          	jalr	806(ra) # 800036ee <ilock>
  if(ip->type == T_DIR){
    800053d0:	04449703          	lh	a4,68(s1)
    800053d4:	4785                	li	a5,1
    800053d6:	08f70463          	beq	a4,a5,8000545e <sys_link+0xea>
  ip->nlink++;
    800053da:	04a4d783          	lhu	a5,74(s1)
    800053de:	2785                	addiw	a5,a5,1
    800053e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053e4:	8526                	mv	a0,s1
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	23e080e7          	jalr	574(ra) # 80003624 <iupdate>
  iunlock(ip);
    800053ee:	8526                	mv	a0,s1
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	3c0080e7          	jalr	960(ra) # 800037b0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053f8:	fd040593          	addi	a1,s0,-48
    800053fc:	f5040513          	addi	a0,s0,-176
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	ab2080e7          	jalr	-1358(ra) # 80003eb2 <nameiparent>
    80005408:	892a                	mv	s2,a0
    8000540a:	c935                	beqz	a0,8000547e <sys_link+0x10a>
  ilock(dp);
    8000540c:	ffffe097          	auipc	ra,0xffffe
    80005410:	2e2080e7          	jalr	738(ra) # 800036ee <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005414:	00092703          	lw	a4,0(s2)
    80005418:	409c                	lw	a5,0(s1)
    8000541a:	04f71d63          	bne	a4,a5,80005474 <sys_link+0x100>
    8000541e:	40d0                	lw	a2,4(s1)
    80005420:	fd040593          	addi	a1,s0,-48
    80005424:	854a                	mv	a0,s2
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	9bc080e7          	jalr	-1604(ra) # 80003de2 <dirlink>
    8000542e:	04054363          	bltz	a0,80005474 <sys_link+0x100>
  iunlockput(dp);
    80005432:	854a                	mv	a0,s2
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	51c080e7          	jalr	1308(ra) # 80003950 <iunlockput>
  iput(ip);
    8000543c:	8526                	mv	a0,s1
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	46a080e7          	jalr	1130(ra) # 800038a8 <iput>
  end_op();
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	cea080e7          	jalr	-790(ra) # 80004130 <end_op>
  return 0;
    8000544e:	4781                	li	a5,0
    80005450:	a085                	j	800054b0 <sys_link+0x13c>
    end_op();
    80005452:	fffff097          	auipc	ra,0xfffff
    80005456:	cde080e7          	jalr	-802(ra) # 80004130 <end_op>
    return -1;
    8000545a:	57fd                	li	a5,-1
    8000545c:	a891                	j	800054b0 <sys_link+0x13c>
    iunlockput(ip);
    8000545e:	8526                	mv	a0,s1
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	4f0080e7          	jalr	1264(ra) # 80003950 <iunlockput>
    end_op();
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	cc8080e7          	jalr	-824(ra) # 80004130 <end_op>
    return -1;
    80005470:	57fd                	li	a5,-1
    80005472:	a83d                	j	800054b0 <sys_link+0x13c>
    iunlockput(dp);
    80005474:	854a                	mv	a0,s2
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	4da080e7          	jalr	1242(ra) # 80003950 <iunlockput>
  ilock(ip);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	26e080e7          	jalr	622(ra) # 800036ee <ilock>
  ip->nlink--;
    80005488:	04a4d783          	lhu	a5,74(s1)
    8000548c:	37fd                	addiw	a5,a5,-1
    8000548e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005492:	8526                	mv	a0,s1
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	190080e7          	jalr	400(ra) # 80003624 <iupdate>
  iunlockput(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	4b2080e7          	jalr	1202(ra) # 80003950 <iunlockput>
  end_op();
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	c8a080e7          	jalr	-886(ra) # 80004130 <end_op>
  return -1;
    800054ae:	57fd                	li	a5,-1
}
    800054b0:	853e                	mv	a0,a5
    800054b2:	70b2                	ld	ra,296(sp)
    800054b4:	7412                	ld	s0,288(sp)
    800054b6:	64f2                	ld	s1,280(sp)
    800054b8:	6952                	ld	s2,272(sp)
    800054ba:	6155                	addi	sp,sp,304
    800054bc:	8082                	ret

00000000800054be <sys_unlink>:
{
    800054be:	7151                	addi	sp,sp,-240
    800054c0:	f586                	sd	ra,232(sp)
    800054c2:	f1a2                	sd	s0,224(sp)
    800054c4:	eda6                	sd	s1,216(sp)
    800054c6:	e9ca                	sd	s2,208(sp)
    800054c8:	e5ce                	sd	s3,200(sp)
    800054ca:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054cc:	08000613          	li	a2,128
    800054d0:	f3040593          	addi	a1,s0,-208
    800054d4:	4501                	li	a0,0
    800054d6:	ffffd097          	auipc	ra,0xffffd
    800054da:	632080e7          	jalr	1586(ra) # 80002b08 <argstr>
    800054de:	18054163          	bltz	a0,80005660 <sys_unlink+0x1a2>
  begin_op();
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	bce080e7          	jalr	-1074(ra) # 800040b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054ea:	fb040593          	addi	a1,s0,-80
    800054ee:	f3040513          	addi	a0,s0,-208
    800054f2:	fffff097          	auipc	ra,0xfffff
    800054f6:	9c0080e7          	jalr	-1600(ra) # 80003eb2 <nameiparent>
    800054fa:	84aa                	mv	s1,a0
    800054fc:	c979                	beqz	a0,800055d2 <sys_unlink+0x114>
  ilock(dp);
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	1f0080e7          	jalr	496(ra) # 800036ee <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005506:	00003597          	auipc	a1,0x3
    8000550a:	20a58593          	addi	a1,a1,522 # 80008710 <syscalls+0x2c0>
    8000550e:	fb040513          	addi	a0,s0,-80
    80005512:	ffffe097          	auipc	ra,0xffffe
    80005516:	6a6080e7          	jalr	1702(ra) # 80003bb8 <namecmp>
    8000551a:	14050a63          	beqz	a0,8000566e <sys_unlink+0x1b0>
    8000551e:	00003597          	auipc	a1,0x3
    80005522:	1fa58593          	addi	a1,a1,506 # 80008718 <syscalls+0x2c8>
    80005526:	fb040513          	addi	a0,s0,-80
    8000552a:	ffffe097          	auipc	ra,0xffffe
    8000552e:	68e080e7          	jalr	1678(ra) # 80003bb8 <namecmp>
    80005532:	12050e63          	beqz	a0,8000566e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005536:	f2c40613          	addi	a2,s0,-212
    8000553a:	fb040593          	addi	a1,s0,-80
    8000553e:	8526                	mv	a0,s1
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	692080e7          	jalr	1682(ra) # 80003bd2 <dirlookup>
    80005548:	892a                	mv	s2,a0
    8000554a:	12050263          	beqz	a0,8000566e <sys_unlink+0x1b0>
  ilock(ip);
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	1a0080e7          	jalr	416(ra) # 800036ee <ilock>
  if(ip->nlink < 1)
    80005556:	04a91783          	lh	a5,74(s2)
    8000555a:	08f05263          	blez	a5,800055de <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000555e:	04491703          	lh	a4,68(s2)
    80005562:	4785                	li	a5,1
    80005564:	08f70563          	beq	a4,a5,800055ee <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005568:	4641                	li	a2,16
    8000556a:	4581                	li	a1,0
    8000556c:	fc040513          	addi	a0,s0,-64
    80005570:	ffffb097          	auipc	ra,0xffffb
    80005574:	762080e7          	jalr	1890(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005578:	4741                	li	a4,16
    8000557a:	f2c42683          	lw	a3,-212(s0)
    8000557e:	fc040613          	addi	a2,s0,-64
    80005582:	4581                	li	a1,0
    80005584:	8526                	mv	a0,s1
    80005586:	ffffe097          	auipc	ra,0xffffe
    8000558a:	514080e7          	jalr	1300(ra) # 80003a9a <writei>
    8000558e:	47c1                	li	a5,16
    80005590:	0af51563          	bne	a0,a5,8000563a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005594:	04491703          	lh	a4,68(s2)
    80005598:	4785                	li	a5,1
    8000559a:	0af70863          	beq	a4,a5,8000564a <sys_unlink+0x18c>
  iunlockput(dp);
    8000559e:	8526                	mv	a0,s1
    800055a0:	ffffe097          	auipc	ra,0xffffe
    800055a4:	3b0080e7          	jalr	944(ra) # 80003950 <iunlockput>
  ip->nlink--;
    800055a8:	04a95783          	lhu	a5,74(s2)
    800055ac:	37fd                	addiw	a5,a5,-1
    800055ae:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055b2:	854a                	mv	a0,s2
    800055b4:	ffffe097          	auipc	ra,0xffffe
    800055b8:	070080e7          	jalr	112(ra) # 80003624 <iupdate>
  iunlockput(ip);
    800055bc:	854a                	mv	a0,s2
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	392080e7          	jalr	914(ra) # 80003950 <iunlockput>
  end_op();
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	b6a080e7          	jalr	-1174(ra) # 80004130 <end_op>
  return 0;
    800055ce:	4501                	li	a0,0
    800055d0:	a84d                	j	80005682 <sys_unlink+0x1c4>
    end_op();
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	b5e080e7          	jalr	-1186(ra) # 80004130 <end_op>
    return -1;
    800055da:	557d                	li	a0,-1
    800055dc:	a05d                	j	80005682 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055de:	00003517          	auipc	a0,0x3
    800055e2:	14250513          	addi	a0,a0,322 # 80008720 <syscalls+0x2d0>
    800055e6:	ffffb097          	auipc	ra,0xffffb
    800055ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ee:	04c92703          	lw	a4,76(s2)
    800055f2:	02000793          	li	a5,32
    800055f6:	f6e7f9e3          	bgeu	a5,a4,80005568 <sys_unlink+0xaa>
    800055fa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055fe:	4741                	li	a4,16
    80005600:	86ce                	mv	a3,s3
    80005602:	f1840613          	addi	a2,s0,-232
    80005606:	4581                	li	a1,0
    80005608:	854a                	mv	a0,s2
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	398080e7          	jalr	920(ra) # 800039a2 <readi>
    80005612:	47c1                	li	a5,16
    80005614:	00f51b63          	bne	a0,a5,8000562a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005618:	f1845783          	lhu	a5,-232(s0)
    8000561c:	e7a1                	bnez	a5,80005664 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000561e:	29c1                	addiw	s3,s3,16
    80005620:	04c92783          	lw	a5,76(s2)
    80005624:	fcf9ede3          	bltu	s3,a5,800055fe <sys_unlink+0x140>
    80005628:	b781                	j	80005568 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000562a:	00003517          	auipc	a0,0x3
    8000562e:	10e50513          	addi	a0,a0,270 # 80008738 <syscalls+0x2e8>
    80005632:	ffffb097          	auipc	ra,0xffffb
    80005636:	f0c080e7          	jalr	-244(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000563a:	00003517          	auipc	a0,0x3
    8000563e:	11650513          	addi	a0,a0,278 # 80008750 <syscalls+0x300>
    80005642:	ffffb097          	auipc	ra,0xffffb
    80005646:	efc080e7          	jalr	-260(ra) # 8000053e <panic>
    dp->nlink--;
    8000564a:	04a4d783          	lhu	a5,74(s1)
    8000564e:	37fd                	addiw	a5,a5,-1
    80005650:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005654:	8526                	mv	a0,s1
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	fce080e7          	jalr	-50(ra) # 80003624 <iupdate>
    8000565e:	b781                	j	8000559e <sys_unlink+0xe0>
    return -1;
    80005660:	557d                	li	a0,-1
    80005662:	a005                	j	80005682 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005664:	854a                	mv	a0,s2
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	2ea080e7          	jalr	746(ra) # 80003950 <iunlockput>
  iunlockput(dp);
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	2e0080e7          	jalr	736(ra) # 80003950 <iunlockput>
  end_op();
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	ab8080e7          	jalr	-1352(ra) # 80004130 <end_op>
  return -1;
    80005680:	557d                	li	a0,-1
}
    80005682:	70ae                	ld	ra,232(sp)
    80005684:	740e                	ld	s0,224(sp)
    80005686:	64ee                	ld	s1,216(sp)
    80005688:	694e                	ld	s2,208(sp)
    8000568a:	69ae                	ld	s3,200(sp)
    8000568c:	616d                	addi	sp,sp,240
    8000568e:	8082                	ret

0000000080005690 <sys_open>:

uint64
sys_open(void)
{
    80005690:	7131                	addi	sp,sp,-192
    80005692:	fd06                	sd	ra,184(sp)
    80005694:	f922                	sd	s0,176(sp)
    80005696:	f526                	sd	s1,168(sp)
    80005698:	f14a                	sd	s2,160(sp)
    8000569a:	ed4e                	sd	s3,152(sp)
    8000569c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000569e:	f4c40593          	addi	a1,s0,-180
    800056a2:	4505                	li	a0,1
    800056a4:	ffffd097          	auipc	ra,0xffffd
    800056a8:	424080e7          	jalr	1060(ra) # 80002ac8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056ac:	08000613          	li	a2,128
    800056b0:	f5040593          	addi	a1,s0,-176
    800056b4:	4501                	li	a0,0
    800056b6:	ffffd097          	auipc	ra,0xffffd
    800056ba:	452080e7          	jalr	1106(ra) # 80002b08 <argstr>
    800056be:	87aa                	mv	a5,a0
    return -1;
    800056c0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056c2:	0a07c963          	bltz	a5,80005774 <sys_open+0xe4>

  begin_op();
    800056c6:	fffff097          	auipc	ra,0xfffff
    800056ca:	9ea080e7          	jalr	-1558(ra) # 800040b0 <begin_op>

  if(omode & O_CREATE){
    800056ce:	f4c42783          	lw	a5,-180(s0)
    800056d2:	2007f793          	andi	a5,a5,512
    800056d6:	cfc5                	beqz	a5,8000578e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056d8:	4681                	li	a3,0
    800056da:	4601                	li	a2,0
    800056dc:	4589                	li	a1,2
    800056de:	f5040513          	addi	a0,s0,-176
    800056e2:	00000097          	auipc	ra,0x0
    800056e6:	976080e7          	jalr	-1674(ra) # 80005058 <create>
    800056ea:	84aa                	mv	s1,a0
    if(ip == 0){
    800056ec:	c959                	beqz	a0,80005782 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056ee:	04449703          	lh	a4,68(s1)
    800056f2:	478d                	li	a5,3
    800056f4:	00f71763          	bne	a4,a5,80005702 <sys_open+0x72>
    800056f8:	0464d703          	lhu	a4,70(s1)
    800056fc:	47a5                	li	a5,9
    800056fe:	0ce7ed63          	bltu	a5,a4,800057d8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	dbe080e7          	jalr	-578(ra) # 800044c0 <filealloc>
    8000570a:	89aa                	mv	s3,a0
    8000570c:	10050363          	beqz	a0,80005812 <sys_open+0x182>
    80005710:	00000097          	auipc	ra,0x0
    80005714:	906080e7          	jalr	-1786(ra) # 80005016 <fdalloc>
    80005718:	892a                	mv	s2,a0
    8000571a:	0e054763          	bltz	a0,80005808 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000571e:	04449703          	lh	a4,68(s1)
    80005722:	478d                	li	a5,3
    80005724:	0cf70563          	beq	a4,a5,800057ee <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005728:	4789                	li	a5,2
    8000572a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000572e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005732:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005736:	f4c42783          	lw	a5,-180(s0)
    8000573a:	0017c713          	xori	a4,a5,1
    8000573e:	8b05                	andi	a4,a4,1
    80005740:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005744:	0037f713          	andi	a4,a5,3
    80005748:	00e03733          	snez	a4,a4
    8000574c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005750:	4007f793          	andi	a5,a5,1024
    80005754:	c791                	beqz	a5,80005760 <sys_open+0xd0>
    80005756:	04449703          	lh	a4,68(s1)
    8000575a:	4789                	li	a5,2
    8000575c:	0af70063          	beq	a4,a5,800057fc <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	04e080e7          	jalr	78(ra) # 800037b0 <iunlock>
  end_op();
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	9c6080e7          	jalr	-1594(ra) # 80004130 <end_op>

  return fd;
    80005772:	854a                	mv	a0,s2
}
    80005774:	70ea                	ld	ra,184(sp)
    80005776:	744a                	ld	s0,176(sp)
    80005778:	74aa                	ld	s1,168(sp)
    8000577a:	790a                	ld	s2,160(sp)
    8000577c:	69ea                	ld	s3,152(sp)
    8000577e:	6129                	addi	sp,sp,192
    80005780:	8082                	ret
      end_op();
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	9ae080e7          	jalr	-1618(ra) # 80004130 <end_op>
      return -1;
    8000578a:	557d                	li	a0,-1
    8000578c:	b7e5                	j	80005774 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000578e:	f5040513          	addi	a0,s0,-176
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	702080e7          	jalr	1794(ra) # 80003e94 <namei>
    8000579a:	84aa                	mv	s1,a0
    8000579c:	c905                	beqz	a0,800057cc <sys_open+0x13c>
    ilock(ip);
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	f50080e7          	jalr	-176(ra) # 800036ee <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057a6:	04449703          	lh	a4,68(s1)
    800057aa:	4785                	li	a5,1
    800057ac:	f4f711e3          	bne	a4,a5,800056ee <sys_open+0x5e>
    800057b0:	f4c42783          	lw	a5,-180(s0)
    800057b4:	d7b9                	beqz	a5,80005702 <sys_open+0x72>
      iunlockput(ip);
    800057b6:	8526                	mv	a0,s1
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	198080e7          	jalr	408(ra) # 80003950 <iunlockput>
      end_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	970080e7          	jalr	-1680(ra) # 80004130 <end_op>
      return -1;
    800057c8:	557d                	li	a0,-1
    800057ca:	b76d                	j	80005774 <sys_open+0xe4>
      end_op();
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	964080e7          	jalr	-1692(ra) # 80004130 <end_op>
      return -1;
    800057d4:	557d                	li	a0,-1
    800057d6:	bf79                	j	80005774 <sys_open+0xe4>
    iunlockput(ip);
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	176080e7          	jalr	374(ra) # 80003950 <iunlockput>
    end_op();
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	94e080e7          	jalr	-1714(ra) # 80004130 <end_op>
    return -1;
    800057ea:	557d                	li	a0,-1
    800057ec:	b761                	j	80005774 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057ee:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057f2:	04649783          	lh	a5,70(s1)
    800057f6:	02f99223          	sh	a5,36(s3)
    800057fa:	bf25                	j	80005732 <sys_open+0xa2>
    itrunc(ip);
    800057fc:	8526                	mv	a0,s1
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	ffe080e7          	jalr	-2(ra) # 800037fc <itrunc>
    80005806:	bfa9                	j	80005760 <sys_open+0xd0>
      fileclose(f);
    80005808:	854e                	mv	a0,s3
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	d72080e7          	jalr	-654(ra) # 8000457c <fileclose>
    iunlockput(ip);
    80005812:	8526                	mv	a0,s1
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	13c080e7          	jalr	316(ra) # 80003950 <iunlockput>
    end_op();
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	914080e7          	jalr	-1772(ra) # 80004130 <end_op>
    return -1;
    80005824:	557d                	li	a0,-1
    80005826:	b7b9                	j	80005774 <sys_open+0xe4>

0000000080005828 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005828:	7175                	addi	sp,sp,-144
    8000582a:	e506                	sd	ra,136(sp)
    8000582c:	e122                	sd	s0,128(sp)
    8000582e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	880080e7          	jalr	-1920(ra) # 800040b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005838:	08000613          	li	a2,128
    8000583c:	f7040593          	addi	a1,s0,-144
    80005840:	4501                	li	a0,0
    80005842:	ffffd097          	auipc	ra,0xffffd
    80005846:	2c6080e7          	jalr	710(ra) # 80002b08 <argstr>
    8000584a:	02054963          	bltz	a0,8000587c <sys_mkdir+0x54>
    8000584e:	4681                	li	a3,0
    80005850:	4601                	li	a2,0
    80005852:	4585                	li	a1,1
    80005854:	f7040513          	addi	a0,s0,-144
    80005858:	00000097          	auipc	ra,0x0
    8000585c:	800080e7          	jalr	-2048(ra) # 80005058 <create>
    80005860:	cd11                	beqz	a0,8000587c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	0ee080e7          	jalr	238(ra) # 80003950 <iunlockput>
  end_op();
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	8c6080e7          	jalr	-1850(ra) # 80004130 <end_op>
  return 0;
    80005872:	4501                	li	a0,0
}
    80005874:	60aa                	ld	ra,136(sp)
    80005876:	640a                	ld	s0,128(sp)
    80005878:	6149                	addi	sp,sp,144
    8000587a:	8082                	ret
    end_op();
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	8b4080e7          	jalr	-1868(ra) # 80004130 <end_op>
    return -1;
    80005884:	557d                	li	a0,-1
    80005886:	b7fd                	j	80005874 <sys_mkdir+0x4c>

0000000080005888 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005888:	7135                	addi	sp,sp,-160
    8000588a:	ed06                	sd	ra,152(sp)
    8000588c:	e922                	sd	s0,144(sp)
    8000588e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	820080e7          	jalr	-2016(ra) # 800040b0 <begin_op>
  argint(1, &major);
    80005898:	f6c40593          	addi	a1,s0,-148
    8000589c:	4505                	li	a0,1
    8000589e:	ffffd097          	auipc	ra,0xffffd
    800058a2:	22a080e7          	jalr	554(ra) # 80002ac8 <argint>
  argint(2, &minor);
    800058a6:	f6840593          	addi	a1,s0,-152
    800058aa:	4509                	li	a0,2
    800058ac:	ffffd097          	auipc	ra,0xffffd
    800058b0:	21c080e7          	jalr	540(ra) # 80002ac8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058b4:	08000613          	li	a2,128
    800058b8:	f7040593          	addi	a1,s0,-144
    800058bc:	4501                	li	a0,0
    800058be:	ffffd097          	auipc	ra,0xffffd
    800058c2:	24a080e7          	jalr	586(ra) # 80002b08 <argstr>
    800058c6:	02054b63          	bltz	a0,800058fc <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058ca:	f6841683          	lh	a3,-152(s0)
    800058ce:	f6c41603          	lh	a2,-148(s0)
    800058d2:	458d                	li	a1,3
    800058d4:	f7040513          	addi	a0,s0,-144
    800058d8:	fffff097          	auipc	ra,0xfffff
    800058dc:	780080e7          	jalr	1920(ra) # 80005058 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058e0:	cd11                	beqz	a0,800058fc <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	06e080e7          	jalr	110(ra) # 80003950 <iunlockput>
  end_op();
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	846080e7          	jalr	-1978(ra) # 80004130 <end_op>
  return 0;
    800058f2:	4501                	li	a0,0
}
    800058f4:	60ea                	ld	ra,152(sp)
    800058f6:	644a                	ld	s0,144(sp)
    800058f8:	610d                	addi	sp,sp,160
    800058fa:	8082                	ret
    end_op();
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	834080e7          	jalr	-1996(ra) # 80004130 <end_op>
    return -1;
    80005904:	557d                	li	a0,-1
    80005906:	b7fd                	j	800058f4 <sys_mknod+0x6c>

0000000080005908 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005908:	7135                	addi	sp,sp,-160
    8000590a:	ed06                	sd	ra,152(sp)
    8000590c:	e922                	sd	s0,144(sp)
    8000590e:	e526                	sd	s1,136(sp)
    80005910:	e14a                	sd	s2,128(sp)
    80005912:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005914:	ffffc097          	auipc	ra,0xffffc
    80005918:	0a0080e7          	jalr	160(ra) # 800019b4 <myproc>
    8000591c:	892a                	mv	s2,a0
  
  begin_op();
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	792080e7          	jalr	1938(ra) # 800040b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005926:	08000613          	li	a2,128
    8000592a:	f6040593          	addi	a1,s0,-160
    8000592e:	4501                	li	a0,0
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	1d8080e7          	jalr	472(ra) # 80002b08 <argstr>
    80005938:	04054b63          	bltz	a0,8000598e <sys_chdir+0x86>
    8000593c:	f6040513          	addi	a0,s0,-160
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	554080e7          	jalr	1364(ra) # 80003e94 <namei>
    80005948:	84aa                	mv	s1,a0
    8000594a:	c131                	beqz	a0,8000598e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	da2080e7          	jalr	-606(ra) # 800036ee <ilock>
  if(ip->type != T_DIR){
    80005954:	04449703          	lh	a4,68(s1)
    80005958:	4785                	li	a5,1
    8000595a:	04f71063          	bne	a4,a5,8000599a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	e50080e7          	jalr	-432(ra) # 800037b0 <iunlock>
  iput(p->cwd);
    80005968:	15093503          	ld	a0,336(s2)
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	f3c080e7          	jalr	-196(ra) # 800038a8 <iput>
  end_op();
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	7bc080e7          	jalr	1980(ra) # 80004130 <end_op>
  p->cwd = ip;
    8000597c:	14993823          	sd	s1,336(s2)
  return 0;
    80005980:	4501                	li	a0,0
}
    80005982:	60ea                	ld	ra,152(sp)
    80005984:	644a                	ld	s0,144(sp)
    80005986:	64aa                	ld	s1,136(sp)
    80005988:	690a                	ld	s2,128(sp)
    8000598a:	610d                	addi	sp,sp,160
    8000598c:	8082                	ret
    end_op();
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	7a2080e7          	jalr	1954(ra) # 80004130 <end_op>
    return -1;
    80005996:	557d                	li	a0,-1
    80005998:	b7ed                	j	80005982 <sys_chdir+0x7a>
    iunlockput(ip);
    8000599a:	8526                	mv	a0,s1
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	fb4080e7          	jalr	-76(ra) # 80003950 <iunlockput>
    end_op();
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	78c080e7          	jalr	1932(ra) # 80004130 <end_op>
    return -1;
    800059ac:	557d                	li	a0,-1
    800059ae:	bfd1                	j	80005982 <sys_chdir+0x7a>

00000000800059b0 <sys_exec>:

uint64
sys_exec(void)
{
    800059b0:	7145                	addi	sp,sp,-464
    800059b2:	e786                	sd	ra,456(sp)
    800059b4:	e3a2                	sd	s0,448(sp)
    800059b6:	ff26                	sd	s1,440(sp)
    800059b8:	fb4a                	sd	s2,432(sp)
    800059ba:	f74e                	sd	s3,424(sp)
    800059bc:	f352                	sd	s4,416(sp)
    800059be:	ef56                	sd	s5,408(sp)
    800059c0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059c2:	e3840593          	addi	a1,s0,-456
    800059c6:	4505                	li	a0,1
    800059c8:	ffffd097          	auipc	ra,0xffffd
    800059cc:	120080e7          	jalr	288(ra) # 80002ae8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059d0:	08000613          	li	a2,128
    800059d4:	f4040593          	addi	a1,s0,-192
    800059d8:	4501                	li	a0,0
    800059da:	ffffd097          	auipc	ra,0xffffd
    800059de:	12e080e7          	jalr	302(ra) # 80002b08 <argstr>
    800059e2:	87aa                	mv	a5,a0
    return -1;
    800059e4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800059e6:	0c07c263          	bltz	a5,80005aaa <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800059ea:	10000613          	li	a2,256
    800059ee:	4581                	li	a1,0
    800059f0:	e4040513          	addi	a0,s0,-448
    800059f4:	ffffb097          	auipc	ra,0xffffb
    800059f8:	2de080e7          	jalr	734(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059fc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a00:	89a6                	mv	s3,s1
    80005a02:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a04:	02000a13          	li	s4,32
    80005a08:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a0c:	00391793          	slli	a5,s2,0x3
    80005a10:	e3040593          	addi	a1,s0,-464
    80005a14:	e3843503          	ld	a0,-456(s0)
    80005a18:	953e                	add	a0,a0,a5
    80005a1a:	ffffd097          	auipc	ra,0xffffd
    80005a1e:	010080e7          	jalr	16(ra) # 80002a2a <fetchaddr>
    80005a22:	02054a63          	bltz	a0,80005a56 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005a26:	e3043783          	ld	a5,-464(s0)
    80005a2a:	c3b9                	beqz	a5,80005a70 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a2c:	ffffb097          	auipc	ra,0xffffb
    80005a30:	0ba080e7          	jalr	186(ra) # 80000ae6 <kalloc>
    80005a34:	85aa                	mv	a1,a0
    80005a36:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a3a:	cd11                	beqz	a0,80005a56 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a3c:	6605                	lui	a2,0x1
    80005a3e:	e3043503          	ld	a0,-464(s0)
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	03a080e7          	jalr	58(ra) # 80002a7c <fetchstr>
    80005a4a:	00054663          	bltz	a0,80005a56 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a4e:	0905                	addi	s2,s2,1
    80005a50:	09a1                	addi	s3,s3,8
    80005a52:	fb491be3          	bne	s2,s4,80005a08 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a56:	10048913          	addi	s2,s1,256
    80005a5a:	6088                	ld	a0,0(s1)
    80005a5c:	c531                	beqz	a0,80005aa8 <sys_exec+0xf8>
    kfree(argv[i]);
    80005a5e:	ffffb097          	auipc	ra,0xffffb
    80005a62:	f8c080e7          	jalr	-116(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a66:	04a1                	addi	s1,s1,8
    80005a68:	ff2499e3          	bne	s1,s2,80005a5a <sys_exec+0xaa>
  return -1;
    80005a6c:	557d                	li	a0,-1
    80005a6e:	a835                	j	80005aaa <sys_exec+0xfa>
      argv[i] = 0;
    80005a70:	0a8e                	slli	s5,s5,0x3
    80005a72:	fc040793          	addi	a5,s0,-64
    80005a76:	9abe                	add	s5,s5,a5
    80005a78:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a7c:	e4040593          	addi	a1,s0,-448
    80005a80:	f4040513          	addi	a0,s0,-192
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	172080e7          	jalr	370(ra) # 80004bf6 <exec>
    80005a8c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a8e:	10048993          	addi	s3,s1,256
    80005a92:	6088                	ld	a0,0(s1)
    80005a94:	c901                	beqz	a0,80005aa4 <sys_exec+0xf4>
    kfree(argv[i]);
    80005a96:	ffffb097          	auipc	ra,0xffffb
    80005a9a:	f54080e7          	jalr	-172(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a9e:	04a1                	addi	s1,s1,8
    80005aa0:	ff3499e3          	bne	s1,s3,80005a92 <sys_exec+0xe2>
  return ret;
    80005aa4:	854a                	mv	a0,s2
    80005aa6:	a011                	j	80005aaa <sys_exec+0xfa>
  return -1;
    80005aa8:	557d                	li	a0,-1
}
    80005aaa:	60be                	ld	ra,456(sp)
    80005aac:	641e                	ld	s0,448(sp)
    80005aae:	74fa                	ld	s1,440(sp)
    80005ab0:	795a                	ld	s2,432(sp)
    80005ab2:	79ba                	ld	s3,424(sp)
    80005ab4:	7a1a                	ld	s4,416(sp)
    80005ab6:	6afa                	ld	s5,408(sp)
    80005ab8:	6179                	addi	sp,sp,464
    80005aba:	8082                	ret

0000000080005abc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005abc:	7139                	addi	sp,sp,-64
    80005abe:	fc06                	sd	ra,56(sp)
    80005ac0:	f822                	sd	s0,48(sp)
    80005ac2:	f426                	sd	s1,40(sp)
    80005ac4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ac6:	ffffc097          	auipc	ra,0xffffc
    80005aca:	eee080e7          	jalr	-274(ra) # 800019b4 <myproc>
    80005ace:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ad0:	fd840593          	addi	a1,s0,-40
    80005ad4:	4501                	li	a0,0
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	012080e7          	jalr	18(ra) # 80002ae8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ade:	fc840593          	addi	a1,s0,-56
    80005ae2:	fd040513          	addi	a0,s0,-48
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	dc6080e7          	jalr	-570(ra) # 800048ac <pipealloc>
    return -1;
    80005aee:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005af0:	0c054463          	bltz	a0,80005bb8 <sys_pipe+0xfc>
  fd0 = -1;
    80005af4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005af8:	fd043503          	ld	a0,-48(s0)
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	51a080e7          	jalr	1306(ra) # 80005016 <fdalloc>
    80005b04:	fca42223          	sw	a0,-60(s0)
    80005b08:	08054b63          	bltz	a0,80005b9e <sys_pipe+0xe2>
    80005b0c:	fc843503          	ld	a0,-56(s0)
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	506080e7          	jalr	1286(ra) # 80005016 <fdalloc>
    80005b18:	fca42023          	sw	a0,-64(s0)
    80005b1c:	06054863          	bltz	a0,80005b8c <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b20:	4691                	li	a3,4
    80005b22:	fc440613          	addi	a2,s0,-60
    80005b26:	fd843583          	ld	a1,-40(s0)
    80005b2a:	68a8                	ld	a0,80(s1)
    80005b2c:	ffffc097          	auipc	ra,0xffffc
    80005b30:	b3c080e7          	jalr	-1220(ra) # 80001668 <copyout>
    80005b34:	02054063          	bltz	a0,80005b54 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b38:	4691                	li	a3,4
    80005b3a:	fc040613          	addi	a2,s0,-64
    80005b3e:	fd843583          	ld	a1,-40(s0)
    80005b42:	0591                	addi	a1,a1,4
    80005b44:	68a8                	ld	a0,80(s1)
    80005b46:	ffffc097          	auipc	ra,0xffffc
    80005b4a:	b22080e7          	jalr	-1246(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b4e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b50:	06055463          	bgez	a0,80005bb8 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b54:	fc442783          	lw	a5,-60(s0)
    80005b58:	07e9                	addi	a5,a5,26
    80005b5a:	078e                	slli	a5,a5,0x3
    80005b5c:	97a6                	add	a5,a5,s1
    80005b5e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b62:	fc042503          	lw	a0,-64(s0)
    80005b66:	0569                	addi	a0,a0,26
    80005b68:	050e                	slli	a0,a0,0x3
    80005b6a:	94aa                	add	s1,s1,a0
    80005b6c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b70:	fd043503          	ld	a0,-48(s0)
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	a08080e7          	jalr	-1528(ra) # 8000457c <fileclose>
    fileclose(wf);
    80005b7c:	fc843503          	ld	a0,-56(s0)
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	9fc080e7          	jalr	-1540(ra) # 8000457c <fileclose>
    return -1;
    80005b88:	57fd                	li	a5,-1
    80005b8a:	a03d                	j	80005bb8 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b8c:	fc442783          	lw	a5,-60(s0)
    80005b90:	0007c763          	bltz	a5,80005b9e <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b94:	07e9                	addi	a5,a5,26
    80005b96:	078e                	slli	a5,a5,0x3
    80005b98:	94be                	add	s1,s1,a5
    80005b9a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b9e:	fd043503          	ld	a0,-48(s0)
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	9da080e7          	jalr	-1574(ra) # 8000457c <fileclose>
    fileclose(wf);
    80005baa:	fc843503          	ld	a0,-56(s0)
    80005bae:	fffff097          	auipc	ra,0xfffff
    80005bb2:	9ce080e7          	jalr	-1586(ra) # 8000457c <fileclose>
    return -1;
    80005bb6:	57fd                	li	a5,-1
}
    80005bb8:	853e                	mv	a0,a5
    80005bba:	70e2                	ld	ra,56(sp)
    80005bbc:	7442                	ld	s0,48(sp)
    80005bbe:	74a2                	ld	s1,40(sp)
    80005bc0:	6121                	addi	sp,sp,64
    80005bc2:	8082                	ret
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
    80005c10:	ce7fc0ef          	jal	ra,800028f6 <kerneltrap>
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
    80005cca:	953e                	add	a0,a0,a5
    80005ccc:	00052023          	sw	zero,0(a0)
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
    80005ce8:	00d5179b          	slliw	a5,a0,0xd
    80005cec:	0c201537          	lui	a0,0xc201
    80005cf0:	953e                	add	a0,a0,a5
  return irq;
}
    80005cf2:	4148                	lw	a0,4(a0)
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
    80005d38:	eec78793          	addi	a5,a5,-276 # 80021c20 <disk>
    80005d3c:	97aa                	add	a5,a5,a0
    80005d3e:	0187c783          	lbu	a5,24(a5)
    80005d42:	ebb9                	bnez	a5,80005d98 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d44:	00451613          	slli	a2,a0,0x4
    80005d48:	0001c797          	auipc	a5,0x1c
    80005d4c:	ed878793          	addi	a5,a5,-296 # 80021c20 <disk>
    80005d50:	6394                	ld	a3,0(a5)
    80005d52:	96b2                	add	a3,a3,a2
    80005d54:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d58:	6398                	ld	a4,0(a5)
    80005d5a:	9732                	add	a4,a4,a2
    80005d5c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d60:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d64:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d68:	953e                	add	a0,a0,a5
    80005d6a:	4785                	li	a5,1
    80005d6c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005d70:	0001c517          	auipc	a0,0x1c
    80005d74:	ec850513          	addi	a0,a0,-312 # 80021c38 <disk+0x18>
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
    80005d94:	7ae080e7          	jalr	1966(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005d98:	00003517          	auipc	a0,0x3
    80005d9c:	9d850513          	addi	a0,a0,-1576 # 80008770 <syscalls+0x320>
    80005da0:	ffffa097          	auipc	ra,0xffffa
    80005da4:	79e080e7          	jalr	1950(ra) # 8000053e <panic>

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
    80005dc0:	f8c50513          	addi	a0,a0,-116 # 80021d48 <disk+0x128>
    80005dc4:	ffffb097          	auipc	ra,0xffffb
    80005dc8:	d82080e7          	jalr	-638(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dcc:	100017b7          	lui	a5,0x10001
    80005dd0:	4398                	lw	a4,0(a5)
    80005dd2:	2701                	sext.w	a4,a4
    80005dd4:	747277b7          	lui	a5,0x74727
    80005dd8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ddc:	14f71c63          	bne	a4,a5,80005f34 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005de0:	100017b7          	lui	a5,0x10001
    80005de4:	43dc                	lw	a5,4(a5)
    80005de6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005de8:	4709                	li	a4,2
    80005dea:	14e79563          	bne	a5,a4,80005f34 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dee:	100017b7          	lui	a5,0x10001
    80005df2:	479c                	lw	a5,8(a5)
    80005df4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005df6:	12e79f63          	bne	a5,a4,80005f34 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005dfa:	100017b7          	lui	a5,0x10001
    80005dfe:	47d8                	lw	a4,12(a5)
    80005e00:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e02:	554d47b7          	lui	a5,0x554d4
    80005e06:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e0a:	12f71563          	bne	a4,a5,80005f34 <virtio_disk_init+0x18c>
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
    80005e1e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e20:	c7ffe737          	lui	a4,0xc7ffe
    80005e24:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc90f>
    80005e28:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e2a:	2701                	sext.w	a4,a4
    80005e2c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e2e:	472d                	li	a4,11
    80005e30:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e32:	5bbc                	lw	a5,112(a5)
    80005e34:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e38:	8ba1                	andi	a5,a5,8
    80005e3a:	10078563          	beqz	a5,80005f44 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e3e:	100017b7          	lui	a5,0x10001
    80005e42:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e46:	43fc                	lw	a5,68(a5)
    80005e48:	2781                	sext.w	a5,a5
    80005e4a:	10079563          	bnez	a5,80005f54 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e4e:	100017b7          	lui	a5,0x10001
    80005e52:	5bdc                	lw	a5,52(a5)
    80005e54:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e56:	10078763          	beqz	a5,80005f64 <virtio_disk_init+0x1bc>
  if(max < NUM)
    80005e5a:	471d                	li	a4,7
    80005e5c:	10f77c63          	bgeu	a4,a5,80005f74 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	c86080e7          	jalr	-890(ra) # 80000ae6 <kalloc>
    80005e68:	0001c497          	auipc	s1,0x1c
    80005e6c:	db848493          	addi	s1,s1,-584 # 80021c20 <disk>
    80005e70:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	c74080e7          	jalr	-908(ra) # 80000ae6 <kalloc>
    80005e7a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e7c:	ffffb097          	auipc	ra,0xffffb
    80005e80:	c6a080e7          	jalr	-918(ra) # 80000ae6 <kalloc>
    80005e84:	87aa                	mv	a5,a0
    80005e86:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e88:	6088                	ld	a0,0(s1)
    80005e8a:	cd6d                	beqz	a0,80005f84 <virtio_disk_init+0x1dc>
    80005e8c:	0001c717          	auipc	a4,0x1c
    80005e90:	d9c73703          	ld	a4,-612(a4) # 80021c28 <disk+0x8>
    80005e94:	cb65                	beqz	a4,80005f84 <virtio_disk_init+0x1dc>
    80005e96:	c7fd                	beqz	a5,80005f84 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005e98:	6605                	lui	a2,0x1
    80005e9a:	4581                	li	a1,0
    80005e9c:	ffffb097          	auipc	ra,0xffffb
    80005ea0:	e36080e7          	jalr	-458(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ea4:	0001c497          	auipc	s1,0x1c
    80005ea8:	d7c48493          	addi	s1,s1,-644 # 80021c20 <disk>
    80005eac:	6605                	lui	a2,0x1
    80005eae:	4581                	li	a1,0
    80005eb0:	6488                	ld	a0,8(s1)
    80005eb2:	ffffb097          	auipc	ra,0xffffb
    80005eb6:	e20080e7          	jalr	-480(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005eba:	6605                	lui	a2,0x1
    80005ebc:	4581                	li	a1,0
    80005ebe:	6888                	ld	a0,16(s1)
    80005ec0:	ffffb097          	auipc	ra,0xffffb
    80005ec4:	e12080e7          	jalr	-494(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ec8:	100017b7          	lui	a5,0x10001
    80005ecc:	4721                	li	a4,8
    80005ece:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ed0:	4098                	lw	a4,0(s1)
    80005ed2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ed6:	40d8                	lw	a4,4(s1)
    80005ed8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005edc:	6498                	ld	a4,8(s1)
    80005ede:	0007069b          	sext.w	a3,a4
    80005ee2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005ee6:	9701                	srai	a4,a4,0x20
    80005ee8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005eec:	6898                	ld	a4,16(s1)
    80005eee:	0007069b          	sext.w	a3,a4
    80005ef2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ef6:	9701                	srai	a4,a4,0x20
    80005ef8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005efc:	4705                	li	a4,1
    80005efe:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f00:	00e48c23          	sb	a4,24(s1)
    80005f04:	00e48ca3          	sb	a4,25(s1)
    80005f08:	00e48d23          	sb	a4,26(s1)
    80005f0c:	00e48da3          	sb	a4,27(s1)
    80005f10:	00e48e23          	sb	a4,28(s1)
    80005f14:	00e48ea3          	sb	a4,29(s1)
    80005f18:	00e48f23          	sb	a4,30(s1)
    80005f1c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f20:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f24:	0727a823          	sw	s2,112(a5)
}
    80005f28:	60e2                	ld	ra,24(sp)
    80005f2a:	6442                	ld	s0,16(sp)
    80005f2c:	64a2                	ld	s1,8(sp)
    80005f2e:	6902                	ld	s2,0(sp)
    80005f30:	6105                	addi	sp,sp,32
    80005f32:	8082                	ret
    panic("could not find virtio disk");
    80005f34:	00003517          	auipc	a0,0x3
    80005f38:	85c50513          	addi	a0,a0,-1956 # 80008790 <syscalls+0x340>
    80005f3c:	ffffa097          	auipc	ra,0xffffa
    80005f40:	602080e7          	jalr	1538(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f44:	00003517          	auipc	a0,0x3
    80005f48:	86c50513          	addi	a0,a0,-1940 # 800087b0 <syscalls+0x360>
    80005f4c:	ffffa097          	auipc	ra,0xffffa
    80005f50:	5f2080e7          	jalr	1522(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80005f54:	00003517          	auipc	a0,0x3
    80005f58:	87c50513          	addi	a0,a0,-1924 # 800087d0 <syscalls+0x380>
    80005f5c:	ffffa097          	auipc	ra,0xffffa
    80005f60:	5e2080e7          	jalr	1506(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80005f64:	00003517          	auipc	a0,0x3
    80005f68:	88c50513          	addi	a0,a0,-1908 # 800087f0 <syscalls+0x3a0>
    80005f6c:	ffffa097          	auipc	ra,0xffffa
    80005f70:	5d2080e7          	jalr	1490(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80005f74:	00003517          	auipc	a0,0x3
    80005f78:	89c50513          	addi	a0,a0,-1892 # 80008810 <syscalls+0x3c0>
    80005f7c:	ffffa097          	auipc	ra,0xffffa
    80005f80:	5c2080e7          	jalr	1474(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80005f84:	00003517          	auipc	a0,0x3
    80005f88:	8ac50513          	addi	a0,a0,-1876 # 80008830 <syscalls+0x3e0>
    80005f8c:	ffffa097          	auipc	ra,0xffffa
    80005f90:	5b2080e7          	jalr	1458(ra) # 8000053e <panic>

0000000080005f94 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f94:	7119                	addi	sp,sp,-128
    80005f96:	fc86                	sd	ra,120(sp)
    80005f98:	f8a2                	sd	s0,112(sp)
    80005f9a:	f4a6                	sd	s1,104(sp)
    80005f9c:	f0ca                	sd	s2,96(sp)
    80005f9e:	ecce                	sd	s3,88(sp)
    80005fa0:	e8d2                	sd	s4,80(sp)
    80005fa2:	e4d6                	sd	s5,72(sp)
    80005fa4:	e0da                	sd	s6,64(sp)
    80005fa6:	fc5e                	sd	s7,56(sp)
    80005fa8:	f862                	sd	s8,48(sp)
    80005faa:	f466                	sd	s9,40(sp)
    80005fac:	f06a                	sd	s10,32(sp)
    80005fae:	ec6e                	sd	s11,24(sp)
    80005fb0:	0100                	addi	s0,sp,128
    80005fb2:	8aaa                	mv	s5,a0
    80005fb4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fb6:	00c52d03          	lw	s10,12(a0)
    80005fba:	001d1d1b          	slliw	s10,s10,0x1
    80005fbe:	1d02                	slli	s10,s10,0x20
    80005fc0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005fc4:	0001c517          	auipc	a0,0x1c
    80005fc8:	d8450513          	addi	a0,a0,-636 # 80021d48 <disk+0x128>
    80005fcc:	ffffb097          	auipc	ra,0xffffb
    80005fd0:	c0a080e7          	jalr	-1014(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005fd4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fd6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fd8:	0001cb97          	auipc	s7,0x1c
    80005fdc:	c48b8b93          	addi	s7,s7,-952 # 80021c20 <disk>
  for(int i = 0; i < 3; i++){
    80005fe0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fe2:	0001cc97          	auipc	s9,0x1c
    80005fe6:	d66c8c93          	addi	s9,s9,-666 # 80021d48 <disk+0x128>
    80005fea:	a08d                	j	8000604c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005fec:	00fb8733          	add	a4,s7,a5
    80005ff0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ff4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ff6:	0207c563          	bltz	a5,80006020 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005ffa:	2905                	addiw	s2,s2,1
    80005ffc:	0611                	addi	a2,a2,4
    80005ffe:	05690c63          	beq	s2,s6,80006056 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006002:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006004:	0001c717          	auipc	a4,0x1c
    80006008:	c1c70713          	addi	a4,a4,-996 # 80021c20 <disk>
    8000600c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000600e:	01874683          	lbu	a3,24(a4)
    80006012:	fee9                	bnez	a3,80005fec <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006014:	2785                	addiw	a5,a5,1
    80006016:	0705                	addi	a4,a4,1
    80006018:	fe979be3          	bne	a5,s1,8000600e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000601c:	57fd                	li	a5,-1
    8000601e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006020:	01205d63          	blez	s2,8000603a <virtio_disk_rw+0xa6>
    80006024:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006026:	000a2503          	lw	a0,0(s4)
    8000602a:	00000097          	auipc	ra,0x0
    8000602e:	cfc080e7          	jalr	-772(ra) # 80005d26 <free_desc>
      for(int j = 0; j < i; j++)
    80006032:	2d85                	addiw	s11,s11,1
    80006034:	0a11                	addi	s4,s4,4
    80006036:	ffb918e3          	bne	s2,s11,80006026 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000603a:	85e6                	mv	a1,s9
    8000603c:	0001c517          	auipc	a0,0x1c
    80006040:	bfc50513          	addi	a0,a0,-1028 # 80021c38 <disk+0x18>
    80006044:	ffffc097          	auipc	ra,0xffffc
    80006048:	018080e7          	jalr	24(ra) # 8000205c <sleep>
  for(int i = 0; i < 3; i++){
    8000604c:	f8040a13          	addi	s4,s0,-128
{
    80006050:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006052:	894e                	mv	s2,s3
    80006054:	b77d                	j	80006002 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006056:	f8042583          	lw	a1,-128(s0)
    8000605a:	00a58793          	addi	a5,a1,10
    8000605e:	0792                	slli	a5,a5,0x4

  if(write)
    80006060:	0001c617          	auipc	a2,0x1c
    80006064:	bc060613          	addi	a2,a2,-1088 # 80021c20 <disk>
    80006068:	00f60733          	add	a4,a2,a5
    8000606c:	018036b3          	snez	a3,s8
    80006070:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006072:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006076:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000607a:	f6078693          	addi	a3,a5,-160
    8000607e:	6218                	ld	a4,0(a2)
    80006080:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006082:	00878513          	addi	a0,a5,8
    80006086:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006088:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000608a:	6208                	ld	a0,0(a2)
    8000608c:	96aa                	add	a3,a3,a0
    8000608e:	4741                	li	a4,16
    80006090:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006092:	4705                	li	a4,1
    80006094:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006098:	f8442703          	lw	a4,-124(s0)
    8000609c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060a0:	0712                	slli	a4,a4,0x4
    800060a2:	953a                	add	a0,a0,a4
    800060a4:	058a8693          	addi	a3,s5,88
    800060a8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800060aa:	6208                	ld	a0,0(a2)
    800060ac:	972a                	add	a4,a4,a0
    800060ae:	40000693          	li	a3,1024
    800060b2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800060b4:	001c3c13          	seqz	s8,s8
    800060b8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060ba:	001c6c13          	ori	s8,s8,1
    800060be:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800060c2:	f8842603          	lw	a2,-120(s0)
    800060c6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060ca:	0001c697          	auipc	a3,0x1c
    800060ce:	b5668693          	addi	a3,a3,-1194 # 80021c20 <disk>
    800060d2:	00258713          	addi	a4,a1,2
    800060d6:	0712                	slli	a4,a4,0x4
    800060d8:	9736                	add	a4,a4,a3
    800060da:	587d                	li	a6,-1
    800060dc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060e0:	0612                	slli	a2,a2,0x4
    800060e2:	9532                	add	a0,a0,a2
    800060e4:	f9078793          	addi	a5,a5,-112
    800060e8:	97b6                	add	a5,a5,a3
    800060ea:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800060ec:	629c                	ld	a5,0(a3)
    800060ee:	97b2                	add	a5,a5,a2
    800060f0:	4605                	li	a2,1
    800060f2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060f4:	4509                	li	a0,2
    800060f6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800060fa:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060fe:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006102:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006106:	6698                	ld	a4,8(a3)
    80006108:	00275783          	lhu	a5,2(a4)
    8000610c:	8b9d                	andi	a5,a5,7
    8000610e:	0786                	slli	a5,a5,0x1
    80006110:	97ba                	add	a5,a5,a4
    80006112:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006116:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000611a:	6698                	ld	a4,8(a3)
    8000611c:	00275783          	lhu	a5,2(a4)
    80006120:	2785                	addiw	a5,a5,1
    80006122:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006126:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000612a:	100017b7          	lui	a5,0x10001
    8000612e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006132:	004aa783          	lw	a5,4(s5)
    80006136:	02c79163          	bne	a5,a2,80006158 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000613a:	0001c917          	auipc	s2,0x1c
    8000613e:	c0e90913          	addi	s2,s2,-1010 # 80021d48 <disk+0x128>
  while(b->disk == 1) {
    80006142:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006144:	85ca                	mv	a1,s2
    80006146:	8556                	mv	a0,s5
    80006148:	ffffc097          	auipc	ra,0xffffc
    8000614c:	f14080e7          	jalr	-236(ra) # 8000205c <sleep>
  while(b->disk == 1) {
    80006150:	004aa783          	lw	a5,4(s5)
    80006154:	fe9788e3          	beq	a5,s1,80006144 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006158:	f8042903          	lw	s2,-128(s0)
    8000615c:	00290793          	addi	a5,s2,2
    80006160:	00479713          	slli	a4,a5,0x4
    80006164:	0001c797          	auipc	a5,0x1c
    80006168:	abc78793          	addi	a5,a5,-1348 # 80021c20 <disk>
    8000616c:	97ba                	add	a5,a5,a4
    8000616e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006172:	0001c997          	auipc	s3,0x1c
    80006176:	aae98993          	addi	s3,s3,-1362 # 80021c20 <disk>
    8000617a:	00491713          	slli	a4,s2,0x4
    8000617e:	0009b783          	ld	a5,0(s3)
    80006182:	97ba                	add	a5,a5,a4
    80006184:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006188:	854a                	mv	a0,s2
    8000618a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000618e:	00000097          	auipc	ra,0x0
    80006192:	b98080e7          	jalr	-1128(ra) # 80005d26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006196:	8885                	andi	s1,s1,1
    80006198:	f0ed                	bnez	s1,8000617a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000619a:	0001c517          	auipc	a0,0x1c
    8000619e:	bae50513          	addi	a0,a0,-1106 # 80021d48 <disk+0x128>
    800061a2:	ffffb097          	auipc	ra,0xffffb
    800061a6:	ae8080e7          	jalr	-1304(ra) # 80000c8a <release>
}
    800061aa:	70e6                	ld	ra,120(sp)
    800061ac:	7446                	ld	s0,112(sp)
    800061ae:	74a6                	ld	s1,104(sp)
    800061b0:	7906                	ld	s2,96(sp)
    800061b2:	69e6                	ld	s3,88(sp)
    800061b4:	6a46                	ld	s4,80(sp)
    800061b6:	6aa6                	ld	s5,72(sp)
    800061b8:	6b06                	ld	s6,64(sp)
    800061ba:	7be2                	ld	s7,56(sp)
    800061bc:	7c42                	ld	s8,48(sp)
    800061be:	7ca2                	ld	s9,40(sp)
    800061c0:	7d02                	ld	s10,32(sp)
    800061c2:	6de2                	ld	s11,24(sp)
    800061c4:	6109                	addi	sp,sp,128
    800061c6:	8082                	ret

00000000800061c8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061c8:	1101                	addi	sp,sp,-32
    800061ca:	ec06                	sd	ra,24(sp)
    800061cc:	e822                	sd	s0,16(sp)
    800061ce:	e426                	sd	s1,8(sp)
    800061d0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061d2:	0001c497          	auipc	s1,0x1c
    800061d6:	a4e48493          	addi	s1,s1,-1458 # 80021c20 <disk>
    800061da:	0001c517          	auipc	a0,0x1c
    800061de:	b6e50513          	addi	a0,a0,-1170 # 80021d48 <disk+0x128>
    800061e2:	ffffb097          	auipc	ra,0xffffb
    800061e6:	9f4080e7          	jalr	-1548(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061ea:	10001737          	lui	a4,0x10001
    800061ee:	533c                	lw	a5,96(a4)
    800061f0:	8b8d                	andi	a5,a5,3
    800061f2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061f4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061f8:	689c                	ld	a5,16(s1)
    800061fa:	0204d703          	lhu	a4,32(s1)
    800061fe:	0027d783          	lhu	a5,2(a5)
    80006202:	04f70863          	beq	a4,a5,80006252 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006206:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000620a:	6898                	ld	a4,16(s1)
    8000620c:	0204d783          	lhu	a5,32(s1)
    80006210:	8b9d                	andi	a5,a5,7
    80006212:	078e                	slli	a5,a5,0x3
    80006214:	97ba                	add	a5,a5,a4
    80006216:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006218:	00278713          	addi	a4,a5,2
    8000621c:	0712                	slli	a4,a4,0x4
    8000621e:	9726                	add	a4,a4,s1
    80006220:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006224:	e721                	bnez	a4,8000626c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006226:	0789                	addi	a5,a5,2
    80006228:	0792                	slli	a5,a5,0x4
    8000622a:	97a6                	add	a5,a5,s1
    8000622c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000622e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006232:	ffffc097          	auipc	ra,0xffffc
    80006236:	e8e080e7          	jalr	-370(ra) # 800020c0 <wakeup>

    disk.used_idx += 1;
    8000623a:	0204d783          	lhu	a5,32(s1)
    8000623e:	2785                	addiw	a5,a5,1
    80006240:	17c2                	slli	a5,a5,0x30
    80006242:	93c1                	srli	a5,a5,0x30
    80006244:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006248:	6898                	ld	a4,16(s1)
    8000624a:	00275703          	lhu	a4,2(a4)
    8000624e:	faf71ce3          	bne	a4,a5,80006206 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006252:	0001c517          	auipc	a0,0x1c
    80006256:	af650513          	addi	a0,a0,-1290 # 80021d48 <disk+0x128>
    8000625a:	ffffb097          	auipc	ra,0xffffb
    8000625e:	a30080e7          	jalr	-1488(ra) # 80000c8a <release>
}
    80006262:	60e2                	ld	ra,24(sp)
    80006264:	6442                	ld	s0,16(sp)
    80006266:	64a2                	ld	s1,8(sp)
    80006268:	6105                	addi	sp,sp,32
    8000626a:	8082                	ret
      panic("virtio_disk_intr status");
    8000626c:	00002517          	auipc	a0,0x2
    80006270:	5dc50513          	addi	a0,a0,1500 # 80008848 <syscalls+0x3f8>
    80006274:	ffffa097          	auipc	ra,0xffffa
    80006278:	2ca080e7          	jalr	714(ra) # 8000053e <panic>

000000008000627c <petersonlock_init>:
#include "proc.h" // בשביל yield()

struct peterson_lock peterson_locks[MAX_PETERSON_LOCKS];

void
petersonlock_init() {
    8000627c:	1141                	addi	sp,sp,-16
    8000627e:	e422                	sd	s0,8(sp)
    80006280:	0800                	addi	s0,sp,16
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    80006282:	0001c797          	auipc	a5,0x1c
    80006286:	ade78793          	addi	a5,a5,-1314 # 80021d60 <peterson_locks>
    8000628a:	0001c717          	auipc	a4,0x1c
    8000628e:	bc670713          	addi	a4,a4,-1082 # 80021e50 <end>
        peterson_locks[i].active = 0;
    80006292:	0007a023          	sw	zero,0(a5)
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    80006296:	07c1                	addi	a5,a5,16
    80006298:	fee79de3          	bne	a5,a4,80006292 <petersonlock_init+0x16>
    }
}
    8000629c:	6422                	ld	s0,8(sp)
    8000629e:	0141                	addi	sp,sp,16
    800062a0:	8082                	ret

00000000800062a2 <petersonlock_create>:

int
petersonlock_create() {
    800062a2:	1141                	addi	sp,sp,-16
    800062a4:	e422                	sd	s0,8(sp)
    800062a6:	0800                	addi	s0,sp,16
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    800062a8:	0001c797          	auipc	a5,0x1c
    800062ac:	ab878793          	addi	a5,a5,-1352 # 80021d60 <peterson_locks>
    800062b0:	4501                	li	a0,0
    800062b2:	46bd                	li	a3,15
        if (peterson_locks[i].active == 0) {
    800062b4:	4398                	lw	a4,0(a5)
    800062b6:	cb09                	beqz	a4,800062c8 <petersonlock_create+0x26>
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
    800062b8:	2505                	addiw	a0,a0,1
    800062ba:	07c1                	addi	a5,a5,16
    800062bc:	fed51ce3          	bne	a0,a3,800062b4 <petersonlock_create+0x12>
            peterson_locks[i].flag[1] = 0;
            peterson_locks[i].turn = 0;
            return i;
        }
    }
    return -1;
    800062c0:	557d                	li	a0,-1
}
    800062c2:	6422                	ld	s0,8(sp)
    800062c4:	0141                	addi	sp,sp,16
    800062c6:	8082                	ret
            peterson_locks[i].active = 1;
    800062c8:	00451713          	slli	a4,a0,0x4
    800062cc:	0001c797          	auipc	a5,0x1c
    800062d0:	a9478793          	addi	a5,a5,-1388 # 80021d60 <peterson_locks>
    800062d4:	97ba                	add	a5,a5,a4
    800062d6:	4705                	li	a4,1
    800062d8:	c398                	sw	a4,0(a5)
            peterson_locks[i].flag[0] = 0;
    800062da:	0007a223          	sw	zero,4(a5)
            peterson_locks[i].flag[1] = 0;
    800062de:	0007a423          	sw	zero,8(a5)
            peterson_locks[i].turn = 0;
    800062e2:	0007a623          	sw	zero,12(a5)
            return i;
    800062e6:	bff1                	j	800062c2 <petersonlock_create+0x20>

00000000800062e8 <petersonlock_acquire>:

int
petersonlock_acquire(int lock_id, int role) {
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
    800062e8:	4739                	li	a4,14
    800062ea:	08a76463          	bltu	a4,a0,80006372 <petersonlock_acquire+0x8a>
    800062ee:	87aa                	mv	a5,a0
    800062f0:	00451693          	slli	a3,a0,0x4
    800062f4:	0001c717          	auipc	a4,0x1c
    800062f8:	a6c70713          	addi	a4,a4,-1428 # 80021d60 <peterson_locks>
    800062fc:	9736                	add	a4,a4,a3
    800062fe:	4318                	lw	a4,0(a4)
    80006300:	cb3d                	beqz	a4,80006376 <petersonlock_acquire+0x8e>
petersonlock_acquire(int lock_id, int role) {
    80006302:	7179                	addi	sp,sp,-48
    80006304:	f406                	sd	ra,40(sp)
    80006306:	f022                	sd	s0,32(sp)
    80006308:	ec26                	sd	s1,24(sp)
    8000630a:	e84a                	sd	s2,16(sp)
    8000630c:	e44e                	sd	s3,8(sp)
    8000630e:	1800                	addi	s0,sp,48
        return -1;

    struct peterson_lock *lock = &peterson_locks[lock_id];
    int other = 1 - role;
    80006310:	4605                	li	a2,1
    80006312:	9e0d                	subw	a2,a2,a1
    80006314:	0006091b          	sext.w	s2,a2

    lock->flag[role] = 1;
    80006318:	0001c697          	auipc	a3,0x1c
    8000631c:	a4868693          	addi	a3,a3,-1464 # 80021d60 <peterson_locks>
    80006320:	00251713          	slli	a4,a0,0x2
    80006324:	95ba                	add	a1,a1,a4
    80006326:	058a                	slli	a1,a1,0x2
    80006328:	95b6                	add	a1,a1,a3
    8000632a:	4505                	li	a0,1
    8000632c:	c1c8                	sw	a0,4(a1)
    __sync_synchronize();
    8000632e:	0ff0000f          	fence
    lock->turn = other;
    80006332:	00479593          	slli	a1,a5,0x4
    80006336:	95b6                	add	a1,a1,a3
    80006338:	c5d0                	sw	a2,12(a1)
    __sync_synchronize();
    8000633a:	0ff0000f          	fence

    while (lock->flag[other] && lock->turn == other) {
    8000633e:	974a                	add	a4,a4,s2
    80006340:	070a                	slli	a4,a4,0x2
    80006342:	9736                	add	a4,a4,a3
    80006344:	4348                	lw	a0,4(a4)
    80006346:	cd19                	beqz	a0,80006364 <petersonlock_acquire+0x7c>
    80006348:	89ae                	mv	s3,a1
    8000634a:	84ba                	mv	s1,a4
    8000634c:	00c9a783          	lw	a5,12(s3)
    80006350:	01279963          	bne	a5,s2,80006362 <petersonlock_acquire+0x7a>
        yield();
    80006354:	ffffc097          	auipc	ra,0xffffc
    80006358:	ccc080e7          	jalr	-820(ra) # 80002020 <yield>
    while (lock->flag[other] && lock->turn == other) {
    8000635c:	40c8                	lw	a0,4(s1)
    8000635e:	f57d                	bnez	a0,8000634c <petersonlock_acquire+0x64>
    80006360:	a011                	j	80006364 <petersonlock_acquire+0x7c>
    }

    return 0;
    80006362:	4501                	li	a0,0
}
    80006364:	70a2                	ld	ra,40(sp)
    80006366:	7402                	ld	s0,32(sp)
    80006368:	64e2                	ld	s1,24(sp)
    8000636a:	6942                	ld	s2,16(sp)
    8000636c:	69a2                	ld	s3,8(sp)
    8000636e:	6145                	addi	sp,sp,48
    80006370:	8082                	ret
        return -1;
    80006372:	557d                	li	a0,-1
    80006374:	8082                	ret
    80006376:	557d                	li	a0,-1
}
    80006378:	8082                	ret

000000008000637a <petersonlock_release>:

int
petersonlock_release(int lock_id, int role) {
    8000637a:	1141                	addi	sp,sp,-16
    8000637c:	e422                	sd	s0,8(sp)
    8000637e:	0800                	addi	s0,sp,16
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
    80006380:	4739                	li	a4,14
    80006382:	02a76e63          	bltu	a4,a0,800063be <petersonlock_release+0x44>
    80006386:	00451693          	slli	a3,a0,0x4
    8000638a:	0001c717          	auipc	a4,0x1c
    8000638e:	9d670713          	addi	a4,a4,-1578 # 80021d60 <peterson_locks>
    80006392:	9736                	add	a4,a4,a3
    80006394:	4318                	lw	a4,0(a4)
    80006396:	c715                	beqz	a4,800063c2 <petersonlock_release+0x48>
        return -1;

    struct peterson_lock *lock = &peterson_locks[lock_id];

    __sync_synchronize();
    80006398:	0ff0000f          	fence
    lock->flag[role] = 0;
    8000639c:	00251793          	slli	a5,a0,0x2
    800063a0:	97ae                	add	a5,a5,a1
    800063a2:	078a                	slli	a5,a5,0x2
    800063a4:	0001c717          	auipc	a4,0x1c
    800063a8:	9bc70713          	addi	a4,a4,-1604 # 80021d60 <peterson_locks>
    800063ac:	97ba                	add	a5,a5,a4
    800063ae:	0007a223          	sw	zero,4(a5)
    __sync_synchronize();
    800063b2:	0ff0000f          	fence

    return 0;
    800063b6:	4501                	li	a0,0
}
    800063b8:	6422                	ld	s0,8(sp)
    800063ba:	0141                	addi	sp,sp,16
    800063bc:	8082                	ret
        return -1;
    800063be:	557d                	li	a0,-1
    800063c0:	bfe5                	j	800063b8 <petersonlock_release+0x3e>
    800063c2:	557d                	li	a0,-1
    800063c4:	bfd5                	j	800063b8 <petersonlock_release+0x3e>

00000000800063c6 <petersonlock_destroy>:

int
petersonlock_destroy(int lock_id) {
    800063c6:	1141                	addi	sp,sp,-16
    800063c8:	e422                	sd	s0,8(sp)
    800063ca:	0800                	addi	s0,sp,16
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
    800063cc:	4739                	li	a4,14
    800063ce:	02a76763          	bltu	a4,a0,800063fc <petersonlock_destroy+0x36>
    800063d2:	00451693          	slli	a3,a0,0x4
    800063d6:	0001c717          	auipc	a4,0x1c
    800063da:	98a70713          	addi	a4,a4,-1654 # 80021d60 <peterson_locks>
    800063de:	9736                	add	a4,a4,a3
    800063e0:	4318                	lw	a4,0(a4)
    800063e2:	cf19                	beqz	a4,80006400 <petersonlock_destroy+0x3a>
        return -1;

    peterson_locks[lock_id].active = 0;
    800063e4:	0001c717          	auipc	a4,0x1c
    800063e8:	97c70713          	addi	a4,a4,-1668 # 80021d60 <peterson_locks>
    800063ec:	00d707b3          	add	a5,a4,a3
    800063f0:	0007a023          	sw	zero,0(a5)
    return 0;
    800063f4:	4501                	li	a0,0
}
    800063f6:	6422                	ld	s0,8(sp)
    800063f8:	0141                	addi	sp,sp,16
    800063fa:	8082                	ret
        return -1;
    800063fc:	557d                	li	a0,-1
    800063fe:	bfe5                	j	800063f6 <petersonlock_destroy+0x30>
    80006400:	557d                	li	a0,-1
    80006402:	bfd5                	j	800063f6 <petersonlock_destroy+0x30>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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

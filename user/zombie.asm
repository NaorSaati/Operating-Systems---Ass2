
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2a2080e7          	jalr	674(ra) # 2aa <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	29c080e7          	jalr	668(ra) # 2b2 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	322080e7          	jalr	802(ra) # 342 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	276080e7          	jalr	630(ra) # 2b2 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	1141                	addi	sp,sp,-16
  46:	e422                	sd	s0,8(sp)
  48:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4a:	87aa                	mv	a5,a0
  4c:	0585                	addi	a1,a1,1
  4e:	0785                	addi	a5,a5,1
  50:	fff5c703          	lbu	a4,-1(a1)
  54:	fee78fa3          	sb	a4,-1(a5)
  58:	fb75                	bnez	a4,4c <strcpy+0x8>
    ;
  return os;
}
  5a:	6422                	ld	s0,8(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	cb91                	beqz	a5,7e <strcmp+0x1e>
  6c:	0005c703          	lbu	a4,0(a1)
  70:	00f71763          	bne	a4,a5,7e <strcmp+0x1e>
    p++, q++;
  74:	0505                	addi	a0,a0,1
  76:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	fbe5                	bnez	a5,6c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7e:	0005c503          	lbu	a0,0(a1)
}
  82:	40a7853b          	subw	a0,a5,a0
  86:	6422                	ld	s0,8(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  92:	00054783          	lbu	a5,0(a0)
  96:	cf91                	beqz	a5,b2 <strlen+0x26>
  98:	0505                	addi	a0,a0,1
  9a:	87aa                	mv	a5,a0
  9c:	4685                	li	a3,1
  9e:	9e89                	subw	a3,a3,a0
  a0:	00f6853b          	addw	a0,a3,a5
  a4:	0785                	addi	a5,a5,1
  a6:	fff7c703          	lbu	a4,-1(a5)
  aa:	fb7d                	bnez	a4,a0 <strlen+0x14>
    ;
  return n;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret
  for(n = 0; s[n]; n++)
  b2:	4501                	li	a0,0
  b4:	bfe5                	j	ac <strlen+0x20>

00000000000000b6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  bc:	ca19                	beqz	a2,d2 <memset+0x1c>
  be:	87aa                	mv	a5,a0
  c0:	1602                	slli	a2,a2,0x20
  c2:	9201                	srli	a2,a2,0x20
  c4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  cc:	0785                	addi	a5,a5,1
  ce:	fee79de3          	bne	a5,a4,c8 <memset+0x12>
  }
  return dst;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strchr>:

char*
strchr(const char *s, char c)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb99                	beqz	a5,f8 <strchr+0x20>
    if(*s == c)
  e4:	00f58763          	beq	a1,a5,f2 <strchr+0x1a>
  for(; *s; s++)
  e8:	0505                	addi	a0,a0,1
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbfd                	bnez	a5,e4 <strchr+0xc>
      return (char*)s;
  return 0;
  f0:	4501                	li	a0,0
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strchr+0x1a>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	1080                	addi	s0,sp,96
 112:	8baa                	mv	s7,a0
 114:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 116:	892a                	mv	s2,a0
 118:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11a:	4aa9                	li	s5,10
 11c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11e:	89a6                	mv	s3,s1
 120:	2485                	addiw	s1,s1,1
 122:	0344d863          	bge	s1,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 126:	4605                	li	a2,1
 128:	faf40593          	addi	a1,s0,-81
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	19c080e7          	jalr	412(ra) # 2ca <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x56>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x54>
 146:	0905                	addi	s2,s2,1
 148:	fd679be3          	bne	a5,s6,11e <gets+0x22>
  for(i=0; i+1 < max; ){
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x56>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e426                	sd	s1,8(sp)
 178:	e04a                	sd	s2,0(sp)
 17a:	1000                	addi	s0,sp,32
 17c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	4581                	li	a1,0
 180:	00000097          	auipc	ra,0x0
 184:	172080e7          	jalr	370(ra) # 2f2 <open>
  if(fd < 0)
 188:	02054563          	bltz	a0,1b2 <stat+0x42>
 18c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18e:	85ca                	mv	a1,s2
 190:	00000097          	auipc	ra,0x0
 194:	17a080e7          	jalr	378(ra) # 30a <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	00000097          	auipc	ra,0x0
 1a0:	13e080e7          	jalr	318(ra) # 2da <close>
  return r;
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	64a2                	ld	s1,8(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	597d                	li	s2,-1
 1b4:	bfc5                	j	1a4 <stat+0x34>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1bc:	00054603          	lbu	a2,0(a0)
 1c0:	fd06079b          	addiw	a5,a2,-48
 1c4:	0ff7f793          	andi	a5,a5,255
 1c8:	4725                	li	a4,9
 1ca:	02f76963          	bltu	a4,a5,1fc <atoi+0x46>
 1ce:	86aa                	mv	a3,a0
  n = 0;
 1d0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d4:	0685                	addi	a3,a3,1
 1d6:	0025179b          	slliw	a5,a0,0x2
 1da:	9fa9                	addw	a5,a5,a0
 1dc:	0017979b          	slliw	a5,a5,0x1
 1e0:	9fb1                	addw	a5,a5,a2
 1e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e6:	0006c603          	lbu	a2,0(a3)
 1ea:	fd06071b          	addiw	a4,a2,-48
 1ee:	0ff77713          	andi	a4,a4,255
 1f2:	fee5f1e3          	bgeu	a1,a4,1d4 <atoi+0x1e>
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  n = 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <atoi+0x40>

0000000000000200 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 206:	02b57463          	bgeu	a0,a1,22e <memmove+0x2e>
    while(n-- > 0)
 20a:	00c05f63          	blez	a2,228 <memmove+0x28>
 20e:	1602                	slli	a2,a2,0x20
 210:	9201                	srli	a2,a2,0x20
 212:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 216:	872a                	mv	a4,a0
      *dst++ = *src++;
 218:	0585                	addi	a1,a1,1
 21a:	0705                	addi	a4,a4,1
 21c:	fff5c683          	lbu	a3,-1(a1)
 220:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 224:	fee79ae3          	bne	a5,a4,218 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
    dst += n;
 22e:	00c50733          	add	a4,a0,a2
    src += n;
 232:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 234:	fec05ae3          	blez	a2,228 <memmove+0x28>
 238:	fff6079b          	addiw	a5,a2,-1
 23c:	1782                	slli	a5,a5,0x20
 23e:	9381                	srli	a5,a5,0x20
 240:	fff7c793          	not	a5,a5
 244:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 246:	15fd                	addi	a1,a1,-1
 248:	177d                	addi	a4,a4,-1
 24a:	0005c683          	lbu	a3,0(a1)
 24e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 252:	fee79ae3          	bne	a5,a4,246 <memmove+0x46>
 256:	bfc9                	j	228 <memmove+0x28>

0000000000000258 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25e:	ca05                	beqz	a2,28e <memcmp+0x36>
 260:	fff6069b          	addiw	a3,a2,-1
 264:	1682                	slli	a3,a3,0x20
 266:	9281                	srli	a3,a3,0x20
 268:	0685                	addi	a3,a3,1
 26a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26c:	00054783          	lbu	a5,0(a0)
 270:	0005c703          	lbu	a4,0(a1)
 274:	00e79863          	bne	a5,a4,284 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 278:	0505                	addi	a0,a0,1
    p2++;
 27a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27c:	fed518e3          	bne	a0,a3,26c <memcmp+0x14>
  }
  return 0;
 280:	4501                	li	a0,0
 282:	a019                	j	288 <memcmp+0x30>
      return *p1 - *p2;
 284:	40e7853b          	subw	a0,a5,a4
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <memcmp+0x30>

0000000000000292 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e406                	sd	ra,8(sp)
 296:	e022                	sd	s0,0(sp)
 298:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29a:	00000097          	auipc	ra,0x0
 29e:	f66080e7          	jalr	-154(ra) # 200 <memmove>
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2aa:	4885                	li	a7,1
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b2:	4889                	li	a7,2
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ba:	488d                	li	a7,3
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c2:	4891                	li	a7,4
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <read>:
.global read
read:
 li a7, SYS_read
 2ca:	4895                	li	a7,5
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <write>:
.global write
write:
 li a7, SYS_write
 2d2:	48c1                	li	a7,16
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <close>:
.global close
close:
 li a7, SYS_close
 2da:	48d5                	li	a7,21
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e2:	4899                	li	a7,6
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ea:	489d                	li	a7,7
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <open>:
.global open
open:
 li a7, SYS_open
 2f2:	48bd                	li	a7,15
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fa:	48c5                	li	a7,17
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 302:	48c9                	li	a7,18
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30a:	48a1                	li	a7,8
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <link>:
.global link
link:
 li a7, SYS_link
 312:	48cd                	li	a7,19
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31a:	48d1                	li	a7,20
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 322:	48a5                	li	a7,9
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <dup>:
.global dup
dup:
 li a7, SYS_dup
 32a:	48a9                	li	a7,10
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 332:	48ad                	li	a7,11
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 33a:	48b1                	li	a7,12
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 342:	48b5                	li	a7,13
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34a:	48b9                	li	a7,14
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 352:	48d9                	li	a7,22
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 35a:	48dd                	li	a7,23
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 362:	48e1                	li	a7,24
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 36a:	48e5                	li	a7,25
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 372:	1101                	addi	sp,sp,-32
 374:	ec06                	sd	ra,24(sp)
 376:	e822                	sd	s0,16(sp)
 378:	1000                	addi	s0,sp,32
 37a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 37e:	4605                	li	a2,1
 380:	fef40593          	addi	a1,s0,-17
 384:	00000097          	auipc	ra,0x0
 388:	f4e080e7          	jalr	-178(ra) # 2d2 <write>
}
 38c:	60e2                	ld	ra,24(sp)
 38e:	6442                	ld	s0,16(sp)
 390:	6105                	addi	sp,sp,32
 392:	8082                	ret

0000000000000394 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 394:	7139                	addi	sp,sp,-64
 396:	fc06                	sd	ra,56(sp)
 398:	f822                	sd	s0,48(sp)
 39a:	f426                	sd	s1,40(sp)
 39c:	f04a                	sd	s2,32(sp)
 39e:	ec4e                	sd	s3,24(sp)
 3a0:	0080                	addi	s0,sp,64
 3a2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a4:	c299                	beqz	a3,3aa <printint+0x16>
 3a6:	0805c863          	bltz	a1,436 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3aa:	2581                	sext.w	a1,a1
  neg = 0;
 3ac:	4881                	li	a7,0
 3ae:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3b2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3b4:	2601                	sext.w	a2,a2
 3b6:	00000517          	auipc	a0,0x0
 3ba:	75250513          	addi	a0,a0,1874 # b08 <digits>
 3be:	883a                	mv	a6,a4
 3c0:	2705                	addiw	a4,a4,1
 3c2:	02c5f7bb          	remuw	a5,a1,a2
 3c6:	1782                	slli	a5,a5,0x20
 3c8:	9381                	srli	a5,a5,0x20
 3ca:	97aa                	add	a5,a5,a0
 3cc:	0007c783          	lbu	a5,0(a5)
 3d0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3d4:	0005879b          	sext.w	a5,a1
 3d8:	02c5d5bb          	divuw	a1,a1,a2
 3dc:	0685                	addi	a3,a3,1
 3de:	fec7f0e3          	bgeu	a5,a2,3be <printint+0x2a>
  if(neg)
 3e2:	00088b63          	beqz	a7,3f8 <printint+0x64>
    buf[i++] = '-';
 3e6:	fd040793          	addi	a5,s0,-48
 3ea:	973e                	add	a4,a4,a5
 3ec:	02d00793          	li	a5,45
 3f0:	fef70823          	sb	a5,-16(a4)
 3f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f8:	02e05863          	blez	a4,428 <printint+0x94>
 3fc:	fc040793          	addi	a5,s0,-64
 400:	00e78933          	add	s2,a5,a4
 404:	fff78993          	addi	s3,a5,-1
 408:	99ba                	add	s3,s3,a4
 40a:	377d                	addiw	a4,a4,-1
 40c:	1702                	slli	a4,a4,0x20
 40e:	9301                	srli	a4,a4,0x20
 410:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 414:	fff94583          	lbu	a1,-1(s2)
 418:	8526                	mv	a0,s1
 41a:	00000097          	auipc	ra,0x0
 41e:	f58080e7          	jalr	-168(ra) # 372 <putc>
  while(--i >= 0)
 422:	197d                	addi	s2,s2,-1
 424:	ff3918e3          	bne	s2,s3,414 <printint+0x80>
}
 428:	70e2                	ld	ra,56(sp)
 42a:	7442                	ld	s0,48(sp)
 42c:	74a2                	ld	s1,40(sp)
 42e:	7902                	ld	s2,32(sp)
 430:	69e2                	ld	s3,24(sp)
 432:	6121                	addi	sp,sp,64
 434:	8082                	ret
    x = -xx;
 436:	40b005bb          	negw	a1,a1
    neg = 1;
 43a:	4885                	li	a7,1
    x = -xx;
 43c:	bf8d                	j	3ae <printint+0x1a>

000000000000043e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43e:	7119                	addi	sp,sp,-128
 440:	fc86                	sd	ra,120(sp)
 442:	f8a2                	sd	s0,112(sp)
 444:	f4a6                	sd	s1,104(sp)
 446:	f0ca                	sd	s2,96(sp)
 448:	ecce                	sd	s3,88(sp)
 44a:	e8d2                	sd	s4,80(sp)
 44c:	e4d6                	sd	s5,72(sp)
 44e:	e0da                	sd	s6,64(sp)
 450:	fc5e                	sd	s7,56(sp)
 452:	f862                	sd	s8,48(sp)
 454:	f466                	sd	s9,40(sp)
 456:	f06a                	sd	s10,32(sp)
 458:	ec6e                	sd	s11,24(sp)
 45a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45c:	0005c903          	lbu	s2,0(a1)
 460:	18090f63          	beqz	s2,5fe <vprintf+0x1c0>
 464:	8aaa                	mv	s5,a0
 466:	8b32                	mv	s6,a2
 468:	00158493          	addi	s1,a1,1
  state = 0;
 46c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 46e:	02500a13          	li	s4,37
      if(c == 'd'){
 472:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 476:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 47a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 47e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 482:	00000b97          	auipc	s7,0x0
 486:	686b8b93          	addi	s7,s7,1670 # b08 <digits>
 48a:	a839                	j	4a8 <vprintf+0x6a>
        putc(fd, c);
 48c:	85ca                	mv	a1,s2
 48e:	8556                	mv	a0,s5
 490:	00000097          	auipc	ra,0x0
 494:	ee2080e7          	jalr	-286(ra) # 372 <putc>
 498:	a019                	j	49e <vprintf+0x60>
    } else if(state == '%'){
 49a:	01498f63          	beq	s3,s4,4b8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 49e:	0485                	addi	s1,s1,1
 4a0:	fff4c903          	lbu	s2,-1(s1)
 4a4:	14090d63          	beqz	s2,5fe <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4a8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ac:	fe0997e3          	bnez	s3,49a <vprintf+0x5c>
      if(c == '%'){
 4b0:	fd479ee3          	bne	a5,s4,48c <vprintf+0x4e>
        state = '%';
 4b4:	89be                	mv	s3,a5
 4b6:	b7e5                	j	49e <vprintf+0x60>
      if(c == 'd'){
 4b8:	05878063          	beq	a5,s8,4f8 <vprintf+0xba>
      } else if(c == 'l') {
 4bc:	05978c63          	beq	a5,s9,514 <vprintf+0xd6>
      } else if(c == 'x') {
 4c0:	07a78863          	beq	a5,s10,530 <vprintf+0xf2>
      } else if(c == 'p') {
 4c4:	09b78463          	beq	a5,s11,54c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4c8:	07300713          	li	a4,115
 4cc:	0ce78663          	beq	a5,a4,598 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4d0:	06300713          	li	a4,99
 4d4:	0ee78e63          	beq	a5,a4,5d0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4d8:	11478863          	beq	a5,s4,5e8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4dc:	85d2                	mv	a1,s4
 4de:	8556                	mv	a0,s5
 4e0:	00000097          	auipc	ra,0x0
 4e4:	e92080e7          	jalr	-366(ra) # 372 <putc>
        putc(fd, c);
 4e8:	85ca                	mv	a1,s2
 4ea:	8556                	mv	a0,s5
 4ec:	00000097          	auipc	ra,0x0
 4f0:	e86080e7          	jalr	-378(ra) # 372 <putc>
      }
      state = 0;
 4f4:	4981                	li	s3,0
 4f6:	b765                	j	49e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4f8:	008b0913          	addi	s2,s6,8
 4fc:	4685                	li	a3,1
 4fe:	4629                	li	a2,10
 500:	000b2583          	lw	a1,0(s6)
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	e8e080e7          	jalr	-370(ra) # 394 <printint>
 50e:	8b4a                	mv	s6,s2
      state = 0;
 510:	4981                	li	s3,0
 512:	b771                	j	49e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 514:	008b0913          	addi	s2,s6,8
 518:	4681                	li	a3,0
 51a:	4629                	li	a2,10
 51c:	000b2583          	lw	a1,0(s6)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e72080e7          	jalr	-398(ra) # 394 <printint>
 52a:	8b4a                	mv	s6,s2
      state = 0;
 52c:	4981                	li	s3,0
 52e:	bf85                	j	49e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 530:	008b0913          	addi	s2,s6,8
 534:	4681                	li	a3,0
 536:	4641                	li	a2,16
 538:	000b2583          	lw	a1,0(s6)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	e56080e7          	jalr	-426(ra) # 394 <printint>
 546:	8b4a                	mv	s6,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	bf91                	j	49e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 54c:	008b0793          	addi	a5,s6,8
 550:	f8f43423          	sd	a5,-120(s0)
 554:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 558:	03000593          	li	a1,48
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e14080e7          	jalr	-492(ra) # 372 <putc>
  putc(fd, 'x');
 566:	85ea                	mv	a1,s10
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e08080e7          	jalr	-504(ra) # 372 <putc>
 572:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 574:	03c9d793          	srli	a5,s3,0x3c
 578:	97de                	add	a5,a5,s7
 57a:	0007c583          	lbu	a1,0(a5)
 57e:	8556                	mv	a0,s5
 580:	00000097          	auipc	ra,0x0
 584:	df2080e7          	jalr	-526(ra) # 372 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 588:	0992                	slli	s3,s3,0x4
 58a:	397d                	addiw	s2,s2,-1
 58c:	fe0914e3          	bnez	s2,574 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 590:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 594:	4981                	li	s3,0
 596:	b721                	j	49e <vprintf+0x60>
        s = va_arg(ap, char*);
 598:	008b0993          	addi	s3,s6,8
 59c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5a0:	02090163          	beqz	s2,5c2 <vprintf+0x184>
        while(*s != 0){
 5a4:	00094583          	lbu	a1,0(s2)
 5a8:	c9a1                	beqz	a1,5f8 <vprintf+0x1ba>
          putc(fd, *s);
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	dc6080e7          	jalr	-570(ra) # 372 <putc>
          s++;
 5b4:	0905                	addi	s2,s2,1
        while(*s != 0){
 5b6:	00094583          	lbu	a1,0(s2)
 5ba:	f9e5                	bnez	a1,5aa <vprintf+0x16c>
        s = va_arg(ap, char*);
 5bc:	8b4e                	mv	s6,s3
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bdf9                	j	49e <vprintf+0x60>
          s = "(null)";
 5c2:	00000917          	auipc	s2,0x0
 5c6:	53e90913          	addi	s2,s2,1342 # b00 <tournament_release+0x88>
        while(*s != 0){
 5ca:	02800593          	li	a1,40
 5ce:	bff1                	j	5aa <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5d0:	008b0913          	addi	s2,s6,8
 5d4:	000b4583          	lbu	a1,0(s6)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	d98080e7          	jalr	-616(ra) # 372 <putc>
 5e2:	8b4a                	mv	s6,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bd65                	j	49e <vprintf+0x60>
        putc(fd, c);
 5e8:	85d2                	mv	a1,s4
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	d86080e7          	jalr	-634(ra) # 372 <putc>
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b565                	j	49e <vprintf+0x60>
        s = va_arg(ap, char*);
 5f8:	8b4e                	mv	s6,s3
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b54d                	j	49e <vprintf+0x60>
    }
  }
}
 5fe:	70e6                	ld	ra,120(sp)
 600:	7446                	ld	s0,112(sp)
 602:	74a6                	ld	s1,104(sp)
 604:	7906                	ld	s2,96(sp)
 606:	69e6                	ld	s3,88(sp)
 608:	6a46                	ld	s4,80(sp)
 60a:	6aa6                	ld	s5,72(sp)
 60c:	6b06                	ld	s6,64(sp)
 60e:	7be2                	ld	s7,56(sp)
 610:	7c42                	ld	s8,48(sp)
 612:	7ca2                	ld	s9,40(sp)
 614:	7d02                	ld	s10,32(sp)
 616:	6de2                	ld	s11,24(sp)
 618:	6109                	addi	sp,sp,128
 61a:	8082                	ret

000000000000061c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 61c:	715d                	addi	sp,sp,-80
 61e:	ec06                	sd	ra,24(sp)
 620:	e822                	sd	s0,16(sp)
 622:	1000                	addi	s0,sp,32
 624:	e010                	sd	a2,0(s0)
 626:	e414                	sd	a3,8(s0)
 628:	e818                	sd	a4,16(s0)
 62a:	ec1c                	sd	a5,24(s0)
 62c:	03043023          	sd	a6,32(s0)
 630:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 634:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 638:	8622                	mv	a2,s0
 63a:	00000097          	auipc	ra,0x0
 63e:	e04080e7          	jalr	-508(ra) # 43e <vprintf>
}
 642:	60e2                	ld	ra,24(sp)
 644:	6442                	ld	s0,16(sp)
 646:	6161                	addi	sp,sp,80
 648:	8082                	ret

000000000000064a <printf>:

void
printf(const char *fmt, ...)
{
 64a:	711d                	addi	sp,sp,-96
 64c:	ec06                	sd	ra,24(sp)
 64e:	e822                	sd	s0,16(sp)
 650:	1000                	addi	s0,sp,32
 652:	e40c                	sd	a1,8(s0)
 654:	e810                	sd	a2,16(s0)
 656:	ec14                	sd	a3,24(s0)
 658:	f018                	sd	a4,32(s0)
 65a:	f41c                	sd	a5,40(s0)
 65c:	03043823          	sd	a6,48(s0)
 660:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 664:	00840613          	addi	a2,s0,8
 668:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 66c:	85aa                	mv	a1,a0
 66e:	4505                	li	a0,1
 670:	00000097          	auipc	ra,0x0
 674:	dce080e7          	jalr	-562(ra) # 43e <vprintf>
}
 678:	60e2                	ld	ra,24(sp)
 67a:	6442                	ld	s0,16(sp)
 67c:	6125                	addi	sp,sp,96
 67e:	8082                	ret

0000000000000680 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 680:	1141                	addi	sp,sp,-16
 682:	e422                	sd	s0,8(sp)
 684:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 686:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68a:	00001797          	auipc	a5,0x1
 68e:	9767b783          	ld	a5,-1674(a5) # 1000 <freep>
 692:	a805                	j	6c2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 694:	4618                	lw	a4,8(a2)
 696:	9db9                	addw	a1,a1,a4
 698:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 69c:	6398                	ld	a4,0(a5)
 69e:	6318                	ld	a4,0(a4)
 6a0:	fee53823          	sd	a4,-16(a0)
 6a4:	a091                	j	6e8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a6:	ff852703          	lw	a4,-8(a0)
 6aa:	9e39                	addw	a2,a2,a4
 6ac:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6ae:	ff053703          	ld	a4,-16(a0)
 6b2:	e398                	sd	a4,0(a5)
 6b4:	a099                	j	6fa <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b6:	6398                	ld	a4,0(a5)
 6b8:	00e7e463          	bltu	a5,a4,6c0 <free+0x40>
 6bc:	00e6ea63          	bltu	a3,a4,6d0 <free+0x50>
{
 6c0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c2:	fed7fae3          	bgeu	a5,a3,6b6 <free+0x36>
 6c6:	6398                	ld	a4,0(a5)
 6c8:	00e6e463          	bltu	a3,a4,6d0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6cc:	fee7eae3          	bltu	a5,a4,6c0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6d0:	ff852583          	lw	a1,-8(a0)
 6d4:	6390                	ld	a2,0(a5)
 6d6:	02059713          	slli	a4,a1,0x20
 6da:	9301                	srli	a4,a4,0x20
 6dc:	0712                	slli	a4,a4,0x4
 6de:	9736                	add	a4,a4,a3
 6e0:	fae60ae3          	beq	a2,a4,694 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6e4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e8:	4790                	lw	a2,8(a5)
 6ea:	02061713          	slli	a4,a2,0x20
 6ee:	9301                	srli	a4,a4,0x20
 6f0:	0712                	slli	a4,a4,0x4
 6f2:	973e                	add	a4,a4,a5
 6f4:	fae689e3          	beq	a3,a4,6a6 <free+0x26>
  } else
    p->s.ptr = bp;
 6f8:	e394                	sd	a3,0(a5)
  freep = p;
 6fa:	00001717          	auipc	a4,0x1
 6fe:	90f73323          	sd	a5,-1786(a4) # 1000 <freep>
}
 702:	6422                	ld	s0,8(sp)
 704:	0141                	addi	sp,sp,16
 706:	8082                	ret

0000000000000708 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 708:	7139                	addi	sp,sp,-64
 70a:	fc06                	sd	ra,56(sp)
 70c:	f822                	sd	s0,48(sp)
 70e:	f426                	sd	s1,40(sp)
 710:	f04a                	sd	s2,32(sp)
 712:	ec4e                	sd	s3,24(sp)
 714:	e852                	sd	s4,16(sp)
 716:	e456                	sd	s5,8(sp)
 718:	e05a                	sd	s6,0(sp)
 71a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71c:	02051493          	slli	s1,a0,0x20
 720:	9081                	srli	s1,s1,0x20
 722:	04bd                	addi	s1,s1,15
 724:	8091                	srli	s1,s1,0x4
 726:	0014899b          	addiw	s3,s1,1
 72a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 72c:	00001517          	auipc	a0,0x1
 730:	8d453503          	ld	a0,-1836(a0) # 1000 <freep>
 734:	c515                	beqz	a0,760 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 736:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 738:	4798                	lw	a4,8(a5)
 73a:	02977f63          	bgeu	a4,s1,778 <malloc+0x70>
 73e:	8a4e                	mv	s4,s3
 740:	0009871b          	sext.w	a4,s3
 744:	6685                	lui	a3,0x1
 746:	00d77363          	bgeu	a4,a3,74c <malloc+0x44>
 74a:	6a05                	lui	s4,0x1
 74c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 750:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 754:	00001917          	auipc	s2,0x1
 758:	8ac90913          	addi	s2,s2,-1876 # 1000 <freep>
  if(p == (char*)-1)
 75c:	5afd                	li	s5,-1
 75e:	a88d                	j	7d0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 760:	00001797          	auipc	a5,0x1
 764:	8c078793          	addi	a5,a5,-1856 # 1020 <base>
 768:	00001717          	auipc	a4,0x1
 76c:	88f73c23          	sd	a5,-1896(a4) # 1000 <freep>
 770:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 772:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 776:	b7e1                	j	73e <malloc+0x36>
      if(p->s.size == nunits)
 778:	02e48b63          	beq	s1,a4,7ae <malloc+0xa6>
        p->s.size -= nunits;
 77c:	4137073b          	subw	a4,a4,s3
 780:	c798                	sw	a4,8(a5)
        p += p->s.size;
 782:	1702                	slli	a4,a4,0x20
 784:	9301                	srli	a4,a4,0x20
 786:	0712                	slli	a4,a4,0x4
 788:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 78a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 78e:	00001717          	auipc	a4,0x1
 792:	86a73923          	sd	a0,-1934(a4) # 1000 <freep>
      return (void*)(p + 1);
 796:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 79a:	70e2                	ld	ra,56(sp)
 79c:	7442                	ld	s0,48(sp)
 79e:	74a2                	ld	s1,40(sp)
 7a0:	7902                	ld	s2,32(sp)
 7a2:	69e2                	ld	s3,24(sp)
 7a4:	6a42                	ld	s4,16(sp)
 7a6:	6aa2                	ld	s5,8(sp)
 7a8:	6b02                	ld	s6,0(sp)
 7aa:	6121                	addi	sp,sp,64
 7ac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ae:	6398                	ld	a4,0(a5)
 7b0:	e118                	sd	a4,0(a0)
 7b2:	bff1                	j	78e <malloc+0x86>
  hp->s.size = nu;
 7b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b8:	0541                	addi	a0,a0,16
 7ba:	00000097          	auipc	ra,0x0
 7be:	ec6080e7          	jalr	-314(ra) # 680 <free>
  return freep;
 7c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c6:	d971                	beqz	a0,79a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ca:	4798                	lw	a4,8(a5)
 7cc:	fa9776e3          	bgeu	a4,s1,778 <malloc+0x70>
    if(p == freep)
 7d0:	00093703          	ld	a4,0(s2)
 7d4:	853e                	mv	a0,a5
 7d6:	fef719e3          	bne	a4,a5,7c8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7da:	8552                	mv	a0,s4
 7dc:	00000097          	auipc	ra,0x0
 7e0:	b5e080e7          	jalr	-1186(ra) # 33a <sbrk>
  if(p == (char*)-1)
 7e4:	fd5518e3          	bne	a0,s5,7b4 <malloc+0xac>
        return 0;
 7e8:	4501                	li	a0,0
 7ea:	bf45                	j	79a <malloc+0x92>

00000000000007ec <tournament_create>:
static int proc_id = 0;  // ID of the current process in the tournament
static int num_processes = 0;   // Number of processes in the tournament
static int num_levels = 0;      // Number of levels in the tournament tree
static int *lock_ids = 0;       // Array of Peterson lock IDs

int tournament_create(int processes) {
 7ec:	715d                	addi	sp,sp,-80
 7ee:	e486                	sd	ra,72(sp)
 7f0:	e0a2                	sd	s0,64(sp)
 7f2:	fc26                	sd	s1,56(sp)
 7f4:	f84a                	sd	s2,48(sp)
 7f6:	f44e                	sd	s3,40(sp)
 7f8:	f052                	sd	s4,32(sp)
 7fa:	ec56                	sd	s5,24(sp)
 7fc:	e85a                	sd	s6,16(sp)
 7fe:	e45e                	sd	s7,8(sp)
 800:	0880                	addi	s0,sp,80
    // Check if the number of processes is valid (power of 2 up to 16)
    if (processes <= 0 || processes > 16 || (processes & (processes - 1)) != 0) {
 802:	fff5071b          	addiw	a4,a0,-1
 806:	47bd                	li	a5,15
 808:	14e7e163          	bltu	a5,a4,94a <tournament_create+0x15e>
 80c:	8aaa                	mv	s5,a0
 80e:	357d                	addiw	a0,a0,-1
 810:	8b3a                	mv	s6,a4
 812:	015777b3          	and	a5,a4,s5
 816:	12079c63          	bnez	a5,94e <tournament_create+0x162>
        return -1;  // Not a power of 2 or out of range
    }

    num_processes = processes;
 81a:	00000797          	auipc	a5,0x0
 81e:	7f57ad23          	sw	s5,2042(a5) # 1014 <num_processes>
    lock_ids = malloc(sizeof(int) * (num_processes - 1));
 822:	0025151b          	slliw	a0,a0,0x2
 826:	00000097          	auipc	ra,0x0
 82a:	ee2080e7          	jalr	-286(ra) # 708 <malloc>
 82e:	00000797          	auipc	a5,0x0
 832:	7ca7bd23          	sd	a0,2010(a5) # 1008 <lock_ids>
    if (!lock_ids) {
 836:	10050e63          	beqz	a0,952 <tournament_create+0x166>
        return -1;  // Memory allocation failed
    }

    for (int i = 0; i < processes - 1; i++) {
 83a:	05605063          	blez	s6,87a <tournament_create+0x8e>
 83e:	4481                	li	s1,0
        lock_ids[i] = peterson_create();
 840:	00000a17          	auipc	s4,0x0
 844:	7c8a0a13          	addi	s4,s4,1992 # 1008 <lock_ids>
 848:	00048b9b          	sext.w	s7,s1
 84c:	00249913          	slli	s2,s1,0x2
 850:	000a3983          	ld	s3,0(s4)
 854:	99ca                	add	s3,s3,s2
 856:	00000097          	auipc	ra,0x0
 85a:	afc080e7          	jalr	-1284(ra) # 352 <peterson_create>
 85e:	00a9a023          	sw	a0,0(s3)
        if (lock_ids[i] < 0) {
 862:	000a3783          	ld	a5,0(s4)
 866:	993e                	add	s2,s2,a5
 868:	00092783          	lw	a5,0(s2)
 86c:	0607c163          	bltz	a5,8ce <tournament_create+0xe2>
    for (int i = 0; i < processes - 1; i++) {
 870:	0485                	addi	s1,s1,1
 872:	0004879b          	sext.w	a5,s1
 876:	fd67c9e3          	blt	a5,s6,848 <tournament_create+0x5c>
            return -1;
        }
    }

    // חישוב מספר הרמות בעץ: log2(processes)
    num_levels = 0;
 87a:	00000797          	auipc	a5,0x0
 87e:	7807ab23          	sw	zero,1942(a5) # 1010 <num_levels>
    int temp = num_processes;
 882:	00000797          	auipc	a5,0x0
 886:	7927a783          	lw	a5,1938(a5) # 1014 <num_processes>
    while (temp > 1) {
 88a:	4705                	li	a4,1
 88c:	00f75e63          	bge	a4,a5,8a8 <tournament_create+0xbc>
 890:	4605                	li	a2,1
        temp >>= 1;
 892:	4017d79b          	sraiw	a5,a5,0x1
        num_levels++;
 896:	0007069b          	sext.w	a3,a4
    while (temp > 1) {
 89a:	2705                	addiw	a4,a4,1
 89c:	fef64be3          	blt	a2,a5,892 <tournament_create+0xa6>
 8a0:	00000797          	auipc	a5,0x0
 8a4:	76d7a823          	sw	a3,1904(a5) # 1010 <num_levels>
    }

    for (int i = 1; i < processes; i++) {
 8a8:	4785                	li	a5,1
 8aa:	0157dd63          	bge	a5,s5,8c4 <tournament_create+0xd8>
 8ae:	4485                	li	s1,1
        int pid = fork();
 8b0:	00000097          	auipc	ra,0x0
 8b4:	9fa080e7          	jalr	-1542(ra) # 2aa <fork>
        if (pid < 0) {
 8b8:	06054a63          	bltz	a0,92c <tournament_create+0x140>
            printf("fork failed!\n");
            return -1;
        }
        if (pid == 0) {
 8bc:	c151                	beqz	a0,940 <tournament_create+0x154>
    for (int i = 1; i < processes; i++) {
 8be:	2485                	addiw	s1,s1,1
 8c0:	fe9a98e3          	bne	s5,s1,8b0 <tournament_create+0xc4>
            proc_id = i;
            return proc_id;
        }
    }

    return proc_id;
 8c4:	00000497          	auipc	s1,0x0
 8c8:	7544a483          	lw	s1,1876(s1) # 1018 <proc_id>
 8cc:	a0a1                	j	914 <tournament_create+0x128>
            for (int j = 0; j < i; j++) {
 8ce:	03705763          	blez	s7,8fc <tournament_create+0x110>
 8d2:	34fd                	addiw	s1,s1,-1
 8d4:	1482                	slli	s1,s1,0x20
 8d6:	9081                	srli	s1,s1,0x20
 8d8:	0485                	addi	s1,s1,1
 8da:	048a                	slli	s1,s1,0x2
 8dc:	4901                	li	s2,0
                peterson_destroy(lock_ids[j]);
 8de:	00000997          	auipc	s3,0x0
 8e2:	72a98993          	addi	s3,s3,1834 # 1008 <lock_ids>
 8e6:	0009b783          	ld	a5,0(s3)
 8ea:	97ca                	add	a5,a5,s2
 8ec:	4388                	lw	a0,0(a5)
 8ee:	00000097          	auipc	ra,0x0
 8f2:	a7c080e7          	jalr	-1412(ra) # 36a <peterson_destroy>
            for (int j = 0; j < i; j++) {
 8f6:	0911                	addi	s2,s2,4
 8f8:	fe9917e3          	bne	s2,s1,8e6 <tournament_create+0xfa>
            free(lock_ids);
 8fc:	00000497          	auipc	s1,0x0
 900:	70c48493          	addi	s1,s1,1804 # 1008 <lock_ids>
 904:	6088                	ld	a0,0(s1)
 906:	00000097          	auipc	ra,0x0
 90a:	d7a080e7          	jalr	-646(ra) # 680 <free>
            lock_ids = 0;
 90e:	0004b023          	sd	zero,0(s1)
            return -1;
 912:	54fd                	li	s1,-1
}
 914:	8526                	mv	a0,s1
 916:	60a6                	ld	ra,72(sp)
 918:	6406                	ld	s0,64(sp)
 91a:	74e2                	ld	s1,56(sp)
 91c:	7942                	ld	s2,48(sp)
 91e:	79a2                	ld	s3,40(sp)
 920:	7a02                	ld	s4,32(sp)
 922:	6ae2                	ld	s5,24(sp)
 924:	6b42                	ld	s6,16(sp)
 926:	6ba2                	ld	s7,8(sp)
 928:	6161                	addi	sp,sp,80
 92a:	8082                	ret
            printf("fork failed!\n");
 92c:	00000517          	auipc	a0,0x0
 930:	1f450513          	addi	a0,a0,500 # b20 <digits+0x18>
 934:	00000097          	auipc	ra,0x0
 938:	d16080e7          	jalr	-746(ra) # 64a <printf>
            return -1;
 93c:	54fd                	li	s1,-1
 93e:	bfd9                	j	914 <tournament_create+0x128>
            proc_id = i;
 940:	00000797          	auipc	a5,0x0
 944:	6c97ac23          	sw	s1,1752(a5) # 1018 <proc_id>
            return proc_id;
 948:	b7f1                	j	914 <tournament_create+0x128>
        return -1;  // Not a power of 2 or out of range
 94a:	54fd                	li	s1,-1
 94c:	b7e1                	j	914 <tournament_create+0x128>
 94e:	54fd                	li	s1,-1
 950:	b7d1                	j	914 <tournament_create+0x128>
        return -1;  // Memory allocation failed
 952:	54fd                	li	s1,-1
 954:	b7c1                	j	914 <tournament_create+0x128>

0000000000000956 <tournament_acquire>:

int tournament_acquire(void) {
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 956:	00000797          	auipc	a5,0x0
 95a:	6be7a783          	lw	a5,1726(a5) # 1014 <num_processes>
 95e:	10078163          	beqz	a5,a60 <tournament_acquire+0x10a>
int tournament_acquire(void) {
 962:	7139                	addi	sp,sp,-64
 964:	fc06                	sd	ra,56(sp)
 966:	f822                	sd	s0,48(sp)
 968:	f426                	sd	s1,40(sp)
 96a:	f04a                	sd	s2,32(sp)
 96c:	ec4e                	sd	s3,24(sp)
 96e:	e852                	sd	s4,16(sp)
 970:	e456                	sd	s5,8(sp)
 972:	0080                	addi	s0,sp,64
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 974:	00000497          	auipc	s1,0x0
 978:	69c4a483          	lw	s1,1692(s1) # 1010 <num_levels>
 97c:	c4e5                	beqz	s1,a64 <tournament_acquire+0x10e>
 97e:	00000797          	auipc	a5,0x0
 982:	68a7b783          	ld	a5,1674(a5) # 1008 <lock_ids>
 986:	c3ed                	beqz	a5,a68 <tournament_acquire+0x112>
        return -1;  // Tournament not initialized
    }

    int node = proc_id, role;
    for (int i = num_levels - 1; i >= 0; i--) {
 988:	34fd                	addiw	s1,s1,-1
 98a:	0e04c163          	bltz	s1,a6c <tournament_acquire+0x116>
        // חישוב תפקיד (role) עבור הרמה הנוכחית
        int shift = num_levels - i - 1;
 98e:	00000a17          	auipc	s4,0x0
 992:	682a0a13          	addi	s4,s4,1666 # 1010 <num_levels>
        role = (proc_id & (1 << shift)) >> shift;
 996:	00000997          	auipc	s3,0x0
 99a:	68298993          	addi	s3,s3,1666 # 1018 <proc_id>
 99e:	4905                	li	s2,1
    for (int i = num_levels - 1; i >= 0; i--) {
 9a0:	5afd                	li	s5,-1
        int shift = num_levels - i - 1;
 9a2:	000a2783          	lw	a5,0(s4)
 9a6:	4097873b          	subw	a4,a5,s1
 9aa:	fff7059b          	addiw	a1,a4,-1
        role = (proc_id & (1 << shift)) >> shift;
 9ae:	0009a783          	lw	a5,0(s3)
 9b2:	00b916bb          	sllw	a3,s2,a1
 9b6:	8efd                	and	a3,a3,a5

        // חישוב אינדקס של המנעול ברמה זו
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 9b8:	0099153b          	sllw	a0,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 9bc:	40e7d7bb          	sraw	a5,a5,a4
        node = lock_level_idx + (1 << i) - 1;
 9c0:	9d3d                	addw	a0,a0,a5

        if (peterson_acquire(node, role) < 0) {
 9c2:	40b6d5bb          	sraw	a1,a3,a1
 9c6:	357d                	addiw	a0,a0,-1
 9c8:	00000097          	auipc	ra,0x0
 9cc:	992080e7          	jalr	-1646(ra) # 35a <peterson_acquire>
 9d0:	00054f63          	bltz	a0,9ee <tournament_acquire+0x98>
    for (int i = num_levels - 1; i >= 0; i--) {
 9d4:	34fd                	addiw	s1,s1,-1
 9d6:	fd5496e3          	bne	s1,s5,9a2 <tournament_acquire+0x4c>
            }
            return -1;
        }
    }

    return 0;
 9da:	4501                	li	a0,0
}
 9dc:	70e2                	ld	ra,56(sp)
 9de:	7442                	ld	s0,48(sp)
 9e0:	74a2                	ld	s1,40(sp)
 9e2:	7902                	ld	s2,32(sp)
 9e4:	69e2                	ld	s3,24(sp)
 9e6:	6a42                	ld	s4,16(sp)
 9e8:	6aa2                	ld	s5,8(sp)
 9ea:	6121                	addi	sp,sp,64
 9ec:	8082                	ret
            printf("failed to acquire: %d \n", proc_id);
 9ee:	00000597          	auipc	a1,0x0
 9f2:	62a5a583          	lw	a1,1578(a1) # 1018 <proc_id>
 9f6:	00000517          	auipc	a0,0x0
 9fa:	13a50513          	addi	a0,a0,314 # b30 <digits+0x28>
 9fe:	00000097          	auipc	ra,0x0
 a02:	c4c080e7          	jalr	-948(ra) # 64a <printf>
            for (int j = i; j < num_levels; j++) {
 a06:	00000517          	auipc	a0,0x0
 a0a:	60a52503          	lw	a0,1546(a0) # 1010 <num_levels>
 a0e:	06a4d163          	bge	s1,a0,a70 <tournament_acquire+0x11a>
                int r = (proc_id & (1 << shift2)) >> shift2;
 a12:	00000997          	auipc	s3,0x0
 a16:	60698993          	addi	s3,s3,1542 # 1018 <proc_id>
 a1a:	4905                	li	s2,1
            for (int j = i; j < num_levels; j++) {
 a1c:	00000a17          	auipc	s4,0x0
 a20:	5f4a0a13          	addi	s4,s4,1524 # 1010 <num_levels>
                int shift2 = num_levels - j - 1;
 a24:	409507bb          	subw	a5,a0,s1
 a28:	fff7859b          	addiw	a1,a5,-1
                int r = (proc_id & (1 << shift2)) >> shift2;
 a2c:	0009a503          	lw	a0,0(s3)
 a30:	00b9173b          	sllw	a4,s2,a1
 a34:	8f69                	and	a4,a4,a0
                int li = (proc_id >> (num_levels - j)) + (1 << j) - 1;
 a36:	40f5553b          	sraw	a0,a0,a5
 a3a:	009917bb          	sllw	a5,s2,s1
 a3e:	9d3d                	addw	a0,a0,a5
                if (peterson_release(li, r) < 0) {
 a40:	40b755bb          	sraw	a1,a4,a1
 a44:	357d                	addiw	a0,a0,-1
 a46:	00000097          	auipc	ra,0x0
 a4a:	91c080e7          	jalr	-1764(ra) # 362 <peterson_release>
 a4e:	02054363          	bltz	a0,a74 <tournament_acquire+0x11e>
            for (int j = i; j < num_levels; j++) {
 a52:	2485                	addiw	s1,s1,1
 a54:	000a2503          	lw	a0,0(s4)
 a58:	fca4c6e3          	blt	s1,a0,a24 <tournament_acquire+0xce>
            return -1;
 a5c:	557d                	li	a0,-1
 a5e:	bfbd                	j	9dc <tournament_acquire+0x86>
        return -1;  // Tournament not initialized
 a60:	557d                	li	a0,-1
}
 a62:	8082                	ret
        return -1;  // Tournament not initialized
 a64:	557d                	li	a0,-1
 a66:	bf9d                	j	9dc <tournament_acquire+0x86>
 a68:	557d                	li	a0,-1
 a6a:	bf8d                	j	9dc <tournament_acquire+0x86>
    return 0;
 a6c:	4501                	li	a0,0
 a6e:	b7bd                	j	9dc <tournament_acquire+0x86>
            return -1;
 a70:	557d                	li	a0,-1
 a72:	b7ad                	j	9dc <tournament_acquire+0x86>
                    return -1;
 a74:	557d                	li	a0,-1
 a76:	b79d                	j	9dc <tournament_acquire+0x86>

0000000000000a78 <tournament_release>:

int tournament_release(void) {
    int node = proc_id, role;
    for (int i = 0; i < num_levels; i++) {
 a78:	00000517          	auipc	a0,0x0
 a7c:	59852503          	lw	a0,1432(a0) # 1010 <num_levels>
 a80:	06a05263          	blez	a0,ae4 <tournament_release+0x6c>
int tournament_release(void) {
 a84:	7179                	addi	sp,sp,-48
 a86:	f406                	sd	ra,40(sp)
 a88:	f022                	sd	s0,32(sp)
 a8a:	ec26                	sd	s1,24(sp)
 a8c:	e84a                	sd	s2,16(sp)
 a8e:	e44e                	sd	s3,8(sp)
 a90:	e052                	sd	s4,0(sp)
 a92:	1800                	addi	s0,sp,48
    for (int i = 0; i < num_levels; i++) {
 a94:	4481                	li	s1,0
        // חישוב תפקיד (role)
        int shift = num_levels - i - 1;
        role = (proc_id & (1 << shift)) >> shift;
 a96:	00000997          	auipc	s3,0x0
 a9a:	58298993          	addi	s3,s3,1410 # 1018 <proc_id>
 a9e:	4905                	li	s2,1
    for (int i = 0; i < num_levels; i++) {
 aa0:	00000a17          	auipc	s4,0x0
 aa4:	570a0a13          	addi	s4,s4,1392 # 1010 <num_levels>
        int shift = num_levels - i - 1;
 aa8:	9d05                	subw	a0,a0,s1
 aaa:	fff5059b          	addiw	a1,a0,-1
        role = (proc_id & (1 << shift)) >> shift;
 aae:	0009a703          	lw	a4,0(s3)
 ab2:	00b916bb          	sllw	a3,s2,a1
 ab6:	8ef9                	and	a3,a3,a4

        // חישוב אינדקס של המנעול
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 ab8:	009917bb          	sllw	a5,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 abc:	40a7573b          	sraw	a4,a4,a0
        node = lock_level_idx + (1 << i) - 1;
 ac0:	00e7853b          	addw	a0,a5,a4

        if (peterson_release(node, role) < 0) {
 ac4:	40b6d5bb          	sraw	a1,a3,a1
 ac8:	357d                	addiw	a0,a0,-1
 aca:	00000097          	auipc	ra,0x0
 ace:	898080e7          	jalr	-1896(ra) # 362 <peterson_release>
 ad2:	00054b63          	bltz	a0,ae8 <tournament_release+0x70>
    for (int i = 0; i < num_levels; i++) {
 ad6:	2485                	addiw	s1,s1,1
 ad8:	000a2503          	lw	a0,0(s4)
 adc:	fca4c6e3          	blt	s1,a0,aa8 <tournament_release+0x30>
            return -1;
        }
    }
    return 0;
 ae0:	4501                	li	a0,0
 ae2:	a021                	j	aea <tournament_release+0x72>
 ae4:	4501                	li	a0,0
}
 ae6:	8082                	ret
            return -1;
 ae8:	557d                	li	a0,-1
}
 aea:	70a2                	ld	ra,40(sp)
 aec:	7402                	ld	s0,32(sp)
 aee:	64e2                	ld	s1,24(sp)
 af0:	6942                	ld	s2,16(sp)
 af2:	69a2                	ld	s3,8(sp)
 af4:	6a02                	ld	s4,0(sp)
 af6:	6145                	addi	sp,sp,48
 af8:	8082                	ret

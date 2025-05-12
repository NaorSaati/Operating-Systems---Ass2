
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	b2058593          	addi	a1,a1,-1248 # b30 <tournament_release+0x82>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	638080e7          	jalr	1592(ra) # 652 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2c4080e7          	jalr	708(ra) # 2e8 <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	316080e7          	jalr	790(ra) # 348 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2a8080e7          	jalr	680(ra) # 2e8 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00001597          	auipc	a1,0x1
  50:	afc58593          	addi	a1,a1,-1284 # b48 <tournament_release+0x9a>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5fc080e7          	jalr	1532(ra) # 652 <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  60:	1141                	addi	sp,sp,-16
  62:	e406                	sd	ra,8(sp)
  64:	e022                	sd	s0,0(sp)
  66:	0800                	addi	s0,sp,16
  extern int main();
  main();
  68:	00000097          	auipc	ra,0x0
  6c:	f98080e7          	jalr	-104(ra) # 0 <main>
  exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	276080e7          	jalr	630(ra) # 2e8 <exit>

000000000000007a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  80:	87aa                	mv	a5,a0
  82:	0585                	addi	a1,a1,1
  84:	0785                	addi	a5,a5,1
  86:	fff5c703          	lbu	a4,-1(a1)
  8a:	fee78fa3          	sb	a4,-1(a5)
  8e:	fb75                	bnez	a4,82 <strcpy+0x8>
    ;
  return os;
}
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret

0000000000000096 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cb91                	beqz	a5,b4 <strcmp+0x1e>
  a2:	0005c703          	lbu	a4,0(a1)
  a6:	00f71763          	bne	a4,a5,b4 <strcmp+0x1e>
    p++, q++;
  aa:	0505                	addi	a0,a0,1
  ac:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	fbe5                	bnez	a5,a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b4:	0005c503          	lbu	a0,0(a1)
}
  b8:	40a7853b          	subw	a0,a5,a0
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strlen>:

uint
strlen(const char *s)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cf91                	beqz	a5,e8 <strlen+0x26>
  ce:	0505                	addi	a0,a0,1
  d0:	87aa                	mv	a5,a0
  d2:	4685                	li	a3,1
  d4:	9e89                	subw	a3,a3,a0
  d6:	00f6853b          	addw	a0,a3,a5
  da:	0785                	addi	a5,a5,1
  dc:	fff7c703          	lbu	a4,-1(a5)
  e0:	fb7d                	bnez	a4,d6 <strlen+0x14>
    ;
  return n;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  for(n = 0; s[n]; n++)
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strlen+0x20>

00000000000000ec <memset>:

void*
memset(void *dst, int c, uint n)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f2:	ca19                	beqz	a2,108 <memset+0x1c>
  f4:	87aa                	mv	a5,a0
  f6:	1602                	slli	a2,a2,0x20
  f8:	9201                	srli	a2,a2,0x20
  fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 102:	0785                	addi	a5,a5,1
 104:	fee79de3          	bne	a5,a4,fe <memset+0x12>
  }
  return dst;
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret

000000000000010e <strchr>:

char*
strchr(const char *s, char c)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  for(; *s; s++)
 114:	00054783          	lbu	a5,0(a0)
 118:	cb99                	beqz	a5,12e <strchr+0x20>
    if(*s == c)
 11a:	00f58763          	beq	a1,a5,128 <strchr+0x1a>
  for(; *s; s++)
 11e:	0505                	addi	a0,a0,1
 120:	00054783          	lbu	a5,0(a0)
 124:	fbfd                	bnez	a5,11a <strchr+0xc>
      return (char*)s;
  return 0;
 126:	4501                	li	a0,0
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  return 0;
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strchr+0x1a>

0000000000000132 <gets>:

char*
gets(char *buf, int max)
{
 132:	711d                	addi	sp,sp,-96
 134:	ec86                	sd	ra,88(sp)
 136:	e8a2                	sd	s0,80(sp)
 138:	e4a6                	sd	s1,72(sp)
 13a:	e0ca                	sd	s2,64(sp)
 13c:	fc4e                	sd	s3,56(sp)
 13e:	f852                	sd	s4,48(sp)
 140:	f456                	sd	s5,40(sp)
 142:	f05a                	sd	s6,32(sp)
 144:	ec5e                	sd	s7,24(sp)
 146:	1080                	addi	s0,sp,96
 148:	8baa                	mv	s7,a0
 14a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14c:	892a                	mv	s2,a0
 14e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 150:	4aa9                	li	s5,10
 152:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 154:	89a6                	mv	s3,s1
 156:	2485                	addiw	s1,s1,1
 158:	0344d863          	bge	s1,s4,188 <gets+0x56>
    cc = read(0, &c, 1);
 15c:	4605                	li	a2,1
 15e:	faf40593          	addi	a1,s0,-81
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	19c080e7          	jalr	412(ra) # 300 <read>
    if(cc < 1)
 16c:	00a05e63          	blez	a0,188 <gets+0x56>
    buf[i++] = c;
 170:	faf44783          	lbu	a5,-81(s0)
 174:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 178:	01578763          	beq	a5,s5,186 <gets+0x54>
 17c:	0905                	addi	s2,s2,1
 17e:	fd679be3          	bne	a5,s6,154 <gets+0x22>
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	a011                	j	188 <gets+0x56>
 186:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 188:	99de                	add	s3,s3,s7
 18a:	00098023          	sb	zero,0(s3)
  return buf;
}
 18e:	855e                	mv	a0,s7
 190:	60e6                	ld	ra,88(sp)
 192:	6446                	ld	s0,80(sp)
 194:	64a6                	ld	s1,72(sp)
 196:	6906                	ld	s2,64(sp)
 198:	79e2                	ld	s3,56(sp)
 19a:	7a42                	ld	s4,48(sp)
 19c:	7aa2                	ld	s5,40(sp)
 19e:	7b02                	ld	s6,32(sp)
 1a0:	6be2                	ld	s7,24(sp)
 1a2:	6125                	addi	sp,sp,96
 1a4:	8082                	ret

00000000000001a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a6:	1101                	addi	sp,sp,-32
 1a8:	ec06                	sd	ra,24(sp)
 1aa:	e822                	sd	s0,16(sp)
 1ac:	e426                	sd	s1,8(sp)
 1ae:	e04a                	sd	s2,0(sp)
 1b0:	1000                	addi	s0,sp,32
 1b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b4:	4581                	li	a1,0
 1b6:	00000097          	auipc	ra,0x0
 1ba:	172080e7          	jalr	370(ra) # 328 <open>
  if(fd < 0)
 1be:	02054563          	bltz	a0,1e8 <stat+0x42>
 1c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c4:	85ca                	mv	a1,s2
 1c6:	00000097          	auipc	ra,0x0
 1ca:	17a080e7          	jalr	378(ra) # 340 <fstat>
 1ce:	892a                	mv	s2,a0
  close(fd);
 1d0:	8526                	mv	a0,s1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	13e080e7          	jalr	318(ra) # 310 <close>
  return r;
}
 1da:	854a                	mv	a0,s2
 1dc:	60e2                	ld	ra,24(sp)
 1de:	6442                	ld	s0,16(sp)
 1e0:	64a2                	ld	s1,8(sp)
 1e2:	6902                	ld	s2,0(sp)
 1e4:	6105                	addi	sp,sp,32
 1e6:	8082                	ret
    return -1;
 1e8:	597d                	li	s2,-1
 1ea:	bfc5                	j	1da <stat+0x34>

00000000000001ec <atoi>:

int
atoi(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f2:	00054603          	lbu	a2,0(a0)
 1f6:	fd06079b          	addiw	a5,a2,-48
 1fa:	0ff7f793          	andi	a5,a5,255
 1fe:	4725                	li	a4,9
 200:	02f76963          	bltu	a4,a5,232 <atoi+0x46>
 204:	86aa                	mv	a3,a0
  n = 0;
 206:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 208:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 20a:	0685                	addi	a3,a3,1
 20c:	0025179b          	slliw	a5,a0,0x2
 210:	9fa9                	addw	a5,a5,a0
 212:	0017979b          	slliw	a5,a5,0x1
 216:	9fb1                	addw	a5,a5,a2
 218:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21c:	0006c603          	lbu	a2,0(a3)
 220:	fd06071b          	addiw	a4,a2,-48
 224:	0ff77713          	andi	a4,a4,255
 228:	fee5f1e3          	bgeu	a1,a4,20a <atoi+0x1e>
  return n;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  n = 0;
 232:	4501                	li	a0,0
 234:	bfe5                	j	22c <atoi+0x40>

0000000000000236 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23c:	02b57463          	bgeu	a0,a1,264 <memmove+0x2e>
    while(n-- > 0)
 240:	00c05f63          	blez	a2,25e <memmove+0x28>
 244:	1602                	slli	a2,a2,0x20
 246:	9201                	srli	a2,a2,0x20
 248:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24c:	872a                	mv	a4,a0
      *dst++ = *src++;
 24e:	0585                	addi	a1,a1,1
 250:	0705                	addi	a4,a4,1
 252:	fff5c683          	lbu	a3,-1(a1)
 256:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25a:	fee79ae3          	bne	a5,a4,24e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
    dst += n;
 264:	00c50733          	add	a4,a0,a2
    src += n;
 268:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26a:	fec05ae3          	blez	a2,25e <memmove+0x28>
 26e:	fff6079b          	addiw	a5,a2,-1
 272:	1782                	slli	a5,a5,0x20
 274:	9381                	srli	a5,a5,0x20
 276:	fff7c793          	not	a5,a5
 27a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27c:	15fd                	addi	a1,a1,-1
 27e:	177d                	addi	a4,a4,-1
 280:	0005c683          	lbu	a3,0(a1)
 284:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 288:	fee79ae3          	bne	a5,a4,27c <memmove+0x46>
 28c:	bfc9                	j	25e <memmove+0x28>

000000000000028e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 294:	ca05                	beqz	a2,2c4 <memcmp+0x36>
 296:	fff6069b          	addiw	a3,a2,-1
 29a:	1682                	slli	a3,a3,0x20
 29c:	9281                	srli	a3,a3,0x20
 29e:	0685                	addi	a3,a3,1
 2a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	0005c703          	lbu	a4,0(a1)
 2aa:	00e79863          	bne	a5,a4,2ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ae:	0505                	addi	a0,a0,1
    p2++;
 2b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b2:	fed518e3          	bne	a0,a3,2a2 <memcmp+0x14>
  }
  return 0;
 2b6:	4501                	li	a0,0
 2b8:	a019                	j	2be <memcmp+0x30>
      return *p1 - *p2;
 2ba:	40e7853b          	subw	a0,a5,a4
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
  return 0;
 2c4:	4501                	li	a0,0
 2c6:	bfe5                	j	2be <memcmp+0x30>

00000000000002c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d0:	00000097          	auipc	ra,0x0
 2d4:	f66080e7          	jalr	-154(ra) # 236 <memmove>
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e0:	4885                	li	a7,1
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e8:	4889                	li	a7,2
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f0:	488d                	li	a7,3
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f8:	4891                	li	a7,4
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <read>:
.global read
read:
 li a7, SYS_read
 300:	4895                	li	a7,5
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <write>:
.global write
write:
 li a7, SYS_write
 308:	48c1                	li	a7,16
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <close>:
.global close
close:
 li a7, SYS_close
 310:	48d5                	li	a7,21
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <kill>:
.global kill
kill:
 li a7, SYS_kill
 318:	4899                	li	a7,6
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exec>:
.global exec
exec:
 li a7, SYS_exec
 320:	489d                	li	a7,7
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <open>:
.global open
open:
 li a7, SYS_open
 328:	48bd                	li	a7,15
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 330:	48c5                	li	a7,17
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 338:	48c9                	li	a7,18
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 340:	48a1                	li	a7,8
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <link>:
.global link
link:
 li a7, SYS_link
 348:	48cd                	li	a7,19
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 350:	48d1                	li	a7,20
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 358:	48a5                	li	a7,9
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <dup>:
.global dup
dup:
 li a7, SYS_dup
 360:	48a9                	li	a7,10
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 368:	48ad                	li	a7,11
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 370:	48b1                	li	a7,12
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 378:	48b5                	li	a7,13
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 380:	48b9                	li	a7,14
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 388:	48d9                	li	a7,22
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 390:	48dd                	li	a7,23
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 398:	48e1                	li	a7,24
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 3a0:	48e5                	li	a7,25
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a8:	1101                	addi	sp,sp,-32
 3aa:	ec06                	sd	ra,24(sp)
 3ac:	e822                	sd	s0,16(sp)
 3ae:	1000                	addi	s0,sp,32
 3b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b4:	4605                	li	a2,1
 3b6:	fef40593          	addi	a1,s0,-17
 3ba:	00000097          	auipc	ra,0x0
 3be:	f4e080e7          	jalr	-178(ra) # 308 <write>
}
 3c2:	60e2                	ld	ra,24(sp)
 3c4:	6442                	ld	s0,16(sp)
 3c6:	6105                	addi	sp,sp,32
 3c8:	8082                	ret

00000000000003ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ca:	7139                	addi	sp,sp,-64
 3cc:	fc06                	sd	ra,56(sp)
 3ce:	f822                	sd	s0,48(sp)
 3d0:	f426                	sd	s1,40(sp)
 3d2:	f04a                	sd	s2,32(sp)
 3d4:	ec4e                	sd	s3,24(sp)
 3d6:	0080                	addi	s0,sp,64
 3d8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3da:	c299                	beqz	a3,3e0 <printint+0x16>
 3dc:	0805c863          	bltz	a1,46c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3e0:	2581                	sext.w	a1,a1
  neg = 0;
 3e2:	4881                	li	a7,0
 3e4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ea:	2601                	sext.w	a2,a2
 3ec:	00000517          	auipc	a0,0x0
 3f0:	77c50513          	addi	a0,a0,1916 # b68 <digits>
 3f4:	883a                	mv	a6,a4
 3f6:	2705                	addiw	a4,a4,1
 3f8:	02c5f7bb          	remuw	a5,a1,a2
 3fc:	1782                	slli	a5,a5,0x20
 3fe:	9381                	srli	a5,a5,0x20
 400:	97aa                	add	a5,a5,a0
 402:	0007c783          	lbu	a5,0(a5)
 406:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 40a:	0005879b          	sext.w	a5,a1
 40e:	02c5d5bb          	divuw	a1,a1,a2
 412:	0685                	addi	a3,a3,1
 414:	fec7f0e3          	bgeu	a5,a2,3f4 <printint+0x2a>
  if(neg)
 418:	00088b63          	beqz	a7,42e <printint+0x64>
    buf[i++] = '-';
 41c:	fd040793          	addi	a5,s0,-48
 420:	973e                	add	a4,a4,a5
 422:	02d00793          	li	a5,45
 426:	fef70823          	sb	a5,-16(a4)
 42a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 42e:	02e05863          	blez	a4,45e <printint+0x94>
 432:	fc040793          	addi	a5,s0,-64
 436:	00e78933          	add	s2,a5,a4
 43a:	fff78993          	addi	s3,a5,-1
 43e:	99ba                	add	s3,s3,a4
 440:	377d                	addiw	a4,a4,-1
 442:	1702                	slli	a4,a4,0x20
 444:	9301                	srli	a4,a4,0x20
 446:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 44a:	fff94583          	lbu	a1,-1(s2)
 44e:	8526                	mv	a0,s1
 450:	00000097          	auipc	ra,0x0
 454:	f58080e7          	jalr	-168(ra) # 3a8 <putc>
  while(--i >= 0)
 458:	197d                	addi	s2,s2,-1
 45a:	ff3918e3          	bne	s2,s3,44a <printint+0x80>
}
 45e:	70e2                	ld	ra,56(sp)
 460:	7442                	ld	s0,48(sp)
 462:	74a2                	ld	s1,40(sp)
 464:	7902                	ld	s2,32(sp)
 466:	69e2                	ld	s3,24(sp)
 468:	6121                	addi	sp,sp,64
 46a:	8082                	ret
    x = -xx;
 46c:	40b005bb          	negw	a1,a1
    neg = 1;
 470:	4885                	li	a7,1
    x = -xx;
 472:	bf8d                	j	3e4 <printint+0x1a>

0000000000000474 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 474:	7119                	addi	sp,sp,-128
 476:	fc86                	sd	ra,120(sp)
 478:	f8a2                	sd	s0,112(sp)
 47a:	f4a6                	sd	s1,104(sp)
 47c:	f0ca                	sd	s2,96(sp)
 47e:	ecce                	sd	s3,88(sp)
 480:	e8d2                	sd	s4,80(sp)
 482:	e4d6                	sd	s5,72(sp)
 484:	e0da                	sd	s6,64(sp)
 486:	fc5e                	sd	s7,56(sp)
 488:	f862                	sd	s8,48(sp)
 48a:	f466                	sd	s9,40(sp)
 48c:	f06a                	sd	s10,32(sp)
 48e:	ec6e                	sd	s11,24(sp)
 490:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 492:	0005c903          	lbu	s2,0(a1)
 496:	18090f63          	beqz	s2,634 <vprintf+0x1c0>
 49a:	8aaa                	mv	s5,a0
 49c:	8b32                	mv	s6,a2
 49e:	00158493          	addi	s1,a1,1
  state = 0;
 4a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a4:	02500a13          	li	s4,37
      if(c == 'd'){
 4a8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4ac:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4b0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4b4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b8:	00000b97          	auipc	s7,0x0
 4bc:	6b0b8b93          	addi	s7,s7,1712 # b68 <digits>
 4c0:	a839                	j	4de <vprintf+0x6a>
        putc(fd, c);
 4c2:	85ca                	mv	a1,s2
 4c4:	8556                	mv	a0,s5
 4c6:	00000097          	auipc	ra,0x0
 4ca:	ee2080e7          	jalr	-286(ra) # 3a8 <putc>
 4ce:	a019                	j	4d4 <vprintf+0x60>
    } else if(state == '%'){
 4d0:	01498f63          	beq	s3,s4,4ee <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4d4:	0485                	addi	s1,s1,1
 4d6:	fff4c903          	lbu	s2,-1(s1)
 4da:	14090d63          	beqz	s2,634 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e2:	fe0997e3          	bnez	s3,4d0 <vprintf+0x5c>
      if(c == '%'){
 4e6:	fd479ee3          	bne	a5,s4,4c2 <vprintf+0x4e>
        state = '%';
 4ea:	89be                	mv	s3,a5
 4ec:	b7e5                	j	4d4 <vprintf+0x60>
      if(c == 'd'){
 4ee:	05878063          	beq	a5,s8,52e <vprintf+0xba>
      } else if(c == 'l') {
 4f2:	05978c63          	beq	a5,s9,54a <vprintf+0xd6>
      } else if(c == 'x') {
 4f6:	07a78863          	beq	a5,s10,566 <vprintf+0xf2>
      } else if(c == 'p') {
 4fa:	09b78463          	beq	a5,s11,582 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4fe:	07300713          	li	a4,115
 502:	0ce78663          	beq	a5,a4,5ce <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 506:	06300713          	li	a4,99
 50a:	0ee78e63          	beq	a5,a4,606 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 50e:	11478863          	beq	a5,s4,61e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 512:	85d2                	mv	a1,s4
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	e92080e7          	jalr	-366(ra) # 3a8 <putc>
        putc(fd, c);
 51e:	85ca                	mv	a1,s2
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e86080e7          	jalr	-378(ra) # 3a8 <putc>
      }
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b765                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 52e:	008b0913          	addi	s2,s6,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000b2583          	lw	a1,0(s6)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e8e080e7          	jalr	-370(ra) # 3ca <printint>
 544:	8b4a                	mv	s6,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	b771                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b0913          	addi	s2,s6,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000b2583          	lw	a1,0(s6)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e72080e7          	jalr	-398(ra) # 3ca <printint>
 560:	8b4a                	mv	s6,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	bf85                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 566:	008b0913          	addi	s2,s6,8
 56a:	4681                	li	a3,0
 56c:	4641                	li	a2,16
 56e:	000b2583          	lw	a1,0(s6)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e56080e7          	jalr	-426(ra) # 3ca <printint>
 57c:	8b4a                	mv	s6,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	bf91                	j	4d4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 582:	008b0793          	addi	a5,s6,8
 586:	f8f43423          	sd	a5,-120(s0)
 58a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 58e:	03000593          	li	a1,48
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e14080e7          	jalr	-492(ra) # 3a8 <putc>
  putc(fd, 'x');
 59c:	85ea                	mv	a1,s10
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e08080e7          	jalr	-504(ra) # 3a8 <putc>
 5a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5aa:	03c9d793          	srli	a5,s3,0x3c
 5ae:	97de                	add	a5,a5,s7
 5b0:	0007c583          	lbu	a1,0(a5)
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	df2080e7          	jalr	-526(ra) # 3a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5be:	0992                	slli	s3,s3,0x4
 5c0:	397d                	addiw	s2,s2,-1
 5c2:	fe0914e3          	bnez	s2,5aa <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5c6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b721                	j	4d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 5ce:	008b0993          	addi	s3,s6,8
 5d2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5d6:	02090163          	beqz	s2,5f8 <vprintf+0x184>
        while(*s != 0){
 5da:	00094583          	lbu	a1,0(s2)
 5de:	c9a1                	beqz	a1,62e <vprintf+0x1ba>
          putc(fd, *s);
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	dc6080e7          	jalr	-570(ra) # 3a8 <putc>
          s++;
 5ea:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ec:	00094583          	lbu	a1,0(s2)
 5f0:	f9e5                	bnez	a1,5e0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5f2:	8b4e                	mv	s6,s3
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bdf9                	j	4d4 <vprintf+0x60>
          s = "(null)";
 5f8:	00000917          	auipc	s2,0x0
 5fc:	56890913          	addi	s2,s2,1384 # b60 <tournament_release+0xb2>
        while(*s != 0){
 600:	02800593          	li	a1,40
 604:	bff1                	j	5e0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 606:	008b0913          	addi	s2,s6,8
 60a:	000b4583          	lbu	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	d98080e7          	jalr	-616(ra) # 3a8 <putc>
 618:	8b4a                	mv	s6,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bd65                	j	4d4 <vprintf+0x60>
        putc(fd, c);
 61e:	85d2                	mv	a1,s4
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	d86080e7          	jalr	-634(ra) # 3a8 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b565                	j	4d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 62e:	8b4e                	mv	s6,s3
      state = 0;
 630:	4981                	li	s3,0
 632:	b54d                	j	4d4 <vprintf+0x60>
    }
  }
}
 634:	70e6                	ld	ra,120(sp)
 636:	7446                	ld	s0,112(sp)
 638:	74a6                	ld	s1,104(sp)
 63a:	7906                	ld	s2,96(sp)
 63c:	69e6                	ld	s3,88(sp)
 63e:	6a46                	ld	s4,80(sp)
 640:	6aa6                	ld	s5,72(sp)
 642:	6b06                	ld	s6,64(sp)
 644:	7be2                	ld	s7,56(sp)
 646:	7c42                	ld	s8,48(sp)
 648:	7ca2                	ld	s9,40(sp)
 64a:	7d02                	ld	s10,32(sp)
 64c:	6de2                	ld	s11,24(sp)
 64e:	6109                	addi	sp,sp,128
 650:	8082                	ret

0000000000000652 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 652:	715d                	addi	sp,sp,-80
 654:	ec06                	sd	ra,24(sp)
 656:	e822                	sd	s0,16(sp)
 658:	1000                	addi	s0,sp,32
 65a:	e010                	sd	a2,0(s0)
 65c:	e414                	sd	a3,8(s0)
 65e:	e818                	sd	a4,16(s0)
 660:	ec1c                	sd	a5,24(s0)
 662:	03043023          	sd	a6,32(s0)
 666:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 66e:	8622                	mv	a2,s0
 670:	00000097          	auipc	ra,0x0
 674:	e04080e7          	jalr	-508(ra) # 474 <vprintf>
}
 678:	60e2                	ld	ra,24(sp)
 67a:	6442                	ld	s0,16(sp)
 67c:	6161                	addi	sp,sp,80
 67e:	8082                	ret

0000000000000680 <printf>:

void
printf(const char *fmt, ...)
{
 680:	711d                	addi	sp,sp,-96
 682:	ec06                	sd	ra,24(sp)
 684:	e822                	sd	s0,16(sp)
 686:	1000                	addi	s0,sp,32
 688:	e40c                	sd	a1,8(s0)
 68a:	e810                	sd	a2,16(s0)
 68c:	ec14                	sd	a3,24(s0)
 68e:	f018                	sd	a4,32(s0)
 690:	f41c                	sd	a5,40(s0)
 692:	03043823          	sd	a6,48(s0)
 696:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69a:	00840613          	addi	a2,s0,8
 69e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a2:	85aa                	mv	a1,a0
 6a4:	4505                	li	a0,1
 6a6:	00000097          	auipc	ra,0x0
 6aa:	dce080e7          	jalr	-562(ra) # 474 <vprintf>
}
 6ae:	60e2                	ld	ra,24(sp)
 6b0:	6442                	ld	s0,16(sp)
 6b2:	6125                	addi	sp,sp,96
 6b4:	8082                	ret

00000000000006b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b6:	1141                	addi	sp,sp,-16
 6b8:	e422                	sd	s0,8(sp)
 6ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	00001797          	auipc	a5,0x1
 6c4:	9407b783          	ld	a5,-1728(a5) # 1000 <freep>
 6c8:	a805                	j	6f8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ca:	4618                	lw	a4,8(a2)
 6cc:	9db9                	addw	a1,a1,a4
 6ce:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d2:	6398                	ld	a4,0(a5)
 6d4:	6318                	ld	a4,0(a4)
 6d6:	fee53823          	sd	a4,-16(a0)
 6da:	a091                	j	71e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6dc:	ff852703          	lw	a4,-8(a0)
 6e0:	9e39                	addw	a2,a2,a4
 6e2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6e4:	ff053703          	ld	a4,-16(a0)
 6e8:	e398                	sd	a4,0(a5)
 6ea:	a099                	j	730 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ec:	6398                	ld	a4,0(a5)
 6ee:	00e7e463          	bltu	a5,a4,6f6 <free+0x40>
 6f2:	00e6ea63          	bltu	a3,a4,706 <free+0x50>
{
 6f6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f8:	fed7fae3          	bgeu	a5,a3,6ec <free+0x36>
 6fc:	6398                	ld	a4,0(a5)
 6fe:	00e6e463          	bltu	a3,a4,706 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 702:	fee7eae3          	bltu	a5,a4,6f6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 706:	ff852583          	lw	a1,-8(a0)
 70a:	6390                	ld	a2,0(a5)
 70c:	02059713          	slli	a4,a1,0x20
 710:	9301                	srli	a4,a4,0x20
 712:	0712                	slli	a4,a4,0x4
 714:	9736                	add	a4,a4,a3
 716:	fae60ae3          	beq	a2,a4,6ca <free+0x14>
    bp->s.ptr = p->s.ptr;
 71a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 71e:	4790                	lw	a2,8(a5)
 720:	02061713          	slli	a4,a2,0x20
 724:	9301                	srli	a4,a4,0x20
 726:	0712                	slli	a4,a4,0x4
 728:	973e                	add	a4,a4,a5
 72a:	fae689e3          	beq	a3,a4,6dc <free+0x26>
  } else
    p->s.ptr = bp;
 72e:	e394                	sd	a3,0(a5)
  freep = p;
 730:	00001717          	auipc	a4,0x1
 734:	8cf73823          	sd	a5,-1840(a4) # 1000 <freep>
}
 738:	6422                	ld	s0,8(sp)
 73a:	0141                	addi	sp,sp,16
 73c:	8082                	ret

000000000000073e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 73e:	7139                	addi	sp,sp,-64
 740:	fc06                	sd	ra,56(sp)
 742:	f822                	sd	s0,48(sp)
 744:	f426                	sd	s1,40(sp)
 746:	f04a                	sd	s2,32(sp)
 748:	ec4e                	sd	s3,24(sp)
 74a:	e852                	sd	s4,16(sp)
 74c:	e456                	sd	s5,8(sp)
 74e:	e05a                	sd	s6,0(sp)
 750:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 752:	02051493          	slli	s1,a0,0x20
 756:	9081                	srli	s1,s1,0x20
 758:	04bd                	addi	s1,s1,15
 75a:	8091                	srli	s1,s1,0x4
 75c:	0014899b          	addiw	s3,s1,1
 760:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 762:	00001517          	auipc	a0,0x1
 766:	89e53503          	ld	a0,-1890(a0) # 1000 <freep>
 76a:	c515                	beqz	a0,796 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 76e:	4798                	lw	a4,8(a5)
 770:	02977f63          	bgeu	a4,s1,7ae <malloc+0x70>
 774:	8a4e                	mv	s4,s3
 776:	0009871b          	sext.w	a4,s3
 77a:	6685                	lui	a3,0x1
 77c:	00d77363          	bgeu	a4,a3,782 <malloc+0x44>
 780:	6a05                	lui	s4,0x1
 782:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 786:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 78a:	00001917          	auipc	s2,0x1
 78e:	87690913          	addi	s2,s2,-1930 # 1000 <freep>
  if(p == (char*)-1)
 792:	5afd                	li	s5,-1
 794:	a88d                	j	806 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 796:	00001797          	auipc	a5,0x1
 79a:	88a78793          	addi	a5,a5,-1910 # 1020 <base>
 79e:	00001717          	auipc	a4,0x1
 7a2:	86f73123          	sd	a5,-1950(a4) # 1000 <freep>
 7a6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ac:	b7e1                	j	774 <malloc+0x36>
      if(p->s.size == nunits)
 7ae:	02e48b63          	beq	s1,a4,7e4 <malloc+0xa6>
        p->s.size -= nunits;
 7b2:	4137073b          	subw	a4,a4,s3
 7b6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b8:	1702                	slli	a4,a4,0x20
 7ba:	9301                	srli	a4,a4,0x20
 7bc:	0712                	slli	a4,a4,0x4
 7be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c4:	00001717          	auipc	a4,0x1
 7c8:	82a73e23          	sd	a0,-1988(a4) # 1000 <freep>
      return (void*)(p + 1);
 7cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d0:	70e2                	ld	ra,56(sp)
 7d2:	7442                	ld	s0,48(sp)
 7d4:	74a2                	ld	s1,40(sp)
 7d6:	7902                	ld	s2,32(sp)
 7d8:	69e2                	ld	s3,24(sp)
 7da:	6a42                	ld	s4,16(sp)
 7dc:	6aa2                	ld	s5,8(sp)
 7de:	6b02                	ld	s6,0(sp)
 7e0:	6121                	addi	sp,sp,64
 7e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e4:	6398                	ld	a4,0(a5)
 7e6:	e118                	sd	a4,0(a0)
 7e8:	bff1                	j	7c4 <malloc+0x86>
  hp->s.size = nu;
 7ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ee:	0541                	addi	a0,a0,16
 7f0:	00000097          	auipc	ra,0x0
 7f4:	ec6080e7          	jalr	-314(ra) # 6b6 <free>
  return freep;
 7f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7fc:	d971                	beqz	a0,7d0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 800:	4798                	lw	a4,8(a5)
 802:	fa9776e3          	bgeu	a4,s1,7ae <malloc+0x70>
    if(p == freep)
 806:	00093703          	ld	a4,0(s2)
 80a:	853e                	mv	a0,a5
 80c:	fef719e3          	bne	a4,a5,7fe <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 810:	8552                	mv	a0,s4
 812:	00000097          	auipc	ra,0x0
 816:	b5e080e7          	jalr	-1186(ra) # 370 <sbrk>
  if(p == (char*)-1)
 81a:	fd5518e3          	bne	a0,s5,7ea <malloc+0xac>
        return 0;
 81e:	4501                	li	a0,0
 820:	bf45                	j	7d0 <malloc+0x92>

0000000000000822 <tournament_create>:
static int proc_id = 0;  // ID of the current process in the tournament
static int num_processes = 0;   // Number of processes in the tournament
static int num_levels = 0;      // Number of levels in the tournament tree
static int *lock_ids = 0;       // Array of Peterson lock IDs

int tournament_create(int processes) {
 822:	715d                	addi	sp,sp,-80
 824:	e486                	sd	ra,72(sp)
 826:	e0a2                	sd	s0,64(sp)
 828:	fc26                	sd	s1,56(sp)
 82a:	f84a                	sd	s2,48(sp)
 82c:	f44e                	sd	s3,40(sp)
 82e:	f052                	sd	s4,32(sp)
 830:	ec56                	sd	s5,24(sp)
 832:	e85a                	sd	s6,16(sp)
 834:	e45e                	sd	s7,8(sp)
 836:	0880                	addi	s0,sp,80
    // Check if the number of processes is valid (power of 2 up to 16)
    if (processes <= 0 || processes > 16 || (processes & (processes - 1)) != 0) {
 838:	fff5071b          	addiw	a4,a0,-1
 83c:	47bd                	li	a5,15
 83e:	14e7e163          	bltu	a5,a4,980 <tournament_create+0x15e>
 842:	8aaa                	mv	s5,a0
 844:	357d                	addiw	a0,a0,-1
 846:	8b3a                	mv	s6,a4
 848:	015777b3          	and	a5,a4,s5
 84c:	12079c63          	bnez	a5,984 <tournament_create+0x162>
        return -1;  // Not a power of 2 or out of range
    }

    num_processes = processes;
 850:	00000797          	auipc	a5,0x0
 854:	7d57a223          	sw	s5,1988(a5) # 1014 <num_processes>
    lock_ids = malloc(sizeof(int) * (num_processes - 1));
 858:	0025151b          	slliw	a0,a0,0x2
 85c:	00000097          	auipc	ra,0x0
 860:	ee2080e7          	jalr	-286(ra) # 73e <malloc>
 864:	00000797          	auipc	a5,0x0
 868:	7aa7b223          	sd	a0,1956(a5) # 1008 <lock_ids>
    if (!lock_ids) {
 86c:	10050e63          	beqz	a0,988 <tournament_create+0x166>
        return -1;  // Memory allocation failed
    }

    for (int i = 0; i < processes - 1; i++) {
 870:	05605063          	blez	s6,8b0 <tournament_create+0x8e>
 874:	4481                	li	s1,0
        lock_ids[i] = peterson_create();
 876:	00000a17          	auipc	s4,0x0
 87a:	792a0a13          	addi	s4,s4,1938 # 1008 <lock_ids>
 87e:	00048b9b          	sext.w	s7,s1
 882:	00249913          	slli	s2,s1,0x2
 886:	000a3983          	ld	s3,0(s4)
 88a:	99ca                	add	s3,s3,s2
 88c:	00000097          	auipc	ra,0x0
 890:	afc080e7          	jalr	-1284(ra) # 388 <peterson_create>
 894:	00a9a023          	sw	a0,0(s3)
        if (lock_ids[i] < 0) {
 898:	000a3783          	ld	a5,0(s4)
 89c:	993e                	add	s2,s2,a5
 89e:	00092783          	lw	a5,0(s2)
 8a2:	0607c163          	bltz	a5,904 <tournament_create+0xe2>
    for (int i = 0; i < processes - 1; i++) {
 8a6:	0485                	addi	s1,s1,1
 8a8:	0004879b          	sext.w	a5,s1
 8ac:	fd67c9e3          	blt	a5,s6,87e <tournament_create+0x5c>
            return -1;
        }
    }

    // חישוב מספר הרמות בעץ: log2(processes)
    num_levels = 0;
 8b0:	00000797          	auipc	a5,0x0
 8b4:	7607a023          	sw	zero,1888(a5) # 1010 <num_levels>
    int temp = num_processes;
 8b8:	00000797          	auipc	a5,0x0
 8bc:	75c7a783          	lw	a5,1884(a5) # 1014 <num_processes>
    while (temp > 1) {
 8c0:	4705                	li	a4,1
 8c2:	00f75e63          	bge	a4,a5,8de <tournament_create+0xbc>
 8c6:	4605                	li	a2,1
        temp >>= 1;
 8c8:	4017d79b          	sraiw	a5,a5,0x1
        num_levels++;
 8cc:	0007069b          	sext.w	a3,a4
    while (temp > 1) {
 8d0:	2705                	addiw	a4,a4,1
 8d2:	fef64be3          	blt	a2,a5,8c8 <tournament_create+0xa6>
 8d6:	00000797          	auipc	a5,0x0
 8da:	72d7ad23          	sw	a3,1850(a5) # 1010 <num_levels>
    }

    for (int i = 1; i < processes; i++) {
 8de:	4785                	li	a5,1
 8e0:	0157dd63          	bge	a5,s5,8fa <tournament_create+0xd8>
 8e4:	4485                	li	s1,1
        int pid = fork();
 8e6:	00000097          	auipc	ra,0x0
 8ea:	9fa080e7          	jalr	-1542(ra) # 2e0 <fork>
        if (pid < 0) {
 8ee:	06054a63          	bltz	a0,962 <tournament_create+0x140>
            printf("fork failed!\n");
            return -1;
        }
        if (pid == 0) {
 8f2:	c151                	beqz	a0,976 <tournament_create+0x154>
    for (int i = 1; i < processes; i++) {
 8f4:	2485                	addiw	s1,s1,1
 8f6:	fe9a98e3          	bne	s5,s1,8e6 <tournament_create+0xc4>
            proc_id = i;
            return proc_id;
        }
    }

    return proc_id;
 8fa:	00000497          	auipc	s1,0x0
 8fe:	71e4a483          	lw	s1,1822(s1) # 1018 <proc_id>
 902:	a0a1                	j	94a <tournament_create+0x128>
            for (int j = 0; j < i; j++) {
 904:	03705763          	blez	s7,932 <tournament_create+0x110>
 908:	34fd                	addiw	s1,s1,-1
 90a:	1482                	slli	s1,s1,0x20
 90c:	9081                	srli	s1,s1,0x20
 90e:	0485                	addi	s1,s1,1
 910:	048a                	slli	s1,s1,0x2
 912:	4901                	li	s2,0
                peterson_destroy(lock_ids[j]);
 914:	00000997          	auipc	s3,0x0
 918:	6f498993          	addi	s3,s3,1780 # 1008 <lock_ids>
 91c:	0009b783          	ld	a5,0(s3)
 920:	97ca                	add	a5,a5,s2
 922:	4388                	lw	a0,0(a5)
 924:	00000097          	auipc	ra,0x0
 928:	a7c080e7          	jalr	-1412(ra) # 3a0 <peterson_destroy>
            for (int j = 0; j < i; j++) {
 92c:	0911                	addi	s2,s2,4
 92e:	fe9917e3          	bne	s2,s1,91c <tournament_create+0xfa>
            free(lock_ids);
 932:	00000497          	auipc	s1,0x0
 936:	6d648493          	addi	s1,s1,1750 # 1008 <lock_ids>
 93a:	6088                	ld	a0,0(s1)
 93c:	00000097          	auipc	ra,0x0
 940:	d7a080e7          	jalr	-646(ra) # 6b6 <free>
            lock_ids = 0;
 944:	0004b023          	sd	zero,0(s1)
            return -1;
 948:	54fd                	li	s1,-1
}
 94a:	8526                	mv	a0,s1
 94c:	60a6                	ld	ra,72(sp)
 94e:	6406                	ld	s0,64(sp)
 950:	74e2                	ld	s1,56(sp)
 952:	7942                	ld	s2,48(sp)
 954:	79a2                	ld	s3,40(sp)
 956:	7a02                	ld	s4,32(sp)
 958:	6ae2                	ld	s5,24(sp)
 95a:	6b42                	ld	s6,16(sp)
 95c:	6ba2                	ld	s7,8(sp)
 95e:	6161                	addi	sp,sp,80
 960:	8082                	ret
            printf("fork failed!\n");
 962:	00000517          	auipc	a0,0x0
 966:	21e50513          	addi	a0,a0,542 # b80 <digits+0x18>
 96a:	00000097          	auipc	ra,0x0
 96e:	d16080e7          	jalr	-746(ra) # 680 <printf>
            return -1;
 972:	54fd                	li	s1,-1
 974:	bfd9                	j	94a <tournament_create+0x128>
            proc_id = i;
 976:	00000797          	auipc	a5,0x0
 97a:	6a97a123          	sw	s1,1698(a5) # 1018 <proc_id>
            return proc_id;
 97e:	b7f1                	j	94a <tournament_create+0x128>
        return -1;  // Not a power of 2 or out of range
 980:	54fd                	li	s1,-1
 982:	b7e1                	j	94a <tournament_create+0x128>
 984:	54fd                	li	s1,-1
 986:	b7d1                	j	94a <tournament_create+0x128>
        return -1;  // Memory allocation failed
 988:	54fd                	li	s1,-1
 98a:	b7c1                	j	94a <tournament_create+0x128>

000000000000098c <tournament_acquire>:

int tournament_acquire(void) {
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 98c:	00000797          	auipc	a5,0x0
 990:	6887a783          	lw	a5,1672(a5) # 1014 <num_processes>
 994:	10078163          	beqz	a5,a96 <tournament_acquire+0x10a>
int tournament_acquire(void) {
 998:	7139                	addi	sp,sp,-64
 99a:	fc06                	sd	ra,56(sp)
 99c:	f822                	sd	s0,48(sp)
 99e:	f426                	sd	s1,40(sp)
 9a0:	f04a                	sd	s2,32(sp)
 9a2:	ec4e                	sd	s3,24(sp)
 9a4:	e852                	sd	s4,16(sp)
 9a6:	e456                	sd	s5,8(sp)
 9a8:	0080                	addi	s0,sp,64
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 9aa:	00000497          	auipc	s1,0x0
 9ae:	6664a483          	lw	s1,1638(s1) # 1010 <num_levels>
 9b2:	c4e5                	beqz	s1,a9a <tournament_acquire+0x10e>
 9b4:	00000797          	auipc	a5,0x0
 9b8:	6547b783          	ld	a5,1620(a5) # 1008 <lock_ids>
 9bc:	c3ed                	beqz	a5,a9e <tournament_acquire+0x112>
        return -1;  // Tournament not initialized
    }

    int node = proc_id, role;
    for (int i = num_levels - 1; i >= 0; i--) {
 9be:	34fd                	addiw	s1,s1,-1
 9c0:	0e04c163          	bltz	s1,aa2 <tournament_acquire+0x116>
        // חישוב תפקיד (role) עבור הרמה הנוכחית
        int shift = num_levels - i - 1;
 9c4:	00000a17          	auipc	s4,0x0
 9c8:	64ca0a13          	addi	s4,s4,1612 # 1010 <num_levels>
        role = (proc_id & (1 << shift)) >> shift;
 9cc:	00000997          	auipc	s3,0x0
 9d0:	64c98993          	addi	s3,s3,1612 # 1018 <proc_id>
 9d4:	4905                	li	s2,1
    for (int i = num_levels - 1; i >= 0; i--) {
 9d6:	5afd                	li	s5,-1
        int shift = num_levels - i - 1;
 9d8:	000a2783          	lw	a5,0(s4)
 9dc:	4097873b          	subw	a4,a5,s1
 9e0:	fff7059b          	addiw	a1,a4,-1
        role = (proc_id & (1 << shift)) >> shift;
 9e4:	0009a783          	lw	a5,0(s3)
 9e8:	00b916bb          	sllw	a3,s2,a1
 9ec:	8efd                	and	a3,a3,a5

        // חישוב אינדקס של המנעול ברמה זו
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 9ee:	0099153b          	sllw	a0,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 9f2:	40e7d7bb          	sraw	a5,a5,a4
        node = lock_level_idx + (1 << i) - 1;
 9f6:	9d3d                	addw	a0,a0,a5

        if (peterson_acquire(node, role) < 0) {
 9f8:	40b6d5bb          	sraw	a1,a3,a1
 9fc:	357d                	addiw	a0,a0,-1
 9fe:	00000097          	auipc	ra,0x0
 a02:	992080e7          	jalr	-1646(ra) # 390 <peterson_acquire>
 a06:	00054f63          	bltz	a0,a24 <tournament_acquire+0x98>
    for (int i = num_levels - 1; i >= 0; i--) {
 a0a:	34fd                	addiw	s1,s1,-1
 a0c:	fd5496e3          	bne	s1,s5,9d8 <tournament_acquire+0x4c>
            }
            return -1;
        }
    }

    return 0;
 a10:	4501                	li	a0,0
}
 a12:	70e2                	ld	ra,56(sp)
 a14:	7442                	ld	s0,48(sp)
 a16:	74a2                	ld	s1,40(sp)
 a18:	7902                	ld	s2,32(sp)
 a1a:	69e2                	ld	s3,24(sp)
 a1c:	6a42                	ld	s4,16(sp)
 a1e:	6aa2                	ld	s5,8(sp)
 a20:	6121                	addi	sp,sp,64
 a22:	8082                	ret
            printf("failed to acquire: %d \n", proc_id);
 a24:	00000597          	auipc	a1,0x0
 a28:	5f45a583          	lw	a1,1524(a1) # 1018 <proc_id>
 a2c:	00000517          	auipc	a0,0x0
 a30:	16450513          	addi	a0,a0,356 # b90 <digits+0x28>
 a34:	00000097          	auipc	ra,0x0
 a38:	c4c080e7          	jalr	-948(ra) # 680 <printf>
            for (int j = i; j < num_levels; j++) {
 a3c:	00000517          	auipc	a0,0x0
 a40:	5d452503          	lw	a0,1492(a0) # 1010 <num_levels>
 a44:	06a4d163          	bge	s1,a0,aa6 <tournament_acquire+0x11a>
                int r = (proc_id & (1 << shift2)) >> shift2;
 a48:	00000997          	auipc	s3,0x0
 a4c:	5d098993          	addi	s3,s3,1488 # 1018 <proc_id>
 a50:	4905                	li	s2,1
            for (int j = i; j < num_levels; j++) {
 a52:	00000a17          	auipc	s4,0x0
 a56:	5bea0a13          	addi	s4,s4,1470 # 1010 <num_levels>
                int shift2 = num_levels - j - 1;
 a5a:	409507bb          	subw	a5,a0,s1
 a5e:	fff7859b          	addiw	a1,a5,-1
                int r = (proc_id & (1 << shift2)) >> shift2;
 a62:	0009a503          	lw	a0,0(s3)
 a66:	00b9173b          	sllw	a4,s2,a1
 a6a:	8f69                	and	a4,a4,a0
                int li = (proc_id >> (num_levels - j)) + (1 << j) - 1;
 a6c:	40f5553b          	sraw	a0,a0,a5
 a70:	009917bb          	sllw	a5,s2,s1
 a74:	9d3d                	addw	a0,a0,a5
                if (peterson_release(li, r) < 0) {
 a76:	40b755bb          	sraw	a1,a4,a1
 a7a:	357d                	addiw	a0,a0,-1
 a7c:	00000097          	auipc	ra,0x0
 a80:	91c080e7          	jalr	-1764(ra) # 398 <peterson_release>
 a84:	02054363          	bltz	a0,aaa <tournament_acquire+0x11e>
            for (int j = i; j < num_levels; j++) {
 a88:	2485                	addiw	s1,s1,1
 a8a:	000a2503          	lw	a0,0(s4)
 a8e:	fca4c6e3          	blt	s1,a0,a5a <tournament_acquire+0xce>
            return -1;
 a92:	557d                	li	a0,-1
 a94:	bfbd                	j	a12 <tournament_acquire+0x86>
        return -1;  // Tournament not initialized
 a96:	557d                	li	a0,-1
}
 a98:	8082                	ret
        return -1;  // Tournament not initialized
 a9a:	557d                	li	a0,-1
 a9c:	bf9d                	j	a12 <tournament_acquire+0x86>
 a9e:	557d                	li	a0,-1
 aa0:	bf8d                	j	a12 <tournament_acquire+0x86>
    return 0;
 aa2:	4501                	li	a0,0
 aa4:	b7bd                	j	a12 <tournament_acquire+0x86>
            return -1;
 aa6:	557d                	li	a0,-1
 aa8:	b7ad                	j	a12 <tournament_acquire+0x86>
                    return -1;
 aaa:	557d                	li	a0,-1
 aac:	b79d                	j	a12 <tournament_acquire+0x86>

0000000000000aae <tournament_release>:

int tournament_release(void) {
    int node = proc_id, role;
    for (int i = 0; i < num_levels; i++) {
 aae:	00000517          	auipc	a0,0x0
 ab2:	56252503          	lw	a0,1378(a0) # 1010 <num_levels>
 ab6:	06a05263          	blez	a0,b1a <tournament_release+0x6c>
int tournament_release(void) {
 aba:	7179                	addi	sp,sp,-48
 abc:	f406                	sd	ra,40(sp)
 abe:	f022                	sd	s0,32(sp)
 ac0:	ec26                	sd	s1,24(sp)
 ac2:	e84a                	sd	s2,16(sp)
 ac4:	e44e                	sd	s3,8(sp)
 ac6:	e052                	sd	s4,0(sp)
 ac8:	1800                	addi	s0,sp,48
    for (int i = 0; i < num_levels; i++) {
 aca:	4481                	li	s1,0
        // חישוב תפקיד (role)
        int shift = num_levels - i - 1;
        role = (proc_id & (1 << shift)) >> shift;
 acc:	00000997          	auipc	s3,0x0
 ad0:	54c98993          	addi	s3,s3,1356 # 1018 <proc_id>
 ad4:	4905                	li	s2,1
    for (int i = 0; i < num_levels; i++) {
 ad6:	00000a17          	auipc	s4,0x0
 ada:	53aa0a13          	addi	s4,s4,1338 # 1010 <num_levels>
        int shift = num_levels - i - 1;
 ade:	9d05                	subw	a0,a0,s1
 ae0:	fff5059b          	addiw	a1,a0,-1
        role = (proc_id & (1 << shift)) >> shift;
 ae4:	0009a703          	lw	a4,0(s3)
 ae8:	00b916bb          	sllw	a3,s2,a1
 aec:	8ef9                	and	a3,a3,a4

        // חישוב אינדקס של המנעול
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 aee:	009917bb          	sllw	a5,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 af2:	40a7573b          	sraw	a4,a4,a0
        node = lock_level_idx + (1 << i) - 1;
 af6:	00e7853b          	addw	a0,a5,a4

        if (peterson_release(node, role) < 0) {
 afa:	40b6d5bb          	sraw	a1,a3,a1
 afe:	357d                	addiw	a0,a0,-1
 b00:	00000097          	auipc	ra,0x0
 b04:	898080e7          	jalr	-1896(ra) # 398 <peterson_release>
 b08:	00054b63          	bltz	a0,b1e <tournament_release+0x70>
    for (int i = 0; i < num_levels; i++) {
 b0c:	2485                	addiw	s1,s1,1
 b0e:	000a2503          	lw	a0,0(s4)
 b12:	fca4c6e3          	blt	s1,a0,ade <tournament_release+0x30>
            return -1;
        }
    }
    return 0;
 b16:	4501                	li	a0,0
 b18:	a021                	j	b20 <tournament_release+0x72>
 b1a:	4501                	li	a0,0
}
 b1c:	8082                	ret
            return -1;
 b1e:	557d                	li	a0,-1
}
 b20:	70a2                	ld	ra,40(sp)
 b22:	7402                	ld	s0,32(sp)
 b24:	64e2                	ld	s1,24(sp)
 b26:	6942                	ld	s2,16(sp)
 b28:	69a2                	ld	s3,8(sp)
 b2a:	6a02                	ld	s4,0(sp)
 b2c:	6145                	addi	sp,sp,48
 b2e:	8082                	ret


user/_tournament:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"

#define MAX_PROCESSES 16

int
main(int argc, char *argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if (argc != 2) {
   a:	4789                	li	a5,2
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: tournament <num_processes>\n");
  10:	00001597          	auipc	a1,0x1
  14:	bf058593          	addi	a1,a1,-1040 # c00 <tournament_release+0x82>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	708080e7          	jalr	1800(ra) # 722 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	394080e7          	jalr	916(ra) # 3b8 <exit>
  }

  int n = atoi(argv[1]);
  2c:	6588                	ld	a0,8(a1)
  2e:	00000097          	auipc	ra,0x0
  32:	28e080e7          	jalr	654(ra) # 2bc <atoi>
  if (n < 2 || n > MAX_PROCESSES) {
  36:	ffe5071b          	addiw	a4,a0,-2
  3a:	47b9                	li	a5,14
  3c:	02e7f063          	bgeu	a5,a4,5c <main+0x5c>
    fprintf(2, "Number of processes must be between 2 and 16\n");
  40:	00001597          	auipc	a1,0x1
  44:	be858593          	addi	a1,a1,-1048 # c28 <tournament_release+0xaa>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6d8080e7          	jalr	1752(ra) # 722 <fprintf>
    exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	364080e7          	jalr	868(ra) # 3b8 <exit>
  }

  int index = tournament_create(n);
  5c:	00001097          	auipc	ra,0x1
  60:	896080e7          	jalr	-1898(ra) # 8f2 <tournament_create>
  64:	84aa                	mv	s1,a0
  if (index < 0) {
  66:	06054963          	bltz	a0,d8 <main+0xd8>
    fprintf(2, "tournament_create failed\n");
    exit(1);
  }

  sleep(10); // חכה שכל התהליכים ייוולדו
  6a:	4529                	li	a0,10
  6c:	00000097          	auipc	ra,0x0
  70:	3dc080e7          	jalr	988(ra) # 448 <sleep>

  if (tournament_acquire() < 0) {
  74:	00001097          	auipc	ra,0x1
  78:	9e8080e7          	jalr	-1560(ra) # a5c <tournament_acquire>
  7c:	06054c63          	bltz	a0,f4 <main+0xf4>
    fprintf(2, "Process %d failed to acquire tournament lock\n", index);
    exit(1);
  }

  // ✅ הדפסה בשורת printf אחת — כדי למנוע קריאות חופפות
  printf("[PID %d] Tournament ID %d ENTERED critical section\n", getpid(), index);
  80:	00000097          	auipc	ra,0x0
  84:	3b8080e7          	jalr	952(ra) # 438 <getpid>
  88:	85aa                	mv	a1,a0
  8a:	8626                	mv	a2,s1
  8c:	00001517          	auipc	a0,0x1
  90:	c1c50513          	addi	a0,a0,-996 # ca8 <tournament_release+0x12a>
  94:	00000097          	auipc	ra,0x0
  98:	6bc080e7          	jalr	1724(ra) # 750 <printf>

  sleep(20); // סימולציה לקטע קריטי
  9c:	4551                	li	a0,20
  9e:	00000097          	auipc	ra,0x0
  a2:	3aa080e7          	jalr	938(ra) # 448 <sleep>

  printf("[PID %d] Tournament ID %d EXITING critical section\n", getpid(), index);
  a6:	00000097          	auipc	ra,0x0
  aa:	392080e7          	jalr	914(ra) # 438 <getpid>
  ae:	85aa                	mv	a1,a0
  b0:	8626                	mv	a2,s1
  b2:	00001517          	auipc	a0,0x1
  b6:	c2e50513          	addi	a0,a0,-978 # ce0 <tournament_release+0x162>
  ba:	00000097          	auipc	ra,0x0
  be:	696080e7          	jalr	1686(ra) # 750 <printf>

  if (tournament_release() < 0) {
  c2:	00001097          	auipc	ra,0x1
  c6:	abc080e7          	jalr	-1348(ra) # b7e <tournament_release>
  ca:	04054463          	bltz	a0,112 <main+0x112>
    fprintf(2, "Process %d failed to release tournament lock\n", index);
    exit(1);
  }

  exit(0);
  ce:	4501                	li	a0,0
  d0:	00000097          	auipc	ra,0x0
  d4:	2e8080e7          	jalr	744(ra) # 3b8 <exit>
    fprintf(2, "tournament_create failed\n");
  d8:	00001597          	auipc	a1,0x1
  dc:	b8058593          	addi	a1,a1,-1152 # c58 <tournament_release+0xda>
  e0:	4509                	li	a0,2
  e2:	00000097          	auipc	ra,0x0
  e6:	640080e7          	jalr	1600(ra) # 722 <fprintf>
    exit(1);
  ea:	4505                	li	a0,1
  ec:	00000097          	auipc	ra,0x0
  f0:	2cc080e7          	jalr	716(ra) # 3b8 <exit>
    fprintf(2, "Process %d failed to acquire tournament lock\n", index);
  f4:	8626                	mv	a2,s1
  f6:	00001597          	auipc	a1,0x1
  fa:	b8258593          	addi	a1,a1,-1150 # c78 <tournament_release+0xfa>
  fe:	4509                	li	a0,2
 100:	00000097          	auipc	ra,0x0
 104:	622080e7          	jalr	1570(ra) # 722 <fprintf>
    exit(1);
 108:	4505                	li	a0,1
 10a:	00000097          	auipc	ra,0x0
 10e:	2ae080e7          	jalr	686(ra) # 3b8 <exit>
    fprintf(2, "Process %d failed to release tournament lock\n", index);
 112:	8626                	mv	a2,s1
 114:	00001597          	auipc	a1,0x1
 118:	c0458593          	addi	a1,a1,-1020 # d18 <tournament_release+0x19a>
 11c:	4509                	li	a0,2
 11e:	00000097          	auipc	ra,0x0
 122:	604080e7          	jalr	1540(ra) # 722 <fprintf>
    exit(1);
 126:	4505                	li	a0,1
 128:	00000097          	auipc	ra,0x0
 12c:	290080e7          	jalr	656(ra) # 3b8 <exit>

0000000000000130 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 130:	1141                	addi	sp,sp,-16
 132:	e406                	sd	ra,8(sp)
 134:	e022                	sd	s0,0(sp)
 136:	0800                	addi	s0,sp,16
  extern int main();
  main();
 138:	00000097          	auipc	ra,0x0
 13c:	ec8080e7          	jalr	-312(ra) # 0 <main>
  exit(0);
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	276080e7          	jalr	630(ra) # 3b8 <exit>

000000000000014a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 150:	87aa                	mv	a5,a0
 152:	0585                	addi	a1,a1,1
 154:	0785                	addi	a5,a5,1
 156:	fff5c703          	lbu	a4,-1(a1)
 15a:	fee78fa3          	sb	a4,-1(a5)
 15e:	fb75                	bnez	a4,152 <strcpy+0x8>
    ;
  return os;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb91                	beqz	a5,184 <strcmp+0x1e>
 172:	0005c703          	lbu	a4,0(a1)
 176:	00f71763          	bne	a4,a5,184 <strcmp+0x1e>
    p++, q++;
 17a:	0505                	addi	a0,a0,1
 17c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbe5                	bnez	a5,172 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 184:	0005c503          	lbu	a0,0(a1)
}
 188:	40a7853b          	subw	a0,a5,a0
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strlen>:

uint
strlen(const char *s)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cf91                	beqz	a5,1b8 <strlen+0x26>
 19e:	0505                	addi	a0,a0,1
 1a0:	87aa                	mv	a5,a0
 1a2:	4685                	li	a3,1
 1a4:	9e89                	subw	a3,a3,a0
 1a6:	00f6853b          	addw	a0,a3,a5
 1aa:	0785                	addi	a5,a5,1
 1ac:	fff7c703          	lbu	a4,-1(a5)
 1b0:	fb7d                	bnez	a4,1a6 <strlen+0x14>
    ;
  return n;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  for(n = 0; s[n]; n++)
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strlen+0x20>

00000000000001bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c2:	ca19                	beqz	a2,1d8 <memset+0x1c>
 1c4:	87aa                	mv	a5,a0
 1c6:	1602                	slli	a2,a2,0x20
 1c8:	9201                	srli	a2,a2,0x20
 1ca:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d2:	0785                	addi	a5,a5,1
 1d4:	fee79de3          	bne	a5,a4,1ce <memset+0x12>
  }
  return dst;
}
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strchr>:

char*
strchr(const char *s, char c)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cb99                	beqz	a5,1fe <strchr+0x20>
    if(*s == c)
 1ea:	00f58763          	beq	a1,a5,1f8 <strchr+0x1a>
  for(; *s; s++)
 1ee:	0505                	addi	a0,a0,1
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	fbfd                	bnez	a5,1ea <strchr+0xc>
      return (char*)s;
  return 0;
 1f6:	4501                	li	a0,0
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  return 0;
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strchr+0x1a>

0000000000000202 <gets>:

char*
gets(char *buf, int max)
{
 202:	711d                	addi	sp,sp,-96
 204:	ec86                	sd	ra,88(sp)
 206:	e8a2                	sd	s0,80(sp)
 208:	e4a6                	sd	s1,72(sp)
 20a:	e0ca                	sd	s2,64(sp)
 20c:	fc4e                	sd	s3,56(sp)
 20e:	f852                	sd	s4,48(sp)
 210:	f456                	sd	s5,40(sp)
 212:	f05a                	sd	s6,32(sp)
 214:	ec5e                	sd	s7,24(sp)
 216:	1080                	addi	s0,sp,96
 218:	8baa                	mv	s7,a0
 21a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21c:	892a                	mv	s2,a0
 21e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 220:	4aa9                	li	s5,10
 222:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 224:	89a6                	mv	s3,s1
 226:	2485                	addiw	s1,s1,1
 228:	0344d863          	bge	s1,s4,258 <gets+0x56>
    cc = read(0, &c, 1);
 22c:	4605                	li	a2,1
 22e:	faf40593          	addi	a1,s0,-81
 232:	4501                	li	a0,0
 234:	00000097          	auipc	ra,0x0
 238:	19c080e7          	jalr	412(ra) # 3d0 <read>
    if(cc < 1)
 23c:	00a05e63          	blez	a0,258 <gets+0x56>
    buf[i++] = c;
 240:	faf44783          	lbu	a5,-81(s0)
 244:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 248:	01578763          	beq	a5,s5,256 <gets+0x54>
 24c:	0905                	addi	s2,s2,1
 24e:	fd679be3          	bne	a5,s6,224 <gets+0x22>
  for(i=0; i+1 < max; ){
 252:	89a6                	mv	s3,s1
 254:	a011                	j	258 <gets+0x56>
 256:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 258:	99de                	add	s3,s3,s7
 25a:	00098023          	sb	zero,0(s3)
  return buf;
}
 25e:	855e                	mv	a0,s7
 260:	60e6                	ld	ra,88(sp)
 262:	6446                	ld	s0,80(sp)
 264:	64a6                	ld	s1,72(sp)
 266:	6906                	ld	s2,64(sp)
 268:	79e2                	ld	s3,56(sp)
 26a:	7a42                	ld	s4,48(sp)
 26c:	7aa2                	ld	s5,40(sp)
 26e:	7b02                	ld	s6,32(sp)
 270:	6be2                	ld	s7,24(sp)
 272:	6125                	addi	sp,sp,96
 274:	8082                	ret

0000000000000276 <stat>:

int
stat(const char *n, struct stat *st)
{
 276:	1101                	addi	sp,sp,-32
 278:	ec06                	sd	ra,24(sp)
 27a:	e822                	sd	s0,16(sp)
 27c:	e426                	sd	s1,8(sp)
 27e:	e04a                	sd	s2,0(sp)
 280:	1000                	addi	s0,sp,32
 282:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 284:	4581                	li	a1,0
 286:	00000097          	auipc	ra,0x0
 28a:	172080e7          	jalr	370(ra) # 3f8 <open>
  if(fd < 0)
 28e:	02054563          	bltz	a0,2b8 <stat+0x42>
 292:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 294:	85ca                	mv	a1,s2
 296:	00000097          	auipc	ra,0x0
 29a:	17a080e7          	jalr	378(ra) # 410 <fstat>
 29e:	892a                	mv	s2,a0
  close(fd);
 2a0:	8526                	mv	a0,s1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	13e080e7          	jalr	318(ra) # 3e0 <close>
  return r;
}
 2aa:	854a                	mv	a0,s2
 2ac:	60e2                	ld	ra,24(sp)
 2ae:	6442                	ld	s0,16(sp)
 2b0:	64a2                	ld	s1,8(sp)
 2b2:	6902                	ld	s2,0(sp)
 2b4:	6105                	addi	sp,sp,32
 2b6:	8082                	ret
    return -1;
 2b8:	597d                	li	s2,-1
 2ba:	bfc5                	j	2aa <stat+0x34>

00000000000002bc <atoi>:

int
atoi(const char *s)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e422                	sd	s0,8(sp)
 2c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c2:	00054603          	lbu	a2,0(a0)
 2c6:	fd06079b          	addiw	a5,a2,-48
 2ca:	0ff7f793          	andi	a5,a5,255
 2ce:	4725                	li	a4,9
 2d0:	02f76963          	bltu	a4,a5,302 <atoi+0x46>
 2d4:	86aa                	mv	a3,a0
  n = 0;
 2d6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2d8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2da:	0685                	addi	a3,a3,1
 2dc:	0025179b          	slliw	a5,a0,0x2
 2e0:	9fa9                	addw	a5,a5,a0
 2e2:	0017979b          	slliw	a5,a5,0x1
 2e6:	9fb1                	addw	a5,a5,a2
 2e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ec:	0006c603          	lbu	a2,0(a3)
 2f0:	fd06071b          	addiw	a4,a2,-48
 2f4:	0ff77713          	andi	a4,a4,255
 2f8:	fee5f1e3          	bgeu	a1,a4,2da <atoi+0x1e>
  return n;
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  n = 0;
 302:	4501                	li	a0,0
 304:	bfe5                	j	2fc <atoi+0x40>

0000000000000306 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30c:	02b57463          	bgeu	a0,a1,334 <memmove+0x2e>
    while(n-- > 0)
 310:	00c05f63          	blez	a2,32e <memmove+0x28>
 314:	1602                	slli	a2,a2,0x20
 316:	9201                	srli	a2,a2,0x20
 318:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31c:	872a                	mv	a4,a0
      *dst++ = *src++;
 31e:	0585                	addi	a1,a1,1
 320:	0705                	addi	a4,a4,1
 322:	fff5c683          	lbu	a3,-1(a1)
 326:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32a:	fee79ae3          	bne	a5,a4,31e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
    dst += n;
 334:	00c50733          	add	a4,a0,a2
    src += n;
 338:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33a:	fec05ae3          	blez	a2,32e <memmove+0x28>
 33e:	fff6079b          	addiw	a5,a2,-1
 342:	1782                	slli	a5,a5,0x20
 344:	9381                	srli	a5,a5,0x20
 346:	fff7c793          	not	a5,a5
 34a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34c:	15fd                	addi	a1,a1,-1
 34e:	177d                	addi	a4,a4,-1
 350:	0005c683          	lbu	a3,0(a1)
 354:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 358:	fee79ae3          	bne	a5,a4,34c <memmove+0x46>
 35c:	bfc9                	j	32e <memmove+0x28>

000000000000035e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 364:	ca05                	beqz	a2,394 <memcmp+0x36>
 366:	fff6069b          	addiw	a3,a2,-1
 36a:	1682                	slli	a3,a3,0x20
 36c:	9281                	srli	a3,a3,0x20
 36e:	0685                	addi	a3,a3,1
 370:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 372:	00054783          	lbu	a5,0(a0)
 376:	0005c703          	lbu	a4,0(a1)
 37a:	00e79863          	bne	a5,a4,38a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 37e:	0505                	addi	a0,a0,1
    p2++;
 380:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 382:	fed518e3          	bne	a0,a3,372 <memcmp+0x14>
  }
  return 0;
 386:	4501                	li	a0,0
 388:	a019                	j	38e <memcmp+0x30>
      return *p1 - *p2;
 38a:	40e7853b          	subw	a0,a5,a4
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
  return 0;
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <memcmp+0x30>

0000000000000398 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e406                	sd	ra,8(sp)
 39c:	e022                	sd	s0,0(sp)
 39e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a0:	00000097          	auipc	ra,0x0
 3a4:	f66080e7          	jalr	-154(ra) # 306 <memmove>
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b0:	4885                	li	a7,1
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b8:	4889                	li	a7,2
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c0:	488d                	li	a7,3
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c8:	4891                	li	a7,4
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <read>:
.global read
read:
 li a7, SYS_read
 3d0:	4895                	li	a7,5
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <write>:
.global write
write:
 li a7, SYS_write
 3d8:	48c1                	li	a7,16
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <close>:
.global close
close:
 li a7, SYS_close
 3e0:	48d5                	li	a7,21
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e8:	4899                	li	a7,6
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f0:	489d                	li	a7,7
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <open>:
.global open
open:
 li a7, SYS_open
 3f8:	48bd                	li	a7,15
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 400:	48c5                	li	a7,17
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 408:	48c9                	li	a7,18
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 410:	48a1                	li	a7,8
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <link>:
.global link
link:
 li a7, SYS_link
 418:	48cd                	li	a7,19
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 420:	48d1                	li	a7,20
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 428:	48a5                	li	a7,9
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <dup>:
.global dup
dup:
 li a7, SYS_dup
 430:	48a9                	li	a7,10
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 438:	48ad                	li	a7,11
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 440:	48b1                	li	a7,12
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 448:	48b5                	li	a7,13
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 450:	48b9                	li	a7,14
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 458:	48d9                	li	a7,22
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 460:	48dd                	li	a7,23
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 468:	48e1                	li	a7,24
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 470:	48e5                	li	a7,25
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 478:	1101                	addi	sp,sp,-32
 47a:	ec06                	sd	ra,24(sp)
 47c:	e822                	sd	s0,16(sp)
 47e:	1000                	addi	s0,sp,32
 480:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 484:	4605                	li	a2,1
 486:	fef40593          	addi	a1,s0,-17
 48a:	00000097          	auipc	ra,0x0
 48e:	f4e080e7          	jalr	-178(ra) # 3d8 <write>
}
 492:	60e2                	ld	ra,24(sp)
 494:	6442                	ld	s0,16(sp)
 496:	6105                	addi	sp,sp,32
 498:	8082                	ret

000000000000049a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49a:	7139                	addi	sp,sp,-64
 49c:	fc06                	sd	ra,56(sp)
 49e:	f822                	sd	s0,48(sp)
 4a0:	f426                	sd	s1,40(sp)
 4a2:	f04a                	sd	s2,32(sp)
 4a4:	ec4e                	sd	s3,24(sp)
 4a6:	0080                	addi	s0,sp,64
 4a8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4aa:	c299                	beqz	a3,4b0 <printint+0x16>
 4ac:	0805c863          	bltz	a1,53c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b0:	2581                	sext.w	a1,a1
  neg = 0;
 4b2:	4881                	li	a7,0
 4b4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4b8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ba:	2601                	sext.w	a2,a2
 4bc:	00001517          	auipc	a0,0x1
 4c0:	89450513          	addi	a0,a0,-1900 # d50 <digits>
 4c4:	883a                	mv	a6,a4
 4c6:	2705                	addiw	a4,a4,1
 4c8:	02c5f7bb          	remuw	a5,a1,a2
 4cc:	1782                	slli	a5,a5,0x20
 4ce:	9381                	srli	a5,a5,0x20
 4d0:	97aa                	add	a5,a5,a0
 4d2:	0007c783          	lbu	a5,0(a5)
 4d6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4da:	0005879b          	sext.w	a5,a1
 4de:	02c5d5bb          	divuw	a1,a1,a2
 4e2:	0685                	addi	a3,a3,1
 4e4:	fec7f0e3          	bgeu	a5,a2,4c4 <printint+0x2a>
  if(neg)
 4e8:	00088b63          	beqz	a7,4fe <printint+0x64>
    buf[i++] = '-';
 4ec:	fd040793          	addi	a5,s0,-48
 4f0:	973e                	add	a4,a4,a5
 4f2:	02d00793          	li	a5,45
 4f6:	fef70823          	sb	a5,-16(a4)
 4fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4fe:	02e05863          	blez	a4,52e <printint+0x94>
 502:	fc040793          	addi	a5,s0,-64
 506:	00e78933          	add	s2,a5,a4
 50a:	fff78993          	addi	s3,a5,-1
 50e:	99ba                	add	s3,s3,a4
 510:	377d                	addiw	a4,a4,-1
 512:	1702                	slli	a4,a4,0x20
 514:	9301                	srli	a4,a4,0x20
 516:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51a:	fff94583          	lbu	a1,-1(s2)
 51e:	8526                	mv	a0,s1
 520:	00000097          	auipc	ra,0x0
 524:	f58080e7          	jalr	-168(ra) # 478 <putc>
  while(--i >= 0)
 528:	197d                	addi	s2,s2,-1
 52a:	ff3918e3          	bne	s2,s3,51a <printint+0x80>
}
 52e:	70e2                	ld	ra,56(sp)
 530:	7442                	ld	s0,48(sp)
 532:	74a2                	ld	s1,40(sp)
 534:	7902                	ld	s2,32(sp)
 536:	69e2                	ld	s3,24(sp)
 538:	6121                	addi	sp,sp,64
 53a:	8082                	ret
    x = -xx;
 53c:	40b005bb          	negw	a1,a1
    neg = 1;
 540:	4885                	li	a7,1
    x = -xx;
 542:	bf8d                	j	4b4 <printint+0x1a>

0000000000000544 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 544:	7119                	addi	sp,sp,-128
 546:	fc86                	sd	ra,120(sp)
 548:	f8a2                	sd	s0,112(sp)
 54a:	f4a6                	sd	s1,104(sp)
 54c:	f0ca                	sd	s2,96(sp)
 54e:	ecce                	sd	s3,88(sp)
 550:	e8d2                	sd	s4,80(sp)
 552:	e4d6                	sd	s5,72(sp)
 554:	e0da                	sd	s6,64(sp)
 556:	fc5e                	sd	s7,56(sp)
 558:	f862                	sd	s8,48(sp)
 55a:	f466                	sd	s9,40(sp)
 55c:	f06a                	sd	s10,32(sp)
 55e:	ec6e                	sd	s11,24(sp)
 560:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 562:	0005c903          	lbu	s2,0(a1)
 566:	18090f63          	beqz	s2,704 <vprintf+0x1c0>
 56a:	8aaa                	mv	s5,a0
 56c:	8b32                	mv	s6,a2
 56e:	00158493          	addi	s1,a1,1
  state = 0;
 572:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 574:	02500a13          	li	s4,37
      if(c == 'd'){
 578:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 57c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 580:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 584:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 588:	00000b97          	auipc	s7,0x0
 58c:	7c8b8b93          	addi	s7,s7,1992 # d50 <digits>
 590:	a839                	j	5ae <vprintf+0x6a>
        putc(fd, c);
 592:	85ca                	mv	a1,s2
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	ee2080e7          	jalr	-286(ra) # 478 <putc>
 59e:	a019                	j	5a4 <vprintf+0x60>
    } else if(state == '%'){
 5a0:	01498f63          	beq	s3,s4,5be <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5a4:	0485                	addi	s1,s1,1
 5a6:	fff4c903          	lbu	s2,-1(s1)
 5aa:	14090d63          	beqz	s2,704 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5ae:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b2:	fe0997e3          	bnez	s3,5a0 <vprintf+0x5c>
      if(c == '%'){
 5b6:	fd479ee3          	bne	a5,s4,592 <vprintf+0x4e>
        state = '%';
 5ba:	89be                	mv	s3,a5
 5bc:	b7e5                	j	5a4 <vprintf+0x60>
      if(c == 'd'){
 5be:	05878063          	beq	a5,s8,5fe <vprintf+0xba>
      } else if(c == 'l') {
 5c2:	05978c63          	beq	a5,s9,61a <vprintf+0xd6>
      } else if(c == 'x') {
 5c6:	07a78863          	beq	a5,s10,636 <vprintf+0xf2>
      } else if(c == 'p') {
 5ca:	09b78463          	beq	a5,s11,652 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ce:	07300713          	li	a4,115
 5d2:	0ce78663          	beq	a5,a4,69e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5d6:	06300713          	li	a4,99
 5da:	0ee78e63          	beq	a5,a4,6d6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5de:	11478863          	beq	a5,s4,6ee <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5e2:	85d2                	mv	a1,s4
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	e92080e7          	jalr	-366(ra) # 478 <putc>
        putc(fd, c);
 5ee:	85ca                	mv	a1,s2
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e86080e7          	jalr	-378(ra) # 478 <putc>
      }
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b765                	j	5a4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5fe:	008b0913          	addi	s2,s6,8
 602:	4685                	li	a3,1
 604:	4629                	li	a2,10
 606:	000b2583          	lw	a1,0(s6)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e8e080e7          	jalr	-370(ra) # 49a <printint>
 614:	8b4a                	mv	s6,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	b771                	j	5a4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	008b0913          	addi	s2,s6,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000b2583          	lw	a1,0(s6)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e72080e7          	jalr	-398(ra) # 49a <printint>
 630:	8b4a                	mv	s6,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	bf85                	j	5a4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 636:	008b0913          	addi	s2,s6,8
 63a:	4681                	li	a3,0
 63c:	4641                	li	a2,16
 63e:	000b2583          	lw	a1,0(s6)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e56080e7          	jalr	-426(ra) # 49a <printint>
 64c:	8b4a                	mv	s6,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	bf91                	j	5a4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 652:	008b0793          	addi	a5,s6,8
 656:	f8f43423          	sd	a5,-120(s0)
 65a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 65e:	03000593          	li	a1,48
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e14080e7          	jalr	-492(ra) # 478 <putc>
  putc(fd, 'x');
 66c:	85ea                	mv	a1,s10
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	e08080e7          	jalr	-504(ra) # 478 <putc>
 678:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67a:	03c9d793          	srli	a5,s3,0x3c
 67e:	97de                	add	a5,a5,s7
 680:	0007c583          	lbu	a1,0(a5)
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	df2080e7          	jalr	-526(ra) # 478 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68e:	0992                	slli	s3,s3,0x4
 690:	397d                	addiw	s2,s2,-1
 692:	fe0914e3          	bnez	s2,67a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 696:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b721                	j	5a4 <vprintf+0x60>
        s = va_arg(ap, char*);
 69e:	008b0993          	addi	s3,s6,8
 6a2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6a6:	02090163          	beqz	s2,6c8 <vprintf+0x184>
        while(*s != 0){
 6aa:	00094583          	lbu	a1,0(s2)
 6ae:	c9a1                	beqz	a1,6fe <vprintf+0x1ba>
          putc(fd, *s);
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	dc6080e7          	jalr	-570(ra) # 478 <putc>
          s++;
 6ba:	0905                	addi	s2,s2,1
        while(*s != 0){
 6bc:	00094583          	lbu	a1,0(s2)
 6c0:	f9e5                	bnez	a1,6b0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6c2:	8b4e                	mv	s6,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bdf9                	j	5a4 <vprintf+0x60>
          s = "(null)";
 6c8:	00000917          	auipc	s2,0x0
 6cc:	68090913          	addi	s2,s2,1664 # d48 <tournament_release+0x1ca>
        while(*s != 0){
 6d0:	02800593          	li	a1,40
 6d4:	bff1                	j	6b0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6d6:	008b0913          	addi	s2,s6,8
 6da:	000b4583          	lbu	a1,0(s6)
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	d98080e7          	jalr	-616(ra) # 478 <putc>
 6e8:	8b4a                	mv	s6,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bd65                	j	5a4 <vprintf+0x60>
        putc(fd, c);
 6ee:	85d2                	mv	a1,s4
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d86080e7          	jalr	-634(ra) # 478 <putc>
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b565                	j	5a4 <vprintf+0x60>
        s = va_arg(ap, char*);
 6fe:	8b4e                	mv	s6,s3
      state = 0;
 700:	4981                	li	s3,0
 702:	b54d                	j	5a4 <vprintf+0x60>
    }
  }
}
 704:	70e6                	ld	ra,120(sp)
 706:	7446                	ld	s0,112(sp)
 708:	74a6                	ld	s1,104(sp)
 70a:	7906                	ld	s2,96(sp)
 70c:	69e6                	ld	s3,88(sp)
 70e:	6a46                	ld	s4,80(sp)
 710:	6aa6                	ld	s5,72(sp)
 712:	6b06                	ld	s6,64(sp)
 714:	7be2                	ld	s7,56(sp)
 716:	7c42                	ld	s8,48(sp)
 718:	7ca2                	ld	s9,40(sp)
 71a:	7d02                	ld	s10,32(sp)
 71c:	6de2                	ld	s11,24(sp)
 71e:	6109                	addi	sp,sp,128
 720:	8082                	ret

0000000000000722 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 722:	715d                	addi	sp,sp,-80
 724:	ec06                	sd	ra,24(sp)
 726:	e822                	sd	s0,16(sp)
 728:	1000                	addi	s0,sp,32
 72a:	e010                	sd	a2,0(s0)
 72c:	e414                	sd	a3,8(s0)
 72e:	e818                	sd	a4,16(s0)
 730:	ec1c                	sd	a5,24(s0)
 732:	03043023          	sd	a6,32(s0)
 736:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 73e:	8622                	mv	a2,s0
 740:	00000097          	auipc	ra,0x0
 744:	e04080e7          	jalr	-508(ra) # 544 <vprintf>
}
 748:	60e2                	ld	ra,24(sp)
 74a:	6442                	ld	s0,16(sp)
 74c:	6161                	addi	sp,sp,80
 74e:	8082                	ret

0000000000000750 <printf>:

void
printf(const char *fmt, ...)
{
 750:	711d                	addi	sp,sp,-96
 752:	ec06                	sd	ra,24(sp)
 754:	e822                	sd	s0,16(sp)
 756:	1000                	addi	s0,sp,32
 758:	e40c                	sd	a1,8(s0)
 75a:	e810                	sd	a2,16(s0)
 75c:	ec14                	sd	a3,24(s0)
 75e:	f018                	sd	a4,32(s0)
 760:	f41c                	sd	a5,40(s0)
 762:	03043823          	sd	a6,48(s0)
 766:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76a:	00840613          	addi	a2,s0,8
 76e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 772:	85aa                	mv	a1,a0
 774:	4505                	li	a0,1
 776:	00000097          	auipc	ra,0x0
 77a:	dce080e7          	jalr	-562(ra) # 544 <vprintf>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6125                	addi	sp,sp,96
 784:	8082                	ret

0000000000000786 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 786:	1141                	addi	sp,sp,-16
 788:	e422                	sd	s0,8(sp)
 78a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 790:	00001797          	auipc	a5,0x1
 794:	8707b783          	ld	a5,-1936(a5) # 1000 <freep>
 798:	a805                	j	7c8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79a:	4618                	lw	a4,8(a2)
 79c:	9db9                	addw	a1,a1,a4
 79e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a2:	6398                	ld	a4,0(a5)
 7a4:	6318                	ld	a4,0(a4)
 7a6:	fee53823          	sd	a4,-16(a0)
 7aa:	a091                	j	7ee <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ac:	ff852703          	lw	a4,-8(a0)
 7b0:	9e39                	addw	a2,a2,a4
 7b2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7b4:	ff053703          	ld	a4,-16(a0)
 7b8:	e398                	sd	a4,0(a5)
 7ba:	a099                	j	800 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	6398                	ld	a4,0(a5)
 7be:	00e7e463          	bltu	a5,a4,7c6 <free+0x40>
 7c2:	00e6ea63          	bltu	a3,a4,7d6 <free+0x50>
{
 7c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c8:	fed7fae3          	bgeu	a5,a3,7bc <free+0x36>
 7cc:	6398                	ld	a4,0(a5)
 7ce:	00e6e463          	bltu	a3,a4,7d6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d2:	fee7eae3          	bltu	a5,a4,7c6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7d6:	ff852583          	lw	a1,-8(a0)
 7da:	6390                	ld	a2,0(a5)
 7dc:	02059713          	slli	a4,a1,0x20
 7e0:	9301                	srli	a4,a4,0x20
 7e2:	0712                	slli	a4,a4,0x4
 7e4:	9736                	add	a4,a4,a3
 7e6:	fae60ae3          	beq	a2,a4,79a <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ee:	4790                	lw	a2,8(a5)
 7f0:	02061713          	slli	a4,a2,0x20
 7f4:	9301                	srli	a4,a4,0x20
 7f6:	0712                	slli	a4,a4,0x4
 7f8:	973e                	add	a4,a4,a5
 7fa:	fae689e3          	beq	a3,a4,7ac <free+0x26>
  } else
    p->s.ptr = bp;
 7fe:	e394                	sd	a3,0(a5)
  freep = p;
 800:	00001717          	auipc	a4,0x1
 804:	80f73023          	sd	a5,-2048(a4) # 1000 <freep>
}
 808:	6422                	ld	s0,8(sp)
 80a:	0141                	addi	sp,sp,16
 80c:	8082                	ret

000000000000080e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80e:	7139                	addi	sp,sp,-64
 810:	fc06                	sd	ra,56(sp)
 812:	f822                	sd	s0,48(sp)
 814:	f426                	sd	s1,40(sp)
 816:	f04a                	sd	s2,32(sp)
 818:	ec4e                	sd	s3,24(sp)
 81a:	e852                	sd	s4,16(sp)
 81c:	e456                	sd	s5,8(sp)
 81e:	e05a                	sd	s6,0(sp)
 820:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 822:	02051493          	slli	s1,a0,0x20
 826:	9081                	srli	s1,s1,0x20
 828:	04bd                	addi	s1,s1,15
 82a:	8091                	srli	s1,s1,0x4
 82c:	0014899b          	addiw	s3,s1,1
 830:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 832:	00000517          	auipc	a0,0x0
 836:	7ce53503          	ld	a0,1998(a0) # 1000 <freep>
 83a:	c515                	beqz	a0,866 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	02977f63          	bgeu	a4,s1,87e <malloc+0x70>
 844:	8a4e                	mv	s4,s3
 846:	0009871b          	sext.w	a4,s3
 84a:	6685                	lui	a3,0x1
 84c:	00d77363          	bgeu	a4,a3,852 <malloc+0x44>
 850:	6a05                	lui	s4,0x1
 852:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 856:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85a:	00000917          	auipc	s2,0x0
 85e:	7a690913          	addi	s2,s2,1958 # 1000 <freep>
  if(p == (char*)-1)
 862:	5afd                	li	s5,-1
 864:	a88d                	j	8d6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 866:	00000797          	auipc	a5,0x0
 86a:	7ba78793          	addi	a5,a5,1978 # 1020 <base>
 86e:	00000717          	auipc	a4,0x0
 872:	78f73923          	sd	a5,1938(a4) # 1000 <freep>
 876:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 878:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87c:	b7e1                	j	844 <malloc+0x36>
      if(p->s.size == nunits)
 87e:	02e48b63          	beq	s1,a4,8b4 <malloc+0xa6>
        p->s.size -= nunits;
 882:	4137073b          	subw	a4,a4,s3
 886:	c798                	sw	a4,8(a5)
        p += p->s.size;
 888:	1702                	slli	a4,a4,0x20
 88a:	9301                	srli	a4,a4,0x20
 88c:	0712                	slli	a4,a4,0x4
 88e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 890:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 894:	00000717          	auipc	a4,0x0
 898:	76a73623          	sd	a0,1900(a4) # 1000 <freep>
      return (void*)(p + 1);
 89c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a0:	70e2                	ld	ra,56(sp)
 8a2:	7442                	ld	s0,48(sp)
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	7902                	ld	s2,32(sp)
 8a8:	69e2                	ld	s3,24(sp)
 8aa:	6a42                	ld	s4,16(sp)
 8ac:	6aa2                	ld	s5,8(sp)
 8ae:	6b02                	ld	s6,0(sp)
 8b0:	6121                	addi	sp,sp,64
 8b2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b4:	6398                	ld	a4,0(a5)
 8b6:	e118                	sd	a4,0(a0)
 8b8:	bff1                	j	894 <malloc+0x86>
  hp->s.size = nu;
 8ba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8be:	0541                	addi	a0,a0,16
 8c0:	00000097          	auipc	ra,0x0
 8c4:	ec6080e7          	jalr	-314(ra) # 786 <free>
  return freep;
 8c8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8cc:	d971                	beqz	a0,8a0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d0:	4798                	lw	a4,8(a5)
 8d2:	fa9776e3          	bgeu	a4,s1,87e <malloc+0x70>
    if(p == freep)
 8d6:	00093703          	ld	a4,0(s2)
 8da:	853e                	mv	a0,a5
 8dc:	fef719e3          	bne	a4,a5,8ce <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8e0:	8552                	mv	a0,s4
 8e2:	00000097          	auipc	ra,0x0
 8e6:	b5e080e7          	jalr	-1186(ra) # 440 <sbrk>
  if(p == (char*)-1)
 8ea:	fd5518e3          	bne	a0,s5,8ba <malloc+0xac>
        return 0;
 8ee:	4501                	li	a0,0
 8f0:	bf45                	j	8a0 <malloc+0x92>

00000000000008f2 <tournament_create>:
static int proc_id = 0;  // ID of the current process in the tournament
static int num_processes = 0;   // Number of processes in the tournament
static int num_levels = 0;      // Number of levels in the tournament tree
static int *lock_ids = 0;       // Array of Peterson lock IDs

int tournament_create(int processes) {
 8f2:	715d                	addi	sp,sp,-80
 8f4:	e486                	sd	ra,72(sp)
 8f6:	e0a2                	sd	s0,64(sp)
 8f8:	fc26                	sd	s1,56(sp)
 8fa:	f84a                	sd	s2,48(sp)
 8fc:	f44e                	sd	s3,40(sp)
 8fe:	f052                	sd	s4,32(sp)
 900:	ec56                	sd	s5,24(sp)
 902:	e85a                	sd	s6,16(sp)
 904:	e45e                	sd	s7,8(sp)
 906:	0880                	addi	s0,sp,80
    // Check if the number of processes is valid (power of 2 up to 16)
    if (processes <= 0 || processes > 16 || (processes & (processes - 1)) != 0) {
 908:	fff5071b          	addiw	a4,a0,-1
 90c:	47bd                	li	a5,15
 90e:	14e7e163          	bltu	a5,a4,a50 <tournament_create+0x15e>
 912:	8aaa                	mv	s5,a0
 914:	357d                	addiw	a0,a0,-1
 916:	8b3a                	mv	s6,a4
 918:	015777b3          	and	a5,a4,s5
 91c:	12079c63          	bnez	a5,a54 <tournament_create+0x162>
        return -1;  // Not a power of 2 or out of range
    }

    num_processes = processes;
 920:	00000797          	auipc	a5,0x0
 924:	6f57aa23          	sw	s5,1780(a5) # 1014 <num_processes>
    lock_ids = malloc(sizeof(int) * (num_processes - 1));
 928:	0025151b          	slliw	a0,a0,0x2
 92c:	00000097          	auipc	ra,0x0
 930:	ee2080e7          	jalr	-286(ra) # 80e <malloc>
 934:	00000797          	auipc	a5,0x0
 938:	6ca7ba23          	sd	a0,1748(a5) # 1008 <lock_ids>
    if (!lock_ids) {
 93c:	10050e63          	beqz	a0,a58 <tournament_create+0x166>
        return -1;  // Memory allocation failed
    }

    for (int i = 0; i < processes - 1; i++) {
 940:	05605063          	blez	s6,980 <tournament_create+0x8e>
 944:	4481                	li	s1,0
        lock_ids[i] = peterson_create();
 946:	00000a17          	auipc	s4,0x0
 94a:	6c2a0a13          	addi	s4,s4,1730 # 1008 <lock_ids>
 94e:	00048b9b          	sext.w	s7,s1
 952:	00249913          	slli	s2,s1,0x2
 956:	000a3983          	ld	s3,0(s4)
 95a:	99ca                	add	s3,s3,s2
 95c:	00000097          	auipc	ra,0x0
 960:	afc080e7          	jalr	-1284(ra) # 458 <peterson_create>
 964:	00a9a023          	sw	a0,0(s3)
        if (lock_ids[i] < 0) {
 968:	000a3783          	ld	a5,0(s4)
 96c:	993e                	add	s2,s2,a5
 96e:	00092783          	lw	a5,0(s2)
 972:	0607c163          	bltz	a5,9d4 <tournament_create+0xe2>
    for (int i = 0; i < processes - 1; i++) {
 976:	0485                	addi	s1,s1,1
 978:	0004879b          	sext.w	a5,s1
 97c:	fd67c9e3          	blt	a5,s6,94e <tournament_create+0x5c>
            return -1;
        }
    }

    // חישוב מספר הרמות בעץ: log2(processes)
    num_levels = 0;
 980:	00000797          	auipc	a5,0x0
 984:	6807a823          	sw	zero,1680(a5) # 1010 <num_levels>
    int temp = num_processes;
 988:	00000797          	auipc	a5,0x0
 98c:	68c7a783          	lw	a5,1676(a5) # 1014 <num_processes>
    while (temp > 1) {
 990:	4705                	li	a4,1
 992:	00f75e63          	bge	a4,a5,9ae <tournament_create+0xbc>
 996:	4605                	li	a2,1
        temp >>= 1;
 998:	4017d79b          	sraiw	a5,a5,0x1
        num_levels++;
 99c:	0007069b          	sext.w	a3,a4
    while (temp > 1) {
 9a0:	2705                	addiw	a4,a4,1
 9a2:	fef64be3          	blt	a2,a5,998 <tournament_create+0xa6>
 9a6:	00000797          	auipc	a5,0x0
 9aa:	66d7a523          	sw	a3,1642(a5) # 1010 <num_levels>
    }

    for (int i = 1; i < processes; i++) {
 9ae:	4785                	li	a5,1
 9b0:	0157dd63          	bge	a5,s5,9ca <tournament_create+0xd8>
 9b4:	4485                	li	s1,1
        int pid = fork();
 9b6:	00000097          	auipc	ra,0x0
 9ba:	9fa080e7          	jalr	-1542(ra) # 3b0 <fork>
        if (pid < 0) {
 9be:	06054a63          	bltz	a0,a32 <tournament_create+0x140>
            printf("fork failed!\n");
            return -1;
        }
        if (pid == 0) {
 9c2:	c151                	beqz	a0,a46 <tournament_create+0x154>
    for (int i = 1; i < processes; i++) {
 9c4:	2485                	addiw	s1,s1,1
 9c6:	fe9a98e3          	bne	s5,s1,9b6 <tournament_create+0xc4>
            proc_id = i;
            return proc_id;
        }
    }

    return proc_id;
 9ca:	00000497          	auipc	s1,0x0
 9ce:	64e4a483          	lw	s1,1614(s1) # 1018 <proc_id>
 9d2:	a0a1                	j	a1a <tournament_create+0x128>
            for (int j = 0; j < i; j++) {
 9d4:	03705763          	blez	s7,a02 <tournament_create+0x110>
 9d8:	34fd                	addiw	s1,s1,-1
 9da:	1482                	slli	s1,s1,0x20
 9dc:	9081                	srli	s1,s1,0x20
 9de:	0485                	addi	s1,s1,1
 9e0:	048a                	slli	s1,s1,0x2
 9e2:	4901                	li	s2,0
                peterson_destroy(lock_ids[j]);
 9e4:	00000997          	auipc	s3,0x0
 9e8:	62498993          	addi	s3,s3,1572 # 1008 <lock_ids>
 9ec:	0009b783          	ld	a5,0(s3)
 9f0:	97ca                	add	a5,a5,s2
 9f2:	4388                	lw	a0,0(a5)
 9f4:	00000097          	auipc	ra,0x0
 9f8:	a7c080e7          	jalr	-1412(ra) # 470 <peterson_destroy>
            for (int j = 0; j < i; j++) {
 9fc:	0911                	addi	s2,s2,4
 9fe:	fe9917e3          	bne	s2,s1,9ec <tournament_create+0xfa>
            free(lock_ids);
 a02:	00000497          	auipc	s1,0x0
 a06:	60648493          	addi	s1,s1,1542 # 1008 <lock_ids>
 a0a:	6088                	ld	a0,0(s1)
 a0c:	00000097          	auipc	ra,0x0
 a10:	d7a080e7          	jalr	-646(ra) # 786 <free>
            lock_ids = 0;
 a14:	0004b023          	sd	zero,0(s1)
            return -1;
 a18:	54fd                	li	s1,-1
}
 a1a:	8526                	mv	a0,s1
 a1c:	60a6                	ld	ra,72(sp)
 a1e:	6406                	ld	s0,64(sp)
 a20:	74e2                	ld	s1,56(sp)
 a22:	7942                	ld	s2,48(sp)
 a24:	79a2                	ld	s3,40(sp)
 a26:	7a02                	ld	s4,32(sp)
 a28:	6ae2                	ld	s5,24(sp)
 a2a:	6b42                	ld	s6,16(sp)
 a2c:	6ba2                	ld	s7,8(sp)
 a2e:	6161                	addi	sp,sp,80
 a30:	8082                	ret
            printf("fork failed!\n");
 a32:	00000517          	auipc	a0,0x0
 a36:	33650513          	addi	a0,a0,822 # d68 <digits+0x18>
 a3a:	00000097          	auipc	ra,0x0
 a3e:	d16080e7          	jalr	-746(ra) # 750 <printf>
            return -1;
 a42:	54fd                	li	s1,-1
 a44:	bfd9                	j	a1a <tournament_create+0x128>
            proc_id = i;
 a46:	00000797          	auipc	a5,0x0
 a4a:	5c97a923          	sw	s1,1490(a5) # 1018 <proc_id>
            return proc_id;
 a4e:	b7f1                	j	a1a <tournament_create+0x128>
        return -1;  // Not a power of 2 or out of range
 a50:	54fd                	li	s1,-1
 a52:	b7e1                	j	a1a <tournament_create+0x128>
 a54:	54fd                	li	s1,-1
 a56:	b7d1                	j	a1a <tournament_create+0x128>
        return -1;  // Memory allocation failed
 a58:	54fd                	li	s1,-1
 a5a:	b7c1                	j	a1a <tournament_create+0x128>

0000000000000a5c <tournament_acquire>:

int tournament_acquire(void) {
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 a5c:	00000797          	auipc	a5,0x0
 a60:	5b87a783          	lw	a5,1464(a5) # 1014 <num_processes>
 a64:	10078163          	beqz	a5,b66 <tournament_acquire+0x10a>
int tournament_acquire(void) {
 a68:	7139                	addi	sp,sp,-64
 a6a:	fc06                	sd	ra,56(sp)
 a6c:	f822                	sd	s0,48(sp)
 a6e:	f426                	sd	s1,40(sp)
 a70:	f04a                	sd	s2,32(sp)
 a72:	ec4e                	sd	s3,24(sp)
 a74:	e852                	sd	s4,16(sp)
 a76:	e456                	sd	s5,8(sp)
 a78:	0080                	addi	s0,sp,64
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 a7a:	00000497          	auipc	s1,0x0
 a7e:	5964a483          	lw	s1,1430(s1) # 1010 <num_levels>
 a82:	c4e5                	beqz	s1,b6a <tournament_acquire+0x10e>
 a84:	00000797          	auipc	a5,0x0
 a88:	5847b783          	ld	a5,1412(a5) # 1008 <lock_ids>
 a8c:	c3ed                	beqz	a5,b6e <tournament_acquire+0x112>
        return -1;  // Tournament not initialized
    }

    int node = proc_id, role;
    for (int i = num_levels - 1; i >= 0; i--) {
 a8e:	34fd                	addiw	s1,s1,-1
 a90:	0e04c163          	bltz	s1,b72 <tournament_acquire+0x116>
        // חישוב תפקיד (role) עבור הרמה הנוכחית
        int shift = num_levels - i - 1;
 a94:	00000a17          	auipc	s4,0x0
 a98:	57ca0a13          	addi	s4,s4,1404 # 1010 <num_levels>
        role = (proc_id & (1 << shift)) >> shift;
 a9c:	00000997          	auipc	s3,0x0
 aa0:	57c98993          	addi	s3,s3,1404 # 1018 <proc_id>
 aa4:	4905                	li	s2,1
    for (int i = num_levels - 1; i >= 0; i--) {
 aa6:	5afd                	li	s5,-1
        int shift = num_levels - i - 1;
 aa8:	000a2783          	lw	a5,0(s4)
 aac:	4097873b          	subw	a4,a5,s1
 ab0:	fff7059b          	addiw	a1,a4,-1
        role = (proc_id & (1 << shift)) >> shift;
 ab4:	0009a783          	lw	a5,0(s3)
 ab8:	00b916bb          	sllw	a3,s2,a1
 abc:	8efd                	and	a3,a3,a5

        // חישוב אינדקס של המנעול ברמה זו
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 abe:	0099153b          	sllw	a0,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 ac2:	40e7d7bb          	sraw	a5,a5,a4
        node = lock_level_idx + (1 << i) - 1;
 ac6:	9d3d                	addw	a0,a0,a5

        if (peterson_acquire(node, role) < 0) {
 ac8:	40b6d5bb          	sraw	a1,a3,a1
 acc:	357d                	addiw	a0,a0,-1
 ace:	00000097          	auipc	ra,0x0
 ad2:	992080e7          	jalr	-1646(ra) # 460 <peterson_acquire>
 ad6:	00054f63          	bltz	a0,af4 <tournament_acquire+0x98>
    for (int i = num_levels - 1; i >= 0; i--) {
 ada:	34fd                	addiw	s1,s1,-1
 adc:	fd5496e3          	bne	s1,s5,aa8 <tournament_acquire+0x4c>
            }
            return -1;
        }
    }

    return 0;
 ae0:	4501                	li	a0,0
}
 ae2:	70e2                	ld	ra,56(sp)
 ae4:	7442                	ld	s0,48(sp)
 ae6:	74a2                	ld	s1,40(sp)
 ae8:	7902                	ld	s2,32(sp)
 aea:	69e2                	ld	s3,24(sp)
 aec:	6a42                	ld	s4,16(sp)
 aee:	6aa2                	ld	s5,8(sp)
 af0:	6121                	addi	sp,sp,64
 af2:	8082                	ret
            printf("failed to acquire: %d \n", proc_id);
 af4:	00000597          	auipc	a1,0x0
 af8:	5245a583          	lw	a1,1316(a1) # 1018 <proc_id>
 afc:	00000517          	auipc	a0,0x0
 b00:	27c50513          	addi	a0,a0,636 # d78 <digits+0x28>
 b04:	00000097          	auipc	ra,0x0
 b08:	c4c080e7          	jalr	-948(ra) # 750 <printf>
            for (int j = i; j < num_levels; j++) {
 b0c:	00000517          	auipc	a0,0x0
 b10:	50452503          	lw	a0,1284(a0) # 1010 <num_levels>
 b14:	06a4d163          	bge	s1,a0,b76 <tournament_acquire+0x11a>
                int r = (proc_id & (1 << shift2)) >> shift2;
 b18:	00000997          	auipc	s3,0x0
 b1c:	50098993          	addi	s3,s3,1280 # 1018 <proc_id>
 b20:	4905                	li	s2,1
            for (int j = i; j < num_levels; j++) {
 b22:	00000a17          	auipc	s4,0x0
 b26:	4eea0a13          	addi	s4,s4,1262 # 1010 <num_levels>
                int shift2 = num_levels - j - 1;
 b2a:	409507bb          	subw	a5,a0,s1
 b2e:	fff7859b          	addiw	a1,a5,-1
                int r = (proc_id & (1 << shift2)) >> shift2;
 b32:	0009a503          	lw	a0,0(s3)
 b36:	00b9173b          	sllw	a4,s2,a1
 b3a:	8f69                	and	a4,a4,a0
                int li = (proc_id >> (num_levels - j)) + (1 << j) - 1;
 b3c:	40f5553b          	sraw	a0,a0,a5
 b40:	009917bb          	sllw	a5,s2,s1
 b44:	9d3d                	addw	a0,a0,a5
                if (peterson_release(li, r) < 0) {
 b46:	40b755bb          	sraw	a1,a4,a1
 b4a:	357d                	addiw	a0,a0,-1
 b4c:	00000097          	auipc	ra,0x0
 b50:	91c080e7          	jalr	-1764(ra) # 468 <peterson_release>
 b54:	02054363          	bltz	a0,b7a <tournament_acquire+0x11e>
            for (int j = i; j < num_levels; j++) {
 b58:	2485                	addiw	s1,s1,1
 b5a:	000a2503          	lw	a0,0(s4)
 b5e:	fca4c6e3          	blt	s1,a0,b2a <tournament_acquire+0xce>
            return -1;
 b62:	557d                	li	a0,-1
 b64:	bfbd                	j	ae2 <tournament_acquire+0x86>
        return -1;  // Tournament not initialized
 b66:	557d                	li	a0,-1
}
 b68:	8082                	ret
        return -1;  // Tournament not initialized
 b6a:	557d                	li	a0,-1
 b6c:	bf9d                	j	ae2 <tournament_acquire+0x86>
 b6e:	557d                	li	a0,-1
 b70:	bf8d                	j	ae2 <tournament_acquire+0x86>
    return 0;
 b72:	4501                	li	a0,0
 b74:	b7bd                	j	ae2 <tournament_acquire+0x86>
            return -1;
 b76:	557d                	li	a0,-1
 b78:	b7ad                	j	ae2 <tournament_acquire+0x86>
                    return -1;
 b7a:	557d                	li	a0,-1
 b7c:	b79d                	j	ae2 <tournament_acquire+0x86>

0000000000000b7e <tournament_release>:

int tournament_release(void) {
    int node = proc_id, role;
    for (int i = 0; i < num_levels; i++) {
 b7e:	00000517          	auipc	a0,0x0
 b82:	49252503          	lw	a0,1170(a0) # 1010 <num_levels>
 b86:	06a05263          	blez	a0,bea <tournament_release+0x6c>
int tournament_release(void) {
 b8a:	7179                	addi	sp,sp,-48
 b8c:	f406                	sd	ra,40(sp)
 b8e:	f022                	sd	s0,32(sp)
 b90:	ec26                	sd	s1,24(sp)
 b92:	e84a                	sd	s2,16(sp)
 b94:	e44e                	sd	s3,8(sp)
 b96:	e052                	sd	s4,0(sp)
 b98:	1800                	addi	s0,sp,48
    for (int i = 0; i < num_levels; i++) {
 b9a:	4481                	li	s1,0
        // חישוב תפקיד (role)
        int shift = num_levels - i - 1;
        role = (proc_id & (1 << shift)) >> shift;
 b9c:	00000997          	auipc	s3,0x0
 ba0:	47c98993          	addi	s3,s3,1148 # 1018 <proc_id>
 ba4:	4905                	li	s2,1
    for (int i = 0; i < num_levels; i++) {
 ba6:	00000a17          	auipc	s4,0x0
 baa:	46aa0a13          	addi	s4,s4,1130 # 1010 <num_levels>
        int shift = num_levels - i - 1;
 bae:	9d05                	subw	a0,a0,s1
 bb0:	fff5059b          	addiw	a1,a0,-1
        role = (proc_id & (1 << shift)) >> shift;
 bb4:	0009a703          	lw	a4,0(s3)
 bb8:	00b916bb          	sllw	a3,s2,a1
 bbc:	8ef9                	and	a3,a3,a4

        // חישוב אינדקס של המנעול
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 bbe:	009917bb          	sllw	a5,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 bc2:	40a7573b          	sraw	a4,a4,a0
        node = lock_level_idx + (1 << i) - 1;
 bc6:	00e7853b          	addw	a0,a5,a4

        if (peterson_release(node, role) < 0) {
 bca:	40b6d5bb          	sraw	a1,a3,a1
 bce:	357d                	addiw	a0,a0,-1
 bd0:	00000097          	auipc	ra,0x0
 bd4:	898080e7          	jalr	-1896(ra) # 468 <peterson_release>
 bd8:	00054b63          	bltz	a0,bee <tournament_release+0x70>
    for (int i = 0; i < num_levels; i++) {
 bdc:	2485                	addiw	s1,s1,1
 bde:	000a2503          	lw	a0,0(s4)
 be2:	fca4c6e3          	blt	s1,a0,bae <tournament_release+0x30>
            return -1;
        }
    }
    return 0;
 be6:	4501                	li	a0,0
 be8:	a021                	j	bf0 <tournament_release+0x72>
 bea:	4501                	li	a0,0
}
 bec:	8082                	ret
            return -1;
 bee:	557d                	li	a0,-1
}
 bf0:	70a2                	ld	ra,40(sp)
 bf2:	7402                	ld	s0,32(sp)
 bf4:	64e2                	ld	s1,24(sp)
 bf6:	6942                	ld	s2,16(sp)
 bf8:	69a2                	ld	s3,8(sp)
 bfa:	6a02                	ld	s4,0(sp)
 bfc:	6145                	addi	sp,sp,48
 bfe:	8082                	ret

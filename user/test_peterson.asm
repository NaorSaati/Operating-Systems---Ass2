
user/_test_peterson:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	0880                	addi	s0,sp,80
    int lock_id = peterson_create();
  16:	00000097          	auipc	ra,0x0
  1a:	45e080e7          	jalr	1118(ra) # 474 <peterson_create>
    if (lock_id < 0) {
  1e:	02054e63          	bltz	a0,5a <main+0x5a>
  22:	892a                	mv	s2,a0
        printf("Failed to create lock\n");
        exit(1);
    }

    printf("Created lock %d\n", lock_id);
  24:	85aa                	mv	a1,a0
  26:	00001517          	auipc	a0,0x1
  2a:	c1250513          	addi	a0,a0,-1006 # c38 <tournament_release+0x9e>
  2e:	00000097          	auipc	ra,0x0
  32:	73e080e7          	jalr	1854(ra) # 76c <printf>

    int fork_ret = fork();
  36:	00000097          	auipc	ra,0x0
  3a:	396080e7          	jalr	918(ra) # 3cc <fork>
  3e:	8a2a                	mv	s4,a0
    int role = fork_ret > 0 ? 0 : 1;
  40:	00152993          	slti	s3,a0,1

    for (int i = 0; i < 10; i++) {
  44:	4481                	li	s1,0

        // Critical section
        if (role == 0)
            printf("[PARENT] In critical section (iteration %d)\n", i);
        else
            printf("[CHILD ] In critical section (iteration %d)\n", i);
  46:	00001b97          	auipc	s7,0x1
  4a:	c52b8b93          	addi	s7,s7,-942 # c98 <tournament_release+0xfe>
            printf("[PARENT] In critical section (iteration %d)\n", i);
  4e:	00001b17          	auipc	s6,0x1
  52:	c1ab0b13          	addi	s6,s6,-998 # c68 <tournament_release+0xce>
    for (int i = 0; i < 10; i++) {
  56:	4aa9                	li	s5,10
  58:	a8a1                	j	b0 <main+0xb0>
        printf("Failed to create lock\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	bc650513          	addi	a0,a0,-1082 # c20 <tournament_release+0x86>
  62:	00000097          	auipc	ra,0x0
  66:	70a080e7          	jalr	1802(ra) # 76c <printf>
        exit(1);
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	368080e7          	jalr	872(ra) # 3d4 <exit>
            printf("Failed to acquire lock\n");
  74:	00001517          	auipc	a0,0x1
  78:	bdc50513          	addi	a0,a0,-1060 # c50 <tournament_release+0xb6>
  7c:	00000097          	auipc	ra,0x0
  80:	6f0080e7          	jalr	1776(ra) # 76c <printf>
            exit(1);
  84:	4505                	li	a0,1
  86:	00000097          	auipc	ra,0x0
  8a:	34e080e7          	jalr	846(ra) # 3d4 <exit>
            printf("[CHILD ] In critical section (iteration %d)\n", i);
  8e:	85a6                	mv	a1,s1
  90:	855e                	mv	a0,s7
  92:	00000097          	auipc	ra,0x0
  96:	6da080e7          	jalr	1754(ra) # 76c <printf>

        if (peterson_release(lock_id, role) < 0) {
  9a:	85ce                	mv	a1,s3
  9c:	854a                	mv	a0,s2
  9e:	00000097          	auipc	ra,0x0
  a2:	3e6080e7          	jalr	998(ra) # 484 <peterson_release>
  a6:	02054663          	bltz	a0,d2 <main+0xd2>
    for (int i = 0; i < 10; i++) {
  aa:	2485                	addiw	s1,s1,1
  ac:	05548063          	beq	s1,s5,ec <main+0xec>
        if (peterson_acquire(lock_id, role) < 0) {
  b0:	85ce                	mv	a1,s3
  b2:	854a                	mv	a0,s2
  b4:	00000097          	auipc	ra,0x0
  b8:	3c8080e7          	jalr	968(ra) # 47c <peterson_acquire>
  bc:	fa054ce3          	bltz	a0,74 <main+0x74>
        if (role == 0)
  c0:	fd4057e3          	blez	s4,8e <main+0x8e>
            printf("[PARENT] In critical section (iteration %d)\n", i);
  c4:	85a6                	mv	a1,s1
  c6:	855a                	mv	a0,s6
  c8:	00000097          	auipc	ra,0x0
  cc:	6a4080e7          	jalr	1700(ra) # 76c <printf>
  d0:	b7e9                	j	9a <main+0x9a>
            printf("Failed to release lock\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	bf650513          	addi	a0,a0,-1034 # cc8 <tournament_release+0x12e>
  da:	00000097          	auipc	ra,0x0
  de:	692080e7          	jalr	1682(ra) # 76c <printf>
            exit(1);
  e2:	4505                	li	a0,1
  e4:	00000097          	auipc	ra,0x0
  e8:	2f0080e7          	jalr	752(ra) # 3d4 <exit>
        }

    }

    if (fork_ret > 0) {
  ec:	03405e63          	blez	s4,128 <main+0x128>
        wait(0);
  f0:	4501                	li	a0,0
  f2:	00000097          	auipc	ra,0x0
  f6:	2ea080e7          	jalr	746(ra) # 3dc <wait>
        printf("Parent destroying lock\n");
  fa:	00001517          	auipc	a0,0x1
  fe:	be650513          	addi	a0,a0,-1050 # ce0 <tournament_release+0x146>
 102:	00000097          	auipc	ra,0x0
 106:	66a080e7          	jalr	1642(ra) # 76c <printf>
        if (peterson_destroy(lock_id) < 0) {
 10a:	854a                	mv	a0,s2
 10c:	00000097          	auipc	ra,0x0
 110:	380080e7          	jalr	896(ra) # 48c <peterson_destroy>
 114:	00054f63          	bltz	a0,132 <main+0x132>
            printf("Failed to destroy lock\n");
            exit(1);
        }
        printf("Lock destroyed\n");
 118:	00001517          	auipc	a0,0x1
 11c:	bf850513          	addi	a0,a0,-1032 # d10 <tournament_release+0x176>
 120:	00000097          	auipc	ra,0x0
 124:	64c080e7          	jalr	1612(ra) # 76c <printf>
    }

    exit(0);
 128:	4501                	li	a0,0
 12a:	00000097          	auipc	ra,0x0
 12e:	2aa080e7          	jalr	682(ra) # 3d4 <exit>
            printf("Failed to destroy lock\n");
 132:	00001517          	auipc	a0,0x1
 136:	bc650513          	addi	a0,a0,-1082 # cf8 <tournament_release+0x15e>
 13a:	00000097          	auipc	ra,0x0
 13e:	632080e7          	jalr	1586(ra) # 76c <printf>
            exit(1);
 142:	4505                	li	a0,1
 144:	00000097          	auipc	ra,0x0
 148:	290080e7          	jalr	656(ra) # 3d4 <exit>

000000000000014c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e406                	sd	ra,8(sp)
 150:	e022                	sd	s0,0(sp)
 152:	0800                	addi	s0,sp,16
  extern int main();
  main();
 154:	00000097          	auipc	ra,0x0
 158:	eac080e7          	jalr	-340(ra) # 0 <main>
  exit(0);
 15c:	4501                	li	a0,0
 15e:	00000097          	auipc	ra,0x0
 162:	276080e7          	jalr	630(ra) # 3d4 <exit>

0000000000000166 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16c:	87aa                	mv	a5,a0
 16e:	0585                	addi	a1,a1,1
 170:	0785                	addi	a5,a5,1
 172:	fff5c703          	lbu	a4,-1(a1)
 176:	fee78fa3          	sb	a4,-1(a5)
 17a:	fb75                	bnez	a4,16e <strcpy+0x8>
    ;
  return os;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cb91                	beqz	a5,1a0 <strcmp+0x1e>
 18e:	0005c703          	lbu	a4,0(a1)
 192:	00f71763          	bne	a4,a5,1a0 <strcmp+0x1e>
    p++, q++;
 196:	0505                	addi	a0,a0,1
 198:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	fbe5                	bnez	a5,18e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a0:	0005c503          	lbu	a0,0(a1)
}
 1a4:	40a7853b          	subw	a0,a5,a0
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strlen>:

uint
strlen(const char *s)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	cf91                	beqz	a5,1d4 <strlen+0x26>
 1ba:	0505                	addi	a0,a0,1
 1bc:	87aa                	mv	a5,a0
 1be:	4685                	li	a3,1
 1c0:	9e89                	subw	a3,a3,a0
 1c2:	00f6853b          	addw	a0,a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	fb7d                	bnez	a4,1c2 <strlen+0x14>
    ;
  return n;
}
 1ce:	6422                	ld	s0,8(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret
  for(n = 0; s[n]; n++)
 1d4:	4501                	li	a0,0
 1d6:	bfe5                	j	1ce <strlen+0x20>

00000000000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1de:	ca19                	beqz	a2,1f4 <memset+0x1c>
 1e0:	87aa                	mv	a5,a0
 1e2:	1602                	slli	a2,a2,0x20
 1e4:	9201                	srli	a2,a2,0x20
 1e6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ee:	0785                	addi	a5,a5,1
 1f0:	fee79de3          	bne	a5,a4,1ea <memset+0x12>
  }
  return dst;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret

00000000000001fa <strchr>:

char*
strchr(const char *s, char c)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  for(; *s; s++)
 200:	00054783          	lbu	a5,0(a0)
 204:	cb99                	beqz	a5,21a <strchr+0x20>
    if(*s == c)
 206:	00f58763          	beq	a1,a5,214 <strchr+0x1a>
  for(; *s; s++)
 20a:	0505                	addi	a0,a0,1
 20c:	00054783          	lbu	a5,0(a0)
 210:	fbfd                	bnez	a5,206 <strchr+0xc>
      return (char*)s;
  return 0;
 212:	4501                	li	a0,0
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
  return 0;
 21a:	4501                	li	a0,0
 21c:	bfe5                	j	214 <strchr+0x1a>

000000000000021e <gets>:

char*
gets(char *buf, int max)
{
 21e:	711d                	addi	sp,sp,-96
 220:	ec86                	sd	ra,88(sp)
 222:	e8a2                	sd	s0,80(sp)
 224:	e4a6                	sd	s1,72(sp)
 226:	e0ca                	sd	s2,64(sp)
 228:	fc4e                	sd	s3,56(sp)
 22a:	f852                	sd	s4,48(sp)
 22c:	f456                	sd	s5,40(sp)
 22e:	f05a                	sd	s6,32(sp)
 230:	ec5e                	sd	s7,24(sp)
 232:	1080                	addi	s0,sp,96
 234:	8baa                	mv	s7,a0
 236:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 238:	892a                	mv	s2,a0
 23a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 23c:	4aa9                	li	s5,10
 23e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
 242:	2485                	addiw	s1,s1,1
 244:	0344d863          	bge	s1,s4,274 <gets+0x56>
    cc = read(0, &c, 1);
 248:	4605                	li	a2,1
 24a:	faf40593          	addi	a1,s0,-81
 24e:	4501                	li	a0,0
 250:	00000097          	auipc	ra,0x0
 254:	19c080e7          	jalr	412(ra) # 3ec <read>
    if(cc < 1)
 258:	00a05e63          	blez	a0,274 <gets+0x56>
    buf[i++] = c;
 25c:	faf44783          	lbu	a5,-81(s0)
 260:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 264:	01578763          	beq	a5,s5,272 <gets+0x54>
 268:	0905                	addi	s2,s2,1
 26a:	fd679be3          	bne	a5,s6,240 <gets+0x22>
  for(i=0; i+1 < max; ){
 26e:	89a6                	mv	s3,s1
 270:	a011                	j	274 <gets+0x56>
 272:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 274:	99de                	add	s3,s3,s7
 276:	00098023          	sb	zero,0(s3)
  return buf;
}
 27a:	855e                	mv	a0,s7
 27c:	60e6                	ld	ra,88(sp)
 27e:	6446                	ld	s0,80(sp)
 280:	64a6                	ld	s1,72(sp)
 282:	6906                	ld	s2,64(sp)
 284:	79e2                	ld	s3,56(sp)
 286:	7a42                	ld	s4,48(sp)
 288:	7aa2                	ld	s5,40(sp)
 28a:	7b02                	ld	s6,32(sp)
 28c:	6be2                	ld	s7,24(sp)
 28e:	6125                	addi	sp,sp,96
 290:	8082                	ret

0000000000000292 <stat>:

int
stat(const char *n, struct stat *st)
{
 292:	1101                	addi	sp,sp,-32
 294:	ec06                	sd	ra,24(sp)
 296:	e822                	sd	s0,16(sp)
 298:	e426                	sd	s1,8(sp)
 29a:	e04a                	sd	s2,0(sp)
 29c:	1000                	addi	s0,sp,32
 29e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a0:	4581                	li	a1,0
 2a2:	00000097          	auipc	ra,0x0
 2a6:	172080e7          	jalr	370(ra) # 414 <open>
  if(fd < 0)
 2aa:	02054563          	bltz	a0,2d4 <stat+0x42>
 2ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b0:	85ca                	mv	a1,s2
 2b2:	00000097          	auipc	ra,0x0
 2b6:	17a080e7          	jalr	378(ra) # 42c <fstat>
 2ba:	892a                	mv	s2,a0
  close(fd);
 2bc:	8526                	mv	a0,s1
 2be:	00000097          	auipc	ra,0x0
 2c2:	13e080e7          	jalr	318(ra) # 3fc <close>
  return r;
}
 2c6:	854a                	mv	a0,s2
 2c8:	60e2                	ld	ra,24(sp)
 2ca:	6442                	ld	s0,16(sp)
 2cc:	64a2                	ld	s1,8(sp)
 2ce:	6902                	ld	s2,0(sp)
 2d0:	6105                	addi	sp,sp,32
 2d2:	8082                	ret
    return -1;
 2d4:	597d                	li	s2,-1
 2d6:	bfc5                	j	2c6 <stat+0x34>

00000000000002d8 <atoi>:

int
atoi(const char *s)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e422                	sd	s0,8(sp)
 2dc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2de:	00054603          	lbu	a2,0(a0)
 2e2:	fd06079b          	addiw	a5,a2,-48
 2e6:	0ff7f793          	andi	a5,a5,255
 2ea:	4725                	li	a4,9
 2ec:	02f76963          	bltu	a4,a5,31e <atoi+0x46>
 2f0:	86aa                	mv	a3,a0
  n = 0;
 2f2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2f4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2f6:	0685                	addi	a3,a3,1
 2f8:	0025179b          	slliw	a5,a0,0x2
 2fc:	9fa9                	addw	a5,a5,a0
 2fe:	0017979b          	slliw	a5,a5,0x1
 302:	9fb1                	addw	a5,a5,a2
 304:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 308:	0006c603          	lbu	a2,0(a3)
 30c:	fd06071b          	addiw	a4,a2,-48
 310:	0ff77713          	andi	a4,a4,255
 314:	fee5f1e3          	bgeu	a1,a4,2f6 <atoi+0x1e>
  return n;
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  n = 0;
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <atoi+0x40>

0000000000000322 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 328:	02b57463          	bgeu	a0,a1,350 <memmove+0x2e>
    while(n-- > 0)
 32c:	00c05f63          	blez	a2,34a <memmove+0x28>
 330:	1602                	slli	a2,a2,0x20
 332:	9201                	srli	a2,a2,0x20
 334:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 338:	872a                	mv	a4,a0
      *dst++ = *src++;
 33a:	0585                	addi	a1,a1,1
 33c:	0705                	addi	a4,a4,1
 33e:	fff5c683          	lbu	a3,-1(a1)
 342:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
    dst += n;
 350:	00c50733          	add	a4,a0,a2
    src += n;
 354:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 356:	fec05ae3          	blez	a2,34a <memmove+0x28>
 35a:	fff6079b          	addiw	a5,a2,-1
 35e:	1782                	slli	a5,a5,0x20
 360:	9381                	srli	a5,a5,0x20
 362:	fff7c793          	not	a5,a5
 366:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 368:	15fd                	addi	a1,a1,-1
 36a:	177d                	addi	a4,a4,-1
 36c:	0005c683          	lbu	a3,0(a1)
 370:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 374:	fee79ae3          	bne	a5,a4,368 <memmove+0x46>
 378:	bfc9                	j	34a <memmove+0x28>

000000000000037a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e422                	sd	s0,8(sp)
 37e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 380:	ca05                	beqz	a2,3b0 <memcmp+0x36>
 382:	fff6069b          	addiw	a3,a2,-1
 386:	1682                	slli	a3,a3,0x20
 388:	9281                	srli	a3,a3,0x20
 38a:	0685                	addi	a3,a3,1
 38c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 38e:	00054783          	lbu	a5,0(a0)
 392:	0005c703          	lbu	a4,0(a1)
 396:	00e79863          	bne	a5,a4,3a6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 39a:	0505                	addi	a0,a0,1
    p2++;
 39c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39e:	fed518e3          	bne	a0,a3,38e <memcmp+0x14>
  }
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	a019                	j	3aa <memcmp+0x30>
      return *p1 - *p2;
 3a6:	40e7853b          	subw	a0,a5,a4
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  return 0;
 3b0:	4501                	li	a0,0
 3b2:	bfe5                	j	3aa <memcmp+0x30>

00000000000003b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e406                	sd	ra,8(sp)
 3b8:	e022                	sd	s0,0(sp)
 3ba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3bc:	00000097          	auipc	ra,0x0
 3c0:	f66080e7          	jalr	-154(ra) # 322 <memmove>
}
 3c4:	60a2                	ld	ra,8(sp)
 3c6:	6402                	ld	s0,0(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret

00000000000003cc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3cc:	4885                	li	a7,1
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d4:	4889                	li	a7,2
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3dc:	488d                	li	a7,3
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e4:	4891                	li	a7,4
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <read>:
.global read
read:
 li a7, SYS_read
 3ec:	4895                	li	a7,5
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <write>:
.global write
write:
 li a7, SYS_write
 3f4:	48c1                	li	a7,16
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <close>:
.global close
close:
 li a7, SYS_close
 3fc:	48d5                	li	a7,21
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <kill>:
.global kill
kill:
 li a7, SYS_kill
 404:	4899                	li	a7,6
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <exec>:
.global exec
exec:
 li a7, SYS_exec
 40c:	489d                	li	a7,7
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <open>:
.global open
open:
 li a7, SYS_open
 414:	48bd                	li	a7,15
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41c:	48c5                	li	a7,17
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 424:	48c9                	li	a7,18
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42c:	48a1                	li	a7,8
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <link>:
.global link
link:
 li a7, SYS_link
 434:	48cd                	li	a7,19
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43c:	48d1                	li	a7,20
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 444:	48a5                	li	a7,9
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <dup>:
.global dup
dup:
 li a7, SYS_dup
 44c:	48a9                	li	a7,10
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 454:	48ad                	li	a7,11
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 45c:	48b1                	li	a7,12
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 464:	48b5                	li	a7,13
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46c:	48b9                	li	a7,14
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 474:	48d9                	li	a7,22
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 47c:	48dd                	li	a7,23
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 484:	48e1                	li	a7,24
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 48c:	48e5                	li	a7,25
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 494:	1101                	addi	sp,sp,-32
 496:	ec06                	sd	ra,24(sp)
 498:	e822                	sd	s0,16(sp)
 49a:	1000                	addi	s0,sp,32
 49c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a0:	4605                	li	a2,1
 4a2:	fef40593          	addi	a1,s0,-17
 4a6:	00000097          	auipc	ra,0x0
 4aa:	f4e080e7          	jalr	-178(ra) # 3f4 <write>
}
 4ae:	60e2                	ld	ra,24(sp)
 4b0:	6442                	ld	s0,16(sp)
 4b2:	6105                	addi	sp,sp,32
 4b4:	8082                	ret

00000000000004b6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b6:	7139                	addi	sp,sp,-64
 4b8:	fc06                	sd	ra,56(sp)
 4ba:	f822                	sd	s0,48(sp)
 4bc:	f426                	sd	s1,40(sp)
 4be:	f04a                	sd	s2,32(sp)
 4c0:	ec4e                	sd	s3,24(sp)
 4c2:	0080                	addi	s0,sp,64
 4c4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c6:	c299                	beqz	a3,4cc <printint+0x16>
 4c8:	0805c863          	bltz	a1,558 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4cc:	2581                	sext.w	a1,a1
  neg = 0;
 4ce:	4881                	li	a7,0
 4d0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d6:	2601                	sext.w	a2,a2
 4d8:	00001517          	auipc	a0,0x1
 4dc:	85050513          	addi	a0,a0,-1968 # d28 <digits>
 4e0:	883a                	mv	a6,a4
 4e2:	2705                	addiw	a4,a4,1
 4e4:	02c5f7bb          	remuw	a5,a1,a2
 4e8:	1782                	slli	a5,a5,0x20
 4ea:	9381                	srli	a5,a5,0x20
 4ec:	97aa                	add	a5,a5,a0
 4ee:	0007c783          	lbu	a5,0(a5)
 4f2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f6:	0005879b          	sext.w	a5,a1
 4fa:	02c5d5bb          	divuw	a1,a1,a2
 4fe:	0685                	addi	a3,a3,1
 500:	fec7f0e3          	bgeu	a5,a2,4e0 <printint+0x2a>
  if(neg)
 504:	00088b63          	beqz	a7,51a <printint+0x64>
    buf[i++] = '-';
 508:	fd040793          	addi	a5,s0,-48
 50c:	973e                	add	a4,a4,a5
 50e:	02d00793          	li	a5,45
 512:	fef70823          	sb	a5,-16(a4)
 516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 51a:	02e05863          	blez	a4,54a <printint+0x94>
 51e:	fc040793          	addi	a5,s0,-64
 522:	00e78933          	add	s2,a5,a4
 526:	fff78993          	addi	s3,a5,-1
 52a:	99ba                	add	s3,s3,a4
 52c:	377d                	addiw	a4,a4,-1
 52e:	1702                	slli	a4,a4,0x20
 530:	9301                	srli	a4,a4,0x20
 532:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 536:	fff94583          	lbu	a1,-1(s2)
 53a:	8526                	mv	a0,s1
 53c:	00000097          	auipc	ra,0x0
 540:	f58080e7          	jalr	-168(ra) # 494 <putc>
  while(--i >= 0)
 544:	197d                	addi	s2,s2,-1
 546:	ff3918e3          	bne	s2,s3,536 <printint+0x80>
}
 54a:	70e2                	ld	ra,56(sp)
 54c:	7442                	ld	s0,48(sp)
 54e:	74a2                	ld	s1,40(sp)
 550:	7902                	ld	s2,32(sp)
 552:	69e2                	ld	s3,24(sp)
 554:	6121                	addi	sp,sp,64
 556:	8082                	ret
    x = -xx;
 558:	40b005bb          	negw	a1,a1
    neg = 1;
 55c:	4885                	li	a7,1
    x = -xx;
 55e:	bf8d                	j	4d0 <printint+0x1a>

0000000000000560 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 560:	7119                	addi	sp,sp,-128
 562:	fc86                	sd	ra,120(sp)
 564:	f8a2                	sd	s0,112(sp)
 566:	f4a6                	sd	s1,104(sp)
 568:	f0ca                	sd	s2,96(sp)
 56a:	ecce                	sd	s3,88(sp)
 56c:	e8d2                	sd	s4,80(sp)
 56e:	e4d6                	sd	s5,72(sp)
 570:	e0da                	sd	s6,64(sp)
 572:	fc5e                	sd	s7,56(sp)
 574:	f862                	sd	s8,48(sp)
 576:	f466                	sd	s9,40(sp)
 578:	f06a                	sd	s10,32(sp)
 57a:	ec6e                	sd	s11,24(sp)
 57c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57e:	0005c903          	lbu	s2,0(a1)
 582:	18090f63          	beqz	s2,720 <vprintf+0x1c0>
 586:	8aaa                	mv	s5,a0
 588:	8b32                	mv	s6,a2
 58a:	00158493          	addi	s1,a1,1
  state = 0;
 58e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 590:	02500a13          	li	s4,37
      if(c == 'd'){
 594:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 598:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 59c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5a0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	00000b97          	auipc	s7,0x0
 5a8:	784b8b93          	addi	s7,s7,1924 # d28 <digits>
 5ac:	a839                	j	5ca <vprintf+0x6a>
        putc(fd, c);
 5ae:	85ca                	mv	a1,s2
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	ee2080e7          	jalr	-286(ra) # 494 <putc>
 5ba:	a019                	j	5c0 <vprintf+0x60>
    } else if(state == '%'){
 5bc:	01498f63          	beq	s3,s4,5da <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c0:	0485                	addi	s1,s1,1
 5c2:	fff4c903          	lbu	s2,-1(s1)
 5c6:	14090d63          	beqz	s2,720 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5ca:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ce:	fe0997e3          	bnez	s3,5bc <vprintf+0x5c>
      if(c == '%'){
 5d2:	fd479ee3          	bne	a5,s4,5ae <vprintf+0x4e>
        state = '%';
 5d6:	89be                	mv	s3,a5
 5d8:	b7e5                	j	5c0 <vprintf+0x60>
      if(c == 'd'){
 5da:	05878063          	beq	a5,s8,61a <vprintf+0xba>
      } else if(c == 'l') {
 5de:	05978c63          	beq	a5,s9,636 <vprintf+0xd6>
      } else if(c == 'x') {
 5e2:	07a78863          	beq	a5,s10,652 <vprintf+0xf2>
      } else if(c == 'p') {
 5e6:	09b78463          	beq	a5,s11,66e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ea:	07300713          	li	a4,115
 5ee:	0ce78663          	beq	a5,a4,6ba <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f2:	06300713          	li	a4,99
 5f6:	0ee78e63          	beq	a5,a4,6f2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5fa:	11478863          	beq	a5,s4,70a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5fe:	85d2                	mv	a1,s4
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e92080e7          	jalr	-366(ra) # 494 <putc>
        putc(fd, c);
 60a:	85ca                	mv	a1,s2
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e86080e7          	jalr	-378(ra) # 494 <putc>
      }
      state = 0;
 616:	4981                	li	s3,0
 618:	b765                	j	5c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 61a:	008b0913          	addi	s2,s6,8
 61e:	4685                	li	a3,1
 620:	4629                	li	a2,10
 622:	000b2583          	lw	a1,0(s6)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e8e080e7          	jalr	-370(ra) # 4b6 <printint>
 630:	8b4a                	mv	s6,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	b771                	j	5c0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 636:	008b0913          	addi	s2,s6,8
 63a:	4681                	li	a3,0
 63c:	4629                	li	a2,10
 63e:	000b2583          	lw	a1,0(s6)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e72080e7          	jalr	-398(ra) # 4b6 <printint>
 64c:	8b4a                	mv	s6,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	bf85                	j	5c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 652:	008b0913          	addi	s2,s6,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000b2583          	lw	a1,0(s6)
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	e56080e7          	jalr	-426(ra) # 4b6 <printint>
 668:	8b4a                	mv	s6,s2
      state = 0;
 66a:	4981                	li	s3,0
 66c:	bf91                	j	5c0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 66e:	008b0793          	addi	a5,s6,8
 672:	f8f43423          	sd	a5,-120(s0)
 676:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 67a:	03000593          	li	a1,48
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	e14080e7          	jalr	-492(ra) # 494 <putc>
  putc(fd, 'x');
 688:	85ea                	mv	a1,s10
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	e08080e7          	jalr	-504(ra) # 494 <putc>
 694:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 696:	03c9d793          	srli	a5,s3,0x3c
 69a:	97de                	add	a5,a5,s7
 69c:	0007c583          	lbu	a1,0(a5)
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	df2080e7          	jalr	-526(ra) # 494 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6aa:	0992                	slli	s3,s3,0x4
 6ac:	397d                	addiw	s2,s2,-1
 6ae:	fe0914e3          	bnez	s2,696 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6b2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b721                	j	5c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ba:	008b0993          	addi	s3,s6,8
 6be:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6c2:	02090163          	beqz	s2,6e4 <vprintf+0x184>
        while(*s != 0){
 6c6:	00094583          	lbu	a1,0(s2)
 6ca:	c9a1                	beqz	a1,71a <vprintf+0x1ba>
          putc(fd, *s);
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	dc6080e7          	jalr	-570(ra) # 494 <putc>
          s++;
 6d6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6d8:	00094583          	lbu	a1,0(s2)
 6dc:	f9e5                	bnez	a1,6cc <vprintf+0x16c>
        s = va_arg(ap, char*);
 6de:	8b4e                	mv	s6,s3
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bdf9                	j	5c0 <vprintf+0x60>
          s = "(null)";
 6e4:	00000917          	auipc	s2,0x0
 6e8:	63c90913          	addi	s2,s2,1596 # d20 <tournament_release+0x186>
        while(*s != 0){
 6ec:	02800593          	li	a1,40
 6f0:	bff1                	j	6cc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6f2:	008b0913          	addi	s2,s6,8
 6f6:	000b4583          	lbu	a1,0(s6)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	d98080e7          	jalr	-616(ra) # 494 <putc>
 704:	8b4a                	mv	s6,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	bd65                	j	5c0 <vprintf+0x60>
        putc(fd, c);
 70a:	85d2                	mv	a1,s4
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	d86080e7          	jalr	-634(ra) # 494 <putc>
      state = 0;
 716:	4981                	li	s3,0
 718:	b565                	j	5c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 71a:	8b4e                	mv	s6,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b54d                	j	5c0 <vprintf+0x60>
    }
  }
}
 720:	70e6                	ld	ra,120(sp)
 722:	7446                	ld	s0,112(sp)
 724:	74a6                	ld	s1,104(sp)
 726:	7906                	ld	s2,96(sp)
 728:	69e6                	ld	s3,88(sp)
 72a:	6a46                	ld	s4,80(sp)
 72c:	6aa6                	ld	s5,72(sp)
 72e:	6b06                	ld	s6,64(sp)
 730:	7be2                	ld	s7,56(sp)
 732:	7c42                	ld	s8,48(sp)
 734:	7ca2                	ld	s9,40(sp)
 736:	7d02                	ld	s10,32(sp)
 738:	6de2                	ld	s11,24(sp)
 73a:	6109                	addi	sp,sp,128
 73c:	8082                	ret

000000000000073e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73e:	715d                	addi	sp,sp,-80
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e010                	sd	a2,0(s0)
 748:	e414                	sd	a3,8(s0)
 74a:	e818                	sd	a4,16(s0)
 74c:	ec1c                	sd	a5,24(s0)
 74e:	03043023          	sd	a6,32(s0)
 752:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75a:	8622                	mv	a2,s0
 75c:	00000097          	auipc	ra,0x0
 760:	e04080e7          	jalr	-508(ra) # 560 <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6161                	addi	sp,sp,80
 76a:	8082                	ret

000000000000076c <printf>:

void
printf(const char *fmt, ...)
{
 76c:	711d                	addi	sp,sp,-96
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e40c                	sd	a1,8(s0)
 776:	e810                	sd	a2,16(s0)
 778:	ec14                	sd	a3,24(s0)
 77a:	f018                	sd	a4,32(s0)
 77c:	f41c                	sd	a5,40(s0)
 77e:	03043823          	sd	a6,48(s0)
 782:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	00840613          	addi	a2,s0,8
 78a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78e:	85aa                	mv	a1,a0
 790:	4505                	li	a0,1
 792:	00000097          	auipc	ra,0x0
 796:	dce080e7          	jalr	-562(ra) # 560 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6125                	addi	sp,sp,96
 7a0:	8082                	ret

00000000000007a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a2:	1141                	addi	sp,sp,-16
 7a4:	e422                	sd	s0,8(sp)
 7a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	00001797          	auipc	a5,0x1
 7b0:	8547b783          	ld	a5,-1964(a5) # 1000 <freep>
 7b4:	a805                	j	7e4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b6:	4618                	lw	a4,8(a2)
 7b8:	9db9                	addw	a1,a1,a4
 7ba:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7be:	6398                	ld	a4,0(a5)
 7c0:	6318                	ld	a4,0(a4)
 7c2:	fee53823          	sd	a4,-16(a0)
 7c6:	a091                	j	80a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c8:	ff852703          	lw	a4,-8(a0)
 7cc:	9e39                	addw	a2,a2,a4
 7ce:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7d0:	ff053703          	ld	a4,-16(a0)
 7d4:	e398                	sd	a4,0(a5)
 7d6:	a099                	j	81c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d8:	6398                	ld	a4,0(a5)
 7da:	00e7e463          	bltu	a5,a4,7e2 <free+0x40>
 7de:	00e6ea63          	bltu	a3,a4,7f2 <free+0x50>
{
 7e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e4:	fed7fae3          	bgeu	a5,a3,7d8 <free+0x36>
 7e8:	6398                	ld	a4,0(a5)
 7ea:	00e6e463          	bltu	a3,a4,7f2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ee:	fee7eae3          	bltu	a5,a4,7e2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7f2:	ff852583          	lw	a1,-8(a0)
 7f6:	6390                	ld	a2,0(a5)
 7f8:	02059713          	slli	a4,a1,0x20
 7fc:	9301                	srli	a4,a4,0x20
 7fe:	0712                	slli	a4,a4,0x4
 800:	9736                	add	a4,a4,a3
 802:	fae60ae3          	beq	a2,a4,7b6 <free+0x14>
    bp->s.ptr = p->s.ptr;
 806:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80a:	4790                	lw	a2,8(a5)
 80c:	02061713          	slli	a4,a2,0x20
 810:	9301                	srli	a4,a4,0x20
 812:	0712                	slli	a4,a4,0x4
 814:	973e                	add	a4,a4,a5
 816:	fae689e3          	beq	a3,a4,7c8 <free+0x26>
  } else
    p->s.ptr = bp;
 81a:	e394                	sd	a3,0(a5)
  freep = p;
 81c:	00000717          	auipc	a4,0x0
 820:	7ef73223          	sd	a5,2020(a4) # 1000 <freep>
}
 824:	6422                	ld	s0,8(sp)
 826:	0141                	addi	sp,sp,16
 828:	8082                	ret

000000000000082a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82a:	7139                	addi	sp,sp,-64
 82c:	fc06                	sd	ra,56(sp)
 82e:	f822                	sd	s0,48(sp)
 830:	f426                	sd	s1,40(sp)
 832:	f04a                	sd	s2,32(sp)
 834:	ec4e                	sd	s3,24(sp)
 836:	e852                	sd	s4,16(sp)
 838:	e456                	sd	s5,8(sp)
 83a:	e05a                	sd	s6,0(sp)
 83c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83e:	02051493          	slli	s1,a0,0x20
 842:	9081                	srli	s1,s1,0x20
 844:	04bd                	addi	s1,s1,15
 846:	8091                	srli	s1,s1,0x4
 848:	0014899b          	addiw	s3,s1,1
 84c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 84e:	00000517          	auipc	a0,0x0
 852:	7b253503          	ld	a0,1970(a0) # 1000 <freep>
 856:	c515                	beqz	a0,882 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 858:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85a:	4798                	lw	a4,8(a5)
 85c:	02977f63          	bgeu	a4,s1,89a <malloc+0x70>
 860:	8a4e                	mv	s4,s3
 862:	0009871b          	sext.w	a4,s3
 866:	6685                	lui	a3,0x1
 868:	00d77363          	bgeu	a4,a3,86e <malloc+0x44>
 86c:	6a05                	lui	s4,0x1
 86e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 872:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 876:	00000917          	auipc	s2,0x0
 87a:	78a90913          	addi	s2,s2,1930 # 1000 <freep>
  if(p == (char*)-1)
 87e:	5afd                	li	s5,-1
 880:	a88d                	j	8f2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 882:	00000797          	auipc	a5,0x0
 886:	79e78793          	addi	a5,a5,1950 # 1020 <base>
 88a:	00000717          	auipc	a4,0x0
 88e:	76f73b23          	sd	a5,1910(a4) # 1000 <freep>
 892:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 894:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 898:	b7e1                	j	860 <malloc+0x36>
      if(p->s.size == nunits)
 89a:	02e48b63          	beq	s1,a4,8d0 <malloc+0xa6>
        p->s.size -= nunits;
 89e:	4137073b          	subw	a4,a4,s3
 8a2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a4:	1702                	slli	a4,a4,0x20
 8a6:	9301                	srli	a4,a4,0x20
 8a8:	0712                	slli	a4,a4,0x4
 8aa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ac:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b0:	00000717          	auipc	a4,0x0
 8b4:	74a73823          	sd	a0,1872(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8bc:	70e2                	ld	ra,56(sp)
 8be:	7442                	ld	s0,48(sp)
 8c0:	74a2                	ld	s1,40(sp)
 8c2:	7902                	ld	s2,32(sp)
 8c4:	69e2                	ld	s3,24(sp)
 8c6:	6a42                	ld	s4,16(sp)
 8c8:	6aa2                	ld	s5,8(sp)
 8ca:	6b02                	ld	s6,0(sp)
 8cc:	6121                	addi	sp,sp,64
 8ce:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d0:	6398                	ld	a4,0(a5)
 8d2:	e118                	sd	a4,0(a0)
 8d4:	bff1                	j	8b0 <malloc+0x86>
  hp->s.size = nu;
 8d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8da:	0541                	addi	a0,a0,16
 8dc:	00000097          	auipc	ra,0x0
 8e0:	ec6080e7          	jalr	-314(ra) # 7a2 <free>
  return freep;
 8e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e8:	d971                	beqz	a0,8bc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ec:	4798                	lw	a4,8(a5)
 8ee:	fa9776e3          	bgeu	a4,s1,89a <malloc+0x70>
    if(p == freep)
 8f2:	00093703          	ld	a4,0(s2)
 8f6:	853e                	mv	a0,a5
 8f8:	fef719e3          	bne	a4,a5,8ea <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8fc:	8552                	mv	a0,s4
 8fe:	00000097          	auipc	ra,0x0
 902:	b5e080e7          	jalr	-1186(ra) # 45c <sbrk>
  if(p == (char*)-1)
 906:	fd5518e3          	bne	a0,s5,8d6 <malloc+0xac>
        return 0;
 90a:	4501                	li	a0,0
 90c:	bf45                	j	8bc <malloc+0x92>

000000000000090e <tournament_create>:
static int proc_id = 0;  // ID of the current process in the tournament
static int num_processes = 0;   // Number of processes in the tournament
static int num_levels = 0;      // Number of levels in the tournament tree
static int *lock_ids = 0;       // Array of Peterson lock IDs

int tournament_create(int processes) {
 90e:	715d                	addi	sp,sp,-80
 910:	e486                	sd	ra,72(sp)
 912:	e0a2                	sd	s0,64(sp)
 914:	fc26                	sd	s1,56(sp)
 916:	f84a                	sd	s2,48(sp)
 918:	f44e                	sd	s3,40(sp)
 91a:	f052                	sd	s4,32(sp)
 91c:	ec56                	sd	s5,24(sp)
 91e:	e85a                	sd	s6,16(sp)
 920:	e45e                	sd	s7,8(sp)
 922:	0880                	addi	s0,sp,80
    // Check if the number of processes is valid (power of 2 up to 16)
    if (processes <= 0 || processes > 16 || (processes & (processes - 1)) != 0) {
 924:	fff5071b          	addiw	a4,a0,-1
 928:	47bd                	li	a5,15
 92a:	14e7e163          	bltu	a5,a4,a6c <tournament_create+0x15e>
 92e:	8aaa                	mv	s5,a0
 930:	357d                	addiw	a0,a0,-1
 932:	8b3a                	mv	s6,a4
 934:	015777b3          	and	a5,a4,s5
 938:	12079c63          	bnez	a5,a70 <tournament_create+0x162>
        return -1;  // Not a power of 2 or out of range
    }

    num_processes = processes;
 93c:	00000797          	auipc	a5,0x0
 940:	6d57ac23          	sw	s5,1752(a5) # 1014 <num_processes>
    lock_ids = malloc(sizeof(int) * (num_processes - 1));
 944:	0025151b          	slliw	a0,a0,0x2
 948:	00000097          	auipc	ra,0x0
 94c:	ee2080e7          	jalr	-286(ra) # 82a <malloc>
 950:	00000797          	auipc	a5,0x0
 954:	6aa7bc23          	sd	a0,1720(a5) # 1008 <lock_ids>
    if (!lock_ids) {
 958:	10050e63          	beqz	a0,a74 <tournament_create+0x166>
        return -1;  // Memory allocation failed
    }

    for (int i = 0; i < processes - 1; i++) {
 95c:	05605063          	blez	s6,99c <tournament_create+0x8e>
 960:	4481                	li	s1,0
        lock_ids[i] = peterson_create();
 962:	00000a17          	auipc	s4,0x0
 966:	6a6a0a13          	addi	s4,s4,1702 # 1008 <lock_ids>
 96a:	00048b9b          	sext.w	s7,s1
 96e:	00249913          	slli	s2,s1,0x2
 972:	000a3983          	ld	s3,0(s4)
 976:	99ca                	add	s3,s3,s2
 978:	00000097          	auipc	ra,0x0
 97c:	afc080e7          	jalr	-1284(ra) # 474 <peterson_create>
 980:	00a9a023          	sw	a0,0(s3)
        if (lock_ids[i] < 0) {
 984:	000a3783          	ld	a5,0(s4)
 988:	993e                	add	s2,s2,a5
 98a:	00092783          	lw	a5,0(s2)
 98e:	0607c163          	bltz	a5,9f0 <tournament_create+0xe2>
    for (int i = 0; i < processes - 1; i++) {
 992:	0485                	addi	s1,s1,1
 994:	0004879b          	sext.w	a5,s1
 998:	fd67c9e3          	blt	a5,s6,96a <tournament_create+0x5c>
            return -1;
        }
    }

    // חישוב מספר הרמות בעץ: log2(processes)
    num_levels = 0;
 99c:	00000797          	auipc	a5,0x0
 9a0:	6607aa23          	sw	zero,1652(a5) # 1010 <num_levels>
    int temp = num_processes;
 9a4:	00000797          	auipc	a5,0x0
 9a8:	6707a783          	lw	a5,1648(a5) # 1014 <num_processes>
    while (temp > 1) {
 9ac:	4705                	li	a4,1
 9ae:	00f75e63          	bge	a4,a5,9ca <tournament_create+0xbc>
 9b2:	4605                	li	a2,1
        temp >>= 1;
 9b4:	4017d79b          	sraiw	a5,a5,0x1
        num_levels++;
 9b8:	0007069b          	sext.w	a3,a4
    while (temp > 1) {
 9bc:	2705                	addiw	a4,a4,1
 9be:	fef64be3          	blt	a2,a5,9b4 <tournament_create+0xa6>
 9c2:	00000797          	auipc	a5,0x0
 9c6:	64d7a723          	sw	a3,1614(a5) # 1010 <num_levels>
    }

    for (int i = 1; i < processes; i++) {
 9ca:	4785                	li	a5,1
 9cc:	0157dd63          	bge	a5,s5,9e6 <tournament_create+0xd8>
 9d0:	4485                	li	s1,1
        int pid = fork();
 9d2:	00000097          	auipc	ra,0x0
 9d6:	9fa080e7          	jalr	-1542(ra) # 3cc <fork>
        if (pid < 0) {
 9da:	06054a63          	bltz	a0,a4e <tournament_create+0x140>
            printf("fork failed!\n");
            return -1;
        }
        if (pid == 0) {
 9de:	c151                	beqz	a0,a62 <tournament_create+0x154>
    for (int i = 1; i < processes; i++) {
 9e0:	2485                	addiw	s1,s1,1
 9e2:	fe9a98e3          	bne	s5,s1,9d2 <tournament_create+0xc4>
            proc_id = i;
            return proc_id;
        }
    }

    return proc_id;
 9e6:	00000497          	auipc	s1,0x0
 9ea:	6324a483          	lw	s1,1586(s1) # 1018 <proc_id>
 9ee:	a0a1                	j	a36 <tournament_create+0x128>
            for (int j = 0; j < i; j++) {
 9f0:	03705763          	blez	s7,a1e <tournament_create+0x110>
 9f4:	34fd                	addiw	s1,s1,-1
 9f6:	1482                	slli	s1,s1,0x20
 9f8:	9081                	srli	s1,s1,0x20
 9fa:	0485                	addi	s1,s1,1
 9fc:	048a                	slli	s1,s1,0x2
 9fe:	4901                	li	s2,0
                peterson_destroy(lock_ids[j]);
 a00:	00000997          	auipc	s3,0x0
 a04:	60898993          	addi	s3,s3,1544 # 1008 <lock_ids>
 a08:	0009b783          	ld	a5,0(s3)
 a0c:	97ca                	add	a5,a5,s2
 a0e:	4388                	lw	a0,0(a5)
 a10:	00000097          	auipc	ra,0x0
 a14:	a7c080e7          	jalr	-1412(ra) # 48c <peterson_destroy>
            for (int j = 0; j < i; j++) {
 a18:	0911                	addi	s2,s2,4
 a1a:	fe9917e3          	bne	s2,s1,a08 <tournament_create+0xfa>
            free(lock_ids);
 a1e:	00000497          	auipc	s1,0x0
 a22:	5ea48493          	addi	s1,s1,1514 # 1008 <lock_ids>
 a26:	6088                	ld	a0,0(s1)
 a28:	00000097          	auipc	ra,0x0
 a2c:	d7a080e7          	jalr	-646(ra) # 7a2 <free>
            lock_ids = 0;
 a30:	0004b023          	sd	zero,0(s1)
            return -1;
 a34:	54fd                	li	s1,-1
}
 a36:	8526                	mv	a0,s1
 a38:	60a6                	ld	ra,72(sp)
 a3a:	6406                	ld	s0,64(sp)
 a3c:	74e2                	ld	s1,56(sp)
 a3e:	7942                	ld	s2,48(sp)
 a40:	79a2                	ld	s3,40(sp)
 a42:	7a02                	ld	s4,32(sp)
 a44:	6ae2                	ld	s5,24(sp)
 a46:	6b42                	ld	s6,16(sp)
 a48:	6ba2                	ld	s7,8(sp)
 a4a:	6161                	addi	sp,sp,80
 a4c:	8082                	ret
            printf("fork failed!\n");
 a4e:	00000517          	auipc	a0,0x0
 a52:	2f250513          	addi	a0,a0,754 # d40 <digits+0x18>
 a56:	00000097          	auipc	ra,0x0
 a5a:	d16080e7          	jalr	-746(ra) # 76c <printf>
            return -1;
 a5e:	54fd                	li	s1,-1
 a60:	bfd9                	j	a36 <tournament_create+0x128>
            proc_id = i;
 a62:	00000797          	auipc	a5,0x0
 a66:	5a97ab23          	sw	s1,1462(a5) # 1018 <proc_id>
            return proc_id;
 a6a:	b7f1                	j	a36 <tournament_create+0x128>
        return -1;  // Not a power of 2 or out of range
 a6c:	54fd                	li	s1,-1
 a6e:	b7e1                	j	a36 <tournament_create+0x128>
 a70:	54fd                	li	s1,-1
 a72:	b7d1                	j	a36 <tournament_create+0x128>
        return -1;  // Memory allocation failed
 a74:	54fd                	li	s1,-1
 a76:	b7c1                	j	a36 <tournament_create+0x128>

0000000000000a78 <tournament_acquire>:

int tournament_acquire(void) {
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 a78:	00000797          	auipc	a5,0x0
 a7c:	59c7a783          	lw	a5,1436(a5) # 1014 <num_processes>
 a80:	10078163          	beqz	a5,b82 <tournament_acquire+0x10a>
int tournament_acquire(void) {
 a84:	7139                	addi	sp,sp,-64
 a86:	fc06                	sd	ra,56(sp)
 a88:	f822                	sd	s0,48(sp)
 a8a:	f426                	sd	s1,40(sp)
 a8c:	f04a                	sd	s2,32(sp)
 a8e:	ec4e                	sd	s3,24(sp)
 a90:	e852                	sd	s4,16(sp)
 a92:	e456                	sd	s5,8(sp)
 a94:	0080                	addi	s0,sp,64
    if (num_processes == 0 || num_levels == 0 || lock_ids == 0) {
 a96:	00000497          	auipc	s1,0x0
 a9a:	57a4a483          	lw	s1,1402(s1) # 1010 <num_levels>
 a9e:	c4e5                	beqz	s1,b86 <tournament_acquire+0x10e>
 aa0:	00000797          	auipc	a5,0x0
 aa4:	5687b783          	ld	a5,1384(a5) # 1008 <lock_ids>
 aa8:	c3ed                	beqz	a5,b8a <tournament_acquire+0x112>
        return -1;  // Tournament not initialized
    }

    int node = proc_id, role;
    for (int i = num_levels - 1; i >= 0; i--) {
 aaa:	34fd                	addiw	s1,s1,-1
 aac:	0e04c163          	bltz	s1,b8e <tournament_acquire+0x116>
        // חישוב תפקיד (role) עבור הרמה הנוכחית
        int shift = num_levels - i - 1;
 ab0:	00000a17          	auipc	s4,0x0
 ab4:	560a0a13          	addi	s4,s4,1376 # 1010 <num_levels>
        role = (proc_id & (1 << shift)) >> shift;
 ab8:	00000997          	auipc	s3,0x0
 abc:	56098993          	addi	s3,s3,1376 # 1018 <proc_id>
 ac0:	4905                	li	s2,1
    for (int i = num_levels - 1; i >= 0; i--) {
 ac2:	5afd                	li	s5,-1
        int shift = num_levels - i - 1;
 ac4:	000a2783          	lw	a5,0(s4)
 ac8:	4097873b          	subw	a4,a5,s1
 acc:	fff7059b          	addiw	a1,a4,-1
        role = (proc_id & (1 << shift)) >> shift;
 ad0:	0009a783          	lw	a5,0(s3)
 ad4:	00b916bb          	sllw	a3,s2,a1
 ad8:	8efd                	and	a3,a3,a5

        // חישוב אינדקס של המנעול ברמה זו
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 ada:	0099153b          	sllw	a0,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 ade:	40e7d7bb          	sraw	a5,a5,a4
        node = lock_level_idx + (1 << i) - 1;
 ae2:	9d3d                	addw	a0,a0,a5

        if (peterson_acquire(node, role) < 0) {
 ae4:	40b6d5bb          	sraw	a1,a3,a1
 ae8:	357d                	addiw	a0,a0,-1
 aea:	00000097          	auipc	ra,0x0
 aee:	992080e7          	jalr	-1646(ra) # 47c <peterson_acquire>
 af2:	00054f63          	bltz	a0,b10 <tournament_acquire+0x98>
    for (int i = num_levels - 1; i >= 0; i--) {
 af6:	34fd                	addiw	s1,s1,-1
 af8:	fd5496e3          	bne	s1,s5,ac4 <tournament_acquire+0x4c>
            }
            return -1;
        }
    }

    return 0;
 afc:	4501                	li	a0,0
}
 afe:	70e2                	ld	ra,56(sp)
 b00:	7442                	ld	s0,48(sp)
 b02:	74a2                	ld	s1,40(sp)
 b04:	7902                	ld	s2,32(sp)
 b06:	69e2                	ld	s3,24(sp)
 b08:	6a42                	ld	s4,16(sp)
 b0a:	6aa2                	ld	s5,8(sp)
 b0c:	6121                	addi	sp,sp,64
 b0e:	8082                	ret
            printf("failed to acquire: %d \n", proc_id);
 b10:	00000597          	auipc	a1,0x0
 b14:	5085a583          	lw	a1,1288(a1) # 1018 <proc_id>
 b18:	00000517          	auipc	a0,0x0
 b1c:	23850513          	addi	a0,a0,568 # d50 <digits+0x28>
 b20:	00000097          	auipc	ra,0x0
 b24:	c4c080e7          	jalr	-948(ra) # 76c <printf>
            for (int j = i; j < num_levels; j++) {
 b28:	00000517          	auipc	a0,0x0
 b2c:	4e852503          	lw	a0,1256(a0) # 1010 <num_levels>
 b30:	06a4d163          	bge	s1,a0,b92 <tournament_acquire+0x11a>
                int r = (proc_id & (1 << shift2)) >> shift2;
 b34:	00000997          	auipc	s3,0x0
 b38:	4e498993          	addi	s3,s3,1252 # 1018 <proc_id>
 b3c:	4905                	li	s2,1
            for (int j = i; j < num_levels; j++) {
 b3e:	00000a17          	auipc	s4,0x0
 b42:	4d2a0a13          	addi	s4,s4,1234 # 1010 <num_levels>
                int shift2 = num_levels - j - 1;
 b46:	409507bb          	subw	a5,a0,s1
 b4a:	fff7859b          	addiw	a1,a5,-1
                int r = (proc_id & (1 << shift2)) >> shift2;
 b4e:	0009a503          	lw	a0,0(s3)
 b52:	00b9173b          	sllw	a4,s2,a1
 b56:	8f69                	and	a4,a4,a0
                int li = (proc_id >> (num_levels - j)) + (1 << j) - 1;
 b58:	40f5553b          	sraw	a0,a0,a5
 b5c:	009917bb          	sllw	a5,s2,s1
 b60:	9d3d                	addw	a0,a0,a5
                if (peterson_release(li, r) < 0) {
 b62:	40b755bb          	sraw	a1,a4,a1
 b66:	357d                	addiw	a0,a0,-1
 b68:	00000097          	auipc	ra,0x0
 b6c:	91c080e7          	jalr	-1764(ra) # 484 <peterson_release>
 b70:	02054363          	bltz	a0,b96 <tournament_acquire+0x11e>
            for (int j = i; j < num_levels; j++) {
 b74:	2485                	addiw	s1,s1,1
 b76:	000a2503          	lw	a0,0(s4)
 b7a:	fca4c6e3          	blt	s1,a0,b46 <tournament_acquire+0xce>
            return -1;
 b7e:	557d                	li	a0,-1
 b80:	bfbd                	j	afe <tournament_acquire+0x86>
        return -1;  // Tournament not initialized
 b82:	557d                	li	a0,-1
}
 b84:	8082                	ret
        return -1;  // Tournament not initialized
 b86:	557d                	li	a0,-1
 b88:	bf9d                	j	afe <tournament_acquire+0x86>
 b8a:	557d                	li	a0,-1
 b8c:	bf8d                	j	afe <tournament_acquire+0x86>
    return 0;
 b8e:	4501                	li	a0,0
 b90:	b7bd                	j	afe <tournament_acquire+0x86>
            return -1;
 b92:	557d                	li	a0,-1
 b94:	b7ad                	j	afe <tournament_acquire+0x86>
                    return -1;
 b96:	557d                	li	a0,-1
 b98:	b79d                	j	afe <tournament_acquire+0x86>

0000000000000b9a <tournament_release>:

int tournament_release(void) {
    int node = proc_id, role;
    for (int i = 0; i < num_levels; i++) {
 b9a:	00000517          	auipc	a0,0x0
 b9e:	47652503          	lw	a0,1142(a0) # 1010 <num_levels>
 ba2:	06a05263          	blez	a0,c06 <tournament_release+0x6c>
int tournament_release(void) {
 ba6:	7179                	addi	sp,sp,-48
 ba8:	f406                	sd	ra,40(sp)
 baa:	f022                	sd	s0,32(sp)
 bac:	ec26                	sd	s1,24(sp)
 bae:	e84a                	sd	s2,16(sp)
 bb0:	e44e                	sd	s3,8(sp)
 bb2:	e052                	sd	s4,0(sp)
 bb4:	1800                	addi	s0,sp,48
    for (int i = 0; i < num_levels; i++) {
 bb6:	4481                	li	s1,0
        // חישוב תפקיד (role)
        int shift = num_levels - i - 1;
        role = (proc_id & (1 << shift)) >> shift;
 bb8:	00000997          	auipc	s3,0x0
 bbc:	46098993          	addi	s3,s3,1120 # 1018 <proc_id>
 bc0:	4905                	li	s2,1
    for (int i = 0; i < num_levels; i++) {
 bc2:	00000a17          	auipc	s4,0x0
 bc6:	44ea0a13          	addi	s4,s4,1102 # 1010 <num_levels>
        int shift = num_levels - i - 1;
 bca:	9d05                	subw	a0,a0,s1
 bcc:	fff5059b          	addiw	a1,a0,-1
        role = (proc_id & (1 << shift)) >> shift;
 bd0:	0009a703          	lw	a4,0(s3)
 bd4:	00b916bb          	sllw	a3,s2,a1
 bd8:	8ef9                	and	a3,a3,a4

        // חישוב אינדקס של המנעול
        int lock_level_idx = proc_id >> (num_levels - i);
        node = lock_level_idx + (1 << i) - 1;
 bda:	009917bb          	sllw	a5,s2,s1
        int lock_level_idx = proc_id >> (num_levels - i);
 bde:	40a7573b          	sraw	a4,a4,a0
        node = lock_level_idx + (1 << i) - 1;
 be2:	00e7853b          	addw	a0,a5,a4

        if (peterson_release(node, role) < 0) {
 be6:	40b6d5bb          	sraw	a1,a3,a1
 bea:	357d                	addiw	a0,a0,-1
 bec:	00000097          	auipc	ra,0x0
 bf0:	898080e7          	jalr	-1896(ra) # 484 <peterson_release>
 bf4:	00054b63          	bltz	a0,c0a <tournament_release+0x70>
    for (int i = 0; i < num_levels; i++) {
 bf8:	2485                	addiw	s1,s1,1
 bfa:	000a2503          	lw	a0,0(s4)
 bfe:	fca4c6e3          	blt	s1,a0,bca <tournament_release+0x30>
            return -1;
        }
    }
    return 0;
 c02:	4501                	li	a0,0
 c04:	a021                	j	c0c <tournament_release+0x72>
 c06:	4501                	li	a0,0
}
 c08:	8082                	ret
            return -1;
 c0a:	557d                	li	a0,-1
}
 c0c:	70a2                	ld	ra,40(sp)
 c0e:	7402                	ld	s0,32(sp)
 c10:	64e2                	ld	s1,24(sp)
 c12:	6942                	ld	s2,16(sp)
 c14:	69a2                	ld	s3,8(sp)
 c16:	6a02                	ld	s4,0(sp)
 c18:	6145                	addi	sp,sp,48
 c1a:	8082                	ret

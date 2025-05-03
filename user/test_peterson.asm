
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
  1a:	45c080e7          	jalr	1116(ra) # 472 <peterson_create>
    if (lock_id < 0) {
  1e:	02054e63          	bltz	a0,5a <main+0x5a>
  22:	892a                	mv	s2,a0
        printf("Failed to create lock\n");
        exit(1);
    }

    printf("Created lock %d\n", lock_id);
  24:	85aa                	mv	a1,a0
  26:	00001517          	auipc	a0,0x1
  2a:	90250513          	addi	a0,a0,-1790 # 928 <malloc+0x104>
  2e:	00000097          	auipc	ra,0x0
  32:	73e080e7          	jalr	1854(ra) # 76c <printf>

    int fork_ret = fork();
  36:	00000097          	auipc	ra,0x0
  3a:	394080e7          	jalr	916(ra) # 3ca <fork>
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
  4a:	942b8b93          	addi	s7,s7,-1726 # 988 <malloc+0x164>
            printf("[PARENT] In critical section (iteration %d)\n", i);
  4e:	00001b17          	auipc	s6,0x1
  52:	90ab0b13          	addi	s6,s6,-1782 # 958 <malloc+0x134>
    for (int i = 0; i < 10; i++) {
  56:	4aa9                	li	s5,10
  58:	a8a1                	j	b0 <main+0xb0>
        printf("Failed to create lock\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	8b650513          	addi	a0,a0,-1866 # 910 <malloc+0xec>
  62:	00000097          	auipc	ra,0x0
  66:	70a080e7          	jalr	1802(ra) # 76c <printf>
        exit(1);
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	366080e7          	jalr	870(ra) # 3d2 <exit>
            printf("Failed to acquire lock\n");
  74:	00001517          	auipc	a0,0x1
  78:	8cc50513          	addi	a0,a0,-1844 # 940 <malloc+0x11c>
  7c:	00000097          	auipc	ra,0x0
  80:	6f0080e7          	jalr	1776(ra) # 76c <printf>
            exit(1);
  84:	4505                	li	a0,1
  86:	00000097          	auipc	ra,0x0
  8a:	34c080e7          	jalr	844(ra) # 3d2 <exit>
            printf("[CHILD ] In critical section (iteration %d)\n", i);
  8e:	85a6                	mv	a1,s1
  90:	855e                	mv	a0,s7
  92:	00000097          	auipc	ra,0x0
  96:	6da080e7          	jalr	1754(ra) # 76c <printf>

        if (peterson_release(lock_id, role) < 0) {
  9a:	85ce                	mv	a1,s3
  9c:	854a                	mv	a0,s2
  9e:	00000097          	auipc	ra,0x0
  a2:	3e4080e7          	jalr	996(ra) # 482 <peterson_release>
  a6:	02054663          	bltz	a0,d2 <main+0xd2>
    for (int i = 0; i < 10; i++) {
  aa:	2485                	addiw	s1,s1,1
  ac:	05548063          	beq	s1,s5,ec <main+0xec>
        if (peterson_acquire(lock_id, role) < 0) {
  b0:	85ce                	mv	a1,s3
  b2:	854a                	mv	a0,s2
  b4:	00000097          	auipc	ra,0x0
  b8:	3c6080e7          	jalr	966(ra) # 47a <peterson_acquire>
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
  d6:	8e650513          	addi	a0,a0,-1818 # 9b8 <malloc+0x194>
  da:	00000097          	auipc	ra,0x0
  de:	692080e7          	jalr	1682(ra) # 76c <printf>
            exit(1);
  e2:	4505                	li	a0,1
  e4:	00000097          	auipc	ra,0x0
  e8:	2ee080e7          	jalr	750(ra) # 3d2 <exit>
        }

    }

    if (fork_ret > 0) {
  ec:	03405e63          	blez	s4,128 <main+0x128>
        wait(0);
  f0:	4501                	li	a0,0
  f2:	00000097          	auipc	ra,0x0
  f6:	2e8080e7          	jalr	744(ra) # 3da <wait>
        printf("Parent destroying lock\n");
  fa:	00001517          	auipc	a0,0x1
  fe:	8d650513          	addi	a0,a0,-1834 # 9d0 <malloc+0x1ac>
 102:	00000097          	auipc	ra,0x0
 106:	66a080e7          	jalr	1642(ra) # 76c <printf>
        if (peterson_destroy(lock_id) < 0) {
 10a:	854a                	mv	a0,s2
 10c:	00000097          	auipc	ra,0x0
 110:	37e080e7          	jalr	894(ra) # 48a <peterson_destroy>
 114:	00054f63          	bltz	a0,132 <main+0x132>
            printf("Failed to destroy lock\n");
            exit(1);
        }
        printf("Lock destroyed\n");
 118:	00001517          	auipc	a0,0x1
 11c:	8e850513          	addi	a0,a0,-1816 # a00 <malloc+0x1dc>
 120:	00000097          	auipc	ra,0x0
 124:	64c080e7          	jalr	1612(ra) # 76c <printf>
    }

    exit(0);
 128:	4501                	li	a0,0
 12a:	00000097          	auipc	ra,0x0
 12e:	2a8080e7          	jalr	680(ra) # 3d2 <exit>
            printf("Failed to destroy lock\n");
 132:	00001517          	auipc	a0,0x1
 136:	8b650513          	addi	a0,a0,-1866 # 9e8 <malloc+0x1c4>
 13a:	00000097          	auipc	ra,0x0
 13e:	632080e7          	jalr	1586(ra) # 76c <printf>
            exit(1);
 142:	4505                	li	a0,1
 144:	00000097          	auipc	ra,0x0
 148:	28e080e7          	jalr	654(ra) # 3d2 <exit>

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
 162:	274080e7          	jalr	628(ra) # 3d2 <exit>

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
 254:	19a080e7          	jalr	410(ra) # 3ea <read>
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
 2a6:	170080e7          	jalr	368(ra) # 412 <open>
  if(fd < 0)
 2aa:	02054563          	bltz	a0,2d4 <stat+0x42>
 2ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b0:	85ca                	mv	a1,s2
 2b2:	00000097          	auipc	ra,0x0
 2b6:	178080e7          	jalr	376(ra) # 42a <fstat>
 2ba:	892a                	mv	s2,a0
  close(fd);
 2bc:	8526                	mv	a0,s1
 2be:	00000097          	auipc	ra,0x0
 2c2:	13c080e7          	jalr	316(ra) # 3fa <close>
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
 2de:	00054683          	lbu	a3,0(a0)
 2e2:	fd06879b          	addiw	a5,a3,-48
 2e6:	0ff7f793          	zext.b	a5,a5
 2ea:	4625                	li	a2,9
 2ec:	02f66863          	bltu	a2,a5,31c <atoi+0x44>
 2f0:	872a                	mv	a4,a0
  n = 0;
 2f2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2f4:	0705                	addi	a4,a4,1
 2f6:	0025179b          	slliw	a5,a0,0x2
 2fa:	9fa9                	addw	a5,a5,a0
 2fc:	0017979b          	slliw	a5,a5,0x1
 300:	9fb5                	addw	a5,a5,a3
 302:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 306:	00074683          	lbu	a3,0(a4)
 30a:	fd06879b          	addiw	a5,a3,-48
 30e:	0ff7f793          	zext.b	a5,a5
 312:	fef671e3          	bgeu	a2,a5,2f4 <atoi+0x1c>
  return n;
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  n = 0;
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <atoi+0x3e>

0000000000000320 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 326:	02b57463          	bgeu	a0,a1,34e <memmove+0x2e>
    while(n-- > 0)
 32a:	00c05f63          	blez	a2,348 <memmove+0x28>
 32e:	1602                	slli	a2,a2,0x20
 330:	9201                	srli	a2,a2,0x20
 332:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 336:	872a                	mv	a4,a0
      *dst++ = *src++;
 338:	0585                	addi	a1,a1,1
 33a:	0705                	addi	a4,a4,1
 33c:	fff5c683          	lbu	a3,-1(a1)
 340:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 344:	fee79ae3          	bne	a5,a4,338 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 348:	6422                	ld	s0,8(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret
    dst += n;
 34e:	00c50733          	add	a4,a0,a2
    src += n;
 352:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 354:	fec05ae3          	blez	a2,348 <memmove+0x28>
 358:	fff6079b          	addiw	a5,a2,-1
 35c:	1782                	slli	a5,a5,0x20
 35e:	9381                	srli	a5,a5,0x20
 360:	fff7c793          	not	a5,a5
 364:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 366:	15fd                	addi	a1,a1,-1
 368:	177d                	addi	a4,a4,-1
 36a:	0005c683          	lbu	a3,0(a1)
 36e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 372:	fee79ae3          	bne	a5,a4,366 <memmove+0x46>
 376:	bfc9                	j	348 <memmove+0x28>

0000000000000378 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 37e:	ca05                	beqz	a2,3ae <memcmp+0x36>
 380:	fff6069b          	addiw	a3,a2,-1
 384:	1682                	slli	a3,a3,0x20
 386:	9281                	srli	a3,a3,0x20
 388:	0685                	addi	a3,a3,1
 38a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 38c:	00054783          	lbu	a5,0(a0)
 390:	0005c703          	lbu	a4,0(a1)
 394:	00e79863          	bne	a5,a4,3a4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 398:	0505                	addi	a0,a0,1
    p2++;
 39a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 39c:	fed518e3          	bne	a0,a3,38c <memcmp+0x14>
  }
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	a019                	j	3a8 <memcmp+0x30>
      return *p1 - *p2;
 3a4:	40e7853b          	subw	a0,a5,a4
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
  return 0;
 3ae:	4501                	li	a0,0
 3b0:	bfe5                	j	3a8 <memcmp+0x30>

00000000000003b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e406                	sd	ra,8(sp)
 3b6:	e022                	sd	s0,0(sp)
 3b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ba:	00000097          	auipc	ra,0x0
 3be:	f66080e7          	jalr	-154(ra) # 320 <memmove>
}
 3c2:	60a2                	ld	ra,8(sp)
 3c4:	6402                	ld	s0,0(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret

00000000000003ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ca:	4885                	li	a7,1
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d2:	4889                	li	a7,2
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <wait>:
.global wait
wait:
 li a7, SYS_wait
 3da:	488d                	li	a7,3
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e2:	4891                	li	a7,4
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <read>:
.global read
read:
 li a7, SYS_read
 3ea:	4895                	li	a7,5
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <write>:
.global write
write:
 li a7, SYS_write
 3f2:	48c1                	li	a7,16
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <close>:
.global close
close:
 li a7, SYS_close
 3fa:	48d5                	li	a7,21
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <kill>:
.global kill
kill:
 li a7, SYS_kill
 402:	4899                	li	a7,6
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <exec>:
.global exec
exec:
 li a7, SYS_exec
 40a:	489d                	li	a7,7
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <open>:
.global open
open:
 li a7, SYS_open
 412:	48bd                	li	a7,15
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41a:	48c5                	li	a7,17
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 422:	48c9                	li	a7,18
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42a:	48a1                	li	a7,8
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <link>:
.global link
link:
 li a7, SYS_link
 432:	48cd                	li	a7,19
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43a:	48d1                	li	a7,20
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 442:	48a5                	li	a7,9
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <dup>:
.global dup
dup:
 li a7, SYS_dup
 44a:	48a9                	li	a7,10
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 452:	48ad                	li	a7,11
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 45a:	48b1                	li	a7,12
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 462:	48b5                	li	a7,13
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46a:	48b9                	li	a7,14
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 472:	48d9                	li	a7,22
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 47a:	48dd                	li	a7,23
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 482:	48e1                	li	a7,24
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 48a:	48e5                	li	a7,25
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 492:	1101                	addi	sp,sp,-32
 494:	ec06                	sd	ra,24(sp)
 496:	e822                	sd	s0,16(sp)
 498:	1000                	addi	s0,sp,32
 49a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49e:	4605                	li	a2,1
 4a0:	fef40593          	addi	a1,s0,-17
 4a4:	00000097          	auipc	ra,0x0
 4a8:	f4e080e7          	jalr	-178(ra) # 3f2 <write>
}
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	6105                	addi	sp,sp,32
 4b2:	8082                	ret

00000000000004b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b4:	7139                	addi	sp,sp,-64
 4b6:	fc06                	sd	ra,56(sp)
 4b8:	f822                	sd	s0,48(sp)
 4ba:	f426                	sd	s1,40(sp)
 4bc:	f04a                	sd	s2,32(sp)
 4be:	ec4e                	sd	s3,24(sp)
 4c0:	0080                	addi	s0,sp,64
 4c2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c4:	c299                	beqz	a3,4ca <printint+0x16>
 4c6:	0805c963          	bltz	a1,558 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ca:	2581                	sext.w	a1,a1
  neg = 0;
 4cc:	4881                	li	a7,0
 4ce:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d4:	2601                	sext.w	a2,a2
 4d6:	00000517          	auipc	a0,0x0
 4da:	59a50513          	addi	a0,a0,1434 # a70 <digits>
 4de:	883a                	mv	a6,a4
 4e0:	2705                	addiw	a4,a4,1
 4e2:	02c5f7bb          	remuw	a5,a1,a2
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	97aa                	add	a5,a5,a0
 4ec:	0007c783          	lbu	a5,0(a5)
 4f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f4:	0005879b          	sext.w	a5,a1
 4f8:	02c5d5bb          	divuw	a1,a1,a2
 4fc:	0685                	addi	a3,a3,1
 4fe:	fec7f0e3          	bgeu	a5,a2,4de <printint+0x2a>
  if(neg)
 502:	00088c63          	beqz	a7,51a <printint+0x66>
    buf[i++] = '-';
 506:	fd070793          	addi	a5,a4,-48
 50a:	00878733          	add	a4,a5,s0
 50e:	02d00793          	li	a5,45
 512:	fef70823          	sb	a5,-16(a4)
 516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 51a:	02e05863          	blez	a4,54a <printint+0x96>
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
 540:	f56080e7          	jalr	-170(ra) # 492 <putc>
  while(--i >= 0)
 544:	197d                	addi	s2,s2,-1
 546:	ff3918e3          	bne	s2,s3,536 <printint+0x82>
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
 55e:	bf85                	j	4ce <printint+0x1a>

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
 594:	4c55                	li	s8,21
 596:	00000c97          	auipc	s9,0x0
 59a:	482c8c93          	addi	s9,s9,1154 # a18 <malloc+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 59e:	02800d93          	li	s11,40
  putc(fd, 'x');
 5a2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	00000b97          	auipc	s7,0x0
 5a8:	4ccb8b93          	addi	s7,s7,1228 # a70 <digits>
 5ac:	a839                	j	5ca <vprintf+0x6a>
        putc(fd, c);
 5ae:	85ca                	mv	a1,s2
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	ee0080e7          	jalr	-288(ra) # 492 <putc>
 5ba:	a019                	j	5c0 <vprintf+0x60>
    } else if(state == '%'){
 5bc:	01498d63          	beq	s3,s4,5d6 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5c0:	0485                	addi	s1,s1,1
 5c2:	fff4c903          	lbu	s2,-1(s1)
 5c6:	14090d63          	beqz	s2,720 <vprintf+0x1c0>
    if(state == 0){
 5ca:	fe0999e3          	bnez	s3,5bc <vprintf+0x5c>
      if(c == '%'){
 5ce:	ff4910e3          	bne	s2,s4,5ae <vprintf+0x4e>
        state = '%';
 5d2:	89d2                	mv	s3,s4
 5d4:	b7f5                	j	5c0 <vprintf+0x60>
      if(c == 'd'){
 5d6:	11490c63          	beq	s2,s4,6ee <vprintf+0x18e>
 5da:	f9d9079b          	addiw	a5,s2,-99
 5de:	0ff7f793          	zext.b	a5,a5
 5e2:	10fc6e63          	bltu	s8,a5,6fe <vprintf+0x19e>
 5e6:	f9d9079b          	addiw	a5,s2,-99
 5ea:	0ff7f713          	zext.b	a4,a5
 5ee:	10ec6863          	bltu	s8,a4,6fe <vprintf+0x19e>
 5f2:	00271793          	slli	a5,a4,0x2
 5f6:	97e6                	add	a5,a5,s9
 5f8:	439c                	lw	a5,0(a5)
 5fa:	97e6                	add	a5,a5,s9
 5fc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5fe:	008b0913          	addi	s2,s6,8
 602:	4685                	li	a3,1
 604:	4629                	li	a2,10
 606:	000b2583          	lw	a1,0(s6)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	ea8080e7          	jalr	-344(ra) # 4b4 <printint>
 614:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 616:	4981                	li	s3,0
 618:	b765                	j	5c0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	008b0913          	addi	s2,s6,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000b2583          	lw	a1,0(s6)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e8c080e7          	jalr	-372(ra) # 4b4 <printint>
 630:	8b4a                	mv	s6,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	b771                	j	5c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 636:	008b0913          	addi	s2,s6,8
 63a:	4681                	li	a3,0
 63c:	866a                	mv	a2,s10
 63e:	000b2583          	lw	a1,0(s6)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e70080e7          	jalr	-400(ra) # 4b4 <printint>
 64c:	8b4a                	mv	s6,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	bf85                	j	5c0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 652:	008b0793          	addi	a5,s6,8
 656:	f8f43423          	sd	a5,-120(s0)
 65a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 65e:	03000593          	li	a1,48
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e2e080e7          	jalr	-466(ra) # 492 <putc>
  putc(fd, 'x');
 66c:	07800593          	li	a1,120
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e20080e7          	jalr	-480(ra) # 492 <putc>
 67a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67c:	03c9d793          	srli	a5,s3,0x3c
 680:	97de                	add	a5,a5,s7
 682:	0007c583          	lbu	a1,0(a5)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	e0a080e7          	jalr	-502(ra) # 492 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 690:	0992                	slli	s3,s3,0x4
 692:	397d                	addiw	s2,s2,-1
 694:	fe0914e3          	bnez	s2,67c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 698:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b70d                	j	5c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 6a0:	008b0913          	addi	s2,s6,8
 6a4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6a8:	02098163          	beqz	s3,6ca <vprintf+0x16a>
        while(*s != 0){
 6ac:	0009c583          	lbu	a1,0(s3)
 6b0:	c5ad                	beqz	a1,71a <vprintf+0x1ba>
          putc(fd, *s);
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	dde080e7          	jalr	-546(ra) # 492 <putc>
          s++;
 6bc:	0985                	addi	s3,s3,1
        while(*s != 0){
 6be:	0009c583          	lbu	a1,0(s3)
 6c2:	f9e5                	bnez	a1,6b2 <vprintf+0x152>
        s = va_arg(ap, char*);
 6c4:	8b4a                	mv	s6,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bde5                	j	5c0 <vprintf+0x60>
          s = "(null)";
 6ca:	00000997          	auipc	s3,0x0
 6ce:	34698993          	addi	s3,s3,838 # a10 <malloc+0x1ec>
        while(*s != 0){
 6d2:	85ee                	mv	a1,s11
 6d4:	bff9                	j	6b2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6d6:	008b0913          	addi	s2,s6,8
 6da:	000b4583          	lbu	a1,0(s6)
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	db2080e7          	jalr	-590(ra) # 492 <putc>
 6e8:	8b4a                	mv	s6,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bdd1                	j	5c0 <vprintf+0x60>
        putc(fd, c);
 6ee:	85d2                	mv	a1,s4
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	da0080e7          	jalr	-608(ra) # 492 <putc>
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b5d1                	j	5c0 <vprintf+0x60>
        putc(fd, '%');
 6fe:	85d2                	mv	a1,s4
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	d90080e7          	jalr	-624(ra) # 492 <putc>
        putc(fd, c);
 70a:	85ca                	mv	a1,s2
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	d84080e7          	jalr	-636(ra) # 492 <putc>
      state = 0;
 716:	4981                	li	s3,0
 718:	b565                	j	5c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 71a:	8b4a                	mv	s6,s2
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
 7b4:	a02d                	j	7de <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b6:	4618                	lw	a4,8(a2)
 7b8:	9f2d                	addw	a4,a4,a1
 7ba:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7be:	6398                	ld	a4,0(a5)
 7c0:	6310                	ld	a2,0(a4)
 7c2:	a83d                	j	800 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c4:	ff852703          	lw	a4,-8(a0)
 7c8:	9f31                	addw	a4,a4,a2
 7ca:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7cc:	ff053683          	ld	a3,-16(a0)
 7d0:	a091                	j	814 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d2:	6398                	ld	a4,0(a5)
 7d4:	00e7e463          	bltu	a5,a4,7dc <free+0x3a>
 7d8:	00e6ea63          	bltu	a3,a4,7ec <free+0x4a>
{
 7dc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7de:	fed7fae3          	bgeu	a5,a3,7d2 <free+0x30>
 7e2:	6398                	ld	a4,0(a5)
 7e4:	00e6e463          	bltu	a3,a4,7ec <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e8:	fee7eae3          	bltu	a5,a4,7dc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ec:	ff852583          	lw	a1,-8(a0)
 7f0:	6390                	ld	a2,0(a5)
 7f2:	02059813          	slli	a6,a1,0x20
 7f6:	01c85713          	srli	a4,a6,0x1c
 7fa:	9736                	add	a4,a4,a3
 7fc:	fae60de3          	beq	a2,a4,7b6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 800:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 804:	4790                	lw	a2,8(a5)
 806:	02061593          	slli	a1,a2,0x20
 80a:	01c5d713          	srli	a4,a1,0x1c
 80e:	973e                	add	a4,a4,a5
 810:	fae68ae3          	beq	a3,a4,7c4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 814:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 816:	00000717          	auipc	a4,0x0
 81a:	7ef73523          	sd	a5,2026(a4) # 1000 <freep>
}
 81e:	6422                	ld	s0,8(sp)
 820:	0141                	addi	sp,sp,16
 822:	8082                	ret

0000000000000824 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 824:	7139                	addi	sp,sp,-64
 826:	fc06                	sd	ra,56(sp)
 828:	f822                	sd	s0,48(sp)
 82a:	f426                	sd	s1,40(sp)
 82c:	f04a                	sd	s2,32(sp)
 82e:	ec4e                	sd	s3,24(sp)
 830:	e852                	sd	s4,16(sp)
 832:	e456                	sd	s5,8(sp)
 834:	e05a                	sd	s6,0(sp)
 836:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 838:	02051493          	slli	s1,a0,0x20
 83c:	9081                	srli	s1,s1,0x20
 83e:	04bd                	addi	s1,s1,15
 840:	8091                	srli	s1,s1,0x4
 842:	0014899b          	addiw	s3,s1,1
 846:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 848:	00000517          	auipc	a0,0x0
 84c:	7b853503          	ld	a0,1976(a0) # 1000 <freep>
 850:	c515                	beqz	a0,87c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 852:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 854:	4798                	lw	a4,8(a5)
 856:	02977f63          	bgeu	a4,s1,894 <malloc+0x70>
 85a:	8a4e                	mv	s4,s3
 85c:	0009871b          	sext.w	a4,s3
 860:	6685                	lui	a3,0x1
 862:	00d77363          	bgeu	a4,a3,868 <malloc+0x44>
 866:	6a05                	lui	s4,0x1
 868:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 86c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 870:	00000917          	auipc	s2,0x0
 874:	79090913          	addi	s2,s2,1936 # 1000 <freep>
  if(p == (char*)-1)
 878:	5afd                	li	s5,-1
 87a:	a895                	j	8ee <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 87c:	00000797          	auipc	a5,0x0
 880:	79478793          	addi	a5,a5,1940 # 1010 <base>
 884:	00000717          	auipc	a4,0x0
 888:	76f73e23          	sd	a5,1916(a4) # 1000 <freep>
 88c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 892:	b7e1                	j	85a <malloc+0x36>
      if(p->s.size == nunits)
 894:	02e48c63          	beq	s1,a4,8cc <malloc+0xa8>
        p->s.size -= nunits;
 898:	4137073b          	subw	a4,a4,s3
 89c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89e:	02071693          	slli	a3,a4,0x20
 8a2:	01c6d713          	srli	a4,a3,0x1c
 8a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74a73a23          	sd	a0,1876(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b8:	70e2                	ld	ra,56(sp)
 8ba:	7442                	ld	s0,48(sp)
 8bc:	74a2                	ld	s1,40(sp)
 8be:	7902                	ld	s2,32(sp)
 8c0:	69e2                	ld	s3,24(sp)
 8c2:	6a42                	ld	s4,16(sp)
 8c4:	6aa2                	ld	s5,8(sp)
 8c6:	6b02                	ld	s6,0(sp)
 8c8:	6121                	addi	sp,sp,64
 8ca:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8cc:	6398                	ld	a4,0(a5)
 8ce:	e118                	sd	a4,0(a0)
 8d0:	bff1                	j	8ac <malloc+0x88>
  hp->s.size = nu;
 8d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d6:	0541                	addi	a0,a0,16
 8d8:	00000097          	auipc	ra,0x0
 8dc:	eca080e7          	jalr	-310(ra) # 7a2 <free>
  return freep;
 8e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e4:	d971                	beqz	a0,8b8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e8:	4798                	lw	a4,8(a5)
 8ea:	fa9775e3          	bgeu	a4,s1,894 <malloc+0x70>
    if(p == freep)
 8ee:	00093703          	ld	a4,0(s2)
 8f2:	853e                	mv	a0,a5
 8f4:	fef719e3          	bne	a4,a5,8e6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8f8:	8552                	mv	a0,s4
 8fa:	00000097          	auipc	ra,0x0
 8fe:	b60080e7          	jalr	-1184(ra) # 45a <sbrk>
  if(p == (char*)-1)
 902:	fd5518e3          	bne	a0,s5,8d2 <malloc+0xae>
        return 0;
 906:	4501                	li	a0,0
 908:	bf45                	j	8b8 <malloc+0x94>

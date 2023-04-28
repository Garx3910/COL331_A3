
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  11:	83 ec 08             	sub    $0x8,%esp
  14:	6a 02                	push   $0x2
  16:	68 86 08 00 00       	push   $0x886
  1b:	e8 78 03 00 00       	call   398 <open>
  20:	83 c4 10             	add    $0x10,%esp
  23:	85 c0                	test   %eax,%eax
  25:	79 26                	jns    4d <main+0x4d>
    mknod("console", 1, 1);
  27:	83 ec 04             	sub    $0x4,%esp
  2a:	6a 01                	push   $0x1
  2c:	6a 01                	push   $0x1
  2e:	68 86 08 00 00       	push   $0x886
  33:	e8 68 03 00 00       	call   3a0 <mknod>
  38:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	6a 02                	push   $0x2
  40:	68 86 08 00 00       	push   $0x886
  45:	e8 4e 03 00 00       	call   398 <open>
  4a:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
  4d:	83 ec 0c             	sub    $0xc,%esp
  50:	6a 00                	push   $0x0
  52:	e8 79 03 00 00       	call   3d0 <dup>
  57:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 6c 03 00 00       	call   3d0 <dup>
  64:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
  67:	83 ec 08             	sub    $0x8,%esp
  6a:	68 8e 08 00 00       	push   $0x88e
  6f:	6a 01                	push   $0x1
  71:	e8 56 04 00 00       	call   4cc <printf>
  76:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  79:	e8 d2 02 00 00       	call   350 <fork>
  7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  85:	79 17                	jns    9e <main+0x9e>
      printf(1, "init: fork failed\n");
  87:	83 ec 08             	sub    $0x8,%esp
  8a:	68 a1 08 00 00       	push   $0x8a1
  8f:	6a 01                	push   $0x1
  91:	e8 36 04 00 00       	call   4cc <printf>
  96:	83 c4 10             	add    $0x10,%esp
      exit();
  99:	e8 ba 02 00 00       	call   358 <exit>
    }
    if(pid == 0){
  9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a2:	75 3e                	jne    e2 <main+0xe2>
      exec("sh", argv);
  a4:	83 ec 08             	sub    $0x8,%esp
  a7:	68 20 0b 00 00       	push   $0xb20
  ac:	68 83 08 00 00       	push   $0x883
  b1:	e8 da 02 00 00       	call   390 <exec>
  b6:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
  b9:	83 ec 08             	sub    $0x8,%esp
  bc:	68 b4 08 00 00       	push   $0x8b4
  c1:	6a 01                	push   $0x1
  c3:	e8 04 04 00 00       	call   4cc <printf>
  c8:	83 c4 10             	add    $0x10,%esp
      exit();
  cb:	e8 88 02 00 00       	call   358 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  d0:	83 ec 08             	sub    $0x8,%esp
  d3:	68 ca 08 00 00       	push   $0x8ca
  d8:	6a 01                	push   $0x1
  da:	e8 ed 03 00 00       	call   4cc <printf>
  df:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  e2:	e8 79 02 00 00       	call   360 <wait>
  e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  ee:	0f 88 73 ff ff ff    	js     67 <main+0x67>
  f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  f7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  fa:	75 d4                	jne    d0 <main+0xd0>
    printf(1, "init: starting sh\n");
  fc:	e9 66 ff ff ff       	jmp    67 <main+0x67>

00000101 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 101:	55                   	push   %ebp
 102:	89 e5                	mov    %esp,%ebp
 104:	57                   	push   %edi
 105:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 106:	8b 4d 08             	mov    0x8(%ebp),%ecx
 109:	8b 55 10             	mov    0x10(%ebp),%edx
 10c:	8b 45 0c             	mov    0xc(%ebp),%eax
 10f:	89 cb                	mov    %ecx,%ebx
 111:	89 df                	mov    %ebx,%edi
 113:	89 d1                	mov    %edx,%ecx
 115:	fc                   	cld    
 116:	f3 aa                	rep stos %al,%es:(%edi)
 118:	89 ca                	mov    %ecx,%edx
 11a:	89 fb                	mov    %edi,%ebx
 11c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 11f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 122:	90                   	nop
 123:	5b                   	pop    %ebx
 124:	5f                   	pop    %edi
 125:	5d                   	pop    %ebp
 126:	c3                   	ret    

00000127 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 12d:	8b 45 08             	mov    0x8(%ebp),%eax
 130:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 133:	90                   	nop
 134:	8b 55 0c             	mov    0xc(%ebp),%edx
 137:	8d 42 01             	lea    0x1(%edx),%eax
 13a:	89 45 0c             	mov    %eax,0xc(%ebp)
 13d:	8b 45 08             	mov    0x8(%ebp),%eax
 140:	8d 48 01             	lea    0x1(%eax),%ecx
 143:	89 4d 08             	mov    %ecx,0x8(%ebp)
 146:	0f b6 12             	movzbl (%edx),%edx
 149:	88 10                	mov    %dl,(%eax)
 14b:	0f b6 00             	movzbl (%eax),%eax
 14e:	84 c0                	test   %al,%al
 150:	75 e2                	jne    134 <strcpy+0xd>
    ;
  return os;
 152:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 155:	c9                   	leave  
 156:	c3                   	ret    

00000157 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 15a:	eb 08                	jmp    164 <strcmp+0xd>
    p++, q++;
 15c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 160:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	0f b6 00             	movzbl (%eax),%eax
 16a:	84 c0                	test   %al,%al
 16c:	74 10                	je     17e <strcmp+0x27>
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 10             	movzbl (%eax),%edx
 174:	8b 45 0c             	mov    0xc(%ebp),%eax
 177:	0f b6 00             	movzbl (%eax),%eax
 17a:	38 c2                	cmp    %al,%dl
 17c:	74 de                	je     15c <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 17e:	8b 45 08             	mov    0x8(%ebp),%eax
 181:	0f b6 00             	movzbl (%eax),%eax
 184:	0f b6 d0             	movzbl %al,%edx
 187:	8b 45 0c             	mov    0xc(%ebp),%eax
 18a:	0f b6 00             	movzbl (%eax),%eax
 18d:	0f b6 c8             	movzbl %al,%ecx
 190:	89 d0                	mov    %edx,%eax
 192:	29 c8                	sub    %ecx,%eax
}
 194:	5d                   	pop    %ebp
 195:	c3                   	ret    

00000196 <strlen>:

uint
strlen(const char *s)
{
 196:	55                   	push   %ebp
 197:	89 e5                	mov    %esp,%ebp
 199:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 19c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a3:	eb 04                	jmp    1a9 <strlen+0x13>
 1a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	01 d0                	add    %edx,%eax
 1b1:	0f b6 00             	movzbl (%eax),%eax
 1b4:	84 c0                	test   %al,%al
 1b6:	75 ed                	jne    1a5 <strlen+0xf>
    ;
  return n;
 1b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1bb:	c9                   	leave  
 1bc:	c3                   	ret    

000001bd <memset>:

void*
memset(void *dst, int c, uint n)
{
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1c0:	8b 45 10             	mov    0x10(%ebp),%eax
 1c3:	50                   	push   %eax
 1c4:	ff 75 0c             	push   0xc(%ebp)
 1c7:	ff 75 08             	push   0x8(%ebp)
 1ca:	e8 32 ff ff ff       	call   101 <stosb>
 1cf:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d5:	c9                   	leave  
 1d6:	c3                   	ret    

000001d7 <strchr>:

char*
strchr(const char *s, char c)
{
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
 1da:	83 ec 04             	sub    $0x4,%esp
 1dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1e3:	eb 14                	jmp    1f9 <strchr+0x22>
    if(*s == c)
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	0f b6 00             	movzbl (%eax),%eax
 1eb:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1ee:	75 05                	jne    1f5 <strchr+0x1e>
      return (char*)s;
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	eb 13                	jmp    208 <strchr+0x31>
  for(; *s; s++)
 1f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	0f b6 00             	movzbl (%eax),%eax
 1ff:	84 c0                	test   %al,%al
 201:	75 e2                	jne    1e5 <strchr+0xe>
  return 0;
 203:	b8 00 00 00 00       	mov    $0x0,%eax
}
 208:	c9                   	leave  
 209:	c3                   	ret    

0000020a <gets>:

char*
gets(char *buf, int max)
{
 20a:	55                   	push   %ebp
 20b:	89 e5                	mov    %esp,%ebp
 20d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 210:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 217:	eb 42                	jmp    25b <gets+0x51>
    cc = read(0, &c, 1);
 219:	83 ec 04             	sub    $0x4,%esp
 21c:	6a 01                	push   $0x1
 21e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 221:	50                   	push   %eax
 222:	6a 00                	push   $0x0
 224:	e8 47 01 00 00       	call   370 <read>
 229:	83 c4 10             	add    $0x10,%esp
 22c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 22f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 233:	7e 33                	jle    268 <gets+0x5e>
      break;
    buf[i++] = c;
 235:	8b 45 f4             	mov    -0xc(%ebp),%eax
 238:	8d 50 01             	lea    0x1(%eax),%edx
 23b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 23e:	89 c2                	mov    %eax,%edx
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	01 c2                	add    %eax,%edx
 245:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 249:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 24b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24f:	3c 0a                	cmp    $0xa,%al
 251:	74 16                	je     269 <gets+0x5f>
 253:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 257:	3c 0d                	cmp    $0xd,%al
 259:	74 0e                	je     269 <gets+0x5f>
  for(i=0; i+1 < max; ){
 25b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25e:	83 c0 01             	add    $0x1,%eax
 261:	39 45 0c             	cmp    %eax,0xc(%ebp)
 264:	7f b3                	jg     219 <gets+0xf>
 266:	eb 01                	jmp    269 <gets+0x5f>
      break;
 268:	90                   	nop
      break;
  }
  buf[i] = '\0';
 269:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	01 d0                	add    %edx,%eax
 271:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <stat>:

int
stat(const char *n, struct stat *st)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27f:	83 ec 08             	sub    $0x8,%esp
 282:	6a 00                	push   $0x0
 284:	ff 75 08             	push   0x8(%ebp)
 287:	e8 0c 01 00 00       	call   398 <open>
 28c:	83 c4 10             	add    $0x10,%esp
 28f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 292:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 296:	79 07                	jns    29f <stat+0x26>
    return -1;
 298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29d:	eb 25                	jmp    2c4 <stat+0x4b>
  r = fstat(fd, st);
 29f:	83 ec 08             	sub    $0x8,%esp
 2a2:	ff 75 0c             	push   0xc(%ebp)
 2a5:	ff 75 f4             	push   -0xc(%ebp)
 2a8:	e8 03 01 00 00       	call   3b0 <fstat>
 2ad:	83 c4 10             	add    $0x10,%esp
 2b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b3:	83 ec 0c             	sub    $0xc,%esp
 2b6:	ff 75 f4             	push   -0xc(%ebp)
 2b9:	e8 c2 00 00 00       	call   380 <close>
 2be:	83 c4 10             	add    $0x10,%esp
  return r;
 2c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c4:	c9                   	leave  
 2c5:	c3                   	ret    

000002c6 <atoi>:

int
atoi(const char *s)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d3:	eb 25                	jmp    2fa <atoi+0x34>
    n = n*10 + *s++ - '0';
 2d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d8:	89 d0                	mov    %edx,%eax
 2da:	c1 e0 02             	shl    $0x2,%eax
 2dd:	01 d0                	add    %edx,%eax
 2df:	01 c0                	add    %eax,%eax
 2e1:	89 c1                	mov    %eax,%ecx
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	8d 50 01             	lea    0x1(%eax),%edx
 2e9:	89 55 08             	mov    %edx,0x8(%ebp)
 2ec:	0f b6 00             	movzbl (%eax),%eax
 2ef:	0f be c0             	movsbl %al,%eax
 2f2:	01 c8                	add    %ecx,%eax
 2f4:	83 e8 30             	sub    $0x30,%eax
 2f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	0f b6 00             	movzbl (%eax),%eax
 300:	3c 2f                	cmp    $0x2f,%al
 302:	7e 0a                	jle    30e <atoi+0x48>
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	3c 39                	cmp    $0x39,%al
 30c:	7e c7                	jle    2d5 <atoi+0xf>
  return n;
 30e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 311:	c9                   	leave  
 312:	c3                   	ret    

00000313 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 313:	55                   	push   %ebp
 314:	89 e5                	mov    %esp,%ebp
 316:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 319:	8b 45 08             	mov    0x8(%ebp),%eax
 31c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 31f:	8b 45 0c             	mov    0xc(%ebp),%eax
 322:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 325:	eb 17                	jmp    33e <memmove+0x2b>
    *dst++ = *src++;
 327:	8b 55 f8             	mov    -0x8(%ebp),%edx
 32a:	8d 42 01             	lea    0x1(%edx),%eax
 32d:	89 45 f8             	mov    %eax,-0x8(%ebp)
 330:	8b 45 fc             	mov    -0x4(%ebp),%eax
 333:	8d 48 01             	lea    0x1(%eax),%ecx
 336:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 339:	0f b6 12             	movzbl (%edx),%edx
 33c:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 33e:	8b 45 10             	mov    0x10(%ebp),%eax
 341:	8d 50 ff             	lea    -0x1(%eax),%edx
 344:	89 55 10             	mov    %edx,0x10(%ebp)
 347:	85 c0                	test   %eax,%eax
 349:	7f dc                	jg     327 <memmove+0x14>
  return vdst;
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34e:	c9                   	leave  
 34f:	c3                   	ret    

00000350 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 350:	b8 01 00 00 00       	mov    $0x1,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <exit>:
SYSCALL(exit)
 358:	b8 02 00 00 00       	mov    $0x2,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <wait>:
SYSCALL(wait)
 360:	b8 03 00 00 00       	mov    $0x3,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <pipe>:
SYSCALL(pipe)
 368:	b8 04 00 00 00       	mov    $0x4,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <read>:
SYSCALL(read)
 370:	b8 05 00 00 00       	mov    $0x5,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <write>:
SYSCALL(write)
 378:	b8 10 00 00 00       	mov    $0x10,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <close>:
SYSCALL(close)
 380:	b8 15 00 00 00       	mov    $0x15,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <kill>:
SYSCALL(kill)
 388:	b8 06 00 00 00       	mov    $0x6,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <exec>:
SYSCALL(exec)
 390:	b8 07 00 00 00       	mov    $0x7,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <open>:
SYSCALL(open)
 398:	b8 0f 00 00 00       	mov    $0xf,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <mknod>:
SYSCALL(mknod)
 3a0:	b8 11 00 00 00       	mov    $0x11,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <unlink>:
SYSCALL(unlink)
 3a8:	b8 12 00 00 00       	mov    $0x12,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <fstat>:
SYSCALL(fstat)
 3b0:	b8 08 00 00 00       	mov    $0x8,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <link>:
SYSCALL(link)
 3b8:	b8 13 00 00 00       	mov    $0x13,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <mkdir>:
SYSCALL(mkdir)
 3c0:	b8 14 00 00 00       	mov    $0x14,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <chdir>:
SYSCALL(chdir)
 3c8:	b8 09 00 00 00       	mov    $0x9,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <dup>:
SYSCALL(dup)
 3d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <getpid>:
SYSCALL(getpid)
 3d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <sbrk>:
SYSCALL(sbrk)
 3e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <sleep>:
SYSCALL(sleep)
 3e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <uptime>:
SYSCALL(uptime)
 3f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	83 ec 18             	sub    $0x18,%esp
 3fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 401:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 404:	83 ec 04             	sub    $0x4,%esp
 407:	6a 01                	push   $0x1
 409:	8d 45 f4             	lea    -0xc(%ebp),%eax
 40c:	50                   	push   %eax
 40d:	ff 75 08             	push   0x8(%ebp)
 410:	e8 63 ff ff ff       	call   378 <write>
 415:	83 c4 10             	add    $0x10,%esp
}
 418:	90                   	nop
 419:	c9                   	leave  
 41a:	c3                   	ret    

0000041b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 41b:	55                   	push   %ebp
 41c:	89 e5                	mov    %esp,%ebp
 41e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 421:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 428:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 42c:	74 17                	je     445 <printint+0x2a>
 42e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 432:	79 11                	jns    445 <printint+0x2a>
    neg = 1;
 434:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 43b:	8b 45 0c             	mov    0xc(%ebp),%eax
 43e:	f7 d8                	neg    %eax
 440:	89 45 ec             	mov    %eax,-0x14(%ebp)
 443:	eb 06                	jmp    44b <printint+0x30>
  } else {
    x = xx;
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 44b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 452:	8b 4d 10             	mov    0x10(%ebp),%ecx
 455:	8b 45 ec             	mov    -0x14(%ebp),%eax
 458:	ba 00 00 00 00       	mov    $0x0,%edx
 45d:	f7 f1                	div    %ecx
 45f:	89 d1                	mov    %edx,%ecx
 461:	8b 45 f4             	mov    -0xc(%ebp),%eax
 464:	8d 50 01             	lea    0x1(%eax),%edx
 467:	89 55 f4             	mov    %edx,-0xc(%ebp)
 46a:	0f b6 91 28 0b 00 00 	movzbl 0xb28(%ecx),%edx
 471:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 475:	8b 4d 10             	mov    0x10(%ebp),%ecx
 478:	8b 45 ec             	mov    -0x14(%ebp),%eax
 47b:	ba 00 00 00 00       	mov    $0x0,%edx
 480:	f7 f1                	div    %ecx
 482:	89 45 ec             	mov    %eax,-0x14(%ebp)
 485:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 489:	75 c7                	jne    452 <printint+0x37>
  if(neg)
 48b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 48f:	74 2d                	je     4be <printint+0xa3>
    buf[i++] = '-';
 491:	8b 45 f4             	mov    -0xc(%ebp),%eax
 494:	8d 50 01             	lea    0x1(%eax),%edx
 497:	89 55 f4             	mov    %edx,-0xc(%ebp)
 49a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 49f:	eb 1d                	jmp    4be <printint+0xa3>
    putc(fd, buf[i]);
 4a1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a7:	01 d0                	add    %edx,%eax
 4a9:	0f b6 00             	movzbl (%eax),%eax
 4ac:	0f be c0             	movsbl %al,%eax
 4af:	83 ec 08             	sub    $0x8,%esp
 4b2:	50                   	push   %eax
 4b3:	ff 75 08             	push   0x8(%ebp)
 4b6:	e8 3d ff ff ff       	call   3f8 <putc>
 4bb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4be:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c6:	79 d9                	jns    4a1 <printint+0x86>
}
 4c8:	90                   	nop
 4c9:	90                   	nop
 4ca:	c9                   	leave  
 4cb:	c3                   	ret    

000004cc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4cc:	55                   	push   %ebp
 4cd:	89 e5                	mov    %esp,%ebp
 4cf:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d9:	8d 45 0c             	lea    0xc(%ebp),%eax
 4dc:	83 c0 04             	add    $0x4,%eax
 4df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e9:	e9 59 01 00 00       	jmp    647 <printf+0x17b>
    c = fmt[i] & 0xff;
 4ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 4f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4f4:	01 d0                	add    %edx,%eax
 4f6:	0f b6 00             	movzbl (%eax),%eax
 4f9:	0f be c0             	movsbl %al,%eax
 4fc:	25 ff 00 00 00       	and    $0xff,%eax
 501:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 504:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 508:	75 2c                	jne    536 <printf+0x6a>
      if(c == '%'){
 50a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 50e:	75 0c                	jne    51c <printf+0x50>
        state = '%';
 510:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 517:	e9 27 01 00 00       	jmp    643 <printf+0x177>
      } else {
        putc(fd, c);
 51c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51f:	0f be c0             	movsbl %al,%eax
 522:	83 ec 08             	sub    $0x8,%esp
 525:	50                   	push   %eax
 526:	ff 75 08             	push   0x8(%ebp)
 529:	e8 ca fe ff ff       	call   3f8 <putc>
 52e:	83 c4 10             	add    $0x10,%esp
 531:	e9 0d 01 00 00       	jmp    643 <printf+0x177>
      }
    } else if(state == '%'){
 536:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 53a:	0f 85 03 01 00 00    	jne    643 <printf+0x177>
      if(c == 'd'){
 540:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 544:	75 1e                	jne    564 <printf+0x98>
        printint(fd, *ap, 10, 1);
 546:	8b 45 e8             	mov    -0x18(%ebp),%eax
 549:	8b 00                	mov    (%eax),%eax
 54b:	6a 01                	push   $0x1
 54d:	6a 0a                	push   $0xa
 54f:	50                   	push   %eax
 550:	ff 75 08             	push   0x8(%ebp)
 553:	e8 c3 fe ff ff       	call   41b <printint>
 558:	83 c4 10             	add    $0x10,%esp
        ap++;
 55b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55f:	e9 d8 00 00 00       	jmp    63c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 564:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 568:	74 06                	je     570 <printf+0xa4>
 56a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 56e:	75 1e                	jne    58e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 570:	8b 45 e8             	mov    -0x18(%ebp),%eax
 573:	8b 00                	mov    (%eax),%eax
 575:	6a 00                	push   $0x0
 577:	6a 10                	push   $0x10
 579:	50                   	push   %eax
 57a:	ff 75 08             	push   0x8(%ebp)
 57d:	e8 99 fe ff ff       	call   41b <printint>
 582:	83 c4 10             	add    $0x10,%esp
        ap++;
 585:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 589:	e9 ae 00 00 00       	jmp    63c <printf+0x170>
      } else if(c == 's'){
 58e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 592:	75 43                	jne    5d7 <printf+0x10b>
        s = (char*)*ap;
 594:	8b 45 e8             	mov    -0x18(%ebp),%eax
 597:	8b 00                	mov    (%eax),%eax
 599:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 59c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a4:	75 25                	jne    5cb <printf+0xff>
          s = "(null)";
 5a6:	c7 45 f4 d3 08 00 00 	movl   $0x8d3,-0xc(%ebp)
        while(*s != 0){
 5ad:	eb 1c                	jmp    5cb <printf+0xff>
          putc(fd, *s);
 5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b2:	0f b6 00             	movzbl (%eax),%eax
 5b5:	0f be c0             	movsbl %al,%eax
 5b8:	83 ec 08             	sub    $0x8,%esp
 5bb:	50                   	push   %eax
 5bc:	ff 75 08             	push   0x8(%ebp)
 5bf:	e8 34 fe ff ff       	call   3f8 <putc>
 5c4:	83 c4 10             	add    $0x10,%esp
          s++;
 5c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ce:	0f b6 00             	movzbl (%eax),%eax
 5d1:	84 c0                	test   %al,%al
 5d3:	75 da                	jne    5af <printf+0xe3>
 5d5:	eb 65                	jmp    63c <printf+0x170>
        }
      } else if(c == 'c'){
 5d7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5db:	75 1d                	jne    5fa <printf+0x12e>
        putc(fd, *ap);
 5dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e0:	8b 00                	mov    (%eax),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	83 ec 08             	sub    $0x8,%esp
 5e8:	50                   	push   %eax
 5e9:	ff 75 08             	push   0x8(%ebp)
 5ec:	e8 07 fe ff ff       	call   3f8 <putc>
 5f1:	83 c4 10             	add    $0x10,%esp
        ap++;
 5f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f8:	eb 42                	jmp    63c <printf+0x170>
      } else if(c == '%'){
 5fa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5fe:	75 17                	jne    617 <printf+0x14b>
        putc(fd, c);
 600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 603:	0f be c0             	movsbl %al,%eax
 606:	83 ec 08             	sub    $0x8,%esp
 609:	50                   	push   %eax
 60a:	ff 75 08             	push   0x8(%ebp)
 60d:	e8 e6 fd ff ff       	call   3f8 <putc>
 612:	83 c4 10             	add    $0x10,%esp
 615:	eb 25                	jmp    63c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 617:	83 ec 08             	sub    $0x8,%esp
 61a:	6a 25                	push   $0x25
 61c:	ff 75 08             	push   0x8(%ebp)
 61f:	e8 d4 fd ff ff       	call   3f8 <putc>
 624:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 627:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62a:	0f be c0             	movsbl %al,%eax
 62d:	83 ec 08             	sub    $0x8,%esp
 630:	50                   	push   %eax
 631:	ff 75 08             	push   0x8(%ebp)
 634:	e8 bf fd ff ff       	call   3f8 <putc>
 639:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 63c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 643:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 647:	8b 55 0c             	mov    0xc(%ebp),%edx
 64a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64d:	01 d0                	add    %edx,%eax
 64f:	0f b6 00             	movzbl (%eax),%eax
 652:	84 c0                	test   %al,%al
 654:	0f 85 94 fe ff ff    	jne    4ee <printf+0x22>
    }
  }
}
 65a:	90                   	nop
 65b:	90                   	nop
 65c:	c9                   	leave  
 65d:	c3                   	ret    

0000065e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 65e:	55                   	push   %ebp
 65f:	89 e5                	mov    %esp,%ebp
 661:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 664:	8b 45 08             	mov    0x8(%ebp),%eax
 667:	83 e8 08             	sub    $0x8,%eax
 66a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66d:	a1 44 0b 00 00       	mov    0xb44,%eax
 672:	89 45 fc             	mov    %eax,-0x4(%ebp)
 675:	eb 24                	jmp    69b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 677:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67a:	8b 00                	mov    (%eax),%eax
 67c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 67f:	72 12                	jb     693 <free+0x35>
 681:	8b 45 f8             	mov    -0x8(%ebp),%eax
 684:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 687:	77 24                	ja     6ad <free+0x4f>
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 691:	72 1a                	jb     6ad <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 693:	8b 45 fc             	mov    -0x4(%ebp),%eax
 696:	8b 00                	mov    (%eax),%eax
 698:	89 45 fc             	mov    %eax,-0x4(%ebp)
 69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a1:	76 d4                	jbe    677 <free+0x19>
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	8b 00                	mov    (%eax),%eax
 6a8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6ab:	73 ca                	jae    677 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b0:	8b 40 04             	mov    0x4(%eax),%eax
 6b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bd:	01 c2                	add    %eax,%edx
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	8b 00                	mov    (%eax),%eax
 6c4:	39 c2                	cmp    %eax,%edx
 6c6:	75 24                	jne    6ec <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cb:	8b 50 04             	mov    0x4(%eax),%edx
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	8b 00                	mov    (%eax),%eax
 6d3:	8b 40 04             	mov    0x4(%eax),%eax
 6d6:	01 c2                	add    %eax,%edx
 6d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6db:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e1:	8b 00                	mov    (%eax),%eax
 6e3:	8b 10                	mov    (%eax),%edx
 6e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e8:	89 10                	mov    %edx,(%eax)
 6ea:	eb 0a                	jmp    6f6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 10                	mov    (%eax),%edx
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 40 04             	mov    0x4(%eax),%eax
 6fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 703:	8b 45 fc             	mov    -0x4(%ebp),%eax
 706:	01 d0                	add    %edx,%eax
 708:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 70b:	75 20                	jne    72d <free+0xcf>
    p->s.size += bp->s.size;
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 50 04             	mov    0x4(%eax),%edx
 713:	8b 45 f8             	mov    -0x8(%ebp),%eax
 716:	8b 40 04             	mov    0x4(%eax),%eax
 719:	01 c2                	add    %eax,%edx
 71b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 721:	8b 45 f8             	mov    -0x8(%ebp),%eax
 724:	8b 10                	mov    (%eax),%edx
 726:	8b 45 fc             	mov    -0x4(%ebp),%eax
 729:	89 10                	mov    %edx,(%eax)
 72b:	eb 08                	jmp    735 <free+0xd7>
  } else
    p->s.ptr = bp;
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 55 f8             	mov    -0x8(%ebp),%edx
 733:	89 10                	mov    %edx,(%eax)
  freep = p;
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	a3 44 0b 00 00       	mov    %eax,0xb44
}
 73d:	90                   	nop
 73e:	c9                   	leave  
 73f:	c3                   	ret    

00000740 <morecore>:

static Header*
morecore(uint nu)
{
 740:	55                   	push   %ebp
 741:	89 e5                	mov    %esp,%ebp
 743:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 746:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 74d:	77 07                	ja     756 <morecore+0x16>
    nu = 4096;
 74f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 756:	8b 45 08             	mov    0x8(%ebp),%eax
 759:	c1 e0 03             	shl    $0x3,%eax
 75c:	83 ec 0c             	sub    $0xc,%esp
 75f:	50                   	push   %eax
 760:	e8 7b fc ff ff       	call   3e0 <sbrk>
 765:	83 c4 10             	add    $0x10,%esp
 768:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 76b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 76f:	75 07                	jne    778 <morecore+0x38>
    return 0;
 771:	b8 00 00 00 00       	mov    $0x0,%eax
 776:	eb 26                	jmp    79e <morecore+0x5e>
  hp = (Header*)p;
 778:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 77e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 781:	8b 55 08             	mov    0x8(%ebp),%edx
 784:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 787:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78a:	83 c0 08             	add    $0x8,%eax
 78d:	83 ec 0c             	sub    $0xc,%esp
 790:	50                   	push   %eax
 791:	e8 c8 fe ff ff       	call   65e <free>
 796:	83 c4 10             	add    $0x10,%esp
  return freep;
 799:	a1 44 0b 00 00       	mov    0xb44,%eax
}
 79e:	c9                   	leave  
 79f:	c3                   	ret    

000007a0 <malloc>:

void*
malloc(uint nbytes)
{
 7a0:	55                   	push   %ebp
 7a1:	89 e5                	mov    %esp,%ebp
 7a3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	83 c0 07             	add    $0x7,%eax
 7ac:	c1 e8 03             	shr    $0x3,%eax
 7af:	83 c0 01             	add    $0x1,%eax
 7b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7b5:	a1 44 0b 00 00       	mov    0xb44,%eax
 7ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7c1:	75 23                	jne    7e6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7c3:	c7 45 f0 3c 0b 00 00 	movl   $0xb3c,-0x10(%ebp)
 7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cd:	a3 44 0b 00 00       	mov    %eax,0xb44
 7d2:	a1 44 0b 00 00       	mov    0xb44,%eax
 7d7:	a3 3c 0b 00 00       	mov    %eax,0xb3c
    base.s.size = 0;
 7dc:	c7 05 40 0b 00 00 00 	movl   $0x0,0xb40
 7e3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	8b 00                	mov    (%eax),%eax
 7eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f1:	8b 40 04             	mov    0x4(%eax),%eax
 7f4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7f7:	77 4d                	ja     846 <malloc+0xa6>
      if(p->s.size == nunits)
 7f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fc:	8b 40 04             	mov    0x4(%eax),%eax
 7ff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 802:	75 0c                	jne    810 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	8b 10                	mov    (%eax),%edx
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	89 10                	mov    %edx,(%eax)
 80e:	eb 26                	jmp    836 <malloc+0x96>
      else {
        p->s.size -= nunits;
 810:	8b 45 f4             	mov    -0xc(%ebp),%eax
 813:	8b 40 04             	mov    0x4(%eax),%eax
 816:	2b 45 ec             	sub    -0x14(%ebp),%eax
 819:	89 c2                	mov    %eax,%edx
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 821:	8b 45 f4             	mov    -0xc(%ebp),%eax
 824:	8b 40 04             	mov    0x4(%eax),%eax
 827:	c1 e0 03             	shl    $0x3,%eax
 82a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 82d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 830:	8b 55 ec             	mov    -0x14(%ebp),%edx
 833:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 836:	8b 45 f0             	mov    -0x10(%ebp),%eax
 839:	a3 44 0b 00 00       	mov    %eax,0xb44
      return (void*)(p + 1);
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	83 c0 08             	add    $0x8,%eax
 844:	eb 3b                	jmp    881 <malloc+0xe1>
    }
    if(p == freep)
 846:	a1 44 0b 00 00       	mov    0xb44,%eax
 84b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 84e:	75 1e                	jne    86e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 850:	83 ec 0c             	sub    $0xc,%esp
 853:	ff 75 ec             	push   -0x14(%ebp)
 856:	e8 e5 fe ff ff       	call   740 <morecore>
 85b:	83 c4 10             	add    $0x10,%esp
 85e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 861:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 865:	75 07                	jne    86e <malloc+0xce>
        return 0;
 867:	b8 00 00 00 00       	mov    $0x0,%eax
 86c:	eb 13                	jmp    881 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 871:	89 45 f0             	mov    %eax,-0x10(%ebp)
 874:	8b 45 f4             	mov    -0xc(%ebp),%eax
 877:	8b 00                	mov    (%eax),%eax
 879:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 87c:	e9 6d ff ff ff       	jmp    7ee <malloc+0x4e>
  }
}
 881:	c9                   	leave  
 882:	c3                   	ret    

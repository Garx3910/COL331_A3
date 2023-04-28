
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
  14:	83 3b 01             	cmpl   $0x1,(%ebx)
  17:	7f 17                	jg     30 <main+0x30>
    printf(2, "usage: kill pid...\n");
  19:	83 ec 08             	sub    $0x8,%esp
  1c:	68 f4 07 00 00       	push   $0x7f4
  21:	6a 02                	push   $0x2
  23:	e8 15 04 00 00       	call   43d <printf>
  28:	83 c4 10             	add    $0x10,%esp
    exit();
  2b:	e8 99 02 00 00       	call   2c9 <exit>
  }
  for(i=1; i<argc; i++)
  30:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  37:	eb 2d                	jmp    66 <main+0x66>
    kill(atoi(argv[i]));
  39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  43:	8b 43 04             	mov    0x4(%ebx),%eax
  46:	01 d0                	add    %edx,%eax
  48:	8b 00                	mov    (%eax),%eax
  4a:	83 ec 0c             	sub    $0xc,%esp
  4d:	50                   	push   %eax
  4e:	e8 e4 01 00 00       	call   237 <atoi>
  53:	83 c4 10             	add    $0x10,%esp
  56:	83 ec 0c             	sub    $0xc,%esp
  59:	50                   	push   %eax
  5a:	e8 9a 02 00 00       	call   2f9 <kill>
  5f:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
  62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  69:	3b 03                	cmp    (%ebx),%eax
  6b:	7c cc                	jl     39 <main+0x39>
  exit();
  6d:	e8 57 02 00 00       	call   2c9 <exit>

00000072 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  72:	55                   	push   %ebp
  73:	89 e5                	mov    %esp,%ebp
  75:	57                   	push   %edi
  76:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7a:	8b 55 10             	mov    0x10(%ebp),%edx
  7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  80:	89 cb                	mov    %ecx,%ebx
  82:	89 df                	mov    %ebx,%edi
  84:	89 d1                	mov    %edx,%ecx
  86:	fc                   	cld    
  87:	f3 aa                	rep stos %al,%es:(%edi)
  89:	89 ca                	mov    %ecx,%edx
  8b:	89 fb                	mov    %edi,%ebx
  8d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  90:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  93:	90                   	nop
  94:	5b                   	pop    %ebx
  95:	5f                   	pop    %edi
  96:	5d                   	pop    %ebp
  97:	c3                   	ret    

00000098 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  98:	55                   	push   %ebp
  99:	89 e5                	mov    %esp,%ebp
  9b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  9e:	8b 45 08             	mov    0x8(%ebp),%eax
  a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a4:	90                   	nop
  a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  a8:	8d 42 01             	lea    0x1(%edx),%eax
  ab:	89 45 0c             	mov    %eax,0xc(%ebp)
  ae:	8b 45 08             	mov    0x8(%ebp),%eax
  b1:	8d 48 01             	lea    0x1(%eax),%ecx
  b4:	89 4d 08             	mov    %ecx,0x8(%ebp)
  b7:	0f b6 12             	movzbl (%edx),%edx
  ba:	88 10                	mov    %dl,(%eax)
  bc:	0f b6 00             	movzbl (%eax),%eax
  bf:	84 c0                	test   %al,%al
  c1:	75 e2                	jne    a5 <strcpy+0xd>
    ;
  return os;
  c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c6:	c9                   	leave  
  c7:	c3                   	ret    

000000c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c8:	55                   	push   %ebp
  c9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cb:	eb 08                	jmp    d5 <strcmp+0xd>
    p++, q++;
  cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  d5:	8b 45 08             	mov    0x8(%ebp),%eax
  d8:	0f b6 00             	movzbl (%eax),%eax
  db:	84 c0                	test   %al,%al
  dd:	74 10                	je     ef <strcmp+0x27>
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	0f b6 10             	movzbl (%eax),%edx
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	0f b6 00             	movzbl (%eax),%eax
  eb:	38 c2                	cmp    %al,%dl
  ed:	74 de                	je     cd <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	0f b6 00             	movzbl (%eax),%eax
  f5:	0f b6 d0             	movzbl %al,%edx
  f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	0f b6 c8             	movzbl %al,%ecx
 101:	89 d0                	mov    %edx,%eax
 103:	29 c8                	sub    %ecx,%eax
}
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    

00000107 <strlen>:

uint
strlen(const char *s)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 114:	eb 04                	jmp    11a <strlen+0x13>
 116:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	01 d0                	add    %edx,%eax
 122:	0f b6 00             	movzbl (%eax),%eax
 125:	84 c0                	test   %al,%al
 127:	75 ed                	jne    116 <strlen+0xf>
    ;
  return n;
 129:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12c:	c9                   	leave  
 12d:	c3                   	ret    

0000012e <memset>:

void*
memset(void *dst, int c, uint n)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 131:	8b 45 10             	mov    0x10(%ebp),%eax
 134:	50                   	push   %eax
 135:	ff 75 0c             	push   0xc(%ebp)
 138:	ff 75 08             	push   0x8(%ebp)
 13b:	e8 32 ff ff ff       	call   72 <stosb>
 140:	83 c4 0c             	add    $0xc,%esp
  return dst;
 143:	8b 45 08             	mov    0x8(%ebp),%eax
}
 146:	c9                   	leave  
 147:	c3                   	ret    

00000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	55                   	push   %ebp
 149:	89 e5                	mov    %esp,%ebp
 14b:	83 ec 04             	sub    $0x4,%esp
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 154:	eb 14                	jmp    16a <strchr+0x22>
    if(*s == c)
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 15f:	75 05                	jne    166 <strchr+0x1e>
      return (char*)s;
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	eb 13                	jmp    179 <strchr+0x31>
  for(; *s; s++)
 166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	0f b6 00             	movzbl (%eax),%eax
 170:	84 c0                	test   %al,%al
 172:	75 e2                	jne    156 <strchr+0xe>
  return 0;
 174:	b8 00 00 00 00       	mov    $0x0,%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <gets>:

char*
gets(char *buf, int max)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 181:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 188:	eb 42                	jmp    1cc <gets+0x51>
    cc = read(0, &c, 1);
 18a:	83 ec 04             	sub    $0x4,%esp
 18d:	6a 01                	push   $0x1
 18f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 192:	50                   	push   %eax
 193:	6a 00                	push   $0x0
 195:	e8 47 01 00 00       	call   2e1 <read>
 19a:	83 c4 10             	add    $0x10,%esp
 19d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a4:	7e 33                	jle    1d9 <gets+0x5e>
      break;
    buf[i++] = c;
 1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a9:	8d 50 01             	lea    0x1(%eax),%edx
 1ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1af:	89 c2                	mov    %eax,%edx
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	01 c2                	add    %eax,%edx
 1b6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ba:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c0:	3c 0a                	cmp    $0xa,%al
 1c2:	74 16                	je     1da <gets+0x5f>
 1c4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c8:	3c 0d                	cmp    $0xd,%al
 1ca:	74 0e                	je     1da <gets+0x5f>
  for(i=0; i+1 < max; ){
 1cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cf:	83 c0 01             	add    $0x1,%eax
 1d2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1d5:	7f b3                	jg     18a <gets+0xf>
 1d7:	eb 01                	jmp    1da <gets+0x5f>
      break;
 1d9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1da:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1dd:	8b 45 08             	mov    0x8(%ebp),%eax
 1e0:	01 d0                	add    %edx,%eax
 1e2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e8:	c9                   	leave  
 1e9:	c3                   	ret    

000001ea <stat>:

int
stat(const char *n, struct stat *st)
{
 1ea:	55                   	push   %ebp
 1eb:	89 e5                	mov    %esp,%ebp
 1ed:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	83 ec 08             	sub    $0x8,%esp
 1f3:	6a 00                	push   $0x0
 1f5:	ff 75 08             	push   0x8(%ebp)
 1f8:	e8 0c 01 00 00       	call   309 <open>
 1fd:	83 c4 10             	add    $0x10,%esp
 200:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 203:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 207:	79 07                	jns    210 <stat+0x26>
    return -1;
 209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 20e:	eb 25                	jmp    235 <stat+0x4b>
  r = fstat(fd, st);
 210:	83 ec 08             	sub    $0x8,%esp
 213:	ff 75 0c             	push   0xc(%ebp)
 216:	ff 75 f4             	push   -0xc(%ebp)
 219:	e8 03 01 00 00       	call   321 <fstat>
 21e:	83 c4 10             	add    $0x10,%esp
 221:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 224:	83 ec 0c             	sub    $0xc,%esp
 227:	ff 75 f4             	push   -0xc(%ebp)
 22a:	e8 c2 00 00 00       	call   2f1 <close>
 22f:	83 c4 10             	add    $0x10,%esp
  return r;
 232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 244:	eb 25                	jmp    26b <atoi+0x34>
    n = n*10 + *s++ - '0';
 246:	8b 55 fc             	mov    -0x4(%ebp),%edx
 249:	89 d0                	mov    %edx,%eax
 24b:	c1 e0 02             	shl    $0x2,%eax
 24e:	01 d0                	add    %edx,%eax
 250:	01 c0                	add    %eax,%eax
 252:	89 c1                	mov    %eax,%ecx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	8d 50 01             	lea    0x1(%eax),%edx
 25a:	89 55 08             	mov    %edx,0x8(%ebp)
 25d:	0f b6 00             	movzbl (%eax),%eax
 260:	0f be c0             	movsbl %al,%eax
 263:	01 c8                	add    %ecx,%eax
 265:	83 e8 30             	sub    $0x30,%eax
 268:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	0f b6 00             	movzbl (%eax),%eax
 271:	3c 2f                	cmp    $0x2f,%al
 273:	7e 0a                	jle    27f <atoi+0x48>
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	0f b6 00             	movzbl (%eax),%eax
 27b:	3c 39                	cmp    $0x39,%al
 27d:	7e c7                	jle    246 <atoi+0xf>
  return n;
 27f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 282:	c9                   	leave  
 283:	c3                   	ret    

00000284 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 284:	55                   	push   %ebp
 285:	89 e5                	mov    %esp,%ebp
 287:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
 28d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 296:	eb 17                	jmp    2af <memmove+0x2b>
    *dst++ = *src++;
 298:	8b 55 f8             	mov    -0x8(%ebp),%edx
 29b:	8d 42 01             	lea    0x1(%edx),%eax
 29e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a4:	8d 48 01             	lea    0x1(%eax),%ecx
 2a7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2aa:	0f b6 12             	movzbl (%edx),%edx
 2ad:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2af:	8b 45 10             	mov    0x10(%ebp),%eax
 2b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b5:	89 55 10             	mov    %edx,0x10(%ebp)
 2b8:	85 c0                	test   %eax,%eax
 2ba:	7f dc                	jg     298 <memmove+0x14>
  return vdst;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c1:	b8 01 00 00 00       	mov    $0x1,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <exit>:
SYSCALL(exit)
 2c9:	b8 02 00 00 00       	mov    $0x2,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <wait>:
SYSCALL(wait)
 2d1:	b8 03 00 00 00       	mov    $0x3,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <pipe>:
SYSCALL(pipe)
 2d9:	b8 04 00 00 00       	mov    $0x4,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <read>:
SYSCALL(read)
 2e1:	b8 05 00 00 00       	mov    $0x5,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <write>:
SYSCALL(write)
 2e9:	b8 10 00 00 00       	mov    $0x10,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <close>:
SYSCALL(close)
 2f1:	b8 15 00 00 00       	mov    $0x15,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <kill>:
SYSCALL(kill)
 2f9:	b8 06 00 00 00       	mov    $0x6,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <exec>:
SYSCALL(exec)
 301:	b8 07 00 00 00       	mov    $0x7,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <open>:
SYSCALL(open)
 309:	b8 0f 00 00 00       	mov    $0xf,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <mknod>:
SYSCALL(mknod)
 311:	b8 11 00 00 00       	mov    $0x11,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <unlink>:
SYSCALL(unlink)
 319:	b8 12 00 00 00       	mov    $0x12,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <fstat>:
SYSCALL(fstat)
 321:	b8 08 00 00 00       	mov    $0x8,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <link>:
SYSCALL(link)
 329:	b8 13 00 00 00       	mov    $0x13,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <mkdir>:
SYSCALL(mkdir)
 331:	b8 14 00 00 00       	mov    $0x14,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <chdir>:
SYSCALL(chdir)
 339:	b8 09 00 00 00       	mov    $0x9,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <dup>:
SYSCALL(dup)
 341:	b8 0a 00 00 00       	mov    $0xa,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <getpid>:
SYSCALL(getpid)
 349:	b8 0b 00 00 00       	mov    $0xb,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <sbrk>:
SYSCALL(sbrk)
 351:	b8 0c 00 00 00       	mov    $0xc,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <sleep>:
SYSCALL(sleep)
 359:	b8 0d 00 00 00       	mov    $0xd,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <uptime>:
SYSCALL(uptime)
 361:	b8 0e 00 00 00       	mov    $0xe,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 369:	55                   	push   %ebp
 36a:	89 e5                	mov    %esp,%ebp
 36c:	83 ec 18             	sub    $0x18,%esp
 36f:	8b 45 0c             	mov    0xc(%ebp),%eax
 372:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 375:	83 ec 04             	sub    $0x4,%esp
 378:	6a 01                	push   $0x1
 37a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 37d:	50                   	push   %eax
 37e:	ff 75 08             	push   0x8(%ebp)
 381:	e8 63 ff ff ff       	call   2e9 <write>
 386:	83 c4 10             	add    $0x10,%esp
}
 389:	90                   	nop
 38a:	c9                   	leave  
 38b:	c3                   	ret    

0000038c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38c:	55                   	push   %ebp
 38d:	89 e5                	mov    %esp,%ebp
 38f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 399:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 39d:	74 17                	je     3b6 <printint+0x2a>
 39f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a3:	79 11                	jns    3b6 <printint+0x2a>
    neg = 1;
 3a5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 3af:	f7 d8                	neg    %eax
 3b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b4:	eb 06                	jmp    3bc <printint+0x30>
  } else {
    x = xx;
 3b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3c9:	ba 00 00 00 00       	mov    $0x0,%edx
 3ce:	f7 f1                	div    %ecx
 3d0:	89 d1                	mov    %edx,%ecx
 3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d5:	8d 50 01             	lea    0x1(%eax),%edx
 3d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3db:	0f b6 91 58 0a 00 00 	movzbl 0xa58(%ecx),%edx
 3e2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ec:	ba 00 00 00 00       	mov    $0x0,%edx
 3f1:	f7 f1                	div    %ecx
 3f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3fa:	75 c7                	jne    3c3 <printint+0x37>
  if(neg)
 3fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 400:	74 2d                	je     42f <printint+0xa3>
    buf[i++] = '-';
 402:	8b 45 f4             	mov    -0xc(%ebp),%eax
 405:	8d 50 01             	lea    0x1(%eax),%edx
 408:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 410:	eb 1d                	jmp    42f <printint+0xa3>
    putc(fd, buf[i]);
 412:	8d 55 dc             	lea    -0x24(%ebp),%edx
 415:	8b 45 f4             	mov    -0xc(%ebp),%eax
 418:	01 d0                	add    %edx,%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	0f be c0             	movsbl %al,%eax
 420:	83 ec 08             	sub    $0x8,%esp
 423:	50                   	push   %eax
 424:	ff 75 08             	push   0x8(%ebp)
 427:	e8 3d ff ff ff       	call   369 <putc>
 42c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 42f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 433:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 437:	79 d9                	jns    412 <printint+0x86>
}
 439:	90                   	nop
 43a:	90                   	nop
 43b:	c9                   	leave  
 43c:	c3                   	ret    

0000043d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 43d:	55                   	push   %ebp
 43e:	89 e5                	mov    %esp,%ebp
 440:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 443:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 44a:	8d 45 0c             	lea    0xc(%ebp),%eax
 44d:	83 c0 04             	add    $0x4,%eax
 450:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 453:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 45a:	e9 59 01 00 00       	jmp    5b8 <printf+0x17b>
    c = fmt[i] & 0xff;
 45f:	8b 55 0c             	mov    0xc(%ebp),%edx
 462:	8b 45 f0             	mov    -0x10(%ebp),%eax
 465:	01 d0                	add    %edx,%eax
 467:	0f b6 00             	movzbl (%eax),%eax
 46a:	0f be c0             	movsbl %al,%eax
 46d:	25 ff 00 00 00       	and    $0xff,%eax
 472:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 475:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 479:	75 2c                	jne    4a7 <printf+0x6a>
      if(c == '%'){
 47b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 47f:	75 0c                	jne    48d <printf+0x50>
        state = '%';
 481:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 488:	e9 27 01 00 00       	jmp    5b4 <printf+0x177>
      } else {
        putc(fd, c);
 48d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 490:	0f be c0             	movsbl %al,%eax
 493:	83 ec 08             	sub    $0x8,%esp
 496:	50                   	push   %eax
 497:	ff 75 08             	push   0x8(%ebp)
 49a:	e8 ca fe ff ff       	call   369 <putc>
 49f:	83 c4 10             	add    $0x10,%esp
 4a2:	e9 0d 01 00 00       	jmp    5b4 <printf+0x177>
      }
    } else if(state == '%'){
 4a7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ab:	0f 85 03 01 00 00    	jne    5b4 <printf+0x177>
      if(c == 'd'){
 4b1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b5:	75 1e                	jne    4d5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ba:	8b 00                	mov    (%eax),%eax
 4bc:	6a 01                	push   $0x1
 4be:	6a 0a                	push   $0xa
 4c0:	50                   	push   %eax
 4c1:	ff 75 08             	push   0x8(%ebp)
 4c4:	e8 c3 fe ff ff       	call   38c <printint>
 4c9:	83 c4 10             	add    $0x10,%esp
        ap++;
 4cc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d0:	e9 d8 00 00 00       	jmp    5ad <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4d5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4d9:	74 06                	je     4e1 <printf+0xa4>
 4db:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4df:	75 1e                	jne    4ff <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e4:	8b 00                	mov    (%eax),%eax
 4e6:	6a 00                	push   $0x0
 4e8:	6a 10                	push   $0x10
 4ea:	50                   	push   %eax
 4eb:	ff 75 08             	push   0x8(%ebp)
 4ee:	e8 99 fe ff ff       	call   38c <printint>
 4f3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fa:	e9 ae 00 00 00       	jmp    5ad <printf+0x170>
      } else if(c == 's'){
 4ff:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 503:	75 43                	jne    548 <printf+0x10b>
        s = (char*)*ap;
 505:	8b 45 e8             	mov    -0x18(%ebp),%eax
 508:	8b 00                	mov    (%eax),%eax
 50a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 50d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 511:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 515:	75 25                	jne    53c <printf+0xff>
          s = "(null)";
 517:	c7 45 f4 08 08 00 00 	movl   $0x808,-0xc(%ebp)
        while(*s != 0){
 51e:	eb 1c                	jmp    53c <printf+0xff>
          putc(fd, *s);
 520:	8b 45 f4             	mov    -0xc(%ebp),%eax
 523:	0f b6 00             	movzbl (%eax),%eax
 526:	0f be c0             	movsbl %al,%eax
 529:	83 ec 08             	sub    $0x8,%esp
 52c:	50                   	push   %eax
 52d:	ff 75 08             	push   0x8(%ebp)
 530:	e8 34 fe ff ff       	call   369 <putc>
 535:	83 c4 10             	add    $0x10,%esp
          s++;
 538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 53c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53f:	0f b6 00             	movzbl (%eax),%eax
 542:	84 c0                	test   %al,%al
 544:	75 da                	jne    520 <printf+0xe3>
 546:	eb 65                	jmp    5ad <printf+0x170>
        }
      } else if(c == 'c'){
 548:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 54c:	75 1d                	jne    56b <printf+0x12e>
        putc(fd, *ap);
 54e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 551:	8b 00                	mov    (%eax),%eax
 553:	0f be c0             	movsbl %al,%eax
 556:	83 ec 08             	sub    $0x8,%esp
 559:	50                   	push   %eax
 55a:	ff 75 08             	push   0x8(%ebp)
 55d:	e8 07 fe ff ff       	call   369 <putc>
 562:	83 c4 10             	add    $0x10,%esp
        ap++;
 565:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 569:	eb 42                	jmp    5ad <printf+0x170>
      } else if(c == '%'){
 56b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56f:	75 17                	jne    588 <printf+0x14b>
        putc(fd, c);
 571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 574:	0f be c0             	movsbl %al,%eax
 577:	83 ec 08             	sub    $0x8,%esp
 57a:	50                   	push   %eax
 57b:	ff 75 08             	push   0x8(%ebp)
 57e:	e8 e6 fd ff ff       	call   369 <putc>
 583:	83 c4 10             	add    $0x10,%esp
 586:	eb 25                	jmp    5ad <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 588:	83 ec 08             	sub    $0x8,%esp
 58b:	6a 25                	push   $0x25
 58d:	ff 75 08             	push   0x8(%ebp)
 590:	e8 d4 fd ff ff       	call   369 <putc>
 595:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59b:	0f be c0             	movsbl %al,%eax
 59e:	83 ec 08             	sub    $0x8,%esp
 5a1:	50                   	push   %eax
 5a2:	ff 75 08             	push   0x8(%ebp)
 5a5:	e8 bf fd ff ff       	call   369 <putc>
 5aa:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5b8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5be:	01 d0                	add    %edx,%eax
 5c0:	0f b6 00             	movzbl (%eax),%eax
 5c3:	84 c0                	test   %al,%al
 5c5:	0f 85 94 fe ff ff    	jne    45f <printf+0x22>
    }
  }
}
 5cb:	90                   	nop
 5cc:	90                   	nop
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    

000005cf <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5cf:	55                   	push   %ebp
 5d0:	89 e5                	mov    %esp,%ebp
 5d2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	83 e8 08             	sub    $0x8,%eax
 5db:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5de:	a1 74 0a 00 00       	mov    0xa74,%eax
 5e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e6:	eb 24                	jmp    60c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5eb:	8b 00                	mov    (%eax),%eax
 5ed:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5f0:	72 12                	jb     604 <free+0x35>
 5f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f8:	77 24                	ja     61e <free+0x4f>
 5fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fd:	8b 00                	mov    (%eax),%eax
 5ff:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 602:	72 1a                	jb     61e <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 604:	8b 45 fc             	mov    -0x4(%ebp),%eax
 607:	8b 00                	mov    (%eax),%eax
 609:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 612:	76 d4                	jbe    5e8 <free+0x19>
 614:	8b 45 fc             	mov    -0x4(%ebp),%eax
 617:	8b 00                	mov    (%eax),%eax
 619:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 61c:	73 ca                	jae    5e8 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 61e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 621:	8b 40 04             	mov    0x4(%eax),%eax
 624:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 62b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62e:	01 c2                	add    %eax,%edx
 630:	8b 45 fc             	mov    -0x4(%ebp),%eax
 633:	8b 00                	mov    (%eax),%eax
 635:	39 c2                	cmp    %eax,%edx
 637:	75 24                	jne    65d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 639:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63c:	8b 50 04             	mov    0x4(%eax),%edx
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	8b 40 04             	mov    0x4(%eax),%eax
 647:	01 c2                	add    %eax,%edx
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	8b 10                	mov    (%eax),%edx
 656:	8b 45 f8             	mov    -0x8(%ebp),%eax
 659:	89 10                	mov    %edx,(%eax)
 65b:	eb 0a                	jmp    667 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	8b 10                	mov    (%eax),%edx
 662:	8b 45 f8             	mov    -0x8(%ebp),%eax
 665:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 40 04             	mov    0x4(%eax),%eax
 66d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	01 d0                	add    %edx,%eax
 679:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 67c:	75 20                	jne    69e <free+0xcf>
    p->s.size += bp->s.size;
 67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 681:	8b 50 04             	mov    0x4(%eax),%edx
 684:	8b 45 f8             	mov    -0x8(%ebp),%eax
 687:	8b 40 04             	mov    0x4(%eax),%eax
 68a:	01 c2                	add    %eax,%edx
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 692:	8b 45 f8             	mov    -0x8(%ebp),%eax
 695:	8b 10                	mov    (%eax),%edx
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	89 10                	mov    %edx,(%eax)
 69c:	eb 08                	jmp    6a6 <free+0xd7>
  } else
    p->s.ptr = bp;
 69e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6a4:	89 10                	mov    %edx,(%eax)
  freep = p;
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	a3 74 0a 00 00       	mov    %eax,0xa74
}
 6ae:	90                   	nop
 6af:	c9                   	leave  
 6b0:	c3                   	ret    

000006b1 <morecore>:

static Header*
morecore(uint nu)
{
 6b1:	55                   	push   %ebp
 6b2:	89 e5                	mov    %esp,%ebp
 6b4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6b7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6be:	77 07                	ja     6c7 <morecore+0x16>
    nu = 4096;
 6c0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	c1 e0 03             	shl    $0x3,%eax
 6cd:	83 ec 0c             	sub    $0xc,%esp
 6d0:	50                   	push   %eax
 6d1:	e8 7b fc ff ff       	call   351 <sbrk>
 6d6:	83 c4 10             	add    $0x10,%esp
 6d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6dc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6e0:	75 07                	jne    6e9 <morecore+0x38>
    return 0;
 6e2:	b8 00 00 00 00       	mov    $0x0,%eax
 6e7:	eb 26                	jmp    70f <morecore+0x5e>
  hp = (Header*)p;
 6e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f2:	8b 55 08             	mov    0x8(%ebp),%edx
 6f5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fb:	83 c0 08             	add    $0x8,%eax
 6fe:	83 ec 0c             	sub    $0xc,%esp
 701:	50                   	push   %eax
 702:	e8 c8 fe ff ff       	call   5cf <free>
 707:	83 c4 10             	add    $0x10,%esp
  return freep;
 70a:	a1 74 0a 00 00       	mov    0xa74,%eax
}
 70f:	c9                   	leave  
 710:	c3                   	ret    

00000711 <malloc>:

void*
malloc(uint nbytes)
{
 711:	55                   	push   %ebp
 712:	89 e5                	mov    %esp,%ebp
 714:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 717:	8b 45 08             	mov    0x8(%ebp),%eax
 71a:	83 c0 07             	add    $0x7,%eax
 71d:	c1 e8 03             	shr    $0x3,%eax
 720:	83 c0 01             	add    $0x1,%eax
 723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 726:	a1 74 0a 00 00       	mov    0xa74,%eax
 72b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 72e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 732:	75 23                	jne    757 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 734:	c7 45 f0 6c 0a 00 00 	movl   $0xa6c,-0x10(%ebp)
 73b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73e:	a3 74 0a 00 00       	mov    %eax,0xa74
 743:	a1 74 0a 00 00       	mov    0xa74,%eax
 748:	a3 6c 0a 00 00       	mov    %eax,0xa6c
    base.s.size = 0;
 74d:	c7 05 70 0a 00 00 00 	movl   $0x0,0xa70
 754:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 757:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75a:	8b 00                	mov    (%eax),%eax
 75c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	8b 40 04             	mov    0x4(%eax),%eax
 765:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 768:	77 4d                	ja     7b7 <malloc+0xa6>
      if(p->s.size == nunits)
 76a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76d:	8b 40 04             	mov    0x4(%eax),%eax
 770:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 773:	75 0c                	jne    781 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 775:	8b 45 f4             	mov    -0xc(%ebp),%eax
 778:	8b 10                	mov    (%eax),%edx
 77a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77d:	89 10                	mov    %edx,(%eax)
 77f:	eb 26                	jmp    7a7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	8b 40 04             	mov    0x4(%eax),%eax
 787:	2b 45 ec             	sub    -0x14(%ebp),%eax
 78a:	89 c2                	mov    %eax,%edx
 78c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	8b 40 04             	mov    0x4(%eax),%eax
 798:	c1 e0 03             	shl    $0x3,%eax
 79b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 79e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7a4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	a3 74 0a 00 00       	mov    %eax,0xa74
      return (void*)(p + 1);
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	83 c0 08             	add    $0x8,%eax
 7b5:	eb 3b                	jmp    7f2 <malloc+0xe1>
    }
    if(p == freep)
 7b7:	a1 74 0a 00 00       	mov    0xa74,%eax
 7bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7bf:	75 1e                	jne    7df <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7c1:	83 ec 0c             	sub    $0xc,%esp
 7c4:	ff 75 ec             	push   -0x14(%ebp)
 7c7:	e8 e5 fe ff ff       	call   6b1 <morecore>
 7cc:	83 c4 10             	add    $0x10,%esp
 7cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7d6:	75 07                	jne    7df <malloc+0xce>
        return 0;
 7d8:	b8 00 00 00 00       	mov    $0x0,%eax
 7dd:	eb 13                	jmp    7f2 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ed:	e9 6d ff ff ff       	jmp    75f <malloc+0x4e>
  }
}
 7f2:	c9                   	leave  
 7f3:	c3                   	ret    

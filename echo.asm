
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
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

  for(i = 1; i < argc; i++)
  14:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  1b:	eb 3c                	jmp    59 <main+0x59>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  20:	83 c0 01             	add    $0x1,%eax
  23:	39 03                	cmp    %eax,(%ebx)
  25:	7e 07                	jle    2e <main+0x2e>
  27:	ba e7 07 00 00       	mov    $0x7e7,%edx
  2c:	eb 05                	jmp    33 <main+0x33>
  2e:	ba e9 07 00 00       	mov    $0x7e9,%edx
  33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  36:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  3d:	8b 43 04             	mov    0x4(%ebx),%eax
  40:	01 c8                	add    %ecx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	52                   	push   %edx
  45:	50                   	push   %eax
  46:	68 eb 07 00 00       	push   $0x7eb
  4b:	6a 01                	push   $0x1
  4d:	e8 de 03 00 00       	call   430 <printf>
  52:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5c:	3b 03                	cmp    (%ebx),%eax
  5e:	7c bd                	jl     1d <main+0x1d>
  exit();
  60:	e8 57 02 00 00       	call   2bc <exit>

00000065 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  65:	55                   	push   %ebp
  66:	89 e5                	mov    %esp,%ebp
  68:	57                   	push   %edi
  69:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6d:	8b 55 10             	mov    0x10(%ebp),%edx
  70:	8b 45 0c             	mov    0xc(%ebp),%eax
  73:	89 cb                	mov    %ecx,%ebx
  75:	89 df                	mov    %ebx,%edi
  77:	89 d1                	mov    %edx,%ecx
  79:	fc                   	cld    
  7a:	f3 aa                	rep stos %al,%es:(%edi)
  7c:	89 ca                	mov    %ecx,%edx
  7e:	89 fb                	mov    %edi,%ebx
  80:	89 5d 08             	mov    %ebx,0x8(%ebp)
  83:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  86:	90                   	nop
  87:	5b                   	pop    %ebx
  88:	5f                   	pop    %edi
  89:	5d                   	pop    %ebp
  8a:	c3                   	ret    

0000008b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  8b:	55                   	push   %ebp
  8c:	89 e5                	mov    %esp,%ebp
  8e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  91:	8b 45 08             	mov    0x8(%ebp),%eax
  94:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  97:	90                   	nop
  98:	8b 55 0c             	mov    0xc(%ebp),%edx
  9b:	8d 42 01             	lea    0x1(%edx),%eax
  9e:	89 45 0c             	mov    %eax,0xc(%ebp)
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	8d 48 01             	lea    0x1(%eax),%ecx
  a7:	89 4d 08             	mov    %ecx,0x8(%ebp)
  aa:	0f b6 12             	movzbl (%edx),%edx
  ad:	88 10                	mov    %dl,(%eax)
  af:	0f b6 00             	movzbl (%eax),%eax
  b2:	84 c0                	test   %al,%al
  b4:	75 e2                	jne    98 <strcpy+0xd>
    ;
  return os;
  b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b9:	c9                   	leave  
  ba:	c3                   	ret    

000000bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  be:	eb 08                	jmp    c8 <strcmp+0xd>
    p++, q++;
  c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	0f b6 00             	movzbl (%eax),%eax
  ce:	84 c0                	test   %al,%al
  d0:	74 10                	je     e2 <strcmp+0x27>
  d2:	8b 45 08             	mov    0x8(%ebp),%eax
  d5:	0f b6 10             	movzbl (%eax),%edx
  d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  db:	0f b6 00             	movzbl (%eax),%eax
  de:	38 c2                	cmp    %al,%dl
  e0:	74 de                	je     c0 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  e2:	8b 45 08             	mov    0x8(%ebp),%eax
  e5:	0f b6 00             	movzbl (%eax),%eax
  e8:	0f b6 d0             	movzbl %al,%edx
  eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ee:	0f b6 00             	movzbl (%eax),%eax
  f1:	0f b6 c8             	movzbl %al,%ecx
  f4:	89 d0                	mov    %edx,%eax
  f6:	29 c8                	sub    %ecx,%eax
}
  f8:	5d                   	pop    %ebp
  f9:	c3                   	ret    

000000fa <strlen>:

uint
strlen(const char *s)
{
  fa:	55                   	push   %ebp
  fb:	89 e5                	mov    %esp,%ebp
  fd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 100:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 107:	eb 04                	jmp    10d <strlen+0x13>
 109:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 10d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 110:	8b 45 08             	mov    0x8(%ebp),%eax
 113:	01 d0                	add    %edx,%eax
 115:	0f b6 00             	movzbl (%eax),%eax
 118:	84 c0                	test   %al,%al
 11a:	75 ed                	jne    109 <strlen+0xf>
    ;
  return n;
 11c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 11f:	c9                   	leave  
 120:	c3                   	ret    

00000121 <memset>:

void*
memset(void *dst, int c, uint n)
{
 121:	55                   	push   %ebp
 122:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 124:	8b 45 10             	mov    0x10(%ebp),%eax
 127:	50                   	push   %eax
 128:	ff 75 0c             	push   0xc(%ebp)
 12b:	ff 75 08             	push   0x8(%ebp)
 12e:	e8 32 ff ff ff       	call   65 <stosb>
 133:	83 c4 0c             	add    $0xc,%esp
  return dst;
 136:	8b 45 08             	mov    0x8(%ebp),%eax
}
 139:	c9                   	leave  
 13a:	c3                   	ret    

0000013b <strchr>:

char*
strchr(const char *s, char c)
{
 13b:	55                   	push   %ebp
 13c:	89 e5                	mov    %esp,%ebp
 13e:	83 ec 04             	sub    $0x4,%esp
 141:	8b 45 0c             	mov    0xc(%ebp),%eax
 144:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 147:	eb 14                	jmp    15d <strchr+0x22>
    if(*s == c)
 149:	8b 45 08             	mov    0x8(%ebp),%eax
 14c:	0f b6 00             	movzbl (%eax),%eax
 14f:	38 45 fc             	cmp    %al,-0x4(%ebp)
 152:	75 05                	jne    159 <strchr+0x1e>
      return (char*)s;
 154:	8b 45 08             	mov    0x8(%ebp),%eax
 157:	eb 13                	jmp    16c <strchr+0x31>
  for(; *s; s++)
 159:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	0f b6 00             	movzbl (%eax),%eax
 163:	84 c0                	test   %al,%al
 165:	75 e2                	jne    149 <strchr+0xe>
  return 0;
 167:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16c:	c9                   	leave  
 16d:	c3                   	ret    

0000016e <gets>:

char*
gets(char *buf, int max)
{
 16e:	55                   	push   %ebp
 16f:	89 e5                	mov    %esp,%ebp
 171:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 174:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 17b:	eb 42                	jmp    1bf <gets+0x51>
    cc = read(0, &c, 1);
 17d:	83 ec 04             	sub    $0x4,%esp
 180:	6a 01                	push   $0x1
 182:	8d 45 ef             	lea    -0x11(%ebp),%eax
 185:	50                   	push   %eax
 186:	6a 00                	push   $0x0
 188:	e8 47 01 00 00       	call   2d4 <read>
 18d:	83 c4 10             	add    $0x10,%esp
 190:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 193:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 197:	7e 33                	jle    1cc <gets+0x5e>
      break;
    buf[i++] = c;
 199:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19c:	8d 50 01             	lea    0x1(%eax),%edx
 19f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1a2:	89 c2                	mov    %eax,%edx
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	01 c2                	add    %eax,%edx
 1a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ad:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1b3:	3c 0a                	cmp    $0xa,%al
 1b5:	74 16                	je     1cd <gets+0x5f>
 1b7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1bb:	3c 0d                	cmp    $0xd,%al
 1bd:	74 0e                	je     1cd <gets+0x5f>
  for(i=0; i+1 < max; ){
 1bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c2:	83 c0 01             	add    $0x1,%eax
 1c5:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1c8:	7f b3                	jg     17d <gets+0xf>
 1ca:	eb 01                	jmp    1cd <gets+0x5f>
      break;
 1cc:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1d0:	8b 45 08             	mov    0x8(%ebp),%eax
 1d3:	01 d0                	add    %edx,%eax
 1d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1db:	c9                   	leave  
 1dc:	c3                   	ret    

000001dd <stat>:

int
stat(const char *n, struct stat *st)
{
 1dd:	55                   	push   %ebp
 1de:	89 e5                	mov    %esp,%ebp
 1e0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e3:	83 ec 08             	sub    $0x8,%esp
 1e6:	6a 00                	push   $0x0
 1e8:	ff 75 08             	push   0x8(%ebp)
 1eb:	e8 0c 01 00 00       	call   2fc <open>
 1f0:	83 c4 10             	add    $0x10,%esp
 1f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1fa:	79 07                	jns    203 <stat+0x26>
    return -1;
 1fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 201:	eb 25                	jmp    228 <stat+0x4b>
  r = fstat(fd, st);
 203:	83 ec 08             	sub    $0x8,%esp
 206:	ff 75 0c             	push   0xc(%ebp)
 209:	ff 75 f4             	push   -0xc(%ebp)
 20c:	e8 03 01 00 00       	call   314 <fstat>
 211:	83 c4 10             	add    $0x10,%esp
 214:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 217:	83 ec 0c             	sub    $0xc,%esp
 21a:	ff 75 f4             	push   -0xc(%ebp)
 21d:	e8 c2 00 00 00       	call   2e4 <close>
 222:	83 c4 10             	add    $0x10,%esp
  return r;
 225:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 228:	c9                   	leave  
 229:	c3                   	ret    

0000022a <atoi>:

int
atoi(const char *s)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 230:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 237:	eb 25                	jmp    25e <atoi+0x34>
    n = n*10 + *s++ - '0';
 239:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23c:	89 d0                	mov    %edx,%eax
 23e:	c1 e0 02             	shl    $0x2,%eax
 241:	01 d0                	add    %edx,%eax
 243:	01 c0                	add    %eax,%eax
 245:	89 c1                	mov    %eax,%ecx
 247:	8b 45 08             	mov    0x8(%ebp),%eax
 24a:	8d 50 01             	lea    0x1(%eax),%edx
 24d:	89 55 08             	mov    %edx,0x8(%ebp)
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	0f be c0             	movsbl %al,%eax
 256:	01 c8                	add    %ecx,%eax
 258:	83 e8 30             	sub    $0x30,%eax
 25b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	0f b6 00             	movzbl (%eax),%eax
 264:	3c 2f                	cmp    $0x2f,%al
 266:	7e 0a                	jle    272 <atoi+0x48>
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	0f b6 00             	movzbl (%eax),%eax
 26e:	3c 39                	cmp    $0x39,%al
 270:	7e c7                	jle    239 <atoi+0xf>
  return n;
 272:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 275:	c9                   	leave  
 276:	c3                   	ret    

00000277 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 283:	8b 45 0c             	mov    0xc(%ebp),%eax
 286:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 289:	eb 17                	jmp    2a2 <memmove+0x2b>
    *dst++ = *src++;
 28b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 28e:	8d 42 01             	lea    0x1(%edx),%eax
 291:	89 45 f8             	mov    %eax,-0x8(%ebp)
 294:	8b 45 fc             	mov    -0x4(%ebp),%eax
 297:	8d 48 01             	lea    0x1(%eax),%ecx
 29a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 29d:	0f b6 12             	movzbl (%edx),%edx
 2a0:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2a2:	8b 45 10             	mov    0x10(%ebp),%eax
 2a5:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a8:	89 55 10             	mov    %edx,0x10(%ebp)
 2ab:	85 c0                	test   %eax,%eax
 2ad:	7f dc                	jg     28b <memmove+0x14>
  return vdst;
 2af:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b2:	c9                   	leave  
 2b3:	c3                   	ret    

000002b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b4:	b8 01 00 00 00       	mov    $0x1,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <exit>:
SYSCALL(exit)
 2bc:	b8 02 00 00 00       	mov    $0x2,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <wait>:
SYSCALL(wait)
 2c4:	b8 03 00 00 00       	mov    $0x3,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <pipe>:
SYSCALL(pipe)
 2cc:	b8 04 00 00 00       	mov    $0x4,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <read>:
SYSCALL(read)
 2d4:	b8 05 00 00 00       	mov    $0x5,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <write>:
SYSCALL(write)
 2dc:	b8 10 00 00 00       	mov    $0x10,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <close>:
SYSCALL(close)
 2e4:	b8 15 00 00 00       	mov    $0x15,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <kill>:
SYSCALL(kill)
 2ec:	b8 06 00 00 00       	mov    $0x6,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <exec>:
SYSCALL(exec)
 2f4:	b8 07 00 00 00       	mov    $0x7,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <open>:
SYSCALL(open)
 2fc:	b8 0f 00 00 00       	mov    $0xf,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <mknod>:
SYSCALL(mknod)
 304:	b8 11 00 00 00       	mov    $0x11,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <unlink>:
SYSCALL(unlink)
 30c:	b8 12 00 00 00       	mov    $0x12,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <fstat>:
SYSCALL(fstat)
 314:	b8 08 00 00 00       	mov    $0x8,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <link>:
SYSCALL(link)
 31c:	b8 13 00 00 00       	mov    $0x13,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <mkdir>:
SYSCALL(mkdir)
 324:	b8 14 00 00 00       	mov    $0x14,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <chdir>:
SYSCALL(chdir)
 32c:	b8 09 00 00 00       	mov    $0x9,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <dup>:
SYSCALL(dup)
 334:	b8 0a 00 00 00       	mov    $0xa,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <getpid>:
SYSCALL(getpid)
 33c:	b8 0b 00 00 00       	mov    $0xb,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <sbrk>:
SYSCALL(sbrk)
 344:	b8 0c 00 00 00       	mov    $0xc,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <sleep>:
SYSCALL(sleep)
 34c:	b8 0d 00 00 00       	mov    $0xd,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <uptime>:
SYSCALL(uptime)
 354:	b8 0e 00 00 00       	mov    $0xe,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	83 ec 18             	sub    $0x18,%esp
 362:	8b 45 0c             	mov    0xc(%ebp),%eax
 365:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 368:	83 ec 04             	sub    $0x4,%esp
 36b:	6a 01                	push   $0x1
 36d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 370:	50                   	push   %eax
 371:	ff 75 08             	push   0x8(%ebp)
 374:	e8 63 ff ff ff       	call   2dc <write>
 379:	83 c4 10             	add    $0x10,%esp
}
 37c:	90                   	nop
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 385:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 38c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 390:	74 17                	je     3a9 <printint+0x2a>
 392:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 396:	79 11                	jns    3a9 <printint+0x2a>
    neg = 1;
 398:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 39f:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a2:	f7 d8                	neg    %eax
 3a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a7:	eb 06                	jmp    3af <printint+0x30>
  } else {
    x = xx;
 3a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3bc:	ba 00 00 00 00       	mov    $0x0,%edx
 3c1:	f7 f1                	div    %ecx
 3c3:	89 d1                	mov    %edx,%ecx
 3c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c8:	8d 50 01             	lea    0x1(%eax),%edx
 3cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ce:	0f b6 91 40 0a 00 00 	movzbl 0xa40(%ecx),%edx
 3d5:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3df:	ba 00 00 00 00       	mov    $0x0,%edx
 3e4:	f7 f1                	div    %ecx
 3e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3ed:	75 c7                	jne    3b6 <printint+0x37>
  if(neg)
 3ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f3:	74 2d                	je     422 <printint+0xa3>
    buf[i++] = '-';
 3f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f8:	8d 50 01             	lea    0x1(%eax),%edx
 3fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3fe:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 403:	eb 1d                	jmp    422 <printint+0xa3>
    putc(fd, buf[i]);
 405:	8d 55 dc             	lea    -0x24(%ebp),%edx
 408:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40b:	01 d0                	add    %edx,%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	0f be c0             	movsbl %al,%eax
 413:	83 ec 08             	sub    $0x8,%esp
 416:	50                   	push   %eax
 417:	ff 75 08             	push   0x8(%ebp)
 41a:	e8 3d ff ff ff       	call   35c <putc>
 41f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 422:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 426:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 42a:	79 d9                	jns    405 <printint+0x86>
}
 42c:	90                   	nop
 42d:	90                   	nop
 42e:	c9                   	leave  
 42f:	c3                   	ret    

00000430 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 436:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 43d:	8d 45 0c             	lea    0xc(%ebp),%eax
 440:	83 c0 04             	add    $0x4,%eax
 443:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 446:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 44d:	e9 59 01 00 00       	jmp    5ab <printf+0x17b>
    c = fmt[i] & 0xff;
 452:	8b 55 0c             	mov    0xc(%ebp),%edx
 455:	8b 45 f0             	mov    -0x10(%ebp),%eax
 458:	01 d0                	add    %edx,%eax
 45a:	0f b6 00             	movzbl (%eax),%eax
 45d:	0f be c0             	movsbl %al,%eax
 460:	25 ff 00 00 00       	and    $0xff,%eax
 465:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 468:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46c:	75 2c                	jne    49a <printf+0x6a>
      if(c == '%'){
 46e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 472:	75 0c                	jne    480 <printf+0x50>
        state = '%';
 474:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 47b:	e9 27 01 00 00       	jmp    5a7 <printf+0x177>
      } else {
        putc(fd, c);
 480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 483:	0f be c0             	movsbl %al,%eax
 486:	83 ec 08             	sub    $0x8,%esp
 489:	50                   	push   %eax
 48a:	ff 75 08             	push   0x8(%ebp)
 48d:	e8 ca fe ff ff       	call   35c <putc>
 492:	83 c4 10             	add    $0x10,%esp
 495:	e9 0d 01 00 00       	jmp    5a7 <printf+0x177>
      }
    } else if(state == '%'){
 49a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 49e:	0f 85 03 01 00 00    	jne    5a7 <printf+0x177>
      if(c == 'd'){
 4a4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4a8:	75 1e                	jne    4c8 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ad:	8b 00                	mov    (%eax),%eax
 4af:	6a 01                	push   $0x1
 4b1:	6a 0a                	push   $0xa
 4b3:	50                   	push   %eax
 4b4:	ff 75 08             	push   0x8(%ebp)
 4b7:	e8 c3 fe ff ff       	call   37f <printint>
 4bc:	83 c4 10             	add    $0x10,%esp
        ap++;
 4bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c3:	e9 d8 00 00 00       	jmp    5a0 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4c8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4cc:	74 06                	je     4d4 <printf+0xa4>
 4ce:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4d2:	75 1e                	jne    4f2 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d7:	8b 00                	mov    (%eax),%eax
 4d9:	6a 00                	push   $0x0
 4db:	6a 10                	push   $0x10
 4dd:	50                   	push   %eax
 4de:	ff 75 08             	push   0x8(%ebp)
 4e1:	e8 99 fe ff ff       	call   37f <printint>
 4e6:	83 c4 10             	add    $0x10,%esp
        ap++;
 4e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ed:	e9 ae 00 00 00       	jmp    5a0 <printf+0x170>
      } else if(c == 's'){
 4f2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4f6:	75 43                	jne    53b <printf+0x10b>
        s = (char*)*ap;
 4f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4fb:	8b 00                	mov    (%eax),%eax
 4fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 500:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 504:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 508:	75 25                	jne    52f <printf+0xff>
          s = "(null)";
 50a:	c7 45 f4 f0 07 00 00 	movl   $0x7f0,-0xc(%ebp)
        while(*s != 0){
 511:	eb 1c                	jmp    52f <printf+0xff>
          putc(fd, *s);
 513:	8b 45 f4             	mov    -0xc(%ebp),%eax
 516:	0f b6 00             	movzbl (%eax),%eax
 519:	0f be c0             	movsbl %al,%eax
 51c:	83 ec 08             	sub    $0x8,%esp
 51f:	50                   	push   %eax
 520:	ff 75 08             	push   0x8(%ebp)
 523:	e8 34 fe ff ff       	call   35c <putc>
 528:	83 c4 10             	add    $0x10,%esp
          s++;
 52b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 52f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 532:	0f b6 00             	movzbl (%eax),%eax
 535:	84 c0                	test   %al,%al
 537:	75 da                	jne    513 <printf+0xe3>
 539:	eb 65                	jmp    5a0 <printf+0x170>
        }
      } else if(c == 'c'){
 53b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 53f:	75 1d                	jne    55e <printf+0x12e>
        putc(fd, *ap);
 541:	8b 45 e8             	mov    -0x18(%ebp),%eax
 544:	8b 00                	mov    (%eax),%eax
 546:	0f be c0             	movsbl %al,%eax
 549:	83 ec 08             	sub    $0x8,%esp
 54c:	50                   	push   %eax
 54d:	ff 75 08             	push   0x8(%ebp)
 550:	e8 07 fe ff ff       	call   35c <putc>
 555:	83 c4 10             	add    $0x10,%esp
        ap++;
 558:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55c:	eb 42                	jmp    5a0 <printf+0x170>
      } else if(c == '%'){
 55e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 562:	75 17                	jne    57b <printf+0x14b>
        putc(fd, c);
 564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 567:	0f be c0             	movsbl %al,%eax
 56a:	83 ec 08             	sub    $0x8,%esp
 56d:	50                   	push   %eax
 56e:	ff 75 08             	push   0x8(%ebp)
 571:	e8 e6 fd ff ff       	call   35c <putc>
 576:	83 c4 10             	add    $0x10,%esp
 579:	eb 25                	jmp    5a0 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 57b:	83 ec 08             	sub    $0x8,%esp
 57e:	6a 25                	push   $0x25
 580:	ff 75 08             	push   0x8(%ebp)
 583:	e8 d4 fd ff ff       	call   35c <putc>
 588:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 58b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58e:	0f be c0             	movsbl %al,%eax
 591:	83 ec 08             	sub    $0x8,%esp
 594:	50                   	push   %eax
 595:	ff 75 08             	push   0x8(%ebp)
 598:	e8 bf fd ff ff       	call   35c <putc>
 59d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5a7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ab:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b1:	01 d0                	add    %edx,%eax
 5b3:	0f b6 00             	movzbl (%eax),%eax
 5b6:	84 c0                	test   %al,%al
 5b8:	0f 85 94 fe ff ff    	jne    452 <printf+0x22>
    }
  }
}
 5be:	90                   	nop
 5bf:	90                   	nop
 5c0:	c9                   	leave  
 5c1:	c3                   	ret    

000005c2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5c2:	55                   	push   %ebp
 5c3:	89 e5                	mov    %esp,%ebp
 5c5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	83 e8 08             	sub    $0x8,%eax
 5ce:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5d1:	a1 5c 0a 00 00       	mov    0xa5c,%eax
 5d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d9:	eb 24                	jmp    5ff <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5de:	8b 00                	mov    (%eax),%eax
 5e0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5e3:	72 12                	jb     5f7 <free+0x35>
 5e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5eb:	77 24                	ja     611 <free+0x4f>
 5ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5f5:	72 1a                	jb     611 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fa:	8b 00                	mov    (%eax),%eax
 5fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 602:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 605:	76 d4                	jbe    5db <free+0x19>
 607:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60a:	8b 00                	mov    (%eax),%eax
 60c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 60f:	73 ca                	jae    5db <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 611:	8b 45 f8             	mov    -0x8(%ebp),%eax
 614:	8b 40 04             	mov    0x4(%eax),%eax
 617:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 61e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 621:	01 c2                	add    %eax,%edx
 623:	8b 45 fc             	mov    -0x4(%ebp),%eax
 626:	8b 00                	mov    (%eax),%eax
 628:	39 c2                	cmp    %eax,%edx
 62a:	75 24                	jne    650 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 62c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62f:	8b 50 04             	mov    0x4(%eax),%edx
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
 635:	8b 00                	mov    (%eax),%eax
 637:	8b 40 04             	mov    0x4(%eax),%eax
 63a:	01 c2                	add    %eax,%edx
 63c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 642:	8b 45 fc             	mov    -0x4(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	8b 10                	mov    (%eax),%edx
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	89 10                	mov    %edx,(%eax)
 64e:	eb 0a                	jmp    65a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 650:	8b 45 fc             	mov    -0x4(%ebp),%eax
 653:	8b 10                	mov    (%eax),%edx
 655:	8b 45 f8             	mov    -0x8(%ebp),%eax
 658:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 65a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65d:	8b 40 04             	mov    0x4(%eax),%eax
 660:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	01 d0                	add    %edx,%eax
 66c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 66f:	75 20                	jne    691 <free+0xcf>
    p->s.size += bp->s.size;
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 50 04             	mov    0x4(%eax),%edx
 677:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67a:	8b 40 04             	mov    0x4(%eax),%eax
 67d:	01 c2                	add    %eax,%edx
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 685:	8b 45 f8             	mov    -0x8(%ebp),%eax
 688:	8b 10                	mov    (%eax),%edx
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	89 10                	mov    %edx,(%eax)
 68f:	eb 08                	jmp    699 <free+0xd7>
  } else
    p->s.ptr = bp;
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 55 f8             	mov    -0x8(%ebp),%edx
 697:	89 10                	mov    %edx,(%eax)
  freep = p;
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	a3 5c 0a 00 00       	mov    %eax,0xa5c
}
 6a1:	90                   	nop
 6a2:	c9                   	leave  
 6a3:	c3                   	ret    

000006a4 <morecore>:

static Header*
morecore(uint nu)
{
 6a4:	55                   	push   %ebp
 6a5:	89 e5                	mov    %esp,%ebp
 6a7:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6aa:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6b1:	77 07                	ja     6ba <morecore+0x16>
    nu = 4096;
 6b3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6ba:	8b 45 08             	mov    0x8(%ebp),%eax
 6bd:	c1 e0 03             	shl    $0x3,%eax
 6c0:	83 ec 0c             	sub    $0xc,%esp
 6c3:	50                   	push   %eax
 6c4:	e8 7b fc ff ff       	call   344 <sbrk>
 6c9:	83 c4 10             	add    $0x10,%esp
 6cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6cf:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6d3:	75 07                	jne    6dc <morecore+0x38>
    return 0;
 6d5:	b8 00 00 00 00       	mov    $0x0,%eax
 6da:	eb 26                	jmp    702 <morecore+0x5e>
  hp = (Header*)p;
 6dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e5:	8b 55 08             	mov    0x8(%ebp),%edx
 6e8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ee:	83 c0 08             	add    $0x8,%eax
 6f1:	83 ec 0c             	sub    $0xc,%esp
 6f4:	50                   	push   %eax
 6f5:	e8 c8 fe ff ff       	call   5c2 <free>
 6fa:	83 c4 10             	add    $0x10,%esp
  return freep;
 6fd:	a1 5c 0a 00 00       	mov    0xa5c,%eax
}
 702:	c9                   	leave  
 703:	c3                   	ret    

00000704 <malloc>:

void*
malloc(uint nbytes)
{
 704:	55                   	push   %ebp
 705:	89 e5                	mov    %esp,%ebp
 707:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	83 c0 07             	add    $0x7,%eax
 710:	c1 e8 03             	shr    $0x3,%eax
 713:	83 c0 01             	add    $0x1,%eax
 716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 719:	a1 5c 0a 00 00       	mov    0xa5c,%eax
 71e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 721:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 725:	75 23                	jne    74a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 727:	c7 45 f0 54 0a 00 00 	movl   $0xa54,-0x10(%ebp)
 72e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 731:	a3 5c 0a 00 00       	mov    %eax,0xa5c
 736:	a1 5c 0a 00 00       	mov    0xa5c,%eax
 73b:	a3 54 0a 00 00       	mov    %eax,0xa54
    base.s.size = 0;
 740:	c7 05 58 0a 00 00 00 	movl   $0x0,0xa58
 747:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74d:	8b 00                	mov    (%eax),%eax
 74f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 752:	8b 45 f4             	mov    -0xc(%ebp),%eax
 755:	8b 40 04             	mov    0x4(%eax),%eax
 758:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 75b:	77 4d                	ja     7aa <malloc+0xa6>
      if(p->s.size == nunits)
 75d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 760:	8b 40 04             	mov    0x4(%eax),%eax
 763:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 766:	75 0c                	jne    774 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 768:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76b:	8b 10                	mov    (%eax),%edx
 76d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 770:	89 10                	mov    %edx,(%eax)
 772:	eb 26                	jmp    79a <malloc+0x96>
      else {
        p->s.size -= nunits;
 774:	8b 45 f4             	mov    -0xc(%ebp),%eax
 777:	8b 40 04             	mov    0x4(%eax),%eax
 77a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 77d:	89 c2                	mov    %eax,%edx
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	8b 40 04             	mov    0x4(%eax),%eax
 78b:	c1 e0 03             	shl    $0x3,%eax
 78e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 791:	8b 45 f4             	mov    -0xc(%ebp),%eax
 794:	8b 55 ec             	mov    -0x14(%ebp),%edx
 797:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	a3 5c 0a 00 00       	mov    %eax,0xa5c
      return (void*)(p + 1);
 7a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a5:	83 c0 08             	add    $0x8,%eax
 7a8:	eb 3b                	jmp    7e5 <malloc+0xe1>
    }
    if(p == freep)
 7aa:	a1 5c 0a 00 00       	mov    0xa5c,%eax
 7af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7b2:	75 1e                	jne    7d2 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7b4:	83 ec 0c             	sub    $0xc,%esp
 7b7:	ff 75 ec             	push   -0x14(%ebp)
 7ba:	e8 e5 fe ff ff       	call   6a4 <morecore>
 7bf:	83 c4 10             	add    $0x10,%esp
 7c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c9:	75 07                	jne    7d2 <malloc+0xce>
        return 0;
 7cb:	b8 00 00 00 00       	mov    $0x0,%eax
 7d0:	eb 13                	jmp    7e5 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e0:	e9 6d ff ff ff       	jmp    752 <malloc+0x4e>
  }
}
 7e5:	c9                   	leave  
 7e6:	c3                   	ret    

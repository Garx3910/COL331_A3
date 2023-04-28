
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	83 ec 0c             	sub    $0xc,%esp
   a:	ff 75 08             	push   0x8(%ebp)
   d:	e8 c5 03 00 00       	call   3d7 <strlen>
  12:	83 c4 10             	add    $0x10,%esp
  15:	8b 55 08             	mov    0x8(%ebp),%edx
  18:	01 d0                	add    %edx,%eax
  1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1d:	eb 04                	jmp    23 <fmtname+0x23>
  1f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  26:	3b 45 08             	cmp    0x8(%ebp),%eax
  29:	72 0a                	jb     35 <fmtname+0x35>
  2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2e:	0f b6 00             	movzbl (%eax),%eax
  31:	3c 2f                	cmp    $0x2f,%al
  33:	75 ea                	jne    1f <fmtname+0x1f>
    ;
  p++;
  35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  39:	83 ec 0c             	sub    $0xc,%esp
  3c:	ff 75 f4             	push   -0xc(%ebp)
  3f:	e8 93 03 00 00       	call   3d7 <strlen>
  44:	83 c4 10             	add    $0x10,%esp
  47:	83 f8 0d             	cmp    $0xd,%eax
  4a:	76 05                	jbe    51 <fmtname+0x51>
    return p;
  4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4f:	eb 60                	jmp    b1 <fmtname+0xb1>
  memmove(buf, p, strlen(p));
  51:	83 ec 0c             	sub    $0xc,%esp
  54:	ff 75 f4             	push   -0xc(%ebp)
  57:	e8 7b 03 00 00       	call   3d7 <strlen>
  5c:	83 c4 10             	add    $0x10,%esp
  5f:	83 ec 04             	sub    $0x4,%esp
  62:	50                   	push   %eax
  63:	ff 75 f4             	push   -0xc(%ebp)
  66:	68 c8 0d 00 00       	push   $0xdc8
  6b:	e8 e4 04 00 00       	call   554 <memmove>
  70:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  73:	83 ec 0c             	sub    $0xc,%esp
  76:	ff 75 f4             	push   -0xc(%ebp)
  79:	e8 59 03 00 00       	call   3d7 <strlen>
  7e:	83 c4 10             	add    $0x10,%esp
  81:	ba 0e 00 00 00       	mov    $0xe,%edx
  86:	89 d3                	mov    %edx,%ebx
  88:	29 c3                	sub    %eax,%ebx
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	ff 75 f4             	push   -0xc(%ebp)
  90:	e8 42 03 00 00       	call   3d7 <strlen>
  95:	83 c4 10             	add    $0x10,%esp
  98:	05 c8 0d 00 00       	add    $0xdc8,%eax
  9d:	83 ec 04             	sub    $0x4,%esp
  a0:	53                   	push   %ebx
  a1:	6a 20                	push   $0x20
  a3:	50                   	push   %eax
  a4:	e8 55 03 00 00       	call   3fe <memset>
  a9:	83 c4 10             	add    $0x10,%esp
  return buf;
  ac:	b8 c8 0d 00 00       	mov    $0xdc8,%eax
}
  b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b4:	c9                   	leave  
  b5:	c3                   	ret    

000000b6 <ls>:

void
ls(char *path)
{
  b6:	55                   	push   %ebp
  b7:	89 e5                	mov    %esp,%ebp
  b9:	57                   	push   %edi
  ba:	56                   	push   %esi
  bb:	53                   	push   %ebx
  bc:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  c2:	83 ec 08             	sub    $0x8,%esp
  c5:	6a 00                	push   $0x0
  c7:	ff 75 08             	push   0x8(%ebp)
  ca:	e8 0a 05 00 00       	call   5d9 <open>
  cf:	83 c4 10             	add    $0x10,%esp
  d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d9:	79 1a                	jns    f5 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
  db:	83 ec 04             	sub    $0x4,%esp
  de:	ff 75 08             	push   0x8(%ebp)
  e1:	68 c4 0a 00 00       	push   $0xac4
  e6:	6a 02                	push   $0x2
  e8:	e8 20 06 00 00       	call   70d <printf>
  ed:	83 c4 10             	add    $0x10,%esp
    return;
  f0:	e9 e1 01 00 00       	jmp    2d6 <ls+0x220>
  }

  if(fstat(fd, &st) < 0){
  f5:	83 ec 08             	sub    $0x8,%esp
  f8:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fe:	50                   	push   %eax
  ff:	ff 75 e4             	push   -0x1c(%ebp)
 102:	e8 ea 04 00 00       	call   5f1 <fstat>
 107:	83 c4 10             	add    $0x10,%esp
 10a:	85 c0                	test   %eax,%eax
 10c:	79 28                	jns    136 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
 10e:	83 ec 04             	sub    $0x4,%esp
 111:	ff 75 08             	push   0x8(%ebp)
 114:	68 d8 0a 00 00       	push   $0xad8
 119:	6a 02                	push   $0x2
 11b:	e8 ed 05 00 00       	call   70d <printf>
 120:	83 c4 10             	add    $0x10,%esp
    close(fd);
 123:	83 ec 0c             	sub    $0xc,%esp
 126:	ff 75 e4             	push   -0x1c(%ebp)
 129:	e8 93 04 00 00       	call   5c1 <close>
 12e:	83 c4 10             	add    $0x10,%esp
    return;
 131:	e9 a0 01 00 00       	jmp    2d6 <ls+0x220>
  }

  switch(st.type){
 136:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 13d:	98                   	cwtl   
 13e:	83 f8 01             	cmp    $0x1,%eax
 141:	74 48                	je     18b <ls+0xd5>
 143:	83 f8 02             	cmp    $0x2,%eax
 146:	0f 85 7c 01 00 00    	jne    2c8 <ls+0x212>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 14c:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 152:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 158:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 15f:	0f bf d8             	movswl %ax,%ebx
 162:	83 ec 0c             	sub    $0xc,%esp
 165:	ff 75 08             	push   0x8(%ebp)
 168:	e8 93 fe ff ff       	call   0 <fmtname>
 16d:	83 c4 10             	add    $0x10,%esp
 170:	83 ec 08             	sub    $0x8,%esp
 173:	57                   	push   %edi
 174:	56                   	push   %esi
 175:	53                   	push   %ebx
 176:	50                   	push   %eax
 177:	68 ec 0a 00 00       	push   $0xaec
 17c:	6a 01                	push   $0x1
 17e:	e8 8a 05 00 00       	call   70d <printf>
 183:	83 c4 20             	add    $0x20,%esp
    break;
 186:	e9 3d 01 00 00       	jmp    2c8 <ls+0x212>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 18b:	83 ec 0c             	sub    $0xc,%esp
 18e:	ff 75 08             	push   0x8(%ebp)
 191:	e8 41 02 00 00       	call   3d7 <strlen>
 196:	83 c4 10             	add    $0x10,%esp
 199:	83 c0 10             	add    $0x10,%eax
 19c:	3d 00 02 00 00       	cmp    $0x200,%eax
 1a1:	76 17                	jbe    1ba <ls+0x104>
      printf(1, "ls: path too long\n");
 1a3:	83 ec 08             	sub    $0x8,%esp
 1a6:	68 f9 0a 00 00       	push   $0xaf9
 1ab:	6a 01                	push   $0x1
 1ad:	e8 5b 05 00 00       	call   70d <printf>
 1b2:	83 c4 10             	add    $0x10,%esp
      break;
 1b5:	e9 0e 01 00 00       	jmp    2c8 <ls+0x212>
    }
    strcpy(buf, path);
 1ba:	83 ec 08             	sub    $0x8,%esp
 1bd:	ff 75 08             	push   0x8(%ebp)
 1c0:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1c6:	50                   	push   %eax
 1c7:	e8 9c 01 00 00       	call   368 <strcpy>
 1cc:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1cf:	83 ec 0c             	sub    $0xc,%esp
 1d2:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d8:	50                   	push   %eax
 1d9:	e8 f9 01 00 00       	call   3d7 <strlen>
 1de:	83 c4 10             	add    $0x10,%esp
 1e1:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1e7:	01 d0                	add    %edx,%eax
 1e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1ef:	8d 50 01             	lea    0x1(%eax),%edx
 1f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1f5:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1f8:	e9 aa 00 00 00       	jmp    2a7 <ls+0x1f1>
      if(de.inum == 0)
 1fd:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 204:	66 85 c0             	test   %ax,%ax
 207:	75 05                	jne    20e <ls+0x158>
        continue;
 209:	e9 99 00 00 00       	jmp    2a7 <ls+0x1f1>
      memmove(p, de.name, DIRSIZ);
 20e:	83 ec 04             	sub    $0x4,%esp
 211:	6a 0e                	push   $0xe
 213:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 219:	83 c0 02             	add    $0x2,%eax
 21c:	50                   	push   %eax
 21d:	ff 75 e0             	push   -0x20(%ebp)
 220:	e8 2f 03 00 00       	call   554 <memmove>
 225:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 228:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22b:	83 c0 0e             	add    $0xe,%eax
 22e:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 231:	83 ec 08             	sub    $0x8,%esp
 234:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 23a:	50                   	push   %eax
 23b:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 241:	50                   	push   %eax
 242:	e8 73 02 00 00       	call   4ba <stat>
 247:	83 c4 10             	add    $0x10,%esp
 24a:	85 c0                	test   %eax,%eax
 24c:	79 1b                	jns    269 <ls+0x1b3>
        printf(1, "ls: cannot stat %s\n", buf);
 24e:	83 ec 04             	sub    $0x4,%esp
 251:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 257:	50                   	push   %eax
 258:	68 d8 0a 00 00       	push   $0xad8
 25d:	6a 01                	push   $0x1
 25f:	e8 a9 04 00 00       	call   70d <printf>
 264:	83 c4 10             	add    $0x10,%esp
        continue;
 267:	eb 3e                	jmp    2a7 <ls+0x1f1>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 269:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 26f:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 275:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 27c:	0f bf d8             	movswl %ax,%ebx
 27f:	83 ec 0c             	sub    $0xc,%esp
 282:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 288:	50                   	push   %eax
 289:	e8 72 fd ff ff       	call   0 <fmtname>
 28e:	83 c4 10             	add    $0x10,%esp
 291:	83 ec 08             	sub    $0x8,%esp
 294:	57                   	push   %edi
 295:	56                   	push   %esi
 296:	53                   	push   %ebx
 297:	50                   	push   %eax
 298:	68 ec 0a 00 00       	push   $0xaec
 29d:	6a 01                	push   $0x1
 29f:	e8 69 04 00 00       	call   70d <printf>
 2a4:	83 c4 20             	add    $0x20,%esp
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2a7:	83 ec 04             	sub    $0x4,%esp
 2aa:	6a 10                	push   $0x10
 2ac:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2b2:	50                   	push   %eax
 2b3:	ff 75 e4             	push   -0x1c(%ebp)
 2b6:	e8 f6 02 00 00       	call   5b1 <read>
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	83 f8 10             	cmp    $0x10,%eax
 2c1:	0f 84 36 ff ff ff    	je     1fd <ls+0x147>
    }
    break;
 2c7:	90                   	nop
  }
  close(fd);
 2c8:	83 ec 0c             	sub    $0xc,%esp
 2cb:	ff 75 e4             	push   -0x1c(%ebp)
 2ce:	e8 ee 02 00 00       	call   5c1 <close>
 2d3:	83 c4 10             	add    $0x10,%esp
}
 2d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2d9:	5b                   	pop    %ebx
 2da:	5e                   	pop    %esi
 2db:	5f                   	pop    %edi
 2dc:	5d                   	pop    %ebp
 2dd:	c3                   	ret    

000002de <main>:

int
main(int argc, char *argv[])
{
 2de:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2e2:	83 e4 f0             	and    $0xfffffff0,%esp
 2e5:	ff 71 fc             	push   -0x4(%ecx)
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	53                   	push   %ebx
 2ec:	51                   	push   %ecx
 2ed:	83 ec 10             	sub    $0x10,%esp
 2f0:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
 2f2:	83 3b 01             	cmpl   $0x1,(%ebx)
 2f5:	7f 15                	jg     30c <main+0x2e>
    ls(".");
 2f7:	83 ec 0c             	sub    $0xc,%esp
 2fa:	68 0c 0b 00 00       	push   $0xb0c
 2ff:	e8 b2 fd ff ff       	call   b6 <ls>
 304:	83 c4 10             	add    $0x10,%esp
    exit();
 307:	e8 8d 02 00 00       	call   599 <exit>
  }
  for(i=1; i<argc; i++)
 30c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 313:	eb 21                	jmp    336 <main+0x58>
    ls(argv[i]);
 315:	8b 45 f4             	mov    -0xc(%ebp),%eax
 318:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 31f:	8b 43 04             	mov    0x4(%ebx),%eax
 322:	01 d0                	add    %edx,%eax
 324:	8b 00                	mov    (%eax),%eax
 326:	83 ec 0c             	sub    $0xc,%esp
 329:	50                   	push   %eax
 32a:	e8 87 fd ff ff       	call   b6 <ls>
 32f:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
 332:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 336:	8b 45 f4             	mov    -0xc(%ebp),%eax
 339:	3b 03                	cmp    (%ebx),%eax
 33b:	7c d8                	jl     315 <main+0x37>
  exit();
 33d:	e8 57 02 00 00       	call   599 <exit>

00000342 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	57                   	push   %edi
 346:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 347:	8b 4d 08             	mov    0x8(%ebp),%ecx
 34a:	8b 55 10             	mov    0x10(%ebp),%edx
 34d:	8b 45 0c             	mov    0xc(%ebp),%eax
 350:	89 cb                	mov    %ecx,%ebx
 352:	89 df                	mov    %ebx,%edi
 354:	89 d1                	mov    %edx,%ecx
 356:	fc                   	cld    
 357:	f3 aa                	rep stos %al,%es:(%edi)
 359:	89 ca                	mov    %ecx,%edx
 35b:	89 fb                	mov    %edi,%ebx
 35d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 360:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 363:	90                   	nop
 364:	5b                   	pop    %ebx
 365:	5f                   	pop    %edi
 366:	5d                   	pop    %ebp
 367:	c3                   	ret    

00000368 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 374:	90                   	nop
 375:	8b 55 0c             	mov    0xc(%ebp),%edx
 378:	8d 42 01             	lea    0x1(%edx),%eax
 37b:	89 45 0c             	mov    %eax,0xc(%ebp)
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	8d 48 01             	lea    0x1(%eax),%ecx
 384:	89 4d 08             	mov    %ecx,0x8(%ebp)
 387:	0f b6 12             	movzbl (%edx),%edx
 38a:	88 10                	mov    %dl,(%eax)
 38c:	0f b6 00             	movzbl (%eax),%eax
 38f:	84 c0                	test   %al,%al
 391:	75 e2                	jne    375 <strcpy+0xd>
    ;
  return os;
 393:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 396:	c9                   	leave  
 397:	c3                   	ret    

00000398 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 39b:	eb 08                	jmp    3a5 <strcmp+0xd>
    p++, q++;
 39d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3a5:	8b 45 08             	mov    0x8(%ebp),%eax
 3a8:	0f b6 00             	movzbl (%eax),%eax
 3ab:	84 c0                	test   %al,%al
 3ad:	74 10                	je     3bf <strcmp+0x27>
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	0f b6 10             	movzbl (%eax),%edx
 3b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	38 c2                	cmp    %al,%dl
 3bd:	74 de                	je     39d <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	0f b6 00             	movzbl (%eax),%eax
 3c5:	0f b6 d0             	movzbl %al,%edx
 3c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	0f b6 c8             	movzbl %al,%ecx
 3d1:	89 d0                	mov    %edx,%eax
 3d3:	29 c8                	sub    %ecx,%eax
}
 3d5:	5d                   	pop    %ebp
 3d6:	c3                   	ret    

000003d7 <strlen>:

uint
strlen(const char *s)
{
 3d7:	55                   	push   %ebp
 3d8:	89 e5                	mov    %esp,%ebp
 3da:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3e4:	eb 04                	jmp    3ea <strlen+0x13>
 3e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	01 d0                	add    %edx,%eax
 3f2:	0f b6 00             	movzbl (%eax),%eax
 3f5:	84 c0                	test   %al,%al
 3f7:	75 ed                	jne    3e6 <strlen+0xf>
    ;
  return n;
 3f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3fc:	c9                   	leave  
 3fd:	c3                   	ret    

000003fe <memset>:

void*
memset(void *dst, int c, uint n)
{
 3fe:	55                   	push   %ebp
 3ff:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 401:	8b 45 10             	mov    0x10(%ebp),%eax
 404:	50                   	push   %eax
 405:	ff 75 0c             	push   0xc(%ebp)
 408:	ff 75 08             	push   0x8(%ebp)
 40b:	e8 32 ff ff ff       	call   342 <stosb>
 410:	83 c4 0c             	add    $0xc,%esp
  return dst;
 413:	8b 45 08             	mov    0x8(%ebp),%eax
}
 416:	c9                   	leave  
 417:	c3                   	ret    

00000418 <strchr>:

char*
strchr(const char *s, char c)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 04             	sub    $0x4,%esp
 41e:	8b 45 0c             	mov    0xc(%ebp),%eax
 421:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 424:	eb 14                	jmp    43a <strchr+0x22>
    if(*s == c)
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 42f:	75 05                	jne    436 <strchr+0x1e>
      return (char*)s;
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	eb 13                	jmp    449 <strchr+0x31>
  for(; *s; s++)
 436:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43a:	8b 45 08             	mov    0x8(%ebp),%eax
 43d:	0f b6 00             	movzbl (%eax),%eax
 440:	84 c0                	test   %al,%al
 442:	75 e2                	jne    426 <strchr+0xe>
  return 0;
 444:	b8 00 00 00 00       	mov    $0x0,%eax
}
 449:	c9                   	leave  
 44a:	c3                   	ret    

0000044b <gets>:

char*
gets(char *buf, int max)
{
 44b:	55                   	push   %ebp
 44c:	89 e5                	mov    %esp,%ebp
 44e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 458:	eb 42                	jmp    49c <gets+0x51>
    cc = read(0, &c, 1);
 45a:	83 ec 04             	sub    $0x4,%esp
 45d:	6a 01                	push   $0x1
 45f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 462:	50                   	push   %eax
 463:	6a 00                	push   $0x0
 465:	e8 47 01 00 00       	call   5b1 <read>
 46a:	83 c4 10             	add    $0x10,%esp
 46d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 470:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 474:	7e 33                	jle    4a9 <gets+0x5e>
      break;
    buf[i++] = c;
 476:	8b 45 f4             	mov    -0xc(%ebp),%eax
 479:	8d 50 01             	lea    0x1(%eax),%edx
 47c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 47f:	89 c2                	mov    %eax,%edx
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	01 c2                	add    %eax,%edx
 486:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 48a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 48c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 490:	3c 0a                	cmp    $0xa,%al
 492:	74 16                	je     4aa <gets+0x5f>
 494:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 498:	3c 0d                	cmp    $0xd,%al
 49a:	74 0e                	je     4aa <gets+0x5f>
  for(i=0; i+1 < max; ){
 49c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49f:	83 c0 01             	add    $0x1,%eax
 4a2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4a5:	7f b3                	jg     45a <gets+0xf>
 4a7:	eb 01                	jmp    4aa <gets+0x5f>
      break;
 4a9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4ad:	8b 45 08             	mov    0x8(%ebp),%eax
 4b0:	01 d0                	add    %edx,%eax
 4b2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4b8:	c9                   	leave  
 4b9:	c3                   	ret    

000004ba <stat>:

int
stat(const char *n, struct stat *st)
{
 4ba:	55                   	push   %ebp
 4bb:	89 e5                	mov    %esp,%ebp
 4bd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c0:	83 ec 08             	sub    $0x8,%esp
 4c3:	6a 00                	push   $0x0
 4c5:	ff 75 08             	push   0x8(%ebp)
 4c8:	e8 0c 01 00 00       	call   5d9 <open>
 4cd:	83 c4 10             	add    $0x10,%esp
 4d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d7:	79 07                	jns    4e0 <stat+0x26>
    return -1;
 4d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4de:	eb 25                	jmp    505 <stat+0x4b>
  r = fstat(fd, st);
 4e0:	83 ec 08             	sub    $0x8,%esp
 4e3:	ff 75 0c             	push   0xc(%ebp)
 4e6:	ff 75 f4             	push   -0xc(%ebp)
 4e9:	e8 03 01 00 00       	call   5f1 <fstat>
 4ee:	83 c4 10             	add    $0x10,%esp
 4f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4f4:	83 ec 0c             	sub    $0xc,%esp
 4f7:	ff 75 f4             	push   -0xc(%ebp)
 4fa:	e8 c2 00 00 00       	call   5c1 <close>
 4ff:	83 c4 10             	add    $0x10,%esp
  return r;
 502:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 505:	c9                   	leave  
 506:	c3                   	ret    

00000507 <atoi>:

int
atoi(const char *s)
{
 507:	55                   	push   %ebp
 508:	89 e5                	mov    %esp,%ebp
 50a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 50d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 514:	eb 25                	jmp    53b <atoi+0x34>
    n = n*10 + *s++ - '0';
 516:	8b 55 fc             	mov    -0x4(%ebp),%edx
 519:	89 d0                	mov    %edx,%eax
 51b:	c1 e0 02             	shl    $0x2,%eax
 51e:	01 d0                	add    %edx,%eax
 520:	01 c0                	add    %eax,%eax
 522:	89 c1                	mov    %eax,%ecx
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	8d 50 01             	lea    0x1(%eax),%edx
 52a:	89 55 08             	mov    %edx,0x8(%ebp)
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	0f be c0             	movsbl %al,%eax
 533:	01 c8                	add    %ecx,%eax
 535:	83 e8 30             	sub    $0x30,%eax
 538:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	0f b6 00             	movzbl (%eax),%eax
 541:	3c 2f                	cmp    $0x2f,%al
 543:	7e 0a                	jle    54f <atoi+0x48>
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	0f b6 00             	movzbl (%eax),%eax
 54b:	3c 39                	cmp    $0x39,%al
 54d:	7e c7                	jle    516 <atoi+0xf>
  return n;
 54f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 552:	c9                   	leave  
 553:	c3                   	ret    

00000554 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 554:	55                   	push   %ebp
 555:	89 e5                	mov    %esp,%ebp
 557:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 560:	8b 45 0c             	mov    0xc(%ebp),%eax
 563:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 566:	eb 17                	jmp    57f <memmove+0x2b>
    *dst++ = *src++;
 568:	8b 55 f8             	mov    -0x8(%ebp),%edx
 56b:	8d 42 01             	lea    0x1(%edx),%eax
 56e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 571:	8b 45 fc             	mov    -0x4(%ebp),%eax
 574:	8d 48 01             	lea    0x1(%eax),%ecx
 577:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 57a:	0f b6 12             	movzbl (%edx),%edx
 57d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 57f:	8b 45 10             	mov    0x10(%ebp),%eax
 582:	8d 50 ff             	lea    -0x1(%eax),%edx
 585:	89 55 10             	mov    %edx,0x10(%ebp)
 588:	85 c0                	test   %eax,%eax
 58a:	7f dc                	jg     568 <memmove+0x14>
  return vdst;
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 58f:	c9                   	leave  
 590:	c3                   	ret    

00000591 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 591:	b8 01 00 00 00       	mov    $0x1,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <exit>:
SYSCALL(exit)
 599:	b8 02 00 00 00       	mov    $0x2,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    

000005a1 <wait>:
SYSCALL(wait)
 5a1:	b8 03 00 00 00       	mov    $0x3,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret    

000005a9 <pipe>:
SYSCALL(pipe)
 5a9:	b8 04 00 00 00       	mov    $0x4,%eax
 5ae:	cd 40                	int    $0x40
 5b0:	c3                   	ret    

000005b1 <read>:
SYSCALL(read)
 5b1:	b8 05 00 00 00       	mov    $0x5,%eax
 5b6:	cd 40                	int    $0x40
 5b8:	c3                   	ret    

000005b9 <write>:
SYSCALL(write)
 5b9:	b8 10 00 00 00       	mov    $0x10,%eax
 5be:	cd 40                	int    $0x40
 5c0:	c3                   	ret    

000005c1 <close>:
SYSCALL(close)
 5c1:	b8 15 00 00 00       	mov    $0x15,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret    

000005c9 <kill>:
SYSCALL(kill)
 5c9:	b8 06 00 00 00       	mov    $0x6,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret    

000005d1 <exec>:
SYSCALL(exec)
 5d1:	b8 07 00 00 00       	mov    $0x7,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret    

000005d9 <open>:
SYSCALL(open)
 5d9:	b8 0f 00 00 00       	mov    $0xf,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret    

000005e1 <mknod>:
SYSCALL(mknod)
 5e1:	b8 11 00 00 00       	mov    $0x11,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret    

000005e9 <unlink>:
SYSCALL(unlink)
 5e9:	b8 12 00 00 00       	mov    $0x12,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret    

000005f1 <fstat>:
SYSCALL(fstat)
 5f1:	b8 08 00 00 00       	mov    $0x8,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret    

000005f9 <link>:
SYSCALL(link)
 5f9:	b8 13 00 00 00       	mov    $0x13,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <mkdir>:
SYSCALL(mkdir)
 601:	b8 14 00 00 00       	mov    $0x14,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <chdir>:
SYSCALL(chdir)
 609:	b8 09 00 00 00       	mov    $0x9,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <dup>:
SYSCALL(dup)
 611:	b8 0a 00 00 00       	mov    $0xa,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <getpid>:
SYSCALL(getpid)
 619:	b8 0b 00 00 00       	mov    $0xb,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <sbrk>:
SYSCALL(sbrk)
 621:	b8 0c 00 00 00       	mov    $0xc,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <sleep>:
SYSCALL(sleep)
 629:	b8 0d 00 00 00       	mov    $0xd,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <uptime>:
SYSCALL(uptime)
 631:	b8 0e 00 00 00       	mov    $0xe,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret    

00000639 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 639:	55                   	push   %ebp
 63a:	89 e5                	mov    %esp,%ebp
 63c:	83 ec 18             	sub    $0x18,%esp
 63f:	8b 45 0c             	mov    0xc(%ebp),%eax
 642:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 645:	83 ec 04             	sub    $0x4,%esp
 648:	6a 01                	push   $0x1
 64a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 64d:	50                   	push   %eax
 64e:	ff 75 08             	push   0x8(%ebp)
 651:	e8 63 ff ff ff       	call   5b9 <write>
 656:	83 c4 10             	add    $0x10,%esp
}
 659:	90                   	nop
 65a:	c9                   	leave  
 65b:	c3                   	ret    

0000065c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 662:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 669:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 66d:	74 17                	je     686 <printint+0x2a>
 66f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 673:	79 11                	jns    686 <printint+0x2a>
    neg = 1;
 675:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 67c:	8b 45 0c             	mov    0xc(%ebp),%eax
 67f:	f7 d8                	neg    %eax
 681:	89 45 ec             	mov    %eax,-0x14(%ebp)
 684:	eb 06                	jmp    68c <printint+0x30>
  } else {
    x = xx;
 686:	8b 45 0c             	mov    0xc(%ebp),%eax
 689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 68c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 693:	8b 4d 10             	mov    0x10(%ebp),%ecx
 696:	8b 45 ec             	mov    -0x14(%ebp),%eax
 699:	ba 00 00 00 00       	mov    $0x0,%edx
 69e:	f7 f1                	div    %ecx
 6a0:	89 d1                	mov    %edx,%ecx
 6a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a5:	8d 50 01             	lea    0x1(%eax),%edx
 6a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6ab:	0f b6 91 b4 0d 00 00 	movzbl 0xdb4(%ecx),%edx
 6b2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6bc:	ba 00 00 00 00       	mov    $0x0,%edx
 6c1:	f7 f1                	div    %ecx
 6c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ca:	75 c7                	jne    693 <printint+0x37>
  if(neg)
 6cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6d0:	74 2d                	je     6ff <printint+0xa3>
    buf[i++] = '-';
 6d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d5:	8d 50 01             	lea    0x1(%eax),%edx
 6d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6db:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6e0:	eb 1d                	jmp    6ff <printint+0xa3>
    putc(fd, buf[i]);
 6e2:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e8:	01 d0                	add    %edx,%eax
 6ea:	0f b6 00             	movzbl (%eax),%eax
 6ed:	0f be c0             	movsbl %al,%eax
 6f0:	83 ec 08             	sub    $0x8,%esp
 6f3:	50                   	push   %eax
 6f4:	ff 75 08             	push   0x8(%ebp)
 6f7:	e8 3d ff ff ff       	call   639 <putc>
 6fc:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6ff:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 703:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 707:	79 d9                	jns    6e2 <printint+0x86>
}
 709:	90                   	nop
 70a:	90                   	nop
 70b:	c9                   	leave  
 70c:	c3                   	ret    

0000070d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 70d:	55                   	push   %ebp
 70e:	89 e5                	mov    %esp,%ebp
 710:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 713:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 71a:	8d 45 0c             	lea    0xc(%ebp),%eax
 71d:	83 c0 04             	add    $0x4,%eax
 720:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 723:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 72a:	e9 59 01 00 00       	jmp    888 <printf+0x17b>
    c = fmt[i] & 0xff;
 72f:	8b 55 0c             	mov    0xc(%ebp),%edx
 732:	8b 45 f0             	mov    -0x10(%ebp),%eax
 735:	01 d0                	add    %edx,%eax
 737:	0f b6 00             	movzbl (%eax),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	25 ff 00 00 00       	and    $0xff,%eax
 742:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 745:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 749:	75 2c                	jne    777 <printf+0x6a>
      if(c == '%'){
 74b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74f:	75 0c                	jne    75d <printf+0x50>
        state = '%';
 751:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 758:	e9 27 01 00 00       	jmp    884 <printf+0x177>
      } else {
        putc(fd, c);
 75d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 760:	0f be c0             	movsbl %al,%eax
 763:	83 ec 08             	sub    $0x8,%esp
 766:	50                   	push   %eax
 767:	ff 75 08             	push   0x8(%ebp)
 76a:	e8 ca fe ff ff       	call   639 <putc>
 76f:	83 c4 10             	add    $0x10,%esp
 772:	e9 0d 01 00 00       	jmp    884 <printf+0x177>
      }
    } else if(state == '%'){
 777:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 77b:	0f 85 03 01 00 00    	jne    884 <printf+0x177>
      if(c == 'd'){
 781:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 785:	75 1e                	jne    7a5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 787:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78a:	8b 00                	mov    (%eax),%eax
 78c:	6a 01                	push   $0x1
 78e:	6a 0a                	push   $0xa
 790:	50                   	push   %eax
 791:	ff 75 08             	push   0x8(%ebp)
 794:	e8 c3 fe ff ff       	call   65c <printint>
 799:	83 c4 10             	add    $0x10,%esp
        ap++;
 79c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a0:	e9 d8 00 00 00       	jmp    87d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7a5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7a9:	74 06                	je     7b1 <printf+0xa4>
 7ab:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7af:	75 1e                	jne    7cf <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	6a 00                	push   $0x0
 7b8:	6a 10                	push   $0x10
 7ba:	50                   	push   %eax
 7bb:	ff 75 08             	push   0x8(%ebp)
 7be:	e8 99 fe ff ff       	call   65c <printint>
 7c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ca:	e9 ae 00 00 00       	jmp    87d <printf+0x170>
      } else if(c == 's'){
 7cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7d3:	75 43                	jne    818 <printf+0x10b>
        s = (char*)*ap;
 7d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e5:	75 25                	jne    80c <printf+0xff>
          s = "(null)";
 7e7:	c7 45 f4 0e 0b 00 00 	movl   $0xb0e,-0xc(%ebp)
        while(*s != 0){
 7ee:	eb 1c                	jmp    80c <printf+0xff>
          putc(fd, *s);
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	0f b6 00             	movzbl (%eax),%eax
 7f6:	0f be c0             	movsbl %al,%eax
 7f9:	83 ec 08             	sub    $0x8,%esp
 7fc:	50                   	push   %eax
 7fd:	ff 75 08             	push   0x8(%ebp)
 800:	e8 34 fe ff ff       	call   639 <putc>
 805:	83 c4 10             	add    $0x10,%esp
          s++;
 808:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 80c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80f:	0f b6 00             	movzbl (%eax),%eax
 812:	84 c0                	test   %al,%al
 814:	75 da                	jne    7f0 <printf+0xe3>
 816:	eb 65                	jmp    87d <printf+0x170>
        }
      } else if(c == 'c'){
 818:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 81c:	75 1d                	jne    83b <printf+0x12e>
        putc(fd, *ap);
 81e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 821:	8b 00                	mov    (%eax),%eax
 823:	0f be c0             	movsbl %al,%eax
 826:	83 ec 08             	sub    $0x8,%esp
 829:	50                   	push   %eax
 82a:	ff 75 08             	push   0x8(%ebp)
 82d:	e8 07 fe ff ff       	call   639 <putc>
 832:	83 c4 10             	add    $0x10,%esp
        ap++;
 835:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 839:	eb 42                	jmp    87d <printf+0x170>
      } else if(c == '%'){
 83b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 83f:	75 17                	jne    858 <printf+0x14b>
        putc(fd, c);
 841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 844:	0f be c0             	movsbl %al,%eax
 847:	83 ec 08             	sub    $0x8,%esp
 84a:	50                   	push   %eax
 84b:	ff 75 08             	push   0x8(%ebp)
 84e:	e8 e6 fd ff ff       	call   639 <putc>
 853:	83 c4 10             	add    $0x10,%esp
 856:	eb 25                	jmp    87d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 858:	83 ec 08             	sub    $0x8,%esp
 85b:	6a 25                	push   $0x25
 85d:	ff 75 08             	push   0x8(%ebp)
 860:	e8 d4 fd ff ff       	call   639 <putc>
 865:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 868:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 86b:	0f be c0             	movsbl %al,%eax
 86e:	83 ec 08             	sub    $0x8,%esp
 871:	50                   	push   %eax
 872:	ff 75 08             	push   0x8(%ebp)
 875:	e8 bf fd ff ff       	call   639 <putc>
 87a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 87d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 884:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 888:	8b 55 0c             	mov    0xc(%ebp),%edx
 88b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88e:	01 d0                	add    %edx,%eax
 890:	0f b6 00             	movzbl (%eax),%eax
 893:	84 c0                	test   %al,%al
 895:	0f 85 94 fe ff ff    	jne    72f <printf+0x22>
    }
  }
}
 89b:	90                   	nop
 89c:	90                   	nop
 89d:	c9                   	leave  
 89e:	c3                   	ret    

0000089f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89f:	55                   	push   %ebp
 8a0:	89 e5                	mov    %esp,%ebp
 8a2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a5:	8b 45 08             	mov    0x8(%ebp),%eax
 8a8:	83 e8 08             	sub    $0x8,%eax
 8ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ae:	a1 e0 0d 00 00       	mov    0xde0,%eax
 8b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b6:	eb 24                	jmp    8dc <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 00                	mov    (%eax),%eax
 8bd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8c0:	72 12                	jb     8d4 <free+0x35>
 8c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c8:	77 24                	ja     8ee <free+0x4f>
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	8b 00                	mov    (%eax),%eax
 8cf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8d2:	72 1a                	jb     8ee <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d7:	8b 00                	mov    (%eax),%eax
 8d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8df:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e2:	76 d4                	jbe    8b8 <free+0x19>
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	8b 00                	mov    (%eax),%eax
 8e9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8ec:	73 ca                	jae    8b8 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f1:	8b 40 04             	mov    0x4(%eax),%eax
 8f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fe:	01 c2                	add    %eax,%edx
 900:	8b 45 fc             	mov    -0x4(%ebp),%eax
 903:	8b 00                	mov    (%eax),%eax
 905:	39 c2                	cmp    %eax,%edx
 907:	75 24                	jne    92d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 909:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90c:	8b 50 04             	mov    0x4(%eax),%edx
 90f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 912:	8b 00                	mov    (%eax),%eax
 914:	8b 40 04             	mov    0x4(%eax),%eax
 917:	01 c2                	add    %eax,%edx
 919:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	8b 00                	mov    (%eax),%eax
 924:	8b 10                	mov    (%eax),%edx
 926:	8b 45 f8             	mov    -0x8(%ebp),%eax
 929:	89 10                	mov    %edx,(%eax)
 92b:	eb 0a                	jmp    937 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 92d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 930:	8b 10                	mov    (%eax),%edx
 932:	8b 45 f8             	mov    -0x8(%ebp),%eax
 935:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	8b 40 04             	mov    0x4(%eax),%eax
 93d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	01 d0                	add    %edx,%eax
 949:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 94c:	75 20                	jne    96e <free+0xcf>
    p->s.size += bp->s.size;
 94e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 951:	8b 50 04             	mov    0x4(%eax),%edx
 954:	8b 45 f8             	mov    -0x8(%ebp),%eax
 957:	8b 40 04             	mov    0x4(%eax),%eax
 95a:	01 c2                	add    %eax,%edx
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 962:	8b 45 f8             	mov    -0x8(%ebp),%eax
 965:	8b 10                	mov    (%eax),%edx
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	89 10                	mov    %edx,(%eax)
 96c:	eb 08                	jmp    976 <free+0xd7>
  } else
    p->s.ptr = bp;
 96e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 971:	8b 55 f8             	mov    -0x8(%ebp),%edx
 974:	89 10                	mov    %edx,(%eax)
  freep = p;
 976:	8b 45 fc             	mov    -0x4(%ebp),%eax
 979:	a3 e0 0d 00 00       	mov    %eax,0xde0
}
 97e:	90                   	nop
 97f:	c9                   	leave  
 980:	c3                   	ret    

00000981 <morecore>:

static Header*
morecore(uint nu)
{
 981:	55                   	push   %ebp
 982:	89 e5                	mov    %esp,%ebp
 984:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 987:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 98e:	77 07                	ja     997 <morecore+0x16>
    nu = 4096;
 990:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 997:	8b 45 08             	mov    0x8(%ebp),%eax
 99a:	c1 e0 03             	shl    $0x3,%eax
 99d:	83 ec 0c             	sub    $0xc,%esp
 9a0:	50                   	push   %eax
 9a1:	e8 7b fc ff ff       	call   621 <sbrk>
 9a6:	83 c4 10             	add    $0x10,%esp
 9a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ac:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9b0:	75 07                	jne    9b9 <morecore+0x38>
    return 0;
 9b2:	b8 00 00 00 00       	mov    $0x0,%eax
 9b7:	eb 26                	jmp    9df <morecore+0x5e>
  hp = (Header*)p;
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c2:	8b 55 08             	mov    0x8(%ebp),%edx
 9c5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cb:	83 c0 08             	add    $0x8,%eax
 9ce:	83 ec 0c             	sub    $0xc,%esp
 9d1:	50                   	push   %eax
 9d2:	e8 c8 fe ff ff       	call   89f <free>
 9d7:	83 c4 10             	add    $0x10,%esp
  return freep;
 9da:	a1 e0 0d 00 00       	mov    0xde0,%eax
}
 9df:	c9                   	leave  
 9e0:	c3                   	ret    

000009e1 <malloc>:

void*
malloc(uint nbytes)
{
 9e1:	55                   	push   %ebp
 9e2:	89 e5                	mov    %esp,%ebp
 9e4:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ea:	83 c0 07             	add    $0x7,%eax
 9ed:	c1 e8 03             	shr    $0x3,%eax
 9f0:	83 c0 01             	add    $0x1,%eax
 9f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9f6:	a1 e0 0d 00 00       	mov    0xde0,%eax
 9fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a02:	75 23                	jne    a27 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a04:	c7 45 f0 d8 0d 00 00 	movl   $0xdd8,-0x10(%ebp)
 a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0e:	a3 e0 0d 00 00       	mov    %eax,0xde0
 a13:	a1 e0 0d 00 00       	mov    0xde0,%eax
 a18:	a3 d8 0d 00 00       	mov    %eax,0xdd8
    base.s.size = 0;
 a1d:	c7 05 dc 0d 00 00 00 	movl   $0x0,0xddc
 a24:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2a:	8b 00                	mov    (%eax),%eax
 a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a32:	8b 40 04             	mov    0x4(%eax),%eax
 a35:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a38:	77 4d                	ja     a87 <malloc+0xa6>
      if(p->s.size == nunits)
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	8b 40 04             	mov    0x4(%eax),%eax
 a40:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a43:	75 0c                	jne    a51 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	8b 10                	mov    (%eax),%edx
 a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4d:	89 10                	mov    %edx,(%eax)
 a4f:	eb 26                	jmp    a77 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a54:	8b 40 04             	mov    0x4(%eax),%eax
 a57:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a5a:	89 c2                	mov    %eax,%edx
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	8b 40 04             	mov    0x4(%eax),%eax
 a68:	c1 e0 03             	shl    $0x3,%eax
 a6b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a71:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a74:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7a:	a3 e0 0d 00 00       	mov    %eax,0xde0
      return (void*)(p + 1);
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	83 c0 08             	add    $0x8,%eax
 a85:	eb 3b                	jmp    ac2 <malloc+0xe1>
    }
    if(p == freep)
 a87:	a1 e0 0d 00 00       	mov    0xde0,%eax
 a8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a8f:	75 1e                	jne    aaf <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a91:	83 ec 0c             	sub    $0xc,%esp
 a94:	ff 75 ec             	push   -0x14(%ebp)
 a97:	e8 e5 fe ff ff       	call   981 <morecore>
 a9c:	83 c4 10             	add    $0x10,%esp
 a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aa2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa6:	75 07                	jne    aaf <malloc+0xce>
        return 0;
 aa8:	b8 00 00 00 00       	mov    $0x0,%eax
 aad:	eb 13                	jmp    ac2 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab8:	8b 00                	mov    (%eax),%eax
 aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 abd:	e9 6d ff ff ff       	jmp    a2f <malloc+0x4e>
  }
}
 ac2:	c9                   	leave  
 ac3:	c3                   	ret    


kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc e0 65 11 80       	mov    $0x801165e0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 19 39 10 80       	mov    $0x80103919,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 3c 84 10 80       	push   $0x8010843c
80100042:	68 80 b5 10 80       	push   $0x8010b580
80100047:	e8 ef 4f 00 00       	call   8010503b <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 cc fc 10 80 7c 	movl   $0x8010fc7c,0x8010fccc
80100056:	fc 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d0 fc 10 80 7c 	movl   $0x8010fc7c,0x8010fcd0
80100060:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 b5 10 80 	movl   $0x8010b5b4,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 43 84 10 80       	push   $0x80108443
80100090:	50                   	push   %eax
80100091:	e8 22 4e 00 00       	call   80104eb8 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 7c fc 10 80       	mov    $0x8010fc7c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
  }
}
801000bd:	90                   	nop
801000be:	90                   	nop
801000bf:	c9                   	leave  
801000c0:	c3                   	ret    

801000c1 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c1:	55                   	push   %ebp
801000c2:	89 e5                	mov    %esp,%ebp
801000c4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c7:	83 ec 0c             	sub    $0xc,%esp
801000ca:	68 80 b5 10 80       	push   $0x8010b580
801000cf:	e8 89 4f 00 00       	call   8010505d <acquire>
801000d4:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d7:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801000dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000df:	eb 58                	jmp    80100139 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e4:	8b 40 04             	mov    0x4(%eax),%eax
801000e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801000ea:	75 44                	jne    80100130 <bget+0x6f>
801000ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ef:	8b 40 08             	mov    0x8(%eax),%eax
801000f2:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000f5:	75 39                	jne    80100130 <bget+0x6f>
      b->refcnt++;
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fd:	8d 50 01             	lea    0x1(%eax),%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100106:	83 ec 0c             	sub    $0xc,%esp
80100109:	68 80 b5 10 80       	push   $0x8010b580
8010010e:	e8 b8 4f 00 00       	call   801050cb <release>
80100113:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100119:	83 c0 0c             	add    $0xc,%eax
8010011c:	83 ec 0c             	sub    $0xc,%esp
8010011f:	50                   	push   %eax
80100120:	e8 cf 4d 00 00       	call   80104ef4 <acquiresleep>
80100125:	83 c4 10             	add    $0x10,%esp
      return b;
80100128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012b:	e9 9d 00 00 00       	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	8b 40 54             	mov    0x54(%eax),%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
80100140:	75 9f                	jne    801000e1 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100142:	a1 cc fc 10 80       	mov    0x8010fccc,%eax
80100147:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014a:	eb 6b                	jmp    801001b7 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014f:	8b 40 4c             	mov    0x4c(%eax),%eax
80100152:	85 c0                	test   %eax,%eax
80100154:	75 58                	jne    801001ae <bget+0xed>
80100156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100159:	8b 00                	mov    (%eax),%eax
8010015b:	83 e0 04             	and    $0x4,%eax
8010015e:	85 c0                	test   %eax,%eax
80100160:	75 4c                	jne    801001ae <bget+0xed>
      b->dev = dev;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 55 08             	mov    0x8(%ebp),%edx
80100168:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016e:	8b 55 0c             	mov    0xc(%ebp),%edx
80100171:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100177:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100180:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100187:	83 ec 0c             	sub    $0xc,%esp
8010018a:	68 80 b5 10 80       	push   $0x8010b580
8010018f:	e8 37 4f 00 00       	call   801050cb <release>
80100194:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019a:	83 c0 0c             	add    $0xc,%eax
8010019d:	83 ec 0c             	sub    $0xc,%esp
801001a0:	50                   	push   %eax
801001a1:	e8 4e 4d 00 00       	call   80104ef4 <acquiresleep>
801001a6:	83 c4 10             	add    $0x10,%esp
      return b;
801001a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ac:	eb 1f                	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	8b 40 50             	mov    0x50(%eax),%eax
801001b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b7:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
801001be:	75 8c                	jne    8010014c <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001c0:	83 ec 0c             	sub    $0xc,%esp
801001c3:	68 4a 84 10 80       	push   $0x8010844a
801001c8:	e8 e8 03 00 00       	call   801005b5 <panic>
}
801001cd:	c9                   	leave  
801001ce:	c3                   	ret    

801001cf <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001cf:	55                   	push   %ebp
801001d0:	89 e5                	mov    %esp,%ebp
801001d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d5:	83 ec 08             	sub    $0x8,%esp
801001d8:	ff 75 0c             	push   0xc(%ebp)
801001db:	ff 75 08             	push   0x8(%ebp)
801001de:	e8 de fe ff ff       	call   801000c1 <bget>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ec:	8b 00                	mov    (%eax),%eax
801001ee:	83 e0 02             	and    $0x2,%eax
801001f1:	85 c0                	test   %eax,%eax
801001f3:	75 0e                	jne    80100203 <bread+0x34>
    iderw(b);
801001f5:	83 ec 0c             	sub    $0xc,%esp
801001f8:	ff 75 f4             	push   -0xc(%ebp)
801001fb:	e8 19 28 00 00       	call   80102a19 <iderw>
80100200:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100203:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100206:	c9                   	leave  
80100207:	c3                   	ret    

80100208 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100208:	55                   	push   %ebp
80100209:	89 e5                	mov    %esp,%ebp
8010020b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	83 c0 0c             	add    $0xc,%eax
80100214:	83 ec 0c             	sub    $0xc,%esp
80100217:	50                   	push   %eax
80100218:	e8 89 4d 00 00       	call   80104fa6 <holdingsleep>
8010021d:	83 c4 10             	add    $0x10,%esp
80100220:	85 c0                	test   %eax,%eax
80100222:	75 0d                	jne    80100231 <bwrite+0x29>
    panic("bwrite");
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	68 5b 84 10 80       	push   $0x8010845b
8010022c:	e8 84 03 00 00       	call   801005b5 <panic>
  b->flags |= B_DIRTY;
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 c8 04             	or     $0x4,%eax
80100239:	89 c2                	mov    %eax,%edx
8010023b:	8b 45 08             	mov    0x8(%ebp),%eax
8010023e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	ff 75 08             	push   0x8(%ebp)
80100246:	e8 ce 27 00 00       	call   80102a19 <iderw>
8010024b:	83 c4 10             	add    $0x10,%esp
}
8010024e:	90                   	nop
8010024f:	c9                   	leave  
80100250:	c3                   	ret    

80100251 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100251:	55                   	push   %ebp
80100252:	89 e5                	mov    %esp,%ebp
80100254:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100257:	8b 45 08             	mov    0x8(%ebp),%eax
8010025a:	83 c0 0c             	add    $0xc,%eax
8010025d:	83 ec 0c             	sub    $0xc,%esp
80100260:	50                   	push   %eax
80100261:	e8 40 4d 00 00       	call   80104fa6 <holdingsleep>
80100266:	83 c4 10             	add    $0x10,%esp
80100269:	85 c0                	test   %eax,%eax
8010026b:	75 0d                	jne    8010027a <brelse+0x29>
    panic("brelse");
8010026d:	83 ec 0c             	sub    $0xc,%esp
80100270:	68 62 84 10 80       	push   $0x80108462
80100275:	e8 3b 03 00 00       	call   801005b5 <panic>

  releasesleep(&b->lock);
8010027a:	8b 45 08             	mov    0x8(%ebp),%eax
8010027d:	83 c0 0c             	add    $0xc,%eax
80100280:	83 ec 0c             	sub    $0xc,%esp
80100283:	50                   	push   %eax
80100284:	e8 cf 4c 00 00       	call   80104f58 <releasesleep>
80100289:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028c:	83 ec 0c             	sub    $0xc,%esp
8010028f:	68 80 b5 10 80       	push   $0x8010b580
80100294:	e8 c4 4d 00 00       	call   8010505d <acquire>
80100299:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a2:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b1:	85 c0                	test   %eax,%eax
801002b3:	75 47                	jne    801002fc <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b5:	8b 45 08             	mov    0x8(%ebp),%eax
801002b8:	8b 40 54             	mov    0x54(%eax),%eax
801002bb:	8b 55 08             	mov    0x8(%ebp),%edx
801002be:	8b 52 50             	mov    0x50(%edx),%edx
801002c1:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c4:	8b 45 08             	mov    0x8(%ebp),%eax
801002c7:	8b 40 50             	mov    0x50(%eax),%eax
801002ca:	8b 55 08             	mov    0x8(%ebp),%edx
801002cd:	8b 52 54             	mov    0x54(%edx),%edx
801002d0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d3:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
801002d9:	8b 45 08             	mov    0x8(%ebp),%eax
801002dc:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002df:	8b 45 08             	mov    0x8(%ebp),%eax
801002e2:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    bcache.head.next->prev = b;
801002e9:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801002ee:	8b 55 08             	mov    0x8(%ebp),%edx
801002f1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f4:	8b 45 08             	mov    0x8(%ebp),%eax
801002f7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  }
  
  release(&bcache.lock);
801002fc:	83 ec 0c             	sub    $0xc,%esp
801002ff:	68 80 b5 10 80       	push   $0x8010b580
80100304:	e8 c2 4d 00 00       	call   801050cb <release>
80100309:	83 c4 10             	add    $0x10,%esp
}
8010030c:	90                   	nop
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
80100312:	83 ec 14             	sub    $0x14,%esp
80100315:	8b 45 08             	mov    0x8(%ebp),%eax
80100318:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100320:	89 c2                	mov    %eax,%edx
80100322:	ec                   	in     (%dx),%al
80100323:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100326:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010032a:	c9                   	leave  
8010032b:	c3                   	ret    

8010032c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032c:	55                   	push   %ebp
8010032d:	89 e5                	mov    %esp,%ebp
8010032f:	83 ec 08             	sub    $0x8,%esp
80100332:	8b 45 08             	mov    0x8(%ebp),%eax
80100335:	8b 55 0c             	mov    0xc(%ebp),%edx
80100338:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010033c:	89 d0                	mov    %edx,%eax
8010033e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100341:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100345:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100349:	ee                   	out    %al,(%dx)
}
8010034a:	90                   	nop
8010034b:	c9                   	leave  
8010034c:	c3                   	ret    

8010034d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034d:	55                   	push   %ebp
8010034e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100350:	fa                   	cli    
}
80100351:	90                   	nop
80100352:	5d                   	pop    %ebp
80100353:	c3                   	ret    

80100354 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100354:	55                   	push   %ebp
80100355:	89 e5                	mov    %esp,%ebp
80100357:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010035a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035e:	74 1c                	je     8010037c <printint+0x28>
80100360:	8b 45 08             	mov    0x8(%ebp),%eax
80100363:	c1 e8 1f             	shr    $0x1f,%eax
80100366:	0f b6 c0             	movzbl %al,%eax
80100369:	89 45 10             	mov    %eax,0x10(%ebp)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 0a                	je     8010037c <printint+0x28>
    x = -xx;
80100372:	8b 45 08             	mov    0x8(%ebp),%eax
80100375:	f7 d8                	neg    %eax
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	eb 06                	jmp    80100382 <printint+0x2e>
  else
    x = xx;
8010037c:	8b 45 08             	mov    0x8(%ebp),%eax
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010038f:	ba 00 00 00 00       	mov    $0x0,%edx
80100394:	f7 f1                	div    %ecx
80100396:	89 d1                	mov    %edx,%ecx
80100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039b:	8d 50 01             	lea    0x1(%eax),%edx
8010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003a1:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
801003a8:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b2:	ba 00 00 00 00       	mov    $0x0,%edx
801003b7:	f7 f1                	div    %ecx
801003b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003c0:	75 c7                	jne    80100389 <printint+0x35>

  if(sign)
801003c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c6:	74 2a                	je     801003f2 <printint+0x9e>
    buf[i++] = '-';
801003c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003cb:	8d 50 01             	lea    0x1(%eax),%edx
801003ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003d1:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d6:	eb 1a                	jmp    801003f2 <printint+0x9e>
    consputc(buf[i]);
801003d8:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003de:	01 d0                	add    %edx,%eax
801003e0:	0f b6 00             	movzbl (%eax),%eax
801003e3:	0f be c0             	movsbl %al,%eax
801003e6:	83 ec 0c             	sub    $0xc,%esp
801003e9:	50                   	push   %eax
801003ea:	e8 f9 03 00 00       	call   801007e8 <consputc>
801003ef:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003f2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003fa:	79 dc                	jns    801003d8 <printint+0x84>
}
801003fc:	90                   	nop
801003fd:	90                   	nop
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 b4 ff 10 80       	mov    0x8010ffb4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 80 ff 10 80       	push   $0x8010ff80
8010041c:	e8 3c 4c 00 00       	call   8010505d <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 69 84 10 80       	push   $0x80108469
80100433:	e8 7d 01 00 00       	call   801005b5 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 2f 01 00 00       	jmp    80100579 <cprintf+0x179>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	push   -0x1c(%ebp)
80100456:	e8 8d 03 00 00       	call   801007e8 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 12 01 00 00       	jmp    80100575 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 14 01 00 00    	je     8010059b <cprintf+0x19b>
      break;
    switch(c){
80100487:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010048b:	74 5e                	je     801004eb <cprintf+0xeb>
8010048d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100491:	0f 8f c2 00 00 00    	jg     80100559 <cprintf+0x159>
80100497:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010049b:	74 6b                	je     80100508 <cprintf+0x108>
8010049d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004a1:	0f 8f b2 00 00 00    	jg     80100559 <cprintf+0x159>
801004a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004ab:	74 3e                	je     801004eb <cprintf+0xeb>
801004ad:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004b1:	0f 8f a2 00 00 00    	jg     80100559 <cprintf+0x159>
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 89 00 00 00    	je     8010054a <cprintf+0x14a>
801004c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004c5:	0f 85 8e 00 00 00    	jne    80100559 <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ce:	8d 50 04             	lea    0x4(%eax),%edx
801004d1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d4:	8b 00                	mov    (%eax),%eax
801004d6:	83 ec 04             	sub    $0x4,%esp
801004d9:	6a 01                	push   $0x1
801004db:	6a 0a                	push   $0xa
801004dd:	50                   	push   %eax
801004de:	e8 71 fe ff ff       	call   80100354 <printint>
801004e3:	83 c4 10             	add    $0x10,%esp
      break;
801004e6:	e9 8a 00 00 00       	jmp    80100575 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ee:	8d 50 04             	lea    0x4(%eax),%edx
801004f1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f4:	8b 00                	mov    (%eax),%eax
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	6a 00                	push   $0x0
801004fb:	6a 10                	push   $0x10
801004fd:	50                   	push   %eax
801004fe:	e8 51 fe ff ff       	call   80100354 <printint>
80100503:	83 c4 10             	add    $0x10,%esp
      break;
80100506:	eb 6d                	jmp    80100575 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
80100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010050b:	8d 50 04             	lea    0x4(%eax),%edx
8010050e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100511:	8b 00                	mov    (%eax),%eax
80100513:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100516:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010051a:	75 22                	jne    8010053e <cprintf+0x13e>
        s = "(null)";
8010051c:	c7 45 ec 72 84 10 80 	movl   $0x80108472,-0x14(%ebp)
      for(; *s; s++)
80100523:	eb 19                	jmp    8010053e <cprintf+0x13e>
        consputc(*s);
80100525:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100528:	0f b6 00             	movzbl (%eax),%eax
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	50                   	push   %eax
80100532:	e8 b1 02 00 00       	call   801007e8 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010053a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010053e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100541:	0f b6 00             	movzbl (%eax),%eax
80100544:	84 c0                	test   %al,%al
80100546:	75 dd                	jne    80100525 <cprintf+0x125>
      break;
80100548:	eb 2b                	jmp    80100575 <cprintf+0x175>
    case '%':
      consputc('%');
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	6a 25                	push   $0x25
8010054f:	e8 94 02 00 00       	call   801007e8 <consputc>
80100554:	83 c4 10             	add    $0x10,%esp
      break;
80100557:	eb 1c                	jmp    80100575 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100559:	83 ec 0c             	sub    $0xc,%esp
8010055c:	6a 25                	push   $0x25
8010055e:	e8 85 02 00 00       	call   801007e8 <consputc>
80100563:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	ff 75 e4             	push   -0x1c(%ebp)
8010056c:	e8 77 02 00 00       	call   801007e8 <consputc>
80100571:	83 c4 10             	add    $0x10,%esp
      break;
80100574:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100579:	8b 55 08             	mov    0x8(%ebp),%edx
8010057c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010057f:	01 d0                	add    %edx,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f be c0             	movsbl %al,%eax
80100587:	25 ff 00 00 00       	and    $0xff,%eax
8010058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100593:	0f 85 b1 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100599:	eb 01                	jmp    8010059c <cprintf+0x19c>
      break;
8010059b:	90                   	nop
    }
  }

  if(locking)
8010059c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005a0:	74 10                	je     801005b2 <cprintf+0x1b2>
    release(&cons.lock);
801005a2:	83 ec 0c             	sub    $0xc,%esp
801005a5:	68 80 ff 10 80       	push   $0x8010ff80
801005aa:	e8 1c 4b 00 00       	call   801050cb <release>
801005af:	83 c4 10             	add    $0x10,%esp
}
801005b2:	90                   	nop
801005b3:	c9                   	leave  
801005b4:	c3                   	ret    

801005b5 <panic>:

void
panic(char *s)
{
801005b5:	55                   	push   %ebp
801005b6:	89 e5                	mov    %esp,%ebp
801005b8:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005bb:	e8 8d fd ff ff       	call   8010034d <cli>
  cons.locking = 0;
801005c0:	c7 05 b4 ff 10 80 00 	movl   $0x0,0x8010ffb4
801005c7:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005ca:	e8 df 2a 00 00       	call   801030ae <lapicid>
801005cf:	83 ec 08             	sub    $0x8,%esp
801005d2:	50                   	push   %eax
801005d3:	68 79 84 10 80       	push   $0x80108479
801005d8:	e8 23 fe ff ff       	call   80100400 <cprintf>
801005dd:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005e0:	8b 45 08             	mov    0x8(%ebp),%eax
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	50                   	push   %eax
801005e7:	e8 14 fe ff ff       	call   80100400 <cprintf>
801005ec:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	68 8d 84 10 80       	push   $0x8010848d
801005f7:	e8 04 fe ff ff       	call   80100400 <cprintf>
801005fc:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ff:	83 ec 08             	sub    $0x8,%esp
80100602:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100605:	50                   	push   %eax
80100606:	8d 45 08             	lea    0x8(%ebp),%eax
80100609:	50                   	push   %eax
8010060a:	e8 0e 4b 00 00       	call   8010511d <getcallerpcs>
8010060f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100619:	eb 1c                	jmp    80100637 <panic+0x82>
    cprintf(" %p", pcs[i]);
8010061b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010061e:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100622:	83 ec 08             	sub    $0x8,%esp
80100625:	50                   	push   %eax
80100626:	68 8f 84 10 80       	push   $0x8010848f
8010062b:	e8 d0 fd ff ff       	call   80100400 <cprintf>
80100630:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100637:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010063b:	7e de                	jle    8010061b <panic+0x66>
  panicked = 1; // freeze other CPU
8010063d:	c7 05 6c ff 10 80 01 	movl   $0x1,0x8010ff6c
80100644:	00 00 00 
  for(;;)
80100647:	eb fe                	jmp    80100647 <panic+0x92>

80100649 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100649:	55                   	push   %ebp
8010064a:	89 e5                	mov    %esp,%ebp
8010064c:	53                   	push   %ebx
8010064d:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100650:	6a 0e                	push   $0xe
80100652:	68 d4 03 00 00       	push   $0x3d4
80100657:	e8 d0 fc ff ff       	call   8010032c <outb>
8010065c:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010065f:	68 d5 03 00 00       	push   $0x3d5
80100664:	e8 a6 fc ff ff       	call   8010030f <inb>
80100669:	83 c4 04             	add    $0x4,%esp
8010066c:	0f b6 c0             	movzbl %al,%eax
8010066f:	c1 e0 08             	shl    $0x8,%eax
80100672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100675:	6a 0f                	push   $0xf
80100677:	68 d4 03 00 00       	push   $0x3d4
8010067c:	e8 ab fc ff ff       	call   8010032c <outb>
80100681:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100684:	68 d5 03 00 00       	push   $0x3d5
80100689:	e8 81 fc ff ff       	call   8010030f <inb>
8010068e:	83 c4 04             	add    $0x4,%esp
80100691:	0f b6 c0             	movzbl %al,%eax
80100694:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100697:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010069b:	75 34                	jne    801006d1 <cgaputc+0x88>
    pos += 80 - pos%80;
8010069d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006a0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006a5:	89 c8                	mov    %ecx,%eax
801006a7:	f7 ea                	imul   %edx
801006a9:	89 d0                	mov    %edx,%eax
801006ab:	c1 f8 05             	sar    $0x5,%eax
801006ae:	89 cb                	mov    %ecx,%ebx
801006b0:	c1 fb 1f             	sar    $0x1f,%ebx
801006b3:	29 d8                	sub    %ebx,%eax
801006b5:	89 c2                	mov    %eax,%edx
801006b7:	89 d0                	mov    %edx,%eax
801006b9:	c1 e0 02             	shl    $0x2,%eax
801006bc:	01 d0                	add    %edx,%eax
801006be:	c1 e0 04             	shl    $0x4,%eax
801006c1:	29 c1                	sub    %eax,%ecx
801006c3:	89 ca                	mov    %ecx,%edx
801006c5:	b8 50 00 00 00       	mov    $0x50,%eax
801006ca:	29 d0                	sub    %edx,%eax
801006cc:	01 45 f4             	add    %eax,-0xc(%ebp)
801006cf:	eb 38                	jmp    80100709 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 0c                	jne    801006e6 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006de:	7e 29                	jle    80100709 <cgaputc+0xc0>
801006e0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006e4:	eb 23                	jmp    80100709 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	8b 45 08             	mov    0x8(%ebp),%eax
801006e9:	0f b6 c0             	movzbl %al,%eax
801006ec:	80 cc 07             	or     $0x7,%ah
801006ef:	89 c1                	mov    %eax,%ecx
801006f1:	8b 1d 00 90 10 80    	mov    0x80109000,%ebx
801006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fa:	8d 50 01             	lea    0x1(%eax),%edx
801006fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100700:	01 c0                	add    %eax,%eax
80100702:	01 d8                	add    %ebx,%eax
80100704:	89 ca                	mov    %ecx,%edx
80100706:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010070d:	78 09                	js     80100718 <cgaputc+0xcf>
8010070f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100716:	7e 0d                	jle    80100725 <cgaputc+0xdc>
    panic("pos under/overflow");
80100718:	83 ec 0c             	sub    $0xc,%esp
8010071b:	68 93 84 10 80       	push   $0x80108493
80100720:	e8 90 fe ff ff       	call   801005b5 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100725:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010072c:	7e 4d                	jle    8010077b <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010072e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100733:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100739:	a1 00 90 10 80       	mov    0x80109000,%eax
8010073e:	83 ec 04             	sub    $0x4,%esp
80100741:	68 60 0e 00 00       	push   $0xe60
80100746:	52                   	push   %edx
80100747:	50                   	push   %eax
80100748:	e8 55 4c 00 00       	call   801053a2 <memmove>
8010074d:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100750:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100754:	b8 80 07 00 00       	mov    $0x780,%eax
80100759:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010075c:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010075f:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100768:	01 c0                	add    %eax,%eax
8010076a:	01 c8                	add    %ecx,%eax
8010076c:	83 ec 04             	sub    $0x4,%esp
8010076f:	52                   	push   %edx
80100770:	6a 00                	push   $0x0
80100772:	50                   	push   %eax
80100773:	e8 6b 4b 00 00       	call   801052e3 <memset>
80100778:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010077b:	83 ec 08             	sub    $0x8,%esp
8010077e:	6a 0e                	push   $0xe
80100780:	68 d4 03 00 00       	push   $0x3d4
80100785:	e8 a2 fb ff ff       	call   8010032c <outb>
8010078a:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100790:	c1 f8 08             	sar    $0x8,%eax
80100793:	0f b6 c0             	movzbl %al,%eax
80100796:	83 ec 08             	sub    $0x8,%esp
80100799:	50                   	push   %eax
8010079a:	68 d5 03 00 00       	push   $0x3d5
8010079f:	e8 88 fb ff ff       	call   8010032c <outb>
801007a4:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007a7:	83 ec 08             	sub    $0x8,%esp
801007aa:	6a 0f                	push   $0xf
801007ac:	68 d4 03 00 00       	push   $0x3d4
801007b1:	e8 76 fb ff ff       	call   8010032c <outb>
801007b6:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007bc:	0f b6 c0             	movzbl %al,%eax
801007bf:	83 ec 08             	sub    $0x8,%esp
801007c2:	50                   	push   %eax
801007c3:	68 d5 03 00 00       	push   $0x3d5
801007c8:	e8 5f fb ff ff       	call   8010032c <outb>
801007cd:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007d0:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d9:	01 c0                	add    %eax,%eax
801007db:	01 d0                	add    %edx,%eax
801007dd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007e2:	90                   	nop
801007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007e6:	c9                   	leave  
801007e7:	c3                   	ret    

801007e8 <consputc>:

void
consputc(int c)
{
801007e8:	55                   	push   %ebp
801007e9:	89 e5                	mov    %esp,%ebp
801007eb:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007ee:	a1 6c ff 10 80       	mov    0x8010ff6c,%eax
801007f3:	85 c0                	test   %eax,%eax
801007f5:	74 07                	je     801007fe <consputc+0x16>
    cli();
801007f7:	e8 51 fb ff ff       	call   8010034d <cli>
    for(;;)
801007fc:	eb fe                	jmp    801007fc <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007fe:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100805:	75 29                	jne    80100830 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100807:	83 ec 0c             	sub    $0xc,%esp
8010080a:	6a 08                	push   $0x8
8010080c:	e8 a6 63 00 00       	call   80106bb7 <uartputc>
80100811:	83 c4 10             	add    $0x10,%esp
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	6a 20                	push   $0x20
80100819:	e8 99 63 00 00       	call   80106bb7 <uartputc>
8010081e:	83 c4 10             	add    $0x10,%esp
80100821:	83 ec 0c             	sub    $0xc,%esp
80100824:	6a 08                	push   $0x8
80100826:	e8 8c 63 00 00       	call   80106bb7 <uartputc>
8010082b:	83 c4 10             	add    $0x10,%esp
8010082e:	eb 0e                	jmp    8010083e <consputc+0x56>
  } else
    uartputc(c);
80100830:	83 ec 0c             	sub    $0xc,%esp
80100833:	ff 75 08             	push   0x8(%ebp)
80100836:	e8 7c 63 00 00       	call   80106bb7 <uartputc>
8010083b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010083e:	83 ec 0c             	sub    $0xc,%esp
80100841:	ff 75 08             	push   0x8(%ebp)
80100844:	e8 00 fe ff ff       	call   80100649 <cgaputc>
80100849:	83 c4 10             	add    $0x10,%esp
}
8010084c:	90                   	nop
8010084d:	c9                   	leave  
8010084e:	c3                   	ret    

8010084f <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010084f:	55                   	push   %ebp
80100850:	89 e5                	mov    %esp,%ebp
80100852:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010085c:	83 ec 0c             	sub    $0xc,%esp
8010085f:	68 80 ff 10 80       	push   $0x8010ff80
80100864:	e8 f4 47 00 00       	call   8010505d <acquire>
80100869:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010086c:	e9 50 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    switch(c){
80100871:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100875:	0f 84 81 00 00 00    	je     801008fc <consoleintr+0xad>
8010087b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010087f:	0f 8f ac 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100885:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100889:	74 43                	je     801008ce <consoleintr+0x7f>
8010088b:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010088f:	0f 8f 9c 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100895:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100899:	74 61                	je     801008fc <consoleintr+0xad>
8010089b:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010089f:	0f 85 8c 00 00 00    	jne    80100931 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
801008a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008ac:	e9 10 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008b6:	83 e8 01             	sub    $0x1,%eax
801008b9:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
801008be:	83 ec 0c             	sub    $0xc,%esp
801008c1:	68 00 01 00 00       	push   $0x100
801008c6:	e8 1d ff ff ff       	call   801007e8 <consputc>
801008cb:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008ce:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
801008d4:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
801008d9:	39 c2                	cmp    %eax,%edx
801008db:	0f 84 e0 00 00 00    	je     801009c1 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008e6:	83 e8 01             	sub    $0x1,%eax
801008e9:	83 e0 7f             	and    $0x7f,%eax
801008ec:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
      while(input.e != input.w &&
801008f3:	3c 0a                	cmp    $0xa,%al
801008f5:	75 ba                	jne    801008b1 <consoleintr+0x62>
      }
      break;
801008f7:	e9 c5 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fc:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
80100902:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100907:	39 c2                	cmp    %eax,%edx
80100909:	0f 84 b2 00 00 00    	je     801009c1 <consoleintr+0x172>
        input.e--;
8010090f:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100914:	83 e8 01             	sub    $0x1,%eax
80100917:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	68 00 01 00 00       	push   $0x100
80100924:	e8 bf fe ff ff       	call   801007e8 <consputc>
80100929:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010092c:	e9 90 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100935:	0f 84 85 00 00 00    	je     801009c0 <consoleintr+0x171>
8010093b:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100940:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100946:	29 d0                	sub    %edx,%eax
80100948:	83 f8 7f             	cmp    $0x7f,%eax
8010094b:	77 73                	ja     801009c0 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010094d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100951:	74 05                	je     80100958 <consoleintr+0x109>
80100953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100956:	eb 05                	jmp    8010095d <consoleintr+0x10e>
80100958:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100960:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 68 ff 10 80    	mov    %edx,0x8010ff68
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 e0 fe 10 80    	mov    %dl,-0x7fef0120(%eax)
        consputc(c);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	ff 75 f0             	push   -0x10(%ebp)
80100980:	e8 63 fe ff ff       	call   801007e8 <consputc>
80100985:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100988:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010098c:	74 18                	je     801009a6 <consoleintr+0x157>
8010098e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100992:	74 12                	je     801009a6 <consoleintr+0x157>
80100994:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100999:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x171>
          input.w = input.e;
801009a6:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801009ab:	a3 64 ff 10 80       	mov    %eax,0x8010ff64
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 60 ff 10 80       	push   $0x8010ff60
801009b8:	e8 46 43 00 00       	call   80104d03 <wakeup>
801009bd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009c0:	90                   	nop
  while((c = getc()) >= 0){
801009c1:	8b 45 08             	mov    0x8(%ebp),%eax
801009c4:	ff d0                	call   *%eax
801009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009cd:	0f 89 9e fe ff ff    	jns    80100871 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 80 ff 10 80       	push   $0x8010ff80
801009db:	e8 eb 46 00 00       	call   801050cb <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 d0 43 00 00       	call   80104dbe <procdump>
  }
}
801009ee:	90                   	nop
801009ef:	c9                   	leave  
801009f0:	c3                   	ret    

801009f1 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009f1:	55                   	push   %ebp
801009f2:	89 e5                	mov    %esp,%ebp
801009f4:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 e9 11 00 00       	call   80101beb <iunlock>
80100a02:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a05:	8b 45 10             	mov    0x10(%ebp),%eax
80100a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a0b:	83 ec 0c             	sub    $0xc,%esp
80100a0e:	68 80 ff 10 80       	push   $0x8010ff80
80100a13:	e8 45 46 00 00       	call   8010505d <acquire>
80100a18:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a1b:	e9 ab 00 00 00       	jmp    80100acb <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
80100a20:	e8 32 39 00 00       	call   80104357 <myproc>
80100a25:	8b 40 24             	mov    0x24(%eax),%eax
80100a28:	85 c0                	test   %eax,%eax
80100a2a:	74 28                	je     80100a54 <consoleread+0x63>
        release(&cons.lock);
80100a2c:	83 ec 0c             	sub    $0xc,%esp
80100a2f:	68 80 ff 10 80       	push   $0x8010ff80
80100a34:	e8 92 46 00 00       	call   801050cb <release>
80100a39:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a3c:	83 ec 0c             	sub    $0xc,%esp
80100a3f:	ff 75 08             	push   0x8(%ebp)
80100a42:	e8 91 10 00 00       	call   80101ad8 <ilock>
80100a47:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a4f:	e9 a9 00 00 00       	jmp    80100afd <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
80100a54:	83 ec 08             	sub    $0x8,%esp
80100a57:	68 80 ff 10 80       	push   $0x8010ff80
80100a5c:	68 60 ff 10 80       	push   $0x8010ff60
80100a61:	e8 b6 41 00 00       	call   80104c1c <sleep>
80100a66:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a69:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100a6f:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100a74:	39 c2                	cmp    %eax,%edx
80100a76:	74 a8                	je     80100a20 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a78:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100a7d:	8d 50 01             	lea    0x1(%eax),%edx
80100a80:	89 15 60 ff 10 80    	mov    %edx,0x8010ff60
80100a86:	83 e0 7f             	and    $0x7f,%eax
80100a89:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
80100a90:	0f be c0             	movsbl %al,%eax
80100a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a96:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a9a:	75 17                	jne    80100ab3 <consoleread+0xc2>
      if(n < target){
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100aa2:	76 2f                	jbe    80100ad3 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aa4:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100aa9:	83 e8 01             	sub    $0x1,%eax
80100aac:	a3 60 ff 10 80       	mov    %eax,0x8010ff60
      }
      break;
80100ab1:	eb 20                	jmp    80100ad3 <consoleread+0xe2>
    }
    *dst++ = c;
80100ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab6:	8d 50 01             	lea    0x1(%eax),%edx
80100ab9:	89 55 0c             	mov    %edx,0xc(%ebp)
80100abc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100abf:	88 10                	mov    %dl,(%eax)
    --n;
80100ac1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ac5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ac9:	74 0b                	je     80100ad6 <consoleread+0xe5>
  while(n > 0){
80100acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100acf:	7f 98                	jg     80100a69 <consoleread+0x78>
80100ad1:	eb 04                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad3:	90                   	nop
80100ad4:	eb 01                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad6:	90                   	nop
  }
  release(&cons.lock);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	68 80 ff 10 80       	push   $0x8010ff80
80100adf:	e8 e7 45 00 00       	call   801050cb <release>
80100ae4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ae7:	83 ec 0c             	sub    $0xc,%esp
80100aea:	ff 75 08             	push   0x8(%ebp)
80100aed:	e8 e6 0f 00 00       	call   80101ad8 <ilock>
80100af2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100af5:	8b 55 10             	mov    0x10(%ebp),%edx
80100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100afb:	29 d0                	sub    %edx,%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b05:	83 ec 0c             	sub    $0xc,%esp
80100b08:	ff 75 08             	push   0x8(%ebp)
80100b0b:	e8 db 10 00 00       	call   80101beb <iunlock>
80100b10:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	68 80 ff 10 80       	push   $0x8010ff80
80100b1b:	e8 3d 45 00 00       	call   8010505d <acquire>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b2a:	eb 21                	jmp    80100b4d <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b32:	01 d0                	add    %edx,%eax
80100b34:	0f b6 00             	movzbl (%eax),%eax
80100b37:	0f be c0             	movsbl %al,%eax
80100b3a:	0f b6 c0             	movzbl %al,%eax
80100b3d:	83 ec 0c             	sub    $0xc,%esp
80100b40:	50                   	push   %eax
80100b41:	e8 a2 fc ff ff       	call   801007e8 <consputc>
80100b46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b50:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b53:	7c d7                	jl     80100b2c <consolewrite+0x2d>
  release(&cons.lock);
80100b55:	83 ec 0c             	sub    $0xc,%esp
80100b58:	68 80 ff 10 80       	push   $0x8010ff80
80100b5d:	e8 69 45 00 00       	call   801050cb <release>
80100b62:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b65:	83 ec 0c             	sub    $0xc,%esp
80100b68:	ff 75 08             	push   0x8(%ebp)
80100b6b:	e8 68 0f 00 00       	call   80101ad8 <ilock>
80100b70:	83 c4 10             	add    $0x10,%esp

  return n;
80100b73:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consoleinit>:

void
consoleinit(void)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b7e:	83 ec 08             	sub    $0x8,%esp
80100b81:	68 a6 84 10 80       	push   $0x801084a6
80100b86:	68 80 ff 10 80       	push   $0x8010ff80
80100b8b:	e8 ab 44 00 00       	call   8010503b <initlock>
80100b90:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b93:	c7 05 cc ff 10 80 ff 	movl   $0x80100aff,0x8010ffcc
80100b9a:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b9d:	c7 05 c8 ff 10 80 f1 	movl   $0x801009f1,0x8010ffc8
80100ba4:	09 10 80 
  cons.locking = 1;
80100ba7:	c7 05 b4 ff 10 80 01 	movl   $0x1,0x8010ffb4
80100bae:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bb1:	83 ec 08             	sub    $0x8,%esp
80100bb4:	6a 00                	push   $0x0
80100bb6:	6a 01                	push   $0x1
80100bb8:	e8 25 20 00 00       	call   80102be2 <ioapicenable>
80100bbd:	83 c4 10             	add    $0x10,%esp
}
80100bc0:	90                   	nop
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    

80100bc3 <exec>:
#include "date.h"
#include "rand.h"

int
exec(char *path, char **argv)
{
80100bc3:	55                   	push   %ebp
80100bc4:	89 e5                	mov    %esp,%ebp
80100bc6:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcc:	e8 86 37 00 00       	call   80104357 <myproc>
80100bd1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  //struct vma prog_vma, stack_vma, heap_vma, shadow_vma;	
  //int prog_aslr, stack_aslr, heap_aslr, r; 	
  begin_op();
80100bd4:	e8 17 2a 00 00       	call   801035f0 <begin_op>
  // Get aslr_flag
  int aslr_flag= 0;
80100bd9:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  char c='0';
80100be0:	c6 85 e3 fe ff ff 30 	movb   $0x30,-0x11d(%ebp)
  if ((ip = namei("aslr_flag")) == 0) {
80100be7:	83 ec 0c             	sub    $0xc,%esp
80100bea:	68 b0 84 10 80       	push   $0x801084b0
80100bef:	e8 17 1a 00 00       	call   8010260b <namei>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bfa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bfe:	75 19                	jne    80100c19 <exec+0x56>
    cprintf("unable to open aslr_flag file, default to no aslr\n");
80100c00:	83 ec 0c             	sub    $0xc,%esp
80100c03:	68 bc 84 10 80       	push   $0x801084bc
80100c08:	e8 f3 f7 ff ff       	call   80100400 <cprintf>
80100c0d:	83 c4 10             	add    $0x10,%esp
    aslr_flag=0;
80100c10:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80100c17:	eb 6b                	jmp    80100c84 <exec+0xc1>
  } else {
    ilock(ip);
80100c19:	83 ec 0c             	sub    $0xc,%esp
80100c1c:	ff 75 d8             	push   -0x28(%ebp)
80100c1f:	e8 b4 0e 00 00       	call   80101ad8 <ilock>
80100c24:	83 c4 10             	add    $0x10,%esp
    if (readi(ip, &c, 0, sizeof(char)) != sizeof(char)) {
80100c27:	6a 01                	push   $0x1
80100c29:	6a 00                	push   $0x0
80100c2b:	8d 85 e3 fe ff ff    	lea    -0x11d(%ebp),%eax
80100c31:	50                   	push   %eax
80100c32:	ff 75 d8             	push   -0x28(%ebp)
80100c35:	e8 8a 13 00 00       	call   80101fc4 <readi>
80100c3a:	83 c4 10             	add    $0x10,%esp
80100c3d:	83 f8 01             	cmp    $0x1,%eax
80100c40:	74 19                	je     80100c5b <exec+0x98>
      cprintf("unable to read aslr_flag file, default to no aslr\n");
80100c42:	83 ec 0c             	sub    $0xc,%esp
80100c45:	68 f0 84 10 80       	push   $0x801084f0
80100c4a:	e8 b1 f7 ff ff       	call   80100400 <cprintf>
80100c4f:	83 c4 10             	add    $0x10,%esp
      aslr_flag=0;
80100c52:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
80100c59:	eb 1b                	jmp    80100c76 <exec+0xb3>
    } else {
      aslr_flag = (c == '1')? 1 : 0;
80100c5b:	0f b6 85 e3 fe ff ff 	movzbl -0x11d(%ebp),%eax
80100c62:	3c 31                	cmp    $0x31,%al
80100c64:	0f 94 c0             	sete   %al
80100c67:	0f b6 c0             	movzbl %al,%eax
80100c6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
      curproc->aslr_enabled=aslr_flag;
80100c6d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100c70:	8b 55 d0             	mov    -0x30(%ebp),%edx
80100c73:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    iunlockput(ip);
80100c76:	83 ec 0c             	sub    $0xc,%esp
80100c79:	ff 75 d8             	push   -0x28(%ebp)
80100c7c:	e8 88 10 00 00       	call   80101d09 <iunlockput>
80100c81:	83 c4 10             	add    $0x10,%esp
  }
  //if (DEBUG_MSG)
  cprintf("aslr_flag = %d\n", aslr_flag);
80100c84:	83 ec 08             	sub    $0x8,%esp
80100c87:	ff 75 d0             	push   -0x30(%ebp)
80100c8a:	68 23 85 10 80       	push   $0x80108523
80100c8f:	e8 6c f7 ff ff       	call   80100400 <cprintf>
80100c94:	83 c4 10             	add    $0x10,%esp
  if((ip = namei(path)) == 0){
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	ff 75 08             	push   0x8(%ebp)
80100c9d:	e8 69 19 00 00       	call   8010260b <namei>
80100ca2:	83 c4 10             	add    $0x10,%esp
80100ca5:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ca8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100cac:	75 1f                	jne    80100ccd <exec+0x10a>
    end_op();
80100cae:	e8 c9 29 00 00       	call   8010367c <end_op>
    cprintf("exec: fail\n");
80100cb3:	83 ec 0c             	sub    $0xc,%esp
80100cb6:	68 33 85 10 80       	push   $0x80108533
80100cbb:	e8 40 f7 ff ff       	call   80100400 <cprintf>
80100cc0:	83 c4 10             	add    $0x10,%esp
    return -1;
80100cc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cc8:	e9 f1 03 00 00       	jmp    801010be <exec+0x4fb>
  }
  ilock(ip);
80100ccd:	83 ec 0c             	sub    $0xc,%esp
80100cd0:	ff 75 d8             	push   -0x28(%ebp)
80100cd3:	e8 00 0e 00 00       	call   80101ad8 <ilock>
80100cd8:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100cdb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100ce2:	6a 34                	push   $0x34
80100ce4:	6a 00                	push   $0x0
80100ce6:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100cec:	50                   	push   %eax
80100ced:	ff 75 d8             	push   -0x28(%ebp)
80100cf0:	e8 cf 12 00 00       	call   80101fc4 <readi>
80100cf5:	83 c4 10             	add    $0x10,%esp
80100cf8:	83 f8 34             	cmp    $0x34,%eax
80100cfb:	0f 85 66 03 00 00    	jne    80101067 <exec+0x4a4>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100d01:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100d07:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d0c:	0f 85 58 03 00 00    	jne    8010106a <exec+0x4a7>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100d12:	e8 9c 6e 00 00       	call   80107bb3 <setupkvm>
80100d17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d1a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d1e:	0f 84 49 03 00 00    	je     8010106d <exec+0x4aa>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d24:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d2b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d32:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100d38:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d3b:	e9 de 00 00 00       	jmp    80100e1e <exec+0x25b>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d40:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d43:	6a 20                	push   $0x20
80100d45:	50                   	push   %eax
80100d46:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100d4c:	50                   	push   %eax
80100d4d:	ff 75 d8             	push   -0x28(%ebp)
80100d50:	e8 6f 12 00 00       	call   80101fc4 <readi>
80100d55:	83 c4 10             	add    $0x10,%esp
80100d58:	83 f8 20             	cmp    $0x20,%eax
80100d5b:	0f 85 0f 03 00 00    	jne    80101070 <exec+0x4ad>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d61:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d67:	83 f8 01             	cmp    $0x1,%eax
80100d6a:	0f 85 a0 00 00 00    	jne    80100e10 <exec+0x24d>
      continue;
    if(ph.memsz < ph.filesz)
80100d70:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d76:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d7c:	39 c2                	cmp    %eax,%edx
80100d7e:	0f 82 ef 02 00 00    	jb     80101073 <exec+0x4b0>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d84:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d8a:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d90:	01 c2                	add    %eax,%edx
80100d92:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d98:	39 c2                	cmp    %eax,%edx
80100d9a:	0f 82 d6 02 00 00    	jb     80101076 <exec+0x4b3>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100da0:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100da6:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100dac:	01 d0                	add    %edx,%eax
80100dae:	83 ec 04             	sub    $0x4,%esp
80100db1:	50                   	push   %eax
80100db2:	ff 75 e0             	push   -0x20(%ebp)
80100db5:	ff 75 d4             	push   -0x2c(%ebp)
80100db8:	e8 9c 71 00 00       	call   80107f59 <allocuvm>
80100dbd:	83 c4 10             	add    $0x10,%esp
80100dc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc7:	0f 84 ac 02 00 00    	je     80101079 <exec+0x4b6>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100dcd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100dd3:	25 ff 0f 00 00       	and    $0xfff,%eax
80100dd8:	85 c0                	test   %eax,%eax
80100dda:	0f 85 9c 02 00 00    	jne    8010107c <exec+0x4b9>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100de0:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100de6:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100dec:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	52                   	push   %edx
80100df6:	50                   	push   %eax
80100df7:	ff 75 d8             	push   -0x28(%ebp)
80100dfa:	51                   	push   %ecx
80100dfb:	ff 75 d4             	push   -0x2c(%ebp)
80100dfe:	e8 89 70 00 00       	call   80107e8c <loaduvm>
80100e03:	83 c4 20             	add    $0x20,%esp
80100e06:	85 c0                	test   %eax,%eax
80100e08:	0f 88 71 02 00 00    	js     8010107f <exec+0x4bc>
80100e0e:	eb 01                	jmp    80100e11 <exec+0x24e>
      continue;
80100e10:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e11:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e18:	83 c0 20             	add    $0x20,%eax
80100e1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e1e:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100e25:	0f b7 c0             	movzwl %ax,%eax
80100e28:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100e2b:	0f 8c 0f ff ff ff    	jl     80100d40 <exec+0x17d>
      goto bad;
  }
  iunlockput(ip);
80100e31:	83 ec 0c             	sub    $0xc,%esp
80100e34:	ff 75 d8             	push   -0x28(%ebp)
80100e37:	e8 cd 0e 00 00       	call   80101d09 <iunlockput>
80100e3c:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e3f:	e8 38 28 00 00       	call   8010367c <end_op>
  ip = 0;
80100e44:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e5e:	05 00 20 00 00       	add    $0x2000,%eax
80100e63:	83 ec 04             	sub    $0x4,%esp
80100e66:	50                   	push   %eax
80100e67:	ff 75 e0             	push   -0x20(%ebp)
80100e6a:	ff 75 d4             	push   -0x2c(%ebp)
80100e6d:	e8 e7 70 00 00       	call   80107f59 <allocuvm>
80100e72:	83 c4 10             	add    $0x10,%esp
80100e75:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e78:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e7c:	0f 84 00 02 00 00    	je     80101082 <exec+0x4bf>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e85:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e8a:	83 ec 08             	sub    $0x8,%esp
80100e8d:	50                   	push   %eax
80100e8e:	ff 75 d4             	push   -0x2c(%ebp)
80100e91:	e8 25 73 00 00       	call   801081bb <clearpteu>
80100e96:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  //cprintf("ffffffffffffffff\n");
  
  //cprintf("ffffffffffffffff\n");
  
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e9f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ea6:	e9 96 00 00 00       	jmp    80100f41 <exec+0x37e>
    if(argc >= MAXARG)
80100eab:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100eaf:	0f 87 d0 01 00 00    	ja     80101085 <exec+0x4c2>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100eb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec2:	01 d0                	add    %edx,%eax
80100ec4:	8b 00                	mov    (%eax),%eax
80100ec6:	83 ec 0c             	sub    $0xc,%esp
80100ec9:	50                   	push   %eax
80100eca:	e8 62 46 00 00       	call   80105531 <strlen>
80100ecf:	83 c4 10             	add    $0x10,%esp
80100ed2:	89 c2                	mov    %eax,%edx
80100ed4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed7:	29 d0                	sub    %edx,%eax
80100ed9:	83 e8 01             	sub    $0x1,%eax
80100edc:	83 e0 fc             	and    $0xfffffffc,%eax
80100edf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ee2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100eec:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eef:	01 d0                	add    %edx,%eax
80100ef1:	8b 00                	mov    (%eax),%eax
80100ef3:	83 ec 0c             	sub    $0xc,%esp
80100ef6:	50                   	push   %eax
80100ef7:	e8 35 46 00 00       	call   80105531 <strlen>
80100efc:	83 c4 10             	add    $0x10,%esp
80100eff:	83 c0 01             	add    $0x1,%eax
80100f02:	89 c2                	mov    %eax,%edx
80100f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f07:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f11:	01 c8                	add    %ecx,%eax
80100f13:	8b 00                	mov    (%eax),%eax
80100f15:	52                   	push   %edx
80100f16:	50                   	push   %eax
80100f17:	ff 75 dc             	push   -0x24(%ebp)
80100f1a:	ff 75 d4             	push   -0x2c(%ebp)
80100f1d:	e8 45 74 00 00       	call   80108367 <copyout>
80100f22:	83 c4 10             	add    $0x10,%esp
80100f25:	85 c0                	test   %eax,%eax
80100f27:	0f 88 5b 01 00 00    	js     80101088 <exec+0x4c5>
      goto bad;
    ustack[3+argc] = sp;
80100f2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f30:	8d 50 03             	lea    0x3(%eax),%edx
80100f33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f36:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100f3d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f44:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f4e:	01 d0                	add    %edx,%eax
80100f50:	8b 00                	mov    (%eax),%eax
80100f52:	85 c0                	test   %eax,%eax
80100f54:	0f 85 51 ff ff ff    	jne    80100eab <exec+0x2e8>
  }
  ustack[3+argc] = 0;
80100f5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5d:	83 c0 03             	add    $0x3,%eax
80100f60:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100f67:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f6b:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100f72:	ff ff ff 
  ustack[1] = argc;
80100f75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f78:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f81:	83 c0 01             	add    $0x1,%eax
80100f84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f8b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f8e:	29 d0                	sub    %edx,%eax
80100f90:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100f96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f99:	83 c0 04             	add    $0x4,%eax
80100f9c:	c1 e0 02             	shl    $0x2,%eax
80100f9f:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa5:	83 c0 04             	add    $0x4,%eax
80100fa8:	c1 e0 02             	shl    $0x2,%eax
80100fab:	50                   	push   %eax
80100fac:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100fb2:	50                   	push   %eax
80100fb3:	ff 75 dc             	push   -0x24(%ebp)
80100fb6:	ff 75 d4             	push   -0x2c(%ebp)
80100fb9:	e8 a9 73 00 00       	call   80108367 <copyout>
80100fbe:	83 c4 10             	add    $0x10,%esp
80100fc1:	85 c0                	test   %eax,%eax
80100fc3:	0f 88 c2 00 00 00    	js     8010108b <exec+0x4c8>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fd5:	eb 17                	jmp    80100fee <exec+0x42b>
    if(*s == '/')
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	0f b6 00             	movzbl (%eax),%eax
80100fdd:	3c 2f                	cmp    $0x2f,%al
80100fdf:	75 09                	jne    80100fea <exec+0x427>
      last = s+1;
80100fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe4:	83 c0 01             	add    $0x1,%eax
80100fe7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100fea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff1:	0f b6 00             	movzbl (%eax),%eax
80100ff4:	84 c0                	test   %al,%al
80100ff6:	75 df                	jne    80100fd7 <exec+0x414>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ff8:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100ffb:	83 c0 6c             	add    $0x6c,%eax
80100ffe:	83 ec 04             	sub    $0x4,%esp
80101001:	6a 10                	push   $0x10
80101003:	ff 75 f0             	push   -0x10(%ebp)
80101006:	50                   	push   %eax
80101007:	e8 da 44 00 00       	call   801054e6 <safestrcpy>
8010100c:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
8010100f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101012:	8b 40 04             	mov    0x4(%eax),%eax
80101015:	89 45 c8             	mov    %eax,-0x38(%ebp)
  curproc->pgdir = pgdir;
80101018:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010101b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010101e:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80101021:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101024:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101027:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101029:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010102c:	8b 40 18             	mov    0x18(%eax),%eax
8010102f:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80101035:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101038:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010103b:	8b 40 18             	mov    0x18(%eax),%eax
8010103e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101041:	89 50 44             	mov    %edx,0x44(%eax)
  
  switchuvm(curproc);
80101044:	83 ec 0c             	sub    $0xc,%esp
80101047:	ff 75 cc             	push   -0x34(%ebp)
8010104a:	e8 2e 6c 00 00       	call   80107c7d <switchuvm>
8010104f:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80101052:	83 ec 0c             	sub    $0xc,%esp
80101055:	ff 75 c8             	push   -0x38(%ebp)
80101058:	e8 c5 70 00 00       	call   80108122 <freevm>
8010105d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101060:	b8 00 00 00 00       	mov    $0x0,%eax
80101065:	eb 57                	jmp    801010be <exec+0x4fb>
    goto bad;
80101067:	90                   	nop
80101068:	eb 22                	jmp    8010108c <exec+0x4c9>
    goto bad;
8010106a:	90                   	nop
8010106b:	eb 1f                	jmp    8010108c <exec+0x4c9>
    goto bad;
8010106d:	90                   	nop
8010106e:	eb 1c                	jmp    8010108c <exec+0x4c9>
      goto bad;
80101070:	90                   	nop
80101071:	eb 19                	jmp    8010108c <exec+0x4c9>
      goto bad;
80101073:	90                   	nop
80101074:	eb 16                	jmp    8010108c <exec+0x4c9>
      goto bad;
80101076:	90                   	nop
80101077:	eb 13                	jmp    8010108c <exec+0x4c9>
      goto bad;
80101079:	90                   	nop
8010107a:	eb 10                	jmp    8010108c <exec+0x4c9>
      goto bad;
8010107c:	90                   	nop
8010107d:	eb 0d                	jmp    8010108c <exec+0x4c9>
      goto bad;
8010107f:	90                   	nop
80101080:	eb 0a                	jmp    8010108c <exec+0x4c9>
    goto bad;
80101082:	90                   	nop
80101083:	eb 07                	jmp    8010108c <exec+0x4c9>
      goto bad;
80101085:	90                   	nop
80101086:	eb 04                	jmp    8010108c <exec+0x4c9>
      goto bad;
80101088:	90                   	nop
80101089:	eb 01                	jmp    8010108c <exec+0x4c9>
    goto bad;
8010108b:	90                   	nop

 bad:
  if(pgdir)
8010108c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101090:	74 0e                	je     801010a0 <exec+0x4dd>
    freevm(pgdir);
80101092:	83 ec 0c             	sub    $0xc,%esp
80101095:	ff 75 d4             	push   -0x2c(%ebp)
80101098:	e8 85 70 00 00       	call   80108122 <freevm>
8010109d:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010a4:	74 13                	je     801010b9 <exec+0x4f6>
    iunlockput(ip);
801010a6:	83 ec 0c             	sub    $0xc,%esp
801010a9:	ff 75 d8             	push   -0x28(%ebp)
801010ac:	e8 58 0c 00 00       	call   80101d09 <iunlockput>
801010b1:	83 c4 10             	add    $0x10,%esp
    end_op();
801010b4:	e8 c3 25 00 00       	call   8010367c <end_op>
  }
  return -1;
801010b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010be:	c9                   	leave  
801010bf:	c3                   	ret    

801010c0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010c0:	55                   	push   %ebp
801010c1:	89 e5                	mov    %esp,%ebp
801010c3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010c6:	83 ec 08             	sub    $0x8,%esp
801010c9:	68 3f 85 10 80       	push   $0x8010853f
801010ce:	68 20 00 11 80       	push   $0x80110020
801010d3:	e8 63 3f 00 00       	call   8010503b <initlock>
801010d8:	83 c4 10             	add    $0x10,%esp
}
801010db:	90                   	nop
801010dc:	c9                   	leave  
801010dd:	c3                   	ret    

801010de <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010de:	55                   	push   %ebp
801010df:	89 e5                	mov    %esp,%ebp
801010e1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 20 00 11 80       	push   $0x80110020
801010ec:	e8 6c 3f 00 00       	call   8010505d <acquire>
801010f1:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010f4:	c7 45 f4 54 00 11 80 	movl   $0x80110054,-0xc(%ebp)
801010fb:	eb 2d                	jmp    8010112a <filealloc+0x4c>
    if(f->ref == 0){
801010fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101100:	8b 40 04             	mov    0x4(%eax),%eax
80101103:	85 c0                	test   %eax,%eax
80101105:	75 1f                	jne    80101126 <filealloc+0x48>
      f->ref = 1;
80101107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010110a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101111:	83 ec 0c             	sub    $0xc,%esp
80101114:	68 20 00 11 80       	push   $0x80110020
80101119:	e8 ad 3f 00 00       	call   801050cb <release>
8010111e:	83 c4 10             	add    $0x10,%esp
      return f;
80101121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101124:	eb 23                	jmp    80101149 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101126:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010112a:	b8 b4 09 11 80       	mov    $0x801109b4,%eax
8010112f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101132:	72 c9                	jb     801010fd <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101134:	83 ec 0c             	sub    $0xc,%esp
80101137:	68 20 00 11 80       	push   $0x80110020
8010113c:	e8 8a 3f 00 00       	call   801050cb <release>
80101141:	83 c4 10             	add    $0x10,%esp
  return 0;
80101144:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101149:	c9                   	leave  
8010114a:	c3                   	ret    

8010114b <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010114b:	55                   	push   %ebp
8010114c:	89 e5                	mov    %esp,%ebp
8010114e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101151:	83 ec 0c             	sub    $0xc,%esp
80101154:	68 20 00 11 80       	push   $0x80110020
80101159:	e8 ff 3e 00 00       	call   8010505d <acquire>
8010115e:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101161:	8b 45 08             	mov    0x8(%ebp),%eax
80101164:	8b 40 04             	mov    0x4(%eax),%eax
80101167:	85 c0                	test   %eax,%eax
80101169:	7f 0d                	jg     80101178 <filedup+0x2d>
    panic("filedup");
8010116b:	83 ec 0c             	sub    $0xc,%esp
8010116e:	68 46 85 10 80       	push   $0x80108546
80101173:	e8 3d f4 ff ff       	call   801005b5 <panic>
  f->ref++;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	8b 40 04             	mov    0x4(%eax),%eax
8010117e:	8d 50 01             	lea    0x1(%eax),%edx
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
80101184:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101187:	83 ec 0c             	sub    $0xc,%esp
8010118a:	68 20 00 11 80       	push   $0x80110020
8010118f:	e8 37 3f 00 00       	call   801050cb <release>
80101194:	83 c4 10             	add    $0x10,%esp
  return f;
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010119a:	c9                   	leave  
8010119b:	c3                   	ret    

8010119c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010119c:	55                   	push   %ebp
8010119d:	89 e5                	mov    %esp,%ebp
8010119f:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011a2:	83 ec 0c             	sub    $0xc,%esp
801011a5:	68 20 00 11 80       	push   $0x80110020
801011aa:	e8 ae 3e 00 00       	call   8010505d <acquire>
801011af:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011b2:	8b 45 08             	mov    0x8(%ebp),%eax
801011b5:	8b 40 04             	mov    0x4(%eax),%eax
801011b8:	85 c0                	test   %eax,%eax
801011ba:	7f 0d                	jg     801011c9 <fileclose+0x2d>
    panic("fileclose");
801011bc:	83 ec 0c             	sub    $0xc,%esp
801011bf:	68 4e 85 10 80       	push   $0x8010854e
801011c4:	e8 ec f3 ff ff       	call   801005b5 <panic>
  if(--f->ref > 0){
801011c9:	8b 45 08             	mov    0x8(%ebp),%eax
801011cc:	8b 40 04             	mov    0x4(%eax),%eax
801011cf:	8d 50 ff             	lea    -0x1(%eax),%edx
801011d2:	8b 45 08             	mov    0x8(%ebp),%eax
801011d5:	89 50 04             	mov    %edx,0x4(%eax)
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 40 04             	mov    0x4(%eax),%eax
801011de:	85 c0                	test   %eax,%eax
801011e0:	7e 15                	jle    801011f7 <fileclose+0x5b>
    release(&ftable.lock);
801011e2:	83 ec 0c             	sub    $0xc,%esp
801011e5:	68 20 00 11 80       	push   $0x80110020
801011ea:	e8 dc 3e 00 00       	call   801050cb <release>
801011ef:	83 c4 10             	add    $0x10,%esp
801011f2:	e9 8b 00 00 00       	jmp    80101282 <fileclose+0xe6>
    return;
  }
  ff = *f;
801011f7:	8b 45 08             	mov    0x8(%ebp),%eax
801011fa:	8b 10                	mov    (%eax),%edx
801011fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011ff:	8b 50 04             	mov    0x4(%eax),%edx
80101202:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101205:	8b 50 08             	mov    0x8(%eax),%edx
80101208:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010120b:	8b 50 0c             	mov    0xc(%eax),%edx
8010120e:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101211:	8b 50 10             	mov    0x10(%eax),%edx
80101214:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101217:	8b 40 14             	mov    0x14(%eax),%eax
8010121a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010121d:	8b 45 08             	mov    0x8(%ebp),%eax
80101220:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101227:	8b 45 08             	mov    0x8(%ebp),%eax
8010122a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101230:	83 ec 0c             	sub    $0xc,%esp
80101233:	68 20 00 11 80       	push   $0x80110020
80101238:	e8 8e 3e 00 00       	call   801050cb <release>
8010123d:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101240:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101243:	83 f8 01             	cmp    $0x1,%eax
80101246:	75 19                	jne    80101261 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101248:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010124c:	0f be d0             	movsbl %al,%edx
8010124f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101252:	83 ec 08             	sub    $0x8,%esp
80101255:	52                   	push   %edx
80101256:	50                   	push   %eax
80101257:	e8 8a 2d 00 00       	call   80103fe6 <pipeclose>
8010125c:	83 c4 10             	add    $0x10,%esp
8010125f:	eb 21                	jmp    80101282 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101264:	83 f8 02             	cmp    $0x2,%eax
80101267:	75 19                	jne    80101282 <fileclose+0xe6>
    begin_op();
80101269:	e8 82 23 00 00       	call   801035f0 <begin_op>
    iput(ff.ip);
8010126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101271:	83 ec 0c             	sub    $0xc,%esp
80101274:	50                   	push   %eax
80101275:	e8 bf 09 00 00       	call   80101c39 <iput>
8010127a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010127d:	e8 fa 23 00 00       	call   8010367c <end_op>
  }
}
80101282:	c9                   	leave  
80101283:	c3                   	ret    

80101284 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101284:	55                   	push   %ebp
80101285:	89 e5                	mov    %esp,%ebp
80101287:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 00                	mov    (%eax),%eax
8010128f:	83 f8 02             	cmp    $0x2,%eax
80101292:	75 40                	jne    801012d4 <filestat+0x50>
    ilock(f->ip);
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	8b 40 10             	mov    0x10(%eax),%eax
8010129a:	83 ec 0c             	sub    $0xc,%esp
8010129d:	50                   	push   %eax
8010129e:	e8 35 08 00 00       	call   80101ad8 <ilock>
801012a3:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012a6:	8b 45 08             	mov    0x8(%ebp),%eax
801012a9:	8b 40 10             	mov    0x10(%eax),%eax
801012ac:	83 ec 08             	sub    $0x8,%esp
801012af:	ff 75 0c             	push   0xc(%ebp)
801012b2:	50                   	push   %eax
801012b3:	e8 c6 0c 00 00       	call   80101f7e <stati>
801012b8:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012bb:	8b 45 08             	mov    0x8(%ebp),%eax
801012be:	8b 40 10             	mov    0x10(%eax),%eax
801012c1:	83 ec 0c             	sub    $0xc,%esp
801012c4:	50                   	push   %eax
801012c5:	e8 21 09 00 00       	call   80101beb <iunlock>
801012ca:	83 c4 10             	add    $0x10,%esp
    return 0;
801012cd:	b8 00 00 00 00       	mov    $0x0,%eax
801012d2:	eb 05                	jmp    801012d9 <filestat+0x55>
  }
  return -1;
801012d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012d9:	c9                   	leave  
801012da:	c3                   	ret    

801012db <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012db:	55                   	push   %ebp
801012dc:	89 e5                	mov    %esp,%ebp
801012de:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012e1:	8b 45 08             	mov    0x8(%ebp),%eax
801012e4:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801012e8:	84 c0                	test   %al,%al
801012ea:	75 0a                	jne    801012f6 <fileread+0x1b>
    return -1;
801012ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f1:	e9 9b 00 00 00       	jmp    80101391 <fileread+0xb6>
  if(f->type == FD_PIPE)
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	8b 00                	mov    (%eax),%eax
801012fb:	83 f8 01             	cmp    $0x1,%eax
801012fe:	75 1a                	jne    8010131a <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	8b 40 0c             	mov    0xc(%eax),%eax
80101306:	83 ec 04             	sub    $0x4,%esp
80101309:	ff 75 10             	push   0x10(%ebp)
8010130c:	ff 75 0c             	push   0xc(%ebp)
8010130f:	50                   	push   %eax
80101310:	e8 7e 2e 00 00       	call   80104193 <piperead>
80101315:	83 c4 10             	add    $0x10,%esp
80101318:	eb 77                	jmp    80101391 <fileread+0xb6>
  if(f->type == FD_INODE){
8010131a:	8b 45 08             	mov    0x8(%ebp),%eax
8010131d:	8b 00                	mov    (%eax),%eax
8010131f:	83 f8 02             	cmp    $0x2,%eax
80101322:	75 60                	jne    80101384 <fileread+0xa9>
    ilock(f->ip);
80101324:	8b 45 08             	mov    0x8(%ebp),%eax
80101327:	8b 40 10             	mov    0x10(%eax),%eax
8010132a:	83 ec 0c             	sub    $0xc,%esp
8010132d:	50                   	push   %eax
8010132e:	e8 a5 07 00 00       	call   80101ad8 <ilock>
80101333:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101336:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101339:	8b 45 08             	mov    0x8(%ebp),%eax
8010133c:	8b 50 14             	mov    0x14(%eax),%edx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	ff 75 0c             	push   0xc(%ebp)
8010134a:	50                   	push   %eax
8010134b:	e8 74 0c 00 00       	call   80101fc4 <readi>
80101350:	83 c4 10             	add    $0x10,%esp
80101353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101356:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010135a:	7e 11                	jle    8010136d <fileread+0x92>
      f->off += r;
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	8b 50 14             	mov    0x14(%eax),%edx
80101362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101365:	01 c2                	add    %eax,%edx
80101367:	8b 45 08             	mov    0x8(%ebp),%eax
8010136a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010136d:	8b 45 08             	mov    0x8(%ebp),%eax
80101370:	8b 40 10             	mov    0x10(%eax),%eax
80101373:	83 ec 0c             	sub    $0xc,%esp
80101376:	50                   	push   %eax
80101377:	e8 6f 08 00 00       	call   80101beb <iunlock>
8010137c:	83 c4 10             	add    $0x10,%esp
    return r;
8010137f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101382:	eb 0d                	jmp    80101391 <fileread+0xb6>
  }
  panic("fileread");
80101384:	83 ec 0c             	sub    $0xc,%esp
80101387:	68 58 85 10 80       	push   $0x80108558
8010138c:	e8 24 f2 ff ff       	call   801005b5 <panic>
}
80101391:	c9                   	leave  
80101392:	c3                   	ret    

80101393 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101393:	55                   	push   %ebp
80101394:	89 e5                	mov    %esp,%ebp
80101396:	53                   	push   %ebx
80101397:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010139a:	8b 45 08             	mov    0x8(%ebp),%eax
8010139d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013a1:	84 c0                	test   %al,%al
801013a3:	75 0a                	jne    801013af <filewrite+0x1c>
    return -1;
801013a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013aa:	e9 1b 01 00 00       	jmp    801014ca <filewrite+0x137>
  if(f->type == FD_PIPE)
801013af:	8b 45 08             	mov    0x8(%ebp),%eax
801013b2:	8b 00                	mov    (%eax),%eax
801013b4:	83 f8 01             	cmp    $0x1,%eax
801013b7:	75 1d                	jne    801013d6 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	8b 40 0c             	mov    0xc(%eax),%eax
801013bf:	83 ec 04             	sub    $0x4,%esp
801013c2:	ff 75 10             	push   0x10(%ebp)
801013c5:	ff 75 0c             	push   0xc(%ebp)
801013c8:	50                   	push   %eax
801013c9:	e8 c3 2c 00 00       	call   80104091 <pipewrite>
801013ce:	83 c4 10             	add    $0x10,%esp
801013d1:	e9 f4 00 00 00       	jmp    801014ca <filewrite+0x137>
  if(f->type == FD_INODE){
801013d6:	8b 45 08             	mov    0x8(%ebp),%eax
801013d9:	8b 00                	mov    (%eax),%eax
801013db:	83 f8 02             	cmp    $0x2,%eax
801013de:	0f 85 d9 00 00 00    	jne    801014bd <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801013e4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801013eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013f2:	e9 a3 00 00 00       	jmp    8010149a <filewrite+0x107>
      int n1 = n - i;
801013f7:	8b 45 10             	mov    0x10(%ebp),%eax
801013fa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101403:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101406:	7e 06                	jle    8010140e <filewrite+0x7b>
        n1 = max;
80101408:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010140b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010140e:	e8 dd 21 00 00       	call   801035f0 <begin_op>
      ilock(f->ip);
80101413:	8b 45 08             	mov    0x8(%ebp),%eax
80101416:	8b 40 10             	mov    0x10(%eax),%eax
80101419:	83 ec 0c             	sub    $0xc,%esp
8010141c:	50                   	push   %eax
8010141d:	e8 b6 06 00 00       	call   80101ad8 <ilock>
80101422:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101425:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101428:	8b 45 08             	mov    0x8(%ebp),%eax
8010142b:	8b 50 14             	mov    0x14(%eax),%edx
8010142e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101431:	8b 45 0c             	mov    0xc(%ebp),%eax
80101434:	01 c3                	add    %eax,%ebx
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	8b 40 10             	mov    0x10(%eax),%eax
8010143c:	51                   	push   %ecx
8010143d:	52                   	push   %edx
8010143e:	53                   	push   %ebx
8010143f:	50                   	push   %eax
80101440:	e8 d4 0c 00 00       	call   80102119 <writei>
80101445:	83 c4 10             	add    $0x10,%esp
80101448:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010144b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010144f:	7e 11                	jle    80101462 <filewrite+0xcf>
        f->off += r;
80101451:	8b 45 08             	mov    0x8(%ebp),%eax
80101454:	8b 50 14             	mov    0x14(%eax),%edx
80101457:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010145a:	01 c2                	add    %eax,%edx
8010145c:	8b 45 08             	mov    0x8(%ebp),%eax
8010145f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101462:	8b 45 08             	mov    0x8(%ebp),%eax
80101465:	8b 40 10             	mov    0x10(%eax),%eax
80101468:	83 ec 0c             	sub    $0xc,%esp
8010146b:	50                   	push   %eax
8010146c:	e8 7a 07 00 00       	call   80101beb <iunlock>
80101471:	83 c4 10             	add    $0x10,%esp
      end_op();
80101474:	e8 03 22 00 00       	call   8010367c <end_op>

      if(r < 0)
80101479:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010147d:	78 29                	js     801014a8 <filewrite+0x115>
        break;
      if(r != n1)
8010147f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101482:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101485:	74 0d                	je     80101494 <filewrite+0x101>
        panic("short filewrite");
80101487:	83 ec 0c             	sub    $0xc,%esp
8010148a:	68 61 85 10 80       	push   $0x80108561
8010148f:	e8 21 f1 ff ff       	call   801005b5 <panic>
      i += r;
80101494:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101497:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149d:	3b 45 10             	cmp    0x10(%ebp),%eax
801014a0:	0f 8c 51 ff ff ff    	jl     801013f7 <filewrite+0x64>
801014a6:	eb 01                	jmp    801014a9 <filewrite+0x116>
        break;
801014a8:	90                   	nop
    }
    return i == n ? n : -1;
801014a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801014af:	75 05                	jne    801014b6 <filewrite+0x123>
801014b1:	8b 45 10             	mov    0x10(%ebp),%eax
801014b4:	eb 14                	jmp    801014ca <filewrite+0x137>
801014b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014bb:	eb 0d                	jmp    801014ca <filewrite+0x137>
  }
  panic("filewrite");
801014bd:	83 ec 0c             	sub    $0xc,%esp
801014c0:	68 71 85 10 80       	push   $0x80108571
801014c5:	e8 eb f0 ff ff       	call   801005b5 <panic>
}
801014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014cd:	c9                   	leave  
801014ce:	c3                   	ret    

801014cf <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014cf:	55                   	push   %ebp
801014d0:	89 e5                	mov    %esp,%ebp
801014d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014d5:	8b 45 08             	mov    0x8(%ebp),%eax
801014d8:	83 ec 08             	sub    $0x8,%esp
801014db:	6a 01                	push   $0x1
801014dd:	50                   	push   %eax
801014de:	e8 ec ec ff ff       	call   801001cf <bread>
801014e3:	83 c4 10             	add    $0x10,%esp
801014e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ec:	83 c0 5c             	add    $0x5c,%eax
801014ef:	83 ec 04             	sub    $0x4,%esp
801014f2:	6a 1c                	push   $0x1c
801014f4:	50                   	push   %eax
801014f5:	ff 75 0c             	push   0xc(%ebp)
801014f8:	e8 a5 3e 00 00       	call   801053a2 <memmove>
801014fd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101500:	83 ec 0c             	sub    $0xc,%esp
80101503:	ff 75 f4             	push   -0xc(%ebp)
80101506:	e8 46 ed ff ff       	call   80100251 <brelse>
8010150b:	83 c4 10             	add    $0x10,%esp
}
8010150e:	90                   	nop
8010150f:	c9                   	leave  
80101510:	c3                   	ret    

80101511 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101511:	55                   	push   %ebp
80101512:	89 e5                	mov    %esp,%ebp
80101514:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101517:	8b 55 0c             	mov    0xc(%ebp),%edx
8010151a:	8b 45 08             	mov    0x8(%ebp),%eax
8010151d:	83 ec 08             	sub    $0x8,%esp
80101520:	52                   	push   %edx
80101521:	50                   	push   %eax
80101522:	e8 a8 ec ff ff       	call   801001cf <bread>
80101527:	83 c4 10             	add    $0x10,%esp
8010152a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010152d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101530:	83 c0 5c             	add    $0x5c,%eax
80101533:	83 ec 04             	sub    $0x4,%esp
80101536:	68 00 02 00 00       	push   $0x200
8010153b:	6a 00                	push   $0x0
8010153d:	50                   	push   %eax
8010153e:	e8 a0 3d 00 00       	call   801052e3 <memset>
80101543:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101546:	83 ec 0c             	sub    $0xc,%esp
80101549:	ff 75 f4             	push   -0xc(%ebp)
8010154c:	e8 d8 22 00 00       	call   80103829 <log_write>
80101551:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101554:	83 ec 0c             	sub    $0xc,%esp
80101557:	ff 75 f4             	push   -0xc(%ebp)
8010155a:	e8 f2 ec ff ff       	call   80100251 <brelse>
8010155f:	83 c4 10             	add    $0x10,%esp
}
80101562:	90                   	nop
80101563:	c9                   	leave  
80101564:	c3                   	ret    

80101565 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101565:	55                   	push   %ebp
80101566:	89 e5                	mov    %esp,%ebp
80101568:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010156b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101572:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101579:	e9 0b 01 00 00       	jmp    80101689 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010157e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101581:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101587:	85 c0                	test   %eax,%eax
80101589:	0f 48 c2             	cmovs  %edx,%eax
8010158c:	c1 f8 0c             	sar    $0xc,%eax
8010158f:	89 c2                	mov    %eax,%edx
80101591:	a1 d8 09 11 80       	mov    0x801109d8,%eax
80101596:	01 d0                	add    %edx,%eax
80101598:	83 ec 08             	sub    $0x8,%esp
8010159b:	50                   	push   %eax
8010159c:	ff 75 08             	push   0x8(%ebp)
8010159f:	e8 2b ec ff ff       	call   801001cf <bread>
801015a4:	83 c4 10             	add    $0x10,%esp
801015a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015b1:	e9 9e 00 00 00       	jmp    80101654 <balloc+0xef>
      m = 1 << (bi % 8);
801015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b9:	83 e0 07             	and    $0x7,%eax
801015bc:	ba 01 00 00 00       	mov    $0x1,%edx
801015c1:	89 c1                	mov    %eax,%ecx
801015c3:	d3 e2                	shl    %cl,%edx
801015c5:	89 d0                	mov    %edx,%eax
801015c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cd:	8d 50 07             	lea    0x7(%eax),%edx
801015d0:	85 c0                	test   %eax,%eax
801015d2:	0f 48 c2             	cmovs  %edx,%eax
801015d5:	c1 f8 03             	sar    $0x3,%eax
801015d8:	89 c2                	mov    %eax,%edx
801015da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015dd:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015e2:	0f b6 c0             	movzbl %al,%eax
801015e5:	23 45 e8             	and    -0x18(%ebp),%eax
801015e8:	85 c0                	test   %eax,%eax
801015ea:	75 64                	jne    80101650 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ef:	8d 50 07             	lea    0x7(%eax),%edx
801015f2:	85 c0                	test   %eax,%eax
801015f4:	0f 48 c2             	cmovs  %edx,%eax
801015f7:	c1 f8 03             	sar    $0x3,%eax
801015fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015fd:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101602:	89 d1                	mov    %edx,%ecx
80101604:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101607:	09 ca                	or     %ecx,%edx
80101609:	89 d1                	mov    %edx,%ecx
8010160b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010160e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101612:	83 ec 0c             	sub    $0xc,%esp
80101615:	ff 75 ec             	push   -0x14(%ebp)
80101618:	e8 0c 22 00 00       	call   80103829 <log_write>
8010161d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101620:	83 ec 0c             	sub    $0xc,%esp
80101623:	ff 75 ec             	push   -0x14(%ebp)
80101626:	e8 26 ec ff ff       	call   80100251 <brelse>
8010162b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010162e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	01 c2                	add    %eax,%edx
80101636:	8b 45 08             	mov    0x8(%ebp),%eax
80101639:	83 ec 08             	sub    $0x8,%esp
8010163c:	52                   	push   %edx
8010163d:	50                   	push   %eax
8010163e:	e8 ce fe ff ff       	call   80101511 <bzero>
80101643:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101646:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164c:	01 d0                	add    %edx,%eax
8010164e:	eb 57                	jmp    801016a7 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101650:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101654:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010165b:	7f 17                	jg     80101674 <balloc+0x10f>
8010165d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101663:	01 d0                	add    %edx,%eax
80101665:	89 c2                	mov    %eax,%edx
80101667:	a1 c0 09 11 80       	mov    0x801109c0,%eax
8010166c:	39 c2                	cmp    %eax,%edx
8010166e:	0f 82 42 ff ff ff    	jb     801015b6 <balloc+0x51>
      }
    }
    brelse(bp);
80101674:	83 ec 0c             	sub    $0xc,%esp
80101677:	ff 75 ec             	push   -0x14(%ebp)
8010167a:	e8 d2 eb ff ff       	call   80100251 <brelse>
8010167f:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101682:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101689:	8b 15 c0 09 11 80    	mov    0x801109c0,%edx
8010168f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101692:	39 c2                	cmp    %eax,%edx
80101694:	0f 87 e4 fe ff ff    	ja     8010157e <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010169a:	83 ec 0c             	sub    $0xc,%esp
8010169d:	68 7c 85 10 80       	push   $0x8010857c
801016a2:	e8 0e ef ff ff       	call   801005b5 <panic>
}
801016a7:	c9                   	leave  
801016a8:	c3                   	ret    

801016a9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016a9:	55                   	push   %ebp
801016aa:	89 e5                	mov    %esp,%ebp
801016ac:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801016af:	8b 45 0c             	mov    0xc(%ebp),%eax
801016b2:	c1 e8 0c             	shr    $0xc,%eax
801016b5:	89 c2                	mov    %eax,%edx
801016b7:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801016bc:	01 c2                	add    %eax,%edx
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	83 ec 08             	sub    $0x8,%esp
801016c4:	52                   	push   %edx
801016c5:	50                   	push   %eax
801016c6:	e8 04 eb ff ff       	call   801001cf <bread>
801016cb:	83 c4 10             	add    $0x10,%esp
801016ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801016d4:	25 ff 0f 00 00       	and    $0xfff,%eax
801016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016df:	83 e0 07             	and    $0x7,%eax
801016e2:	ba 01 00 00 00       	mov    $0x1,%edx
801016e7:	89 c1                	mov    %eax,%ecx
801016e9:	d3 e2                	shl    %cl,%edx
801016eb:	89 d0                	mov    %edx,%eax
801016ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	8d 50 07             	lea    0x7(%eax),%edx
801016f6:	85 c0                	test   %eax,%eax
801016f8:	0f 48 c2             	cmovs  %edx,%eax
801016fb:	c1 f8 03             	sar    $0x3,%eax
801016fe:	89 c2                	mov    %eax,%edx
80101700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101703:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101708:	0f b6 c0             	movzbl %al,%eax
8010170b:	23 45 ec             	and    -0x14(%ebp),%eax
8010170e:	85 c0                	test   %eax,%eax
80101710:	75 0d                	jne    8010171f <bfree+0x76>
    panic("freeing free block");
80101712:	83 ec 0c             	sub    $0xc,%esp
80101715:	68 92 85 10 80       	push   $0x80108592
8010171a:	e8 96 ee ff ff       	call   801005b5 <panic>
  bp->data[bi/8] &= ~m;
8010171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101722:	8d 50 07             	lea    0x7(%eax),%edx
80101725:	85 c0                	test   %eax,%eax
80101727:	0f 48 c2             	cmovs  %edx,%eax
8010172a:	c1 f8 03             	sar    $0x3,%eax
8010172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101730:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101735:	89 d1                	mov    %edx,%ecx
80101737:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010173a:	f7 d2                	not    %edx
8010173c:	21 ca                	and    %ecx,%edx
8010173e:	89 d1                	mov    %edx,%ecx
80101740:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101743:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101747:	83 ec 0c             	sub    $0xc,%esp
8010174a:	ff 75 f4             	push   -0xc(%ebp)
8010174d:	e8 d7 20 00 00       	call   80103829 <log_write>
80101752:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101755:	83 ec 0c             	sub    $0xc,%esp
80101758:	ff 75 f4             	push   -0xc(%ebp)
8010175b:	e8 f1 ea ff ff       	call   80100251 <brelse>
80101760:	83 c4 10             	add    $0x10,%esp
}
80101763:	90                   	nop
80101764:	c9                   	leave  
80101765:	c3                   	ret    

80101766 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101766:	55                   	push   %ebp
80101767:	89 e5                	mov    %esp,%ebp
80101769:	57                   	push   %edi
8010176a:	56                   	push   %esi
8010176b:	53                   	push   %ebx
8010176c:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010176f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101776:	83 ec 08             	sub    $0x8,%esp
80101779:	68 a5 85 10 80       	push   $0x801085a5
8010177e:	68 e0 09 11 80       	push   $0x801109e0
80101783:	e8 b3 38 00 00       	call   8010503b <initlock>
80101788:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010178b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101792:	eb 2d                	jmp    801017c1 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
80101794:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101797:	89 d0                	mov    %edx,%eax
80101799:	c1 e0 03             	shl    $0x3,%eax
8010179c:	01 d0                	add    %edx,%eax
8010179e:	c1 e0 04             	shl    $0x4,%eax
801017a1:	83 c0 30             	add    $0x30,%eax
801017a4:	05 e0 09 11 80       	add    $0x801109e0,%eax
801017a9:	83 c0 10             	add    $0x10,%eax
801017ac:	83 ec 08             	sub    $0x8,%esp
801017af:	68 ac 85 10 80       	push   $0x801085ac
801017b4:	50                   	push   %eax
801017b5:	e8 fe 36 00 00       	call   80104eb8 <initsleeplock>
801017ba:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017bd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017c1:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017c5:	7e cd                	jle    80101794 <iinit+0x2e>
  }

  readsb(dev, &sb);
801017c7:	83 ec 08             	sub    $0x8,%esp
801017ca:	68 c0 09 11 80       	push   $0x801109c0
801017cf:	ff 75 08             	push   0x8(%ebp)
801017d2:	e8 f8 fc ff ff       	call   801014cf <readsb>
801017d7:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017da:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801017df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017e2:	8b 3d d4 09 11 80    	mov    0x801109d4,%edi
801017e8:	8b 35 d0 09 11 80    	mov    0x801109d0,%esi
801017ee:	8b 1d cc 09 11 80    	mov    0x801109cc,%ebx
801017f4:	8b 0d c8 09 11 80    	mov    0x801109c8,%ecx
801017fa:	8b 15 c4 09 11 80    	mov    0x801109c4,%edx
80101800:	a1 c0 09 11 80       	mov    0x801109c0,%eax
80101805:	ff 75 d4             	push   -0x2c(%ebp)
80101808:	57                   	push   %edi
80101809:	56                   	push   %esi
8010180a:	53                   	push   %ebx
8010180b:	51                   	push   %ecx
8010180c:	52                   	push   %edx
8010180d:	50                   	push   %eax
8010180e:	68 b4 85 10 80       	push   $0x801085b4
80101813:	e8 e8 eb ff ff       	call   80100400 <cprintf>
80101818:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010181b:	90                   	nop
8010181c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010181f:	5b                   	pop    %ebx
80101820:	5e                   	pop    %esi
80101821:	5f                   	pop    %edi
80101822:	5d                   	pop    %ebp
80101823:	c3                   	ret    

80101824 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101824:	55                   	push   %ebp
80101825:	89 e5                	mov    %esp,%ebp
80101827:	83 ec 28             	sub    $0x28,%esp
8010182a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010182d:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101831:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101838:	e9 9e 00 00 00       	jmp    801018db <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101840:	c1 e8 03             	shr    $0x3,%eax
80101843:	89 c2                	mov    %eax,%edx
80101845:	a1 d4 09 11 80       	mov    0x801109d4,%eax
8010184a:	01 d0                	add    %edx,%eax
8010184c:	83 ec 08             	sub    $0x8,%esp
8010184f:	50                   	push   %eax
80101850:	ff 75 08             	push   0x8(%ebp)
80101853:	e8 77 e9 ff ff       	call   801001cf <bread>
80101858:	83 c4 10             	add    $0x10,%esp
8010185b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010185e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101861:	8d 50 5c             	lea    0x5c(%eax),%edx
80101864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101867:	83 e0 07             	and    $0x7,%eax
8010186a:	c1 e0 06             	shl    $0x6,%eax
8010186d:	01 d0                	add    %edx,%eax
8010186f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101872:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101875:	0f b7 00             	movzwl (%eax),%eax
80101878:	66 85 c0             	test   %ax,%ax
8010187b:	75 4c                	jne    801018c9 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010187d:	83 ec 04             	sub    $0x4,%esp
80101880:	6a 40                	push   $0x40
80101882:	6a 00                	push   $0x0
80101884:	ff 75 ec             	push   -0x14(%ebp)
80101887:	e8 57 3a 00 00       	call   801052e3 <memset>
8010188c:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010188f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101892:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101896:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101899:	83 ec 0c             	sub    $0xc,%esp
8010189c:	ff 75 f0             	push   -0x10(%ebp)
8010189f:	e8 85 1f 00 00       	call   80103829 <log_write>
801018a4:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018a7:	83 ec 0c             	sub    $0xc,%esp
801018aa:	ff 75 f0             	push   -0x10(%ebp)
801018ad:	e8 9f e9 ff ff       	call   80100251 <brelse>
801018b2:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	83 ec 08             	sub    $0x8,%esp
801018bb:	50                   	push   %eax
801018bc:	ff 75 08             	push   0x8(%ebp)
801018bf:	e8 f8 00 00 00       	call   801019bc <iget>
801018c4:	83 c4 10             	add    $0x10,%esp
801018c7:	eb 30                	jmp    801018f9 <ialloc+0xd5>
    }
    brelse(bp);
801018c9:	83 ec 0c             	sub    $0xc,%esp
801018cc:	ff 75 f0             	push   -0x10(%ebp)
801018cf:	e8 7d e9 ff ff       	call   80100251 <brelse>
801018d4:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018db:	8b 15 c8 09 11 80    	mov    0x801109c8,%edx
801018e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e4:	39 c2                	cmp    %eax,%edx
801018e6:	0f 87 51 ff ff ff    	ja     8010183d <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801018ec:	83 ec 0c             	sub    $0xc,%esp
801018ef:	68 07 86 10 80       	push   $0x80108607
801018f4:	e8 bc ec ff ff       	call   801005b5 <panic>
}
801018f9:	c9                   	leave  
801018fa:	c3                   	ret    

801018fb <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018fb:	55                   	push   %ebp
801018fc:	89 e5                	mov    %esp,%ebp
801018fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101901:	8b 45 08             	mov    0x8(%ebp),%eax
80101904:	8b 40 04             	mov    0x4(%eax),%eax
80101907:	c1 e8 03             	shr    $0x3,%eax
8010190a:	89 c2                	mov    %eax,%edx
8010190c:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101911:	01 c2                	add    %eax,%edx
80101913:	8b 45 08             	mov    0x8(%ebp),%eax
80101916:	8b 00                	mov    (%eax),%eax
80101918:	83 ec 08             	sub    $0x8,%esp
8010191b:	52                   	push   %edx
8010191c:	50                   	push   %eax
8010191d:	e8 ad e8 ff ff       	call   801001cf <bread>
80101922:	83 c4 10             	add    $0x10,%esp
80101925:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010192e:	8b 45 08             	mov    0x8(%ebp),%eax
80101931:	8b 40 04             	mov    0x4(%eax),%eax
80101934:	83 e0 07             	and    $0x7,%eax
80101937:	c1 e0 06             	shl    $0x6,%eax
8010193a:	01 d0                	add    %edx,%eax
8010193c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101949:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101964:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101972:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101976:	8b 45 08             	mov    0x8(%ebp),%eax
80101979:	8b 50 58             	mov    0x58(%eax),%edx
8010197c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197f:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101982:	8b 45 08             	mov    0x8(%ebp),%eax
80101985:	8d 50 5c             	lea    0x5c(%eax),%edx
80101988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198b:	83 c0 0c             	add    $0xc,%eax
8010198e:	83 ec 04             	sub    $0x4,%esp
80101991:	6a 34                	push   $0x34
80101993:	52                   	push   %edx
80101994:	50                   	push   %eax
80101995:	e8 08 3a 00 00       	call   801053a2 <memmove>
8010199a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010199d:	83 ec 0c             	sub    $0xc,%esp
801019a0:	ff 75 f4             	push   -0xc(%ebp)
801019a3:	e8 81 1e 00 00       	call   80103829 <log_write>
801019a8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019ab:	83 ec 0c             	sub    $0xc,%esp
801019ae:	ff 75 f4             	push   -0xc(%ebp)
801019b1:	e8 9b e8 ff ff       	call   80100251 <brelse>
801019b6:	83 c4 10             	add    $0x10,%esp
}
801019b9:	90                   	nop
801019ba:	c9                   	leave  
801019bb:	c3                   	ret    

801019bc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019bc:	55                   	push   %ebp
801019bd:	89 e5                	mov    %esp,%ebp
801019bf:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019c2:	83 ec 0c             	sub    $0xc,%esp
801019c5:	68 e0 09 11 80       	push   $0x801109e0
801019ca:	e8 8e 36 00 00       	call   8010505d <acquire>
801019cf:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019d9:	c7 45 f4 14 0a 11 80 	movl   $0x80110a14,-0xc(%ebp)
801019e0:	eb 60                	jmp    80101a42 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e5:	8b 40 08             	mov    0x8(%eax),%eax
801019e8:	85 c0                	test   %eax,%eax
801019ea:	7e 39                	jle    80101a25 <iget+0x69>
801019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ef:	8b 00                	mov    (%eax),%eax
801019f1:	39 45 08             	cmp    %eax,0x8(%ebp)
801019f4:	75 2f                	jne    80101a25 <iget+0x69>
801019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f9:	8b 40 04             	mov    0x4(%eax),%eax
801019fc:	39 45 0c             	cmp    %eax,0xc(%ebp)
801019ff:	75 24                	jne    80101a25 <iget+0x69>
      ip->ref++;
80101a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a04:	8b 40 08             	mov    0x8(%eax),%eax
80101a07:	8d 50 01             	lea    0x1(%eax),%edx
80101a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a10:	83 ec 0c             	sub    $0xc,%esp
80101a13:	68 e0 09 11 80       	push   $0x801109e0
80101a18:	e8 ae 36 00 00       	call   801050cb <release>
80101a1d:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a23:	eb 77                	jmp    80101a9c <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a29:	75 10                	jne    80101a3b <iget+0x7f>
80101a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2e:	8b 40 08             	mov    0x8(%eax),%eax
80101a31:	85 c0                	test   %eax,%eax
80101a33:	75 06                	jne    80101a3b <iget+0x7f>
      empty = ip;
80101a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a3b:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a42:	81 7d f4 34 26 11 80 	cmpl   $0x80112634,-0xc(%ebp)
80101a49:	72 97                	jb     801019e2 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a4f:	75 0d                	jne    80101a5e <iget+0xa2>
    panic("iget: no inodes");
80101a51:	83 ec 0c             	sub    $0xc,%esp
80101a54:	68 19 86 10 80       	push   $0x80108619
80101a59:	e8 57 eb ff ff       	call   801005b5 <panic>

  ip = empty;
80101a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a67:	8b 55 08             	mov    0x8(%ebp),%edx
80101a6a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a72:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a82:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a89:	83 ec 0c             	sub    $0xc,%esp
80101a8c:	68 e0 09 11 80       	push   $0x801109e0
80101a91:	e8 35 36 00 00       	call   801050cb <release>
80101a96:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a9c:	c9                   	leave  
80101a9d:	c3                   	ret    

80101a9e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a9e:	55                   	push   %ebp
80101a9f:	89 e5                	mov    %esp,%ebp
80101aa1:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101aa4:	83 ec 0c             	sub    $0xc,%esp
80101aa7:	68 e0 09 11 80       	push   $0x801109e0
80101aac:	e8 ac 35 00 00       	call   8010505d <acquire>
80101ab1:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	8b 40 08             	mov    0x8(%eax),%eax
80101aba:	8d 50 01             	lea    0x1(%eax),%edx
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ac3:	83 ec 0c             	sub    $0xc,%esp
80101ac6:	68 e0 09 11 80       	push   $0x801109e0
80101acb:	e8 fb 35 00 00       	call   801050cb <release>
80101ad0:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ad6:	c9                   	leave  
80101ad7:	c3                   	ret    

80101ad8 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ad8:	55                   	push   %ebp
80101ad9:	89 e5                	mov    %esp,%ebp
80101adb:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ade:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ae2:	74 0a                	je     80101aee <ilock+0x16>
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 40 08             	mov    0x8(%eax),%eax
80101aea:	85 c0                	test   %eax,%eax
80101aec:	7f 0d                	jg     80101afb <ilock+0x23>
    panic("ilock");
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	68 29 86 10 80       	push   $0x80108629
80101af6:	e8 ba ea ff ff       	call   801005b5 <panic>

  acquiresleep(&ip->lock);
80101afb:	8b 45 08             	mov    0x8(%ebp),%eax
80101afe:	83 c0 0c             	add    $0xc,%eax
80101b01:	83 ec 0c             	sub    $0xc,%esp
80101b04:	50                   	push   %eax
80101b05:	e8 ea 33 00 00       	call   80104ef4 <acquiresleep>
80101b0a:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b10:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b13:	85 c0                	test   %eax,%eax
80101b15:	0f 85 cd 00 00 00    	jne    80101be8 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1e:	8b 40 04             	mov    0x4(%eax),%eax
80101b21:	c1 e8 03             	shr    $0x3,%eax
80101b24:	89 c2                	mov    %eax,%edx
80101b26:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101b2b:	01 c2                	add    %eax,%edx
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 00                	mov    (%eax),%eax
80101b32:	83 ec 08             	sub    $0x8,%esp
80101b35:	52                   	push   %edx
80101b36:	50                   	push   %eax
80101b37:	e8 93 e6 ff ff       	call   801001cf <bread>
80101b3c:	83 c4 10             	add    $0x10,%esp
80101b3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b45:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b48:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4b:	8b 40 04             	mov    0x4(%eax),%eax
80101b4e:	83 e0 07             	and    $0x7,%eax
80101b51:	c1 e0 06             	shl    $0x6,%eax
80101b54:	01 d0                	add    %edx,%eax
80101b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5c:	0f b7 10             	movzwl (%eax),%edx
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b69:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b77:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b85:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b93:	8b 50 08             	mov    0x8(%eax),%edx
80101b96:	8b 45 08             	mov    0x8(%ebp),%eax
80101b99:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9f:	8d 50 0c             	lea    0xc(%eax),%edx
80101ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba5:	83 c0 5c             	add    $0x5c,%eax
80101ba8:	83 ec 04             	sub    $0x4,%esp
80101bab:	6a 34                	push   $0x34
80101bad:	52                   	push   %edx
80101bae:	50                   	push   %eax
80101baf:	e8 ee 37 00 00       	call   801053a2 <memmove>
80101bb4:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bb7:	83 ec 0c             	sub    $0xc,%esp
80101bba:	ff 75 f4             	push   -0xc(%ebp)
80101bbd:	e8 8f e6 ff ff       	call   80100251 <brelse>
80101bc2:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc8:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101bd6:	66 85 c0             	test   %ax,%ax
80101bd9:	75 0d                	jne    80101be8 <ilock+0x110>
      panic("ilock: no type");
80101bdb:	83 ec 0c             	sub    $0xc,%esp
80101bde:	68 2f 86 10 80       	push   $0x8010862f
80101be3:	e8 cd e9 ff ff       	call   801005b5 <panic>
  }
}
80101be8:	90                   	nop
80101be9:	c9                   	leave  
80101bea:	c3                   	ret    

80101beb <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101beb:	55                   	push   %ebp
80101bec:	89 e5                	mov    %esp,%ebp
80101bee:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bf1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bf5:	74 20                	je     80101c17 <iunlock+0x2c>
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	83 c0 0c             	add    $0xc,%eax
80101bfd:	83 ec 0c             	sub    $0xc,%esp
80101c00:	50                   	push   %eax
80101c01:	e8 a0 33 00 00       	call   80104fa6 <holdingsleep>
80101c06:	83 c4 10             	add    $0x10,%esp
80101c09:	85 c0                	test   %eax,%eax
80101c0b:	74 0a                	je     80101c17 <iunlock+0x2c>
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	8b 40 08             	mov    0x8(%eax),%eax
80101c13:	85 c0                	test   %eax,%eax
80101c15:	7f 0d                	jg     80101c24 <iunlock+0x39>
    panic("iunlock");
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 3e 86 10 80       	push   $0x8010863e
80101c1f:	e8 91 e9 ff ff       	call   801005b5 <panic>

  releasesleep(&ip->lock);
80101c24:	8b 45 08             	mov    0x8(%ebp),%eax
80101c27:	83 c0 0c             	add    $0xc,%eax
80101c2a:	83 ec 0c             	sub    $0xc,%esp
80101c2d:	50                   	push   %eax
80101c2e:	e8 25 33 00 00       	call   80104f58 <releasesleep>
80101c33:	83 c4 10             	add    $0x10,%esp
}
80101c36:	90                   	nop
80101c37:	c9                   	leave  
80101c38:	c3                   	ret    

80101c39 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c39:	55                   	push   %ebp
80101c3a:	89 e5                	mov    %esp,%ebp
80101c3c:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c42:	83 c0 0c             	add    $0xc,%eax
80101c45:	83 ec 0c             	sub    $0xc,%esp
80101c48:	50                   	push   %eax
80101c49:	e8 a6 32 00 00       	call   80104ef4 <acquiresleep>
80101c4e:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c51:	8b 45 08             	mov    0x8(%ebp),%eax
80101c54:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c57:	85 c0                	test   %eax,%eax
80101c59:	74 6a                	je     80101cc5 <iput+0x8c>
80101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c62:	66 85 c0             	test   %ax,%ax
80101c65:	75 5e                	jne    80101cc5 <iput+0x8c>
    acquire(&icache.lock);
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	68 e0 09 11 80       	push   $0x801109e0
80101c6f:	e8 e9 33 00 00       	call   8010505d <acquire>
80101c74:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	8b 40 08             	mov    0x8(%eax),%eax
80101c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c80:	83 ec 0c             	sub    $0xc,%esp
80101c83:	68 e0 09 11 80       	push   $0x801109e0
80101c88:	e8 3e 34 00 00       	call   801050cb <release>
80101c8d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c90:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c94:	75 2f                	jne    80101cc5 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c96:	83 ec 0c             	sub    $0xc,%esp
80101c99:	ff 75 08             	push   0x8(%ebp)
80101c9c:	e8 ad 01 00 00       	call   80101e4e <itrunc>
80101ca1:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cad:	83 ec 0c             	sub    $0xc,%esp
80101cb0:	ff 75 08             	push   0x8(%ebp)
80101cb3:	e8 43 fc ff ff       	call   801018fb <iupdate>
80101cb8:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc8:	83 c0 0c             	add    $0xc,%eax
80101ccb:	83 ec 0c             	sub    $0xc,%esp
80101cce:	50                   	push   %eax
80101ccf:	e8 84 32 00 00       	call   80104f58 <releasesleep>
80101cd4:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101cd7:	83 ec 0c             	sub    $0xc,%esp
80101cda:	68 e0 09 11 80       	push   $0x801109e0
80101cdf:	e8 79 33 00 00       	call   8010505d <acquire>
80101ce4:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cea:	8b 40 08             	mov    0x8(%eax),%eax
80101ced:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cf6:	83 ec 0c             	sub    $0xc,%esp
80101cf9:	68 e0 09 11 80       	push   $0x801109e0
80101cfe:	e8 c8 33 00 00       	call   801050cb <release>
80101d03:	83 c4 10             	add    $0x10,%esp
}
80101d06:	90                   	nop
80101d07:	c9                   	leave  
80101d08:	c3                   	ret    

80101d09 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d09:	55                   	push   %ebp
80101d0a:	89 e5                	mov    %esp,%ebp
80101d0c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d0f:	83 ec 0c             	sub    $0xc,%esp
80101d12:	ff 75 08             	push   0x8(%ebp)
80101d15:	e8 d1 fe ff ff       	call   80101beb <iunlock>
80101d1a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d1d:	83 ec 0c             	sub    $0xc,%esp
80101d20:	ff 75 08             	push   0x8(%ebp)
80101d23:	e8 11 ff ff ff       	call   80101c39 <iput>
80101d28:	83 c4 10             	add    $0x10,%esp
}
80101d2b:	90                   	nop
80101d2c:	c9                   	leave  
80101d2d:	c3                   	ret    

80101d2e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d2e:	55                   	push   %ebp
80101d2f:	89 e5                	mov    %esp,%ebp
80101d31:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d34:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d38:	77 42                	ja     80101d7c <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d40:	83 c2 14             	add    $0x14,%edx
80101d43:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d4e:	75 24                	jne    80101d74 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	8b 00                	mov    (%eax),%eax
80101d55:	83 ec 0c             	sub    $0xc,%esp
80101d58:	50                   	push   %eax
80101d59:	e8 07 f8 ff ff       	call   80101565 <balloc>
80101d5e:	83 c4 10             	add    $0x10,%esp
80101d61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d6a:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d70:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d77:	e9 d0 00 00 00       	jmp    80101e4c <bmap+0x11e>
  }
  bn -= NDIRECT;
80101d7c:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d80:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d84:	0f 87 b5 00 00 00    	ja     80101e3f <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d9a:	75 20                	jne    80101dbc <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	8b 00                	mov    (%eax),%eax
80101da1:	83 ec 0c             	sub    $0xc,%esp
80101da4:	50                   	push   %eax
80101da5:	e8 bb f7 ff ff       	call   80101565 <balloc>
80101daa:	83 c4 10             	add    $0x10,%esp
80101dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db6:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbf:	8b 00                	mov    (%eax),%eax
80101dc1:	83 ec 08             	sub    $0x8,%esp
80101dc4:	ff 75 f4             	push   -0xc(%ebp)
80101dc7:	50                   	push   %eax
80101dc8:	e8 02 e4 ff ff       	call   801001cf <bread>
80101dcd:	83 c4 10             	add    $0x10,%esp
80101dd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd6:	83 c0 5c             	add    $0x5c,%eax
80101dd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ddf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101de6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101de9:	01 d0                	add    %edx,%eax
80101deb:	8b 00                	mov    (%eax),%eax
80101ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df4:	75 36                	jne    80101e2c <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 00                	mov    (%eax),%eax
80101dfb:	83 ec 0c             	sub    $0xc,%esp
80101dfe:	50                   	push   %eax
80101dff:	e8 61 f7 ff ff       	call   80101565 <balloc>
80101e04:	83 c4 10             	add    $0x10,%esp
80101e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e17:	01 c2                	add    %eax,%edx
80101e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e1c:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e1e:	83 ec 0c             	sub    $0xc,%esp
80101e21:	ff 75 f0             	push   -0x10(%ebp)
80101e24:	e8 00 1a 00 00       	call   80103829 <log_write>
80101e29:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e2c:	83 ec 0c             	sub    $0xc,%esp
80101e2f:	ff 75 f0             	push   -0x10(%ebp)
80101e32:	e8 1a e4 ff ff       	call   80100251 <brelse>
80101e37:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e3d:	eb 0d                	jmp    80101e4c <bmap+0x11e>
  }

  panic("bmap: out of range");
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	68 46 86 10 80       	push   $0x80108646
80101e47:	e8 69 e7 ff ff       	call   801005b5 <panic>
}
80101e4c:	c9                   	leave  
80101e4d:	c3                   	ret    

80101e4e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e4e:	55                   	push   %ebp
80101e4f:	89 e5                	mov    %esp,%ebp
80101e51:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e5b:	eb 45                	jmp    80101ea2 <itrunc+0x54>
    if(ip->addrs[i]){
80101e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e63:	83 c2 14             	add    $0x14,%edx
80101e66:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e6a:	85 c0                	test   %eax,%eax
80101e6c:	74 30                	je     80101e9e <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e74:	83 c2 14             	add    $0x14,%edx
80101e77:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e7b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e7e:	8b 12                	mov    (%edx),%edx
80101e80:	83 ec 08             	sub    $0x8,%esp
80101e83:	50                   	push   %eax
80101e84:	52                   	push   %edx
80101e85:	e8 1f f8 ff ff       	call   801016a9 <bfree>
80101e8a:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e93:	83 c2 14             	add    $0x14,%edx
80101e96:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e9d:	00 
  for(i = 0; i < NDIRECT; i++){
80101e9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ea2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ea6:	7e b5                	jle    80101e5d <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eb1:	85 c0                	test   %eax,%eax
80101eb3:	0f 84 aa 00 00 00    	je     80101f63 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec5:	8b 00                	mov    (%eax),%eax
80101ec7:	83 ec 08             	sub    $0x8,%esp
80101eca:	52                   	push   %edx
80101ecb:	50                   	push   %eax
80101ecc:	e8 fe e2 ff ff       	call   801001cf <bread>
80101ed1:	83 c4 10             	add    $0x10,%esp
80101ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eda:	83 c0 5c             	add    $0x5c,%eax
80101edd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ee0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ee7:	eb 3c                	jmp    80101f25 <itrunc+0xd7>
      if(a[j])
80101ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ef3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ef6:	01 d0                	add    %edx,%eax
80101ef8:	8b 00                	mov    (%eax),%eax
80101efa:	85 c0                	test   %eax,%eax
80101efc:	74 23                	je     80101f21 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f0b:	01 d0                	add    %edx,%eax
80101f0d:	8b 00                	mov    (%eax),%eax
80101f0f:	8b 55 08             	mov    0x8(%ebp),%edx
80101f12:	8b 12                	mov    (%edx),%edx
80101f14:	83 ec 08             	sub    $0x8,%esp
80101f17:	50                   	push   %eax
80101f18:	52                   	push   %edx
80101f19:	e8 8b f7 ff ff       	call   801016a9 <bfree>
80101f1e:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f21:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f28:	83 f8 7f             	cmp    $0x7f,%eax
80101f2b:	76 bc                	jbe    80101ee9 <itrunc+0x9b>
    }
    brelse(bp);
80101f2d:	83 ec 0c             	sub    $0xc,%esp
80101f30:	ff 75 ec             	push   -0x14(%ebp)
80101f33:	e8 19 e3 ff ff       	call   80100251 <brelse>
80101f38:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f44:	8b 55 08             	mov    0x8(%ebp),%edx
80101f47:	8b 12                	mov    (%edx),%edx
80101f49:	83 ec 08             	sub    $0x8,%esp
80101f4c:	50                   	push   %eax
80101f4d:	52                   	push   %edx
80101f4e:	e8 56 f7 ff ff       	call   801016a9 <bfree>
80101f53:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f60:	00 00 00 
  }

  ip->size = 0;
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f6d:	83 ec 0c             	sub    $0xc,%esp
80101f70:	ff 75 08             	push   0x8(%ebp)
80101f73:	e8 83 f9 ff ff       	call   801018fb <iupdate>
80101f78:	83 c4 10             	add    $0x10,%esp
}
80101f7b:	90                   	nop
80101f7c:	c9                   	leave  
80101f7d:	c3                   	ret    

80101f7e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f7e:	55                   	push   %ebp
80101f7f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 00                	mov    (%eax),%eax
80101f86:	89 c2                	mov    %eax,%edx
80101f88:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f8b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	8b 50 04             	mov    0x4(%eax),%edx
80101f94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f97:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fa4:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101fae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb1:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb8:	8b 50 58             	mov    0x58(%eax),%edx
80101fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fbe:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fc1:	90                   	nop
80101fc2:	5d                   	pop    %ebp
80101fc3:	c3                   	ret    

80101fc4 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fc4:	55                   	push   %ebp
80101fc5:	89 e5                	mov    %esp,%ebp
80101fc7:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fca:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101fd1:	66 83 f8 03          	cmp    $0x3,%ax
80101fd5:	75 5c                	jne    80102033 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fda:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fde:	66 85 c0             	test   %ax,%ax
80101fe1:	78 20                	js     80102003 <readi+0x3f>
80101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fea:	66 83 f8 09          	cmp    $0x9,%ax
80101fee:	7f 13                	jg     80102003 <readi+0x3f>
80101ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ff7:	98                   	cwtl   
80101ff8:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101fff:	85 c0                	test   %eax,%eax
80102001:	75 0a                	jne    8010200d <readi+0x49>
      return -1;
80102003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102008:	e9 0a 01 00 00       	jmp    80102117 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
80102010:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102014:	98                   	cwtl   
80102015:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
8010201c:	8b 55 14             	mov    0x14(%ebp),%edx
8010201f:	83 ec 04             	sub    $0x4,%esp
80102022:	52                   	push   %edx
80102023:	ff 75 0c             	push   0xc(%ebp)
80102026:	ff 75 08             	push   0x8(%ebp)
80102029:	ff d0                	call   *%eax
8010202b:	83 c4 10             	add    $0x10,%esp
8010202e:	e9 e4 00 00 00       	jmp    80102117 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	8b 40 58             	mov    0x58(%eax),%eax
80102039:	39 45 10             	cmp    %eax,0x10(%ebp)
8010203c:	77 0d                	ja     8010204b <readi+0x87>
8010203e:	8b 55 10             	mov    0x10(%ebp),%edx
80102041:	8b 45 14             	mov    0x14(%ebp),%eax
80102044:	01 d0                	add    %edx,%eax
80102046:	39 45 10             	cmp    %eax,0x10(%ebp)
80102049:	76 0a                	jbe    80102055 <readi+0x91>
    return -1;
8010204b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102050:	e9 c2 00 00 00       	jmp    80102117 <readi+0x153>
  if(off + n > ip->size)
80102055:	8b 55 10             	mov    0x10(%ebp),%edx
80102058:	8b 45 14             	mov    0x14(%ebp),%eax
8010205b:	01 c2                	add    %eax,%edx
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	8b 40 58             	mov    0x58(%eax),%eax
80102063:	39 c2                	cmp    %eax,%edx
80102065:	76 0c                	jbe    80102073 <readi+0xaf>
    n = ip->size - off;
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	8b 40 58             	mov    0x58(%eax),%eax
8010206d:	2b 45 10             	sub    0x10(%ebp),%eax
80102070:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102073:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010207a:	e9 89 00 00 00       	jmp    80102108 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010207f:	8b 45 10             	mov    0x10(%ebp),%eax
80102082:	c1 e8 09             	shr    $0x9,%eax
80102085:	83 ec 08             	sub    $0x8,%esp
80102088:	50                   	push   %eax
80102089:	ff 75 08             	push   0x8(%ebp)
8010208c:	e8 9d fc ff ff       	call   80101d2e <bmap>
80102091:	83 c4 10             	add    $0x10,%esp
80102094:	8b 55 08             	mov    0x8(%ebp),%edx
80102097:	8b 12                	mov    (%edx),%edx
80102099:	83 ec 08             	sub    $0x8,%esp
8010209c:	50                   	push   %eax
8010209d:	52                   	push   %edx
8010209e:	e8 2c e1 ff ff       	call   801001cf <bread>
801020a3:	83 c4 10             	add    $0x10,%esp
801020a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020a9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ac:	25 ff 01 00 00       	and    $0x1ff,%eax
801020b1:	ba 00 02 00 00       	mov    $0x200,%edx
801020b6:	29 c2                	sub    %eax,%edx
801020b8:	8b 45 14             	mov    0x14(%ebp),%eax
801020bb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020be:	39 c2                	cmp    %eax,%edx
801020c0:	0f 46 c2             	cmovbe %edx,%eax
801020c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020c9:	8d 50 5c             	lea    0x5c(%eax),%edx
801020cc:	8b 45 10             	mov    0x10(%ebp),%eax
801020cf:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d4:	01 d0                	add    %edx,%eax
801020d6:	83 ec 04             	sub    $0x4,%esp
801020d9:	ff 75 ec             	push   -0x14(%ebp)
801020dc:	50                   	push   %eax
801020dd:	ff 75 0c             	push   0xc(%ebp)
801020e0:	e8 bd 32 00 00       	call   801053a2 <memmove>
801020e5:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020e8:	83 ec 0c             	sub    $0xc,%esp
801020eb:	ff 75 f0             	push   -0x10(%ebp)
801020ee:	e8 5e e1 ff ff       	call   80100251 <brelse>
801020f3:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f9:	01 45 f4             	add    %eax,-0xc(%ebp)
801020fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020ff:	01 45 10             	add    %eax,0x10(%ebp)
80102102:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102105:	01 45 0c             	add    %eax,0xc(%ebp)
80102108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010210b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010210e:	0f 82 6b ff ff ff    	jb     8010207f <readi+0xbb>
  }
  return n;
80102114:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102117:	c9                   	leave  
80102118:	c3                   	ret    

80102119 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102119:	55                   	push   %ebp
8010211a:	89 e5                	mov    %esp,%ebp
8010211c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010211f:	8b 45 08             	mov    0x8(%ebp),%eax
80102122:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102126:	66 83 f8 03          	cmp    $0x3,%ax
8010212a:	75 5c                	jne    80102188 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010212c:	8b 45 08             	mov    0x8(%ebp),%eax
8010212f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102133:	66 85 c0             	test   %ax,%ax
80102136:	78 20                	js     80102158 <writei+0x3f>
80102138:	8b 45 08             	mov    0x8(%ebp),%eax
8010213b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010213f:	66 83 f8 09          	cmp    $0x9,%ax
80102143:	7f 13                	jg     80102158 <writei+0x3f>
80102145:	8b 45 08             	mov    0x8(%ebp),%eax
80102148:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010214c:	98                   	cwtl   
8010214d:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
80102154:	85 c0                	test   %eax,%eax
80102156:	75 0a                	jne    80102162 <writei+0x49>
      return -1;
80102158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010215d:	e9 3b 01 00 00       	jmp    8010229d <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102162:	8b 45 08             	mov    0x8(%ebp),%eax
80102165:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102169:	98                   	cwtl   
8010216a:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
80102171:	8b 55 14             	mov    0x14(%ebp),%edx
80102174:	83 ec 04             	sub    $0x4,%esp
80102177:	52                   	push   %edx
80102178:	ff 75 0c             	push   0xc(%ebp)
8010217b:	ff 75 08             	push   0x8(%ebp)
8010217e:	ff d0                	call   *%eax
80102180:	83 c4 10             	add    $0x10,%esp
80102183:	e9 15 01 00 00       	jmp    8010229d <writei+0x184>
  }

  if(off > ip->size || off + n < off)
80102188:	8b 45 08             	mov    0x8(%ebp),%eax
8010218b:	8b 40 58             	mov    0x58(%eax),%eax
8010218e:	39 45 10             	cmp    %eax,0x10(%ebp)
80102191:	77 0d                	ja     801021a0 <writei+0x87>
80102193:	8b 55 10             	mov    0x10(%ebp),%edx
80102196:	8b 45 14             	mov    0x14(%ebp),%eax
80102199:	01 d0                	add    %edx,%eax
8010219b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010219e:	76 0a                	jbe    801021aa <writei+0x91>
    return -1;
801021a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021a5:	e9 f3 00 00 00       	jmp    8010229d <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801021aa:	8b 55 10             	mov    0x10(%ebp),%edx
801021ad:	8b 45 14             	mov    0x14(%ebp),%eax
801021b0:	01 d0                	add    %edx,%eax
801021b2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021b7:	76 0a                	jbe    801021c3 <writei+0xaa>
    return -1;
801021b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021be:	e9 da 00 00 00       	jmp    8010229d <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ca:	e9 97 00 00 00       	jmp    80102266 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021cf:	8b 45 10             	mov    0x10(%ebp),%eax
801021d2:	c1 e8 09             	shr    $0x9,%eax
801021d5:	83 ec 08             	sub    $0x8,%esp
801021d8:	50                   	push   %eax
801021d9:	ff 75 08             	push   0x8(%ebp)
801021dc:	e8 4d fb ff ff       	call   80101d2e <bmap>
801021e1:	83 c4 10             	add    $0x10,%esp
801021e4:	8b 55 08             	mov    0x8(%ebp),%edx
801021e7:	8b 12                	mov    (%edx),%edx
801021e9:	83 ec 08             	sub    $0x8,%esp
801021ec:	50                   	push   %eax
801021ed:	52                   	push   %edx
801021ee:	e8 dc df ff ff       	call   801001cf <bread>
801021f3:	83 c4 10             	add    $0x10,%esp
801021f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021f9:	8b 45 10             	mov    0x10(%ebp),%eax
801021fc:	25 ff 01 00 00       	and    $0x1ff,%eax
80102201:	ba 00 02 00 00       	mov    $0x200,%edx
80102206:	29 c2                	sub    %eax,%edx
80102208:	8b 45 14             	mov    0x14(%ebp),%eax
8010220b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010220e:	39 c2                	cmp    %eax,%edx
80102210:	0f 46 c2             	cmovbe %edx,%eax
80102213:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102219:	8d 50 5c             	lea    0x5c(%eax),%edx
8010221c:	8b 45 10             	mov    0x10(%ebp),%eax
8010221f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102224:	01 d0                	add    %edx,%eax
80102226:	83 ec 04             	sub    $0x4,%esp
80102229:	ff 75 ec             	push   -0x14(%ebp)
8010222c:	ff 75 0c             	push   0xc(%ebp)
8010222f:	50                   	push   %eax
80102230:	e8 6d 31 00 00       	call   801053a2 <memmove>
80102235:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102238:	83 ec 0c             	sub    $0xc,%esp
8010223b:	ff 75 f0             	push   -0x10(%ebp)
8010223e:	e8 e6 15 00 00       	call   80103829 <log_write>
80102243:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102246:	83 ec 0c             	sub    $0xc,%esp
80102249:	ff 75 f0             	push   -0x10(%ebp)
8010224c:	e8 00 e0 ff ff       	call   80100251 <brelse>
80102251:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102254:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102257:	01 45 f4             	add    %eax,-0xc(%ebp)
8010225a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010225d:	01 45 10             	add    %eax,0x10(%ebp)
80102260:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102263:	01 45 0c             	add    %eax,0xc(%ebp)
80102266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102269:	3b 45 14             	cmp    0x14(%ebp),%eax
8010226c:	0f 82 5d ff ff ff    	jb     801021cf <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102272:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102276:	74 22                	je     8010229a <writei+0x181>
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 10             	cmp    %eax,0x10(%ebp)
80102281:	76 17                	jbe    8010229a <writei+0x181>
    ip->size = off;
80102283:	8b 45 08             	mov    0x8(%ebp),%eax
80102286:	8b 55 10             	mov    0x10(%ebp),%edx
80102289:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010228c:	83 ec 0c             	sub    $0xc,%esp
8010228f:	ff 75 08             	push   0x8(%ebp)
80102292:	e8 64 f6 ff ff       	call   801018fb <iupdate>
80102297:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010229a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010229d:	c9                   	leave  
8010229e:	c3                   	ret    

8010229f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010229f:	55                   	push   %ebp
801022a0:	89 e5                	mov    %esp,%ebp
801022a2:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022a5:	83 ec 04             	sub    $0x4,%esp
801022a8:	6a 0e                	push   $0xe
801022aa:	ff 75 0c             	push   0xc(%ebp)
801022ad:	ff 75 08             	push   0x8(%ebp)
801022b0:	e8 83 31 00 00       	call   80105438 <strncmp>
801022b5:	83 c4 10             	add    $0x10,%esp
}
801022b8:	c9                   	leave  
801022b9:	c3                   	ret    

801022ba <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022ba:	55                   	push   %ebp
801022bb:	89 e5                	mov    %esp,%ebp
801022bd:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022c0:	8b 45 08             	mov    0x8(%ebp),%eax
801022c3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022c7:	66 83 f8 01          	cmp    $0x1,%ax
801022cb:	74 0d                	je     801022da <dirlookup+0x20>
    panic("dirlookup not DIR");
801022cd:	83 ec 0c             	sub    $0xc,%esp
801022d0:	68 59 86 10 80       	push   $0x80108659
801022d5:	e8 db e2 ff ff       	call   801005b5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e1:	eb 7b                	jmp    8010235e <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e3:	6a 10                	push   $0x10
801022e5:	ff 75 f4             	push   -0xc(%ebp)
801022e8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022eb:	50                   	push   %eax
801022ec:	ff 75 08             	push   0x8(%ebp)
801022ef:	e8 d0 fc ff ff       	call   80101fc4 <readi>
801022f4:	83 c4 10             	add    $0x10,%esp
801022f7:	83 f8 10             	cmp    $0x10,%eax
801022fa:	74 0d                	je     80102309 <dirlookup+0x4f>
      panic("dirlookup read");
801022fc:	83 ec 0c             	sub    $0xc,%esp
801022ff:	68 6b 86 10 80       	push   $0x8010866b
80102304:	e8 ac e2 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
80102309:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230d:	66 85 c0             	test   %ax,%ax
80102310:	74 47                	je     80102359 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102312:	83 ec 08             	sub    $0x8,%esp
80102315:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102318:	83 c0 02             	add    $0x2,%eax
8010231b:	50                   	push   %eax
8010231c:	ff 75 0c             	push   0xc(%ebp)
8010231f:	e8 7b ff ff ff       	call   8010229f <namecmp>
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	85 c0                	test   %eax,%eax
80102329:	75 2f                	jne    8010235a <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010232b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010232f:	74 08                	je     80102339 <dirlookup+0x7f>
        *poff = off;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102337:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102339:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010233d:	0f b7 c0             	movzwl %ax,%eax
80102340:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102343:	8b 45 08             	mov    0x8(%ebp),%eax
80102346:	8b 00                	mov    (%eax),%eax
80102348:	83 ec 08             	sub    $0x8,%esp
8010234b:	ff 75 f0             	push   -0x10(%ebp)
8010234e:	50                   	push   %eax
8010234f:	e8 68 f6 ff ff       	call   801019bc <iget>
80102354:	83 c4 10             	add    $0x10,%esp
80102357:	eb 19                	jmp    80102372 <dirlookup+0xb8>
      continue;
80102359:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010235a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010235e:	8b 45 08             	mov    0x8(%ebp),%eax
80102361:	8b 40 58             	mov    0x58(%eax),%eax
80102364:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102367:	0f 82 76 ff ff ff    	jb     801022e3 <dirlookup+0x29>
    }
  }

  return 0;
8010236d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102372:	c9                   	leave  
80102373:	c3                   	ret    

80102374 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102374:	55                   	push   %ebp
80102375:	89 e5                	mov    %esp,%ebp
80102377:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010237a:	83 ec 04             	sub    $0x4,%esp
8010237d:	6a 00                	push   $0x0
8010237f:	ff 75 0c             	push   0xc(%ebp)
80102382:	ff 75 08             	push   0x8(%ebp)
80102385:	e8 30 ff ff ff       	call   801022ba <dirlookup>
8010238a:	83 c4 10             	add    $0x10,%esp
8010238d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102390:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102394:	74 18                	je     801023ae <dirlink+0x3a>
    iput(ip);
80102396:	83 ec 0c             	sub    $0xc,%esp
80102399:	ff 75 f0             	push   -0x10(%ebp)
8010239c:	e8 98 f8 ff ff       	call   80101c39 <iput>
801023a1:	83 c4 10             	add    $0x10,%esp
    return -1;
801023a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023a9:	e9 9c 00 00 00       	jmp    8010244a <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b5:	eb 39                	jmp    801023f0 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ba:	6a 10                	push   $0x10
801023bc:	50                   	push   %eax
801023bd:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c0:	50                   	push   %eax
801023c1:	ff 75 08             	push   0x8(%ebp)
801023c4:	e8 fb fb ff ff       	call   80101fc4 <readi>
801023c9:	83 c4 10             	add    $0x10,%esp
801023cc:	83 f8 10             	cmp    $0x10,%eax
801023cf:	74 0d                	je     801023de <dirlink+0x6a>
      panic("dirlink read");
801023d1:	83 ec 0c             	sub    $0xc,%esp
801023d4:	68 7a 86 10 80       	push   $0x8010867a
801023d9:	e8 d7 e1 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
801023de:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023e2:	66 85 c0             	test   %ax,%ax
801023e5:	74 18                	je     801023ff <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ea:	83 c0 10             	add    $0x10,%eax
801023ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023f0:	8b 45 08             	mov    0x8(%ebp),%eax
801023f3:	8b 50 58             	mov    0x58(%eax),%edx
801023f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f9:	39 c2                	cmp    %eax,%edx
801023fb:	77 ba                	ja     801023b7 <dirlink+0x43>
801023fd:	eb 01                	jmp    80102400 <dirlink+0x8c>
      break;
801023ff:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102400:	83 ec 04             	sub    $0x4,%esp
80102403:	6a 0e                	push   $0xe
80102405:	ff 75 0c             	push   0xc(%ebp)
80102408:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010240b:	83 c0 02             	add    $0x2,%eax
8010240e:	50                   	push   %eax
8010240f:	e8 7a 30 00 00       	call   8010548e <strncpy>
80102414:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102417:	8b 45 10             	mov    0x10(%ebp),%eax
8010241a:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010241e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102421:	6a 10                	push   $0x10
80102423:	50                   	push   %eax
80102424:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102427:	50                   	push   %eax
80102428:	ff 75 08             	push   0x8(%ebp)
8010242b:	e8 e9 fc ff ff       	call   80102119 <writei>
80102430:	83 c4 10             	add    $0x10,%esp
80102433:	83 f8 10             	cmp    $0x10,%eax
80102436:	74 0d                	je     80102445 <dirlink+0xd1>
    panic("dirlink");
80102438:	83 ec 0c             	sub    $0xc,%esp
8010243b:	68 87 86 10 80       	push   $0x80108687
80102440:	e8 70 e1 ff ff       	call   801005b5 <panic>

  return 0;
80102445:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010244a:	c9                   	leave  
8010244b:	c3                   	ret    

8010244c <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010244c:	55                   	push   %ebp
8010244d:	89 e5                	mov    %esp,%ebp
8010244f:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102452:	eb 04                	jmp    80102458 <skipelem+0xc>
    path++;
80102454:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102458:	8b 45 08             	mov    0x8(%ebp),%eax
8010245b:	0f b6 00             	movzbl (%eax),%eax
8010245e:	3c 2f                	cmp    $0x2f,%al
80102460:	74 f2                	je     80102454 <skipelem+0x8>
  if(*path == 0)
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	0f b6 00             	movzbl (%eax),%eax
80102468:	84 c0                	test   %al,%al
8010246a:	75 07                	jne    80102473 <skipelem+0x27>
    return 0;
8010246c:	b8 00 00 00 00       	mov    $0x0,%eax
80102471:	eb 77                	jmp    801024ea <skipelem+0x9e>
  s = path;
80102473:	8b 45 08             	mov    0x8(%ebp),%eax
80102476:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102479:	eb 04                	jmp    8010247f <skipelem+0x33>
    path++;
8010247b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010247f:	8b 45 08             	mov    0x8(%ebp),%eax
80102482:	0f b6 00             	movzbl (%eax),%eax
80102485:	3c 2f                	cmp    $0x2f,%al
80102487:	74 0a                	je     80102493 <skipelem+0x47>
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	0f b6 00             	movzbl (%eax),%eax
8010248f:	84 c0                	test   %al,%al
80102491:	75 e8                	jne    8010247b <skipelem+0x2f>
  len = path - s;
80102493:	8b 45 08             	mov    0x8(%ebp),%eax
80102496:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102499:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010249c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024a0:	7e 15                	jle    801024b7 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 0e                	push   $0xe
801024a7:	ff 75 f4             	push   -0xc(%ebp)
801024aa:	ff 75 0c             	push   0xc(%ebp)
801024ad:	e8 f0 2e 00 00       	call   801053a2 <memmove>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	eb 26                	jmp    801024dd <skipelem+0x91>
  else {
    memmove(name, s, len);
801024b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024ba:	83 ec 04             	sub    $0x4,%esp
801024bd:	50                   	push   %eax
801024be:	ff 75 f4             	push   -0xc(%ebp)
801024c1:	ff 75 0c             	push   0xc(%ebp)
801024c4:	e8 d9 2e 00 00       	call   801053a2 <memmove>
801024c9:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801024d2:	01 d0                	add    %edx,%eax
801024d4:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024d7:	eb 04                	jmp    801024dd <skipelem+0x91>
    path++;
801024d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024dd:	8b 45 08             	mov    0x8(%ebp),%eax
801024e0:	0f b6 00             	movzbl (%eax),%eax
801024e3:	3c 2f                	cmp    $0x2f,%al
801024e5:	74 f2                	je     801024d9 <skipelem+0x8d>
  return path;
801024e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024ea:	c9                   	leave  
801024eb:	c3                   	ret    

801024ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024ec:	55                   	push   %ebp
801024ed:	89 e5                	mov    %esp,%ebp
801024ef:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024f2:	8b 45 08             	mov    0x8(%ebp),%eax
801024f5:	0f b6 00             	movzbl (%eax),%eax
801024f8:	3c 2f                	cmp    $0x2f,%al
801024fa:	75 17                	jne    80102513 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024fc:	83 ec 08             	sub    $0x8,%esp
801024ff:	6a 01                	push   $0x1
80102501:	6a 01                	push   $0x1
80102503:	e8 b4 f4 ff ff       	call   801019bc <iget>
80102508:	83 c4 10             	add    $0x10,%esp
8010250b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010250e:	e9 ba 00 00 00       	jmp    801025cd <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102513:	e8 3f 1e 00 00       	call   80104357 <myproc>
80102518:	8b 40 68             	mov    0x68(%eax),%eax
8010251b:	83 ec 0c             	sub    $0xc,%esp
8010251e:	50                   	push   %eax
8010251f:	e8 7a f5 ff ff       	call   80101a9e <idup>
80102524:	83 c4 10             	add    $0x10,%esp
80102527:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010252a:	e9 9e 00 00 00       	jmp    801025cd <namex+0xe1>
    ilock(ip);
8010252f:	83 ec 0c             	sub    $0xc,%esp
80102532:	ff 75 f4             	push   -0xc(%ebp)
80102535:	e8 9e f5 ff ff       	call   80101ad8 <ilock>
8010253a:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010253d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102540:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102544:	66 83 f8 01          	cmp    $0x1,%ax
80102548:	74 18                	je     80102562 <namex+0x76>
      iunlockput(ip);
8010254a:	83 ec 0c             	sub    $0xc,%esp
8010254d:	ff 75 f4             	push   -0xc(%ebp)
80102550:	e8 b4 f7 ff ff       	call   80101d09 <iunlockput>
80102555:	83 c4 10             	add    $0x10,%esp
      return 0;
80102558:	b8 00 00 00 00       	mov    $0x0,%eax
8010255d:	e9 a7 00 00 00       	jmp    80102609 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102562:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102566:	74 20                	je     80102588 <namex+0x9c>
80102568:	8b 45 08             	mov    0x8(%ebp),%eax
8010256b:	0f b6 00             	movzbl (%eax),%eax
8010256e:	84 c0                	test   %al,%al
80102570:	75 16                	jne    80102588 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102572:	83 ec 0c             	sub    $0xc,%esp
80102575:	ff 75 f4             	push   -0xc(%ebp)
80102578:	e8 6e f6 ff ff       	call   80101beb <iunlock>
8010257d:	83 c4 10             	add    $0x10,%esp
      return ip;
80102580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102583:	e9 81 00 00 00       	jmp    80102609 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102588:	83 ec 04             	sub    $0x4,%esp
8010258b:	6a 00                	push   $0x0
8010258d:	ff 75 10             	push   0x10(%ebp)
80102590:	ff 75 f4             	push   -0xc(%ebp)
80102593:	e8 22 fd ff ff       	call   801022ba <dirlookup>
80102598:	83 c4 10             	add    $0x10,%esp
8010259b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010259e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025a2:	75 15                	jne    801025b9 <namex+0xcd>
      iunlockput(ip);
801025a4:	83 ec 0c             	sub    $0xc,%esp
801025a7:	ff 75 f4             	push   -0xc(%ebp)
801025aa:	e8 5a f7 ff ff       	call   80101d09 <iunlockput>
801025af:	83 c4 10             	add    $0x10,%esp
      return 0;
801025b2:	b8 00 00 00 00       	mov    $0x0,%eax
801025b7:	eb 50                	jmp    80102609 <namex+0x11d>
    }
    iunlockput(ip);
801025b9:	83 ec 0c             	sub    $0xc,%esp
801025bc:	ff 75 f4             	push   -0xc(%ebp)
801025bf:	e8 45 f7 ff ff       	call   80101d09 <iunlockput>
801025c4:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025cd:	83 ec 08             	sub    $0x8,%esp
801025d0:	ff 75 10             	push   0x10(%ebp)
801025d3:	ff 75 08             	push   0x8(%ebp)
801025d6:	e8 71 fe ff ff       	call   8010244c <skipelem>
801025db:	83 c4 10             	add    $0x10,%esp
801025de:	89 45 08             	mov    %eax,0x8(%ebp)
801025e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025e5:	0f 85 44 ff ff ff    	jne    8010252f <namex+0x43>
  }
  if(nameiparent){
801025eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025ef:	74 15                	je     80102606 <namex+0x11a>
    iput(ip);
801025f1:	83 ec 0c             	sub    $0xc,%esp
801025f4:	ff 75 f4             	push   -0xc(%ebp)
801025f7:	e8 3d f6 ff ff       	call   80101c39 <iput>
801025fc:	83 c4 10             	add    $0x10,%esp
    return 0;
801025ff:	b8 00 00 00 00       	mov    $0x0,%eax
80102604:	eb 03                	jmp    80102609 <namex+0x11d>
  }
  return ip;
80102606:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102609:	c9                   	leave  
8010260a:	c3                   	ret    

8010260b <namei>:

struct inode*
namei(char *path)
{
8010260b:	55                   	push   %ebp
8010260c:	89 e5                	mov    %esp,%ebp
8010260e:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102611:	83 ec 04             	sub    $0x4,%esp
80102614:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102617:	50                   	push   %eax
80102618:	6a 00                	push   $0x0
8010261a:	ff 75 08             	push   0x8(%ebp)
8010261d:	e8 ca fe ff ff       	call   801024ec <namex>
80102622:	83 c4 10             	add    $0x10,%esp
}
80102625:	c9                   	leave  
80102626:	c3                   	ret    

80102627 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102627:	55                   	push   %ebp
80102628:	89 e5                	mov    %esp,%ebp
8010262a:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010262d:	83 ec 04             	sub    $0x4,%esp
80102630:	ff 75 0c             	push   0xc(%ebp)
80102633:	6a 01                	push   $0x1
80102635:	ff 75 08             	push   0x8(%ebp)
80102638:	e8 af fe ff ff       	call   801024ec <namex>
8010263d:	83 c4 10             	add    $0x10,%esp
}
80102640:	c9                   	leave  
80102641:	c3                   	ret    

80102642 <inb>:
{
80102642:	55                   	push   %ebp
80102643:	89 e5                	mov    %esp,%ebp
80102645:	83 ec 14             	sub    $0x14,%esp
80102648:	8b 45 08             	mov    0x8(%ebp),%eax
8010264b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010264f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102653:	89 c2                	mov    %eax,%edx
80102655:	ec                   	in     (%dx),%al
80102656:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102659:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010265d:	c9                   	leave  
8010265e:	c3                   	ret    

8010265f <insl>:
{
8010265f:	55                   	push   %ebp
80102660:	89 e5                	mov    %esp,%ebp
80102662:	57                   	push   %edi
80102663:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102664:	8b 55 08             	mov    0x8(%ebp),%edx
80102667:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010266a:	8b 45 10             	mov    0x10(%ebp),%eax
8010266d:	89 cb                	mov    %ecx,%ebx
8010266f:	89 df                	mov    %ebx,%edi
80102671:	89 c1                	mov    %eax,%ecx
80102673:	fc                   	cld    
80102674:	f3 6d                	rep insl (%dx),%es:(%edi)
80102676:	89 c8                	mov    %ecx,%eax
80102678:	89 fb                	mov    %edi,%ebx
8010267a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010267d:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102680:	90                   	nop
80102681:	5b                   	pop    %ebx
80102682:	5f                   	pop    %edi
80102683:	5d                   	pop    %ebp
80102684:	c3                   	ret    

80102685 <outb>:
{
80102685:	55                   	push   %ebp
80102686:	89 e5                	mov    %esp,%ebp
80102688:	83 ec 08             	sub    $0x8,%esp
8010268b:	8b 45 08             	mov    0x8(%ebp),%eax
8010268e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102691:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102695:	89 d0                	mov    %edx,%eax
80102697:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010269a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010269e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801026a2:	ee                   	out    %al,(%dx)
}
801026a3:	90                   	nop
801026a4:	c9                   	leave  
801026a5:	c3                   	ret    

801026a6 <outsl>:
{
801026a6:	55                   	push   %ebp
801026a7:	89 e5                	mov    %esp,%ebp
801026a9:	56                   	push   %esi
801026aa:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801026ab:	8b 55 08             	mov    0x8(%ebp),%edx
801026ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026b1:	8b 45 10             	mov    0x10(%ebp),%eax
801026b4:	89 cb                	mov    %ecx,%ebx
801026b6:	89 de                	mov    %ebx,%esi
801026b8:	89 c1                	mov    %eax,%ecx
801026ba:	fc                   	cld    
801026bb:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026bd:	89 c8                	mov    %ecx,%eax
801026bf:	89 f3                	mov    %esi,%ebx
801026c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026c4:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026c7:	90                   	nop
801026c8:	5b                   	pop    %ebx
801026c9:	5e                   	pop    %esi
801026ca:	5d                   	pop    %ebp
801026cb:	c3                   	ret    

801026cc <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026cc:	55                   	push   %ebp
801026cd:	89 e5                	mov    %esp,%ebp
801026cf:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026d2:	90                   	nop
801026d3:	68 f7 01 00 00       	push   $0x1f7
801026d8:	e8 65 ff ff ff       	call   80102642 <inb>
801026dd:	83 c4 04             	add    $0x4,%esp
801026e0:	0f b6 c0             	movzbl %al,%eax
801026e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026e9:	25 c0 00 00 00       	and    $0xc0,%eax
801026ee:	83 f8 40             	cmp    $0x40,%eax
801026f1:	75 e0                	jne    801026d3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f7:	74 11                	je     8010270a <idewait+0x3e>
801026f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026fc:	83 e0 21             	and    $0x21,%eax
801026ff:	85 c0                	test   %eax,%eax
80102701:	74 07                	je     8010270a <idewait+0x3e>
    return -1;
80102703:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102708:	eb 05                	jmp    8010270f <idewait+0x43>
  return 0;
8010270a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010270f:	c9                   	leave  
80102710:	c3                   	ret    

80102711 <ideinit>:

void
ideinit(void)
{
80102711:	55                   	push   %ebp
80102712:	89 e5                	mov    %esp,%ebp
80102714:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102717:	83 ec 08             	sub    $0x8,%esp
8010271a:	68 8f 86 10 80       	push   $0x8010868f
8010271f:	68 40 26 11 80       	push   $0x80112640
80102724:	e8 12 29 00 00       	call   8010503b <initlock>
80102729:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010272c:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80102731:	83 e8 01             	sub    $0x1,%eax
80102734:	83 ec 08             	sub    $0x8,%esp
80102737:	50                   	push   %eax
80102738:	6a 0e                	push   $0xe
8010273a:	e8 a3 04 00 00       	call   80102be2 <ioapicenable>
8010273f:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102742:	83 ec 0c             	sub    $0xc,%esp
80102745:	6a 00                	push   $0x0
80102747:	e8 80 ff ff ff       	call   801026cc <idewait>
8010274c:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010274f:	83 ec 08             	sub    $0x8,%esp
80102752:	68 f0 00 00 00       	push   $0xf0
80102757:	68 f6 01 00 00       	push   $0x1f6
8010275c:	e8 24 ff ff ff       	call   80102685 <outb>
80102761:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102764:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010276b:	eb 24                	jmp    80102791 <ideinit+0x80>
    if(inb(0x1f7) != 0){
8010276d:	83 ec 0c             	sub    $0xc,%esp
80102770:	68 f7 01 00 00       	push   $0x1f7
80102775:	e8 c8 fe ff ff       	call   80102642 <inb>
8010277a:	83 c4 10             	add    $0x10,%esp
8010277d:	84 c0                	test   %al,%al
8010277f:	74 0c                	je     8010278d <ideinit+0x7c>
      havedisk1 = 1;
80102781:	c7 05 78 26 11 80 01 	movl   $0x1,0x80112678
80102788:	00 00 00 
      break;
8010278b:	eb 0d                	jmp    8010279a <ideinit+0x89>
  for(i=0; i<1000; i++){
8010278d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102791:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102798:	7e d3                	jle    8010276d <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010279a:	83 ec 08             	sub    $0x8,%esp
8010279d:	68 e0 00 00 00       	push   $0xe0
801027a2:	68 f6 01 00 00       	push   $0x1f6
801027a7:	e8 d9 fe ff ff       	call   80102685 <outb>
801027ac:	83 c4 10             	add    $0x10,%esp
}
801027af:	90                   	nop
801027b0:	c9                   	leave  
801027b1:	c3                   	ret    

801027b2 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801027b2:	55                   	push   %ebp
801027b3:	89 e5                	mov    %esp,%ebp
801027b5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801027b8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027bc:	75 0d                	jne    801027cb <idestart+0x19>
    panic("idestart");
801027be:	83 ec 0c             	sub    $0xc,%esp
801027c1:	68 93 86 10 80       	push   $0x80108693
801027c6:	e8 ea dd ff ff       	call   801005b5 <panic>
  if(b->blockno >= FSSIZE)
801027cb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ce:	8b 40 08             	mov    0x8(%eax),%eax
801027d1:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027d6:	76 0d                	jbe    801027e5 <idestart+0x33>
    panic("incorrect blockno");
801027d8:	83 ec 0c             	sub    $0xc,%esp
801027db:	68 9c 86 10 80       	push   $0x8010869c
801027e0:	e8 d0 dd ff ff       	call   801005b5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027e5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027ec:	8b 45 08             	mov    0x8(%ebp),%eax
801027ef:	8b 50 08             	mov    0x8(%eax),%edx
801027f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f5:	0f af c2             	imul   %edx,%eax
801027f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027fb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027ff:	75 07                	jne    80102808 <idestart+0x56>
80102801:	b8 20 00 00 00       	mov    $0x20,%eax
80102806:	eb 05                	jmp    8010280d <idestart+0x5b>
80102808:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010280d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102810:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102814:	75 07                	jne    8010281d <idestart+0x6b>
80102816:	b8 30 00 00 00       	mov    $0x30,%eax
8010281b:	eb 05                	jmp    80102822 <idestart+0x70>
8010281d:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102822:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102825:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102829:	7e 0d                	jle    80102838 <idestart+0x86>
8010282b:	83 ec 0c             	sub    $0xc,%esp
8010282e:	68 93 86 10 80       	push   $0x80108693
80102833:	e8 7d dd ff ff       	call   801005b5 <panic>

  idewait(0);
80102838:	83 ec 0c             	sub    $0xc,%esp
8010283b:	6a 00                	push   $0x0
8010283d:	e8 8a fe ff ff       	call   801026cc <idewait>
80102842:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102845:	83 ec 08             	sub    $0x8,%esp
80102848:	6a 00                	push   $0x0
8010284a:	68 f6 03 00 00       	push   $0x3f6
8010284f:	e8 31 fe ff ff       	call   80102685 <outb>
80102854:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285a:	0f b6 c0             	movzbl %al,%eax
8010285d:	83 ec 08             	sub    $0x8,%esp
80102860:	50                   	push   %eax
80102861:	68 f2 01 00 00       	push   $0x1f2
80102866:	e8 1a fe ff ff       	call   80102685 <outb>
8010286b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010286e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102871:	0f b6 c0             	movzbl %al,%eax
80102874:	83 ec 08             	sub    $0x8,%esp
80102877:	50                   	push   %eax
80102878:	68 f3 01 00 00       	push   $0x1f3
8010287d:	e8 03 fe ff ff       	call   80102685 <outb>
80102882:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102888:	c1 f8 08             	sar    $0x8,%eax
8010288b:	0f b6 c0             	movzbl %al,%eax
8010288e:	83 ec 08             	sub    $0x8,%esp
80102891:	50                   	push   %eax
80102892:	68 f4 01 00 00       	push   $0x1f4
80102897:	e8 e9 fd ff ff       	call   80102685 <outb>
8010289c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010289f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028a2:	c1 f8 10             	sar    $0x10,%eax
801028a5:	0f b6 c0             	movzbl %al,%eax
801028a8:	83 ec 08             	sub    $0x8,%esp
801028ab:	50                   	push   %eax
801028ac:	68 f5 01 00 00       	push   $0x1f5
801028b1:	e8 cf fd ff ff       	call   80102685 <outb>
801028b6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028b9:	8b 45 08             	mov    0x8(%ebp),%eax
801028bc:	8b 40 04             	mov    0x4(%eax),%eax
801028bf:	c1 e0 04             	shl    $0x4,%eax
801028c2:	83 e0 10             	and    $0x10,%eax
801028c5:	89 c2                	mov    %eax,%edx
801028c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ca:	c1 f8 18             	sar    $0x18,%eax
801028cd:	83 e0 0f             	and    $0xf,%eax
801028d0:	09 d0                	or     %edx,%eax
801028d2:	83 c8 e0             	or     $0xffffffe0,%eax
801028d5:	0f b6 c0             	movzbl %al,%eax
801028d8:	83 ec 08             	sub    $0x8,%esp
801028db:	50                   	push   %eax
801028dc:	68 f6 01 00 00       	push   $0x1f6
801028e1:	e8 9f fd ff ff       	call   80102685 <outb>
801028e6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028e9:	8b 45 08             	mov    0x8(%ebp),%eax
801028ec:	8b 00                	mov    (%eax),%eax
801028ee:	83 e0 04             	and    $0x4,%eax
801028f1:	85 c0                	test   %eax,%eax
801028f3:	74 35                	je     8010292a <idestart+0x178>
    outb(0x1f7, write_cmd);
801028f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028f8:	0f b6 c0             	movzbl %al,%eax
801028fb:	83 ec 08             	sub    $0x8,%esp
801028fe:	50                   	push   %eax
801028ff:	68 f7 01 00 00       	push   $0x1f7
80102904:	e8 7c fd ff ff       	call   80102685 <outb>
80102909:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010290c:	8b 45 08             	mov    0x8(%ebp),%eax
8010290f:	83 c0 5c             	add    $0x5c,%eax
80102912:	83 ec 04             	sub    $0x4,%esp
80102915:	68 80 00 00 00       	push   $0x80
8010291a:	50                   	push   %eax
8010291b:	68 f0 01 00 00       	push   $0x1f0
80102920:	e8 81 fd ff ff       	call   801026a6 <outsl>
80102925:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102928:	eb 17                	jmp    80102941 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010292a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010292d:	0f b6 c0             	movzbl %al,%eax
80102930:	83 ec 08             	sub    $0x8,%esp
80102933:	50                   	push   %eax
80102934:	68 f7 01 00 00       	push   $0x1f7
80102939:	e8 47 fd ff ff       	call   80102685 <outb>
8010293e:	83 c4 10             	add    $0x10,%esp
}
80102941:	90                   	nop
80102942:	c9                   	leave  
80102943:	c3                   	ret    

80102944 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102944:	55                   	push   %ebp
80102945:	89 e5                	mov    %esp,%ebp
80102947:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010294a:	83 ec 0c             	sub    $0xc,%esp
8010294d:	68 40 26 11 80       	push   $0x80112640
80102952:	e8 06 27 00 00       	call   8010505d <acquire>
80102957:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010295a:	a1 74 26 11 80       	mov    0x80112674,%eax
8010295f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102962:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102966:	75 15                	jne    8010297d <ideintr+0x39>
    release(&idelock);
80102968:	83 ec 0c             	sub    $0xc,%esp
8010296b:	68 40 26 11 80       	push   $0x80112640
80102970:	e8 56 27 00 00       	call   801050cb <release>
80102975:	83 c4 10             	add    $0x10,%esp
    return;
80102978:	e9 9a 00 00 00       	jmp    80102a17 <ideintr+0xd3>
  }
  idequeue = b->qnext;
8010297d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102980:	8b 40 58             	mov    0x58(%eax),%eax
80102983:	a3 74 26 11 80       	mov    %eax,0x80112674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298b:	8b 00                	mov    (%eax),%eax
8010298d:	83 e0 04             	and    $0x4,%eax
80102990:	85 c0                	test   %eax,%eax
80102992:	75 2d                	jne    801029c1 <ideintr+0x7d>
80102994:	83 ec 0c             	sub    $0xc,%esp
80102997:	6a 01                	push   $0x1
80102999:	e8 2e fd ff ff       	call   801026cc <idewait>
8010299e:	83 c4 10             	add    $0x10,%esp
801029a1:	85 c0                	test   %eax,%eax
801029a3:	78 1c                	js     801029c1 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801029a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a8:	83 c0 5c             	add    $0x5c,%eax
801029ab:	83 ec 04             	sub    $0x4,%esp
801029ae:	68 80 00 00 00       	push   $0x80
801029b3:	50                   	push   %eax
801029b4:	68 f0 01 00 00       	push   $0x1f0
801029b9:	e8 a1 fc ff ff       	call   8010265f <insl>
801029be:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c4:	8b 00                	mov    (%eax),%eax
801029c6:	83 c8 02             	or     $0x2,%eax
801029c9:	89 c2                	mov    %eax,%edx
801029cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ce:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d3:	8b 00                	mov    (%eax),%eax
801029d5:	83 e0 fb             	and    $0xfffffffb,%eax
801029d8:	89 c2                	mov    %eax,%edx
801029da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029dd:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029df:	83 ec 0c             	sub    $0xc,%esp
801029e2:	ff 75 f4             	push   -0xc(%ebp)
801029e5:	e8 19 23 00 00       	call   80104d03 <wakeup>
801029ea:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029ed:	a1 74 26 11 80       	mov    0x80112674,%eax
801029f2:	85 c0                	test   %eax,%eax
801029f4:	74 11                	je     80102a07 <ideintr+0xc3>
    idestart(idequeue);
801029f6:	a1 74 26 11 80       	mov    0x80112674,%eax
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	50                   	push   %eax
801029ff:	e8 ae fd ff ff       	call   801027b2 <idestart>
80102a04:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a07:	83 ec 0c             	sub    $0xc,%esp
80102a0a:	68 40 26 11 80       	push   $0x80112640
80102a0f:	e8 b7 26 00 00       	call   801050cb <release>
80102a14:	83 c4 10             	add    $0x10,%esp
}
80102a17:	c9                   	leave  
80102a18:	c3                   	ret    

80102a19 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a19:	55                   	push   %ebp
80102a1a:	89 e5                	mov    %esp,%ebp
80102a1c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a22:	83 c0 0c             	add    $0xc,%eax
80102a25:	83 ec 0c             	sub    $0xc,%esp
80102a28:	50                   	push   %eax
80102a29:	e8 78 25 00 00       	call   80104fa6 <holdingsleep>
80102a2e:	83 c4 10             	add    $0x10,%esp
80102a31:	85 c0                	test   %eax,%eax
80102a33:	75 0d                	jne    80102a42 <iderw+0x29>
    panic("iderw: buf not locked");
80102a35:	83 ec 0c             	sub    $0xc,%esp
80102a38:	68 ae 86 10 80       	push   $0x801086ae
80102a3d:	e8 73 db ff ff       	call   801005b5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a42:	8b 45 08             	mov    0x8(%ebp),%eax
80102a45:	8b 00                	mov    (%eax),%eax
80102a47:	83 e0 06             	and    $0x6,%eax
80102a4a:	83 f8 02             	cmp    $0x2,%eax
80102a4d:	75 0d                	jne    80102a5c <iderw+0x43>
    panic("iderw: nothing to do");
80102a4f:	83 ec 0c             	sub    $0xc,%esp
80102a52:	68 c4 86 10 80       	push   $0x801086c4
80102a57:	e8 59 db ff ff       	call   801005b5 <panic>
  if(b->dev != 0 && !havedisk1)
80102a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5f:	8b 40 04             	mov    0x4(%eax),%eax
80102a62:	85 c0                	test   %eax,%eax
80102a64:	74 16                	je     80102a7c <iderw+0x63>
80102a66:	a1 78 26 11 80       	mov    0x80112678,%eax
80102a6b:	85 c0                	test   %eax,%eax
80102a6d:	75 0d                	jne    80102a7c <iderw+0x63>
    panic("iderw: ide disk 1 not present");
80102a6f:	83 ec 0c             	sub    $0xc,%esp
80102a72:	68 d9 86 10 80       	push   $0x801086d9
80102a77:	e8 39 db ff ff       	call   801005b5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a7c:	83 ec 0c             	sub    $0xc,%esp
80102a7f:	68 40 26 11 80       	push   $0x80112640
80102a84:	e8 d4 25 00 00       	call   8010505d <acquire>
80102a89:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a96:	c7 45 f4 74 26 11 80 	movl   $0x80112674,-0xc(%ebp)
80102a9d:	eb 0b                	jmp    80102aaa <iderw+0x91>
80102a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa2:	8b 00                	mov    (%eax),%eax
80102aa4:	83 c0 58             	add    $0x58,%eax
80102aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aad:	8b 00                	mov    (%eax),%eax
80102aaf:	85 c0                	test   %eax,%eax
80102ab1:	75 ec                	jne    80102a9f <iderw+0x86>
    ;
  *pp = b;
80102ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab6:	8b 55 08             	mov    0x8(%ebp),%edx
80102ab9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102abb:	a1 74 26 11 80       	mov    0x80112674,%eax
80102ac0:	39 45 08             	cmp    %eax,0x8(%ebp)
80102ac3:	75 23                	jne    80102ae8 <iderw+0xcf>
    idestart(b);
80102ac5:	83 ec 0c             	sub    $0xc,%esp
80102ac8:	ff 75 08             	push   0x8(%ebp)
80102acb:	e8 e2 fc ff ff       	call   801027b2 <idestart>
80102ad0:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ad3:	eb 13                	jmp    80102ae8 <iderw+0xcf>
    sleep(b, &idelock);
80102ad5:	83 ec 08             	sub    $0x8,%esp
80102ad8:	68 40 26 11 80       	push   $0x80112640
80102add:	ff 75 08             	push   0x8(%ebp)
80102ae0:	e8 37 21 00 00       	call   80104c1c <sleep>
80102ae5:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80102aeb:	8b 00                	mov    (%eax),%eax
80102aed:	83 e0 06             	and    $0x6,%eax
80102af0:	83 f8 02             	cmp    $0x2,%eax
80102af3:	75 e0                	jne    80102ad5 <iderw+0xbc>
  }


  release(&idelock);
80102af5:	83 ec 0c             	sub    $0xc,%esp
80102af8:	68 40 26 11 80       	push   $0x80112640
80102afd:	e8 c9 25 00 00       	call   801050cb <release>
80102b02:	83 c4 10             	add    $0x10,%esp
}
80102b05:	90                   	nop
80102b06:	c9                   	leave  
80102b07:	c3                   	ret    

80102b08 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b08:	55                   	push   %ebp
80102b09:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b0b:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102b10:	8b 55 08             	mov    0x8(%ebp),%edx
80102b13:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b15:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102b1a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b1d:	5d                   	pop    %ebp
80102b1e:	c3                   	ret    

80102b1f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b1f:	55                   	push   %ebp
80102b20:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b22:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102b27:	8b 55 08             	mov    0x8(%ebp),%edx
80102b2a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b2c:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102b31:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b34:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b37:	90                   	nop
80102b38:	5d                   	pop    %ebp
80102b39:	c3                   	ret    

80102b3a <ioapicinit>:

void
ioapicinit(void)
{
80102b3a:	55                   	push   %ebp
80102b3b:	89 e5                	mov    %esp,%ebp
80102b3d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b40:	c7 05 7c 26 11 80 00 	movl   $0xfec00000,0x8011267c
80102b47:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b4a:	6a 01                	push   $0x1
80102b4c:	e8 b7 ff ff ff       	call   80102b08 <ioapicread>
80102b51:	83 c4 04             	add    $0x4,%esp
80102b54:	c1 e8 10             	shr    $0x10,%eax
80102b57:	25 ff 00 00 00       	and    $0xff,%eax
80102b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b5f:	6a 00                	push   $0x0
80102b61:	e8 a2 ff ff ff       	call   80102b08 <ioapicread>
80102b66:	83 c4 04             	add    $0x4,%esp
80102b69:	c1 e8 18             	shr    $0x18,%eax
80102b6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b6f:	0f b6 05 44 2d 11 80 	movzbl 0x80112d44,%eax
80102b76:	0f b6 c0             	movzbl %al,%eax
80102b79:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102b7c:	74 10                	je     80102b8e <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b7e:	83 ec 0c             	sub    $0xc,%esp
80102b81:	68 f8 86 10 80       	push   $0x801086f8
80102b86:	e8 75 d8 ff ff       	call   80100400 <cprintf>
80102b8b:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b95:	eb 3f                	jmp    80102bd6 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9a:	83 c0 20             	add    $0x20,%eax
80102b9d:	0d 00 00 01 00       	or     $0x10000,%eax
80102ba2:	89 c2                	mov    %eax,%edx
80102ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba7:	83 c0 08             	add    $0x8,%eax
80102baa:	01 c0                	add    %eax,%eax
80102bac:	83 ec 08             	sub    $0x8,%esp
80102baf:	52                   	push   %edx
80102bb0:	50                   	push   %eax
80102bb1:	e8 69 ff ff ff       	call   80102b1f <ioapicwrite>
80102bb6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	83 c0 08             	add    $0x8,%eax
80102bbf:	01 c0                	add    %eax,%eax
80102bc1:	83 c0 01             	add    $0x1,%eax
80102bc4:	83 ec 08             	sub    $0x8,%esp
80102bc7:	6a 00                	push   $0x0
80102bc9:	50                   	push   %eax
80102bca:	e8 50 ff ff ff       	call   80102b1f <ioapicwrite>
80102bcf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102bd2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bdc:	7e b9                	jle    80102b97 <ioapicinit+0x5d>
  }
}
80102bde:	90                   	nop
80102bdf:	90                   	nop
80102be0:	c9                   	leave  
80102be1:	c3                   	ret    

80102be2 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102be2:	55                   	push   %ebp
80102be3:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102be5:	8b 45 08             	mov    0x8(%ebp),%eax
80102be8:	83 c0 20             	add    $0x20,%eax
80102beb:	89 c2                	mov    %eax,%edx
80102bed:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf0:	83 c0 08             	add    $0x8,%eax
80102bf3:	01 c0                	add    %eax,%eax
80102bf5:	52                   	push   %edx
80102bf6:	50                   	push   %eax
80102bf7:	e8 23 ff ff ff       	call   80102b1f <ioapicwrite>
80102bfc:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102bff:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c02:	c1 e0 18             	shl    $0x18,%eax
80102c05:	89 c2                	mov    %eax,%edx
80102c07:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0a:	83 c0 08             	add    $0x8,%eax
80102c0d:	01 c0                	add    %eax,%eax
80102c0f:	83 c0 01             	add    $0x1,%eax
80102c12:	52                   	push   %edx
80102c13:	50                   	push   %eax
80102c14:	e8 06 ff ff ff       	call   80102b1f <ioapicwrite>
80102c19:	83 c4 08             	add    $0x8,%esp
}
80102c1c:	90                   	nop
80102c1d:	c9                   	leave  
80102c1e:	c3                   	ret    

80102c1f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c1f:	55                   	push   %ebp
80102c20:	89 e5                	mov    %esp,%ebp
80102c22:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c25:	83 ec 08             	sub    $0x8,%esp
80102c28:	68 2a 87 10 80       	push   $0x8010872a
80102c2d:	68 80 26 11 80       	push   $0x80112680
80102c32:	e8 04 24 00 00       	call   8010503b <initlock>
80102c37:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c3a:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
80102c41:	00 00 00 
  freerange(vstart, vend);
80102c44:	83 ec 08             	sub    $0x8,%esp
80102c47:	ff 75 0c             	push   0xc(%ebp)
80102c4a:	ff 75 08             	push   0x8(%ebp)
80102c4d:	e8 2a 00 00 00       	call   80102c7c <freerange>
80102c52:	83 c4 10             	add    $0x10,%esp
}
80102c55:	90                   	nop
80102c56:	c9                   	leave  
80102c57:	c3                   	ret    

80102c58 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c58:	55                   	push   %ebp
80102c59:	89 e5                	mov    %esp,%ebp
80102c5b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c5e:	83 ec 08             	sub    $0x8,%esp
80102c61:	ff 75 0c             	push   0xc(%ebp)
80102c64:	ff 75 08             	push   0x8(%ebp)
80102c67:	e8 10 00 00 00       	call   80102c7c <freerange>
80102c6c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c6f:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
80102c76:	00 00 00 
}
80102c79:	90                   	nop
80102c7a:	c9                   	leave  
80102c7b:	c3                   	ret    

80102c7c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c7c:	55                   	push   %ebp
80102c7d:	89 e5                	mov    %esp,%ebp
80102c7f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c82:	8b 45 08             	mov    0x8(%ebp),%eax
80102c85:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c92:	eb 15                	jmp    80102ca9 <freerange+0x2d>
    kfree(p);
80102c94:	83 ec 0c             	sub    $0xc,%esp
80102c97:	ff 75 f4             	push   -0xc(%ebp)
80102c9a:	e8 1b 00 00 00       	call   80102cba <kfree>
80102c9f:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ca2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cac:	05 00 10 00 00       	add    $0x1000,%eax
80102cb1:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102cb4:	73 de                	jae    80102c94 <freerange+0x18>
}
80102cb6:	90                   	nop
80102cb7:	90                   	nop
80102cb8:	c9                   	leave  
80102cb9:	c3                   	ret    

80102cba <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cba:	55                   	push   %ebp
80102cbb:	89 e5                	mov    %esp,%ebp
80102cbd:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102cc0:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cc8:	85 c0                	test   %eax,%eax
80102cca:	75 18                	jne    80102ce4 <kfree+0x2a>
80102ccc:	81 7d 08 e0 65 11 80 	cmpl   $0x801165e0,0x8(%ebp)
80102cd3:	72 0f                	jb     80102ce4 <kfree+0x2a>
80102cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd8:	05 00 00 00 80       	add    $0x80000000,%eax
80102cdd:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ce2:	76 0d                	jbe    80102cf1 <kfree+0x37>
    panic("kfree");
80102ce4:	83 ec 0c             	sub    $0xc,%esp
80102ce7:	68 2f 87 10 80       	push   $0x8010872f
80102cec:	e8 c4 d8 ff ff       	call   801005b5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cf1:	83 ec 04             	sub    $0x4,%esp
80102cf4:	68 00 10 00 00       	push   $0x1000
80102cf9:	6a 01                	push   $0x1
80102cfb:	ff 75 08             	push   0x8(%ebp)
80102cfe:	e8 e0 25 00 00       	call   801052e3 <memset>
80102d03:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d06:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102d0b:	85 c0                	test   %eax,%eax
80102d0d:	74 10                	je     80102d1f <kfree+0x65>
    acquire(&kmem.lock);
80102d0f:	83 ec 0c             	sub    $0xc,%esp
80102d12:	68 80 26 11 80       	push   $0x80112680
80102d17:	e8 41 23 00 00       	call   8010505d <acquire>
80102d1c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d25:	8b 15 b8 26 11 80    	mov    0x801126b8,%edx
80102d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d33:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102d38:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102d3d:	85 c0                	test   %eax,%eax
80102d3f:	74 10                	je     80102d51 <kfree+0x97>
    release(&kmem.lock);
80102d41:	83 ec 0c             	sub    $0xc,%esp
80102d44:	68 80 26 11 80       	push   $0x80112680
80102d49:	e8 7d 23 00 00       	call   801050cb <release>
80102d4e:	83 c4 10             	add    $0x10,%esp
}
80102d51:	90                   	nop
80102d52:	c9                   	leave  
80102d53:	c3                   	ret    

80102d54 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d54:	55                   	push   %ebp
80102d55:	89 e5                	mov    %esp,%ebp
80102d57:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d5a:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102d5f:	85 c0                	test   %eax,%eax
80102d61:	74 10                	je     80102d73 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d63:	83 ec 0c             	sub    $0xc,%esp
80102d66:	68 80 26 11 80       	push   $0x80112680
80102d6b:	e8 ed 22 00 00       	call   8010505d <acquire>
80102d70:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d73:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d7f:	74 0a                	je     80102d8b <kalloc+0x37>
    kmem.freelist = r->next;
80102d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d84:	8b 00                	mov    (%eax),%eax
80102d86:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102d8b:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102d90:	85 c0                	test   %eax,%eax
80102d92:	74 10                	je     80102da4 <kalloc+0x50>
    release(&kmem.lock);
80102d94:	83 ec 0c             	sub    $0xc,%esp
80102d97:	68 80 26 11 80       	push   $0x80112680
80102d9c:	e8 2a 23 00 00       	call   801050cb <release>
80102da1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102da7:	c9                   	leave  
80102da8:	c3                   	ret    

80102da9 <inb>:
{
80102da9:	55                   	push   %ebp
80102daa:	89 e5                	mov    %esp,%ebp
80102dac:	83 ec 14             	sub    $0x14,%esp
80102daf:	8b 45 08             	mov    0x8(%ebp),%eax
80102db2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102db6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102dba:	89 c2                	mov    %eax,%edx
80102dbc:	ec                   	in     (%dx),%al
80102dbd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dc0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dc4:	c9                   	leave  
80102dc5:	c3                   	ret    

80102dc6 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102dc6:	55                   	push   %ebp
80102dc7:	89 e5                	mov    %esp,%ebp
80102dc9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102dcc:	6a 64                	push   $0x64
80102dce:	e8 d6 ff ff ff       	call   80102da9 <inb>
80102dd3:	83 c4 04             	add    $0x4,%esp
80102dd6:	0f b6 c0             	movzbl %al,%eax
80102dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ddf:	83 e0 01             	and    $0x1,%eax
80102de2:	85 c0                	test   %eax,%eax
80102de4:	75 0a                	jne    80102df0 <kbdgetc+0x2a>
    return -1;
80102de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102deb:	e9 23 01 00 00       	jmp    80102f13 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102df0:	6a 60                	push   $0x60
80102df2:	e8 b2 ff ff ff       	call   80102da9 <inb>
80102df7:	83 c4 04             	add    $0x4,%esp
80102dfa:	0f b6 c0             	movzbl %al,%eax
80102dfd:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e00:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e07:	75 17                	jne    80102e20 <kbdgetc+0x5a>
    shift |= E0ESC;
80102e09:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e0e:	83 c8 40             	or     $0x40,%eax
80102e11:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102e16:	b8 00 00 00 00       	mov    $0x0,%eax
80102e1b:	e9 f3 00 00 00       	jmp    80102f13 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e20:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e23:	25 80 00 00 00       	and    $0x80,%eax
80102e28:	85 c0                	test   %eax,%eax
80102e2a:	74 45                	je     80102e71 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e2c:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e31:	83 e0 40             	and    $0x40,%eax
80102e34:	85 c0                	test   %eax,%eax
80102e36:	75 08                	jne    80102e40 <kbdgetc+0x7a>
80102e38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e3b:	83 e0 7f             	and    $0x7f,%eax
80102e3e:	eb 03                	jmp    80102e43 <kbdgetc+0x7d>
80102e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e43:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e49:	05 20 90 10 80       	add    $0x80109020,%eax
80102e4e:	0f b6 00             	movzbl (%eax),%eax
80102e51:	83 c8 40             	or     $0x40,%eax
80102e54:	0f b6 c0             	movzbl %al,%eax
80102e57:	f7 d0                	not    %eax
80102e59:	89 c2                	mov    %eax,%edx
80102e5b:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e60:	21 d0                	and    %edx,%eax
80102e62:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102e67:	b8 00 00 00 00       	mov    $0x0,%eax
80102e6c:	e9 a2 00 00 00       	jmp    80102f13 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e71:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e76:	83 e0 40             	and    $0x40,%eax
80102e79:	85 c0                	test   %eax,%eax
80102e7b:	74 14                	je     80102e91 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e7d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e84:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e89:	83 e0 bf             	and    $0xffffffbf,%eax
80102e8c:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  }

  shift |= shiftcode[data];
80102e91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e94:	05 20 90 10 80       	add    $0x80109020,%eax
80102e99:	0f b6 00             	movzbl (%eax),%eax
80102e9c:	0f b6 d0             	movzbl %al,%edx
80102e9f:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102ea4:	09 d0                	or     %edx,%eax
80102ea6:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  shift ^= togglecode[data];
80102eab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eae:	05 20 91 10 80       	add    $0x80109120,%eax
80102eb3:	0f b6 00             	movzbl (%eax),%eax
80102eb6:	0f b6 d0             	movzbl %al,%edx
80102eb9:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102ebe:	31 d0                	xor    %edx,%eax
80102ec0:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102ec5:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102eca:	83 e0 03             	and    $0x3,%eax
80102ecd:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102ed4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed7:	01 d0                	add    %edx,%eax
80102ed9:	0f b6 00             	movzbl (%eax),%eax
80102edc:	0f b6 c0             	movzbl %al,%eax
80102edf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ee2:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102ee7:	83 e0 08             	and    $0x8,%eax
80102eea:	85 c0                	test   %eax,%eax
80102eec:	74 22                	je     80102f10 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102eee:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ef2:	76 0c                	jbe    80102f00 <kbdgetc+0x13a>
80102ef4:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ef8:	77 06                	ja     80102f00 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102efa:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102efe:	eb 10                	jmp    80102f10 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f00:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f04:	76 0a                	jbe    80102f10 <kbdgetc+0x14a>
80102f06:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f0a:	77 04                	ja     80102f10 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f0c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f10:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f13:	c9                   	leave  
80102f14:	c3                   	ret    

80102f15 <kbdintr>:

void
kbdintr(void)
{
80102f15:	55                   	push   %ebp
80102f16:	89 e5                	mov    %esp,%ebp
80102f18:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f1b:	83 ec 0c             	sub    $0xc,%esp
80102f1e:	68 c6 2d 10 80       	push   $0x80102dc6
80102f23:	e8 27 d9 ff ff       	call   8010084f <consoleintr>
80102f28:	83 c4 10             	add    $0x10,%esp
}
80102f2b:	90                   	nop
80102f2c:	c9                   	leave  
80102f2d:	c3                   	ret    

80102f2e <inb>:
{
80102f2e:	55                   	push   %ebp
80102f2f:	89 e5                	mov    %esp,%ebp
80102f31:	83 ec 14             	sub    $0x14,%esp
80102f34:	8b 45 08             	mov    0x8(%ebp),%eax
80102f37:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f3b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f3f:	89 c2                	mov    %eax,%edx
80102f41:	ec                   	in     (%dx),%al
80102f42:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f45:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f49:	c9                   	leave  
80102f4a:	c3                   	ret    

80102f4b <outb>:
{
80102f4b:	55                   	push   %ebp
80102f4c:	89 e5                	mov    %esp,%ebp
80102f4e:	83 ec 08             	sub    $0x8,%esp
80102f51:	8b 45 08             	mov    0x8(%ebp),%eax
80102f54:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f5b:	89 d0                	mov    %edx,%eax
80102f5d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f60:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f64:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f68:	ee                   	out    %al,(%dx)
}
80102f69:	90                   	nop
80102f6a:	c9                   	leave  
80102f6b:	c3                   	ret    

80102f6c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f6c:	55                   	push   %ebp
80102f6d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f6f:	8b 15 c0 26 11 80    	mov    0x801126c0,%edx
80102f75:	8b 45 08             	mov    0x8(%ebp),%eax
80102f78:	c1 e0 02             	shl    $0x2,%eax
80102f7b:	01 c2                	add    %eax,%edx
80102f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f80:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f82:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f87:	83 c0 20             	add    $0x20,%eax
80102f8a:	8b 00                	mov    (%eax),%eax
}
80102f8c:	90                   	nop
80102f8d:	5d                   	pop    %ebp
80102f8e:	c3                   	ret    

80102f8f <lapicinit>:

void
lapicinit(void)
{
80102f8f:	55                   	push   %ebp
80102f90:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102f92:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f97:	85 c0                	test   %eax,%eax
80102f99:	0f 84 0c 01 00 00    	je     801030ab <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f9f:	68 3f 01 00 00       	push   $0x13f
80102fa4:	6a 3c                	push   $0x3c
80102fa6:	e8 c1 ff ff ff       	call   80102f6c <lapicw>
80102fab:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102fae:	6a 0b                	push   $0xb
80102fb0:	68 f8 00 00 00       	push   $0xf8
80102fb5:	e8 b2 ff ff ff       	call   80102f6c <lapicw>
80102fba:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102fbd:	68 20 00 02 00       	push   $0x20020
80102fc2:	68 c8 00 00 00       	push   $0xc8
80102fc7:	e8 a0 ff ff ff       	call   80102f6c <lapicw>
80102fcc:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102fcf:	68 80 96 98 00       	push   $0x989680
80102fd4:	68 e0 00 00 00       	push   $0xe0
80102fd9:	e8 8e ff ff ff       	call   80102f6c <lapicw>
80102fde:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102fe1:	68 00 00 01 00       	push   $0x10000
80102fe6:	68 d4 00 00 00       	push   $0xd4
80102feb:	e8 7c ff ff ff       	call   80102f6c <lapicw>
80102ff0:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102ff3:	68 00 00 01 00       	push   $0x10000
80102ff8:	68 d8 00 00 00       	push   $0xd8
80102ffd:	e8 6a ff ff ff       	call   80102f6c <lapicw>
80103002:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103005:	a1 c0 26 11 80       	mov    0x801126c0,%eax
8010300a:	83 c0 30             	add    $0x30,%eax
8010300d:	8b 00                	mov    (%eax),%eax
8010300f:	c1 e8 10             	shr    $0x10,%eax
80103012:	25 fc 00 00 00       	and    $0xfc,%eax
80103017:	85 c0                	test   %eax,%eax
80103019:	74 12                	je     8010302d <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
8010301b:	68 00 00 01 00       	push   $0x10000
80103020:	68 d0 00 00 00       	push   $0xd0
80103025:	e8 42 ff ff ff       	call   80102f6c <lapicw>
8010302a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010302d:	6a 33                	push   $0x33
8010302f:	68 dc 00 00 00       	push   $0xdc
80103034:	e8 33 ff ff ff       	call   80102f6c <lapicw>
80103039:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010303c:	6a 00                	push   $0x0
8010303e:	68 a0 00 00 00       	push   $0xa0
80103043:	e8 24 ff ff ff       	call   80102f6c <lapicw>
80103048:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010304b:	6a 00                	push   $0x0
8010304d:	68 a0 00 00 00       	push   $0xa0
80103052:	e8 15 ff ff ff       	call   80102f6c <lapicw>
80103057:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010305a:	6a 00                	push   $0x0
8010305c:	6a 2c                	push   $0x2c
8010305e:	e8 09 ff ff ff       	call   80102f6c <lapicw>
80103063:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103066:	6a 00                	push   $0x0
80103068:	68 c4 00 00 00       	push   $0xc4
8010306d:	e8 fa fe ff ff       	call   80102f6c <lapicw>
80103072:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103075:	68 00 85 08 00       	push   $0x88500
8010307a:	68 c0 00 00 00       	push   $0xc0
8010307f:	e8 e8 fe ff ff       	call   80102f6c <lapicw>
80103084:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103087:	90                   	nop
80103088:	a1 c0 26 11 80       	mov    0x801126c0,%eax
8010308d:	05 00 03 00 00       	add    $0x300,%eax
80103092:	8b 00                	mov    (%eax),%eax
80103094:	25 00 10 00 00       	and    $0x1000,%eax
80103099:	85 c0                	test   %eax,%eax
8010309b:	75 eb                	jne    80103088 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010309d:	6a 00                	push   $0x0
8010309f:	6a 20                	push   $0x20
801030a1:	e8 c6 fe ff ff       	call   80102f6c <lapicw>
801030a6:	83 c4 08             	add    $0x8,%esp
801030a9:	eb 01                	jmp    801030ac <lapicinit+0x11d>
    return;
801030ab:	90                   	nop
}
801030ac:	c9                   	leave  
801030ad:	c3                   	ret    

801030ae <lapicid>:

int
lapicid(void)
{
801030ae:	55                   	push   %ebp
801030af:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801030b1:	a1 c0 26 11 80       	mov    0x801126c0,%eax
801030b6:	85 c0                	test   %eax,%eax
801030b8:	75 07                	jne    801030c1 <lapicid+0x13>
    return 0;
801030ba:	b8 00 00 00 00       	mov    $0x0,%eax
801030bf:	eb 0d                	jmp    801030ce <lapicid+0x20>
  return lapic[ID] >> 24;
801030c1:	a1 c0 26 11 80       	mov    0x801126c0,%eax
801030c6:	83 c0 20             	add    $0x20,%eax
801030c9:	8b 00                	mov    (%eax),%eax
801030cb:	c1 e8 18             	shr    $0x18,%eax
}
801030ce:	5d                   	pop    %ebp
801030cf:	c3                   	ret    

801030d0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030d0:	55                   	push   %ebp
801030d1:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030d3:	a1 c0 26 11 80       	mov    0x801126c0,%eax
801030d8:	85 c0                	test   %eax,%eax
801030da:	74 0c                	je     801030e8 <lapiceoi+0x18>
    lapicw(EOI, 0);
801030dc:	6a 00                	push   $0x0
801030de:	6a 2c                	push   $0x2c
801030e0:	e8 87 fe ff ff       	call   80102f6c <lapicw>
801030e5:	83 c4 08             	add    $0x8,%esp
}
801030e8:	90                   	nop
801030e9:	c9                   	leave  
801030ea:	c3                   	ret    

801030eb <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030eb:	55                   	push   %ebp
801030ec:	89 e5                	mov    %esp,%ebp
}
801030ee:	90                   	nop
801030ef:	5d                   	pop    %ebp
801030f0:	c3                   	ret    

801030f1 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030f1:	55                   	push   %ebp
801030f2:	89 e5                	mov    %esp,%ebp
801030f4:	83 ec 14             	sub    $0x14,%esp
801030f7:	8b 45 08             	mov    0x8(%ebp),%eax
801030fa:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030fd:	6a 0f                	push   $0xf
801030ff:	6a 70                	push   $0x70
80103101:	e8 45 fe ff ff       	call   80102f4b <outb>
80103106:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103109:	6a 0a                	push   $0xa
8010310b:	6a 71                	push   $0x71
8010310d:	e8 39 fe ff ff       	call   80102f4b <outb>
80103112:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103115:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010311c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010311f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103124:	8b 45 0c             	mov    0xc(%ebp),%eax
80103127:	c1 e8 04             	shr    $0x4,%eax
8010312a:	89 c2                	mov    %eax,%edx
8010312c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010312f:	83 c0 02             	add    $0x2,%eax
80103132:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103135:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103139:	c1 e0 18             	shl    $0x18,%eax
8010313c:	50                   	push   %eax
8010313d:	68 c4 00 00 00       	push   $0xc4
80103142:	e8 25 fe ff ff       	call   80102f6c <lapicw>
80103147:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010314a:	68 00 c5 00 00       	push   $0xc500
8010314f:	68 c0 00 00 00       	push   $0xc0
80103154:	e8 13 fe ff ff       	call   80102f6c <lapicw>
80103159:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010315c:	68 c8 00 00 00       	push   $0xc8
80103161:	e8 85 ff ff ff       	call   801030eb <microdelay>
80103166:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103169:	68 00 85 00 00       	push   $0x8500
8010316e:	68 c0 00 00 00       	push   $0xc0
80103173:	e8 f4 fd ff ff       	call   80102f6c <lapicw>
80103178:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010317b:	6a 64                	push   $0x64
8010317d:	e8 69 ff ff ff       	call   801030eb <microdelay>
80103182:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103185:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010318c:	eb 3d                	jmp    801031cb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
8010318e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103192:	c1 e0 18             	shl    $0x18,%eax
80103195:	50                   	push   %eax
80103196:	68 c4 00 00 00       	push   $0xc4
8010319b:	e8 cc fd ff ff       	call   80102f6c <lapicw>
801031a0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801031a6:	c1 e8 0c             	shr    $0xc,%eax
801031a9:	80 cc 06             	or     $0x6,%ah
801031ac:	50                   	push   %eax
801031ad:	68 c0 00 00 00       	push   $0xc0
801031b2:	e8 b5 fd ff ff       	call   80102f6c <lapicw>
801031b7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801031ba:	68 c8 00 00 00       	push   $0xc8
801031bf:	e8 27 ff ff ff       	call   801030eb <microdelay>
801031c4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801031c7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031cb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031cf:	7e bd                	jle    8010318e <lapicstartap+0x9d>
  }
}
801031d1:	90                   	nop
801031d2:	90                   	nop
801031d3:	c9                   	leave  
801031d4:	c3                   	ret    

801031d5 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801031d5:	55                   	push   %ebp
801031d6:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031d8:	8b 45 08             	mov    0x8(%ebp),%eax
801031db:	0f b6 c0             	movzbl %al,%eax
801031de:	50                   	push   %eax
801031df:	6a 70                	push   $0x70
801031e1:	e8 65 fd ff ff       	call   80102f4b <outb>
801031e6:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031e9:	68 c8 00 00 00       	push   $0xc8
801031ee:	e8 f8 fe ff ff       	call   801030eb <microdelay>
801031f3:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031f6:	6a 71                	push   $0x71
801031f8:	e8 31 fd ff ff       	call   80102f2e <inb>
801031fd:	83 c4 04             	add    $0x4,%esp
80103200:	0f b6 c0             	movzbl %al,%eax
}
80103203:	c9                   	leave  
80103204:	c3                   	ret    

80103205 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103208:	6a 00                	push   $0x0
8010320a:	e8 c6 ff ff ff       	call   801031d5 <cmos_read>
8010320f:	83 c4 04             	add    $0x4,%esp
80103212:	8b 55 08             	mov    0x8(%ebp),%edx
80103215:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103217:	6a 02                	push   $0x2
80103219:	e8 b7 ff ff ff       	call   801031d5 <cmos_read>
8010321e:	83 c4 04             	add    $0x4,%esp
80103221:	8b 55 08             	mov    0x8(%ebp),%edx
80103224:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103227:	6a 04                	push   $0x4
80103229:	e8 a7 ff ff ff       	call   801031d5 <cmos_read>
8010322e:	83 c4 04             	add    $0x4,%esp
80103231:	8b 55 08             	mov    0x8(%ebp),%edx
80103234:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103237:	6a 07                	push   $0x7
80103239:	e8 97 ff ff ff       	call   801031d5 <cmos_read>
8010323e:	83 c4 04             	add    $0x4,%esp
80103241:	8b 55 08             	mov    0x8(%ebp),%edx
80103244:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103247:	6a 08                	push   $0x8
80103249:	e8 87 ff ff ff       	call   801031d5 <cmos_read>
8010324e:	83 c4 04             	add    $0x4,%esp
80103251:	8b 55 08             	mov    0x8(%ebp),%edx
80103254:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103257:	6a 09                	push   $0x9
80103259:	e8 77 ff ff ff       	call   801031d5 <cmos_read>
8010325e:	83 c4 04             	add    $0x4,%esp
80103261:	8b 55 08             	mov    0x8(%ebp),%edx
80103264:	89 42 14             	mov    %eax,0x14(%edx)
}
80103267:	90                   	nop
80103268:	c9                   	leave  
80103269:	c3                   	ret    

8010326a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
8010326a:	55                   	push   %ebp
8010326b:	89 e5                	mov    %esp,%ebp
8010326d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103270:	6a 0b                	push   $0xb
80103272:	e8 5e ff ff ff       	call   801031d5 <cmos_read>
80103277:	83 c4 04             	add    $0x4,%esp
8010327a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010327d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103280:	83 e0 04             	and    $0x4,%eax
80103283:	85 c0                	test   %eax,%eax
80103285:	0f 94 c0             	sete   %al
80103288:	0f b6 c0             	movzbl %al,%eax
8010328b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010328e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103291:	50                   	push   %eax
80103292:	e8 6e ff ff ff       	call   80103205 <fill_rtcdate>
80103297:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010329a:	6a 0a                	push   $0xa
8010329c:	e8 34 ff ff ff       	call   801031d5 <cmos_read>
801032a1:	83 c4 04             	add    $0x4,%esp
801032a4:	25 80 00 00 00       	and    $0x80,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	75 27                	jne    801032d4 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801032ad:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032b0:	50                   	push   %eax
801032b1:	e8 4f ff ff ff       	call   80103205 <fill_rtcdate>
801032b6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801032b9:	83 ec 04             	sub    $0x4,%esp
801032bc:	6a 18                	push   $0x18
801032be:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032c1:	50                   	push   %eax
801032c2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032c5:	50                   	push   %eax
801032c6:	e8 7f 20 00 00       	call   8010534a <memcmp>
801032cb:	83 c4 10             	add    $0x10,%esp
801032ce:	85 c0                	test   %eax,%eax
801032d0:	74 05                	je     801032d7 <cmostime+0x6d>
801032d2:	eb ba                	jmp    8010328e <cmostime+0x24>
        continue;
801032d4:	90                   	nop
    fill_rtcdate(&t1);
801032d5:	eb b7                	jmp    8010328e <cmostime+0x24>
      break;
801032d7:	90                   	nop
  }

  // convert
  if(bcd) {
801032d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032dc:	0f 84 b4 00 00 00    	je     80103396 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032e5:	c1 e8 04             	shr    $0x4,%eax
801032e8:	89 c2                	mov    %eax,%edx
801032ea:	89 d0                	mov    %edx,%eax
801032ec:	c1 e0 02             	shl    $0x2,%eax
801032ef:	01 d0                	add    %edx,%eax
801032f1:	01 c0                	add    %eax,%eax
801032f3:	89 c2                	mov    %eax,%edx
801032f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032f8:	83 e0 0f             	and    $0xf,%eax
801032fb:	01 d0                	add    %edx,%eax
801032fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103300:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103303:	c1 e8 04             	shr    $0x4,%eax
80103306:	89 c2                	mov    %eax,%edx
80103308:	89 d0                	mov    %edx,%eax
8010330a:	c1 e0 02             	shl    $0x2,%eax
8010330d:	01 d0                	add    %edx,%eax
8010330f:	01 c0                	add    %eax,%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103316:	83 e0 0f             	and    $0xf,%eax
80103319:	01 d0                	add    %edx,%eax
8010331b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010331e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103321:	c1 e8 04             	shr    $0x4,%eax
80103324:	89 c2                	mov    %eax,%edx
80103326:	89 d0                	mov    %edx,%eax
80103328:	c1 e0 02             	shl    $0x2,%eax
8010332b:	01 d0                	add    %edx,%eax
8010332d:	01 c0                	add    %eax,%eax
8010332f:	89 c2                	mov    %eax,%edx
80103331:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103334:	83 e0 0f             	and    $0xf,%eax
80103337:	01 d0                	add    %edx,%eax
80103339:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010333c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010333f:	c1 e8 04             	shr    $0x4,%eax
80103342:	89 c2                	mov    %eax,%edx
80103344:	89 d0                	mov    %edx,%eax
80103346:	c1 e0 02             	shl    $0x2,%eax
80103349:	01 d0                	add    %edx,%eax
8010334b:	01 c0                	add    %eax,%eax
8010334d:	89 c2                	mov    %eax,%edx
8010334f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103352:	83 e0 0f             	and    $0xf,%eax
80103355:	01 d0                	add    %edx,%eax
80103357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010335a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010335d:	c1 e8 04             	shr    $0x4,%eax
80103360:	89 c2                	mov    %eax,%edx
80103362:	89 d0                	mov    %edx,%eax
80103364:	c1 e0 02             	shl    $0x2,%eax
80103367:	01 d0                	add    %edx,%eax
80103369:	01 c0                	add    %eax,%eax
8010336b:	89 c2                	mov    %eax,%edx
8010336d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103370:	83 e0 0f             	and    $0xf,%eax
80103373:	01 d0                	add    %edx,%eax
80103375:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103378:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010337b:	c1 e8 04             	shr    $0x4,%eax
8010337e:	89 c2                	mov    %eax,%edx
80103380:	89 d0                	mov    %edx,%eax
80103382:	c1 e0 02             	shl    $0x2,%eax
80103385:	01 d0                	add    %edx,%eax
80103387:	01 c0                	add    %eax,%eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010338e:	83 e0 0f             	and    $0xf,%eax
80103391:	01 d0                	add    %edx,%eax
80103393:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103396:	8b 45 08             	mov    0x8(%ebp),%eax
80103399:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010339c:	89 10                	mov    %edx,(%eax)
8010339e:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033a1:	89 50 04             	mov    %edx,0x4(%eax)
801033a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033a7:	89 50 08             	mov    %edx,0x8(%eax)
801033aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033ad:	89 50 0c             	mov    %edx,0xc(%eax)
801033b0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033b3:	89 50 10             	mov    %edx,0x10(%eax)
801033b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033b9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033bc:	8b 45 08             	mov    0x8(%ebp),%eax
801033bf:	8b 40 14             	mov    0x14(%eax),%eax
801033c2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033c8:	8b 45 08             	mov    0x8(%ebp),%eax
801033cb:	89 50 14             	mov    %edx,0x14(%eax)
}
801033ce:	90                   	nop
801033cf:	c9                   	leave  
801033d0:	c3                   	ret    

801033d1 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033d1:	55                   	push   %ebp
801033d2:	89 e5                	mov    %esp,%ebp
801033d4:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	68 35 87 10 80       	push   $0x80108735
801033df:	68 e0 26 11 80       	push   $0x801126e0
801033e4:	e8 52 1c 00 00       	call   8010503b <initlock>
801033e9:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033ec:	83 ec 08             	sub    $0x8,%esp
801033ef:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033f2:	50                   	push   %eax
801033f3:	ff 75 08             	push   0x8(%ebp)
801033f6:	e8 d4 e0 ff ff       	call   801014cf <readsb>
801033fb:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103401:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80103406:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103409:	a3 18 27 11 80       	mov    %eax,0x80112718
  log.dev = dev;
8010340e:	8b 45 08             	mov    0x8(%ebp),%eax
80103411:	a3 24 27 11 80       	mov    %eax,0x80112724
  recover_from_log();
80103416:	e8 b3 01 00 00       	call   801035ce <recover_from_log>
}
8010341b:	90                   	nop
8010341c:	c9                   	leave  
8010341d:	c3                   	ret    

8010341e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010341e:	55                   	push   %ebp
8010341f:	89 e5                	mov    %esp,%ebp
80103421:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103424:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010342b:	e9 95 00 00 00       	jmp    801034c5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103430:	8b 15 14 27 11 80    	mov    0x80112714,%edx
80103436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103439:	01 d0                	add    %edx,%eax
8010343b:	83 c0 01             	add    $0x1,%eax
8010343e:	89 c2                	mov    %eax,%edx
80103440:	a1 24 27 11 80       	mov    0x80112724,%eax
80103445:	83 ec 08             	sub    $0x8,%esp
80103448:	52                   	push   %edx
80103449:	50                   	push   %eax
8010344a:	e8 80 cd ff ff       	call   801001cf <bread>
8010344f:	83 c4 10             	add    $0x10,%esp
80103452:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103458:	83 c0 10             	add    $0x10,%eax
8010345b:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
80103462:	89 c2                	mov    %eax,%edx
80103464:	a1 24 27 11 80       	mov    0x80112724,%eax
80103469:	83 ec 08             	sub    $0x8,%esp
8010346c:	52                   	push   %edx
8010346d:	50                   	push   %eax
8010346e:	e8 5c cd ff ff       	call   801001cf <bread>
80103473:	83 c4 10             	add    $0x10,%esp
80103476:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010347f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103482:	83 c0 5c             	add    $0x5c,%eax
80103485:	83 ec 04             	sub    $0x4,%esp
80103488:	68 00 02 00 00       	push   $0x200
8010348d:	52                   	push   %edx
8010348e:	50                   	push   %eax
8010348f:	e8 0e 1f 00 00       	call   801053a2 <memmove>
80103494:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103497:	83 ec 0c             	sub    $0xc,%esp
8010349a:	ff 75 ec             	push   -0x14(%ebp)
8010349d:	e8 66 cd ff ff       	call   80100208 <bwrite>
801034a2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801034a5:	83 ec 0c             	sub    $0xc,%esp
801034a8:	ff 75 f0             	push   -0x10(%ebp)
801034ab:	e8 a1 cd ff ff       	call   80100251 <brelse>
801034b0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801034b3:	83 ec 0c             	sub    $0xc,%esp
801034b6:	ff 75 ec             	push   -0x14(%ebp)
801034b9:	e8 93 cd ff ff       	call   80100251 <brelse>
801034be:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801034c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034c5:	a1 28 27 11 80       	mov    0x80112728,%eax
801034ca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034cd:	0f 8c 5d ff ff ff    	jl     80103430 <install_trans+0x12>
  }
}
801034d3:	90                   	nop
801034d4:	90                   	nop
801034d5:	c9                   	leave  
801034d6:	c3                   	ret    

801034d7 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034d7:	55                   	push   %ebp
801034d8:	89 e5                	mov    %esp,%ebp
801034da:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034dd:	a1 14 27 11 80       	mov    0x80112714,%eax
801034e2:	89 c2                	mov    %eax,%edx
801034e4:	a1 24 27 11 80       	mov    0x80112724,%eax
801034e9:	83 ec 08             	sub    $0x8,%esp
801034ec:	52                   	push   %edx
801034ed:	50                   	push   %eax
801034ee:	e8 dc cc ff ff       	call   801001cf <bread>
801034f3:	83 c4 10             	add    $0x10,%esp
801034f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034fc:	83 c0 5c             	add    $0x5c,%eax
801034ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103502:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103505:	8b 00                	mov    (%eax),%eax
80103507:	a3 28 27 11 80       	mov    %eax,0x80112728
  for (i = 0; i < log.lh.n; i++) {
8010350c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103513:	eb 1b                	jmp    80103530 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103515:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103518:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010351b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010351f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103522:	83 c2 10             	add    $0x10,%edx
80103525:	89 04 95 ec 26 11 80 	mov    %eax,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010352c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103530:	a1 28 27 11 80       	mov    0x80112728,%eax
80103535:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103538:	7c db                	jl     80103515 <read_head+0x3e>
  }
  brelse(buf);
8010353a:	83 ec 0c             	sub    $0xc,%esp
8010353d:	ff 75 f0             	push   -0x10(%ebp)
80103540:	e8 0c cd ff ff       	call   80100251 <brelse>
80103545:	83 c4 10             	add    $0x10,%esp
}
80103548:	90                   	nop
80103549:	c9                   	leave  
8010354a:	c3                   	ret    

8010354b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010354b:	55                   	push   %ebp
8010354c:	89 e5                	mov    %esp,%ebp
8010354e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103551:	a1 14 27 11 80       	mov    0x80112714,%eax
80103556:	89 c2                	mov    %eax,%edx
80103558:	a1 24 27 11 80       	mov    0x80112724,%eax
8010355d:	83 ec 08             	sub    $0x8,%esp
80103560:	52                   	push   %edx
80103561:	50                   	push   %eax
80103562:	e8 68 cc ff ff       	call   801001cf <bread>
80103567:	83 c4 10             	add    $0x10,%esp
8010356a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010356d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103570:	83 c0 5c             	add    $0x5c,%eax
80103573:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103576:	8b 15 28 27 11 80    	mov    0x80112728,%edx
8010357c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010357f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103588:	eb 1b                	jmp    801035a5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010358a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010358d:	83 c0 10             	add    $0x10,%eax
80103590:	8b 0c 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%ecx
80103597:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010359a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010359d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801035a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a5:	a1 28 27 11 80       	mov    0x80112728,%eax
801035aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035ad:	7c db                	jl     8010358a <write_head+0x3f>
  }
  bwrite(buf);
801035af:	83 ec 0c             	sub    $0xc,%esp
801035b2:	ff 75 f0             	push   -0x10(%ebp)
801035b5:	e8 4e cc ff ff       	call   80100208 <bwrite>
801035ba:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801035bd:	83 ec 0c             	sub    $0xc,%esp
801035c0:	ff 75 f0             	push   -0x10(%ebp)
801035c3:	e8 89 cc ff ff       	call   80100251 <brelse>
801035c8:	83 c4 10             	add    $0x10,%esp
}
801035cb:	90                   	nop
801035cc:	c9                   	leave  
801035cd:	c3                   	ret    

801035ce <recover_from_log>:

static void
recover_from_log(void)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 08             	sub    $0x8,%esp
  read_head();
801035d4:	e8 fe fe ff ff       	call   801034d7 <read_head>
  install_trans(); // if committed, copy from log to disk
801035d9:	e8 40 fe ff ff       	call   8010341e <install_trans>
  log.lh.n = 0;
801035de:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
801035e5:	00 00 00 
  write_head(); // clear the log
801035e8:	e8 5e ff ff ff       	call   8010354b <write_head>
}
801035ed:	90                   	nop
801035ee:	c9                   	leave  
801035ef:	c3                   	ret    

801035f0 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035f0:	55                   	push   %ebp
801035f1:	89 e5                	mov    %esp,%ebp
801035f3:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035f6:	83 ec 0c             	sub    $0xc,%esp
801035f9:	68 e0 26 11 80       	push   $0x801126e0
801035fe:	e8 5a 1a 00 00       	call   8010505d <acquire>
80103603:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103606:	a1 20 27 11 80       	mov    0x80112720,%eax
8010360b:	85 c0                	test   %eax,%eax
8010360d:	74 17                	je     80103626 <begin_op+0x36>
      sleep(&log, &log.lock);
8010360f:	83 ec 08             	sub    $0x8,%esp
80103612:	68 e0 26 11 80       	push   $0x801126e0
80103617:	68 e0 26 11 80       	push   $0x801126e0
8010361c:	e8 fb 15 00 00       	call   80104c1c <sleep>
80103621:	83 c4 10             	add    $0x10,%esp
80103624:	eb e0                	jmp    80103606 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103626:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
8010362c:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103631:	8d 50 01             	lea    0x1(%eax),%edx
80103634:	89 d0                	mov    %edx,%eax
80103636:	c1 e0 02             	shl    $0x2,%eax
80103639:	01 d0                	add    %edx,%eax
8010363b:	01 c0                	add    %eax,%eax
8010363d:	01 c8                	add    %ecx,%eax
8010363f:	83 f8 1e             	cmp    $0x1e,%eax
80103642:	7e 17                	jle    8010365b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103644:	83 ec 08             	sub    $0x8,%esp
80103647:	68 e0 26 11 80       	push   $0x801126e0
8010364c:	68 e0 26 11 80       	push   $0x801126e0
80103651:	e8 c6 15 00 00       	call   80104c1c <sleep>
80103656:	83 c4 10             	add    $0x10,%esp
80103659:	eb ab                	jmp    80103606 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010365b:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103660:	83 c0 01             	add    $0x1,%eax
80103663:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
80103668:	83 ec 0c             	sub    $0xc,%esp
8010366b:	68 e0 26 11 80       	push   $0x801126e0
80103670:	e8 56 1a 00 00       	call   801050cb <release>
80103675:	83 c4 10             	add    $0x10,%esp
      break;
80103678:	90                   	nop
    }
  }
}
80103679:	90                   	nop
8010367a:	c9                   	leave  
8010367b:	c3                   	ret    

8010367c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010367c:	55                   	push   %ebp
8010367d:	89 e5                	mov    %esp,%ebp
8010367f:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103689:	83 ec 0c             	sub    $0xc,%esp
8010368c:	68 e0 26 11 80       	push   $0x801126e0
80103691:	e8 c7 19 00 00       	call   8010505d <acquire>
80103696:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103699:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010369e:	83 e8 01             	sub    $0x1,%eax
801036a1:	a3 1c 27 11 80       	mov    %eax,0x8011271c
  if(log.committing)
801036a6:	a1 20 27 11 80       	mov    0x80112720,%eax
801036ab:	85 c0                	test   %eax,%eax
801036ad:	74 0d                	je     801036bc <end_op+0x40>
    panic("log.committing");
801036af:	83 ec 0c             	sub    $0xc,%esp
801036b2:	68 39 87 10 80       	push   $0x80108739
801036b7:	e8 f9 ce ff ff       	call   801005b5 <panic>
  if(log.outstanding == 0){
801036bc:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801036c1:	85 c0                	test   %eax,%eax
801036c3:	75 13                	jne    801036d8 <end_op+0x5c>
    do_commit = 1;
801036c5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036cc:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
801036d3:	00 00 00 
801036d6:	eb 10                	jmp    801036e8 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801036d8:	83 ec 0c             	sub    $0xc,%esp
801036db:	68 e0 26 11 80       	push   $0x801126e0
801036e0:	e8 1e 16 00 00       	call   80104d03 <wakeup>
801036e5:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036e8:	83 ec 0c             	sub    $0xc,%esp
801036eb:	68 e0 26 11 80       	push   $0x801126e0
801036f0:	e8 d6 19 00 00       	call   801050cb <release>
801036f5:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036fc:	74 3f                	je     8010373d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036fe:	e8 f6 00 00 00       	call   801037f9 <commit>
    acquire(&log.lock);
80103703:	83 ec 0c             	sub    $0xc,%esp
80103706:	68 e0 26 11 80       	push   $0x801126e0
8010370b:	e8 4d 19 00 00       	call   8010505d <acquire>
80103710:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103713:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
8010371a:	00 00 00 
    wakeup(&log);
8010371d:	83 ec 0c             	sub    $0xc,%esp
80103720:	68 e0 26 11 80       	push   $0x801126e0
80103725:	e8 d9 15 00 00       	call   80104d03 <wakeup>
8010372a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010372d:	83 ec 0c             	sub    $0xc,%esp
80103730:	68 e0 26 11 80       	push   $0x801126e0
80103735:	e8 91 19 00 00       	call   801050cb <release>
8010373a:	83 c4 10             	add    $0x10,%esp
  }
}
8010373d:	90                   	nop
8010373e:	c9                   	leave  
8010373f:	c3                   	ret    

80103740 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103740:	55                   	push   %ebp
80103741:	89 e5                	mov    %esp,%ebp
80103743:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103746:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010374d:	e9 95 00 00 00       	jmp    801037e7 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103752:	8b 15 14 27 11 80    	mov    0x80112714,%edx
80103758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375b:	01 d0                	add    %edx,%eax
8010375d:	83 c0 01             	add    $0x1,%eax
80103760:	89 c2                	mov    %eax,%edx
80103762:	a1 24 27 11 80       	mov    0x80112724,%eax
80103767:	83 ec 08             	sub    $0x8,%esp
8010376a:	52                   	push   %edx
8010376b:	50                   	push   %eax
8010376c:	e8 5e ca ff ff       	call   801001cf <bread>
80103771:	83 c4 10             	add    $0x10,%esp
80103774:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377a:	83 c0 10             	add    $0x10,%eax
8010377d:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
80103784:	89 c2                	mov    %eax,%edx
80103786:	a1 24 27 11 80       	mov    0x80112724,%eax
8010378b:	83 ec 08             	sub    $0x8,%esp
8010378e:	52                   	push   %edx
8010378f:	50                   	push   %eax
80103790:	e8 3a ca ff ff       	call   801001cf <bread>
80103795:	83 c4 10             	add    $0x10,%esp
80103798:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010379b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010379e:	8d 50 5c             	lea    0x5c(%eax),%edx
801037a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037a4:	83 c0 5c             	add    $0x5c,%eax
801037a7:	83 ec 04             	sub    $0x4,%esp
801037aa:	68 00 02 00 00       	push   $0x200
801037af:	52                   	push   %edx
801037b0:	50                   	push   %eax
801037b1:	e8 ec 1b 00 00       	call   801053a2 <memmove>
801037b6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801037b9:	83 ec 0c             	sub    $0xc,%esp
801037bc:	ff 75 f0             	push   -0x10(%ebp)
801037bf:	e8 44 ca ff ff       	call   80100208 <bwrite>
801037c4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	ff 75 ec             	push   -0x14(%ebp)
801037cd:	e8 7f ca ff ff       	call   80100251 <brelse>
801037d2:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037d5:	83 ec 0c             	sub    $0xc,%esp
801037d8:	ff 75 f0             	push   -0x10(%ebp)
801037db:	e8 71 ca ff ff       	call   80100251 <brelse>
801037e0:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801037e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e7:	a1 28 27 11 80       	mov    0x80112728,%eax
801037ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037ef:	0f 8c 5d ff ff ff    	jl     80103752 <write_log+0x12>
  }
}
801037f5:	90                   	nop
801037f6:	90                   	nop
801037f7:	c9                   	leave  
801037f8:	c3                   	ret    

801037f9 <commit>:

static void
commit()
{
801037f9:	55                   	push   %ebp
801037fa:	89 e5                	mov    %esp,%ebp
801037fc:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037ff:	a1 28 27 11 80       	mov    0x80112728,%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	7e 1e                	jle    80103826 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103808:	e8 33 ff ff ff       	call   80103740 <write_log>
    write_head();    // Write header to disk -- the real commit
8010380d:	e8 39 fd ff ff       	call   8010354b <write_head>
    install_trans(); // Now install writes to home locations
80103812:	e8 07 fc ff ff       	call   8010341e <install_trans>
    log.lh.n = 0;
80103817:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
8010381e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103821:	e8 25 fd ff ff       	call   8010354b <write_head>
  }
}
80103826:	90                   	nop
80103827:	c9                   	leave  
80103828:	c3                   	ret    

80103829 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103829:	55                   	push   %ebp
8010382a:	89 e5                	mov    %esp,%ebp
8010382c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010382f:	a1 28 27 11 80       	mov    0x80112728,%eax
80103834:	83 f8 1d             	cmp    $0x1d,%eax
80103837:	7f 12                	jg     8010384b <log_write+0x22>
80103839:	a1 28 27 11 80       	mov    0x80112728,%eax
8010383e:	8b 15 18 27 11 80    	mov    0x80112718,%edx
80103844:	83 ea 01             	sub    $0x1,%edx
80103847:	39 d0                	cmp    %edx,%eax
80103849:	7c 0d                	jl     80103858 <log_write+0x2f>
    panic("too big a transaction");
8010384b:	83 ec 0c             	sub    $0xc,%esp
8010384e:	68 48 87 10 80       	push   $0x80108748
80103853:	e8 5d cd ff ff       	call   801005b5 <panic>
  if (log.outstanding < 1)
80103858:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010385d:	85 c0                	test   %eax,%eax
8010385f:	7f 0d                	jg     8010386e <log_write+0x45>
    panic("log_write outside of trans");
80103861:	83 ec 0c             	sub    $0xc,%esp
80103864:	68 5e 87 10 80       	push   $0x8010875e
80103869:	e8 47 cd ff ff       	call   801005b5 <panic>

  acquire(&log.lock);
8010386e:	83 ec 0c             	sub    $0xc,%esp
80103871:	68 e0 26 11 80       	push   $0x801126e0
80103876:	e8 e2 17 00 00       	call   8010505d <acquire>
8010387b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010387e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103885:	eb 1d                	jmp    801038a4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010388a:	83 c0 10             	add    $0x10,%eax
8010388d:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
80103894:	89 c2                	mov    %eax,%edx
80103896:	8b 45 08             	mov    0x8(%ebp),%eax
80103899:	8b 40 08             	mov    0x8(%eax),%eax
8010389c:	39 c2                	cmp    %eax,%edx
8010389e:	74 10                	je     801038b0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801038a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038a4:	a1 28 27 11 80       	mov    0x80112728,%eax
801038a9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038ac:	7c d9                	jl     80103887 <log_write+0x5e>
801038ae:	eb 01                	jmp    801038b1 <log_write+0x88>
      break;
801038b0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801038b1:	8b 45 08             	mov    0x8(%ebp),%eax
801038b4:	8b 40 08             	mov    0x8(%eax),%eax
801038b7:	89 c2                	mov    %eax,%edx
801038b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038bc:	83 c0 10             	add    $0x10,%eax
801038bf:	89 14 85 ec 26 11 80 	mov    %edx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
801038c6:	a1 28 27 11 80       	mov    0x80112728,%eax
801038cb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801038ce:	75 0d                	jne    801038dd <log_write+0xb4>
    log.lh.n++;
801038d0:	a1 28 27 11 80       	mov    0x80112728,%eax
801038d5:	83 c0 01             	add    $0x1,%eax
801038d8:	a3 28 27 11 80       	mov    %eax,0x80112728
  b->flags |= B_DIRTY; // prevent eviction
801038dd:	8b 45 08             	mov    0x8(%ebp),%eax
801038e0:	8b 00                	mov    (%eax),%eax
801038e2:	83 c8 04             	or     $0x4,%eax
801038e5:	89 c2                	mov    %eax,%edx
801038e7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ea:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038ec:	83 ec 0c             	sub    $0xc,%esp
801038ef:	68 e0 26 11 80       	push   $0x801126e0
801038f4:	e8 d2 17 00 00       	call   801050cb <release>
801038f9:	83 c4 10             	add    $0x10,%esp
}
801038fc:	90                   	nop
801038fd:	c9                   	leave  
801038fe:	c3                   	ret    

801038ff <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038ff:	55                   	push   %ebp
80103900:	89 e5                	mov    %esp,%ebp
80103902:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103905:	8b 55 08             	mov    0x8(%ebp),%edx
80103908:	8b 45 0c             	mov    0xc(%ebp),%eax
8010390b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010390e:	f0 87 02             	lock xchg %eax,(%edx)
80103911:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103914:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103917:	c9                   	leave  
80103918:	c3                   	ret    

80103919 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103919:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010391d:	83 e4 f0             	and    $0xfffffff0,%esp
80103920:	ff 71 fc             	push   -0x4(%ecx)
80103923:	55                   	push   %ebp
80103924:	89 e5                	mov    %esp,%ebp
80103926:	51                   	push   %ecx
80103927:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010392a:	83 ec 08             	sub    $0x8,%esp
8010392d:	68 00 00 40 80       	push   $0x80400000
80103932:	68 e0 65 11 80       	push   $0x801165e0
80103937:	e8 e3 f2 ff ff       	call   80102c1f <kinit1>
8010393c:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010393f:	e8 08 43 00 00       	call   80107c4c <kvmalloc>
  mpinit();        // detect other processors
80103944:	e8 bd 03 00 00       	call   80103d06 <mpinit>
  lapicinit();     // interrupt controller
80103949:	e8 41 f6 ff ff       	call   80102f8f <lapicinit>
  seginit();       // segment descriptors
8010394e:	e8 e4 3d 00 00       	call   80107737 <seginit>
  picinit();       // disable pic
80103953:	e8 15 05 00 00       	call   80103e6d <picinit>
  ioapicinit();    // another interrupt controller
80103958:	e8 dd f1 ff ff       	call   80102b3a <ioapicinit>
  consoleinit();   // console hardware
8010395d:	e8 16 d2 ff ff       	call   80100b78 <consoleinit>
  uartinit();      // serial port
80103962:	e8 69 31 00 00       	call   80106ad0 <uartinit>
  pinit();         // process table
80103967:	e8 3a 09 00 00       	call   801042a6 <pinit>
  tvinit();        // trap vectors
8010396c:	e8 3f 2d 00 00       	call   801066b0 <tvinit>
  binit();         // buffer cache
80103971:	e8 be c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103976:	e8 45 d7 ff ff       	call   801010c0 <fileinit>
  ideinit();       // disk 
8010397b:	e8 91 ed ff ff       	call   80102711 <ideinit>
  startothers();   // start other processors
80103980:	e8 80 00 00 00       	call   80103a05 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 00 00 00 8e       	push   $0x8e000000
8010398d:	68 00 00 40 80       	push   $0x80400000
80103992:	e8 c1 f2 ff ff       	call   80102c58 <kinit2>
80103997:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010399a:	e8 e5 0a 00 00       	call   80104484 <userinit>
  mpmain();        // finish this processor's setup
8010399f:	e8 1a 00 00 00       	call   801039be <mpmain>

801039a4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039a4:	55                   	push   %ebp
801039a5:	89 e5                	mov    %esp,%ebp
801039a7:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801039aa:	e8 b5 42 00 00       	call   80107c64 <switchkvm>
  seginit();
801039af:	e8 83 3d 00 00       	call   80107737 <seginit>
  lapicinit();
801039b4:	e8 d6 f5 ff ff       	call   80102f8f <lapicinit>
  mpmain();
801039b9:	e8 00 00 00 00       	call   801039be <mpmain>

801039be <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	53                   	push   %ebx
801039c2:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801039c5:	e8 fa 08 00 00       	call   801042c4 <cpuid>
801039ca:	89 c3                	mov    %eax,%ebx
801039cc:	e8 f3 08 00 00       	call   801042c4 <cpuid>
801039d1:	83 ec 04             	sub    $0x4,%esp
801039d4:	53                   	push   %ebx
801039d5:	50                   	push   %eax
801039d6:	68 79 87 10 80       	push   $0x80108779
801039db:	e8 20 ca ff ff       	call   80100400 <cprintf>
801039e0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039e3:	e8 3e 2e 00 00       	call   80106826 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039e8:	e8 f2 08 00 00       	call   801042df <mycpu>
801039ed:	05 a0 00 00 00       	add    $0xa0,%eax
801039f2:	83 ec 08             	sub    $0x8,%esp
801039f5:	6a 01                	push   $0x1
801039f7:	50                   	push   %eax
801039f8:	e8 02 ff ff ff       	call   801038ff <xchg>
801039fd:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a00:	e8 26 10 00 00       	call   80104a2b <scheduler>

80103a05 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a05:	55                   	push   %ebp
80103a06:	89 e5                	mov    %esp,%ebp
80103a08:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103a0b:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a12:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a17:	83 ec 04             	sub    $0x4,%esp
80103a1a:	50                   	push   %eax
80103a1b:	68 f0 b4 10 80       	push   $0x8010b4f0
80103a20:	ff 75 f0             	push   -0x10(%ebp)
80103a23:	e8 7a 19 00 00       	call   801053a2 <memmove>
80103a28:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a2b:	c7 45 f4 c0 27 11 80 	movl   $0x801127c0,-0xc(%ebp)
80103a32:	eb 79                	jmp    80103aad <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103a34:	e8 a6 08 00 00       	call   801042df <mycpu>
80103a39:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a3c:	74 67                	je     80103aa5 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a3e:	e8 11 f3 ff ff       	call   80102d54 <kalloc>
80103a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a49:	83 e8 04             	sub    $0x4,%eax
80103a4c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a4f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a55:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a5a:	83 e8 08             	sub    $0x8,%eax
80103a5d:	c7 00 a4 39 10 80    	movl   $0x801039a4,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a63:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
80103a68:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a71:	83 e8 0c             	sub    $0xc,%eax
80103a74:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a79:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a82:	0f b6 00             	movzbl (%eax),%eax
80103a85:	0f b6 c0             	movzbl %al,%eax
80103a88:	83 ec 08             	sub    $0x8,%esp
80103a8b:	52                   	push   %edx
80103a8c:	50                   	push   %eax
80103a8d:	e8 5f f6 ff ff       	call   801030f1 <lapicstartap>
80103a92:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a95:	90                   	nop
80103a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a99:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a9f:	85 c0                	test   %eax,%eax
80103aa1:	74 f3                	je     80103a96 <startothers+0x91>
80103aa3:	eb 01                	jmp    80103aa6 <startothers+0xa1>
      continue;
80103aa5:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103aa6:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103aad:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103ab2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ab8:	05 c0 27 11 80       	add    $0x801127c0,%eax
80103abd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ac0:	0f 82 6e ff ff ff    	jb     80103a34 <startothers+0x2f>
      ;
  }
}
80103ac6:	90                   	nop
80103ac7:	90                   	nop
80103ac8:	c9                   	leave  
80103ac9:	c3                   	ret    

80103aca <inb>:
{
80103aca:	55                   	push   %ebp
80103acb:	89 e5                	mov    %esp,%ebp
80103acd:	83 ec 14             	sub    $0x14,%esp
80103ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ad7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103adb:	89 c2                	mov    %eax,%edx
80103add:	ec                   	in     (%dx),%al
80103ade:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ae1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ae5:	c9                   	leave  
80103ae6:	c3                   	ret    

80103ae7 <outb>:
{
80103ae7:	55                   	push   %ebp
80103ae8:	89 e5                	mov    %esp,%ebp
80103aea:	83 ec 08             	sub    $0x8,%esp
80103aed:	8b 45 08             	mov    0x8(%ebp),%eax
80103af0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103af3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103af7:	89 d0                	mov    %edx,%eax
80103af9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103afc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b00:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b04:	ee                   	out    %al,(%dx)
}
80103b05:	90                   	nop
80103b06:	c9                   	leave  
80103b07:	c3                   	ret    

80103b08 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103b08:	55                   	push   %ebp
80103b09:	89 e5                	mov    %esp,%ebp
80103b0b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103b0e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b15:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b1c:	eb 15                	jmp    80103b33 <sum+0x2b>
    sum += addr[i];
80103b1e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b21:	8b 45 08             	mov    0x8(%ebp),%eax
80103b24:	01 d0                	add    %edx,%eax
80103b26:	0f b6 00             	movzbl (%eax),%eax
80103b29:	0f b6 c0             	movzbl %al,%eax
80103b2c:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b2f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b39:	7c e3                	jl     80103b1e <sum+0x16>
  return sum;
80103b3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b3e:	c9                   	leave  
80103b3f:	c3                   	ret    

80103b40 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b46:	8b 45 08             	mov    0x8(%ebp),%eax
80103b49:	05 00 00 00 80       	add    $0x80000000,%eax
80103b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b51:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b57:	01 d0                	add    %edx,%eax
80103b59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b62:	eb 36                	jmp    80103b9a <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b64:	83 ec 04             	sub    $0x4,%esp
80103b67:	6a 04                	push   $0x4
80103b69:	68 90 87 10 80       	push   $0x80108790
80103b6e:	ff 75 f4             	push   -0xc(%ebp)
80103b71:	e8 d4 17 00 00       	call   8010534a <memcmp>
80103b76:	83 c4 10             	add    $0x10,%esp
80103b79:	85 c0                	test   %eax,%eax
80103b7b:	75 19                	jne    80103b96 <mpsearch1+0x56>
80103b7d:	83 ec 08             	sub    $0x8,%esp
80103b80:	6a 10                	push   $0x10
80103b82:	ff 75 f4             	push   -0xc(%ebp)
80103b85:	e8 7e ff ff ff       	call   80103b08 <sum>
80103b8a:	83 c4 10             	add    $0x10,%esp
80103b8d:	84 c0                	test   %al,%al
80103b8f:	75 05                	jne    80103b96 <mpsearch1+0x56>
      return (struct mp*)p;
80103b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b94:	eb 11                	jmp    80103ba7 <mpsearch1+0x67>
  for(p = addr; p < e; p += sizeof(struct mp))
80103b96:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ba0:	72 c2                	jb     80103b64 <mpsearch1+0x24>
  return 0;
80103ba2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ba7:	c9                   	leave  
80103ba8:	c3                   	ret    

80103ba9 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ba9:	55                   	push   %ebp
80103baa:	89 e5                	mov    %esp,%ebp
80103bac:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103baf:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb9:	83 c0 0f             	add    $0xf,%eax
80103bbc:	0f b6 00             	movzbl (%eax),%eax
80103bbf:	0f b6 c0             	movzbl %al,%eax
80103bc2:	c1 e0 08             	shl    $0x8,%eax
80103bc5:	89 c2                	mov    %eax,%edx
80103bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bca:	83 c0 0e             	add    $0xe,%eax
80103bcd:	0f b6 00             	movzbl (%eax),%eax
80103bd0:	0f b6 c0             	movzbl %al,%eax
80103bd3:	09 d0                	or     %edx,%eax
80103bd5:	c1 e0 04             	shl    $0x4,%eax
80103bd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bdf:	74 21                	je     80103c02 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103be1:	83 ec 08             	sub    $0x8,%esp
80103be4:	68 00 04 00 00       	push   $0x400
80103be9:	ff 75 f0             	push   -0x10(%ebp)
80103bec:	e8 4f ff ff ff       	call   80103b40 <mpsearch1>
80103bf1:	83 c4 10             	add    $0x10,%esp
80103bf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bf7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bfb:	74 51                	je     80103c4e <mpsearch+0xa5>
      return mp;
80103bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c00:	eb 61                	jmp    80103c63 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c05:	83 c0 14             	add    $0x14,%eax
80103c08:	0f b6 00             	movzbl (%eax),%eax
80103c0b:	0f b6 c0             	movzbl %al,%eax
80103c0e:	c1 e0 08             	shl    $0x8,%eax
80103c11:	89 c2                	mov    %eax,%edx
80103c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c16:	83 c0 13             	add    $0x13,%eax
80103c19:	0f b6 00             	movzbl (%eax),%eax
80103c1c:	0f b6 c0             	movzbl %al,%eax
80103c1f:	09 d0                	or     %edx,%eax
80103c21:	c1 e0 0a             	shl    $0xa,%eax
80103c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2a:	2d 00 04 00 00       	sub    $0x400,%eax
80103c2f:	83 ec 08             	sub    $0x8,%esp
80103c32:	68 00 04 00 00       	push   $0x400
80103c37:	50                   	push   %eax
80103c38:	e8 03 ff ff ff       	call   80103b40 <mpsearch1>
80103c3d:	83 c4 10             	add    $0x10,%esp
80103c40:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c43:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c47:	74 05                	je     80103c4e <mpsearch+0xa5>
      return mp;
80103c49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c4c:	eb 15                	jmp    80103c63 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c4e:	83 ec 08             	sub    $0x8,%esp
80103c51:	68 00 00 01 00       	push   $0x10000
80103c56:	68 00 00 0f 00       	push   $0xf0000
80103c5b:	e8 e0 fe ff ff       	call   80103b40 <mpsearch1>
80103c60:	83 c4 10             	add    $0x10,%esp
}
80103c63:	c9                   	leave  
80103c64:	c3                   	ret    

80103c65 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c65:	55                   	push   %ebp
80103c66:	89 e5                	mov    %esp,%ebp
80103c68:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c6b:	e8 39 ff ff ff       	call   80103ba9 <mpsearch>
80103c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c77:	74 0a                	je     80103c83 <mpconfig+0x1e>
80103c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7c:	8b 40 04             	mov    0x4(%eax),%eax
80103c7f:	85 c0                	test   %eax,%eax
80103c81:	75 07                	jne    80103c8a <mpconfig+0x25>
    return 0;
80103c83:	b8 00 00 00 00       	mov    $0x0,%eax
80103c88:	eb 7a                	jmp    80103d04 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8d:	8b 40 04             	mov    0x4(%eax),%eax
80103c90:	05 00 00 00 80       	add    $0x80000000,%eax
80103c95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c98:	83 ec 04             	sub    $0x4,%esp
80103c9b:	6a 04                	push   $0x4
80103c9d:	68 95 87 10 80       	push   $0x80108795
80103ca2:	ff 75 f0             	push   -0x10(%ebp)
80103ca5:	e8 a0 16 00 00       	call   8010534a <memcmp>
80103caa:	83 c4 10             	add    $0x10,%esp
80103cad:	85 c0                	test   %eax,%eax
80103caf:	74 07                	je     80103cb8 <mpconfig+0x53>
    return 0;
80103cb1:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb6:	eb 4c                	jmp    80103d04 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cbf:	3c 01                	cmp    $0x1,%al
80103cc1:	74 12                	je     80103cd5 <mpconfig+0x70>
80103cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cca:	3c 04                	cmp    $0x4,%al
80103ccc:	74 07                	je     80103cd5 <mpconfig+0x70>
    return 0;
80103cce:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd3:	eb 2f                	jmp    80103d04 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cdc:	0f b7 c0             	movzwl %ax,%eax
80103cdf:	83 ec 08             	sub    $0x8,%esp
80103ce2:	50                   	push   %eax
80103ce3:	ff 75 f0             	push   -0x10(%ebp)
80103ce6:	e8 1d fe ff ff       	call   80103b08 <sum>
80103ceb:	83 c4 10             	add    $0x10,%esp
80103cee:	84 c0                	test   %al,%al
80103cf0:	74 07                	je     80103cf9 <mpconfig+0x94>
    return 0;
80103cf2:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf7:	eb 0b                	jmp    80103d04 <mpconfig+0x9f>
  *pmp = mp;
80103cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cff:	89 10                	mov    %edx,(%eax)
  return conf;
80103d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d04:	c9                   	leave  
80103d05:	c3                   	ret    

80103d06 <mpinit>:

void
mpinit(void)
{
80103d06:	55                   	push   %ebp
80103d07:	89 e5                	mov    %esp,%ebp
80103d09:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103d0c:	83 ec 0c             	sub    $0xc,%esp
80103d0f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103d12:	50                   	push   %eax
80103d13:	e8 4d ff ff ff       	call   80103c65 <mpconfig>
80103d18:	83 c4 10             	add    $0x10,%esp
80103d1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d22:	75 0d                	jne    80103d31 <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103d24:	83 ec 0c             	sub    $0xc,%esp
80103d27:	68 9a 87 10 80       	push   $0x8010879a
80103d2c:	e8 84 c8 ff ff       	call   801005b5 <panic>
  ismp = 1;
80103d31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d3b:	8b 40 24             	mov    0x24(%eax),%eax
80103d3e:	a3 c0 26 11 80       	mov    %eax,0x801126c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d46:	83 c0 2c             	add    $0x2c,%eax
80103d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d4f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d53:	0f b7 d0             	movzwl %ax,%edx
80103d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d59:	01 d0                	add    %edx,%eax
80103d5b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d5e:	e9 8c 00 00 00       	jmp    80103def <mpinit+0xe9>
    switch(*p){
80103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d66:	0f b6 00             	movzbl (%eax),%eax
80103d69:	0f b6 c0             	movzbl %al,%eax
80103d6c:	83 f8 04             	cmp    $0x4,%eax
80103d6f:	7f 76                	jg     80103de7 <mpinit+0xe1>
80103d71:	83 f8 03             	cmp    $0x3,%eax
80103d74:	7d 6b                	jge    80103de1 <mpinit+0xdb>
80103d76:	83 f8 02             	cmp    $0x2,%eax
80103d79:	74 4e                	je     80103dc9 <mpinit+0xc3>
80103d7b:	83 f8 02             	cmp    $0x2,%eax
80103d7e:	7f 67                	jg     80103de7 <mpinit+0xe1>
80103d80:	85 c0                	test   %eax,%eax
80103d82:	74 07                	je     80103d8b <mpinit+0x85>
80103d84:	83 f8 01             	cmp    $0x1,%eax
80103d87:	74 58                	je     80103de1 <mpinit+0xdb>
80103d89:	eb 5c                	jmp    80103de7 <mpinit+0xe1>
    case MPPROC:
      proc = (struct mpproc*)p;
80103d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103d91:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103d96:	83 f8 07             	cmp    $0x7,%eax
80103d99:	7f 28                	jg     80103dc3 <mpinit+0xbd>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d9b:	8b 15 40 2d 11 80    	mov    0x80112d40,%edx
80103da1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103da4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103da8:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103dae:	81 c2 c0 27 11 80    	add    $0x801127c0,%edx
80103db4:	88 02                	mov    %al,(%edx)
        ncpu++;
80103db6:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103dbb:	83 c0 01             	add    $0x1,%eax
80103dbe:	a3 40 2d 11 80       	mov    %eax,0x80112d40
      }
      p += sizeof(struct mpproc);
80103dc3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103dc7:	eb 26                	jmp    80103def <mpinit+0xe9>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103dcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dd2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dd6:	a2 44 2d 11 80       	mov    %al,0x80112d44
      p += sizeof(struct mpioapic);
80103ddb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ddf:	eb 0e                	jmp    80103def <mpinit+0xe9>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103de1:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103de5:	eb 08                	jmp    80103def <mpinit+0xe9>
    default:
      ismp = 0;
80103de7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103dee:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df2:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103df5:	0f 82 68 ff ff ff    	jb     80103d63 <mpinit+0x5d>
    }
  }
  if(!ismp)
80103dfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dff:	75 0d                	jne    80103e0e <mpinit+0x108>
    panic("Didn't find a suitable machine");
80103e01:	83 ec 0c             	sub    $0xc,%esp
80103e04:	68 b4 87 10 80       	push   $0x801087b4
80103e09:	e8 a7 c7 ff ff       	call   801005b5 <panic>

  if(mp->imcrp){
80103e0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e11:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e15:	84 c0                	test   %al,%al
80103e17:	74 30                	je     80103e49 <mpinit+0x143>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e19:	83 ec 08             	sub    $0x8,%esp
80103e1c:	6a 70                	push   $0x70
80103e1e:	6a 22                	push   $0x22
80103e20:	e8 c2 fc ff ff       	call   80103ae7 <outb>
80103e25:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e28:	83 ec 0c             	sub    $0xc,%esp
80103e2b:	6a 23                	push   $0x23
80103e2d:	e8 98 fc ff ff       	call   80103aca <inb>
80103e32:	83 c4 10             	add    $0x10,%esp
80103e35:	83 c8 01             	or     $0x1,%eax
80103e38:	0f b6 c0             	movzbl %al,%eax
80103e3b:	83 ec 08             	sub    $0x8,%esp
80103e3e:	50                   	push   %eax
80103e3f:	6a 23                	push   $0x23
80103e41:	e8 a1 fc ff ff       	call   80103ae7 <outb>
80103e46:	83 c4 10             	add    $0x10,%esp
  }
}
80103e49:	90                   	nop
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <outb>:
{
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	83 ec 08             	sub    $0x8,%esp
80103e52:	8b 45 08             	mov    0x8(%ebp),%eax
80103e55:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e58:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103e5c:	89 d0                	mov    %edx,%eax
80103e5e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e61:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e65:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e69:	ee                   	out    %al,(%dx)
}
80103e6a:	90                   	nop
80103e6b:	c9                   	leave  
80103e6c:	c3                   	ret    

80103e6d <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e6d:	55                   	push   %ebp
80103e6e:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e70:	68 ff 00 00 00       	push   $0xff
80103e75:	6a 21                	push   $0x21
80103e77:	e8 d0 ff ff ff       	call   80103e4c <outb>
80103e7c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103e7f:	68 ff 00 00 00       	push   $0xff
80103e84:	68 a1 00 00 00       	push   $0xa1
80103e89:	e8 be ff ff ff       	call   80103e4c <outb>
80103e8e:	83 c4 08             	add    $0x8,%esp
}
80103e91:	90                   	nop
80103e92:	c9                   	leave  
80103e93:	c3                   	ret    

80103e94 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e94:	55                   	push   %ebp
80103e95:	89 e5                	mov    %esp,%ebp
80103e97:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ead:	8b 10                	mov    (%eax),%edx
80103eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb2:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103eb4:	e8 25 d2 ff ff       	call   801010de <filealloc>
80103eb9:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebc:	89 02                	mov    %eax,(%edx)
80103ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec1:	8b 00                	mov    (%eax),%eax
80103ec3:	85 c0                	test   %eax,%eax
80103ec5:	0f 84 c8 00 00 00    	je     80103f93 <pipealloc+0xff>
80103ecb:	e8 0e d2 ff ff       	call   801010de <filealloc>
80103ed0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ed3:	89 02                	mov    %eax,(%edx)
80103ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed8:	8b 00                	mov    (%eax),%eax
80103eda:	85 c0                	test   %eax,%eax
80103edc:	0f 84 b1 00 00 00    	je     80103f93 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ee2:	e8 6d ee ff ff       	call   80102d54 <kalloc>
80103ee7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eee:	0f 84 a2 00 00 00    	je     80103f96 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103efe:	00 00 00 
  p->writeopen = 1;
80103f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f04:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f0b:	00 00 00 
  p->nwrite = 0;
80103f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f11:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f18:	00 00 00 
  p->nread = 0;
80103f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f25:	00 00 00 
  initlock(&p->lock, "pipe");
80103f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2b:	83 ec 08             	sub    $0x8,%esp
80103f2e:	68 d3 87 10 80       	push   $0x801087d3
80103f33:	50                   	push   %eax
80103f34:	e8 02 11 00 00       	call   8010503b <initlock>
80103f39:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	8b 00                	mov    (%eax),%eax
80103f41:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	8b 00                	mov    (%eax),%eax
80103f4c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f50:	8b 45 08             	mov    0x8(%ebp),%eax
80103f53:	8b 00                	mov    (%eax),%eax
80103f55:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f59:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5c:	8b 00                	mov    (%eax),%eax
80103f5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f61:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f67:	8b 00                	mov    (%eax),%eax
80103f69:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f72:	8b 00                	mov    (%eax),%eax
80103f74:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f7b:	8b 00                	mov    (%eax),%eax
80103f7d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f81:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f84:	8b 00                	mov    (%eax),%eax
80103f86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f89:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103f91:	eb 51                	jmp    80103fe4 <pipealloc+0x150>
    goto bad;
80103f93:	90                   	nop
80103f94:	eb 01                	jmp    80103f97 <pipealloc+0x103>
    goto bad;
80103f96:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103f97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f9b:	74 0e                	je     80103fab <pipealloc+0x117>
    kfree((char*)p);
80103f9d:	83 ec 0c             	sub    $0xc,%esp
80103fa0:	ff 75 f4             	push   -0xc(%ebp)
80103fa3:	e8 12 ed ff ff       	call   80102cba <kfree>
80103fa8:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103fab:	8b 45 08             	mov    0x8(%ebp),%eax
80103fae:	8b 00                	mov    (%eax),%eax
80103fb0:	85 c0                	test   %eax,%eax
80103fb2:	74 11                	je     80103fc5 <pipealloc+0x131>
    fileclose(*f0);
80103fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb7:	8b 00                	mov    (%eax),%eax
80103fb9:	83 ec 0c             	sub    $0xc,%esp
80103fbc:	50                   	push   %eax
80103fbd:	e8 da d1 ff ff       	call   8010119c <fileclose>
80103fc2:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc8:	8b 00                	mov    (%eax),%eax
80103fca:	85 c0                	test   %eax,%eax
80103fcc:	74 11                	je     80103fdf <pipealloc+0x14b>
    fileclose(*f1);
80103fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd1:	8b 00                	mov    (%eax),%eax
80103fd3:	83 ec 0c             	sub    $0xc,%esp
80103fd6:	50                   	push   %eax
80103fd7:	e8 c0 d1 ff ff       	call   8010119c <fileclose>
80103fdc:	83 c4 10             	add    $0x10,%esp
  return -1;
80103fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fe4:	c9                   	leave  
80103fe5:	c3                   	ret    

80103fe6 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fe6:	55                   	push   %ebp
80103fe7:	89 e5                	mov    %esp,%ebp
80103fe9:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103fec:	8b 45 08             	mov    0x8(%ebp),%eax
80103fef:	83 ec 0c             	sub    $0xc,%esp
80103ff2:	50                   	push   %eax
80103ff3:	e8 65 10 00 00       	call   8010505d <acquire>
80103ff8:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103ffb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fff:	74 23                	je     80104024 <pipeclose+0x3e>
    p->writeopen = 0;
80104001:	8b 45 08             	mov    0x8(%ebp),%eax
80104004:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010400b:	00 00 00 
    wakeup(&p->nread);
8010400e:	8b 45 08             	mov    0x8(%ebp),%eax
80104011:	05 34 02 00 00       	add    $0x234,%eax
80104016:	83 ec 0c             	sub    $0xc,%esp
80104019:	50                   	push   %eax
8010401a:	e8 e4 0c 00 00       	call   80104d03 <wakeup>
8010401f:	83 c4 10             	add    $0x10,%esp
80104022:	eb 21                	jmp    80104045 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104024:	8b 45 08             	mov    0x8(%ebp),%eax
80104027:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010402e:	00 00 00 
    wakeup(&p->nwrite);
80104031:	8b 45 08             	mov    0x8(%ebp),%eax
80104034:	05 38 02 00 00       	add    $0x238,%eax
80104039:	83 ec 0c             	sub    $0xc,%esp
8010403c:	50                   	push   %eax
8010403d:	e8 c1 0c 00 00       	call   80104d03 <wakeup>
80104042:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104045:	8b 45 08             	mov    0x8(%ebp),%eax
80104048:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010404e:	85 c0                	test   %eax,%eax
80104050:	75 2c                	jne    8010407e <pipeclose+0x98>
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010405b:	85 c0                	test   %eax,%eax
8010405d:	75 1f                	jne    8010407e <pipeclose+0x98>
    release(&p->lock);
8010405f:	8b 45 08             	mov    0x8(%ebp),%eax
80104062:	83 ec 0c             	sub    $0xc,%esp
80104065:	50                   	push   %eax
80104066:	e8 60 10 00 00       	call   801050cb <release>
8010406b:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010406e:	83 ec 0c             	sub    $0xc,%esp
80104071:	ff 75 08             	push   0x8(%ebp)
80104074:	e8 41 ec ff ff       	call   80102cba <kfree>
80104079:	83 c4 10             	add    $0x10,%esp
8010407c:	eb 10                	jmp    8010408e <pipeclose+0xa8>
  } else
    release(&p->lock);
8010407e:	8b 45 08             	mov    0x8(%ebp),%eax
80104081:	83 ec 0c             	sub    $0xc,%esp
80104084:	50                   	push   %eax
80104085:	e8 41 10 00 00       	call   801050cb <release>
8010408a:	83 c4 10             	add    $0x10,%esp
}
8010408d:	90                   	nop
8010408e:	90                   	nop
8010408f:	c9                   	leave  
80104090:	c3                   	ret    

80104091 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104091:	55                   	push   %ebp
80104092:	89 e5                	mov    %esp,%ebp
80104094:	53                   	push   %ebx
80104095:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	83 ec 0c             	sub    $0xc,%esp
8010409e:	50                   	push   %eax
8010409f:	e8 b9 0f 00 00       	call   8010505d <acquire>
801040a4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801040a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040ae:	e9 ad 00 00 00       	jmp    80104160 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801040b3:	8b 45 08             	mov    0x8(%ebp),%eax
801040b6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040bc:	85 c0                	test   %eax,%eax
801040be:	74 0c                	je     801040cc <pipewrite+0x3b>
801040c0:	e8 92 02 00 00       	call   80104357 <myproc>
801040c5:	8b 40 24             	mov    0x24(%eax),%eax
801040c8:	85 c0                	test   %eax,%eax
801040ca:	74 19                	je     801040e5 <pipewrite+0x54>
        release(&p->lock);
801040cc:	8b 45 08             	mov    0x8(%ebp),%eax
801040cf:	83 ec 0c             	sub    $0xc,%esp
801040d2:	50                   	push   %eax
801040d3:	e8 f3 0f 00 00       	call   801050cb <release>
801040d8:	83 c4 10             	add    $0x10,%esp
        return -1;
801040db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e0:	e9 a9 00 00 00       	jmp    8010418e <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801040e5:	8b 45 08             	mov    0x8(%ebp),%eax
801040e8:	05 34 02 00 00       	add    $0x234,%eax
801040ed:	83 ec 0c             	sub    $0xc,%esp
801040f0:	50                   	push   %eax
801040f1:	e8 0d 0c 00 00       	call   80104d03 <wakeup>
801040f6:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	8b 55 08             	mov    0x8(%ebp),%edx
801040ff:	81 c2 38 02 00 00    	add    $0x238,%edx
80104105:	83 ec 08             	sub    $0x8,%esp
80104108:	50                   	push   %eax
80104109:	52                   	push   %edx
8010410a:	e8 0d 0b 00 00       	call   80104c1c <sleep>
8010410f:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104112:	8b 45 08             	mov    0x8(%ebp),%eax
80104115:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010411b:	8b 45 08             	mov    0x8(%ebp),%eax
8010411e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104124:	05 00 02 00 00       	add    $0x200,%eax
80104129:	39 c2                	cmp    %eax,%edx
8010412b:	74 86                	je     801040b3 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010412d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104130:	8b 45 0c             	mov    0xc(%ebp),%eax
80104133:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010413f:	8d 48 01             	lea    0x1(%eax),%ecx
80104142:	8b 55 08             	mov    0x8(%ebp),%edx
80104145:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010414b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104150:	89 c1                	mov    %eax,%ecx
80104152:	0f b6 13             	movzbl (%ebx),%edx
80104155:	8b 45 08             	mov    0x8(%ebp),%eax
80104158:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010415c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104163:	3b 45 10             	cmp    0x10(%ebp),%eax
80104166:	7c aa                	jl     80104112 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	05 34 02 00 00       	add    $0x234,%eax
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	50                   	push   %eax
80104174:	e8 8a 0b 00 00       	call   80104d03 <wakeup>
80104179:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	83 ec 0c             	sub    $0xc,%esp
80104182:	50                   	push   %eax
80104183:	e8 43 0f 00 00       	call   801050cb <release>
80104188:	83 c4 10             	add    $0x10,%esp
  return n;
8010418b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010418e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104191:	c9                   	leave  
80104192:	c3                   	ret    

80104193 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104193:	55                   	push   %ebp
80104194:	89 e5                	mov    %esp,%ebp
80104196:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	83 ec 0c             	sub    $0xc,%esp
8010419f:	50                   	push   %eax
801041a0:	e8 b8 0e 00 00       	call   8010505d <acquire>
801041a5:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041a8:	eb 3e                	jmp    801041e8 <piperead+0x55>
    if(myproc()->killed){
801041aa:	e8 a8 01 00 00       	call   80104357 <myproc>
801041af:	8b 40 24             	mov    0x24(%eax),%eax
801041b2:	85 c0                	test   %eax,%eax
801041b4:	74 19                	je     801041cf <piperead+0x3c>
      release(&p->lock);
801041b6:	8b 45 08             	mov    0x8(%ebp),%eax
801041b9:	83 ec 0c             	sub    $0xc,%esp
801041bc:	50                   	push   %eax
801041bd:	e8 09 0f 00 00       	call   801050cb <release>
801041c2:	83 c4 10             	add    $0x10,%esp
      return -1;
801041c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ca:	e9 be 00 00 00       	jmp    8010428d <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801041cf:	8b 45 08             	mov    0x8(%ebp),%eax
801041d2:	8b 55 08             	mov    0x8(%ebp),%edx
801041d5:	81 c2 34 02 00 00    	add    $0x234,%edx
801041db:	83 ec 08             	sub    $0x8,%esp
801041de:	50                   	push   %eax
801041df:	52                   	push   %edx
801041e0:	e8 37 0a 00 00       	call   80104c1c <sleep>
801041e5:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041e8:	8b 45 08             	mov    0x8(%ebp),%eax
801041eb:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041f1:	8b 45 08             	mov    0x8(%ebp),%eax
801041f4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041fa:	39 c2                	cmp    %eax,%edx
801041fc:	75 0d                	jne    8010420b <piperead+0x78>
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104207:	85 c0                	test   %eax,%eax
80104209:	75 9f                	jne    801041aa <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010420b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104212:	eb 48                	jmp    8010425c <piperead+0xc9>
    if(p->nread == p->nwrite)
80104214:	8b 45 08             	mov    0x8(%ebp),%eax
80104217:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010421d:	8b 45 08             	mov    0x8(%ebp),%eax
80104220:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104226:	39 c2                	cmp    %eax,%edx
80104228:	74 3c                	je     80104266 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010422a:	8b 45 08             	mov    0x8(%ebp),%eax
8010422d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104233:	8d 48 01             	lea    0x1(%eax),%ecx
80104236:	8b 55 08             	mov    0x8(%ebp),%edx
80104239:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010423f:	25 ff 01 00 00       	and    $0x1ff,%eax
80104244:	89 c1                	mov    %eax,%ecx
80104246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104249:	8b 45 0c             	mov    0xc(%ebp),%eax
8010424c:	01 c2                	add    %eax,%edx
8010424e:	8b 45 08             	mov    0x8(%ebp),%eax
80104251:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104256:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104258:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104262:	7c b0                	jl     80104214 <piperead+0x81>
80104264:	eb 01                	jmp    80104267 <piperead+0xd4>
      break;
80104266:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104267:	8b 45 08             	mov    0x8(%ebp),%eax
8010426a:	05 38 02 00 00       	add    $0x238,%eax
8010426f:	83 ec 0c             	sub    $0xc,%esp
80104272:	50                   	push   %eax
80104273:	e8 8b 0a 00 00       	call   80104d03 <wakeup>
80104278:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010427b:	8b 45 08             	mov    0x8(%ebp),%eax
8010427e:	83 ec 0c             	sub    $0xc,%esp
80104281:	50                   	push   %eax
80104282:	e8 44 0e 00 00       	call   801050cb <release>
80104287:	83 c4 10             	add    $0x10,%esp
  return i;
8010428a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010428d:	c9                   	leave  
8010428e:	c3                   	ret    

8010428f <readeflags>:
{
8010428f:	55                   	push   %ebp
80104290:	89 e5                	mov    %esp,%ebp
80104292:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104295:	9c                   	pushf  
80104296:	58                   	pop    %eax
80104297:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010429a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010429d:	c9                   	leave  
8010429e:	c3                   	ret    

8010429f <sti>:
{
8010429f:	55                   	push   %ebp
801042a0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042a2:	fb                   	sti    
}
801042a3:	90                   	nop
801042a4:	5d                   	pop    %ebp
801042a5:	c3                   	ret    

801042a6 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801042a6:	55                   	push   %ebp
801042a7:	89 e5                	mov    %esp,%ebp
801042a9:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801042ac:	83 ec 08             	sub    $0x8,%esp
801042af:	68 d8 87 10 80       	push   $0x801087d8
801042b4:	68 60 2d 11 80       	push   $0x80112d60
801042b9:	e8 7d 0d 00 00       	call   8010503b <initlock>
801042be:	83 c4 10             	add    $0x10,%esp
}
801042c1:	90                   	nop
801042c2:	c9                   	leave  
801042c3:	c3                   	ret    

801042c4 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801042c4:	55                   	push   %ebp
801042c5:	89 e5                	mov    %esp,%ebp
801042c7:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801042ca:	e8 10 00 00 00       	call   801042df <mycpu>
801042cf:	2d c0 27 11 80       	sub    $0x801127c0,%eax
801042d4:	c1 f8 04             	sar    $0x4,%eax
801042d7:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801042dd:	c9                   	leave  
801042de:	c3                   	ret    

801042df <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801042df:	55                   	push   %ebp
801042e0:	89 e5                	mov    %esp,%ebp
801042e2:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801042e5:	e8 a5 ff ff ff       	call   8010428f <readeflags>
801042ea:	25 00 02 00 00       	and    $0x200,%eax
801042ef:	85 c0                	test   %eax,%eax
801042f1:	74 0d                	je     80104300 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801042f3:	83 ec 0c             	sub    $0xc,%esp
801042f6:	68 e0 87 10 80       	push   $0x801087e0
801042fb:	e8 b5 c2 ff ff       	call   801005b5 <panic>
  
  apicid = lapicid();
80104300:	e8 a9 ed ff ff       	call   801030ae <lapicid>
80104305:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104308:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010430f:	eb 2d                	jmp    8010433e <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
80104311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104314:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010431a:	05 c0 27 11 80       	add    $0x801127c0,%eax
8010431f:	0f b6 00             	movzbl (%eax),%eax
80104322:	0f b6 c0             	movzbl %al,%eax
80104325:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104328:	75 10                	jne    8010433a <mycpu+0x5b>
      return &cpus[i];
8010432a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104333:	05 c0 27 11 80       	add    $0x801127c0,%eax
80104338:	eb 1b                	jmp    80104355 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
8010433a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010433e:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80104343:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104346:	7c c9                	jl     80104311 <mycpu+0x32>
  }
  panic("unknown apicid\n");
80104348:	83 ec 0c             	sub    $0xc,%esp
8010434b:	68 06 88 10 80       	push   $0x80108806
80104350:	e8 60 c2 ff ff       	call   801005b5 <panic>
}
80104355:	c9                   	leave  
80104356:	c3                   	ret    

80104357 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104357:	55                   	push   %ebp
80104358:	89 e5                	mov    %esp,%ebp
8010435a:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010435d:	e8 76 0e 00 00       	call   801051d8 <pushcli>
  c = mycpu();
80104362:	e8 78 ff ff ff       	call   801042df <mycpu>
80104367:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104373:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104376:	e8 aa 0e 00 00       	call   80105225 <popcli>
  return p;
8010437b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010437e:	c9                   	leave  
8010437f:	c3                   	ret    

80104380 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104386:	83 ec 0c             	sub    $0xc,%esp
80104389:	68 60 2d 11 80       	push   $0x80112d60
8010438e:	e8 ca 0c 00 00       	call   8010505d <acquire>
80104393:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104396:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
8010439d:	eb 0e                	jmp    801043ad <allocproc+0x2d>
    if(p->state == UNUSED)
8010439f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a2:	8b 40 0c             	mov    0xc(%eax),%eax
801043a5:	85 c0                	test   %eax,%eax
801043a7:	74 27                	je     801043d0 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a9:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801043ad:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
801043b4:	72 e9                	jb     8010439f <allocproc+0x1f>
      goto found;

  release(&ptable.lock);
801043b6:	83 ec 0c             	sub    $0xc,%esp
801043b9:	68 60 2d 11 80       	push   $0x80112d60
801043be:	e8 08 0d 00 00       	call   801050cb <release>
801043c3:	83 c4 10             	add    $0x10,%esp
  return 0;
801043c6:	b8 00 00 00 00       	mov    $0x0,%eax
801043cb:	e9 b2 00 00 00       	jmp    80104482 <allocproc+0x102>
      goto found;
801043d0:	90                   	nop

found:
  p->state = EMBRYO;
801043d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d4:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043db:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801043e0:	8d 50 01             	lea    0x1(%eax),%edx
801043e3:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
801043e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ec:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801043ef:	83 ec 0c             	sub    $0xc,%esp
801043f2:	68 60 2d 11 80       	push   $0x80112d60
801043f7:	e8 cf 0c 00 00       	call   801050cb <release>
801043fc:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043ff:	e8 50 e9 ff ff       	call   80102d54 <kalloc>
80104404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104407:	89 42 08             	mov    %eax,0x8(%edx)
8010440a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440d:	8b 40 08             	mov    0x8(%eax),%eax
80104410:	85 c0                	test   %eax,%eax
80104412:	75 11                	jne    80104425 <allocproc+0xa5>
    p->state = UNUSED;
80104414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104417:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010441e:	b8 00 00 00 00       	mov    $0x0,%eax
80104423:	eb 5d                	jmp    80104482 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80104425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104428:	8b 40 08             	mov    0x8(%eax),%eax
8010442b:	05 00 10 00 00       	add    $0x1000,%eax
80104430:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104433:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010443d:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104440:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104444:	ba 6a 66 10 80       	mov    $0x8010666a,%edx
80104449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010444c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010444e:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104458:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010445b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104461:	83 ec 04             	sub    $0x4,%esp
80104464:	6a 14                	push   $0x14
80104466:	6a 00                	push   $0x0
80104468:	50                   	push   %eax
80104469:	e8 75 0e 00 00       	call   801052e3 <memset>
8010446e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104474:	8b 40 1c             	mov    0x1c(%eax),%eax
80104477:	ba d6 4b 10 80       	mov    $0x80104bd6,%edx
8010447c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010447f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104482:	c9                   	leave  
80104483:	c3                   	ret    

80104484 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104484:	55                   	push   %ebp
80104485:	89 e5                	mov    %esp,%ebp
80104487:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010448a:	e8 f1 fe ff ff       	call   80104380 <allocproc>
8010448f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104495:	a3 94 4d 11 80       	mov    %eax,0x80114d94
  if((p->pgdir = setupkvm()) == 0)
8010449a:	e8 14 37 00 00       	call   80107bb3 <setupkvm>
8010449f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a2:	89 42 04             	mov    %eax,0x4(%edx)
801044a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a8:	8b 40 04             	mov    0x4(%eax),%eax
801044ab:	85 c0                	test   %eax,%eax
801044ad:	75 0d                	jne    801044bc <userinit+0x38>
    panic("userinit: out of memory?");
801044af:	83 ec 0c             	sub    $0xc,%esp
801044b2:	68 16 88 10 80       	push   $0x80108816
801044b7:	e8 f9 c0 ff ff       	call   801005b5 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044bc:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c4:	8b 40 04             	mov    0x4(%eax),%eax
801044c7:	83 ec 04             	sub    $0x4,%esp
801044ca:	52                   	push   %edx
801044cb:	68 c4 b4 10 80       	push   $0x8010b4c4
801044d0:	50                   	push   %eax
801044d1:	e8 46 39 00 00       	call   80107e1c <inituvm>
801044d6:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dc:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  //p->stackpos = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	8b 40 18             	mov    0x18(%eax),%eax
801044e8:	83 ec 04             	sub    $0x4,%esp
801044eb:	6a 4c                	push   $0x4c
801044ed:	6a 00                	push   $0x0
801044ef:	50                   	push   %eax
801044f0:	e8 ee 0d 00 00       	call   801052e3 <memset>
801044f5:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fb:	8b 40 18             	mov    0x18(%eax),%eax
801044fe:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104507:	8b 40 18             	mov    0x18(%eax),%eax
8010450a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	8b 50 18             	mov    0x18(%eax),%edx
80104516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104519:	8b 40 18             	mov    0x18(%eax),%eax
8010451c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104520:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 50 18             	mov    0x18(%eax),%edx
8010452a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452d:	8b 40 18             	mov    0x18(%eax),%eax
80104530:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104534:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453b:	8b 40 18             	mov    0x18(%eax),%eax
8010453e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104548:	8b 40 18             	mov    0x18(%eax),%eax
8010454b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104555:	8b 40 18             	mov    0x18(%eax),%eax
80104558:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  cprintf("ffffffffffffffff\n");
8010455f:	83 ec 0c             	sub    $0xc,%esp
80104562:	68 2f 88 10 80       	push   $0x8010882f
80104567:	e8 94 be ff ff       	call   80100400 <cprintf>
8010456c:	83 c4 10             	add    $0x10,%esp
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010456f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104572:	83 c0 6c             	add    $0x6c,%eax
80104575:	83 ec 04             	sub    $0x4,%esp
80104578:	6a 10                	push   $0x10
8010457a:	68 41 88 10 80       	push   $0x80108841
8010457f:	50                   	push   %eax
80104580:	e8 61 0f 00 00       	call   801054e6 <safestrcpy>
80104585:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104588:	83 ec 0c             	sub    $0xc,%esp
8010458b:	68 4a 88 10 80       	push   $0x8010884a
80104590:	e8 76 e0 ff ff       	call   8010260b <namei>
80104595:	83 c4 10             	add    $0x10,%esp
80104598:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459b:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010459e:	83 ec 0c             	sub    $0xc,%esp
801045a1:	68 60 2d 11 80       	push   $0x80112d60
801045a6:	e8 b2 0a 00 00       	call   8010505d <acquire>
801045ab:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801045ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801045b8:	83 ec 0c             	sub    $0xc,%esp
801045bb:	68 60 2d 11 80       	push   $0x80112d60
801045c0:	e8 06 0b 00 00       	call   801050cb <release>
801045c5:	83 c4 10             	add    $0x10,%esp
}
801045c8:	90                   	nop
801045c9:	c9                   	leave  
801045ca:	c3                   	ret    

801045cb <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045cb:	55                   	push   %ebp
801045cc:	89 e5                	mov    %esp,%ebp
801045ce:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801045d1:	e8 81 fd ff ff       	call   80104357 <myproc>
801045d6:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801045d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045dc:	8b 00                	mov    (%eax),%eax
801045de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045e5:	7e 2e                	jle    80104615 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045e7:	8b 55 08             	mov    0x8(%ebp),%edx
801045ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ed:	01 c2                	add    %eax,%edx
801045ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045f2:	8b 40 04             	mov    0x4(%eax),%eax
801045f5:	83 ec 04             	sub    $0x4,%esp
801045f8:	52                   	push   %edx
801045f9:	ff 75 f4             	push   -0xc(%ebp)
801045fc:	50                   	push   %eax
801045fd:	e8 57 39 00 00       	call   80107f59 <allocuvm>
80104602:	83 c4 10             	add    $0x10,%esp
80104605:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104608:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010460c:	75 3b                	jne    80104649 <growproc+0x7e>
      return -1;
8010460e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104613:	eb 4f                	jmp    80104664 <growproc+0x99>
  } else if(n < 0){
80104615:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104619:	79 2e                	jns    80104649 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010461b:	8b 55 08             	mov    0x8(%ebp),%edx
8010461e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104621:	01 c2                	add    %eax,%edx
80104623:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104626:	8b 40 04             	mov    0x4(%eax),%eax
80104629:	83 ec 04             	sub    $0x4,%esp
8010462c:	52                   	push   %edx
8010462d:	ff 75 f4             	push   -0xc(%ebp)
80104630:	50                   	push   %eax
80104631:	e8 28 3a 00 00       	call   8010805e <deallocuvm>
80104636:	83 c4 10             	add    $0x10,%esp
80104639:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010463c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104640:	75 07                	jne    80104649 <growproc+0x7e>
      return -1;
80104642:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104647:	eb 1b                	jmp    80104664 <growproc+0x99>
  }
  curproc->sz = sz;
80104649:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010464c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464f:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104651:	83 ec 0c             	sub    $0xc,%esp
80104654:	ff 75 f0             	push   -0x10(%ebp)
80104657:	e8 21 36 00 00       	call   80107c7d <switchuvm>
8010465c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010465f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104664:	c9                   	leave  
80104665:	c3                   	ret    

80104666 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104666:	55                   	push   %ebp
80104667:	89 e5                	mov    %esp,%ebp
80104669:	57                   	push   %edi
8010466a:	56                   	push   %esi
8010466b:	53                   	push   %ebx
8010466c:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010466f:	e8 e3 fc ff ff       	call   80104357 <myproc>
80104674:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104677:	e8 04 fd ff ff       	call   80104380 <allocproc>
8010467c:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010467f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104683:	75 0a                	jne    8010468f <fork+0x29>
    return -1;
80104685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468a:	e9 54 01 00 00       	jmp    801047e3 <fork+0x17d>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010468f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104692:	8b 10                	mov    (%eax),%edx
80104694:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104697:	8b 40 04             	mov    0x4(%eax),%eax
8010469a:	83 ec 08             	sub    $0x8,%esp
8010469d:	52                   	push   %edx
8010469e:	50                   	push   %eax
8010469f:	e8 58 3b 00 00       	call   801081fc <copyuvm>
801046a4:	83 c4 10             	add    $0x10,%esp
801046a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046aa:	89 42 04             	mov    %eax,0x4(%edx)
801046ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b0:	8b 40 04             	mov    0x4(%eax),%eax
801046b3:	85 c0                	test   %eax,%eax
801046b5:	75 30                	jne    801046e7 <fork+0x81>
    kfree(np->kstack);
801046b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ba:	8b 40 08             	mov    0x8(%eax),%eax
801046bd:	83 ec 0c             	sub    $0xc,%esp
801046c0:	50                   	push   %eax
801046c1:	e8 f4 e5 ff ff       	call   80102cba <kfree>
801046c6:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801046c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046cc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e2:	e9 fc 00 00 00       	jmp    801047e3 <fork+0x17d>
  }
  np->sz = curproc->sz;
801046e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ea:	8b 10                	mov    (%eax),%edx
801046ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ef:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801046f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046f7:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fd:	8b 48 18             	mov    0x18(%eax),%ecx
80104700:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104703:	8b 40 18             	mov    0x18(%eax),%eax
80104706:	89 c2                	mov    %eax,%edx
80104708:	89 cb                	mov    %ecx,%ebx
8010470a:	b8 13 00 00 00       	mov    $0x13,%eax
8010470f:	89 d7                	mov    %edx,%edi
80104711:	89 de                	mov    %ebx,%esi
80104713:	89 c1                	mov    %eax,%ecx
80104715:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->aslr_enabled = curproc->aslr_enabled;
80104717:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471a:	8b 50 7c             	mov    0x7c(%eax),%edx
8010471d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104720:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104723:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104726:	8b 40 18             	mov    0x18(%eax),%eax
80104729:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104730:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104737:	eb 3b                	jmp    80104774 <fork+0x10e>
    if(curproc->ofile[i])
80104739:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010473f:	83 c2 08             	add    $0x8,%edx
80104742:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104746:	85 c0                	test   %eax,%eax
80104748:	74 26                	je     80104770 <fork+0x10a>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010474a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010474d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104750:	83 c2 08             	add    $0x8,%edx
80104753:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104757:	83 ec 0c             	sub    $0xc,%esp
8010475a:	50                   	push   %eax
8010475b:	e8 eb c9 ff ff       	call   8010114b <filedup>
80104760:	83 c4 10             	add    $0x10,%esp
80104763:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104766:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104769:	83 c1 08             	add    $0x8,%ecx
8010476c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104770:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104774:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104778:	7e bf                	jle    80104739 <fork+0xd3>
  np->cwd = idup(curproc->cwd);
8010477a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477d:	8b 40 68             	mov    0x68(%eax),%eax
80104780:	83 ec 0c             	sub    $0xc,%esp
80104783:	50                   	push   %eax
80104784:	e8 15 d3 ff ff       	call   80101a9e <idup>
80104789:	83 c4 10             	add    $0x10,%esp
8010478c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010478f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104792:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104795:	8d 50 6c             	lea    0x6c(%eax),%edx
80104798:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010479b:	83 c0 6c             	add    $0x6c,%eax
8010479e:	83 ec 04             	sub    $0x4,%esp
801047a1:	6a 10                	push   $0x10
801047a3:	52                   	push   %edx
801047a4:	50                   	push   %eax
801047a5:	e8 3c 0d 00 00       	call   801054e6 <safestrcpy>
801047aa:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801047ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047b0:	8b 40 10             	mov    0x10(%eax),%eax
801047b3:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801047b6:	83 ec 0c             	sub    $0xc,%esp
801047b9:	68 60 2d 11 80       	push   $0x80112d60
801047be:	e8 9a 08 00 00       	call   8010505d <acquire>
801047c3:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801047c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047c9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047d0:	83 ec 0c             	sub    $0xc,%esp
801047d3:	68 60 2d 11 80       	push   $0x80112d60
801047d8:	e8 ee 08 00 00       	call   801050cb <release>
801047dd:	83 c4 10             	add    $0x10,%esp

  return pid;
801047e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801047e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047e6:	5b                   	pop    %ebx
801047e7:	5e                   	pop    %esi
801047e8:	5f                   	pop    %edi
801047e9:	5d                   	pop    %ebp
801047ea:	c3                   	ret    

801047eb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047eb:	55                   	push   %ebp
801047ec:	89 e5                	mov    %esp,%ebp
801047ee:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801047f1:	e8 61 fb ff ff       	call   80104357 <myproc>
801047f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801047f9:	a1 94 4d 11 80       	mov    0x80114d94,%eax
801047fe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104801:	75 0d                	jne    80104810 <exit+0x25>
    panic("init exiting");
80104803:	83 ec 0c             	sub    $0xc,%esp
80104806:	68 4c 88 10 80       	push   $0x8010884c
8010480b:	e8 a5 bd ff ff       	call   801005b5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104810:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104817:	eb 3f                	jmp    80104858 <exit+0x6d>
    if(curproc->ofile[fd]){
80104819:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010481c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010481f:	83 c2 08             	add    $0x8,%edx
80104822:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104826:	85 c0                	test   %eax,%eax
80104828:	74 2a                	je     80104854 <exit+0x69>
      fileclose(curproc->ofile[fd]);
8010482a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010482d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104830:	83 c2 08             	add    $0x8,%edx
80104833:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104837:	83 ec 0c             	sub    $0xc,%esp
8010483a:	50                   	push   %eax
8010483b:	e8 5c c9 ff ff       	call   8010119c <fileclose>
80104840:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104843:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104846:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104849:	83 c2 08             	add    $0x8,%edx
8010484c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104853:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104854:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104858:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010485c:	7e bb                	jle    80104819 <exit+0x2e>
    }
  }

  begin_op();
8010485e:	e8 8d ed ff ff       	call   801035f0 <begin_op>
  iput(curproc->cwd);
80104863:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104866:	8b 40 68             	mov    0x68(%eax),%eax
80104869:	83 ec 0c             	sub    $0xc,%esp
8010486c:	50                   	push   %eax
8010486d:	e8 c7 d3 ff ff       	call   80101c39 <iput>
80104872:	83 c4 10             	add    $0x10,%esp
  end_op();
80104875:	e8 02 ee ff ff       	call   8010367c <end_op>
  curproc->cwd = 0;
8010487a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010487d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104884:	83 ec 0c             	sub    $0xc,%esp
80104887:	68 60 2d 11 80       	push   $0x80112d60
8010488c:	e8 cc 07 00 00       	call   8010505d <acquire>
80104891:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104894:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104897:	8b 40 14             	mov    0x14(%eax),%eax
8010489a:	83 ec 0c             	sub    $0xc,%esp
8010489d:	50                   	push   %eax
8010489e:	e8 20 04 00 00       	call   80104cc3 <wakeup1>
801048a3:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a6:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801048ad:	eb 37                	jmp    801048e6 <exit+0xfb>
    if(p->parent == curproc){
801048af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b2:	8b 40 14             	mov    0x14(%eax),%eax
801048b5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801048b8:	75 28                	jne    801048e2 <exit+0xf7>
      p->parent = initproc;
801048ba:	8b 15 94 4d 11 80    	mov    0x80114d94,%edx
801048c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c3:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c9:	8b 40 0c             	mov    0xc(%eax),%eax
801048cc:	83 f8 05             	cmp    $0x5,%eax
801048cf:	75 11                	jne    801048e2 <exit+0xf7>
        wakeup1(initproc);
801048d1:	a1 94 4d 11 80       	mov    0x80114d94,%eax
801048d6:	83 ec 0c             	sub    $0xc,%esp
801048d9:	50                   	push   %eax
801048da:	e8 e4 03 00 00       	call   80104cc3 <wakeup1>
801048df:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048e2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048e6:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
801048ed:	72 c0                	jb     801048af <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801048ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048f2:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048f9:	e8 e5 01 00 00       	call   80104ae3 <sched>
  panic("zombie exit");
801048fe:	83 ec 0c             	sub    $0xc,%esp
80104901:	68 59 88 10 80       	push   $0x80108859
80104906:	e8 aa bc ff ff       	call   801005b5 <panic>

8010490b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010490b:	55                   	push   %ebp
8010490c:	89 e5                	mov    %esp,%ebp
8010490e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104911:	e8 41 fa ff ff       	call   80104357 <myproc>
80104916:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104919:	83 ec 0c             	sub    $0xc,%esp
8010491c:	68 60 2d 11 80       	push   $0x80112d60
80104921:	e8 37 07 00 00       	call   8010505d <acquire>
80104926:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104929:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104930:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104937:	e9 a1 00 00 00       	jmp    801049dd <wait+0xd2>
      if(p->parent != curproc)
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 40 14             	mov    0x14(%eax),%eax
80104942:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104945:	0f 85 8d 00 00 00    	jne    801049d8 <wait+0xcd>
        continue;
      havekids = 1;
8010494b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	8b 40 0c             	mov    0xc(%eax),%eax
80104958:	83 f8 05             	cmp    $0x5,%eax
8010495b:	75 7c                	jne    801049d9 <wait+0xce>
        // Found one.
        pid = p->pid;
8010495d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104960:	8b 40 10             	mov    0x10(%eax),%eax
80104963:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104969:	8b 40 08             	mov    0x8(%eax),%eax
8010496c:	83 ec 0c             	sub    $0xc,%esp
8010496f:	50                   	push   %eax
80104970:	e8 45 e3 ff ff       	call   80102cba <kfree>
80104975:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104985:	8b 40 04             	mov    0x4(%eax),%eax
80104988:	83 ec 0c             	sub    $0xc,%esp
8010498b:	50                   	push   %eax
8010498c:	e8 91 37 00 00       	call   80108122 <freevm>
80104991:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104997:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010499e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ab:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801049b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049c3:	83 ec 0c             	sub    $0xc,%esp
801049c6:	68 60 2d 11 80       	push   $0x80112d60
801049cb:	e8 fb 06 00 00       	call   801050cb <release>
801049d0:	83 c4 10             	add    $0x10,%esp
        return pid;
801049d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049d6:	eb 51                	jmp    80104a29 <wait+0x11e>
        continue;
801049d8:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d9:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049dd:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
801049e4:	0f 82 52 ff ff ff    	jb     8010493c <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801049ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049ee:	74 0a                	je     801049fa <wait+0xef>
801049f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f3:	8b 40 24             	mov    0x24(%eax),%eax
801049f6:	85 c0                	test   %eax,%eax
801049f8:	74 17                	je     80104a11 <wait+0x106>
      release(&ptable.lock);
801049fa:	83 ec 0c             	sub    $0xc,%esp
801049fd:	68 60 2d 11 80       	push   $0x80112d60
80104a02:	e8 c4 06 00 00       	call   801050cb <release>
80104a07:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0f:	eb 18                	jmp    80104a29 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104a11:	83 ec 08             	sub    $0x8,%esp
80104a14:	68 60 2d 11 80       	push   $0x80112d60
80104a19:	ff 75 ec             	push   -0x14(%ebp)
80104a1c:	e8 fb 01 00 00       	call   80104c1c <sleep>
80104a21:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104a24:	e9 00 ff ff ff       	jmp    80104929 <wait+0x1e>
  }
}
80104a29:	c9                   	leave  
80104a2a:	c3                   	ret    

80104a2b <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a2b:	55                   	push   %ebp
80104a2c:	89 e5                	mov    %esp,%ebp
80104a2e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a31:	e8 a9 f8 ff ff       	call   801042df <mycpu>
80104a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a3c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a43:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a46:	e8 54 f8 ff ff       	call   8010429f <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	68 60 2d 11 80       	push   $0x80112d60
80104a53:	e8 05 06 00 00       	call   8010505d <acquire>
80104a58:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a5b:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104a62:	eb 61                	jmp    80104ac5 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a67:	8b 40 0c             	mov    0xc(%eax),%eax
80104a6a:	83 f8 03             	cmp    $0x3,%eax
80104a6d:	75 51                	jne    80104ac0 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a75:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a7b:	83 ec 0c             	sub    $0xc,%esp
80104a7e:	ff 75 f4             	push   -0xc(%ebp)
80104a81:	e8 f7 31 00 00       	call   80107c7d <switchuvm>
80104a86:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a99:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a9c:	83 c2 04             	add    $0x4,%edx
80104a9f:	83 ec 08             	sub    $0x8,%esp
80104aa2:	50                   	push   %eax
80104aa3:	52                   	push   %edx
80104aa4:	e8 af 0a 00 00       	call   80105558 <swtch>
80104aa9:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104aac:	e8 b3 31 00 00       	call   80107c64 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104abb:	00 00 00 
80104abe:	eb 01                	jmp    80104ac1 <scheduler+0x96>
        continue;
80104ac0:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ac1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104ac5:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80104acc:	72 96                	jb     80104a64 <scheduler+0x39>
    }
    release(&ptable.lock);
80104ace:	83 ec 0c             	sub    $0xc,%esp
80104ad1:	68 60 2d 11 80       	push   $0x80112d60
80104ad6:	e8 f0 05 00 00       	call   801050cb <release>
80104adb:	83 c4 10             	add    $0x10,%esp
    sti();
80104ade:	e9 63 ff ff ff       	jmp    80104a46 <scheduler+0x1b>

80104ae3 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ae3:	55                   	push   %ebp
80104ae4:	89 e5                	mov    %esp,%ebp
80104ae6:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104ae9:	e8 69 f8 ff ff       	call   80104357 <myproc>
80104aee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	68 60 2d 11 80       	push   $0x80112d60
80104af9:	e8 9a 06 00 00       	call   80105198 <holding>
80104afe:	83 c4 10             	add    $0x10,%esp
80104b01:	85 c0                	test   %eax,%eax
80104b03:	75 0d                	jne    80104b12 <sched+0x2f>
    panic("sched ptable.lock");
80104b05:	83 ec 0c             	sub    $0xc,%esp
80104b08:	68 65 88 10 80       	push   $0x80108865
80104b0d:	e8 a3 ba ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli != 1)
80104b12:	e8 c8 f7 ff ff       	call   801042df <mycpu>
80104b17:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b1d:	83 f8 01             	cmp    $0x1,%eax
80104b20:	74 0d                	je     80104b2f <sched+0x4c>
    panic("sched locks");
80104b22:	83 ec 0c             	sub    $0xc,%esp
80104b25:	68 77 88 10 80       	push   $0x80108877
80104b2a:	e8 86 ba ff ff       	call   801005b5 <panic>
  if(p->state == RUNNING)
80104b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b32:	8b 40 0c             	mov    0xc(%eax),%eax
80104b35:	83 f8 04             	cmp    $0x4,%eax
80104b38:	75 0d                	jne    80104b47 <sched+0x64>
    panic("sched running");
80104b3a:	83 ec 0c             	sub    $0xc,%esp
80104b3d:	68 83 88 10 80       	push   $0x80108883
80104b42:	e8 6e ba ff ff       	call   801005b5 <panic>
  if(readeflags()&FL_IF)
80104b47:	e8 43 f7 ff ff       	call   8010428f <readeflags>
80104b4c:	25 00 02 00 00       	and    $0x200,%eax
80104b51:	85 c0                	test   %eax,%eax
80104b53:	74 0d                	je     80104b62 <sched+0x7f>
    panic("sched interruptible");
80104b55:	83 ec 0c             	sub    $0xc,%esp
80104b58:	68 91 88 10 80       	push   $0x80108891
80104b5d:	e8 53 ba ff ff       	call   801005b5 <panic>
  intena = mycpu()->intena;
80104b62:	e8 78 f7 ff ff       	call   801042df <mycpu>
80104b67:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b70:	e8 6a f7 ff ff       	call   801042df <mycpu>
80104b75:	8b 40 04             	mov    0x4(%eax),%eax
80104b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b7b:	83 c2 1c             	add    $0x1c,%edx
80104b7e:	83 ec 08             	sub    $0x8,%esp
80104b81:	50                   	push   %eax
80104b82:	52                   	push   %edx
80104b83:	e8 d0 09 00 00       	call   80105558 <swtch>
80104b88:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b8b:	e8 4f f7 ff ff       	call   801042df <mycpu>
80104b90:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b93:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104b99:	90                   	nop
80104b9a:	c9                   	leave  
80104b9b:	c3                   	ret    

80104b9c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b9c:	55                   	push   %ebp
80104b9d:	89 e5                	mov    %esp,%ebp
80104b9f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ba2:	83 ec 0c             	sub    $0xc,%esp
80104ba5:	68 60 2d 11 80       	push   $0x80112d60
80104baa:	e8 ae 04 00 00       	call   8010505d <acquire>
80104baf:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104bb2:	e8 a0 f7 ff ff       	call   80104357 <myproc>
80104bb7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bbe:	e8 20 ff ff ff       	call   80104ae3 <sched>
  release(&ptable.lock);
80104bc3:	83 ec 0c             	sub    $0xc,%esp
80104bc6:	68 60 2d 11 80       	push   $0x80112d60
80104bcb:	e8 fb 04 00 00       	call   801050cb <release>
80104bd0:	83 c4 10             	add    $0x10,%esp
}
80104bd3:	90                   	nop
80104bd4:	c9                   	leave  
80104bd5:	c3                   	ret    

80104bd6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bd6:	55                   	push   %ebp
80104bd7:	89 e5                	mov    %esp,%ebp
80104bd9:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bdc:	83 ec 0c             	sub    $0xc,%esp
80104bdf:	68 60 2d 11 80       	push   $0x80112d60
80104be4:	e8 e2 04 00 00       	call   801050cb <release>
80104be9:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bec:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104bf1:	85 c0                	test   %eax,%eax
80104bf3:	74 24                	je     80104c19 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bf5:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104bfc:	00 00 00 
    iinit(ROOTDEV);
80104bff:	83 ec 0c             	sub    $0xc,%esp
80104c02:	6a 01                	push   $0x1
80104c04:	e8 5d cb ff ff       	call   80101766 <iinit>
80104c09:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104c0c:	83 ec 0c             	sub    $0xc,%esp
80104c0f:	6a 01                	push   $0x1
80104c11:	e8 bb e7 ff ff       	call   801033d1 <initlog>
80104c16:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c19:	90                   	nop
80104c1a:	c9                   	leave  
80104c1b:	c3                   	ret    

80104c1c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c1c:	55                   	push   %ebp
80104c1d:	89 e5                	mov    %esp,%ebp
80104c1f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c22:	e8 30 f7 ff ff       	call   80104357 <myproc>
80104c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c2e:	75 0d                	jne    80104c3d <sleep+0x21>
    panic("sleep");
80104c30:	83 ec 0c             	sub    $0xc,%esp
80104c33:	68 a5 88 10 80       	push   $0x801088a5
80104c38:	e8 78 b9 ff ff       	call   801005b5 <panic>

  if(lk == 0)
80104c3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c41:	75 0d                	jne    80104c50 <sleep+0x34>
    panic("sleep without lk");
80104c43:	83 ec 0c             	sub    $0xc,%esp
80104c46:	68 ab 88 10 80       	push   $0x801088ab
80104c4b:	e8 65 b9 ff ff       	call   801005b5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c50:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104c57:	74 1e                	je     80104c77 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c59:	83 ec 0c             	sub    $0xc,%esp
80104c5c:	68 60 2d 11 80       	push   $0x80112d60
80104c61:	e8 f7 03 00 00       	call   8010505d <acquire>
80104c66:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c69:	83 ec 0c             	sub    $0xc,%esp
80104c6c:	ff 75 0c             	push   0xc(%ebp)
80104c6f:	e8 57 04 00 00       	call   801050cb <release>
80104c74:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7a:	8b 55 08             	mov    0x8(%ebp),%edx
80104c7d:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c83:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c8a:	e8 54 fe ff ff       	call   80104ae3 <sched>

  // Tidy up.
  p->chan = 0;
80104c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c92:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c99:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104ca0:	74 1e                	je     80104cc0 <sleep+0xa4>
    release(&ptable.lock);
80104ca2:	83 ec 0c             	sub    $0xc,%esp
80104ca5:	68 60 2d 11 80       	push   $0x80112d60
80104caa:	e8 1c 04 00 00       	call   801050cb <release>
80104caf:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104cb2:	83 ec 0c             	sub    $0xc,%esp
80104cb5:	ff 75 0c             	push   0xc(%ebp)
80104cb8:	e8 a0 03 00 00       	call   8010505d <acquire>
80104cbd:	83 c4 10             	add    $0x10,%esp
  }
}
80104cc0:	90                   	nop
80104cc1:	c9                   	leave  
80104cc2:	c3                   	ret    

80104cc3 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cc3:	55                   	push   %ebp
80104cc4:	89 e5                	mov    %esp,%ebp
80104cc6:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cc9:	c7 45 fc 94 2d 11 80 	movl   $0x80112d94,-0x4(%ebp)
80104cd0:	eb 24                	jmp    80104cf6 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104cd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cd5:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd8:	83 f8 02             	cmp    $0x2,%eax
80104cdb:	75 15                	jne    80104cf2 <wakeup1+0x2f>
80104cdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce0:	8b 40 20             	mov    0x20(%eax),%eax
80104ce3:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ce6:	75 0a                	jne    80104cf2 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ce8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ceb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cf2:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104cf6:	81 7d fc 94 4d 11 80 	cmpl   $0x80114d94,-0x4(%ebp)
80104cfd:	72 d3                	jb     80104cd2 <wakeup1+0xf>
}
80104cff:	90                   	nop
80104d00:	90                   	nop
80104d01:	c9                   	leave  
80104d02:	c3                   	ret    

80104d03 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d03:	55                   	push   %ebp
80104d04:	89 e5                	mov    %esp,%ebp
80104d06:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104d09:	83 ec 0c             	sub    $0xc,%esp
80104d0c:	68 60 2d 11 80       	push   $0x80112d60
80104d11:	e8 47 03 00 00       	call   8010505d <acquire>
80104d16:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d19:	83 ec 0c             	sub    $0xc,%esp
80104d1c:	ff 75 08             	push   0x8(%ebp)
80104d1f:	e8 9f ff ff ff       	call   80104cc3 <wakeup1>
80104d24:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d27:	83 ec 0c             	sub    $0xc,%esp
80104d2a:	68 60 2d 11 80       	push   $0x80112d60
80104d2f:	e8 97 03 00 00       	call   801050cb <release>
80104d34:	83 c4 10             	add    $0x10,%esp
}
80104d37:	90                   	nop
80104d38:	c9                   	leave  
80104d39:	c3                   	ret    

80104d3a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d3a:	55                   	push   %ebp
80104d3b:	89 e5                	mov    %esp,%ebp
80104d3d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d40:	83 ec 0c             	sub    $0xc,%esp
80104d43:	68 60 2d 11 80       	push   $0x80112d60
80104d48:	e8 10 03 00 00       	call   8010505d <acquire>
80104d4d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d50:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104d57:	eb 45                	jmp    80104d9e <kill+0x64>
    if(p->pid == pid){
80104d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5c:	8b 40 10             	mov    0x10(%eax),%eax
80104d5f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d62:	75 36                	jne    80104d9a <kill+0x60>
      p->killed = 1;
80104d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d67:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d71:	8b 40 0c             	mov    0xc(%eax),%eax
80104d74:	83 f8 02             	cmp    $0x2,%eax
80104d77:	75 0a                	jne    80104d83 <kill+0x49>
        p->state = RUNNABLE;
80104d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d83:	83 ec 0c             	sub    $0xc,%esp
80104d86:	68 60 2d 11 80       	push   $0x80112d60
80104d8b:	e8 3b 03 00 00       	call   801050cb <release>
80104d90:	83 c4 10             	add    $0x10,%esp
      return 0;
80104d93:	b8 00 00 00 00       	mov    $0x0,%eax
80104d98:	eb 22                	jmp    80104dbc <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d9a:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104d9e:	81 7d f4 94 4d 11 80 	cmpl   $0x80114d94,-0xc(%ebp)
80104da5:	72 b2                	jb     80104d59 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104da7:	83 ec 0c             	sub    $0xc,%esp
80104daa:	68 60 2d 11 80       	push   $0x80112d60
80104daf:	e8 17 03 00 00       	call   801050cb <release>
80104db4:	83 c4 10             	add    $0x10,%esp
  return -1;
80104db7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dbc:	c9                   	leave  
80104dbd:	c3                   	ret    

80104dbe <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dbe:	55                   	push   %ebp
80104dbf:	89 e5                	mov    %esp,%ebp
80104dc1:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dc4:	c7 45 f0 94 2d 11 80 	movl   $0x80112d94,-0x10(%ebp)
80104dcb:	e9 d7 00 00 00       	jmp    80104ea7 <procdump+0xe9>
    if(p->state == UNUSED)
80104dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd3:	8b 40 0c             	mov    0xc(%eax),%eax
80104dd6:	85 c0                	test   %eax,%eax
80104dd8:	0f 84 c4 00 00 00    	je     80104ea2 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104de1:	8b 40 0c             	mov    0xc(%eax),%eax
80104de4:	83 f8 05             	cmp    $0x5,%eax
80104de7:	77 23                	ja     80104e0c <procdump+0x4e>
80104de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dec:	8b 40 0c             	mov    0xc(%eax),%eax
80104def:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104df6:	85 c0                	test   %eax,%eax
80104df8:	74 12                	je     80104e0c <procdump+0x4e>
      state = states[p->state];
80104dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfd:	8b 40 0c             	mov    0xc(%eax),%eax
80104e00:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104e07:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e0a:	eb 07                	jmp    80104e13 <procdump+0x55>
    else
      state = "???";
80104e0c:	c7 45 ec bc 88 10 80 	movl   $0x801088bc,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e16:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1c:	8b 40 10             	mov    0x10(%eax),%eax
80104e1f:	52                   	push   %edx
80104e20:	ff 75 ec             	push   -0x14(%ebp)
80104e23:	50                   	push   %eax
80104e24:	68 c0 88 10 80       	push   $0x801088c0
80104e29:	e8 d2 b5 ff ff       	call   80100400 <cprintf>
80104e2e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e34:	8b 40 0c             	mov    0xc(%eax),%eax
80104e37:	83 f8 02             	cmp    $0x2,%eax
80104e3a:	75 54                	jne    80104e90 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e42:	8b 40 0c             	mov    0xc(%eax),%eax
80104e45:	83 c0 08             	add    $0x8,%eax
80104e48:	89 c2                	mov    %eax,%edx
80104e4a:	83 ec 08             	sub    $0x8,%esp
80104e4d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e50:	50                   	push   %eax
80104e51:	52                   	push   %edx
80104e52:	e8 c6 02 00 00       	call   8010511d <getcallerpcs>
80104e57:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e61:	eb 1c                	jmp    80104e7f <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e66:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e6a:	83 ec 08             	sub    $0x8,%esp
80104e6d:	50                   	push   %eax
80104e6e:	68 c9 88 10 80       	push   $0x801088c9
80104e73:	e8 88 b5 ff ff       	call   80100400 <cprintf>
80104e78:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e7b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e7f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e83:	7f 0b                	jg     80104e90 <procdump+0xd2>
80104e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e88:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e8c:	85 c0                	test   %eax,%eax
80104e8e:	75 d3                	jne    80104e63 <procdump+0xa5>
    }
    cprintf("\n");
80104e90:	83 ec 0c             	sub    $0xc,%esp
80104e93:	68 cd 88 10 80       	push   $0x801088cd
80104e98:	e8 63 b5 ff ff       	call   80100400 <cprintf>
80104e9d:	83 c4 10             	add    $0x10,%esp
80104ea0:	eb 01                	jmp    80104ea3 <procdump+0xe5>
      continue;
80104ea2:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea3:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104ea7:	81 7d f0 94 4d 11 80 	cmpl   $0x80114d94,-0x10(%ebp)
80104eae:	0f 82 1c ff ff ff    	jb     80104dd0 <procdump+0x12>
  }
}
80104eb4:	90                   	nop
80104eb5:	90                   	nop
80104eb6:	c9                   	leave  
80104eb7:	c3                   	ret    

80104eb8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104eb8:	55                   	push   %ebp
80104eb9:	89 e5                	mov    %esp,%ebp
80104ebb:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec1:	83 c0 04             	add    $0x4,%eax
80104ec4:	83 ec 08             	sub    $0x8,%esp
80104ec7:	68 f9 88 10 80       	push   $0x801088f9
80104ecc:	50                   	push   %eax
80104ecd:	e8 69 01 00 00       	call   8010503b <initlock>
80104ed2:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104edb:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ede:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ee7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eea:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ef1:	90                   	nop
80104ef2:	c9                   	leave  
80104ef3:	c3                   	ret    

80104ef4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ef4:	55                   	push   %ebp
80104ef5:	89 e5                	mov    %esp,%ebp
80104ef7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104efa:	8b 45 08             	mov    0x8(%ebp),%eax
80104efd:	83 c0 04             	add    $0x4,%eax
80104f00:	83 ec 0c             	sub    $0xc,%esp
80104f03:	50                   	push   %eax
80104f04:	e8 54 01 00 00       	call   8010505d <acquire>
80104f09:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f0c:	eb 15                	jmp    80104f23 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f11:	83 c0 04             	add    $0x4,%eax
80104f14:	83 ec 08             	sub    $0x8,%esp
80104f17:	50                   	push   %eax
80104f18:	ff 75 08             	push   0x8(%ebp)
80104f1b:	e8 fc fc ff ff       	call   80104c1c <sleep>
80104f20:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f23:	8b 45 08             	mov    0x8(%ebp),%eax
80104f26:	8b 00                	mov    (%eax),%eax
80104f28:	85 c0                	test   %eax,%eax
80104f2a:	75 e2                	jne    80104f0e <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f35:	e8 1d f4 ff ff       	call   80104357 <myproc>
80104f3a:	8b 50 10             	mov    0x10(%eax),%edx
80104f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f40:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f43:	8b 45 08             	mov    0x8(%ebp),%eax
80104f46:	83 c0 04             	add    $0x4,%eax
80104f49:	83 ec 0c             	sub    $0xc,%esp
80104f4c:	50                   	push   %eax
80104f4d:	e8 79 01 00 00       	call   801050cb <release>
80104f52:	83 c4 10             	add    $0x10,%esp
}
80104f55:	90                   	nop
80104f56:	c9                   	leave  
80104f57:	c3                   	ret    

80104f58 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f58:	55                   	push   %ebp
80104f59:	89 e5                	mov    %esp,%ebp
80104f5b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f61:	83 c0 04             	add    $0x4,%eax
80104f64:	83 ec 0c             	sub    $0xc,%esp
80104f67:	50                   	push   %eax
80104f68:	e8 f0 00 00 00       	call   8010505d <acquire>
80104f6d:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104f70:	8b 45 08             	mov    0x8(%ebp),%eax
80104f73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f79:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f83:	83 ec 0c             	sub    $0xc,%esp
80104f86:	ff 75 08             	push   0x8(%ebp)
80104f89:	e8 75 fd ff ff       	call   80104d03 <wakeup>
80104f8e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f91:	8b 45 08             	mov    0x8(%ebp),%eax
80104f94:	83 c0 04             	add    $0x4,%eax
80104f97:	83 ec 0c             	sub    $0xc,%esp
80104f9a:	50                   	push   %eax
80104f9b:	e8 2b 01 00 00       	call   801050cb <release>
80104fa0:	83 c4 10             	add    $0x10,%esp
}
80104fa3:	90                   	nop
80104fa4:	c9                   	leave  
80104fa5:	c3                   	ret    

80104fa6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104fa6:	55                   	push   %ebp
80104fa7:	89 e5                	mov    %esp,%ebp
80104fa9:	53                   	push   %ebx
80104faa:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
80104fad:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb0:	83 c0 04             	add    $0x4,%eax
80104fb3:	83 ec 0c             	sub    $0xc,%esp
80104fb6:	50                   	push   %eax
80104fb7:	e8 a1 00 00 00       	call   8010505d <acquire>
80104fbc:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80104fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc2:	8b 00                	mov    (%eax),%eax
80104fc4:	85 c0                	test   %eax,%eax
80104fc6:	74 19                	je     80104fe1 <holdingsleep+0x3b>
80104fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcb:	8b 58 3c             	mov    0x3c(%eax),%ebx
80104fce:	e8 84 f3 ff ff       	call   80104357 <myproc>
80104fd3:	8b 40 10             	mov    0x10(%eax),%eax
80104fd6:	39 c3                	cmp    %eax,%ebx
80104fd8:	75 07                	jne    80104fe1 <holdingsleep+0x3b>
80104fda:	b8 01 00 00 00       	mov    $0x1,%eax
80104fdf:	eb 05                	jmp    80104fe6 <holdingsleep+0x40>
80104fe1:	b8 00 00 00 00       	mov    $0x0,%eax
80104fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fec:	83 c0 04             	add    $0x4,%eax
80104fef:	83 ec 0c             	sub    $0xc,%esp
80104ff2:	50                   	push   %eax
80104ff3:	e8 d3 00 00 00       	call   801050cb <release>
80104ff8:	83 c4 10             	add    $0x10,%esp
  return r;
80104ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ffe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105001:	c9                   	leave  
80105002:	c3                   	ret    

80105003 <readeflags>:
{
80105003:	55                   	push   %ebp
80105004:	89 e5                	mov    %esp,%ebp
80105006:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105009:	9c                   	pushf  
8010500a:	58                   	pop    %eax
8010500b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010500e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105011:	c9                   	leave  
80105012:	c3                   	ret    

80105013 <cli>:
{
80105013:	55                   	push   %ebp
80105014:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105016:	fa                   	cli    
}
80105017:	90                   	nop
80105018:	5d                   	pop    %ebp
80105019:	c3                   	ret    

8010501a <sti>:
{
8010501a:	55                   	push   %ebp
8010501b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010501d:	fb                   	sti    
}
8010501e:	90                   	nop
8010501f:	5d                   	pop    %ebp
80105020:	c3                   	ret    

80105021 <xchg>:
{
80105021:	55                   	push   %ebp
80105022:	89 e5                	mov    %esp,%ebp
80105024:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105027:	8b 55 08             	mov    0x8(%ebp),%edx
8010502a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010502d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105030:	f0 87 02             	lock xchg %eax,(%edx)
80105033:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105036:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105039:	c9                   	leave  
8010503a:	c3                   	ret    

8010503b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010503b:	55                   	push   %ebp
8010503c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010503e:	8b 45 08             	mov    0x8(%ebp),%eax
80105041:	8b 55 0c             	mov    0xc(%ebp),%edx
80105044:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105047:	8b 45 08             	mov    0x8(%ebp),%eax
8010504a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105050:	8b 45 08             	mov    0x8(%ebp),%eax
80105053:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010505a:	90                   	nop
8010505b:	5d                   	pop    %ebp
8010505c:	c3                   	ret    

8010505d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010505d:	55                   	push   %ebp
8010505e:	89 e5                	mov    %esp,%ebp
80105060:	53                   	push   %ebx
80105061:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105064:	e8 6f 01 00 00       	call   801051d8 <pushcli>
  if(holding(lk))
80105069:	8b 45 08             	mov    0x8(%ebp),%eax
8010506c:	83 ec 0c             	sub    $0xc,%esp
8010506f:	50                   	push   %eax
80105070:	e8 23 01 00 00       	call   80105198 <holding>
80105075:	83 c4 10             	add    $0x10,%esp
80105078:	85 c0                	test   %eax,%eax
8010507a:	74 0d                	je     80105089 <acquire+0x2c>
    panic("acquire");
8010507c:	83 ec 0c             	sub    $0xc,%esp
8010507f:	68 04 89 10 80       	push   $0x80108904
80105084:	e8 2c b5 ff ff       	call   801005b5 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105089:	90                   	nop
8010508a:	8b 45 08             	mov    0x8(%ebp),%eax
8010508d:	83 ec 08             	sub    $0x8,%esp
80105090:	6a 01                	push   $0x1
80105092:	50                   	push   %eax
80105093:	e8 89 ff ff ff       	call   80105021 <xchg>
80105098:	83 c4 10             	add    $0x10,%esp
8010509b:	85 c0                	test   %eax,%eax
8010509d:	75 eb                	jne    8010508a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010509f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801050a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
801050a7:	e8 33 f2 ff ff       	call   801042df <mycpu>
801050ac:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801050af:	8b 45 08             	mov    0x8(%ebp),%eax
801050b2:	83 c0 0c             	add    $0xc,%eax
801050b5:	83 ec 08             	sub    $0x8,%esp
801050b8:	50                   	push   %eax
801050b9:	8d 45 08             	lea    0x8(%ebp),%eax
801050bc:	50                   	push   %eax
801050bd:	e8 5b 00 00 00       	call   8010511d <getcallerpcs>
801050c2:	83 c4 10             	add    $0x10,%esp
}
801050c5:	90                   	nop
801050c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050c9:	c9                   	leave  
801050ca:	c3                   	ret    

801050cb <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050cb:	55                   	push   %ebp
801050cc:	89 e5                	mov    %esp,%ebp
801050ce:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050d1:	83 ec 0c             	sub    $0xc,%esp
801050d4:	ff 75 08             	push   0x8(%ebp)
801050d7:	e8 bc 00 00 00       	call   80105198 <holding>
801050dc:	83 c4 10             	add    $0x10,%esp
801050df:	85 c0                	test   %eax,%eax
801050e1:	75 0d                	jne    801050f0 <release+0x25>
    panic("release");
801050e3:	83 ec 0c             	sub    $0xc,%esp
801050e6:	68 0c 89 10 80       	push   $0x8010890c
801050eb:	e8 c5 b4 ff ff       	call   801005b5 <panic>

  lk->pcs[0] = 0;
801050f0:	8b 45 08             	mov    0x8(%ebp),%eax
801050f3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050fa:	8b 45 08             	mov    0x8(%ebp),%eax
801050fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105104:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105109:	8b 45 08             	mov    0x8(%ebp),%eax
8010510c:	8b 55 08             	mov    0x8(%ebp),%edx
8010510f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105115:	e8 0b 01 00 00       	call   80105225 <popcli>
}
8010511a:	90                   	nop
8010511b:	c9                   	leave  
8010511c:	c3                   	ret    

8010511d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010511d:	55                   	push   %ebp
8010511e:	89 e5                	mov    %esp,%ebp
80105120:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105123:	8b 45 08             	mov    0x8(%ebp),%eax
80105126:	83 e8 08             	sub    $0x8,%eax
80105129:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010512c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105133:	eb 38                	jmp    8010516d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105135:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105139:	74 53                	je     8010518e <getcallerpcs+0x71>
8010513b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105142:	76 4a                	jbe    8010518e <getcallerpcs+0x71>
80105144:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105148:	74 44                	je     8010518e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010514a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010514d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105154:	8b 45 0c             	mov    0xc(%ebp),%eax
80105157:	01 c2                	add    %eax,%edx
80105159:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010515c:	8b 40 04             	mov    0x4(%eax),%eax
8010515f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105161:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105164:	8b 00                	mov    (%eax),%eax
80105166:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105169:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010516d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105171:	7e c2                	jle    80105135 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105173:	eb 19                	jmp    8010518e <getcallerpcs+0x71>
    pcs[i] = 0;
80105175:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105178:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010517f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105182:	01 d0                	add    %edx,%eax
80105184:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010518a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010518e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105192:	7e e1                	jle    80105175 <getcallerpcs+0x58>
}
80105194:	90                   	nop
80105195:	90                   	nop
80105196:	c9                   	leave  
80105197:	c3                   	ret    

80105198 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105198:	55                   	push   %ebp
80105199:	89 e5                	mov    %esp,%ebp
8010519b:	53                   	push   %ebx
8010519c:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
8010519f:	e8 34 00 00 00       	call   801051d8 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801051a4:	8b 45 08             	mov    0x8(%ebp),%eax
801051a7:	8b 00                	mov    (%eax),%eax
801051a9:	85 c0                	test   %eax,%eax
801051ab:	74 16                	je     801051c3 <holding+0x2b>
801051ad:	8b 45 08             	mov    0x8(%ebp),%eax
801051b0:	8b 58 08             	mov    0x8(%eax),%ebx
801051b3:	e8 27 f1 ff ff       	call   801042df <mycpu>
801051b8:	39 c3                	cmp    %eax,%ebx
801051ba:	75 07                	jne    801051c3 <holding+0x2b>
801051bc:	b8 01 00 00 00       	mov    $0x1,%eax
801051c1:	eb 05                	jmp    801051c8 <holding+0x30>
801051c3:	b8 00 00 00 00       	mov    $0x0,%eax
801051c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
801051cb:	e8 55 00 00 00       	call   80105225 <popcli>
  return r;
801051d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801051d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051d6:	c9                   	leave  
801051d7:	c3                   	ret    

801051d8 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801051de:	e8 20 fe ff ff       	call   80105003 <readeflags>
801051e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801051e6:	e8 28 fe ff ff       	call   80105013 <cli>
  if(mycpu()->ncli == 0)
801051eb:	e8 ef f0 ff ff       	call   801042df <mycpu>
801051f0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051f6:	85 c0                	test   %eax,%eax
801051f8:	75 14                	jne    8010520e <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801051fa:	e8 e0 f0 ff ff       	call   801042df <mycpu>
801051ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105202:	81 e2 00 02 00 00    	and    $0x200,%edx
80105208:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010520e:	e8 cc f0 ff ff       	call   801042df <mycpu>
80105213:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105219:	83 c2 01             	add    $0x1,%edx
8010521c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105222:	90                   	nop
80105223:	c9                   	leave  
80105224:	c3                   	ret    

80105225 <popcli>:

void
popcli(void)
{
80105225:	55                   	push   %ebp
80105226:	89 e5                	mov    %esp,%ebp
80105228:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010522b:	e8 d3 fd ff ff       	call   80105003 <readeflags>
80105230:	25 00 02 00 00       	and    $0x200,%eax
80105235:	85 c0                	test   %eax,%eax
80105237:	74 0d                	je     80105246 <popcli+0x21>
    panic("popcli - interruptible");
80105239:	83 ec 0c             	sub    $0xc,%esp
8010523c:	68 14 89 10 80       	push   $0x80108914
80105241:	e8 6f b3 ff ff       	call   801005b5 <panic>
  if(--mycpu()->ncli < 0)
80105246:	e8 94 f0 ff ff       	call   801042df <mycpu>
8010524b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105251:	83 ea 01             	sub    $0x1,%edx
80105254:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010525a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105260:	85 c0                	test   %eax,%eax
80105262:	79 0d                	jns    80105271 <popcli+0x4c>
    panic("popcli");
80105264:	83 ec 0c             	sub    $0xc,%esp
80105267:	68 2b 89 10 80       	push   $0x8010892b
8010526c:	e8 44 b3 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105271:	e8 69 f0 ff ff       	call   801042df <mycpu>
80105276:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010527c:	85 c0                	test   %eax,%eax
8010527e:	75 14                	jne    80105294 <popcli+0x6f>
80105280:	e8 5a f0 ff ff       	call   801042df <mycpu>
80105285:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010528b:	85 c0                	test   %eax,%eax
8010528d:	74 05                	je     80105294 <popcli+0x6f>
    sti();
8010528f:	e8 86 fd ff ff       	call   8010501a <sti>
}
80105294:	90                   	nop
80105295:	c9                   	leave  
80105296:	c3                   	ret    

80105297 <stosb>:
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
8010529a:	57                   	push   %edi
8010529b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010529c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010529f:	8b 55 10             	mov    0x10(%ebp),%edx
801052a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a5:	89 cb                	mov    %ecx,%ebx
801052a7:	89 df                	mov    %ebx,%edi
801052a9:	89 d1                	mov    %edx,%ecx
801052ab:	fc                   	cld    
801052ac:	f3 aa                	rep stos %al,%es:(%edi)
801052ae:	89 ca                	mov    %ecx,%edx
801052b0:	89 fb                	mov    %edi,%ebx
801052b2:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052b5:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052b8:	90                   	nop
801052b9:	5b                   	pop    %ebx
801052ba:	5f                   	pop    %edi
801052bb:	5d                   	pop    %ebp
801052bc:	c3                   	ret    

801052bd <stosl>:
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	57                   	push   %edi
801052c1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052c5:	8b 55 10             	mov    0x10(%ebp),%edx
801052c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cb:	89 cb                	mov    %ecx,%ebx
801052cd:	89 df                	mov    %ebx,%edi
801052cf:	89 d1                	mov    %edx,%ecx
801052d1:	fc                   	cld    
801052d2:	f3 ab                	rep stos %eax,%es:(%edi)
801052d4:	89 ca                	mov    %ecx,%edx
801052d6:	89 fb                	mov    %edi,%ebx
801052d8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052db:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052de:	90                   	nop
801052df:	5b                   	pop    %ebx
801052e0:	5f                   	pop    %edi
801052e1:	5d                   	pop    %ebp
801052e2:	c3                   	ret    

801052e3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052e3:	55                   	push   %ebp
801052e4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052e6:	8b 45 08             	mov    0x8(%ebp),%eax
801052e9:	83 e0 03             	and    $0x3,%eax
801052ec:	85 c0                	test   %eax,%eax
801052ee:	75 43                	jne    80105333 <memset+0x50>
801052f0:	8b 45 10             	mov    0x10(%ebp),%eax
801052f3:	83 e0 03             	and    $0x3,%eax
801052f6:	85 c0                	test   %eax,%eax
801052f8:	75 39                	jne    80105333 <memset+0x50>
    c &= 0xFF;
801052fa:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105301:	8b 45 10             	mov    0x10(%ebp),%eax
80105304:	c1 e8 02             	shr    $0x2,%eax
80105307:	89 c2                	mov    %eax,%edx
80105309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530c:	c1 e0 18             	shl    $0x18,%eax
8010530f:	89 c1                	mov    %eax,%ecx
80105311:	8b 45 0c             	mov    0xc(%ebp),%eax
80105314:	c1 e0 10             	shl    $0x10,%eax
80105317:	09 c1                	or     %eax,%ecx
80105319:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531c:	c1 e0 08             	shl    $0x8,%eax
8010531f:	09 c8                	or     %ecx,%eax
80105321:	0b 45 0c             	or     0xc(%ebp),%eax
80105324:	52                   	push   %edx
80105325:	50                   	push   %eax
80105326:	ff 75 08             	push   0x8(%ebp)
80105329:	e8 8f ff ff ff       	call   801052bd <stosl>
8010532e:	83 c4 0c             	add    $0xc,%esp
80105331:	eb 12                	jmp    80105345 <memset+0x62>
  } else
    stosb(dst, c, n);
80105333:	8b 45 10             	mov    0x10(%ebp),%eax
80105336:	50                   	push   %eax
80105337:	ff 75 0c             	push   0xc(%ebp)
8010533a:	ff 75 08             	push   0x8(%ebp)
8010533d:	e8 55 ff ff ff       	call   80105297 <stosb>
80105342:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105345:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105348:	c9                   	leave  
80105349:	c3                   	ret    

8010534a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010534a:	55                   	push   %ebp
8010534b:	89 e5                	mov    %esp,%ebp
8010534d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105350:	8b 45 08             	mov    0x8(%ebp),%eax
80105353:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105356:	8b 45 0c             	mov    0xc(%ebp),%eax
80105359:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010535c:	eb 30                	jmp    8010538e <memcmp+0x44>
    if(*s1 != *s2)
8010535e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105361:	0f b6 10             	movzbl (%eax),%edx
80105364:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105367:	0f b6 00             	movzbl (%eax),%eax
8010536a:	38 c2                	cmp    %al,%dl
8010536c:	74 18                	je     80105386 <memcmp+0x3c>
      return *s1 - *s2;
8010536e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105371:	0f b6 00             	movzbl (%eax),%eax
80105374:	0f b6 d0             	movzbl %al,%edx
80105377:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537a:	0f b6 00             	movzbl (%eax),%eax
8010537d:	0f b6 c8             	movzbl %al,%ecx
80105380:	89 d0                	mov    %edx,%eax
80105382:	29 c8                	sub    %ecx,%eax
80105384:	eb 1a                	jmp    801053a0 <memcmp+0x56>
    s1++, s2++;
80105386:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010538a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010538e:	8b 45 10             	mov    0x10(%ebp),%eax
80105391:	8d 50 ff             	lea    -0x1(%eax),%edx
80105394:	89 55 10             	mov    %edx,0x10(%ebp)
80105397:	85 c0                	test   %eax,%eax
80105399:	75 c3                	jne    8010535e <memcmp+0x14>
  }

  return 0;
8010539b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053a0:	c9                   	leave  
801053a1:	c3                   	ret    

801053a2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053a2:	55                   	push   %ebp
801053a3:	89 e5                	mov    %esp,%ebp
801053a5:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053ba:	73 54                	jae    80105410 <memmove+0x6e>
801053bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053bf:	8b 45 10             	mov    0x10(%ebp),%eax
801053c2:	01 d0                	add    %edx,%eax
801053c4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053c7:	73 47                	jae    80105410 <memmove+0x6e>
    s += n;
801053c9:	8b 45 10             	mov    0x10(%ebp),%eax
801053cc:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053cf:	8b 45 10             	mov    0x10(%ebp),%eax
801053d2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053d5:	eb 13                	jmp    801053ea <memmove+0x48>
      *--d = *--s;
801053d7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053db:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e2:	0f b6 10             	movzbl (%eax),%edx
801053e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e8:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053ea:	8b 45 10             	mov    0x10(%ebp),%eax
801053ed:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f0:	89 55 10             	mov    %edx,0x10(%ebp)
801053f3:	85 c0                	test   %eax,%eax
801053f5:	75 e0                	jne    801053d7 <memmove+0x35>
  if(s < d && s + n > d){
801053f7:	eb 24                	jmp    8010541d <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053fc:	8d 42 01             	lea    0x1(%edx),%eax
801053ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105402:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105405:	8d 48 01             	lea    0x1(%eax),%ecx
80105408:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010540b:	0f b6 12             	movzbl (%edx),%edx
8010540e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105410:	8b 45 10             	mov    0x10(%ebp),%eax
80105413:	8d 50 ff             	lea    -0x1(%eax),%edx
80105416:	89 55 10             	mov    %edx,0x10(%ebp)
80105419:	85 c0                	test   %eax,%eax
8010541b:	75 dc                	jne    801053f9 <memmove+0x57>

  return dst;
8010541d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105420:	c9                   	leave  
80105421:	c3                   	ret    

80105422 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105425:	ff 75 10             	push   0x10(%ebp)
80105428:	ff 75 0c             	push   0xc(%ebp)
8010542b:	ff 75 08             	push   0x8(%ebp)
8010542e:	e8 6f ff ff ff       	call   801053a2 <memmove>
80105433:	83 c4 0c             	add    $0xc,%esp
}
80105436:	c9                   	leave  
80105437:	c3                   	ret    

80105438 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105438:	55                   	push   %ebp
80105439:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010543b:	eb 0c                	jmp    80105449 <strncmp+0x11>
    n--, p++, q++;
8010543d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105441:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105445:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105449:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010544d:	74 1a                	je     80105469 <strncmp+0x31>
8010544f:	8b 45 08             	mov    0x8(%ebp),%eax
80105452:	0f b6 00             	movzbl (%eax),%eax
80105455:	84 c0                	test   %al,%al
80105457:	74 10                	je     80105469 <strncmp+0x31>
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
8010545c:	0f b6 10             	movzbl (%eax),%edx
8010545f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105462:	0f b6 00             	movzbl (%eax),%eax
80105465:	38 c2                	cmp    %al,%dl
80105467:	74 d4                	je     8010543d <strncmp+0x5>
  if(n == 0)
80105469:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010546d:	75 07                	jne    80105476 <strncmp+0x3e>
    return 0;
8010546f:	b8 00 00 00 00       	mov    $0x0,%eax
80105474:	eb 16                	jmp    8010548c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105476:	8b 45 08             	mov    0x8(%ebp),%eax
80105479:	0f b6 00             	movzbl (%eax),%eax
8010547c:	0f b6 d0             	movzbl %al,%edx
8010547f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105482:	0f b6 00             	movzbl (%eax),%eax
80105485:	0f b6 c8             	movzbl %al,%ecx
80105488:	89 d0                	mov    %edx,%eax
8010548a:	29 c8                	sub    %ecx,%eax
}
8010548c:	5d                   	pop    %ebp
8010548d:	c3                   	ret    

8010548e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010548e:	55                   	push   %ebp
8010548f:	89 e5                	mov    %esp,%ebp
80105491:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105494:	8b 45 08             	mov    0x8(%ebp),%eax
80105497:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010549a:	90                   	nop
8010549b:	8b 45 10             	mov    0x10(%ebp),%eax
8010549e:	8d 50 ff             	lea    -0x1(%eax),%edx
801054a1:	89 55 10             	mov    %edx,0x10(%ebp)
801054a4:	85 c0                	test   %eax,%eax
801054a6:	7e 2c                	jle    801054d4 <strncpy+0x46>
801054a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ab:	8d 42 01             	lea    0x1(%edx),%eax
801054ae:	89 45 0c             	mov    %eax,0xc(%ebp)
801054b1:	8b 45 08             	mov    0x8(%ebp),%eax
801054b4:	8d 48 01             	lea    0x1(%eax),%ecx
801054b7:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054ba:	0f b6 12             	movzbl (%edx),%edx
801054bd:	88 10                	mov    %dl,(%eax)
801054bf:	0f b6 00             	movzbl (%eax),%eax
801054c2:	84 c0                	test   %al,%al
801054c4:	75 d5                	jne    8010549b <strncpy+0xd>
    ;
  while(n-- > 0)
801054c6:	eb 0c                	jmp    801054d4 <strncpy+0x46>
    *s++ = 0;
801054c8:	8b 45 08             	mov    0x8(%ebp),%eax
801054cb:	8d 50 01             	lea    0x1(%eax),%edx
801054ce:	89 55 08             	mov    %edx,0x8(%ebp)
801054d1:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054d4:	8b 45 10             	mov    0x10(%ebp),%eax
801054d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801054da:	89 55 10             	mov    %edx,0x10(%ebp)
801054dd:	85 c0                	test   %eax,%eax
801054df:	7f e7                	jg     801054c8 <strncpy+0x3a>
  return os;
801054e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054e4:	c9                   	leave  
801054e5:	c3                   	ret    

801054e6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054e6:	55                   	push   %ebp
801054e7:	89 e5                	mov    %esp,%ebp
801054e9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054ec:	8b 45 08             	mov    0x8(%ebp),%eax
801054ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054f6:	7f 05                	jg     801054fd <safestrcpy+0x17>
    return os;
801054f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054fb:	eb 32                	jmp    8010552f <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801054fd:	90                   	nop
801054fe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105502:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105506:	7e 1e                	jle    80105526 <safestrcpy+0x40>
80105508:	8b 55 0c             	mov    0xc(%ebp),%edx
8010550b:	8d 42 01             	lea    0x1(%edx),%eax
8010550e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105511:	8b 45 08             	mov    0x8(%ebp),%eax
80105514:	8d 48 01             	lea    0x1(%eax),%ecx
80105517:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010551a:	0f b6 12             	movzbl (%edx),%edx
8010551d:	88 10                	mov    %dl,(%eax)
8010551f:	0f b6 00             	movzbl (%eax),%eax
80105522:	84 c0                	test   %al,%al
80105524:	75 d8                	jne    801054fe <safestrcpy+0x18>
    ;
  *s = 0;
80105526:	8b 45 08             	mov    0x8(%ebp),%eax
80105529:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010552c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552f:	c9                   	leave  
80105530:	c3                   	ret    

80105531 <strlen>:

int
strlen(const char *s)
{
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
80105534:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105537:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010553e:	eb 04                	jmp    80105544 <strlen+0x13>
80105540:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105544:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105547:	8b 45 08             	mov    0x8(%ebp),%eax
8010554a:	01 d0                	add    %edx,%eax
8010554c:	0f b6 00             	movzbl (%eax),%eax
8010554f:	84 c0                	test   %al,%al
80105551:	75 ed                	jne    80105540 <strlen+0xf>
    ;
  return n;
80105553:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105556:	c9                   	leave  
80105557:	c3                   	ret    

80105558 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105558:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010555c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105560:	55                   	push   %ebp
  pushl %ebx
80105561:	53                   	push   %ebx
  pushl %esi
80105562:	56                   	push   %esi
  pushl %edi
80105563:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105564:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105566:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80105568:	5f                   	pop    %edi
  popl %esi
80105569:	5e                   	pop    %esi
  popl %ebx
8010556a:	5b                   	pop    %ebx
  popl %ebp
8010556b:	5d                   	pop    %ebp
  ret
8010556c:	c3                   	ret    

8010556d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010556d:	55                   	push   %ebp
8010556e:	89 e5                	mov    %esp,%ebp
80105570:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105573:	e8 df ed ff ff       	call   80104357 <myproc>
80105578:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010557b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557e:	8b 00                	mov    (%eax),%eax
80105580:	39 45 08             	cmp    %eax,0x8(%ebp)
80105583:	73 0f                	jae    80105594 <fetchint+0x27>
80105585:	8b 45 08             	mov    0x8(%ebp),%eax
80105588:	8d 50 04             	lea    0x4(%eax),%edx
8010558b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558e:	8b 00                	mov    (%eax),%eax
80105590:	39 c2                	cmp    %eax,%edx
80105592:	76 07                	jbe    8010559b <fetchint+0x2e>
    return -1;
80105594:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105599:	eb 0f                	jmp    801055aa <fetchint+0x3d>
  *ip = *(int*)(addr);
8010559b:	8b 45 08             	mov    0x8(%ebp),%eax
8010559e:	8b 10                	mov    (%eax),%edx
801055a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a3:	89 10                	mov    %edx,(%eax)
  return 0;
801055a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055aa:	c9                   	leave  
801055ab:	c3                   	ret    

801055ac <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055ac:	55                   	push   %ebp
801055ad:	89 e5                	mov    %esp,%ebp
801055af:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801055b2:	e8 a0 ed ff ff       	call   80104357 <myproc>
801055b7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801055ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055bd:	8b 00                	mov    (%eax),%eax
801055bf:	39 45 08             	cmp    %eax,0x8(%ebp)
801055c2:	72 07                	jb     801055cb <fetchstr+0x1f>
    return -1;
801055c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c9:	eb 41                	jmp    8010560c <fetchstr+0x60>
  *pp = (char*)addr;
801055cb:	8b 55 08             	mov    0x8(%ebp),%edx
801055ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d1:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801055d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d6:	8b 00                	mov    (%eax),%eax
801055d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801055db:	8b 45 0c             	mov    0xc(%ebp),%eax
801055de:	8b 00                	mov    (%eax),%eax
801055e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055e3:	eb 1a                	jmp    801055ff <fetchstr+0x53>
    if(*s == 0)
801055e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e8:	0f b6 00             	movzbl (%eax),%eax
801055eb:	84 c0                	test   %al,%al
801055ed:	75 0c                	jne    801055fb <fetchstr+0x4f>
      return s - *pp;
801055ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f2:	8b 10                	mov    (%eax),%edx
801055f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f7:	29 d0                	sub    %edx,%eax
801055f9:	eb 11                	jmp    8010560c <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801055fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105602:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105605:	72 de                	jb     801055e5 <fetchstr+0x39>
  }
  return -1;
80105607:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010560c:	c9                   	leave  
8010560d:	c3                   	ret    

8010560e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010560e:	55                   	push   %ebp
8010560f:	89 e5                	mov    %esp,%ebp
80105611:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105614:	e8 3e ed ff ff       	call   80104357 <myproc>
80105619:	8b 40 18             	mov    0x18(%eax),%eax
8010561c:	8b 50 44             	mov    0x44(%eax),%edx
8010561f:	8b 45 08             	mov    0x8(%ebp),%eax
80105622:	c1 e0 02             	shl    $0x2,%eax
80105625:	01 d0                	add    %edx,%eax
80105627:	83 c0 04             	add    $0x4,%eax
8010562a:	83 ec 08             	sub    $0x8,%esp
8010562d:	ff 75 0c             	push   0xc(%ebp)
80105630:	50                   	push   %eax
80105631:	e8 37 ff ff ff       	call   8010556d <fetchint>
80105636:	83 c4 10             	add    $0x10,%esp
}
80105639:	c9                   	leave  
8010563a:	c3                   	ret    

8010563b <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010563b:	55                   	push   %ebp
8010563c:	89 e5                	mov    %esp,%ebp
8010563e:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105641:	e8 11 ed ff ff       	call   80104357 <myproc>
80105646:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105649:	83 ec 08             	sub    $0x8,%esp
8010564c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010564f:	50                   	push   %eax
80105650:	ff 75 08             	push   0x8(%ebp)
80105653:	e8 b6 ff ff ff       	call   8010560e <argint>
80105658:	83 c4 10             	add    $0x10,%esp
8010565b:	85 c0                	test   %eax,%eax
8010565d:	79 07                	jns    80105666 <argptr+0x2b>
    return -1;
8010565f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105664:	eb 3b                	jmp    801056a1 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105666:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010566a:	78 1f                	js     8010568b <argptr+0x50>
8010566c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566f:	8b 00                	mov    (%eax),%eax
80105671:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105674:	39 d0                	cmp    %edx,%eax
80105676:	76 13                	jbe    8010568b <argptr+0x50>
80105678:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010567b:	89 c2                	mov    %eax,%edx
8010567d:	8b 45 10             	mov    0x10(%ebp),%eax
80105680:	01 c2                	add    %eax,%edx
80105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105685:	8b 00                	mov    (%eax),%eax
80105687:	39 c2                	cmp    %eax,%edx
80105689:	76 07                	jbe    80105692 <argptr+0x57>
    return -1;
8010568b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105690:	eb 0f                	jmp    801056a1 <argptr+0x66>
  *pp = (char*)i;
80105692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105695:	89 c2                	mov    %eax,%edx
80105697:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569a:	89 10                	mov    %edx,(%eax)
  return 0;
8010569c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a1:	c9                   	leave  
801056a2:	c3                   	ret    

801056a3 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056a3:	55                   	push   %ebp
801056a4:	89 e5                	mov    %esp,%ebp
801056a6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056a9:	83 ec 08             	sub    $0x8,%esp
801056ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056af:	50                   	push   %eax
801056b0:	ff 75 08             	push   0x8(%ebp)
801056b3:	e8 56 ff ff ff       	call   8010560e <argint>
801056b8:	83 c4 10             	add    $0x10,%esp
801056bb:	85 c0                	test   %eax,%eax
801056bd:	79 07                	jns    801056c6 <argstr+0x23>
    return -1;
801056bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c4:	eb 12                	jmp    801056d8 <argstr+0x35>
  return fetchstr(addr, pp);
801056c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c9:	83 ec 08             	sub    $0x8,%esp
801056cc:	ff 75 0c             	push   0xc(%ebp)
801056cf:	50                   	push   %eax
801056d0:	e8 d7 fe ff ff       	call   801055ac <fetchstr>
801056d5:	83 c4 10             	add    $0x10,%esp
}
801056d8:	c9                   	leave  
801056d9:	c3                   	ret    

801056da <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801056da:	55                   	push   %ebp
801056db:	89 e5                	mov    %esp,%ebp
801056dd:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801056e0:	e8 72 ec ff ff       	call   80104357 <myproc>
801056e5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801056e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056eb:	8b 40 18             	mov    0x18(%eax),%eax
801056ee:	8b 40 1c             	mov    0x1c(%eax),%eax
801056f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056f8:	7e 2f                	jle    80105729 <syscall+0x4f>
801056fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056fd:	83 f8 15             	cmp    $0x15,%eax
80105700:	77 27                	ja     80105729 <syscall+0x4f>
80105702:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105705:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010570c:	85 c0                	test   %eax,%eax
8010570e:	74 19                	je     80105729 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105713:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
8010571a:	ff d0                	call   *%eax
8010571c:	89 c2                	mov    %eax,%edx
8010571e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105721:	8b 40 18             	mov    0x18(%eax),%eax
80105724:	89 50 1c             	mov    %edx,0x1c(%eax)
80105727:	eb 2c                	jmp    80105755 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572c:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010572f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105732:	8b 40 10             	mov    0x10(%eax),%eax
80105735:	ff 75 f0             	push   -0x10(%ebp)
80105738:	52                   	push   %edx
80105739:	50                   	push   %eax
8010573a:	68 32 89 10 80       	push   $0x80108932
8010573f:	e8 bc ac ff ff       	call   80100400 <cprintf>
80105744:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574a:	8b 40 18             	mov    0x18(%eax),%eax
8010574d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105754:	90                   	nop
80105755:	90                   	nop
80105756:	c9                   	leave  
80105757:	c3                   	ret    

80105758 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105758:	55                   	push   %ebp
80105759:	89 e5                	mov    %esp,%ebp
8010575b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010575e:	83 ec 08             	sub    $0x8,%esp
80105761:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105764:	50                   	push   %eax
80105765:	ff 75 08             	push   0x8(%ebp)
80105768:	e8 a1 fe ff ff       	call   8010560e <argint>
8010576d:	83 c4 10             	add    $0x10,%esp
80105770:	85 c0                	test   %eax,%eax
80105772:	79 07                	jns    8010577b <argfd+0x23>
    return -1;
80105774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105779:	eb 4f                	jmp    801057ca <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010577b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577e:	85 c0                	test   %eax,%eax
80105780:	78 20                	js     801057a2 <argfd+0x4a>
80105782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105785:	83 f8 0f             	cmp    $0xf,%eax
80105788:	7f 18                	jg     801057a2 <argfd+0x4a>
8010578a:	e8 c8 eb ff ff       	call   80104357 <myproc>
8010578f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105792:	83 c2 08             	add    $0x8,%edx
80105795:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105799:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010579c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a0:	75 07                	jne    801057a9 <argfd+0x51>
    return -1;
801057a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a7:	eb 21                	jmp    801057ca <argfd+0x72>
  if(pfd)
801057a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057ad:	74 08                	je     801057b7 <argfd+0x5f>
    *pfd = fd;
801057af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801057b5:	89 10                	mov    %edx,(%eax)
  if(pf)
801057b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057bb:	74 08                	je     801057c5 <argfd+0x6d>
    *pf = f;
801057bd:	8b 45 10             	mov    0x10(%ebp),%eax
801057c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c3:	89 10                	mov    %edx,(%eax)
  return 0;
801057c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057ca:	c9                   	leave  
801057cb:	c3                   	ret    

801057cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057cc:	55                   	push   %ebp
801057cd:	89 e5                	mov    %esp,%ebp
801057cf:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801057d2:	e8 80 eb ff ff       	call   80104357 <myproc>
801057d7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801057da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801057e1:	eb 2a                	jmp    8010580d <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801057e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057e9:	83 c2 08             	add    $0x8,%edx
801057ec:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057f0:	85 c0                	test   %eax,%eax
801057f2:	75 15                	jne    80105809 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801057f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057fa:	8d 4a 08             	lea    0x8(%edx),%ecx
801057fd:	8b 55 08             	mov    0x8(%ebp),%edx
80105800:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105807:	eb 0f                	jmp    80105818 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105809:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010580d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105811:	7e d0                	jle    801057e3 <fdalloc+0x17>
    }
  }
  return -1;
80105813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105818:	c9                   	leave  
80105819:	c3                   	ret    

8010581a <sys_dup>:

int
sys_dup(void)
{
8010581a:	55                   	push   %ebp
8010581b:	89 e5                	mov    %esp,%ebp
8010581d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105820:	83 ec 04             	sub    $0x4,%esp
80105823:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105826:	50                   	push   %eax
80105827:	6a 00                	push   $0x0
80105829:	6a 00                	push   $0x0
8010582b:	e8 28 ff ff ff       	call   80105758 <argfd>
80105830:	83 c4 10             	add    $0x10,%esp
80105833:	85 c0                	test   %eax,%eax
80105835:	79 07                	jns    8010583e <sys_dup+0x24>
    return -1;
80105837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583c:	eb 31                	jmp    8010586f <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010583e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105841:	83 ec 0c             	sub    $0xc,%esp
80105844:	50                   	push   %eax
80105845:	e8 82 ff ff ff       	call   801057cc <fdalloc>
8010584a:	83 c4 10             	add    $0x10,%esp
8010584d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105850:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105854:	79 07                	jns    8010585d <sys_dup+0x43>
    return -1;
80105856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010585b:	eb 12                	jmp    8010586f <sys_dup+0x55>
  filedup(f);
8010585d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105860:	83 ec 0c             	sub    $0xc,%esp
80105863:	50                   	push   %eax
80105864:	e8 e2 b8 ff ff       	call   8010114b <filedup>
80105869:	83 c4 10             	add    $0x10,%esp
  return fd;
8010586c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010586f:	c9                   	leave  
80105870:	c3                   	ret    

80105871 <sys_read>:

int
sys_read(void)
{
80105871:	55                   	push   %ebp
80105872:	89 e5                	mov    %esp,%ebp
80105874:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105877:	83 ec 04             	sub    $0x4,%esp
8010587a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010587d:	50                   	push   %eax
8010587e:	6a 00                	push   $0x0
80105880:	6a 00                	push   $0x0
80105882:	e8 d1 fe ff ff       	call   80105758 <argfd>
80105887:	83 c4 10             	add    $0x10,%esp
8010588a:	85 c0                	test   %eax,%eax
8010588c:	78 2e                	js     801058bc <sys_read+0x4b>
8010588e:	83 ec 08             	sub    $0x8,%esp
80105891:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105894:	50                   	push   %eax
80105895:	6a 02                	push   $0x2
80105897:	e8 72 fd ff ff       	call   8010560e <argint>
8010589c:	83 c4 10             	add    $0x10,%esp
8010589f:	85 c0                	test   %eax,%eax
801058a1:	78 19                	js     801058bc <sys_read+0x4b>
801058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a6:	83 ec 04             	sub    $0x4,%esp
801058a9:	50                   	push   %eax
801058aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058ad:	50                   	push   %eax
801058ae:	6a 01                	push   $0x1
801058b0:	e8 86 fd ff ff       	call   8010563b <argptr>
801058b5:	83 c4 10             	add    $0x10,%esp
801058b8:	85 c0                	test   %eax,%eax
801058ba:	79 07                	jns    801058c3 <sys_read+0x52>
    return -1;
801058bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c1:	eb 17                	jmp    801058da <sys_read+0x69>
  return fileread(f, p, n);
801058c3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cc:	83 ec 04             	sub    $0x4,%esp
801058cf:	51                   	push   %ecx
801058d0:	52                   	push   %edx
801058d1:	50                   	push   %eax
801058d2:	e8 04 ba ff ff       	call   801012db <fileread>
801058d7:	83 c4 10             	add    $0x10,%esp
}
801058da:	c9                   	leave  
801058db:	c3                   	ret    

801058dc <sys_write>:

int
sys_write(void)
{
801058dc:	55                   	push   %ebp
801058dd:	89 e5                	mov    %esp,%ebp
801058df:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058e2:	83 ec 04             	sub    $0x4,%esp
801058e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058e8:	50                   	push   %eax
801058e9:	6a 00                	push   $0x0
801058eb:	6a 00                	push   $0x0
801058ed:	e8 66 fe ff ff       	call   80105758 <argfd>
801058f2:	83 c4 10             	add    $0x10,%esp
801058f5:	85 c0                	test   %eax,%eax
801058f7:	78 2e                	js     80105927 <sys_write+0x4b>
801058f9:	83 ec 08             	sub    $0x8,%esp
801058fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ff:	50                   	push   %eax
80105900:	6a 02                	push   $0x2
80105902:	e8 07 fd ff ff       	call   8010560e <argint>
80105907:	83 c4 10             	add    $0x10,%esp
8010590a:	85 c0                	test   %eax,%eax
8010590c:	78 19                	js     80105927 <sys_write+0x4b>
8010590e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105911:	83 ec 04             	sub    $0x4,%esp
80105914:	50                   	push   %eax
80105915:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105918:	50                   	push   %eax
80105919:	6a 01                	push   $0x1
8010591b:	e8 1b fd ff ff       	call   8010563b <argptr>
80105920:	83 c4 10             	add    $0x10,%esp
80105923:	85 c0                	test   %eax,%eax
80105925:	79 07                	jns    8010592e <sys_write+0x52>
    return -1;
80105927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592c:	eb 17                	jmp    80105945 <sys_write+0x69>
  return filewrite(f, p, n);
8010592e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105931:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105937:	83 ec 04             	sub    $0x4,%esp
8010593a:	51                   	push   %ecx
8010593b:	52                   	push   %edx
8010593c:	50                   	push   %eax
8010593d:	e8 51 ba ff ff       	call   80101393 <filewrite>
80105942:	83 c4 10             	add    $0x10,%esp
}
80105945:	c9                   	leave  
80105946:	c3                   	ret    

80105947 <sys_close>:

int
sys_close(void)
{
80105947:	55                   	push   %ebp
80105948:	89 e5                	mov    %esp,%ebp
8010594a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010594d:	83 ec 04             	sub    $0x4,%esp
80105950:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105953:	50                   	push   %eax
80105954:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105957:	50                   	push   %eax
80105958:	6a 00                	push   $0x0
8010595a:	e8 f9 fd ff ff       	call   80105758 <argfd>
8010595f:	83 c4 10             	add    $0x10,%esp
80105962:	85 c0                	test   %eax,%eax
80105964:	79 07                	jns    8010596d <sys_close+0x26>
    return -1;
80105966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596b:	eb 27                	jmp    80105994 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
8010596d:	e8 e5 e9 ff ff       	call   80104357 <myproc>
80105972:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105975:	83 c2 08             	add    $0x8,%edx
80105978:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010597f:	00 
  fileclose(f);
80105980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105983:	83 ec 0c             	sub    $0xc,%esp
80105986:	50                   	push   %eax
80105987:	e8 10 b8 ff ff       	call   8010119c <fileclose>
8010598c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010598f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105994:	c9                   	leave  
80105995:	c3                   	ret    

80105996 <sys_fstat>:

int
sys_fstat(void)
{
80105996:	55                   	push   %ebp
80105997:	89 e5                	mov    %esp,%ebp
80105999:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010599c:	83 ec 04             	sub    $0x4,%esp
8010599f:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059a2:	50                   	push   %eax
801059a3:	6a 00                	push   $0x0
801059a5:	6a 00                	push   $0x0
801059a7:	e8 ac fd ff ff       	call   80105758 <argfd>
801059ac:	83 c4 10             	add    $0x10,%esp
801059af:	85 c0                	test   %eax,%eax
801059b1:	78 17                	js     801059ca <sys_fstat+0x34>
801059b3:	83 ec 04             	sub    $0x4,%esp
801059b6:	6a 14                	push   $0x14
801059b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059bb:	50                   	push   %eax
801059bc:	6a 01                	push   $0x1
801059be:	e8 78 fc ff ff       	call   8010563b <argptr>
801059c3:	83 c4 10             	add    $0x10,%esp
801059c6:	85 c0                	test   %eax,%eax
801059c8:	79 07                	jns    801059d1 <sys_fstat+0x3b>
    return -1;
801059ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cf:	eb 13                	jmp    801059e4 <sys_fstat+0x4e>
  return filestat(f, st);
801059d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d7:	83 ec 08             	sub    $0x8,%esp
801059da:	52                   	push   %edx
801059db:	50                   	push   %eax
801059dc:	e8 a3 b8 ff ff       	call   80101284 <filestat>
801059e1:	83 c4 10             	add    $0x10,%esp
}
801059e4:	c9                   	leave  
801059e5:	c3                   	ret    

801059e6 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059e6:	55                   	push   %ebp
801059e7:	89 e5                	mov    %esp,%ebp
801059e9:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059ec:	83 ec 08             	sub    $0x8,%esp
801059ef:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059f2:	50                   	push   %eax
801059f3:	6a 00                	push   $0x0
801059f5:	e8 a9 fc ff ff       	call   801056a3 <argstr>
801059fa:	83 c4 10             	add    $0x10,%esp
801059fd:	85 c0                	test   %eax,%eax
801059ff:	78 15                	js     80105a16 <sys_link+0x30>
80105a01:	83 ec 08             	sub    $0x8,%esp
80105a04:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a07:	50                   	push   %eax
80105a08:	6a 01                	push   $0x1
80105a0a:	e8 94 fc ff ff       	call   801056a3 <argstr>
80105a0f:	83 c4 10             	add    $0x10,%esp
80105a12:	85 c0                	test   %eax,%eax
80105a14:	79 0a                	jns    80105a20 <sys_link+0x3a>
    return -1;
80105a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1b:	e9 68 01 00 00       	jmp    80105b88 <sys_link+0x1a2>

  begin_op();
80105a20:	e8 cb db ff ff       	call   801035f0 <begin_op>
  if((ip = namei(old)) == 0){
80105a25:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a28:	83 ec 0c             	sub    $0xc,%esp
80105a2b:	50                   	push   %eax
80105a2c:	e8 da cb ff ff       	call   8010260b <namei>
80105a31:	83 c4 10             	add    $0x10,%esp
80105a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a3b:	75 0f                	jne    80105a4c <sys_link+0x66>
    end_op();
80105a3d:	e8 3a dc ff ff       	call   8010367c <end_op>
    return -1;
80105a42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a47:	e9 3c 01 00 00       	jmp    80105b88 <sys_link+0x1a2>
  }

  ilock(ip);
80105a4c:	83 ec 0c             	sub    $0xc,%esp
80105a4f:	ff 75 f4             	push   -0xc(%ebp)
80105a52:	e8 81 c0 ff ff       	call   80101ad8 <ilock>
80105a57:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a61:	66 83 f8 01          	cmp    $0x1,%ax
80105a65:	75 1d                	jne    80105a84 <sys_link+0x9e>
    iunlockput(ip);
80105a67:	83 ec 0c             	sub    $0xc,%esp
80105a6a:	ff 75 f4             	push   -0xc(%ebp)
80105a6d:	e8 97 c2 ff ff       	call   80101d09 <iunlockput>
80105a72:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a75:	e8 02 dc ff ff       	call   8010367c <end_op>
    return -1;
80105a7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7f:	e9 04 01 00 00       	jmp    80105b88 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a87:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a8b:	83 c0 01             	add    $0x1,%eax
80105a8e:	89 c2                	mov    %eax,%edx
80105a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a93:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a97:	83 ec 0c             	sub    $0xc,%esp
80105a9a:	ff 75 f4             	push   -0xc(%ebp)
80105a9d:	e8 59 be ff ff       	call   801018fb <iupdate>
80105aa2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105aa5:	83 ec 0c             	sub    $0xc,%esp
80105aa8:	ff 75 f4             	push   -0xc(%ebp)
80105aab:	e8 3b c1 ff ff       	call   80101beb <iunlock>
80105ab0:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105ab3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ab6:	83 ec 08             	sub    $0x8,%esp
80105ab9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105abc:	52                   	push   %edx
80105abd:	50                   	push   %eax
80105abe:	e8 64 cb ff ff       	call   80102627 <nameiparent>
80105ac3:	83 c4 10             	add    $0x10,%esp
80105ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ac9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105acd:	74 71                	je     80105b40 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	ff 75 f0             	push   -0x10(%ebp)
80105ad5:	e8 fe bf ff ff       	call   80101ad8 <ilock>
80105ada:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae0:	8b 10                	mov    (%eax),%edx
80105ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae5:	8b 00                	mov    (%eax),%eax
80105ae7:	39 c2                	cmp    %eax,%edx
80105ae9:	75 1d                	jne    80105b08 <sys_link+0x122>
80105aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aee:	8b 40 04             	mov    0x4(%eax),%eax
80105af1:	83 ec 04             	sub    $0x4,%esp
80105af4:	50                   	push   %eax
80105af5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105af8:	50                   	push   %eax
80105af9:	ff 75 f0             	push   -0x10(%ebp)
80105afc:	e8 73 c8 ff ff       	call   80102374 <dirlink>
80105b01:	83 c4 10             	add    $0x10,%esp
80105b04:	85 c0                	test   %eax,%eax
80105b06:	79 10                	jns    80105b18 <sys_link+0x132>
    iunlockput(dp);
80105b08:	83 ec 0c             	sub    $0xc,%esp
80105b0b:	ff 75 f0             	push   -0x10(%ebp)
80105b0e:	e8 f6 c1 ff ff       	call   80101d09 <iunlockput>
80105b13:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b16:	eb 29                	jmp    80105b41 <sys_link+0x15b>
  }
  iunlockput(dp);
80105b18:	83 ec 0c             	sub    $0xc,%esp
80105b1b:	ff 75 f0             	push   -0x10(%ebp)
80105b1e:	e8 e6 c1 ff ff       	call   80101d09 <iunlockput>
80105b23:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b26:	83 ec 0c             	sub    $0xc,%esp
80105b29:	ff 75 f4             	push   -0xc(%ebp)
80105b2c:	e8 08 c1 ff ff       	call   80101c39 <iput>
80105b31:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b34:	e8 43 db ff ff       	call   8010367c <end_op>

  return 0;
80105b39:	b8 00 00 00 00       	mov    $0x0,%eax
80105b3e:	eb 48                	jmp    80105b88 <sys_link+0x1a2>
    goto bad;
80105b40:	90                   	nop

bad:
  ilock(ip);
80105b41:	83 ec 0c             	sub    $0xc,%esp
80105b44:	ff 75 f4             	push   -0xc(%ebp)
80105b47:	e8 8c bf ff ff       	call   80101ad8 <ilock>
80105b4c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b52:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b56:	83 e8 01             	sub    $0x1,%eax
80105b59:	89 c2                	mov    %eax,%edx
80105b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b62:	83 ec 0c             	sub    $0xc,%esp
80105b65:	ff 75 f4             	push   -0xc(%ebp)
80105b68:	e8 8e bd ff ff       	call   801018fb <iupdate>
80105b6d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b70:	83 ec 0c             	sub    $0xc,%esp
80105b73:	ff 75 f4             	push   -0xc(%ebp)
80105b76:	e8 8e c1 ff ff       	call   80101d09 <iunlockput>
80105b7b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b7e:	e8 f9 da ff ff       	call   8010367c <end_op>
  return -1;
80105b83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b88:	c9                   	leave  
80105b89:	c3                   	ret    

80105b8a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b8a:	55                   	push   %ebp
80105b8b:	89 e5                	mov    %esp,%ebp
80105b8d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b90:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b97:	eb 40                	jmp    80105bd9 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9c:	6a 10                	push   $0x10
80105b9e:	50                   	push   %eax
80105b9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ba2:	50                   	push   %eax
80105ba3:	ff 75 08             	push   0x8(%ebp)
80105ba6:	e8 19 c4 ff ff       	call   80101fc4 <readi>
80105bab:	83 c4 10             	add    $0x10,%esp
80105bae:	83 f8 10             	cmp    $0x10,%eax
80105bb1:	74 0d                	je     80105bc0 <isdirempty+0x36>
      panic("isdirempty: readi");
80105bb3:	83 ec 0c             	sub    $0xc,%esp
80105bb6:	68 4e 89 10 80       	push   $0x8010894e
80105bbb:	e8 f5 a9 ff ff       	call   801005b5 <panic>
    if(de.inum != 0)
80105bc0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bc4:	66 85 c0             	test   %ax,%ax
80105bc7:	74 07                	je     80105bd0 <isdirempty+0x46>
      return 0;
80105bc9:	b8 00 00 00 00       	mov    $0x0,%eax
80105bce:	eb 1b                	jmp    80105beb <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd3:	83 c0 10             	add    $0x10,%eax
80105bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bdc:	8b 50 58             	mov    0x58(%eax),%edx
80105bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be2:	39 c2                	cmp    %eax,%edx
80105be4:	77 b3                	ja     80105b99 <isdirempty+0xf>
  }
  return 1;
80105be6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105beb:	c9                   	leave  
80105bec:	c3                   	ret    

80105bed <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bed:	55                   	push   %ebp
80105bee:	89 e5                	mov    %esp,%ebp
80105bf0:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bf3:	83 ec 08             	sub    $0x8,%esp
80105bf6:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bf9:	50                   	push   %eax
80105bfa:	6a 00                	push   $0x0
80105bfc:	e8 a2 fa ff ff       	call   801056a3 <argstr>
80105c01:	83 c4 10             	add    $0x10,%esp
80105c04:	85 c0                	test   %eax,%eax
80105c06:	79 0a                	jns    80105c12 <sys_unlink+0x25>
    return -1;
80105c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0d:	e9 bf 01 00 00       	jmp    80105dd1 <sys_unlink+0x1e4>

  begin_op();
80105c12:	e8 d9 d9 ff ff       	call   801035f0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c17:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c1a:	83 ec 08             	sub    $0x8,%esp
80105c1d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c20:	52                   	push   %edx
80105c21:	50                   	push   %eax
80105c22:	e8 00 ca ff ff       	call   80102627 <nameiparent>
80105c27:	83 c4 10             	add    $0x10,%esp
80105c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c31:	75 0f                	jne    80105c42 <sys_unlink+0x55>
    end_op();
80105c33:	e8 44 da ff ff       	call   8010367c <end_op>
    return -1;
80105c38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3d:	e9 8f 01 00 00       	jmp    80105dd1 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c42:	83 ec 0c             	sub    $0xc,%esp
80105c45:	ff 75 f4             	push   -0xc(%ebp)
80105c48:	e8 8b be ff ff       	call   80101ad8 <ilock>
80105c4d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c50:	83 ec 08             	sub    $0x8,%esp
80105c53:	68 60 89 10 80       	push   $0x80108960
80105c58:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c5b:	50                   	push   %eax
80105c5c:	e8 3e c6 ff ff       	call   8010229f <namecmp>
80105c61:	83 c4 10             	add    $0x10,%esp
80105c64:	85 c0                	test   %eax,%eax
80105c66:	0f 84 49 01 00 00    	je     80105db5 <sys_unlink+0x1c8>
80105c6c:	83 ec 08             	sub    $0x8,%esp
80105c6f:	68 62 89 10 80       	push   $0x80108962
80105c74:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c77:	50                   	push   %eax
80105c78:	e8 22 c6 ff ff       	call   8010229f <namecmp>
80105c7d:	83 c4 10             	add    $0x10,%esp
80105c80:	85 c0                	test   %eax,%eax
80105c82:	0f 84 2d 01 00 00    	je     80105db5 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c88:	83 ec 04             	sub    $0x4,%esp
80105c8b:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c8e:	50                   	push   %eax
80105c8f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c92:	50                   	push   %eax
80105c93:	ff 75 f4             	push   -0xc(%ebp)
80105c96:	e8 1f c6 ff ff       	call   801022ba <dirlookup>
80105c9b:	83 c4 10             	add    $0x10,%esp
80105c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ca1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ca5:	0f 84 0d 01 00 00    	je     80105db8 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105cab:	83 ec 0c             	sub    $0xc,%esp
80105cae:	ff 75 f0             	push   -0x10(%ebp)
80105cb1:	e8 22 be ff ff       	call   80101ad8 <ilock>
80105cb6:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cc0:	66 85 c0             	test   %ax,%ax
80105cc3:	7f 0d                	jg     80105cd2 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105cc5:	83 ec 0c             	sub    $0xc,%esp
80105cc8:	68 65 89 10 80       	push   $0x80108965
80105ccd:	e8 e3 a8 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cd9:	66 83 f8 01          	cmp    $0x1,%ax
80105cdd:	75 25                	jne    80105d04 <sys_unlink+0x117>
80105cdf:	83 ec 0c             	sub    $0xc,%esp
80105ce2:	ff 75 f0             	push   -0x10(%ebp)
80105ce5:	e8 a0 fe ff ff       	call   80105b8a <isdirempty>
80105cea:	83 c4 10             	add    $0x10,%esp
80105ced:	85 c0                	test   %eax,%eax
80105cef:	75 13                	jne    80105d04 <sys_unlink+0x117>
    iunlockput(ip);
80105cf1:	83 ec 0c             	sub    $0xc,%esp
80105cf4:	ff 75 f0             	push   -0x10(%ebp)
80105cf7:	e8 0d c0 ff ff       	call   80101d09 <iunlockput>
80105cfc:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cff:	e9 b5 00 00 00       	jmp    80105db9 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105d04:	83 ec 04             	sub    $0x4,%esp
80105d07:	6a 10                	push   $0x10
80105d09:	6a 00                	push   $0x0
80105d0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d0e:	50                   	push   %eax
80105d0f:	e8 cf f5 ff ff       	call   801052e3 <memset>
80105d14:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d17:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d1a:	6a 10                	push   $0x10
80105d1c:	50                   	push   %eax
80105d1d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d20:	50                   	push   %eax
80105d21:	ff 75 f4             	push   -0xc(%ebp)
80105d24:	e8 f0 c3 ff ff       	call   80102119 <writei>
80105d29:	83 c4 10             	add    $0x10,%esp
80105d2c:	83 f8 10             	cmp    $0x10,%eax
80105d2f:	74 0d                	je     80105d3e <sys_unlink+0x151>
    panic("unlink: writei");
80105d31:	83 ec 0c             	sub    $0xc,%esp
80105d34:	68 77 89 10 80       	push   $0x80108977
80105d39:	e8 77 a8 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR){
80105d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d41:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d45:	66 83 f8 01          	cmp    $0x1,%ax
80105d49:	75 21                	jne    80105d6c <sys_unlink+0x17f>
    dp->nlink--;
80105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d52:	83 e8 01             	sub    $0x1,%eax
80105d55:	89 c2                	mov    %eax,%edx
80105d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105d5e:	83 ec 0c             	sub    $0xc,%esp
80105d61:	ff 75 f4             	push   -0xc(%ebp)
80105d64:	e8 92 bb ff ff       	call   801018fb <iupdate>
80105d69:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d6c:	83 ec 0c             	sub    $0xc,%esp
80105d6f:	ff 75 f4             	push   -0xc(%ebp)
80105d72:	e8 92 bf ff ff       	call   80101d09 <iunlockput>
80105d77:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d81:	83 e8 01             	sub    $0x1,%eax
80105d84:	89 c2                	mov    %eax,%edx
80105d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d89:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d8d:	83 ec 0c             	sub    $0xc,%esp
80105d90:	ff 75 f0             	push   -0x10(%ebp)
80105d93:	e8 63 bb ff ff       	call   801018fb <iupdate>
80105d98:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d9b:	83 ec 0c             	sub    $0xc,%esp
80105d9e:	ff 75 f0             	push   -0x10(%ebp)
80105da1:	e8 63 bf ff ff       	call   80101d09 <iunlockput>
80105da6:	83 c4 10             	add    $0x10,%esp

  end_op();
80105da9:	e8 ce d8 ff ff       	call   8010367c <end_op>

  return 0;
80105dae:	b8 00 00 00 00       	mov    $0x0,%eax
80105db3:	eb 1c                	jmp    80105dd1 <sys_unlink+0x1e4>
    goto bad;
80105db5:	90                   	nop
80105db6:	eb 01                	jmp    80105db9 <sys_unlink+0x1cc>
    goto bad;
80105db8:	90                   	nop

bad:
  iunlockput(dp);
80105db9:	83 ec 0c             	sub    $0xc,%esp
80105dbc:	ff 75 f4             	push   -0xc(%ebp)
80105dbf:	e8 45 bf ff ff       	call   80101d09 <iunlockput>
80105dc4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dc7:	e8 b0 d8 ff ff       	call   8010367c <end_op>
  return -1;
80105dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dd1:	c9                   	leave  
80105dd2:	c3                   	ret    

80105dd3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dd3:	55                   	push   %ebp
80105dd4:	89 e5                	mov    %esp,%ebp
80105dd6:	83 ec 38             	sub    $0x38,%esp
80105dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ddc:	8b 55 10             	mov    0x10(%ebp),%edx
80105ddf:	8b 45 14             	mov    0x14(%ebp),%eax
80105de2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105de6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dea:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dee:	83 ec 08             	sub    $0x8,%esp
80105df1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105df4:	50                   	push   %eax
80105df5:	ff 75 08             	push   0x8(%ebp)
80105df8:	e8 2a c8 ff ff       	call   80102627 <nameiparent>
80105dfd:	83 c4 10             	add    $0x10,%esp
80105e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e07:	75 0a                	jne    80105e13 <create+0x40>
    return 0;
80105e09:	b8 00 00 00 00       	mov    $0x0,%eax
80105e0e:	e9 8e 01 00 00       	jmp    80105fa1 <create+0x1ce>
  ilock(dp);
80105e13:	83 ec 0c             	sub    $0xc,%esp
80105e16:	ff 75 f4             	push   -0xc(%ebp)
80105e19:	e8 ba bc ff ff       	call   80101ad8 <ilock>
80105e1e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80105e21:	83 ec 04             	sub    $0x4,%esp
80105e24:	6a 00                	push   $0x0
80105e26:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e29:	50                   	push   %eax
80105e2a:	ff 75 f4             	push   -0xc(%ebp)
80105e2d:	e8 88 c4 ff ff       	call   801022ba <dirlookup>
80105e32:	83 c4 10             	add    $0x10,%esp
80105e35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e3c:	74 50                	je     80105e8e <create+0xbb>
    iunlockput(dp);
80105e3e:	83 ec 0c             	sub    $0xc,%esp
80105e41:	ff 75 f4             	push   -0xc(%ebp)
80105e44:	e8 c0 be ff ff       	call   80101d09 <iunlockput>
80105e49:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e4c:	83 ec 0c             	sub    $0xc,%esp
80105e4f:	ff 75 f0             	push   -0x10(%ebp)
80105e52:	e8 81 bc ff ff       	call   80101ad8 <ilock>
80105e57:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e5a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e5f:	75 15                	jne    80105e76 <create+0xa3>
80105e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e64:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e68:	66 83 f8 02          	cmp    $0x2,%ax
80105e6c:	75 08                	jne    80105e76 <create+0xa3>
      return ip;
80105e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e71:	e9 2b 01 00 00       	jmp    80105fa1 <create+0x1ce>
    iunlockput(ip);
80105e76:	83 ec 0c             	sub    $0xc,%esp
80105e79:	ff 75 f0             	push   -0x10(%ebp)
80105e7c:	e8 88 be ff ff       	call   80101d09 <iunlockput>
80105e81:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e84:	b8 00 00 00 00       	mov    $0x0,%eax
80105e89:	e9 13 01 00 00       	jmp    80105fa1 <create+0x1ce>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e8e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e95:	8b 00                	mov    (%eax),%eax
80105e97:	83 ec 08             	sub    $0x8,%esp
80105e9a:	52                   	push   %edx
80105e9b:	50                   	push   %eax
80105e9c:	e8 83 b9 ff ff       	call   80101824 <ialloc>
80105ea1:	83 c4 10             	add    $0x10,%esp
80105ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ea7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eab:	75 0d                	jne    80105eba <create+0xe7>
    panic("create: ialloc");
80105ead:	83 ec 0c             	sub    $0xc,%esp
80105eb0:	68 86 89 10 80       	push   $0x80108986
80105eb5:	e8 fb a6 ff ff       	call   801005b5 <panic>

  ilock(ip);
80105eba:	83 ec 0c             	sub    $0xc,%esp
80105ebd:	ff 75 f0             	push   -0x10(%ebp)
80105ec0:	e8 13 bc ff ff       	call   80101ad8 <ilock>
80105ec5:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecb:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ecf:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105eda:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee1:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105ee7:	83 ec 0c             	sub    $0xc,%esp
80105eea:	ff 75 f0             	push   -0x10(%ebp)
80105eed:	e8 09 ba ff ff       	call   801018fb <iupdate>
80105ef2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ef5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105efa:	75 6a                	jne    80105f66 <create+0x193>
    dp->nlink++;  // for ".."
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f03:	83 c0 01             	add    $0x1,%eax
80105f06:	89 c2                	mov    %eax,%edx
80105f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f0f:	83 ec 0c             	sub    $0xc,%esp
80105f12:	ff 75 f4             	push   -0xc(%ebp)
80105f15:	e8 e1 b9 ff ff       	call   801018fb <iupdate>
80105f1a:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	8b 40 04             	mov    0x4(%eax),%eax
80105f23:	83 ec 04             	sub    $0x4,%esp
80105f26:	50                   	push   %eax
80105f27:	68 60 89 10 80       	push   $0x80108960
80105f2c:	ff 75 f0             	push   -0x10(%ebp)
80105f2f:	e8 40 c4 ff ff       	call   80102374 <dirlink>
80105f34:	83 c4 10             	add    $0x10,%esp
80105f37:	85 c0                	test   %eax,%eax
80105f39:	78 1e                	js     80105f59 <create+0x186>
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	8b 40 04             	mov    0x4(%eax),%eax
80105f41:	83 ec 04             	sub    $0x4,%esp
80105f44:	50                   	push   %eax
80105f45:	68 62 89 10 80       	push   $0x80108962
80105f4a:	ff 75 f0             	push   -0x10(%ebp)
80105f4d:	e8 22 c4 ff ff       	call   80102374 <dirlink>
80105f52:	83 c4 10             	add    $0x10,%esp
80105f55:	85 c0                	test   %eax,%eax
80105f57:	79 0d                	jns    80105f66 <create+0x193>
      panic("create dots");
80105f59:	83 ec 0c             	sub    $0xc,%esp
80105f5c:	68 95 89 10 80       	push   $0x80108995
80105f61:	e8 4f a6 ff ff       	call   801005b5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f69:	8b 40 04             	mov    0x4(%eax),%eax
80105f6c:	83 ec 04             	sub    $0x4,%esp
80105f6f:	50                   	push   %eax
80105f70:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105f73:	50                   	push   %eax
80105f74:	ff 75 f4             	push   -0xc(%ebp)
80105f77:	e8 f8 c3 ff ff       	call   80102374 <dirlink>
80105f7c:	83 c4 10             	add    $0x10,%esp
80105f7f:	85 c0                	test   %eax,%eax
80105f81:	79 0d                	jns    80105f90 <create+0x1bd>
    panic("create: dirlink");
80105f83:	83 ec 0c             	sub    $0xc,%esp
80105f86:	68 a1 89 10 80       	push   $0x801089a1
80105f8b:	e8 25 a6 ff ff       	call   801005b5 <panic>

  iunlockput(dp);
80105f90:	83 ec 0c             	sub    $0xc,%esp
80105f93:	ff 75 f4             	push   -0xc(%ebp)
80105f96:	e8 6e bd ff ff       	call   80101d09 <iunlockput>
80105f9b:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105fa1:	c9                   	leave  
80105fa2:	c3                   	ret    

80105fa3 <sys_open>:

int
sys_open(void)
{
80105fa3:	55                   	push   %ebp
80105fa4:	89 e5                	mov    %esp,%ebp
80105fa6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105fa9:	83 ec 08             	sub    $0x8,%esp
80105fac:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105faf:	50                   	push   %eax
80105fb0:	6a 00                	push   $0x0
80105fb2:	e8 ec f6 ff ff       	call   801056a3 <argstr>
80105fb7:	83 c4 10             	add    $0x10,%esp
80105fba:	85 c0                	test   %eax,%eax
80105fbc:	78 15                	js     80105fd3 <sys_open+0x30>
80105fbe:	83 ec 08             	sub    $0x8,%esp
80105fc1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fc4:	50                   	push   %eax
80105fc5:	6a 01                	push   $0x1
80105fc7:	e8 42 f6 ff ff       	call   8010560e <argint>
80105fcc:	83 c4 10             	add    $0x10,%esp
80105fcf:	85 c0                	test   %eax,%eax
80105fd1:	79 0a                	jns    80105fdd <sys_open+0x3a>
    return -1;
80105fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd8:	e9 61 01 00 00       	jmp    8010613e <sys_open+0x19b>

  begin_op();
80105fdd:	e8 0e d6 ff ff       	call   801035f0 <begin_op>

  if(omode & O_CREATE){
80105fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe5:	25 00 02 00 00       	and    $0x200,%eax
80105fea:	85 c0                	test   %eax,%eax
80105fec:	74 2a                	je     80106018 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ff1:	6a 00                	push   $0x0
80105ff3:	6a 00                	push   $0x0
80105ff5:	6a 02                	push   $0x2
80105ff7:	50                   	push   %eax
80105ff8:	e8 d6 fd ff ff       	call   80105dd3 <create>
80105ffd:	83 c4 10             	add    $0x10,%esp
80106000:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106003:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106007:	75 75                	jne    8010607e <sys_open+0xdb>
      end_op();
80106009:	e8 6e d6 ff ff       	call   8010367c <end_op>
      return -1;
8010600e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106013:	e9 26 01 00 00       	jmp    8010613e <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106018:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010601b:	83 ec 0c             	sub    $0xc,%esp
8010601e:	50                   	push   %eax
8010601f:	e8 e7 c5 ff ff       	call   8010260b <namei>
80106024:	83 c4 10             	add    $0x10,%esp
80106027:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010602a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010602e:	75 0f                	jne    8010603f <sys_open+0x9c>
      end_op();
80106030:	e8 47 d6 ff ff       	call   8010367c <end_op>
      return -1;
80106035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603a:	e9 ff 00 00 00       	jmp    8010613e <sys_open+0x19b>
    }
    ilock(ip);
8010603f:	83 ec 0c             	sub    $0xc,%esp
80106042:	ff 75 f4             	push   -0xc(%ebp)
80106045:	e8 8e ba ff ff       	call   80101ad8 <ilock>
8010604a:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106054:	66 83 f8 01          	cmp    $0x1,%ax
80106058:	75 24                	jne    8010607e <sys_open+0xdb>
8010605a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010605d:	85 c0                	test   %eax,%eax
8010605f:	74 1d                	je     8010607e <sys_open+0xdb>
      iunlockput(ip);
80106061:	83 ec 0c             	sub    $0xc,%esp
80106064:	ff 75 f4             	push   -0xc(%ebp)
80106067:	e8 9d bc ff ff       	call   80101d09 <iunlockput>
8010606c:	83 c4 10             	add    $0x10,%esp
      end_op();
8010606f:	e8 08 d6 ff ff       	call   8010367c <end_op>
      return -1;
80106074:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106079:	e9 c0 00 00 00       	jmp    8010613e <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010607e:	e8 5b b0 ff ff       	call   801010de <filealloc>
80106083:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106086:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010608a:	74 17                	je     801060a3 <sys_open+0x100>
8010608c:	83 ec 0c             	sub    $0xc,%esp
8010608f:	ff 75 f0             	push   -0x10(%ebp)
80106092:	e8 35 f7 ff ff       	call   801057cc <fdalloc>
80106097:	83 c4 10             	add    $0x10,%esp
8010609a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010609d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801060a1:	79 2e                	jns    801060d1 <sys_open+0x12e>
    if(f)
801060a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060a7:	74 0e                	je     801060b7 <sys_open+0x114>
      fileclose(f);
801060a9:	83 ec 0c             	sub    $0xc,%esp
801060ac:	ff 75 f0             	push   -0x10(%ebp)
801060af:	e8 e8 b0 ff ff       	call   8010119c <fileclose>
801060b4:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060b7:	83 ec 0c             	sub    $0xc,%esp
801060ba:	ff 75 f4             	push   -0xc(%ebp)
801060bd:	e8 47 bc ff ff       	call   80101d09 <iunlockput>
801060c2:	83 c4 10             	add    $0x10,%esp
    end_op();
801060c5:	e8 b2 d5 ff ff       	call   8010367c <end_op>
    return -1;
801060ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060cf:	eb 6d                	jmp    8010613e <sys_open+0x19b>
  }
  iunlock(ip);
801060d1:	83 ec 0c             	sub    $0xc,%esp
801060d4:	ff 75 f4             	push   -0xc(%ebp)
801060d7:	e8 0f bb ff ff       	call   80101beb <iunlock>
801060dc:	83 c4 10             	add    $0x10,%esp
  end_op();
801060df:	e8 98 d5 ff ff       	call   8010367c <end_op>

  f->type = FD_INODE;
801060e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e7:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060f3:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106103:	83 e0 01             	and    $0x1,%eax
80106106:	85 c0                	test   %eax,%eax
80106108:	0f 94 c0             	sete   %al
8010610b:	89 c2                	mov    %eax,%edx
8010610d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106110:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106116:	83 e0 01             	and    $0x1,%eax
80106119:	85 c0                	test   %eax,%eax
8010611b:	75 0a                	jne    80106127 <sys_open+0x184>
8010611d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106120:	83 e0 02             	and    $0x2,%eax
80106123:	85 c0                	test   %eax,%eax
80106125:	74 07                	je     8010612e <sys_open+0x18b>
80106127:	b8 01 00 00 00       	mov    $0x1,%eax
8010612c:	eb 05                	jmp    80106133 <sys_open+0x190>
8010612e:	b8 00 00 00 00       	mov    $0x0,%eax
80106133:	89 c2                	mov    %eax,%edx
80106135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106138:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010613b:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010613e:	c9                   	leave  
8010613f:	c3                   	ret    

80106140 <sys_mkdir>:

int
sys_mkdir(void)
{
80106140:	55                   	push   %ebp
80106141:	89 e5                	mov    %esp,%ebp
80106143:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106146:	e8 a5 d4 ff ff       	call   801035f0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010614b:	83 ec 08             	sub    $0x8,%esp
8010614e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106151:	50                   	push   %eax
80106152:	6a 00                	push   $0x0
80106154:	e8 4a f5 ff ff       	call   801056a3 <argstr>
80106159:	83 c4 10             	add    $0x10,%esp
8010615c:	85 c0                	test   %eax,%eax
8010615e:	78 1b                	js     8010617b <sys_mkdir+0x3b>
80106160:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106163:	6a 00                	push   $0x0
80106165:	6a 00                	push   $0x0
80106167:	6a 01                	push   $0x1
80106169:	50                   	push   %eax
8010616a:	e8 64 fc ff ff       	call   80105dd3 <create>
8010616f:	83 c4 10             	add    $0x10,%esp
80106172:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106175:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106179:	75 0c                	jne    80106187 <sys_mkdir+0x47>
    end_op();
8010617b:	e8 fc d4 ff ff       	call   8010367c <end_op>
    return -1;
80106180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106185:	eb 18                	jmp    8010619f <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106187:	83 ec 0c             	sub    $0xc,%esp
8010618a:	ff 75 f4             	push   -0xc(%ebp)
8010618d:	e8 77 bb ff ff       	call   80101d09 <iunlockput>
80106192:	83 c4 10             	add    $0x10,%esp
  end_op();
80106195:	e8 e2 d4 ff ff       	call   8010367c <end_op>
  return 0;
8010619a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619f:	c9                   	leave  
801061a0:	c3                   	ret    

801061a1 <sys_mknod>:

int
sys_mknod(void)
{
801061a1:	55                   	push   %ebp
801061a2:	89 e5                	mov    %esp,%ebp
801061a4:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801061a7:	e8 44 d4 ff ff       	call   801035f0 <begin_op>
  if((argstr(0, &path)) < 0 ||
801061ac:	83 ec 08             	sub    $0x8,%esp
801061af:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061b2:	50                   	push   %eax
801061b3:	6a 00                	push   $0x0
801061b5:	e8 e9 f4 ff ff       	call   801056a3 <argstr>
801061ba:	83 c4 10             	add    $0x10,%esp
801061bd:	85 c0                	test   %eax,%eax
801061bf:	78 4f                	js     80106210 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801061c1:	83 ec 08             	sub    $0x8,%esp
801061c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061c7:	50                   	push   %eax
801061c8:	6a 01                	push   $0x1
801061ca:	e8 3f f4 ff ff       	call   8010560e <argint>
801061cf:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801061d2:	85 c0                	test   %eax,%eax
801061d4:	78 3a                	js     80106210 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801061d6:	83 ec 08             	sub    $0x8,%esp
801061d9:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061dc:	50                   	push   %eax
801061dd:	6a 02                	push   $0x2
801061df:	e8 2a f4 ff ff       	call   8010560e <argint>
801061e4:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061e7:	85 c0                	test   %eax,%eax
801061e9:	78 25                	js     80106210 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ee:	0f bf c8             	movswl %ax,%ecx
801061f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061f4:	0f bf d0             	movswl %ax,%edx
801061f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fa:	51                   	push   %ecx
801061fb:	52                   	push   %edx
801061fc:	6a 03                	push   $0x3
801061fe:	50                   	push   %eax
801061ff:	e8 cf fb ff ff       	call   80105dd3 <create>
80106204:	83 c4 10             	add    $0x10,%esp
80106207:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010620a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010620e:	75 0c                	jne    8010621c <sys_mknod+0x7b>
    end_op();
80106210:	e8 67 d4 ff ff       	call   8010367c <end_op>
    return -1;
80106215:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621a:	eb 18                	jmp    80106234 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010621c:	83 ec 0c             	sub    $0xc,%esp
8010621f:	ff 75 f4             	push   -0xc(%ebp)
80106222:	e8 e2 ba ff ff       	call   80101d09 <iunlockput>
80106227:	83 c4 10             	add    $0x10,%esp
  end_op();
8010622a:	e8 4d d4 ff ff       	call   8010367c <end_op>
  return 0;
8010622f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106234:	c9                   	leave  
80106235:	c3                   	ret    

80106236 <sys_chdir>:

int
sys_chdir(void)
{
80106236:	55                   	push   %ebp
80106237:	89 e5                	mov    %esp,%ebp
80106239:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010623c:	e8 16 e1 ff ff       	call   80104357 <myproc>
80106241:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106244:	e8 a7 d3 ff ff       	call   801035f0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106249:	83 ec 08             	sub    $0x8,%esp
8010624c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010624f:	50                   	push   %eax
80106250:	6a 00                	push   $0x0
80106252:	e8 4c f4 ff ff       	call   801056a3 <argstr>
80106257:	83 c4 10             	add    $0x10,%esp
8010625a:	85 c0                	test   %eax,%eax
8010625c:	78 18                	js     80106276 <sys_chdir+0x40>
8010625e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106261:	83 ec 0c             	sub    $0xc,%esp
80106264:	50                   	push   %eax
80106265:	e8 a1 c3 ff ff       	call   8010260b <namei>
8010626a:	83 c4 10             	add    $0x10,%esp
8010626d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106270:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106274:	75 0c                	jne    80106282 <sys_chdir+0x4c>
    end_op();
80106276:	e8 01 d4 ff ff       	call   8010367c <end_op>
    return -1;
8010627b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106280:	eb 68                	jmp    801062ea <sys_chdir+0xb4>
  }
  ilock(ip);
80106282:	83 ec 0c             	sub    $0xc,%esp
80106285:	ff 75 f0             	push   -0x10(%ebp)
80106288:	e8 4b b8 ff ff       	call   80101ad8 <ilock>
8010628d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106293:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106297:	66 83 f8 01          	cmp    $0x1,%ax
8010629b:	74 1a                	je     801062b7 <sys_chdir+0x81>
    iunlockput(ip);
8010629d:	83 ec 0c             	sub    $0xc,%esp
801062a0:	ff 75 f0             	push   -0x10(%ebp)
801062a3:	e8 61 ba ff ff       	call   80101d09 <iunlockput>
801062a8:	83 c4 10             	add    $0x10,%esp
    end_op();
801062ab:	e8 cc d3 ff ff       	call   8010367c <end_op>
    return -1;
801062b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b5:	eb 33                	jmp    801062ea <sys_chdir+0xb4>
  }
  iunlock(ip);
801062b7:	83 ec 0c             	sub    $0xc,%esp
801062ba:	ff 75 f0             	push   -0x10(%ebp)
801062bd:	e8 29 b9 ff ff       	call   80101beb <iunlock>
801062c2:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801062c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c8:	8b 40 68             	mov    0x68(%eax),%eax
801062cb:	83 ec 0c             	sub    $0xc,%esp
801062ce:	50                   	push   %eax
801062cf:	e8 65 b9 ff ff       	call   80101c39 <iput>
801062d4:	83 c4 10             	add    $0x10,%esp
  end_op();
801062d7:	e8 a0 d3 ff ff       	call   8010367c <end_op>
  curproc->cwd = ip;
801062dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062e2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ea:	c9                   	leave  
801062eb:	c3                   	ret    

801062ec <sys_exec>:

int
sys_exec(void)
{
801062ec:	55                   	push   %ebp
801062ed:	89 e5                	mov    %esp,%ebp
801062ef:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062f5:	83 ec 08             	sub    $0x8,%esp
801062f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062fb:	50                   	push   %eax
801062fc:	6a 00                	push   $0x0
801062fe:	e8 a0 f3 ff ff       	call   801056a3 <argstr>
80106303:	83 c4 10             	add    $0x10,%esp
80106306:	85 c0                	test   %eax,%eax
80106308:	78 18                	js     80106322 <sys_exec+0x36>
8010630a:	83 ec 08             	sub    $0x8,%esp
8010630d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106313:	50                   	push   %eax
80106314:	6a 01                	push   $0x1
80106316:	e8 f3 f2 ff ff       	call   8010560e <argint>
8010631b:	83 c4 10             	add    $0x10,%esp
8010631e:	85 c0                	test   %eax,%eax
80106320:	79 0a                	jns    8010632c <sys_exec+0x40>
    return -1;
80106322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106327:	e9 c6 00 00 00       	jmp    801063f2 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010632c:	83 ec 04             	sub    $0x4,%esp
8010632f:	68 80 00 00 00       	push   $0x80
80106334:	6a 00                	push   $0x0
80106336:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010633c:	50                   	push   %eax
8010633d:	e8 a1 ef ff ff       	call   801052e3 <memset>
80106342:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010634c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634f:	83 f8 1f             	cmp    $0x1f,%eax
80106352:	76 0a                	jbe    8010635e <sys_exec+0x72>
      return -1;
80106354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106359:	e9 94 00 00 00       	jmp    801063f2 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010635e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106361:	c1 e0 02             	shl    $0x2,%eax
80106364:	89 c2                	mov    %eax,%edx
80106366:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010636c:	01 c2                	add    %eax,%edx
8010636e:	83 ec 08             	sub    $0x8,%esp
80106371:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106377:	50                   	push   %eax
80106378:	52                   	push   %edx
80106379:	e8 ef f1 ff ff       	call   8010556d <fetchint>
8010637e:	83 c4 10             	add    $0x10,%esp
80106381:	85 c0                	test   %eax,%eax
80106383:	79 07                	jns    8010638c <sys_exec+0xa0>
      return -1;
80106385:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638a:	eb 66                	jmp    801063f2 <sys_exec+0x106>
    if(uarg == 0){
8010638c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106392:	85 c0                	test   %eax,%eax
80106394:	75 27                	jne    801063bd <sys_exec+0xd1>
      argv[i] = 0;
80106396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106399:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801063a0:	00 00 00 00 
      break;
801063a4:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801063a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a8:	83 ec 08             	sub    $0x8,%esp
801063ab:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063b1:	52                   	push   %edx
801063b2:	50                   	push   %eax
801063b3:	e8 0b a8 ff ff       	call   80100bc3 <exec>
801063b8:	83 c4 10             	add    $0x10,%esp
801063bb:	eb 35                	jmp    801063f2 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801063bd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c6:	c1 e0 02             	shl    $0x2,%eax
801063c9:	01 c2                	add    %eax,%edx
801063cb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063d1:	83 ec 08             	sub    $0x8,%esp
801063d4:	52                   	push   %edx
801063d5:	50                   	push   %eax
801063d6:	e8 d1 f1 ff ff       	call   801055ac <fetchstr>
801063db:	83 c4 10             	add    $0x10,%esp
801063de:	85 c0                	test   %eax,%eax
801063e0:	79 07                	jns    801063e9 <sys_exec+0xfd>
      return -1;
801063e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e7:	eb 09                	jmp    801063f2 <sys_exec+0x106>
  for(i=0;; i++){
801063e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063ed:	e9 5a ff ff ff       	jmp    8010634c <sys_exec+0x60>
}
801063f2:	c9                   	leave  
801063f3:	c3                   	ret    

801063f4 <sys_pipe>:

int
sys_pipe(void)
{
801063f4:	55                   	push   %ebp
801063f5:	89 e5                	mov    %esp,%ebp
801063f7:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063fa:	83 ec 04             	sub    $0x4,%esp
801063fd:	6a 08                	push   $0x8
801063ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106402:	50                   	push   %eax
80106403:	6a 00                	push   $0x0
80106405:	e8 31 f2 ff ff       	call   8010563b <argptr>
8010640a:	83 c4 10             	add    $0x10,%esp
8010640d:	85 c0                	test   %eax,%eax
8010640f:	79 0a                	jns    8010641b <sys_pipe+0x27>
    return -1;
80106411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106416:	e9 ae 00 00 00       	jmp    801064c9 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
8010641b:	83 ec 08             	sub    $0x8,%esp
8010641e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106421:	50                   	push   %eax
80106422:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106425:	50                   	push   %eax
80106426:	e8 69 da ff ff       	call   80103e94 <pipealloc>
8010642b:	83 c4 10             	add    $0x10,%esp
8010642e:	85 c0                	test   %eax,%eax
80106430:	79 0a                	jns    8010643c <sys_pipe+0x48>
    return -1;
80106432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106437:	e9 8d 00 00 00       	jmp    801064c9 <sys_pipe+0xd5>
  fd0 = -1;
8010643c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106443:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106446:	83 ec 0c             	sub    $0xc,%esp
80106449:	50                   	push   %eax
8010644a:	e8 7d f3 ff ff       	call   801057cc <fdalloc>
8010644f:	83 c4 10             	add    $0x10,%esp
80106452:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106455:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106459:	78 18                	js     80106473 <sys_pipe+0x7f>
8010645b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010645e:	83 ec 0c             	sub    $0xc,%esp
80106461:	50                   	push   %eax
80106462:	e8 65 f3 ff ff       	call   801057cc <fdalloc>
80106467:	83 c4 10             	add    $0x10,%esp
8010646a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010646d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106471:	79 3e                	jns    801064b1 <sys_pipe+0xbd>
    if(fd0 >= 0)
80106473:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106477:	78 13                	js     8010648c <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106479:	e8 d9 de ff ff       	call   80104357 <myproc>
8010647e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106481:	83 c2 08             	add    $0x8,%edx
80106484:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010648b:	00 
    fileclose(rf);
8010648c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010648f:	83 ec 0c             	sub    $0xc,%esp
80106492:	50                   	push   %eax
80106493:	e8 04 ad ff ff       	call   8010119c <fileclose>
80106498:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010649b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010649e:	83 ec 0c             	sub    $0xc,%esp
801064a1:	50                   	push   %eax
801064a2:	e8 f5 ac ff ff       	call   8010119c <fileclose>
801064a7:	83 c4 10             	add    $0x10,%esp
    return -1;
801064aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064af:	eb 18                	jmp    801064c9 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
801064b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064b7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064bc:	8d 50 04             	lea    0x4(%eax),%edx
801064bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c2:	89 02                	mov    %eax,(%edx)
  return 0;
801064c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c9:	c9                   	leave  
801064ca:	c3                   	ret    

801064cb <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801064cb:	55                   	push   %ebp
801064cc:	89 e5                	mov    %esp,%ebp
801064ce:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064d1:	e8 90 e1 ff ff       	call   80104666 <fork>
}
801064d6:	c9                   	leave  
801064d7:	c3                   	ret    

801064d8 <sys_exit>:

int
sys_exit(void)
{
801064d8:	55                   	push   %ebp
801064d9:	89 e5                	mov    %esp,%ebp
801064db:	83 ec 08             	sub    $0x8,%esp
  exit();
801064de:	e8 08 e3 ff ff       	call   801047eb <exit>
  return 0;  // not reached
801064e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e8:	c9                   	leave  
801064e9:	c3                   	ret    

801064ea <sys_wait>:

int
sys_wait(void)
{
801064ea:	55                   	push   %ebp
801064eb:	89 e5                	mov    %esp,%ebp
801064ed:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064f0:	e8 16 e4 ff ff       	call   8010490b <wait>
}
801064f5:	c9                   	leave  
801064f6:	c3                   	ret    

801064f7 <sys_kill>:

int
sys_kill(void)
{
801064f7:	55                   	push   %ebp
801064f8:	89 e5                	mov    %esp,%ebp
801064fa:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064fd:	83 ec 08             	sub    $0x8,%esp
80106500:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106503:	50                   	push   %eax
80106504:	6a 00                	push   $0x0
80106506:	e8 03 f1 ff ff       	call   8010560e <argint>
8010650b:	83 c4 10             	add    $0x10,%esp
8010650e:	85 c0                	test   %eax,%eax
80106510:	79 07                	jns    80106519 <sys_kill+0x22>
    return -1;
80106512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106517:	eb 0f                	jmp    80106528 <sys_kill+0x31>
  return kill(pid);
80106519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651c:	83 ec 0c             	sub    $0xc,%esp
8010651f:	50                   	push   %eax
80106520:	e8 15 e8 ff ff       	call   80104d3a <kill>
80106525:	83 c4 10             	add    $0x10,%esp
}
80106528:	c9                   	leave  
80106529:	c3                   	ret    

8010652a <sys_getpid>:

int
sys_getpid(void)
{
8010652a:	55                   	push   %ebp
8010652b:	89 e5                	mov    %esp,%ebp
8010652d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106530:	e8 22 de ff ff       	call   80104357 <myproc>
80106535:	8b 40 10             	mov    0x10(%eax),%eax
}
80106538:	c9                   	leave  
80106539:	c3                   	ret    

8010653a <sys_sbrk>:

int
sys_sbrk(void)
{
8010653a:	55                   	push   %ebp
8010653b:	89 e5                	mov    %esp,%ebp
8010653d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106540:	83 ec 08             	sub    $0x8,%esp
80106543:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106546:	50                   	push   %eax
80106547:	6a 00                	push   $0x0
80106549:	e8 c0 f0 ff ff       	call   8010560e <argint>
8010654e:	83 c4 10             	add    $0x10,%esp
80106551:	85 c0                	test   %eax,%eax
80106553:	79 07                	jns    8010655c <sys_sbrk+0x22>
    return -1;
80106555:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655a:	eb 27                	jmp    80106583 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010655c:	e8 f6 dd ff ff       	call   80104357 <myproc>
80106561:	8b 00                	mov    (%eax),%eax
80106563:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106569:	83 ec 0c             	sub    $0xc,%esp
8010656c:	50                   	push   %eax
8010656d:	e8 59 e0 ff ff       	call   801045cb <growproc>
80106572:	83 c4 10             	add    $0x10,%esp
80106575:	85 c0                	test   %eax,%eax
80106577:	79 07                	jns    80106580 <sys_sbrk+0x46>
    return -1;
80106579:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010657e:	eb 03                	jmp    80106583 <sys_sbrk+0x49>
  return addr;
80106580:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106583:	c9                   	leave  
80106584:	c3                   	ret    

80106585 <sys_sleep>:

int
sys_sleep(void)
{
80106585:	55                   	push   %ebp
80106586:	89 e5                	mov    %esp,%ebp
80106588:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010658b:	83 ec 08             	sub    $0x8,%esp
8010658e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106591:	50                   	push   %eax
80106592:	6a 00                	push   $0x0
80106594:	e8 75 f0 ff ff       	call   8010560e <argint>
80106599:	83 c4 10             	add    $0x10,%esp
8010659c:	85 c0                	test   %eax,%eax
8010659e:	79 07                	jns    801065a7 <sys_sleep+0x22>
    return -1;
801065a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a5:	eb 76                	jmp    8010661d <sys_sleep+0x98>
  acquire(&tickslock);
801065a7:	83 ec 0c             	sub    $0xc,%esp
801065aa:	68 a0 55 11 80       	push   $0x801155a0
801065af:	e8 a9 ea ff ff       	call   8010505d <acquire>
801065b4:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065b7:	a1 d4 55 11 80       	mov    0x801155d4,%eax
801065bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065bf:	eb 38                	jmp    801065f9 <sys_sleep+0x74>
    if(myproc()->killed){
801065c1:	e8 91 dd ff ff       	call   80104357 <myproc>
801065c6:	8b 40 24             	mov    0x24(%eax),%eax
801065c9:	85 c0                	test   %eax,%eax
801065cb:	74 17                	je     801065e4 <sys_sleep+0x5f>
      release(&tickslock);
801065cd:	83 ec 0c             	sub    $0xc,%esp
801065d0:	68 a0 55 11 80       	push   $0x801155a0
801065d5:	e8 f1 ea ff ff       	call   801050cb <release>
801065da:	83 c4 10             	add    $0x10,%esp
      return -1;
801065dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e2:	eb 39                	jmp    8010661d <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801065e4:	83 ec 08             	sub    $0x8,%esp
801065e7:	68 a0 55 11 80       	push   $0x801155a0
801065ec:	68 d4 55 11 80       	push   $0x801155d4
801065f1:	e8 26 e6 ff ff       	call   80104c1c <sleep>
801065f6:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801065f9:	a1 d4 55 11 80       	mov    0x801155d4,%eax
801065fe:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106601:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106604:	39 d0                	cmp    %edx,%eax
80106606:	72 b9                	jb     801065c1 <sys_sleep+0x3c>
  }
  release(&tickslock);
80106608:	83 ec 0c             	sub    $0xc,%esp
8010660b:	68 a0 55 11 80       	push   $0x801155a0
80106610:	e8 b6 ea ff ff       	call   801050cb <release>
80106615:	83 c4 10             	add    $0x10,%esp
  return 0;
80106618:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010661d:	c9                   	leave  
8010661e:	c3                   	ret    

8010661f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010661f:	55                   	push   %ebp
80106620:	89 e5                	mov    %esp,%ebp
80106622:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106625:	83 ec 0c             	sub    $0xc,%esp
80106628:	68 a0 55 11 80       	push   $0x801155a0
8010662d:	e8 2b ea ff ff       	call   8010505d <acquire>
80106632:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106635:	a1 d4 55 11 80       	mov    0x801155d4,%eax
8010663a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010663d:	83 ec 0c             	sub    $0xc,%esp
80106640:	68 a0 55 11 80       	push   $0x801155a0
80106645:	e8 81 ea ff ff       	call   801050cb <release>
8010664a:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010664d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106650:	c9                   	leave  
80106651:	c3                   	ret    

80106652 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106652:	1e                   	push   %ds
  pushl %es
80106653:	06                   	push   %es
  pushl %fs
80106654:	0f a0                	push   %fs
  pushl %gs
80106656:	0f a8                	push   %gs
  pushal
80106658:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106659:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010665d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010665f:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106661:	54                   	push   %esp
  call trap
80106662:	e8 d7 01 00 00       	call   8010683e <trap>
  addl $4, %esp
80106667:	83 c4 04             	add    $0x4,%esp

8010666a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010666a:	61                   	popa   
  popl %gs
8010666b:	0f a9                	pop    %gs
  popl %fs
8010666d:	0f a1                	pop    %fs
  popl %es
8010666f:	07                   	pop    %es
  popl %ds
80106670:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106671:	83 c4 08             	add    $0x8,%esp
  iret
80106674:	cf                   	iret   

80106675 <lidt>:
{
80106675:	55                   	push   %ebp
80106676:	89 e5                	mov    %esp,%ebp
80106678:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010667b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010667e:	83 e8 01             	sub    $0x1,%eax
80106681:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106685:	8b 45 08             	mov    0x8(%ebp),%eax
80106688:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010668c:	8b 45 08             	mov    0x8(%ebp),%eax
8010668f:	c1 e8 10             	shr    $0x10,%eax
80106692:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106696:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106699:	0f 01 18             	lidtl  (%eax)
}
8010669c:	90                   	nop
8010669d:	c9                   	leave  
8010669e:	c3                   	ret    

8010669f <rcr2>:

static inline uint
rcr2(void)
{
8010669f:	55                   	push   %ebp
801066a0:	89 e5                	mov    %esp,%ebp
801066a2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066a5:	0f 20 d0             	mov    %cr2,%eax
801066a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066ae:	c9                   	leave  
801066af:	c3                   	ret    

801066b0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066b0:	55                   	push   %ebp
801066b1:	89 e5                	mov    %esp,%ebp
801066b3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801066b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066bd:	e9 c3 00 00 00       	jmp    80106785 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c5:	8b 04 85 78 b0 10 80 	mov    -0x7fef4f88(,%eax,4),%eax
801066cc:	89 c2                	mov    %eax,%edx
801066ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d1:	66 89 14 c5 a0 4d 11 	mov    %dx,-0x7feeb260(,%eax,8)
801066d8:	80 
801066d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066dc:	66 c7 04 c5 a2 4d 11 	movw   $0x8,-0x7feeb25e(,%eax,8)
801066e3:	80 08 00 
801066e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e9:	0f b6 14 c5 a4 4d 11 	movzbl -0x7feeb25c(,%eax,8),%edx
801066f0:	80 
801066f1:	83 e2 e0             	and    $0xffffffe0,%edx
801066f4:	88 14 c5 a4 4d 11 80 	mov    %dl,-0x7feeb25c(,%eax,8)
801066fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fe:	0f b6 14 c5 a4 4d 11 	movzbl -0x7feeb25c(,%eax,8),%edx
80106705:	80 
80106706:	83 e2 1f             	and    $0x1f,%edx
80106709:	88 14 c5 a4 4d 11 80 	mov    %dl,-0x7feeb25c(,%eax,8)
80106710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106713:	0f b6 14 c5 a5 4d 11 	movzbl -0x7feeb25b(,%eax,8),%edx
8010671a:	80 
8010671b:	83 e2 f0             	and    $0xfffffff0,%edx
8010671e:	83 ca 0e             	or     $0xe,%edx
80106721:	88 14 c5 a5 4d 11 80 	mov    %dl,-0x7feeb25b(,%eax,8)
80106728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672b:	0f b6 14 c5 a5 4d 11 	movzbl -0x7feeb25b(,%eax,8),%edx
80106732:	80 
80106733:	83 e2 ef             	and    $0xffffffef,%edx
80106736:	88 14 c5 a5 4d 11 80 	mov    %dl,-0x7feeb25b(,%eax,8)
8010673d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106740:	0f b6 14 c5 a5 4d 11 	movzbl -0x7feeb25b(,%eax,8),%edx
80106747:	80 
80106748:	83 e2 9f             	and    $0xffffff9f,%edx
8010674b:	88 14 c5 a5 4d 11 80 	mov    %dl,-0x7feeb25b(,%eax,8)
80106752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106755:	0f b6 14 c5 a5 4d 11 	movzbl -0x7feeb25b(,%eax,8),%edx
8010675c:	80 
8010675d:	83 ca 80             	or     $0xffffff80,%edx
80106760:	88 14 c5 a5 4d 11 80 	mov    %dl,-0x7feeb25b(,%eax,8)
80106767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676a:	8b 04 85 78 b0 10 80 	mov    -0x7fef4f88(,%eax,4),%eax
80106771:	c1 e8 10             	shr    $0x10,%eax
80106774:	89 c2                	mov    %eax,%edx
80106776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106779:	66 89 14 c5 a6 4d 11 	mov    %dx,-0x7feeb25a(,%eax,8)
80106780:	80 
  for(i = 0; i < 256; i++)
80106781:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106785:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010678c:	0f 8e 30 ff ff ff    	jle    801066c2 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106792:	a1 78 b1 10 80       	mov    0x8010b178,%eax
80106797:	66 a3 a0 4f 11 80    	mov    %ax,0x80114fa0
8010679d:	66 c7 05 a2 4f 11 80 	movw   $0x8,0x80114fa2
801067a4:	08 00 
801067a6:	0f b6 05 a4 4f 11 80 	movzbl 0x80114fa4,%eax
801067ad:	83 e0 e0             	and    $0xffffffe0,%eax
801067b0:	a2 a4 4f 11 80       	mov    %al,0x80114fa4
801067b5:	0f b6 05 a4 4f 11 80 	movzbl 0x80114fa4,%eax
801067bc:	83 e0 1f             	and    $0x1f,%eax
801067bf:	a2 a4 4f 11 80       	mov    %al,0x80114fa4
801067c4:	0f b6 05 a5 4f 11 80 	movzbl 0x80114fa5,%eax
801067cb:	83 c8 0f             	or     $0xf,%eax
801067ce:	a2 a5 4f 11 80       	mov    %al,0x80114fa5
801067d3:	0f b6 05 a5 4f 11 80 	movzbl 0x80114fa5,%eax
801067da:	83 e0 ef             	and    $0xffffffef,%eax
801067dd:	a2 a5 4f 11 80       	mov    %al,0x80114fa5
801067e2:	0f b6 05 a5 4f 11 80 	movzbl 0x80114fa5,%eax
801067e9:	83 c8 60             	or     $0x60,%eax
801067ec:	a2 a5 4f 11 80       	mov    %al,0x80114fa5
801067f1:	0f b6 05 a5 4f 11 80 	movzbl 0x80114fa5,%eax
801067f8:	83 c8 80             	or     $0xffffff80,%eax
801067fb:	a2 a5 4f 11 80       	mov    %al,0x80114fa5
80106800:	a1 78 b1 10 80       	mov    0x8010b178,%eax
80106805:	c1 e8 10             	shr    $0x10,%eax
80106808:	66 a3 a6 4f 11 80    	mov    %ax,0x80114fa6

  initlock(&tickslock, "time");
8010680e:	83 ec 08             	sub    $0x8,%esp
80106811:	68 b4 89 10 80       	push   $0x801089b4
80106816:	68 a0 55 11 80       	push   $0x801155a0
8010681b:	e8 1b e8 ff ff       	call   8010503b <initlock>
80106820:	83 c4 10             	add    $0x10,%esp
}
80106823:	90                   	nop
80106824:	c9                   	leave  
80106825:	c3                   	ret    

80106826 <idtinit>:

void
idtinit(void)
{
80106826:	55                   	push   %ebp
80106827:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106829:	68 00 08 00 00       	push   $0x800
8010682e:	68 a0 4d 11 80       	push   $0x80114da0
80106833:	e8 3d fe ff ff       	call   80106675 <lidt>
80106838:	83 c4 08             	add    $0x8,%esp
}
8010683b:	90                   	nop
8010683c:	c9                   	leave  
8010683d:	c3                   	ret    

8010683e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010683e:	55                   	push   %ebp
8010683f:	89 e5                	mov    %esp,%ebp
80106841:	57                   	push   %edi
80106842:	56                   	push   %esi
80106843:	53                   	push   %ebx
80106844:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106847:	8b 45 08             	mov    0x8(%ebp),%eax
8010684a:	8b 40 30             	mov    0x30(%eax),%eax
8010684d:	83 f8 40             	cmp    $0x40,%eax
80106850:	75 3b                	jne    8010688d <trap+0x4f>
    if(myproc()->killed)
80106852:	e8 00 db ff ff       	call   80104357 <myproc>
80106857:	8b 40 24             	mov    0x24(%eax),%eax
8010685a:	85 c0                	test   %eax,%eax
8010685c:	74 05                	je     80106863 <trap+0x25>
      exit();
8010685e:	e8 88 df ff ff       	call   801047eb <exit>
    myproc()->tf = tf;
80106863:	e8 ef da ff ff       	call   80104357 <myproc>
80106868:	8b 55 08             	mov    0x8(%ebp),%edx
8010686b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010686e:	e8 67 ee ff ff       	call   801056da <syscall>
    if(myproc()->killed)
80106873:	e8 df da ff ff       	call   80104357 <myproc>
80106878:	8b 40 24             	mov    0x24(%eax),%eax
8010687b:	85 c0                	test   %eax,%eax
8010687d:	0f 84 06 02 00 00    	je     80106a89 <trap+0x24b>
      exit();
80106883:	e8 63 df ff ff       	call   801047eb <exit>
    return;
80106888:	e9 fc 01 00 00       	jmp    80106a89 <trap+0x24b>
  }

  switch(tf->trapno){
8010688d:	8b 45 08             	mov    0x8(%ebp),%eax
80106890:	8b 40 30             	mov    0x30(%eax),%eax
80106893:	83 e8 20             	sub    $0x20,%eax
80106896:	83 f8 1f             	cmp    $0x1f,%eax
80106899:	0f 87 b5 00 00 00    	ja     80106954 <trap+0x116>
8010689f:	8b 04 85 5c 8a 10 80 	mov    -0x7fef75a4(,%eax,4),%eax
801068a6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801068a8:	e8 17 da ff ff       	call   801042c4 <cpuid>
801068ad:	85 c0                	test   %eax,%eax
801068af:	75 3d                	jne    801068ee <trap+0xb0>
      acquire(&tickslock);
801068b1:	83 ec 0c             	sub    $0xc,%esp
801068b4:	68 a0 55 11 80       	push   $0x801155a0
801068b9:	e8 9f e7 ff ff       	call   8010505d <acquire>
801068be:	83 c4 10             	add    $0x10,%esp
      ticks++;
801068c1:	a1 d4 55 11 80       	mov    0x801155d4,%eax
801068c6:	83 c0 01             	add    $0x1,%eax
801068c9:	a3 d4 55 11 80       	mov    %eax,0x801155d4
      wakeup(&ticks);
801068ce:	83 ec 0c             	sub    $0xc,%esp
801068d1:	68 d4 55 11 80       	push   $0x801155d4
801068d6:	e8 28 e4 ff ff       	call   80104d03 <wakeup>
801068db:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801068de:	83 ec 0c             	sub    $0xc,%esp
801068e1:	68 a0 55 11 80       	push   $0x801155a0
801068e6:	e8 e0 e7 ff ff       	call   801050cb <release>
801068eb:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801068ee:	e8 dd c7 ff ff       	call   801030d0 <lapiceoi>
    break;
801068f3:	e9 11 01 00 00       	jmp    80106a09 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801068f8:	e8 47 c0 ff ff       	call   80102944 <ideintr>
    lapiceoi();
801068fd:	e8 ce c7 ff ff       	call   801030d0 <lapiceoi>
    break;
80106902:	e9 02 01 00 00       	jmp    80106a09 <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106907:	e8 09 c6 ff ff       	call   80102f15 <kbdintr>
    lapiceoi();
8010690c:	e8 bf c7 ff ff       	call   801030d0 <lapiceoi>
    break;
80106911:	e9 f3 00 00 00       	jmp    80106a09 <trap+0x1cb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106916:	e8 44 03 00 00       	call   80106c5f <uartintr>
    lapiceoi();
8010691b:	e8 b0 c7 ff ff       	call   801030d0 <lapiceoi>
    break;
80106920:	e9 e4 00 00 00       	jmp    80106a09 <trap+0x1cb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106925:	8b 45 08             	mov    0x8(%ebp),%eax
80106928:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010692b:	8b 45 08             	mov    0x8(%ebp),%eax
8010692e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106932:	0f b7 d8             	movzwl %ax,%ebx
80106935:	e8 8a d9 ff ff       	call   801042c4 <cpuid>
8010693a:	56                   	push   %esi
8010693b:	53                   	push   %ebx
8010693c:	50                   	push   %eax
8010693d:	68 bc 89 10 80       	push   $0x801089bc
80106942:	e8 b9 9a ff ff       	call   80100400 <cprintf>
80106947:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010694a:	e8 81 c7 ff ff       	call   801030d0 <lapiceoi>
    break;
8010694f:	e9 b5 00 00 00       	jmp    80106a09 <trap+0x1cb>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106954:	e8 fe d9 ff ff       	call   80104357 <myproc>
80106959:	85 c0                	test   %eax,%eax
8010695b:	74 11                	je     8010696e <trap+0x130>
8010695d:	8b 45 08             	mov    0x8(%ebp),%eax
80106960:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106964:	0f b7 c0             	movzwl %ax,%eax
80106967:	83 e0 03             	and    $0x3,%eax
8010696a:	85 c0                	test   %eax,%eax
8010696c:	75 39                	jne    801069a7 <trap+0x169>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010696e:	e8 2c fd ff ff       	call   8010669f <rcr2>
80106973:	89 c3                	mov    %eax,%ebx
80106975:	8b 45 08             	mov    0x8(%ebp),%eax
80106978:	8b 70 38             	mov    0x38(%eax),%esi
8010697b:	e8 44 d9 ff ff       	call   801042c4 <cpuid>
80106980:	8b 55 08             	mov    0x8(%ebp),%edx
80106983:	8b 52 30             	mov    0x30(%edx),%edx
80106986:	83 ec 0c             	sub    $0xc,%esp
80106989:	53                   	push   %ebx
8010698a:	56                   	push   %esi
8010698b:	50                   	push   %eax
8010698c:	52                   	push   %edx
8010698d:	68 e0 89 10 80       	push   $0x801089e0
80106992:	e8 69 9a ff ff       	call   80100400 <cprintf>
80106997:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010699a:	83 ec 0c             	sub    $0xc,%esp
8010699d:	68 12 8a 10 80       	push   $0x80108a12
801069a2:	e8 0e 9c ff ff       	call   801005b5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069a7:	e8 f3 fc ff ff       	call   8010669f <rcr2>
801069ac:	89 c6                	mov    %eax,%esi
801069ae:	8b 45 08             	mov    0x8(%ebp),%eax
801069b1:	8b 40 38             	mov    0x38(%eax),%eax
801069b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801069b7:	e8 08 d9 ff ff       	call   801042c4 <cpuid>
801069bc:	89 c3                	mov    %eax,%ebx
801069be:	8b 45 08             	mov    0x8(%ebp),%eax
801069c1:	8b 48 34             	mov    0x34(%eax),%ecx
801069c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801069c7:	8b 45 08             	mov    0x8(%ebp),%eax
801069ca:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801069cd:	e8 85 d9 ff ff       	call   80104357 <myproc>
801069d2:	8d 50 6c             	lea    0x6c(%eax),%edx
801069d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
801069d8:	e8 7a d9 ff ff       	call   80104357 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069dd:	8b 40 10             	mov    0x10(%eax),%eax
801069e0:	56                   	push   %esi
801069e1:	ff 75 e4             	push   -0x1c(%ebp)
801069e4:	53                   	push   %ebx
801069e5:	ff 75 e0             	push   -0x20(%ebp)
801069e8:	57                   	push   %edi
801069e9:	ff 75 dc             	push   -0x24(%ebp)
801069ec:	50                   	push   %eax
801069ed:	68 18 8a 10 80       	push   $0x80108a18
801069f2:	e8 09 9a ff ff       	call   80100400 <cprintf>
801069f7:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801069fa:	e8 58 d9 ff ff       	call   80104357 <myproc>
801069ff:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a06:	eb 01                	jmp    80106a09 <trap+0x1cb>
    break;
80106a08:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a09:	e8 49 d9 ff ff       	call   80104357 <myproc>
80106a0e:	85 c0                	test   %eax,%eax
80106a10:	74 23                	je     80106a35 <trap+0x1f7>
80106a12:	e8 40 d9 ff ff       	call   80104357 <myproc>
80106a17:	8b 40 24             	mov    0x24(%eax),%eax
80106a1a:	85 c0                	test   %eax,%eax
80106a1c:	74 17                	je     80106a35 <trap+0x1f7>
80106a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106a21:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a25:	0f b7 c0             	movzwl %ax,%eax
80106a28:	83 e0 03             	and    $0x3,%eax
80106a2b:	83 f8 03             	cmp    $0x3,%eax
80106a2e:	75 05                	jne    80106a35 <trap+0x1f7>
    exit();
80106a30:	e8 b6 dd ff ff       	call   801047eb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106a35:	e8 1d d9 ff ff       	call   80104357 <myproc>
80106a3a:	85 c0                	test   %eax,%eax
80106a3c:	74 1d                	je     80106a5b <trap+0x21d>
80106a3e:	e8 14 d9 ff ff       	call   80104357 <myproc>
80106a43:	8b 40 0c             	mov    0xc(%eax),%eax
80106a46:	83 f8 04             	cmp    $0x4,%eax
80106a49:	75 10                	jne    80106a5b <trap+0x21d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a4e:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106a51:	83 f8 20             	cmp    $0x20,%eax
80106a54:	75 05                	jne    80106a5b <trap+0x21d>
    yield();
80106a56:	e8 41 e1 ff ff       	call   80104b9c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a5b:	e8 f7 d8 ff ff       	call   80104357 <myproc>
80106a60:	85 c0                	test   %eax,%eax
80106a62:	74 26                	je     80106a8a <trap+0x24c>
80106a64:	e8 ee d8 ff ff       	call   80104357 <myproc>
80106a69:	8b 40 24             	mov    0x24(%eax),%eax
80106a6c:	85 c0                	test   %eax,%eax
80106a6e:	74 1a                	je     80106a8a <trap+0x24c>
80106a70:	8b 45 08             	mov    0x8(%ebp),%eax
80106a73:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a77:	0f b7 c0             	movzwl %ax,%eax
80106a7a:	83 e0 03             	and    $0x3,%eax
80106a7d:	83 f8 03             	cmp    $0x3,%eax
80106a80:	75 08                	jne    80106a8a <trap+0x24c>
    exit();
80106a82:	e8 64 dd ff ff       	call   801047eb <exit>
80106a87:	eb 01                	jmp    80106a8a <trap+0x24c>
    return;
80106a89:	90                   	nop
}
80106a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a8d:	5b                   	pop    %ebx
80106a8e:	5e                   	pop    %esi
80106a8f:	5f                   	pop    %edi
80106a90:	5d                   	pop    %ebp
80106a91:	c3                   	ret    

80106a92 <inb>:
{
80106a92:	55                   	push   %ebp
80106a93:	89 e5                	mov    %esp,%ebp
80106a95:	83 ec 14             	sub    $0x14,%esp
80106a98:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a9f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106aa3:	89 c2                	mov    %eax,%edx
80106aa5:	ec                   	in     (%dx),%al
80106aa6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106aa9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106aad:	c9                   	leave  
80106aae:	c3                   	ret    

80106aaf <outb>:
{
80106aaf:	55                   	push   %ebp
80106ab0:	89 e5                	mov    %esp,%ebp
80106ab2:	83 ec 08             	sub    $0x8,%esp
80106ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
80106abb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106abf:	89 d0                	mov    %edx,%eax
80106ac1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ac4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ac8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106acc:	ee                   	out    %al,(%dx)
}
80106acd:	90                   	nop
80106ace:	c9                   	leave  
80106acf:	c3                   	ret    

80106ad0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106ad0:	55                   	push   %ebp
80106ad1:	89 e5                	mov    %esp,%ebp
80106ad3:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106ad6:	6a 00                	push   $0x0
80106ad8:	68 fa 03 00 00       	push   $0x3fa
80106add:	e8 cd ff ff ff       	call   80106aaf <outb>
80106ae2:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ae5:	68 80 00 00 00       	push   $0x80
80106aea:	68 fb 03 00 00       	push   $0x3fb
80106aef:	e8 bb ff ff ff       	call   80106aaf <outb>
80106af4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106af7:	6a 0c                	push   $0xc
80106af9:	68 f8 03 00 00       	push   $0x3f8
80106afe:	e8 ac ff ff ff       	call   80106aaf <outb>
80106b03:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b06:	6a 00                	push   $0x0
80106b08:	68 f9 03 00 00       	push   $0x3f9
80106b0d:	e8 9d ff ff ff       	call   80106aaf <outb>
80106b12:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b15:	6a 03                	push   $0x3
80106b17:	68 fb 03 00 00       	push   $0x3fb
80106b1c:	e8 8e ff ff ff       	call   80106aaf <outb>
80106b21:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b24:	6a 00                	push   $0x0
80106b26:	68 fc 03 00 00       	push   $0x3fc
80106b2b:	e8 7f ff ff ff       	call   80106aaf <outb>
80106b30:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b33:	6a 01                	push   $0x1
80106b35:	68 f9 03 00 00       	push   $0x3f9
80106b3a:	e8 70 ff ff ff       	call   80106aaf <outb>
80106b3f:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b42:	68 fd 03 00 00       	push   $0x3fd
80106b47:	e8 46 ff ff ff       	call   80106a92 <inb>
80106b4c:	83 c4 04             	add    $0x4,%esp
80106b4f:	3c ff                	cmp    $0xff,%al
80106b51:	74 61                	je     80106bb4 <uartinit+0xe4>
    return;
  uart = 1;
80106b53:	c7 05 d8 55 11 80 01 	movl   $0x1,0x801155d8
80106b5a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b5d:	68 fa 03 00 00       	push   $0x3fa
80106b62:	e8 2b ff ff ff       	call   80106a92 <inb>
80106b67:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b6a:	68 f8 03 00 00       	push   $0x3f8
80106b6f:	e8 1e ff ff ff       	call   80106a92 <inb>
80106b74:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106b77:	83 ec 08             	sub    $0x8,%esp
80106b7a:	6a 00                	push   $0x0
80106b7c:	6a 04                	push   $0x4
80106b7e:	e8 5f c0 ff ff       	call   80102be2 <ioapicenable>
80106b83:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106b86:	c7 45 f4 dc 8a 10 80 	movl   $0x80108adc,-0xc(%ebp)
80106b8d:	eb 19                	jmp    80106ba8 <uartinit+0xd8>
    uartputc(*p);
80106b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b92:	0f b6 00             	movzbl (%eax),%eax
80106b95:	0f be c0             	movsbl %al,%eax
80106b98:	83 ec 0c             	sub    $0xc,%esp
80106b9b:	50                   	push   %eax
80106b9c:	e8 16 00 00 00       	call   80106bb7 <uartputc>
80106ba1:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106ba4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bab:	0f b6 00             	movzbl (%eax),%eax
80106bae:	84 c0                	test   %al,%al
80106bb0:	75 dd                	jne    80106b8f <uartinit+0xbf>
80106bb2:	eb 01                	jmp    80106bb5 <uartinit+0xe5>
    return;
80106bb4:	90                   	nop
}
80106bb5:	c9                   	leave  
80106bb6:	c3                   	ret    

80106bb7 <uartputc>:

void
uartputc(int c)
{
80106bb7:	55                   	push   %ebp
80106bb8:	89 e5                	mov    %esp,%ebp
80106bba:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106bbd:	a1 d8 55 11 80       	mov    0x801155d8,%eax
80106bc2:	85 c0                	test   %eax,%eax
80106bc4:	74 53                	je     80106c19 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106bcd:	eb 11                	jmp    80106be0 <uartputc+0x29>
    microdelay(10);
80106bcf:	83 ec 0c             	sub    $0xc,%esp
80106bd2:	6a 0a                	push   $0xa
80106bd4:	e8 12 c5 ff ff       	call   801030eb <microdelay>
80106bd9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106bdc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106be0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106be4:	7f 1a                	jg     80106c00 <uartputc+0x49>
80106be6:	83 ec 0c             	sub    $0xc,%esp
80106be9:	68 fd 03 00 00       	push   $0x3fd
80106bee:	e8 9f fe ff ff       	call   80106a92 <inb>
80106bf3:	83 c4 10             	add    $0x10,%esp
80106bf6:	0f b6 c0             	movzbl %al,%eax
80106bf9:	83 e0 20             	and    $0x20,%eax
80106bfc:	85 c0                	test   %eax,%eax
80106bfe:	74 cf                	je     80106bcf <uartputc+0x18>
  outb(COM1+0, c);
80106c00:	8b 45 08             	mov    0x8(%ebp),%eax
80106c03:	0f b6 c0             	movzbl %al,%eax
80106c06:	83 ec 08             	sub    $0x8,%esp
80106c09:	50                   	push   %eax
80106c0a:	68 f8 03 00 00       	push   $0x3f8
80106c0f:	e8 9b fe ff ff       	call   80106aaf <outb>
80106c14:	83 c4 10             	add    $0x10,%esp
80106c17:	eb 01                	jmp    80106c1a <uartputc+0x63>
    return;
80106c19:	90                   	nop
}
80106c1a:	c9                   	leave  
80106c1b:	c3                   	ret    

80106c1c <uartgetc>:

static int
uartgetc(void)
{
80106c1c:	55                   	push   %ebp
80106c1d:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c1f:	a1 d8 55 11 80       	mov    0x801155d8,%eax
80106c24:	85 c0                	test   %eax,%eax
80106c26:	75 07                	jne    80106c2f <uartgetc+0x13>
    return -1;
80106c28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c2d:	eb 2e                	jmp    80106c5d <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c2f:	68 fd 03 00 00       	push   $0x3fd
80106c34:	e8 59 fe ff ff       	call   80106a92 <inb>
80106c39:	83 c4 04             	add    $0x4,%esp
80106c3c:	0f b6 c0             	movzbl %al,%eax
80106c3f:	83 e0 01             	and    $0x1,%eax
80106c42:	85 c0                	test   %eax,%eax
80106c44:	75 07                	jne    80106c4d <uartgetc+0x31>
    return -1;
80106c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c4b:	eb 10                	jmp    80106c5d <uartgetc+0x41>
  return inb(COM1+0);
80106c4d:	68 f8 03 00 00       	push   $0x3f8
80106c52:	e8 3b fe ff ff       	call   80106a92 <inb>
80106c57:	83 c4 04             	add    $0x4,%esp
80106c5a:	0f b6 c0             	movzbl %al,%eax
}
80106c5d:	c9                   	leave  
80106c5e:	c3                   	ret    

80106c5f <uartintr>:

void
uartintr(void)
{
80106c5f:	55                   	push   %ebp
80106c60:	89 e5                	mov    %esp,%ebp
80106c62:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106c65:	83 ec 0c             	sub    $0xc,%esp
80106c68:	68 1c 6c 10 80       	push   $0x80106c1c
80106c6d:	e8 dd 9b ff ff       	call   8010084f <consoleintr>
80106c72:	83 c4 10             	add    $0x10,%esp
}
80106c75:	90                   	nop
80106c76:	c9                   	leave  
80106c77:	c3                   	ret    

80106c78 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $0
80106c7a:	6a 00                	push   $0x0
  jmp alltraps
80106c7c:	e9 d1 f9 ff ff       	jmp    80106652 <alltraps>

80106c81 <vector1>:
.globl vector1
vector1:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $1
80106c83:	6a 01                	push   $0x1
  jmp alltraps
80106c85:	e9 c8 f9 ff ff       	jmp    80106652 <alltraps>

80106c8a <vector2>:
.globl vector2
vector2:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $2
80106c8c:	6a 02                	push   $0x2
  jmp alltraps
80106c8e:	e9 bf f9 ff ff       	jmp    80106652 <alltraps>

80106c93 <vector3>:
.globl vector3
vector3:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $3
80106c95:	6a 03                	push   $0x3
  jmp alltraps
80106c97:	e9 b6 f9 ff ff       	jmp    80106652 <alltraps>

80106c9c <vector4>:
.globl vector4
vector4:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $4
80106c9e:	6a 04                	push   $0x4
  jmp alltraps
80106ca0:	e9 ad f9 ff ff       	jmp    80106652 <alltraps>

80106ca5 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $5
80106ca7:	6a 05                	push   $0x5
  jmp alltraps
80106ca9:	e9 a4 f9 ff ff       	jmp    80106652 <alltraps>

80106cae <vector6>:
.globl vector6
vector6:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $6
80106cb0:	6a 06                	push   $0x6
  jmp alltraps
80106cb2:	e9 9b f9 ff ff       	jmp    80106652 <alltraps>

80106cb7 <vector7>:
.globl vector7
vector7:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $7
80106cb9:	6a 07                	push   $0x7
  jmp alltraps
80106cbb:	e9 92 f9 ff ff       	jmp    80106652 <alltraps>

80106cc0 <vector8>:
.globl vector8
vector8:
  pushl $8
80106cc0:	6a 08                	push   $0x8
  jmp alltraps
80106cc2:	e9 8b f9 ff ff       	jmp    80106652 <alltraps>

80106cc7 <vector9>:
.globl vector9
vector9:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $9
80106cc9:	6a 09                	push   $0x9
  jmp alltraps
80106ccb:	e9 82 f9 ff ff       	jmp    80106652 <alltraps>

80106cd0 <vector10>:
.globl vector10
vector10:
  pushl $10
80106cd0:	6a 0a                	push   $0xa
  jmp alltraps
80106cd2:	e9 7b f9 ff ff       	jmp    80106652 <alltraps>

80106cd7 <vector11>:
.globl vector11
vector11:
  pushl $11
80106cd7:	6a 0b                	push   $0xb
  jmp alltraps
80106cd9:	e9 74 f9 ff ff       	jmp    80106652 <alltraps>

80106cde <vector12>:
.globl vector12
vector12:
  pushl $12
80106cde:	6a 0c                	push   $0xc
  jmp alltraps
80106ce0:	e9 6d f9 ff ff       	jmp    80106652 <alltraps>

80106ce5 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ce5:	6a 0d                	push   $0xd
  jmp alltraps
80106ce7:	e9 66 f9 ff ff       	jmp    80106652 <alltraps>

80106cec <vector14>:
.globl vector14
vector14:
  pushl $14
80106cec:	6a 0e                	push   $0xe
  jmp alltraps
80106cee:	e9 5f f9 ff ff       	jmp    80106652 <alltraps>

80106cf3 <vector15>:
.globl vector15
vector15:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $15
80106cf5:	6a 0f                	push   $0xf
  jmp alltraps
80106cf7:	e9 56 f9 ff ff       	jmp    80106652 <alltraps>

80106cfc <vector16>:
.globl vector16
vector16:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $16
80106cfe:	6a 10                	push   $0x10
  jmp alltraps
80106d00:	e9 4d f9 ff ff       	jmp    80106652 <alltraps>

80106d05 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d05:	6a 11                	push   $0x11
  jmp alltraps
80106d07:	e9 46 f9 ff ff       	jmp    80106652 <alltraps>

80106d0c <vector18>:
.globl vector18
vector18:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $18
80106d0e:	6a 12                	push   $0x12
  jmp alltraps
80106d10:	e9 3d f9 ff ff       	jmp    80106652 <alltraps>

80106d15 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $19
80106d17:	6a 13                	push   $0x13
  jmp alltraps
80106d19:	e9 34 f9 ff ff       	jmp    80106652 <alltraps>

80106d1e <vector20>:
.globl vector20
vector20:
  pushl $0
80106d1e:	6a 00                	push   $0x0
  pushl $20
80106d20:	6a 14                	push   $0x14
  jmp alltraps
80106d22:	e9 2b f9 ff ff       	jmp    80106652 <alltraps>

80106d27 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $21
80106d29:	6a 15                	push   $0x15
  jmp alltraps
80106d2b:	e9 22 f9 ff ff       	jmp    80106652 <alltraps>

80106d30 <vector22>:
.globl vector22
vector22:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $22
80106d32:	6a 16                	push   $0x16
  jmp alltraps
80106d34:	e9 19 f9 ff ff       	jmp    80106652 <alltraps>

80106d39 <vector23>:
.globl vector23
vector23:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $23
80106d3b:	6a 17                	push   $0x17
  jmp alltraps
80106d3d:	e9 10 f9 ff ff       	jmp    80106652 <alltraps>

80106d42 <vector24>:
.globl vector24
vector24:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $24
80106d44:	6a 18                	push   $0x18
  jmp alltraps
80106d46:	e9 07 f9 ff ff       	jmp    80106652 <alltraps>

80106d4b <vector25>:
.globl vector25
vector25:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $25
80106d4d:	6a 19                	push   $0x19
  jmp alltraps
80106d4f:	e9 fe f8 ff ff       	jmp    80106652 <alltraps>

80106d54 <vector26>:
.globl vector26
vector26:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $26
80106d56:	6a 1a                	push   $0x1a
  jmp alltraps
80106d58:	e9 f5 f8 ff ff       	jmp    80106652 <alltraps>

80106d5d <vector27>:
.globl vector27
vector27:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $27
80106d5f:	6a 1b                	push   $0x1b
  jmp alltraps
80106d61:	e9 ec f8 ff ff       	jmp    80106652 <alltraps>

80106d66 <vector28>:
.globl vector28
vector28:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $28
80106d68:	6a 1c                	push   $0x1c
  jmp alltraps
80106d6a:	e9 e3 f8 ff ff       	jmp    80106652 <alltraps>

80106d6f <vector29>:
.globl vector29
vector29:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $29
80106d71:	6a 1d                	push   $0x1d
  jmp alltraps
80106d73:	e9 da f8 ff ff       	jmp    80106652 <alltraps>

80106d78 <vector30>:
.globl vector30
vector30:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $30
80106d7a:	6a 1e                	push   $0x1e
  jmp alltraps
80106d7c:	e9 d1 f8 ff ff       	jmp    80106652 <alltraps>

80106d81 <vector31>:
.globl vector31
vector31:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $31
80106d83:	6a 1f                	push   $0x1f
  jmp alltraps
80106d85:	e9 c8 f8 ff ff       	jmp    80106652 <alltraps>

80106d8a <vector32>:
.globl vector32
vector32:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $32
80106d8c:	6a 20                	push   $0x20
  jmp alltraps
80106d8e:	e9 bf f8 ff ff       	jmp    80106652 <alltraps>

80106d93 <vector33>:
.globl vector33
vector33:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $33
80106d95:	6a 21                	push   $0x21
  jmp alltraps
80106d97:	e9 b6 f8 ff ff       	jmp    80106652 <alltraps>

80106d9c <vector34>:
.globl vector34
vector34:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $34
80106d9e:	6a 22                	push   $0x22
  jmp alltraps
80106da0:	e9 ad f8 ff ff       	jmp    80106652 <alltraps>

80106da5 <vector35>:
.globl vector35
vector35:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $35
80106da7:	6a 23                	push   $0x23
  jmp alltraps
80106da9:	e9 a4 f8 ff ff       	jmp    80106652 <alltraps>

80106dae <vector36>:
.globl vector36
vector36:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $36
80106db0:	6a 24                	push   $0x24
  jmp alltraps
80106db2:	e9 9b f8 ff ff       	jmp    80106652 <alltraps>

80106db7 <vector37>:
.globl vector37
vector37:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $37
80106db9:	6a 25                	push   $0x25
  jmp alltraps
80106dbb:	e9 92 f8 ff ff       	jmp    80106652 <alltraps>

80106dc0 <vector38>:
.globl vector38
vector38:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $38
80106dc2:	6a 26                	push   $0x26
  jmp alltraps
80106dc4:	e9 89 f8 ff ff       	jmp    80106652 <alltraps>

80106dc9 <vector39>:
.globl vector39
vector39:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $39
80106dcb:	6a 27                	push   $0x27
  jmp alltraps
80106dcd:	e9 80 f8 ff ff       	jmp    80106652 <alltraps>

80106dd2 <vector40>:
.globl vector40
vector40:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $40
80106dd4:	6a 28                	push   $0x28
  jmp alltraps
80106dd6:	e9 77 f8 ff ff       	jmp    80106652 <alltraps>

80106ddb <vector41>:
.globl vector41
vector41:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $41
80106ddd:	6a 29                	push   $0x29
  jmp alltraps
80106ddf:	e9 6e f8 ff ff       	jmp    80106652 <alltraps>

80106de4 <vector42>:
.globl vector42
vector42:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $42
80106de6:	6a 2a                	push   $0x2a
  jmp alltraps
80106de8:	e9 65 f8 ff ff       	jmp    80106652 <alltraps>

80106ded <vector43>:
.globl vector43
vector43:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $43
80106def:	6a 2b                	push   $0x2b
  jmp alltraps
80106df1:	e9 5c f8 ff ff       	jmp    80106652 <alltraps>

80106df6 <vector44>:
.globl vector44
vector44:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $44
80106df8:	6a 2c                	push   $0x2c
  jmp alltraps
80106dfa:	e9 53 f8 ff ff       	jmp    80106652 <alltraps>

80106dff <vector45>:
.globl vector45
vector45:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $45
80106e01:	6a 2d                	push   $0x2d
  jmp alltraps
80106e03:	e9 4a f8 ff ff       	jmp    80106652 <alltraps>

80106e08 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $46
80106e0a:	6a 2e                	push   $0x2e
  jmp alltraps
80106e0c:	e9 41 f8 ff ff       	jmp    80106652 <alltraps>

80106e11 <vector47>:
.globl vector47
vector47:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $47
80106e13:	6a 2f                	push   $0x2f
  jmp alltraps
80106e15:	e9 38 f8 ff ff       	jmp    80106652 <alltraps>

80106e1a <vector48>:
.globl vector48
vector48:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $48
80106e1c:	6a 30                	push   $0x30
  jmp alltraps
80106e1e:	e9 2f f8 ff ff       	jmp    80106652 <alltraps>

80106e23 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $49
80106e25:	6a 31                	push   $0x31
  jmp alltraps
80106e27:	e9 26 f8 ff ff       	jmp    80106652 <alltraps>

80106e2c <vector50>:
.globl vector50
vector50:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $50
80106e2e:	6a 32                	push   $0x32
  jmp alltraps
80106e30:	e9 1d f8 ff ff       	jmp    80106652 <alltraps>

80106e35 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $51
80106e37:	6a 33                	push   $0x33
  jmp alltraps
80106e39:	e9 14 f8 ff ff       	jmp    80106652 <alltraps>

80106e3e <vector52>:
.globl vector52
vector52:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $52
80106e40:	6a 34                	push   $0x34
  jmp alltraps
80106e42:	e9 0b f8 ff ff       	jmp    80106652 <alltraps>

80106e47 <vector53>:
.globl vector53
vector53:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $53
80106e49:	6a 35                	push   $0x35
  jmp alltraps
80106e4b:	e9 02 f8 ff ff       	jmp    80106652 <alltraps>

80106e50 <vector54>:
.globl vector54
vector54:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $54
80106e52:	6a 36                	push   $0x36
  jmp alltraps
80106e54:	e9 f9 f7 ff ff       	jmp    80106652 <alltraps>

80106e59 <vector55>:
.globl vector55
vector55:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $55
80106e5b:	6a 37                	push   $0x37
  jmp alltraps
80106e5d:	e9 f0 f7 ff ff       	jmp    80106652 <alltraps>

80106e62 <vector56>:
.globl vector56
vector56:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $56
80106e64:	6a 38                	push   $0x38
  jmp alltraps
80106e66:	e9 e7 f7 ff ff       	jmp    80106652 <alltraps>

80106e6b <vector57>:
.globl vector57
vector57:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $57
80106e6d:	6a 39                	push   $0x39
  jmp alltraps
80106e6f:	e9 de f7 ff ff       	jmp    80106652 <alltraps>

80106e74 <vector58>:
.globl vector58
vector58:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $58
80106e76:	6a 3a                	push   $0x3a
  jmp alltraps
80106e78:	e9 d5 f7 ff ff       	jmp    80106652 <alltraps>

80106e7d <vector59>:
.globl vector59
vector59:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $59
80106e7f:	6a 3b                	push   $0x3b
  jmp alltraps
80106e81:	e9 cc f7 ff ff       	jmp    80106652 <alltraps>

80106e86 <vector60>:
.globl vector60
vector60:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $60
80106e88:	6a 3c                	push   $0x3c
  jmp alltraps
80106e8a:	e9 c3 f7 ff ff       	jmp    80106652 <alltraps>

80106e8f <vector61>:
.globl vector61
vector61:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $61
80106e91:	6a 3d                	push   $0x3d
  jmp alltraps
80106e93:	e9 ba f7 ff ff       	jmp    80106652 <alltraps>

80106e98 <vector62>:
.globl vector62
vector62:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $62
80106e9a:	6a 3e                	push   $0x3e
  jmp alltraps
80106e9c:	e9 b1 f7 ff ff       	jmp    80106652 <alltraps>

80106ea1 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $63
80106ea3:	6a 3f                	push   $0x3f
  jmp alltraps
80106ea5:	e9 a8 f7 ff ff       	jmp    80106652 <alltraps>

80106eaa <vector64>:
.globl vector64
vector64:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $64
80106eac:	6a 40                	push   $0x40
  jmp alltraps
80106eae:	e9 9f f7 ff ff       	jmp    80106652 <alltraps>

80106eb3 <vector65>:
.globl vector65
vector65:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $65
80106eb5:	6a 41                	push   $0x41
  jmp alltraps
80106eb7:	e9 96 f7 ff ff       	jmp    80106652 <alltraps>

80106ebc <vector66>:
.globl vector66
vector66:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $66
80106ebe:	6a 42                	push   $0x42
  jmp alltraps
80106ec0:	e9 8d f7 ff ff       	jmp    80106652 <alltraps>

80106ec5 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $67
80106ec7:	6a 43                	push   $0x43
  jmp alltraps
80106ec9:	e9 84 f7 ff ff       	jmp    80106652 <alltraps>

80106ece <vector68>:
.globl vector68
vector68:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $68
80106ed0:	6a 44                	push   $0x44
  jmp alltraps
80106ed2:	e9 7b f7 ff ff       	jmp    80106652 <alltraps>

80106ed7 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $69
80106ed9:	6a 45                	push   $0x45
  jmp alltraps
80106edb:	e9 72 f7 ff ff       	jmp    80106652 <alltraps>

80106ee0 <vector70>:
.globl vector70
vector70:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $70
80106ee2:	6a 46                	push   $0x46
  jmp alltraps
80106ee4:	e9 69 f7 ff ff       	jmp    80106652 <alltraps>

80106ee9 <vector71>:
.globl vector71
vector71:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $71
80106eeb:	6a 47                	push   $0x47
  jmp alltraps
80106eed:	e9 60 f7 ff ff       	jmp    80106652 <alltraps>

80106ef2 <vector72>:
.globl vector72
vector72:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $72
80106ef4:	6a 48                	push   $0x48
  jmp alltraps
80106ef6:	e9 57 f7 ff ff       	jmp    80106652 <alltraps>

80106efb <vector73>:
.globl vector73
vector73:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $73
80106efd:	6a 49                	push   $0x49
  jmp alltraps
80106eff:	e9 4e f7 ff ff       	jmp    80106652 <alltraps>

80106f04 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $74
80106f06:	6a 4a                	push   $0x4a
  jmp alltraps
80106f08:	e9 45 f7 ff ff       	jmp    80106652 <alltraps>

80106f0d <vector75>:
.globl vector75
vector75:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $75
80106f0f:	6a 4b                	push   $0x4b
  jmp alltraps
80106f11:	e9 3c f7 ff ff       	jmp    80106652 <alltraps>

80106f16 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $76
80106f18:	6a 4c                	push   $0x4c
  jmp alltraps
80106f1a:	e9 33 f7 ff ff       	jmp    80106652 <alltraps>

80106f1f <vector77>:
.globl vector77
vector77:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $77
80106f21:	6a 4d                	push   $0x4d
  jmp alltraps
80106f23:	e9 2a f7 ff ff       	jmp    80106652 <alltraps>

80106f28 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $78
80106f2a:	6a 4e                	push   $0x4e
  jmp alltraps
80106f2c:	e9 21 f7 ff ff       	jmp    80106652 <alltraps>

80106f31 <vector79>:
.globl vector79
vector79:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $79
80106f33:	6a 4f                	push   $0x4f
  jmp alltraps
80106f35:	e9 18 f7 ff ff       	jmp    80106652 <alltraps>

80106f3a <vector80>:
.globl vector80
vector80:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $80
80106f3c:	6a 50                	push   $0x50
  jmp alltraps
80106f3e:	e9 0f f7 ff ff       	jmp    80106652 <alltraps>

80106f43 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $81
80106f45:	6a 51                	push   $0x51
  jmp alltraps
80106f47:	e9 06 f7 ff ff       	jmp    80106652 <alltraps>

80106f4c <vector82>:
.globl vector82
vector82:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $82
80106f4e:	6a 52                	push   $0x52
  jmp alltraps
80106f50:	e9 fd f6 ff ff       	jmp    80106652 <alltraps>

80106f55 <vector83>:
.globl vector83
vector83:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $83
80106f57:	6a 53                	push   $0x53
  jmp alltraps
80106f59:	e9 f4 f6 ff ff       	jmp    80106652 <alltraps>

80106f5e <vector84>:
.globl vector84
vector84:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $84
80106f60:	6a 54                	push   $0x54
  jmp alltraps
80106f62:	e9 eb f6 ff ff       	jmp    80106652 <alltraps>

80106f67 <vector85>:
.globl vector85
vector85:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $85
80106f69:	6a 55                	push   $0x55
  jmp alltraps
80106f6b:	e9 e2 f6 ff ff       	jmp    80106652 <alltraps>

80106f70 <vector86>:
.globl vector86
vector86:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $86
80106f72:	6a 56                	push   $0x56
  jmp alltraps
80106f74:	e9 d9 f6 ff ff       	jmp    80106652 <alltraps>

80106f79 <vector87>:
.globl vector87
vector87:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $87
80106f7b:	6a 57                	push   $0x57
  jmp alltraps
80106f7d:	e9 d0 f6 ff ff       	jmp    80106652 <alltraps>

80106f82 <vector88>:
.globl vector88
vector88:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $88
80106f84:	6a 58                	push   $0x58
  jmp alltraps
80106f86:	e9 c7 f6 ff ff       	jmp    80106652 <alltraps>

80106f8b <vector89>:
.globl vector89
vector89:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $89
80106f8d:	6a 59                	push   $0x59
  jmp alltraps
80106f8f:	e9 be f6 ff ff       	jmp    80106652 <alltraps>

80106f94 <vector90>:
.globl vector90
vector90:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $90
80106f96:	6a 5a                	push   $0x5a
  jmp alltraps
80106f98:	e9 b5 f6 ff ff       	jmp    80106652 <alltraps>

80106f9d <vector91>:
.globl vector91
vector91:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $91
80106f9f:	6a 5b                	push   $0x5b
  jmp alltraps
80106fa1:	e9 ac f6 ff ff       	jmp    80106652 <alltraps>

80106fa6 <vector92>:
.globl vector92
vector92:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $92
80106fa8:	6a 5c                	push   $0x5c
  jmp alltraps
80106faa:	e9 a3 f6 ff ff       	jmp    80106652 <alltraps>

80106faf <vector93>:
.globl vector93
vector93:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $93
80106fb1:	6a 5d                	push   $0x5d
  jmp alltraps
80106fb3:	e9 9a f6 ff ff       	jmp    80106652 <alltraps>

80106fb8 <vector94>:
.globl vector94
vector94:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $94
80106fba:	6a 5e                	push   $0x5e
  jmp alltraps
80106fbc:	e9 91 f6 ff ff       	jmp    80106652 <alltraps>

80106fc1 <vector95>:
.globl vector95
vector95:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $95
80106fc3:	6a 5f                	push   $0x5f
  jmp alltraps
80106fc5:	e9 88 f6 ff ff       	jmp    80106652 <alltraps>

80106fca <vector96>:
.globl vector96
vector96:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $96
80106fcc:	6a 60                	push   $0x60
  jmp alltraps
80106fce:	e9 7f f6 ff ff       	jmp    80106652 <alltraps>

80106fd3 <vector97>:
.globl vector97
vector97:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $97
80106fd5:	6a 61                	push   $0x61
  jmp alltraps
80106fd7:	e9 76 f6 ff ff       	jmp    80106652 <alltraps>

80106fdc <vector98>:
.globl vector98
vector98:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $98
80106fde:	6a 62                	push   $0x62
  jmp alltraps
80106fe0:	e9 6d f6 ff ff       	jmp    80106652 <alltraps>

80106fe5 <vector99>:
.globl vector99
vector99:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $99
80106fe7:	6a 63                	push   $0x63
  jmp alltraps
80106fe9:	e9 64 f6 ff ff       	jmp    80106652 <alltraps>

80106fee <vector100>:
.globl vector100
vector100:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $100
80106ff0:	6a 64                	push   $0x64
  jmp alltraps
80106ff2:	e9 5b f6 ff ff       	jmp    80106652 <alltraps>

80106ff7 <vector101>:
.globl vector101
vector101:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $101
80106ff9:	6a 65                	push   $0x65
  jmp alltraps
80106ffb:	e9 52 f6 ff ff       	jmp    80106652 <alltraps>

80107000 <vector102>:
.globl vector102
vector102:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $102
80107002:	6a 66                	push   $0x66
  jmp alltraps
80107004:	e9 49 f6 ff ff       	jmp    80106652 <alltraps>

80107009 <vector103>:
.globl vector103
vector103:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $103
8010700b:	6a 67                	push   $0x67
  jmp alltraps
8010700d:	e9 40 f6 ff ff       	jmp    80106652 <alltraps>

80107012 <vector104>:
.globl vector104
vector104:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $104
80107014:	6a 68                	push   $0x68
  jmp alltraps
80107016:	e9 37 f6 ff ff       	jmp    80106652 <alltraps>

8010701b <vector105>:
.globl vector105
vector105:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $105
8010701d:	6a 69                	push   $0x69
  jmp alltraps
8010701f:	e9 2e f6 ff ff       	jmp    80106652 <alltraps>

80107024 <vector106>:
.globl vector106
vector106:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $106
80107026:	6a 6a                	push   $0x6a
  jmp alltraps
80107028:	e9 25 f6 ff ff       	jmp    80106652 <alltraps>

8010702d <vector107>:
.globl vector107
vector107:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $107
8010702f:	6a 6b                	push   $0x6b
  jmp alltraps
80107031:	e9 1c f6 ff ff       	jmp    80106652 <alltraps>

80107036 <vector108>:
.globl vector108
vector108:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $108
80107038:	6a 6c                	push   $0x6c
  jmp alltraps
8010703a:	e9 13 f6 ff ff       	jmp    80106652 <alltraps>

8010703f <vector109>:
.globl vector109
vector109:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $109
80107041:	6a 6d                	push   $0x6d
  jmp alltraps
80107043:	e9 0a f6 ff ff       	jmp    80106652 <alltraps>

80107048 <vector110>:
.globl vector110
vector110:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $110
8010704a:	6a 6e                	push   $0x6e
  jmp alltraps
8010704c:	e9 01 f6 ff ff       	jmp    80106652 <alltraps>

80107051 <vector111>:
.globl vector111
vector111:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $111
80107053:	6a 6f                	push   $0x6f
  jmp alltraps
80107055:	e9 f8 f5 ff ff       	jmp    80106652 <alltraps>

8010705a <vector112>:
.globl vector112
vector112:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $112
8010705c:	6a 70                	push   $0x70
  jmp alltraps
8010705e:	e9 ef f5 ff ff       	jmp    80106652 <alltraps>

80107063 <vector113>:
.globl vector113
vector113:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $113
80107065:	6a 71                	push   $0x71
  jmp alltraps
80107067:	e9 e6 f5 ff ff       	jmp    80106652 <alltraps>

8010706c <vector114>:
.globl vector114
vector114:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $114
8010706e:	6a 72                	push   $0x72
  jmp alltraps
80107070:	e9 dd f5 ff ff       	jmp    80106652 <alltraps>

80107075 <vector115>:
.globl vector115
vector115:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $115
80107077:	6a 73                	push   $0x73
  jmp alltraps
80107079:	e9 d4 f5 ff ff       	jmp    80106652 <alltraps>

8010707e <vector116>:
.globl vector116
vector116:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $116
80107080:	6a 74                	push   $0x74
  jmp alltraps
80107082:	e9 cb f5 ff ff       	jmp    80106652 <alltraps>

80107087 <vector117>:
.globl vector117
vector117:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $117
80107089:	6a 75                	push   $0x75
  jmp alltraps
8010708b:	e9 c2 f5 ff ff       	jmp    80106652 <alltraps>

80107090 <vector118>:
.globl vector118
vector118:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $118
80107092:	6a 76                	push   $0x76
  jmp alltraps
80107094:	e9 b9 f5 ff ff       	jmp    80106652 <alltraps>

80107099 <vector119>:
.globl vector119
vector119:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $119
8010709b:	6a 77                	push   $0x77
  jmp alltraps
8010709d:	e9 b0 f5 ff ff       	jmp    80106652 <alltraps>

801070a2 <vector120>:
.globl vector120
vector120:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $120
801070a4:	6a 78                	push   $0x78
  jmp alltraps
801070a6:	e9 a7 f5 ff ff       	jmp    80106652 <alltraps>

801070ab <vector121>:
.globl vector121
vector121:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $121
801070ad:	6a 79                	push   $0x79
  jmp alltraps
801070af:	e9 9e f5 ff ff       	jmp    80106652 <alltraps>

801070b4 <vector122>:
.globl vector122
vector122:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $122
801070b6:	6a 7a                	push   $0x7a
  jmp alltraps
801070b8:	e9 95 f5 ff ff       	jmp    80106652 <alltraps>

801070bd <vector123>:
.globl vector123
vector123:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $123
801070bf:	6a 7b                	push   $0x7b
  jmp alltraps
801070c1:	e9 8c f5 ff ff       	jmp    80106652 <alltraps>

801070c6 <vector124>:
.globl vector124
vector124:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $124
801070c8:	6a 7c                	push   $0x7c
  jmp alltraps
801070ca:	e9 83 f5 ff ff       	jmp    80106652 <alltraps>

801070cf <vector125>:
.globl vector125
vector125:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $125
801070d1:	6a 7d                	push   $0x7d
  jmp alltraps
801070d3:	e9 7a f5 ff ff       	jmp    80106652 <alltraps>

801070d8 <vector126>:
.globl vector126
vector126:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $126
801070da:	6a 7e                	push   $0x7e
  jmp alltraps
801070dc:	e9 71 f5 ff ff       	jmp    80106652 <alltraps>

801070e1 <vector127>:
.globl vector127
vector127:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $127
801070e3:	6a 7f                	push   $0x7f
  jmp alltraps
801070e5:	e9 68 f5 ff ff       	jmp    80106652 <alltraps>

801070ea <vector128>:
.globl vector128
vector128:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $128
801070ec:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801070f1:	e9 5c f5 ff ff       	jmp    80106652 <alltraps>

801070f6 <vector129>:
.globl vector129
vector129:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $129
801070f8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801070fd:	e9 50 f5 ff ff       	jmp    80106652 <alltraps>

80107102 <vector130>:
.globl vector130
vector130:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $130
80107104:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107109:	e9 44 f5 ff ff       	jmp    80106652 <alltraps>

8010710e <vector131>:
.globl vector131
vector131:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $131
80107110:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107115:	e9 38 f5 ff ff       	jmp    80106652 <alltraps>

8010711a <vector132>:
.globl vector132
vector132:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $132
8010711c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107121:	e9 2c f5 ff ff       	jmp    80106652 <alltraps>

80107126 <vector133>:
.globl vector133
vector133:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $133
80107128:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010712d:	e9 20 f5 ff ff       	jmp    80106652 <alltraps>

80107132 <vector134>:
.globl vector134
vector134:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $134
80107134:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107139:	e9 14 f5 ff ff       	jmp    80106652 <alltraps>

8010713e <vector135>:
.globl vector135
vector135:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $135
80107140:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107145:	e9 08 f5 ff ff       	jmp    80106652 <alltraps>

8010714a <vector136>:
.globl vector136
vector136:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $136
8010714c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107151:	e9 fc f4 ff ff       	jmp    80106652 <alltraps>

80107156 <vector137>:
.globl vector137
vector137:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $137
80107158:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010715d:	e9 f0 f4 ff ff       	jmp    80106652 <alltraps>

80107162 <vector138>:
.globl vector138
vector138:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $138
80107164:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107169:	e9 e4 f4 ff ff       	jmp    80106652 <alltraps>

8010716e <vector139>:
.globl vector139
vector139:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $139
80107170:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107175:	e9 d8 f4 ff ff       	jmp    80106652 <alltraps>

8010717a <vector140>:
.globl vector140
vector140:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $140
8010717c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107181:	e9 cc f4 ff ff       	jmp    80106652 <alltraps>

80107186 <vector141>:
.globl vector141
vector141:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $141
80107188:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010718d:	e9 c0 f4 ff ff       	jmp    80106652 <alltraps>

80107192 <vector142>:
.globl vector142
vector142:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $142
80107194:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107199:	e9 b4 f4 ff ff       	jmp    80106652 <alltraps>

8010719e <vector143>:
.globl vector143
vector143:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $143
801071a0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801071a5:	e9 a8 f4 ff ff       	jmp    80106652 <alltraps>

801071aa <vector144>:
.globl vector144
vector144:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $144
801071ac:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801071b1:	e9 9c f4 ff ff       	jmp    80106652 <alltraps>

801071b6 <vector145>:
.globl vector145
vector145:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $145
801071b8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801071bd:	e9 90 f4 ff ff       	jmp    80106652 <alltraps>

801071c2 <vector146>:
.globl vector146
vector146:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $146
801071c4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801071c9:	e9 84 f4 ff ff       	jmp    80106652 <alltraps>

801071ce <vector147>:
.globl vector147
vector147:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $147
801071d0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801071d5:	e9 78 f4 ff ff       	jmp    80106652 <alltraps>

801071da <vector148>:
.globl vector148
vector148:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $148
801071dc:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801071e1:	e9 6c f4 ff ff       	jmp    80106652 <alltraps>

801071e6 <vector149>:
.globl vector149
vector149:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $149
801071e8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801071ed:	e9 60 f4 ff ff       	jmp    80106652 <alltraps>

801071f2 <vector150>:
.globl vector150
vector150:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $150
801071f4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801071f9:	e9 54 f4 ff ff       	jmp    80106652 <alltraps>

801071fe <vector151>:
.globl vector151
vector151:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $151
80107200:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107205:	e9 48 f4 ff ff       	jmp    80106652 <alltraps>

8010720a <vector152>:
.globl vector152
vector152:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $152
8010720c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107211:	e9 3c f4 ff ff       	jmp    80106652 <alltraps>

80107216 <vector153>:
.globl vector153
vector153:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $153
80107218:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010721d:	e9 30 f4 ff ff       	jmp    80106652 <alltraps>

80107222 <vector154>:
.globl vector154
vector154:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $154
80107224:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107229:	e9 24 f4 ff ff       	jmp    80106652 <alltraps>

8010722e <vector155>:
.globl vector155
vector155:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $155
80107230:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107235:	e9 18 f4 ff ff       	jmp    80106652 <alltraps>

8010723a <vector156>:
.globl vector156
vector156:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $156
8010723c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107241:	e9 0c f4 ff ff       	jmp    80106652 <alltraps>

80107246 <vector157>:
.globl vector157
vector157:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $157
80107248:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010724d:	e9 00 f4 ff ff       	jmp    80106652 <alltraps>

80107252 <vector158>:
.globl vector158
vector158:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $158
80107254:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107259:	e9 f4 f3 ff ff       	jmp    80106652 <alltraps>

8010725e <vector159>:
.globl vector159
vector159:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $159
80107260:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107265:	e9 e8 f3 ff ff       	jmp    80106652 <alltraps>

8010726a <vector160>:
.globl vector160
vector160:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $160
8010726c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107271:	e9 dc f3 ff ff       	jmp    80106652 <alltraps>

80107276 <vector161>:
.globl vector161
vector161:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $161
80107278:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010727d:	e9 d0 f3 ff ff       	jmp    80106652 <alltraps>

80107282 <vector162>:
.globl vector162
vector162:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $162
80107284:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107289:	e9 c4 f3 ff ff       	jmp    80106652 <alltraps>

8010728e <vector163>:
.globl vector163
vector163:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $163
80107290:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107295:	e9 b8 f3 ff ff       	jmp    80106652 <alltraps>

8010729a <vector164>:
.globl vector164
vector164:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $164
8010729c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072a1:	e9 ac f3 ff ff       	jmp    80106652 <alltraps>

801072a6 <vector165>:
.globl vector165
vector165:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $165
801072a8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801072ad:	e9 a0 f3 ff ff       	jmp    80106652 <alltraps>

801072b2 <vector166>:
.globl vector166
vector166:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $166
801072b4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801072b9:	e9 94 f3 ff ff       	jmp    80106652 <alltraps>

801072be <vector167>:
.globl vector167
vector167:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $167
801072c0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801072c5:	e9 88 f3 ff ff       	jmp    80106652 <alltraps>

801072ca <vector168>:
.globl vector168
vector168:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $168
801072cc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801072d1:	e9 7c f3 ff ff       	jmp    80106652 <alltraps>

801072d6 <vector169>:
.globl vector169
vector169:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $169
801072d8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801072dd:	e9 70 f3 ff ff       	jmp    80106652 <alltraps>

801072e2 <vector170>:
.globl vector170
vector170:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $170
801072e4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801072e9:	e9 64 f3 ff ff       	jmp    80106652 <alltraps>

801072ee <vector171>:
.globl vector171
vector171:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $171
801072f0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801072f5:	e9 58 f3 ff ff       	jmp    80106652 <alltraps>

801072fa <vector172>:
.globl vector172
vector172:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $172
801072fc:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107301:	e9 4c f3 ff ff       	jmp    80106652 <alltraps>

80107306 <vector173>:
.globl vector173
vector173:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $173
80107308:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010730d:	e9 40 f3 ff ff       	jmp    80106652 <alltraps>

80107312 <vector174>:
.globl vector174
vector174:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $174
80107314:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107319:	e9 34 f3 ff ff       	jmp    80106652 <alltraps>

8010731e <vector175>:
.globl vector175
vector175:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $175
80107320:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107325:	e9 28 f3 ff ff       	jmp    80106652 <alltraps>

8010732a <vector176>:
.globl vector176
vector176:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $176
8010732c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107331:	e9 1c f3 ff ff       	jmp    80106652 <alltraps>

80107336 <vector177>:
.globl vector177
vector177:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $177
80107338:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010733d:	e9 10 f3 ff ff       	jmp    80106652 <alltraps>

80107342 <vector178>:
.globl vector178
vector178:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $178
80107344:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107349:	e9 04 f3 ff ff       	jmp    80106652 <alltraps>

8010734e <vector179>:
.globl vector179
vector179:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $179
80107350:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107355:	e9 f8 f2 ff ff       	jmp    80106652 <alltraps>

8010735a <vector180>:
.globl vector180
vector180:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $180
8010735c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107361:	e9 ec f2 ff ff       	jmp    80106652 <alltraps>

80107366 <vector181>:
.globl vector181
vector181:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $181
80107368:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010736d:	e9 e0 f2 ff ff       	jmp    80106652 <alltraps>

80107372 <vector182>:
.globl vector182
vector182:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $182
80107374:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107379:	e9 d4 f2 ff ff       	jmp    80106652 <alltraps>

8010737e <vector183>:
.globl vector183
vector183:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $183
80107380:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107385:	e9 c8 f2 ff ff       	jmp    80106652 <alltraps>

8010738a <vector184>:
.globl vector184
vector184:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $184
8010738c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107391:	e9 bc f2 ff ff       	jmp    80106652 <alltraps>

80107396 <vector185>:
.globl vector185
vector185:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $185
80107398:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010739d:	e9 b0 f2 ff ff       	jmp    80106652 <alltraps>

801073a2 <vector186>:
.globl vector186
vector186:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $186
801073a4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801073a9:	e9 a4 f2 ff ff       	jmp    80106652 <alltraps>

801073ae <vector187>:
.globl vector187
vector187:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $187
801073b0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801073b5:	e9 98 f2 ff ff       	jmp    80106652 <alltraps>

801073ba <vector188>:
.globl vector188
vector188:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $188
801073bc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801073c1:	e9 8c f2 ff ff       	jmp    80106652 <alltraps>

801073c6 <vector189>:
.globl vector189
vector189:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $189
801073c8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801073cd:	e9 80 f2 ff ff       	jmp    80106652 <alltraps>

801073d2 <vector190>:
.globl vector190
vector190:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $190
801073d4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801073d9:	e9 74 f2 ff ff       	jmp    80106652 <alltraps>

801073de <vector191>:
.globl vector191
vector191:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $191
801073e0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801073e5:	e9 68 f2 ff ff       	jmp    80106652 <alltraps>

801073ea <vector192>:
.globl vector192
vector192:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $192
801073ec:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801073f1:	e9 5c f2 ff ff       	jmp    80106652 <alltraps>

801073f6 <vector193>:
.globl vector193
vector193:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $193
801073f8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801073fd:	e9 50 f2 ff ff       	jmp    80106652 <alltraps>

80107402 <vector194>:
.globl vector194
vector194:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $194
80107404:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107409:	e9 44 f2 ff ff       	jmp    80106652 <alltraps>

8010740e <vector195>:
.globl vector195
vector195:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $195
80107410:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107415:	e9 38 f2 ff ff       	jmp    80106652 <alltraps>

8010741a <vector196>:
.globl vector196
vector196:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $196
8010741c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107421:	e9 2c f2 ff ff       	jmp    80106652 <alltraps>

80107426 <vector197>:
.globl vector197
vector197:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $197
80107428:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010742d:	e9 20 f2 ff ff       	jmp    80106652 <alltraps>

80107432 <vector198>:
.globl vector198
vector198:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $198
80107434:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107439:	e9 14 f2 ff ff       	jmp    80106652 <alltraps>

8010743e <vector199>:
.globl vector199
vector199:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $199
80107440:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107445:	e9 08 f2 ff ff       	jmp    80106652 <alltraps>

8010744a <vector200>:
.globl vector200
vector200:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $200
8010744c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107451:	e9 fc f1 ff ff       	jmp    80106652 <alltraps>

80107456 <vector201>:
.globl vector201
vector201:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $201
80107458:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010745d:	e9 f0 f1 ff ff       	jmp    80106652 <alltraps>

80107462 <vector202>:
.globl vector202
vector202:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $202
80107464:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107469:	e9 e4 f1 ff ff       	jmp    80106652 <alltraps>

8010746e <vector203>:
.globl vector203
vector203:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $203
80107470:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107475:	e9 d8 f1 ff ff       	jmp    80106652 <alltraps>

8010747a <vector204>:
.globl vector204
vector204:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $204
8010747c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107481:	e9 cc f1 ff ff       	jmp    80106652 <alltraps>

80107486 <vector205>:
.globl vector205
vector205:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $205
80107488:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010748d:	e9 c0 f1 ff ff       	jmp    80106652 <alltraps>

80107492 <vector206>:
.globl vector206
vector206:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $206
80107494:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107499:	e9 b4 f1 ff ff       	jmp    80106652 <alltraps>

8010749e <vector207>:
.globl vector207
vector207:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $207
801074a0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801074a5:	e9 a8 f1 ff ff       	jmp    80106652 <alltraps>

801074aa <vector208>:
.globl vector208
vector208:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $208
801074ac:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801074b1:	e9 9c f1 ff ff       	jmp    80106652 <alltraps>

801074b6 <vector209>:
.globl vector209
vector209:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $209
801074b8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801074bd:	e9 90 f1 ff ff       	jmp    80106652 <alltraps>

801074c2 <vector210>:
.globl vector210
vector210:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $210
801074c4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801074c9:	e9 84 f1 ff ff       	jmp    80106652 <alltraps>

801074ce <vector211>:
.globl vector211
vector211:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $211
801074d0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801074d5:	e9 78 f1 ff ff       	jmp    80106652 <alltraps>

801074da <vector212>:
.globl vector212
vector212:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $212
801074dc:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801074e1:	e9 6c f1 ff ff       	jmp    80106652 <alltraps>

801074e6 <vector213>:
.globl vector213
vector213:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $213
801074e8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801074ed:	e9 60 f1 ff ff       	jmp    80106652 <alltraps>

801074f2 <vector214>:
.globl vector214
vector214:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $214
801074f4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801074f9:	e9 54 f1 ff ff       	jmp    80106652 <alltraps>

801074fe <vector215>:
.globl vector215
vector215:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $215
80107500:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107505:	e9 48 f1 ff ff       	jmp    80106652 <alltraps>

8010750a <vector216>:
.globl vector216
vector216:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $216
8010750c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107511:	e9 3c f1 ff ff       	jmp    80106652 <alltraps>

80107516 <vector217>:
.globl vector217
vector217:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $217
80107518:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010751d:	e9 30 f1 ff ff       	jmp    80106652 <alltraps>

80107522 <vector218>:
.globl vector218
vector218:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $218
80107524:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107529:	e9 24 f1 ff ff       	jmp    80106652 <alltraps>

8010752e <vector219>:
.globl vector219
vector219:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $219
80107530:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107535:	e9 18 f1 ff ff       	jmp    80106652 <alltraps>

8010753a <vector220>:
.globl vector220
vector220:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $220
8010753c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107541:	e9 0c f1 ff ff       	jmp    80106652 <alltraps>

80107546 <vector221>:
.globl vector221
vector221:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $221
80107548:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010754d:	e9 00 f1 ff ff       	jmp    80106652 <alltraps>

80107552 <vector222>:
.globl vector222
vector222:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $222
80107554:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107559:	e9 f4 f0 ff ff       	jmp    80106652 <alltraps>

8010755e <vector223>:
.globl vector223
vector223:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $223
80107560:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107565:	e9 e8 f0 ff ff       	jmp    80106652 <alltraps>

8010756a <vector224>:
.globl vector224
vector224:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $224
8010756c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107571:	e9 dc f0 ff ff       	jmp    80106652 <alltraps>

80107576 <vector225>:
.globl vector225
vector225:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $225
80107578:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010757d:	e9 d0 f0 ff ff       	jmp    80106652 <alltraps>

80107582 <vector226>:
.globl vector226
vector226:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $226
80107584:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107589:	e9 c4 f0 ff ff       	jmp    80106652 <alltraps>

8010758e <vector227>:
.globl vector227
vector227:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $227
80107590:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107595:	e9 b8 f0 ff ff       	jmp    80106652 <alltraps>

8010759a <vector228>:
.globl vector228
vector228:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $228
8010759c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075a1:	e9 ac f0 ff ff       	jmp    80106652 <alltraps>

801075a6 <vector229>:
.globl vector229
vector229:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $229
801075a8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801075ad:	e9 a0 f0 ff ff       	jmp    80106652 <alltraps>

801075b2 <vector230>:
.globl vector230
vector230:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $230
801075b4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801075b9:	e9 94 f0 ff ff       	jmp    80106652 <alltraps>

801075be <vector231>:
.globl vector231
vector231:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $231
801075c0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801075c5:	e9 88 f0 ff ff       	jmp    80106652 <alltraps>

801075ca <vector232>:
.globl vector232
vector232:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $232
801075cc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801075d1:	e9 7c f0 ff ff       	jmp    80106652 <alltraps>

801075d6 <vector233>:
.globl vector233
vector233:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $233
801075d8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801075dd:	e9 70 f0 ff ff       	jmp    80106652 <alltraps>

801075e2 <vector234>:
.globl vector234
vector234:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $234
801075e4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801075e9:	e9 64 f0 ff ff       	jmp    80106652 <alltraps>

801075ee <vector235>:
.globl vector235
vector235:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $235
801075f0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801075f5:	e9 58 f0 ff ff       	jmp    80106652 <alltraps>

801075fa <vector236>:
.globl vector236
vector236:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $236
801075fc:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107601:	e9 4c f0 ff ff       	jmp    80106652 <alltraps>

80107606 <vector237>:
.globl vector237
vector237:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $237
80107608:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010760d:	e9 40 f0 ff ff       	jmp    80106652 <alltraps>

80107612 <vector238>:
.globl vector238
vector238:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $238
80107614:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107619:	e9 34 f0 ff ff       	jmp    80106652 <alltraps>

8010761e <vector239>:
.globl vector239
vector239:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $239
80107620:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107625:	e9 28 f0 ff ff       	jmp    80106652 <alltraps>

8010762a <vector240>:
.globl vector240
vector240:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $240
8010762c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107631:	e9 1c f0 ff ff       	jmp    80106652 <alltraps>

80107636 <vector241>:
.globl vector241
vector241:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $241
80107638:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010763d:	e9 10 f0 ff ff       	jmp    80106652 <alltraps>

80107642 <vector242>:
.globl vector242
vector242:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $242
80107644:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107649:	e9 04 f0 ff ff       	jmp    80106652 <alltraps>

8010764e <vector243>:
.globl vector243
vector243:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $243
80107650:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107655:	e9 f8 ef ff ff       	jmp    80106652 <alltraps>

8010765a <vector244>:
.globl vector244
vector244:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $244
8010765c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107661:	e9 ec ef ff ff       	jmp    80106652 <alltraps>

80107666 <vector245>:
.globl vector245
vector245:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $245
80107668:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010766d:	e9 e0 ef ff ff       	jmp    80106652 <alltraps>

80107672 <vector246>:
.globl vector246
vector246:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $246
80107674:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107679:	e9 d4 ef ff ff       	jmp    80106652 <alltraps>

8010767e <vector247>:
.globl vector247
vector247:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $247
80107680:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107685:	e9 c8 ef ff ff       	jmp    80106652 <alltraps>

8010768a <vector248>:
.globl vector248
vector248:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $248
8010768c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107691:	e9 bc ef ff ff       	jmp    80106652 <alltraps>

80107696 <vector249>:
.globl vector249
vector249:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $249
80107698:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010769d:	e9 b0 ef ff ff       	jmp    80106652 <alltraps>

801076a2 <vector250>:
.globl vector250
vector250:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $250
801076a4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801076a9:	e9 a4 ef ff ff       	jmp    80106652 <alltraps>

801076ae <vector251>:
.globl vector251
vector251:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $251
801076b0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801076b5:	e9 98 ef ff ff       	jmp    80106652 <alltraps>

801076ba <vector252>:
.globl vector252
vector252:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $252
801076bc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801076c1:	e9 8c ef ff ff       	jmp    80106652 <alltraps>

801076c6 <vector253>:
.globl vector253
vector253:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $253
801076c8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801076cd:	e9 80 ef ff ff       	jmp    80106652 <alltraps>

801076d2 <vector254>:
.globl vector254
vector254:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $254
801076d4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801076d9:	e9 74 ef ff ff       	jmp    80106652 <alltraps>

801076de <vector255>:
.globl vector255
vector255:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $255
801076e0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801076e5:	e9 68 ef ff ff       	jmp    80106652 <alltraps>

801076ea <lgdt>:
{
801076ea:	55                   	push   %ebp
801076eb:	89 e5                	mov    %esp,%ebp
801076ed:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801076f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801076f3:	83 e8 01             	sub    $0x1,%eax
801076f6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801076fa:	8b 45 08             	mov    0x8(%ebp),%eax
801076fd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107701:	8b 45 08             	mov    0x8(%ebp),%eax
80107704:	c1 e8 10             	shr    $0x10,%eax
80107707:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010770b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010770e:	0f 01 10             	lgdtl  (%eax)
}
80107711:	90                   	nop
80107712:	c9                   	leave  
80107713:	c3                   	ret    

80107714 <ltr>:
{
80107714:	55                   	push   %ebp
80107715:	89 e5                	mov    %esp,%ebp
80107717:	83 ec 04             	sub    $0x4,%esp
8010771a:	8b 45 08             	mov    0x8(%ebp),%eax
8010771d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107721:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107725:	0f 00 d8             	ltr    %ax
}
80107728:	90                   	nop
80107729:	c9                   	leave  
8010772a:	c3                   	ret    

8010772b <lcr3>:

static inline void
lcr3(uint val)
{
8010772b:	55                   	push   %ebp
8010772c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010772e:	8b 45 08             	mov    0x8(%ebp),%eax
80107731:	0f 22 d8             	mov    %eax,%cr3
}
80107734:	90                   	nop
80107735:	5d                   	pop    %ebp
80107736:	c3                   	ret    

80107737 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107737:	55                   	push   %ebp
80107738:	89 e5                	mov    %esp,%ebp
8010773a:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010773d:	e8 82 cb ff ff       	call   801042c4 <cpuid>
80107742:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107748:	05 c0 27 11 80       	add    $0x801127c0,%eax
8010774d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107765:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107770:	83 e2 f0             	and    $0xfffffff0,%edx
80107773:	83 ca 0a             	or     $0xa,%edx
80107776:	88 50 7d             	mov    %dl,0x7d(%eax)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107780:	83 ca 10             	or     $0x10,%edx
80107783:	88 50 7d             	mov    %dl,0x7d(%eax)
80107786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107789:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010778d:	83 e2 9f             	and    $0xffffff9f,%edx
80107790:	88 50 7d             	mov    %dl,0x7d(%eax)
80107793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107796:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010779a:	83 ca 80             	or     $0xffffff80,%edx
8010779d:	88 50 7d             	mov    %dl,0x7d(%eax)
801077a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077a7:	83 ca 0f             	or     $0xf,%edx
801077aa:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077b4:	83 e2 ef             	and    $0xffffffef,%edx
801077b7:	88 50 7e             	mov    %dl,0x7e(%eax)
801077ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077c1:	83 e2 df             	and    $0xffffffdf,%edx
801077c4:	88 50 7e             	mov    %dl,0x7e(%eax)
801077c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077ce:	83 ca 40             	or     $0x40,%edx
801077d1:	88 50 7e             	mov    %dl,0x7e(%eax)
801077d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801077db:	83 ca 80             	or     $0xffffff80,%edx
801077de:	88 50 7e             	mov    %dl,0x7e(%eax)
801077e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e4:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801077e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077eb:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801077f2:	ff ff 
801077f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f7:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801077fe:	00 00 
80107800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107803:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010780a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107814:	83 e2 f0             	and    $0xfffffff0,%edx
80107817:	83 ca 02             	or     $0x2,%edx
8010781a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107823:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010782a:	83 ca 10             	or     $0x10,%edx
8010782d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107836:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010783d:	83 e2 9f             	and    $0xffffff9f,%edx
80107840:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107849:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107850:	83 ca 80             	or     $0xffffff80,%edx
80107853:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107863:	83 ca 0f             	or     $0xf,%edx
80107866:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010786c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107876:	83 e2 ef             	and    $0xffffffef,%edx
80107879:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107889:	83 e2 df             	and    $0xffffffdf,%edx
8010788c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010789c:	83 ca 40             	or     $0x40,%edx
8010789f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078af:	83 ca 80             	or     $0xffffff80,%edx
801078b2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801078c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c5:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801078cc:	ff ff 
801078ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d1:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801078d8:	00 00 
801078da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078dd:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801078e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801078ee:	83 e2 f0             	and    $0xfffffff0,%edx
801078f1:	83 ca 0a             	or     $0xa,%edx
801078f4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801078fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107904:	83 ca 10             	or     $0x10,%edx
80107907:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010790d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107910:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107917:	83 ca 60             	or     $0x60,%edx
8010791a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107923:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010792a:	83 ca 80             	or     $0xffffff80,%edx
8010792d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107936:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010793d:	83 ca 0f             	or     $0xf,%edx
80107940:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107949:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107950:	83 e2 ef             	and    $0xffffffef,%edx
80107953:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107963:	83 e2 df             	and    $0xffffffdf,%edx
80107966:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010796c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107976:	83 ca 40             	or     $0x40,%edx
80107979:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010797f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107982:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107989:	83 ca 80             	or     $0xffffff80,%edx
8010798c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010799c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799f:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801079a6:	ff ff 
801079a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ab:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801079b2:	00 00 
801079b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b7:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079c8:	83 e2 f0             	and    $0xfffffff0,%edx
801079cb:	83 ca 02             	or     $0x2,%edx
801079ce:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079de:	83 ca 10             	or     $0x10,%edx
801079e1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079f1:	83 ca 60             	or     $0x60,%edx
801079f4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a04:	83 ca 80             	or     $0xffffff80,%edx
80107a07:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a10:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a17:	83 ca 0f             	or     $0xf,%edx
80107a1a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a23:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a2a:	83 e2 ef             	and    $0xffffffef,%edx
80107a2d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a36:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a3d:	83 e2 df             	and    $0xffffffdf,%edx
80107a40:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a49:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a50:	83 ca 40             	or     $0x40,%edx
80107a53:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a63:	83 ca 80             	or     $0xffffff80,%edx
80107a66:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a79:	83 c0 70             	add    $0x70,%eax
80107a7c:	83 ec 08             	sub    $0x8,%esp
80107a7f:	6a 30                	push   $0x30
80107a81:	50                   	push   %eax
80107a82:	e8 63 fc ff ff       	call   801076ea <lgdt>
80107a87:	83 c4 10             	add    $0x10,%esp
}
80107a8a:	90                   	nop
80107a8b:	c9                   	leave  
80107a8c:	c3                   	ret    

80107a8d <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a8d:	55                   	push   %ebp
80107a8e:	89 e5                	mov    %esp,%ebp
80107a90:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107a93:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a96:	c1 e8 16             	shr    $0x16,%eax
80107a99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80107aa3:	01 d0                	add    %edx,%eax
80107aa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aab:	8b 00                	mov    (%eax),%eax
80107aad:	83 e0 01             	and    $0x1,%eax
80107ab0:	85 c0                	test   %eax,%eax
80107ab2:	74 14                	je     80107ac8 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ab7:	8b 00                	mov    (%eax),%eax
80107ab9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107abe:	05 00 00 00 80       	add    $0x80000000,%eax
80107ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ac6:	eb 42                	jmp    80107b0a <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ac8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107acc:	74 0e                	je     80107adc <walkpgdir+0x4f>
80107ace:	e8 81 b2 ff ff       	call   80102d54 <kalloc>
80107ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ad6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ada:	75 07                	jne    80107ae3 <walkpgdir+0x56>
      return 0;
80107adc:	b8 00 00 00 00       	mov    $0x0,%eax
80107ae1:	eb 3e                	jmp    80107b21 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ae3:	83 ec 04             	sub    $0x4,%esp
80107ae6:	68 00 10 00 00       	push   $0x1000
80107aeb:	6a 00                	push   $0x0
80107aed:	ff 75 f4             	push   -0xc(%ebp)
80107af0:	e8 ee d7 ff ff       	call   801052e3 <memset>
80107af5:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	05 00 00 00 80       	add    $0x80000000,%eax
80107b00:	83 c8 07             	or     $0x7,%eax
80107b03:	89 c2                	mov    %eax,%edx
80107b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b08:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b0d:	c1 e8 0c             	shr    $0xc,%eax
80107b10:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1f:	01 d0                	add    %edx,%eax
}
80107b21:	c9                   	leave  
80107b22:	c3                   	ret    

80107b23 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b23:	55                   	push   %ebp
80107b24:	89 e5                	mov    %esp,%ebp
80107b26:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b29:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107b34:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b37:	8b 45 10             	mov    0x10(%ebp),%eax
80107b3a:	01 d0                	add    %edx,%eax
80107b3c:	83 e8 01             	sub    $0x1,%eax
80107b3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107b47:	83 ec 04             	sub    $0x4,%esp
80107b4a:	6a 01                	push   $0x1
80107b4c:	ff 75 f4             	push   -0xc(%ebp)
80107b4f:	ff 75 08             	push   0x8(%ebp)
80107b52:	e8 36 ff ff ff       	call   80107a8d <walkpgdir>
80107b57:	83 c4 10             	add    $0x10,%esp
80107b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b61:	75 07                	jne    80107b6a <mappages+0x47>
      return -1;
80107b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b68:	eb 47                	jmp    80107bb1 <mappages+0x8e>
    if(*pte & PTE_P)
80107b6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b6d:	8b 00                	mov    (%eax),%eax
80107b6f:	83 e0 01             	and    $0x1,%eax
80107b72:	85 c0                	test   %eax,%eax
80107b74:	74 0d                	je     80107b83 <mappages+0x60>
      panic("remap");
80107b76:	83 ec 0c             	sub    $0xc,%esp
80107b79:	68 e4 8a 10 80       	push   $0x80108ae4
80107b7e:	e8 32 8a ff ff       	call   801005b5 <panic>
    *pte = pa | perm | PTE_P;
80107b83:	8b 45 18             	mov    0x18(%ebp),%eax
80107b86:	0b 45 14             	or     0x14(%ebp),%eax
80107b89:	83 c8 01             	or     $0x1,%eax
80107b8c:	89 c2                	mov    %eax,%edx
80107b8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b91:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b96:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107b99:	74 10                	je     80107bab <mappages+0x88>
      break;
    a += PGSIZE;
80107b9b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ba2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ba9:	eb 9c                	jmp    80107b47 <mappages+0x24>
      break;
80107bab:	90                   	nop
  }
  return 0;
80107bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bb1:	c9                   	leave  
80107bb2:	c3                   	ret    

80107bb3 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107bb3:	55                   	push   %ebp
80107bb4:	89 e5                	mov    %esp,%ebp
80107bb6:	53                   	push   %ebx
80107bb7:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107bba:	e8 95 b1 ff ff       	call   80102d54 <kalloc>
80107bbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bc6:	75 07                	jne    80107bcf <setupkvm+0x1c>
    return 0;
80107bc8:	b8 00 00 00 00       	mov    $0x0,%eax
80107bcd:	eb 78                	jmp    80107c47 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107bcf:	83 ec 04             	sub    $0x4,%esp
80107bd2:	68 00 10 00 00       	push   $0x1000
80107bd7:	6a 00                	push   $0x0
80107bd9:	ff 75 f0             	push   -0x10(%ebp)
80107bdc:	e8 02 d7 ff ff       	call   801052e3 <memset>
80107be1:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107be4:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107beb:	eb 4e                	jmp    80107c3b <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf6:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	8b 58 08             	mov    0x8(%eax),%ebx
80107bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c02:	8b 40 04             	mov    0x4(%eax),%eax
80107c05:	29 c3                	sub    %eax,%ebx
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	8b 00                	mov    (%eax),%eax
80107c0c:	83 ec 0c             	sub    $0xc,%esp
80107c0f:	51                   	push   %ecx
80107c10:	52                   	push   %edx
80107c11:	53                   	push   %ebx
80107c12:	50                   	push   %eax
80107c13:	ff 75 f0             	push   -0x10(%ebp)
80107c16:	e8 08 ff ff ff       	call   80107b23 <mappages>
80107c1b:	83 c4 20             	add    $0x20,%esp
80107c1e:	85 c0                	test   %eax,%eax
80107c20:	79 15                	jns    80107c37 <setupkvm+0x84>
      freevm(pgdir);
80107c22:	83 ec 0c             	sub    $0xc,%esp
80107c25:	ff 75 f0             	push   -0x10(%ebp)
80107c28:	e8 f5 04 00 00       	call   80108122 <freevm>
80107c2d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c30:	b8 00 00 00 00       	mov    $0x0,%eax
80107c35:	eb 10                	jmp    80107c47 <setupkvm+0x94>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c37:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107c3b:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107c42:	72 a9                	jb     80107bed <setupkvm+0x3a>
    }
  return pgdir;
80107c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c4a:	c9                   	leave  
80107c4b:	c3                   	ret    

80107c4c <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c4c:	55                   	push   %ebp
80107c4d:	89 e5                	mov    %esp,%ebp
80107c4f:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c52:	e8 5c ff ff ff       	call   80107bb3 <setupkvm>
80107c57:	a3 dc 55 11 80       	mov    %eax,0x801155dc
  switchkvm();
80107c5c:	e8 03 00 00 00       	call   80107c64 <switchkvm>
}
80107c61:	90                   	nop
80107c62:	c9                   	leave  
80107c63:	c3                   	ret    

80107c64 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c64:	55                   	push   %ebp
80107c65:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107c67:	a1 dc 55 11 80       	mov    0x801155dc,%eax
80107c6c:	05 00 00 00 80       	add    $0x80000000,%eax
80107c71:	50                   	push   %eax
80107c72:	e8 b4 fa ff ff       	call   8010772b <lcr3>
80107c77:	83 c4 04             	add    $0x4,%esp
}
80107c7a:	90                   	nop
80107c7b:	c9                   	leave  
80107c7c:	c3                   	ret    

80107c7d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c7d:	55                   	push   %ebp
80107c7e:	89 e5                	mov    %esp,%ebp
80107c80:	56                   	push   %esi
80107c81:	53                   	push   %ebx
80107c82:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107c85:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c89:	75 0d                	jne    80107c98 <switchuvm+0x1b>
    panic("switchuvm: no process");
80107c8b:	83 ec 0c             	sub    $0xc,%esp
80107c8e:	68 ea 8a 10 80       	push   $0x80108aea
80107c93:	e8 1d 89 ff ff       	call   801005b5 <panic>
  if(p->kstack == 0)
80107c98:	8b 45 08             	mov    0x8(%ebp),%eax
80107c9b:	8b 40 08             	mov    0x8(%eax),%eax
80107c9e:	85 c0                	test   %eax,%eax
80107ca0:	75 0d                	jne    80107caf <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107ca2:	83 ec 0c             	sub    $0xc,%esp
80107ca5:	68 00 8b 10 80       	push   $0x80108b00
80107caa:	e8 06 89 ff ff       	call   801005b5 <panic>
  if(p->pgdir == 0)
80107caf:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb2:	8b 40 04             	mov    0x4(%eax),%eax
80107cb5:	85 c0                	test   %eax,%eax
80107cb7:	75 0d                	jne    80107cc6 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107cb9:	83 ec 0c             	sub    $0xc,%esp
80107cbc:	68 15 8b 10 80       	push   $0x80108b15
80107cc1:	e8 ef 88 ff ff       	call   801005b5 <panic>

  pushcli();
80107cc6:	e8 0d d5 ff ff       	call   801051d8 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ccb:	e8 0f c6 ff ff       	call   801042df <mycpu>
80107cd0:	89 c3                	mov    %eax,%ebx
80107cd2:	e8 08 c6 ff ff       	call   801042df <mycpu>
80107cd7:	83 c0 08             	add    $0x8,%eax
80107cda:	89 c6                	mov    %eax,%esi
80107cdc:	e8 fe c5 ff ff       	call   801042df <mycpu>
80107ce1:	83 c0 08             	add    $0x8,%eax
80107ce4:	c1 e8 10             	shr    $0x10,%eax
80107ce7:	88 45 f7             	mov    %al,-0x9(%ebp)
80107cea:	e8 f0 c5 ff ff       	call   801042df <mycpu>
80107cef:	83 c0 08             	add    $0x8,%eax
80107cf2:	c1 e8 18             	shr    $0x18,%eax
80107cf5:	89 c2                	mov    %eax,%edx
80107cf7:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107cfe:	67 00 
80107d00:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107d07:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107d0b:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107d11:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d18:	83 e0 f0             	and    $0xfffffff0,%eax
80107d1b:	83 c8 09             	or     $0x9,%eax
80107d1e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d24:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d2b:	83 c8 10             	or     $0x10,%eax
80107d2e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d34:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d3b:	83 e0 9f             	and    $0xffffff9f,%eax
80107d3e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d44:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107d4b:	83 c8 80             	or     $0xffffff80,%eax
80107d4e:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107d54:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d5b:	83 e0 f0             	and    $0xfffffff0,%eax
80107d5e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d64:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d6b:	83 e0 ef             	and    $0xffffffef,%eax
80107d6e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d74:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d7b:	83 e0 df             	and    $0xffffffdf,%eax
80107d7e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d84:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d8b:	83 c8 40             	or     $0x40,%eax
80107d8e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107d94:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107d9b:	83 e0 7f             	and    $0x7f,%eax
80107d9e:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107da4:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107daa:	e8 30 c5 ff ff       	call   801042df <mycpu>
80107daf:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107db6:	83 e2 ef             	and    $0xffffffef,%edx
80107db9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107dbf:	e8 1b c5 ff ff       	call   801042df <mycpu>
80107dc4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107dca:	8b 45 08             	mov    0x8(%ebp),%eax
80107dcd:	8b 40 08             	mov    0x8(%eax),%eax
80107dd0:	89 c3                	mov    %eax,%ebx
80107dd2:	e8 08 c5 ff ff       	call   801042df <mycpu>
80107dd7:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107ddd:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107de0:	e8 fa c4 ff ff       	call   801042df <mycpu>
80107de5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107deb:	83 ec 0c             	sub    $0xc,%esp
80107dee:	6a 28                	push   $0x28
80107df0:	e8 1f f9 ff ff       	call   80107714 <ltr>
80107df5:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107df8:	8b 45 08             	mov    0x8(%ebp),%eax
80107dfb:	8b 40 04             	mov    0x4(%eax),%eax
80107dfe:	05 00 00 00 80       	add    $0x80000000,%eax
80107e03:	83 ec 0c             	sub    $0xc,%esp
80107e06:	50                   	push   %eax
80107e07:	e8 1f f9 ff ff       	call   8010772b <lcr3>
80107e0c:	83 c4 10             	add    $0x10,%esp
  popcli();
80107e0f:	e8 11 d4 ff ff       	call   80105225 <popcli>
}
80107e14:	90                   	nop
80107e15:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107e18:	5b                   	pop    %ebx
80107e19:	5e                   	pop    %esi
80107e1a:	5d                   	pop    %ebp
80107e1b:	c3                   	ret    

80107e1c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e1c:	55                   	push   %ebp
80107e1d:	89 e5                	mov    %esp,%ebp
80107e1f:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107e22:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e29:	76 0d                	jbe    80107e38 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107e2b:	83 ec 0c             	sub    $0xc,%esp
80107e2e:	68 29 8b 10 80       	push   $0x80108b29
80107e33:	e8 7d 87 ff ff       	call   801005b5 <panic>
  mem = kalloc();
80107e38:	e8 17 af ff ff       	call   80102d54 <kalloc>
80107e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107e40:	83 ec 04             	sub    $0x4,%esp
80107e43:	68 00 10 00 00       	push   $0x1000
80107e48:	6a 00                	push   $0x0
80107e4a:	ff 75 f4             	push   -0xc(%ebp)
80107e4d:	e8 91 d4 ff ff       	call   801052e3 <memset>
80107e52:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	05 00 00 00 80       	add    $0x80000000,%eax
80107e5d:	83 ec 0c             	sub    $0xc,%esp
80107e60:	6a 06                	push   $0x6
80107e62:	50                   	push   %eax
80107e63:	68 00 10 00 00       	push   $0x1000
80107e68:	6a 00                	push   $0x0
80107e6a:	ff 75 08             	push   0x8(%ebp)
80107e6d:	e8 b1 fc ff ff       	call   80107b23 <mappages>
80107e72:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107e75:	83 ec 04             	sub    $0x4,%esp
80107e78:	ff 75 10             	push   0x10(%ebp)
80107e7b:	ff 75 0c             	push   0xc(%ebp)
80107e7e:	ff 75 f4             	push   -0xc(%ebp)
80107e81:	e8 1c d5 ff ff       	call   801053a2 <memmove>
80107e86:	83 c4 10             	add    $0x10,%esp
}
80107e89:	90                   	nop
80107e8a:	c9                   	leave  
80107e8b:	c3                   	ret    

80107e8c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e8c:	55                   	push   %ebp
80107e8d:	89 e5                	mov    %esp,%ebp
80107e8f:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107e92:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e95:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e9a:	85 c0                	test   %eax,%eax
80107e9c:	74 0d                	je     80107eab <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107e9e:	83 ec 0c             	sub    $0xc,%esp
80107ea1:	68 44 8b 10 80       	push   $0x80108b44
80107ea6:	e8 0a 87 ff ff       	call   801005b5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107eab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107eb2:	e9 8f 00 00 00       	jmp    80107f46 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107eb7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	01 d0                	add    %edx,%eax
80107ebf:	83 ec 04             	sub    $0x4,%esp
80107ec2:	6a 00                	push   $0x0
80107ec4:	50                   	push   %eax
80107ec5:	ff 75 08             	push   0x8(%ebp)
80107ec8:	e8 c0 fb ff ff       	call   80107a8d <walkpgdir>
80107ecd:	83 c4 10             	add    $0x10,%esp
80107ed0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ed3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ed7:	75 0d                	jne    80107ee6 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107ed9:	83 ec 0c             	sub    $0xc,%esp
80107edc:	68 67 8b 10 80       	push   $0x80108b67
80107ee1:	e8 cf 86 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
80107ee6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee9:	8b 00                	mov    (%eax),%eax
80107eeb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ef3:	8b 45 18             	mov    0x18(%ebp),%eax
80107ef6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ef9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107efe:	77 0b                	ja     80107f0b <loaduvm+0x7f>
      n = sz - i;
80107f00:	8b 45 18             	mov    0x18(%ebp),%eax
80107f03:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f09:	eb 07                	jmp    80107f12 <loaduvm+0x86>
    else
      n = PGSIZE;
80107f0b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107f12:	8b 55 14             	mov    0x14(%ebp),%edx
80107f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f18:	01 d0                	add    %edx,%eax
80107f1a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f1d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107f23:	ff 75 f0             	push   -0x10(%ebp)
80107f26:	50                   	push   %eax
80107f27:	52                   	push   %edx
80107f28:	ff 75 10             	push   0x10(%ebp)
80107f2b:	e8 94 a0 ff ff       	call   80101fc4 <readi>
80107f30:	83 c4 10             	add    $0x10,%esp
80107f33:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107f36:	74 07                	je     80107f3f <loaduvm+0xb3>
      return -1;
80107f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f3d:	eb 18                	jmp    80107f57 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107f3f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f49:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f4c:	0f 82 65 ff ff ff    	jb     80107eb7 <loaduvm+0x2b>
  }
  return 0;
80107f52:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f57:	c9                   	leave  
80107f58:	c3                   	ret    

80107f59 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f59:	55                   	push   %ebp
80107f5a:	89 e5                	mov    %esp,%ebp
80107f5c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f5f:	8b 45 10             	mov    0x10(%ebp),%eax
80107f62:	85 c0                	test   %eax,%eax
80107f64:	79 0a                	jns    80107f70 <allocuvm+0x17>
    return 0;
80107f66:	b8 00 00 00 00       	mov    $0x0,%eax
80107f6b:	e9 ec 00 00 00       	jmp    8010805c <allocuvm+0x103>
  if(newsz < oldsz)
80107f70:	8b 45 10             	mov    0x10(%ebp),%eax
80107f73:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f76:	73 08                	jae    80107f80 <allocuvm+0x27>
    return oldsz;
80107f78:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f7b:	e9 dc 00 00 00       	jmp    8010805c <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f83:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107f90:	e9 b8 00 00 00       	jmp    8010804d <allocuvm+0xf4>
    mem = kalloc();
80107f95:	e8 ba ad ff ff       	call   80102d54 <kalloc>
80107f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107f9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fa1:	75 2e                	jne    80107fd1 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107fa3:	83 ec 0c             	sub    $0xc,%esp
80107fa6:	68 85 8b 10 80       	push   $0x80108b85
80107fab:	e8 50 84 ff ff       	call   80100400 <cprintf>
80107fb0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107fb3:	83 ec 04             	sub    $0x4,%esp
80107fb6:	ff 75 0c             	push   0xc(%ebp)
80107fb9:	ff 75 10             	push   0x10(%ebp)
80107fbc:	ff 75 08             	push   0x8(%ebp)
80107fbf:	e8 9a 00 00 00       	call   8010805e <deallocuvm>
80107fc4:	83 c4 10             	add    $0x10,%esp
      return 0;
80107fc7:	b8 00 00 00 00       	mov    $0x0,%eax
80107fcc:	e9 8b 00 00 00       	jmp    8010805c <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107fd1:	83 ec 04             	sub    $0x4,%esp
80107fd4:	68 00 10 00 00       	push   $0x1000
80107fd9:	6a 00                	push   $0x0
80107fdb:	ff 75 f0             	push   -0x10(%ebp)
80107fde:	e8 00 d3 ff ff       	call   801052e3 <memset>
80107fe3:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fe9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff2:	83 ec 0c             	sub    $0xc,%esp
80107ff5:	6a 06                	push   $0x6
80107ff7:	52                   	push   %edx
80107ff8:	68 00 10 00 00       	push   $0x1000
80107ffd:	50                   	push   %eax
80107ffe:	ff 75 08             	push   0x8(%ebp)
80108001:	e8 1d fb ff ff       	call   80107b23 <mappages>
80108006:	83 c4 20             	add    $0x20,%esp
80108009:	85 c0                	test   %eax,%eax
8010800b:	79 39                	jns    80108046 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
8010800d:	83 ec 0c             	sub    $0xc,%esp
80108010:	68 9d 8b 10 80       	push   $0x80108b9d
80108015:	e8 e6 83 ff ff       	call   80100400 <cprintf>
8010801a:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010801d:	83 ec 04             	sub    $0x4,%esp
80108020:	ff 75 0c             	push   0xc(%ebp)
80108023:	ff 75 10             	push   0x10(%ebp)
80108026:	ff 75 08             	push   0x8(%ebp)
80108029:	e8 30 00 00 00       	call   8010805e <deallocuvm>
8010802e:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108031:	83 ec 0c             	sub    $0xc,%esp
80108034:	ff 75 f0             	push   -0x10(%ebp)
80108037:	e8 7e ac ff ff       	call   80102cba <kfree>
8010803c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010803f:	b8 00 00 00 00       	mov    $0x0,%eax
80108044:	eb 16                	jmp    8010805c <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80108046:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010804d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108050:	3b 45 10             	cmp    0x10(%ebp),%eax
80108053:	0f 82 3c ff ff ff    	jb     80107f95 <allocuvm+0x3c>
    }
  }
  return newsz;
80108059:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010805c:	c9                   	leave  
8010805d:	c3                   	ret    

8010805e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010805e:	55                   	push   %ebp
8010805f:	89 e5                	mov    %esp,%ebp
80108061:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108064:	8b 45 10             	mov    0x10(%ebp),%eax
80108067:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010806a:	72 08                	jb     80108074 <deallocuvm+0x16>
    return oldsz;
8010806c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010806f:	e9 ac 00 00 00       	jmp    80108120 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108074:	8b 45 10             	mov    0x10(%ebp),%eax
80108077:	05 ff 0f 00 00       	add    $0xfff,%eax
8010807c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108084:	e9 88 00 00 00       	jmp    80108111 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808c:	83 ec 04             	sub    $0x4,%esp
8010808f:	6a 00                	push   $0x0
80108091:	50                   	push   %eax
80108092:	ff 75 08             	push   0x8(%ebp)
80108095:	e8 f3 f9 ff ff       	call   80107a8d <walkpgdir>
8010809a:	83 c4 10             	add    $0x10,%esp
8010809d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801080a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080a4:	75 16                	jne    801080bc <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a9:	c1 e8 16             	shr    $0x16,%eax
801080ac:	83 c0 01             	add    $0x1,%eax
801080af:	c1 e0 16             	shl    $0x16,%eax
801080b2:	2d 00 10 00 00       	sub    $0x1000,%eax
801080b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801080ba:	eb 4e                	jmp    8010810a <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801080bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bf:	8b 00                	mov    (%eax),%eax
801080c1:	83 e0 01             	and    $0x1,%eax
801080c4:	85 c0                	test   %eax,%eax
801080c6:	74 42                	je     8010810a <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801080c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080cb:	8b 00                	mov    (%eax),%eax
801080cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801080d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080d9:	75 0d                	jne    801080e8 <deallocuvm+0x8a>
        panic("kfree");
801080db:	83 ec 0c             	sub    $0xc,%esp
801080de:	68 b9 8b 10 80       	push   $0x80108bb9
801080e3:	e8 cd 84 ff ff       	call   801005b5 <panic>
      char *v = P2V(pa);
801080e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080eb:	05 00 00 00 80       	add    $0x80000000,%eax
801080f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801080f3:	83 ec 0c             	sub    $0xc,%esp
801080f6:	ff 75 e8             	push   -0x18(%ebp)
801080f9:	e8 bc ab ff ff       	call   80102cba <kfree>
801080fe:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108101:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108104:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010810a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108114:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108117:	0f 82 6c ff ff ff    	jb     80108089 <deallocuvm+0x2b>
    }
  }
  return newsz;
8010811d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108120:	c9                   	leave  
80108121:	c3                   	ret    

80108122 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108122:	55                   	push   %ebp
80108123:	89 e5                	mov    %esp,%ebp
80108125:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108128:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010812c:	75 0d                	jne    8010813b <freevm+0x19>
    panic("freevm: no pgdir");
8010812e:	83 ec 0c             	sub    $0xc,%esp
80108131:	68 bf 8b 10 80       	push   $0x80108bbf
80108136:	e8 7a 84 ff ff       	call   801005b5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010813b:	83 ec 04             	sub    $0x4,%esp
8010813e:	6a 00                	push   $0x0
80108140:	68 00 00 00 80       	push   $0x80000000
80108145:	ff 75 08             	push   0x8(%ebp)
80108148:	e8 11 ff ff ff       	call   8010805e <deallocuvm>
8010814d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108150:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108157:	eb 48                	jmp    801081a1 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80108159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108163:	8b 45 08             	mov    0x8(%ebp),%eax
80108166:	01 d0                	add    %edx,%eax
80108168:	8b 00                	mov    (%eax),%eax
8010816a:	83 e0 01             	and    $0x1,%eax
8010816d:	85 c0                	test   %eax,%eax
8010816f:	74 2c                	je     8010819d <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010817b:	8b 45 08             	mov    0x8(%ebp),%eax
8010817e:	01 d0                	add    %edx,%eax
80108180:	8b 00                	mov    (%eax),%eax
80108182:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108187:	05 00 00 00 80       	add    $0x80000000,%eax
8010818c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010818f:	83 ec 0c             	sub    $0xc,%esp
80108192:	ff 75 f0             	push   -0x10(%ebp)
80108195:	e8 20 ab ff ff       	call   80102cba <kfree>
8010819a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010819d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801081a1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801081a8:	76 af                	jbe    80108159 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801081aa:	83 ec 0c             	sub    $0xc,%esp
801081ad:	ff 75 08             	push   0x8(%ebp)
801081b0:	e8 05 ab ff ff       	call   80102cba <kfree>
801081b5:	83 c4 10             	add    $0x10,%esp
}
801081b8:	90                   	nop
801081b9:	c9                   	leave  
801081ba:	c3                   	ret    

801081bb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801081bb:	55                   	push   %ebp
801081bc:	89 e5                	mov    %esp,%ebp
801081be:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081c1:	83 ec 04             	sub    $0x4,%esp
801081c4:	6a 00                	push   $0x0
801081c6:	ff 75 0c             	push   0xc(%ebp)
801081c9:	ff 75 08             	push   0x8(%ebp)
801081cc:	e8 bc f8 ff ff       	call   80107a8d <walkpgdir>
801081d1:	83 c4 10             	add    $0x10,%esp
801081d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801081d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081db:	75 0d                	jne    801081ea <clearpteu+0x2f>
    panic("clearpteu");
801081dd:	83 ec 0c             	sub    $0xc,%esp
801081e0:	68 d0 8b 10 80       	push   $0x80108bd0
801081e5:	e8 cb 83 ff ff       	call   801005b5 <panic>
  *pte &= ~PTE_U;
801081ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ed:	8b 00                	mov    (%eax),%eax
801081ef:	83 e0 fb             	and    $0xfffffffb,%eax
801081f2:	89 c2                	mov    %eax,%edx
801081f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f7:	89 10                	mov    %edx,(%eax)
}
801081f9:	90                   	nop
801081fa:	c9                   	leave  
801081fb:	c3                   	ret    

801081fc <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801081fc:	55                   	push   %ebp
801081fd:	89 e5                	mov    %esp,%ebp
801081ff:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108202:	e8 ac f9 ff ff       	call   80107bb3 <setupkvm>
80108207:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010820a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010820e:	75 0a                	jne    8010821a <copyuvm+0x1e>
    return 0;
80108210:	b8 00 00 00 00       	mov    $0x0,%eax
80108215:	e9 f8 00 00 00       	jmp    80108312 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
8010821a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108221:	e9 c7 00 00 00       	jmp    801082ed <copyuvm+0xf1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108229:	83 ec 04             	sub    $0x4,%esp
8010822c:	6a 00                	push   $0x0
8010822e:	50                   	push   %eax
8010822f:	ff 75 08             	push   0x8(%ebp)
80108232:	e8 56 f8 ff ff       	call   80107a8d <walkpgdir>
80108237:	83 c4 10             	add    $0x10,%esp
8010823a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010823d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108241:	75 0d                	jne    80108250 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108243:	83 ec 0c             	sub    $0xc,%esp
80108246:	68 da 8b 10 80       	push   $0x80108bda
8010824b:	e8 65 83 ff ff       	call   801005b5 <panic>
    if(!(*pte & PTE_P))
80108250:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108253:	8b 00                	mov    (%eax),%eax
80108255:	83 e0 01             	and    $0x1,%eax
80108258:	85 c0                	test   %eax,%eax
8010825a:	75 0d                	jne    80108269 <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010825c:	83 ec 0c             	sub    $0xc,%esp
8010825f:	68 f4 8b 10 80       	push   $0x80108bf4
80108264:	e8 4c 83 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
80108269:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010826c:	8b 00                	mov    (%eax),%eax
8010826e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108273:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108276:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108279:	8b 00                	mov    (%eax),%eax
8010827b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108280:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108283:	e8 cc aa ff ff       	call   80102d54 <kalloc>
80108288:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010828b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010828f:	74 6d                	je     801082fe <copyuvm+0x102>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108291:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108294:	05 00 00 00 80       	add    $0x80000000,%eax
80108299:	83 ec 04             	sub    $0x4,%esp
8010829c:	68 00 10 00 00       	push   $0x1000
801082a1:	50                   	push   %eax
801082a2:	ff 75 e0             	push   -0x20(%ebp)
801082a5:	e8 f8 d0 ff ff       	call   801053a2 <memmove>
801082aa:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801082ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801082b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801082b3:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801082b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bc:	83 ec 0c             	sub    $0xc,%esp
801082bf:	52                   	push   %edx
801082c0:	51                   	push   %ecx
801082c1:	68 00 10 00 00       	push   $0x1000
801082c6:	50                   	push   %eax
801082c7:	ff 75 f0             	push   -0x10(%ebp)
801082ca:	e8 54 f8 ff ff       	call   80107b23 <mappages>
801082cf:	83 c4 20             	add    $0x20,%esp
801082d2:	85 c0                	test   %eax,%eax
801082d4:	79 10                	jns    801082e6 <copyuvm+0xea>
      kfree(mem);
801082d6:	83 ec 0c             	sub    $0xc,%esp
801082d9:	ff 75 e0             	push   -0x20(%ebp)
801082dc:	e8 d9 a9 ff ff       	call   80102cba <kfree>
801082e1:	83 c4 10             	add    $0x10,%esp
      goto bad;
801082e4:	eb 19                	jmp    801082ff <copyuvm+0x103>
  for(i = 0; i < sz; i += PGSIZE){
801082e6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082f3:	0f 82 2d ff ff ff    	jb     80108226 <copyuvm+0x2a>
    }
  }
  return d;
801082f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082fc:	eb 14                	jmp    80108312 <copyuvm+0x116>
      goto bad;
801082fe:	90                   	nop

bad:
  freevm(d);
801082ff:	83 ec 0c             	sub    $0xc,%esp
80108302:	ff 75 f0             	push   -0x10(%ebp)
80108305:	e8 18 fe ff ff       	call   80108122 <freevm>
8010830a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010830d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108312:	c9                   	leave  
80108313:	c3                   	ret    

80108314 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108314:	55                   	push   %ebp
80108315:	89 e5                	mov    %esp,%ebp
80108317:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010831a:	83 ec 04             	sub    $0x4,%esp
8010831d:	6a 00                	push   $0x0
8010831f:	ff 75 0c             	push   0xc(%ebp)
80108322:	ff 75 08             	push   0x8(%ebp)
80108325:	e8 63 f7 ff ff       	call   80107a8d <walkpgdir>
8010832a:	83 c4 10             	add    $0x10,%esp
8010832d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108333:	8b 00                	mov    (%eax),%eax
80108335:	83 e0 01             	and    $0x1,%eax
80108338:	85 c0                	test   %eax,%eax
8010833a:	75 07                	jne    80108343 <uva2ka+0x2f>
    return 0;
8010833c:	b8 00 00 00 00       	mov    $0x0,%eax
80108341:	eb 22                	jmp    80108365 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108346:	8b 00                	mov    (%eax),%eax
80108348:	83 e0 04             	and    $0x4,%eax
8010834b:	85 c0                	test   %eax,%eax
8010834d:	75 07                	jne    80108356 <uva2ka+0x42>
    return 0;
8010834f:	b8 00 00 00 00       	mov    $0x0,%eax
80108354:	eb 0f                	jmp    80108365 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108359:	8b 00                	mov    (%eax),%eax
8010835b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108360:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108365:	c9                   	leave  
80108366:	c3                   	ret    

80108367 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108367:	55                   	push   %ebp
80108368:	89 e5                	mov    %esp,%ebp
8010836a:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010836d:	8b 45 10             	mov    0x10(%ebp),%eax
80108370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108373:	eb 7f                	jmp    801083f4 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108375:	8b 45 0c             	mov    0xc(%ebp),%eax
80108378:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010837d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108383:	83 ec 08             	sub    $0x8,%esp
80108386:	50                   	push   %eax
80108387:	ff 75 08             	push   0x8(%ebp)
8010838a:	e8 85 ff ff ff       	call   80108314 <uva2ka>
8010838f:	83 c4 10             	add    $0x10,%esp
80108392:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108395:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108399:	75 07                	jne    801083a2 <copyout+0x3b>
      return -1;
8010839b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083a0:	eb 61                	jmp    80108403 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801083a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a5:	2b 45 0c             	sub    0xc(%ebp),%eax
801083a8:	05 00 10 00 00       	add    $0x1000,%eax
801083ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801083b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b3:	3b 45 14             	cmp    0x14(%ebp),%eax
801083b6:	76 06                	jbe    801083be <copyout+0x57>
      n = len;
801083b8:	8b 45 14             	mov    0x14(%ebp),%eax
801083bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801083be:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c1:	2b 45 ec             	sub    -0x14(%ebp),%eax
801083c4:	89 c2                	mov    %eax,%edx
801083c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083c9:	01 d0                	add    %edx,%eax
801083cb:	83 ec 04             	sub    $0x4,%esp
801083ce:	ff 75 f0             	push   -0x10(%ebp)
801083d1:	ff 75 f4             	push   -0xc(%ebp)
801083d4:	50                   	push   %eax
801083d5:	e8 c8 cf ff ff       	call   801053a2 <memmove>
801083da:	83 c4 10             	add    $0x10,%esp
    len -= n;
801083dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e0:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801083e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e6:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801083e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ec:	05 00 10 00 00       	add    $0x1000,%eax
801083f1:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801083f4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801083f8:	0f 85 77 ff ff ff    	jne    80108375 <copyout+0xe>
  }
  return 0;
801083fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108403:	c9                   	leave  
80108404:	c3                   	ret    

80108405 <srand>:
#include "rand.h"
static unsigned int next = 1;

void srand(unsigned int seed){
80108405:	55                   	push   %ebp
80108406:	89 e5                	mov    %esp,%ebp
	next = seed;
80108408:	8b 45 08             	mov    0x8(%ebp),%eax
8010840b:	a3 c0 b4 10 80       	mov    %eax,0x8010b4c0
}
80108410:	90                   	nop
80108411:	5d                   	pop    %ebp
80108412:	c3                   	ret    

80108413 <rand>:

int rand(void){
80108413:	55                   	push   %ebp
80108414:	89 e5                	mov    %esp,%ebp
	next = next * 1103515245 + 12345;
80108416:	a1 c0 b4 10 80       	mov    0x8010b4c0,%eax
8010841b:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
80108421:	05 39 30 00 00       	add    $0x3039,%eax
80108426:	a3 c0 b4 10 80       	mov    %eax,0x8010b4c0
        return((unsigned)(next/65536) % 32768);
8010842b:	a1 c0 b4 10 80       	mov    0x8010b4c0,%eax
80108430:	c1 e8 10             	shr    $0x10,%eax
80108433:	25 ff 7f 00 00       	and    $0x7fff,%eax
}
80108438:	5d                   	pop    %ebp
80108439:	c3                   	ret    

mkdir -p target
cross/bin/i586-elf-as src/asm/boot.s -o target/boot.o
nim c --gcc.exe:"/Users/pascalmouret/workspace/nimOS/cross/bin/i586-elf-gcc" ./src/nim/kernel.nim
# cross/bin/i586-elf-gcc -c src/kernel.c -o target/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
cross/bin/i586-elf-gcc -T src/linker.ld -o nimOS.bin -ffreestanding -O2 -nostdlib target/boot.o src/nim/nimcache/kernel.o src/nim/nimcache/stdlib_system.o -lgcc
# cross/bin/i586-elf-gcc -T src/linker.ld -o nimOS.bin -ffreestanding -O2 -nostdlib target/boot.o target/kernel.o -lgcc

mkdir -p isodir/boot/grub
cp nimOS.bin isodir/boot/nimOS.bin
cp grub.cfg isodir/boot/grub/grub.cfg
grub-mkrescue -o nimOS.iso isodir

rm -rf isodir
rm -rf src/nim/nimcache
rm -rf target

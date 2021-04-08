import java.io.File

/**
 * заходим в Settings -> Project structure -> Artifacts. Создаём новый артифакт jar.
 * Выбираем свой основной класс и нажимаем создать.
 * Затем выбираем build -> build artifacts -> build jar. Всё.
 *
 *
 */

const val LEVEL_WIDTH = 16
const val LEVEL_HEIGHT = 12


@ExperimentalUnsignedTypes
//fun main(args: Array<String>) {
fun main() {
    val file = File("../maps/levels.tmx")

    val conversion = TiledConversion(
        file,
        "../sprites/storage.asm",
        "../maps/levelsData.asm"
    )
    conversion.exec()
}


/*
            APULTRA
apultra command-line tool v1.4.0 by Emmanuel Marty and spke
usage: apultra.exe [-c] [-d] [-v] [-b] <infile> <outfile>
        -c: check resulting stream after compressing
        -d: decompress (default: compress)
        -b: backwards compression or decompression
 -w <size>: maximum window size, in bytes (16..2097152), defaults to maximum
 -D <file>: use dictionary file
   -cbench: benchmark in-memory compression
   -dbench: benchmark in-memory decompression
     -test: run full automated self-tests
-quicktest: run quick automated self-tests
    -stats: show compressed data stats
        -v: be verbose
 */

/*
                APLIB
Usage:
  .exe in out [b] [s]

  b - byte align power of 2.
  s - speed:
         0 - slowest,
         1 - fastest,
         2 - slower than 1,
         3 - slower than 2
         n - ...

  Author: r57shell@uralweb.ru
  Last update: 31.08.2017

 */
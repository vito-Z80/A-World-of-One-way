import java.io.File

@ExperimentalUnsignedTypes
fun main(args: Array<String>) {
    val file = File("../maps/levels.tmx")

    val conversion = TiledConversion(
        file,
        "../sprites/storage.asm",
        "../maps/levelsData.asm"
    )
    conversion.exec()







    val time = System.currentTimeMillis()
    val f = File("complete_$time.txt")
    f.writeText(time.toString())

}

//    or  java [-options] -jar jarfile [args...]
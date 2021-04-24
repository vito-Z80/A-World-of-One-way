import java.io.File
import java.util.*
import kotlin.collections.ArrayList

// gradlew desktop:dist for jar create in path ..../ desktop / build / libs
// автор тайледа 100% редактор делал изначально не для геймдэва - он не логичен пиздец !!!
// есть выделение части слоя, но его нельзя двигать блять !!! Нужно удалять выделение и вставлять куда требуется !!!!
// ятаворотибал
const val LEVEL_WIDTH = 16
const val LEVEL_HEIGHT = 12
@ExperimentalUnsignedTypes
class TiledConversion(val map: File, val dstSpriteStorage: String, val dstLevelsStorage: String) {

    val mapString = map.readText(Charsets.ISO_8859_1)

    val mapProperties = "(<map)\\s.+(>)?".toRegex().find(mapString)?.value ?: error("Wrong map properties.")
    val mapWidth =
        "(?<= width=\")\\d+(?=\")?".toRegex().find(mapProperties)?.value?.toInt() ?: error("Wrong map WIDTH:")
    val mapHeight =
        "(?<= height=\")\\d+(?=\")?".toRegex().find(mapProperties)?.value?.toInt() ?: error("Wrong map HEIGHT:")
    val columns = mapWidth / LEVEL_WIDTH
    val rows = mapHeight / LEVEL_HEIGHT
    val mapLine = columns * LEVEL_WIDTH


    val tilesId =
        "(?<=tile id=\")\\d+(?!\")?".toRegex(RegexOption.DOT_MATCHES_ALL).findAll(mapString).toList()
            .map { it.value.toInt() }
    val tileset =
        "(?<=source=\")[a-zA-Z0-9_./]+(?!\")?".toRegex(RegexOption.DOT_MATCHES_ALL).findAll(mapString).toList()
            .map { it.value }
    val mapData =
        "(?<=<data encoding=\"csv\">)[0-9,\\s]+(?=</data>)?".toRegex(RegexOption.DOT_MATCHES_ALL).findAll(mapString)
            .toList().map { it.value.split(",").map { d -> d.trim().toInt() } }

    val wallsLayer = mapData[0]

    //    val objectsLayer = MutableList(mapData[1].size) { mapData[1][it] }
    val objectsLayer = mapData[1].toMutableList().map { it - 1 }

    val levelAsmData = StringBuilder()
    var levelAddressesOffset = 0
    val levelAddresses = StringBuilder("LEVELS_MAP:\tdw ")

    fun exec() {
        val spritesAsmData = StringBuilder()
        val spritesAddressesOffset = ArrayList<Int>()


        println("Tiles ID`s:")
        val indices = getIndices()
        indices.forEachIndexed { newId, arrayInt ->
            arrayInt.forEach { oldId ->
                Collections.replaceAll(objectsLayer, oldId, newId)
            }
        }
        prtLine()
        val names =
            "(?:../)\\S+(?=\"/>)".toRegex(RegexOption.DOT_MATCHES_ALL).findAll(mapString).map { it.value }.toList()
        val labels = names.map {
            val r = it.split("/")
            r.last().toUpperCase().replace(".", "_")
        }
        var imgId = 0
        var offset = 0
        indices.forEachIndexed { id, arrayInt ->
            spritesAddressesOffset.add(offset)
            spritesAsmData.append("${labels[imgId]}_ID:\tequ $id\n")
            arrayInt.forEach { _ ->
//                val file = File(names[imgId]).readLines(Charsets.ISO_8859_1)
                val file = File(names[imgId]).readText(Charsets.ISO_8859_1).split("\n")
//                println(f.size)
                val width = file[1].toInt()
                val height = file[2].toInt()
                offset += (width / 8) * height
                val data = file[3].toByteArray(Charsets.ISO_8859_1).map { it.toUByte().inv() }.toString()
                    .replace("[\\[\\] ]+".toRegex(), "")
                spritesAsmData.append("${labels[imgId]}:\tdb $data\n")
                imgId++
            }
        }

        val spritesResult = StringBuilder()
        spritesResult.append(
            "SPRITE_MAP:\tdw ${
                spritesAddressesOffset.toString().replace("[\\[\\] ]+".toRegex(), "")
            }\n"
        ).append(spritesAsmData)
        println(spritesResult)
        prtLine()


        val layers = ArrayList<Pair<List<Int>, List<Int>>>()
        repeat(rows) { r ->
            repeat(columns) { c ->
//                val startLevelAddress = r * (mapWidth * LEVEL_HEIGHT) + c * LEVEL_WIDTH
//                val levelId = r * rows + c
                layers.add(
                    Pair(
                        cut(wallsLayer, mapWidth, c, r),
                        cut(objectsLayer, mapWidth, c, r)
                    )
                )
            }
        }

        // отбрасываем пустые уровни
        layers.filter { it.second.any { int -> int != -1 } }.forEach {
            levelAsmData.append(tiledConvertToASMFile(it.first, it.second))
        }


        val levelsResult = StringBuilder()
        levelsResult.append(levelAddresses.dropLast(1)).append("\nLEVELS_BEGIN:").append(levelAsmData)
        println(levelsResult)

        saveFile(dstSpriteStorage, spritesResult)
        saveFile(dstLevelsStorage, levelsResult)

    }

    //-----------------------------------------------------------

    private fun tiledConvertToASMFile(walls: List<Int>, objects: List<Int>): String {
        val wallsString = StringBuilder("\n\tdb ")
        val objectsString = StringBuilder("\n\tdb ")

        levelAddresses.append("$levelAddressesOffset,")
        repeat(24) { line ->
            var byte = 0
            var value = 32768
            repeat(8) { b ->
                val id = b + (line * 8)
                byte = if (walls[id] == 0) byte else byte or value
                value = value shr 1

                if (objects[id] != -1) {
                    objectsString.append("$id,${objects[id]},")     // -1 !?!
                    levelAddressesOffset += 2
                }

            }
            wallsString.append("${byte shr 8 and 255},")
        }
        objectsString.append("255")
        levelAddressesOffset += 24 + 1      // +1 =255 завершающий байт

        return "${wallsString.dropLast(1)}${objectsString}"
    }


    private fun getIndices(): ArrayList<ArrayList<Int>> {
        val indices = ArrayList<ArrayList<Int>>()
        val tileset = "(?<=<tileset).+(?=</tileset>)".toRegex(RegexOption.DOT_MATCHES_ALL).find(mapString)?.value
            ?: error("Tileset is empty !!!")

        // индексы из тайлсета, они отличаются от индексов карты - на карте эти индексы +1 (захуярить афтора Tiled map editor)
        val tileIds =
            "(?<=<tile id=\")\\d+(?=\">)".toRegex(RegexOption.DOT_MATCHES_ALL).findAll(tileset).map { it.value.trim() }
                .toList()

        val tileNames =
            "(?<=source=\")\\S+(?=\")".toRegex(RegexOption.DOT_MATCHES_ALL).findAll(tileset).map { it.value.trim() }
                .toList()


        var preName: String? = null
//        var count = 0
        tileNames.forEachIndexed { id, name ->
            val n = "\\S+(?=_\\d+)".toRegex().find(name)?.value ?: name
            if (n != preName) {
                indices.add(arrayListOf())
                preName = n
//                println(count++)
//                println("$preName, $n")
            }
            indices.last().add(tileIds[id].trimIndent().toInt())
        }

        indices.forEachIndexed { id, i ->
            println("$id: ${i.toString()}")
        }
        return indices
    }

    // вырезает (чанк) уровень 16х12 из карты
    private fun cut(
        src: List<Int>, srcWidth: Int, x: Int, y: Int
    ): List<Int> {
        val a = ArrayList<Int>()
        val id = y * (srcWidth * LEVEL_HEIGHT) + x * LEVEL_WIDTH
        repeat(LEVEL_HEIGHT) { h ->
            repeat(LEVEL_WIDTH) { w ->
                a.add(src[id + h * srcWidth + w])
            }
        }
        return a
    }

    private fun prtLine() {
        println("----------------------------------------------------------------------------------------------")
    }

    private fun saveFile(fileName: String, data: StringBuilder) = File(fileName).writeText(data.toString())

}
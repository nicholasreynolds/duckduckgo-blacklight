plugins {
    id("org.gradlewebtools.minify") version "1.0.0"
}

tasks {
    val src = "src"
    val srcElm = "$src/elm"
    val srcJs = "$src/js"
    val srcPlugin = "$src/plugin"
    val build = "build"
    val buildElm = "$build/elm"
    val buildJs = "$build/js"
    val buildMinify = "$build/minify"
    val buildPlugin = "$build/plugin"
    val nodeMods = "node_modules"
    val initJs = "$srcJs/init.js"
    val blacklightElmJs = "$buildElm/blacklight.elm.js"
    val blacklightJs = "$buildJs/blacklight.js"
    val webExt = "$nodeMods/web-ext/bin/web-ext"
    val webExtLink = "bin/web-ext"

    val elmMake by register("elmMake") {
        inputs.dir(srcElm)
        outputs.file(blacklightElmJs)
        doLast {
            val cmd = mutableListOf(
                  "$nodeMods/elm/bin/elm",
                  "make",
                  "$srcElm/Main.elm",
                  "--output",
                  blacklightElmJs
            )
            if (project.hasProperty("debug")) {
                cmd.add("--debug")
            } else {
                cmd.add("--optimize")
            }
            execute(getLogger(), cmd)
        }
    }

    val makeAppended by register("makeAppended") {
        dependsOn(elmMake)
        inputs.file(blacklightElmJs)
        inputs.file(initJs)
        outputs.file(blacklightJs)
        doLast {
            val outputFile = project.file(blacklightJs)
            outputFile.writeBytes(
                elmMake.outputs.files.getSingleFile().readBytes()
            )
            outputFile.appendBytes(
                project.file(initJs).readBytes()
            )
        }
    }

    val copyJs by register<Copy>("copyJs") {
        from(
            "$srcJs/settings",
            "$srcJs/background"
        )
        setDestinationDir(project.file("$buildJs"))
    }

    val minify by register<org.gradlewebtools.minify.JsMinifyTask>("minify") {
        dependsOn(makeAppended)
        dependsOn(copyJs)
        srcDir = project.file("$buildJs")
        dstDir = project.file("$buildMinify")
        if (project.hasProperty("debug")) {
            options { createSourceMaps = true }
        }
    }

    val plugin by register<Copy>("plugin") {
        dependsOn(minify)

        if (project.hasProperty("debug")) {
            from(
                "$buildJs",
                "$buildMinify",
                "$srcPlugin"
            )
        } else {
            from(
                "$buildMinify",
                "$srcPlugin"
            )
        }
        setDestinationDir(project.file("$buildPlugin"))
    }

    val linkWebExt by register("linkWebExt") {
        inputs.file(webExt)
        outputs.file(webExtLink)
        doLast {
            execute(getLogger(), listOf(
                "ln",
                "-sf",
                "${project.projectDir}/$webExt",
                webExtLink
                )
            )
        }
    }

    val buildXpi by register("buildXpi") {
        dependsOn(linkWebExt)
        dependsOn(plugin)
        doLast {
            execute(getLogger(), listOf(
                webExtLink,
                "build",
                "-s",
                "$buildPlugin",
                "-a",
                "$build/artifacts"
                )
            )
        }
    }

    val elmTest by register("elmTest") {
        doLast {
            execute(getLogger(), listOf(
                "$nodeMods/elm-test/bin/elm-test"
                )
            )
        }
    }

    val clean by register<Delete>("clean") {
        delete("$build")
    }
}

// Adapted from org.mohme.gradle.elm-plugin version 4.0.1
fun execute(logger: org.gradle.api.logging.Logger, cmd: List<String>) {
    val cmdString = cmd.joinToString(" ")
    logger.info("executing '{}'", cmdString)

    val process: Process
    try {
        process = ProcessBuilder(cmd).start()
    } catch (e: java.io.IOException) {
        throw GradleException("Failed to execute '${cmdString}'", e)
    }

    process.waitFor()

    val stdOut = java.io.BufferedReader(java.io.InputStreamReader(process.inputStream))
    stdOut.lineSequence().forEach { line -> logger.info(line) }

    val stdErr = java.io.BufferedReader(java.io.InputStreamReader(process.errorStream))
    stdErr.lineSequence().forEach { line -> logger.error(line) }

    val exitVal = process.exitValue();
    if (exitVal != 0) {
        throw GradleException("'${cmdString}' exited with non-zero value ${exitVal}.")
    }
}

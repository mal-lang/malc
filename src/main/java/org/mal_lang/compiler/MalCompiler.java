/*
 * Copyright 2019-2021 Foreseeti AB <https://foreseeti.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.mal_lang.compiler;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AccessDeniedException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.NotDirectoryException;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import org.fusesource.jansi.AnsiConsole;
import org.mal_lang.langspec.Utils;
import org.mal_lang.langspec.io.LangWriter;
import org.mal_lang.lib.Analyzer;
import org.mal_lang.lib.CompilerException;
import org.mal_lang.lib.LangConverter;
import org.mal_lang.lib.Parser;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

/**
 * The main MAL compiler class.
 *
 * @since 0.1.0
 */
@Command(
    name = "malc",
    versionProvider = ManifestVersionProvider.class,
    mixinStandardHelpOptions = true,
    description = {"A compiler for the Meta Attack Language."},
    sortOptions = false)
public class MalCompiler implements Callable<Integer> {
  @Parameters(index = "0", paramLabel = "file", description = "The MAL specification to compile")
  private Path input;

  @Option(
      names = {"-i", "--icons"},
      paramLabel = "<dir>",
      description = "Icons directory")
  private Path icons;

  @Option(
      names = {"-l", "--license"},
      paramLabel = "<file>",
      description = "License file")
  private Path license;

  @Option(
      names = {"-n", "--notice"},
      paramLabel = "<file>",
      description = "Notice file")
  private Path notice;

  @Option(
      names = {"-o", "--output"},
      paramLabel = "<file>",
      description = "Write output to <file>")
  private Path output;

  @Option(
      names = {"-v", "--verbose"},
      description = "Print verbose output")
  private boolean verbose;

  @Option(
      names = {"-d", "--debug"},
      description = "Print debug output")
  private boolean debug;

  private final Map<String, byte[]> svgIcons = new LinkedHashMap<>();
  private final Map<String, byte[]> pngIcons = new LinkedHashMap<>();
  private String licenseString = null;
  private String noticeString = null;

  private void readIcons() throws IOException {
    if (this.icons != null) {
      try (var directoryStream = Files.newDirectoryStream(this.icons)) {
        for (var entry : directoryStream) {
          if (Files.isDirectory(entry)) {
            continue;
          }
          if (entry.toString().endsWith(".svg")) {
            var assetName = entry.getFileName().toString();
            assetName = assetName.substring(0, assetName.length() - ".svg".length());
            if (Utils.isIdentifier(assetName)) {
              this.svgIcons.put(assetName, Files.readAllBytes(entry));
            }
          } else if (entry.toString().endsWith(".png")) {
            var assetName = entry.getFileName().toString();
            assetName = assetName.substring(0, assetName.length() - ".png".length());
            if (Utils.isIdentifier(assetName)) {
              this.pngIcons.put(assetName, Files.readAllBytes(entry));
            }
          }
        }
      }
    }
  }

  @Override
  public Integer call() throws Exception {
    try {
      this.readIcons();
      if (this.license != null) {
        this.licenseString = Files.readString(license, StandardCharsets.UTF_8);
      }
      if (this.notice != null) {
        this.noticeString = Files.readString(notice, StandardCharsets.UTF_8);
      }
      var ast = Parser.parse(this.input.toFile(), this.verbose, this.debug);
      Analyzer.analyze(ast, this.verbose, this.debug);
      var lang =
          LangConverter.convert(
              ast,
              this.verbose,
              this.debug,
              this.svgIcons,
              this.pngIcons,
              this.licenseString,
              this.noticeString);
      if (this.output == null) {
        this.output =
            Path.of(String.format("%s-%s.mar", lang.getDefine("id"), lang.getDefine("version")));
      }
      try (var out = Files.newOutputStream(this.output);
          var writer = new LangWriter(out)) {
        writer.write(lang);
      }
    } catch (AccessDeniedException e) {
      System.err.println(String.format("%s: Permission denied", e.getFile()));
      return 1;
    } catch (NoSuchFileException e) {
      System.err.println(String.format("%s: No such file or directory", e.getFile()));
      return 1;
    } catch (NotDirectoryException e) {
      System.err.println(String.format("%s: Not a directory", e.getFile()));
      return 1;
    } catch (IOException e) {
      System.err.println(e.getMessage());
      return 1;
    } catch (CompilerException e) {
      return 1;
    }
    return 0;
  }

  public static void main(String... args) {
    AnsiConsole.systemInstall();
    int exitCode = new CommandLine(new MalCompiler()).execute(args);
    AnsiConsole.systemUninstall();
    System.exit(exitCode);
  }
}

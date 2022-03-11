/*
 * Copyright 2019-2022 Foreseeti AB <https://foreseeti.com>
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
import java.util.jar.Manifest;
import picocli.CommandLine.IVersionProvider;

/**
 * Reads version string from manifest file.
 *
 * @since 0.1.0
 */
public class ManifestVersionProvider implements IVersionProvider {
  @Override
  public String[] getVersion() throws Exception {
    try {
      var resources =
          ManifestVersionProvider.class.getClassLoader().getResources("META-INF/MANIFEST.MF");
      while (resources.hasMoreElements()) {
        var url = resources.nextElement();
        try (var in = url.openStream()) {
          var manifest = new Manifest(in);
          var attributes = manifest.getMainAttributes();
          var title = attributes.getValue("Implementation-Title");
          var version = attributes.getValue("Implementation-Version");
          var vendor = attributes.getValue("Implementation-Vendor");
          if (title != null
              && version != null
              && vendor != null
              && title.equals("malc")
              && vendor.equals("MAL")) {
            return new String[] {String.format("%s version %s", title, version)};
          }
        }
      }
      throw new RuntimeException("Failed to get resource \"META-INF/MANIFEST.MF\"");
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
}

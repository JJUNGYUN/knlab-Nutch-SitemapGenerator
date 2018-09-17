/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.nutch.util;

import java.util.Map.Entry;
import java.util.Properties;
import java.util.UUID;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.StringTokenizer;
import java.util.Vector;
import org.apache.hadoop.conf.Configuration;


/** Utility to create Hadoop {@link Configuration}s that include Nutch-specific
 * resources.  */
public class NutchConfiguration {
  public static final String UUID_KEY = "nutch.conf.uuid";
  
  private NutchConfiguration() {}                 // singleton
  
  /*
   * Configuration.hashCode() doesn't return values that
   * correspond to a unique set of parameters. This is a workaround
   * so that we can track instances of Configuration created by Nutch.
   */
  private static void setUUID(Configuration conf) {
    UUID uuid = UUID.randomUUID();
    conf.set(UUID_KEY, uuid.toString());
  }
  
  /**
   * Retrieve a Nutch UUID of this configuration object, or null
   * if the configuration was created elsewhere.
   * @param conf configuration instance
   * @return uuid or null
   */
  public static String getUUID(Configuration conf) {
    return conf.get(UUID_KEY);
  }

  /** Create a {@link Configuration} for Nutch. This will load the standard
   * Nutch resources, <code>nutch-default.xml</code> and
   * <code>nutch-site.xml</code> overrides.
   */
  public static Configuration create() {
    Configuration conf = new Configuration();
    setUUID(conf);
    addNutchResources(conf);
    return conf;
  }
  
  /** Create a {@link Configuration} from supplied properties.
   * @param addNutchResources if true, then first <code>nutch-default.xml</code>,
   * and then <code>nutch-site.xml</code> will be loaded prior to applying the
   * properties. Otherwise these resources won't be used.
   * @param nutchProperties a set of properties to define (or override)
   */
  public static Configuration create(boolean addNutchResources, Properties nutchProperties) {
    Configuration conf = new Configuration();
    setUUID(conf);
    if (addNutchResources) {
      addNutchResources(conf);
    }
    for (Entry<Object, Object> e : nutchProperties.entrySet()) {
      conf.set(e.getKey().toString(), e.getValue().toString());
    }
    return conf;
  }

  /**
   * Add the standard Nutch resources to {@link Configuration}.
   * 
   * @param conf               Configuration object to which
   *                           configuration is to be added.
   */
  private static Configuration addNutchResources(Configuration conf) {
   			String currentDir = System.getProperty("user.dir");
						System.out.println(currentDir);
	  conf.addResource("nutch-default.xml");
    conf.addResource("nutch-site.xml");
    return conf;
  }
  public static class Host_port{
	Host_port(String Host,String Port) {
		this._Host = Host;
		this._Port = Port;
	}
	public String _Host;
	public String _Port;
  }
	public static Vector<Host_port> Call_proxy(){
		System.out.println("파일을 불러오긴 하네");
					String currentDir = System.getProperty("user.dir");
								System.out.println(currentDir);
		Vector<Host_port> Proxyip = new Vector<Host_port>();
		String ip;
		try {
			BufferedReader in = new BufferedReader(new FileReader("./conf/proxy.txt"));
			while((ip = in.readLine()) != null) {
				StringTokenizer srt = new StringTokenizer(ip,":");
				String Host = srt.nextToken();
				String Port = srt.nextToken();
				System.out.println(Host+"    "+Port);
				Host_port HP = new Host_port(Host, Port);
				Proxyip.add(HP);
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}catch (IOException e) {
			e.printStackTrace();
		}
		return Proxyip;
	}
}


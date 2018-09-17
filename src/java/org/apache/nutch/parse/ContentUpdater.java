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

package org.apache.nutch.parse;

import java.nio.ByteBuffer;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.avro.util.Utf8;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.nutch.crawl.SignatureFactory;
import org.apache.nutch.protocol.Content;
import org.apache.nutch.protocol.Protocol;
import org.apache.nutch.protocol.ProtocolFactory;
import org.apache.nutch.protocol.ProtocolOutput;
import org.apache.nutch.protocol.ProtocolStatusUtils;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.util.Bytes;
import org.apache.nutch.util.NutchConfiguration;
import org.apache.nutch.util.StringUtil;
import org.apache.nutch.util.URLUtil;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Content Updater
 * @version Beta 
 * @author Hyun-sung Kim 
 */

public class ContentUpdater implements Tool {

	public static final Logger LOG = LoggerFactory.getLogger(ParserChecker.class);

	private Configuration conf;

	public ContentUpdater() {
	}

	public int run(String[] args) throws Exception {
	  
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		String storageDbName = "pepper_storage";
		String storageDbUser = "pepper";
		String storageDbPw = "pepper";
		String storageJdbcDriver = "jdbc:mysql://localhost:3306/" + storageDbName + "?createDatabaseIfNotExist=true&autoReconnect=true&useSSL=false";

		String crawlTableName = null;
		String storageTableName = null;
		
		int updateCnt = 0;
		int totalCnt = 0;
		int errorCnt = 0;
		int setStrCnt = 1;

	    String keyword = null;
	    String extType = null;
	  
		String contentType = null;
		String url = null;

		String usage = "Usage: contentupdater -keyword [keyword] -extType [extType] -crawlId [crawlId]";
		
		if (args.length == 0) {
			LOG.error(usage);
			return (-1);
		}
		
		for (int i = 0; i < args.length; i++) {
			if (args[i].equals("-extType")) {
				extType = args[++i];
			} else if (args[i].equals("-keyword")) {
				keyword = args[++i];
			} else if (args[i].equals("-crawlId")) {
				crawlTableName = args[++i] + "_webpage";
				storageTableName = crawlTableName + "_info";
			} else if (i != args.length - 1) {
				LOG.error(usage);
				System.exit(-1);
			}
		}

		String selectSql = "SELECT "
				+ "id, "
				+ "CASE WHEN INSTR(id, ':https') > 1 "
				+ "	THEN 'https' "
				+ "	ELSE "
				+ "		CASE WHEN INSTR(id, ':http') > 1 "
				+ " 		THEN 'http' "
				+ "			ELSE NULL "
	            + " 		END "
	            + "	END AS protocol, "
				+ "genUrl, "
				+ "host, "
				+ "path, "
				+ "param, "
				+ "extTyp, "
				+ "REPLACE(SUBSTRING_INDEX(path, '/', -1), '" + extType + "', '') AS fileName "
				+ " FROM " + storageTableName + " WHERE 1=1 "
				+ "		AND refineYn = 'N' ";

		if(keyword != null && !keyword.equals("") && !keyword.equals("ALL")) {
			selectSql += " AND id LIKE ? ";
		}

		if(extType != null && !extType.equals("") && !extType.equals("ALL")) {
			selectSql += " AND id LIKE ? ";
		}
		
		String updateSql = "UPDATE " + storageTableName + " SET "
				+ "metaContTitle=?, "
				+ "urlContTitle=?, "
				+ "metaTitleYn=?, "
				+ "contLength=?, "
				+ "nPages=?, "
				+ "contRegisteredTime=?, "
				+ "contModifiedTime=?, "
				+ "refineYn='Y', "
				+ "mod_time=NOW() "
				+ " WHERE id=? ";

		// FILE UPDATER START
		try {
								        
			conn = DriverManager.getConnection(storageJdbcDriver, storageDbUser, storageDbPw);
			conn.setAutoCommit(false);
													        
			pstmt = conn.prepareStatement(selectSql);
			
			if(keyword != null && !keyword.equals("") && !keyword.equals("ALL")) {
				pstmt.setString(setStrCnt, "%" + keyword + "%");
				setStrCnt++;
			}

			if(extType != null && !extType.equals("") && !extType.equals("ALL")) {
				pstmt.setString(setStrCnt, "%" + extType + "%");
			}
																				
			rs = pstmt.executeQuery();
																								
			while(rs.next()) {
																														
				String id = rs.getString("id");
				String genUrl = rs.getString("genUrl");
				String host = rs.getString("host");
				String path = rs.getString("path");
				String param = rs.getString("param");
				String extTyp = rs.getString("extTyp");
				String fileName = rs.getString("fileName");
				
				String fetUrl = genUrl;
				String metaContTitle = null;
				String urlContTitle = fileName;
				String metaTitleYn = "N";
				String contLength = null;
				String nPages = null;
				String contRegisteredTime = null;
				String contModifiedTime = null;

				LOG.info("\n----------\nDbInfo\n----------\n");
				LOG.info("id : " + id);
				LOG.info("genUrl : " + genUrl);
				LOG.info("host : " + host);
				LOG.info("path : " + path);
				LOG.info("param : " + param);
				LOG.info("extTyp : " + extTyp);
				LOG.info("fileName : " + fileName);

				// URL FETCHING START
				if (LOG.isInfoEnabled()) {
					LOG.info("\nfetching: " + fetUrl);
			    }

			    ProtocolFactory factory = new ProtocolFactory(conf);
			    Protocol protocol = factory.getProtocol(fetUrl);
			    WebPage page = new WebPage();

			    ProtocolOutput protocolOutput = protocol.getProtocolOutput(fetUrl, page);

			    if(!protocolOutput.getStatus().isSuccess()) {
					errorCnt++;
			    	LOG.error("Fetch failed with protocol status: "
			    			+ ProtocolStatusUtils.getName(protocolOutput.getStatus().getCode())
			    			+ ": " + ProtocolStatusUtils.getMessage(protocolOutput.getStatus()));
			    	//return (-1);
			    } else {

				    Content content = protocolOutput.getContent();

				    if (content == null) {
				    	LOG.error("No content for " + fetUrl);
				    	return (-1);
			   	    } else {
			    		page.setBaseUrl(new org.apache.avro.util.Utf8(fetUrl));
			    		page.setContent(ByteBuffer.wrap(content.getContent()));

						contentType = content.getContentType();
					}

			    	contentType = content.getContentType();

				    if (contentType == null) {
				    	LOG.error("Failed to determine content type!");
				    	return (-1);
				    } else {
				    	page.setContentType(new Utf8(contentType));
					}

					contentType = content.getContentType();

				    if (ParserJob.isTruncated(fetUrl, page)) {
				      LOG.warn("Content is truncated, parse may fail!");
				    }

				    Parse parse = new ParseUtil(conf).parse(fetUrl, page);

				    if (parse == null) {
				    	LOG.error("Problem with parse - check log");
				    	return (-1);
				    }

				    // Calculate the signature
				    byte[] signature = SignatureFactory.getSignature(getConf()).calculate(page);

				    if (LOG.isInfoEnabled()) {
				    	LOG.info("parsing: " + fetUrl);
				    	LOG.info("contentType: " + contentType);
				    	LOG.info("signature: " + StringUtil.toHexString(signature));
				    }

				    // URL INFO
				    LOG.info("\n----------\nUrl\n----------\n");
				    LOG.info(fetUrl + "\n");
			    
				    // METADATA INFO
				    LOG.info("\n----------\nMetadata\n----------\n");
	
				    Map<Utf8, ByteBuffer> metadata = page.getMetadata();
				    StringBuffer sb = new StringBuffer();

				    if (metadata != null) {
				    	Iterator<Entry<Utf8, ByteBuffer>> iterator = metadata.entrySet().iterator();
				    	while (iterator.hasNext()) {
			        
				    		Entry<Utf8, ByteBuffer> entry = iterator.next();
			        
				    		String mEntryKey = entry.getKey().toString();
				    		ByteBuffer mBuffer = ByteBuffer.allocate(2048).put(entry.getValue());
							byte[] mBytes = new byte[mBuffer.position()];
							mBuffer.flip();
							mBuffer.get(mBytes);
							String mEntryVal = new String(mBytes);
			    	  
				    		if(mEntryKey.contains("title")) {
								metaTitleYn = "Y";
				    			metaContTitle = mEntryVal;
				    		} else if(mEntryKey.contains("NPages")) {
				    			nPages = mEntryVal;
				    		} else if(mEntryKey.contains("Creation-Date")) {
				    			contRegisteredTime = mEntryVal.replaceAll("T", " ").replaceAll("Z", " ");
				    		} else if(mEntryKey.contains("Last-Modified")) {
				    			contModifiedTime = mEntryVal.replaceAll("T", " ").replaceAll("Z", " ");
							}
			        
				    		sb.append(mEntryKey).append(" : \t").append(mEntryVal).append("\n");
			    		}
			      
			    		LOG.info(sb.toString());
				    }

				    // HEADER INFO
				    LOG.info("\n----------\nHeader\n----------\n");
				    Map<Utf8, Utf8> header = page.getHeaders();
				    sb = new StringBuffer();

				    if (header != null) {
				    	Iterator<Entry<Utf8, Utf8>> iterator = header.entrySet().iterator();
				    	while (iterator.hasNext()) {
			    	  
				    		Entry<Utf8, Utf8> entry = iterator.next();
			   	     
				   	 		String hEntryKey = entry.getKey().toString();
				   	 		String hEntryVal = entry.getValue().toString();
			    	
				    		if(hEntryKey.contains("Content-Length")) {
				    			contLength = hEntryVal;
							}
				        
				    		sb.append(hEntryKey).append(" : \t").append(hEntryVal).append("\n");
				    	}
				      
				    	LOG.info(sb.toString());
				    }
			    
				    LOG.info("\n fetUrl : " + fetUrl + "\n metaContTitle : " + metaContTitle + "\n urlContTitle : " + urlContTitle + "\n metaTitleYn : " + metaTitleYn + "\n contLength : " + contLength 
							+ "\n nPages : " + nPages + "\n contRegisteredTime : " + contRegisteredTime + "\n contModifiedTime : " + contModifiedTime + "\n");

					pstmt = conn.prepareStatement(updateSql);
					pstmt.setString(1, metaContTitle);
					pstmt.setString(2, urlContTitle);
					pstmt.setString(3, metaTitleYn);
					pstmt.setString(4, contLength);
					pstmt.setString(5, nPages);
					pstmt.setString(6, contRegisteredTime);
					pstmt.setString(7, contModifiedTime);
					pstmt.setString(8, id);

					updateCnt = pstmt.executeUpdate();
					LOG.info("Metadata Updated " + updateCnt  +" record.");

					totalCnt++;
					LOG.info("Total Updated Metadata Count : " + totalCnt);
					LOG.info("Total Error Count : " + errorCnt);
				
				}
			}

			conn.commit();
			
			rs.close();
			pstmt.close();
			conn.close();
			
		} catch(SQLException ex) {
			ex.printStackTrace();
			LOG.warn("SQLException: " + ex.getMessage());
			LOG.warn("SQLState: " + ex.getSQLState());
		} finally {
			if(rs != null) { try { rs.close(); } catch(SQLException ex) {} }
			if(pstmt != null) { try { pstmt.close(); } catch(SQLException ex) {} }
			if(conn != null) { try { conn.close(); } catch(SQLException ex) {} }
		}
		
		return 0;
				
	}

	@Override
	public Configuration getConf() {
		return conf;
	}

	@Override
	public void setConf(Configuration c) {
		conf = c;
	}

	public static void main(String[] args) throws Exception {
		int res = ToolRunner.run(NutchConfiguration.create(), new ContentUpdater(), args);
		System.exit(res);
	}

}


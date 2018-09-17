package org.apache.nutch.process;

import java.nio.ByteBuffer;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Table Checker
 * @version Beta
 * @author Hyun-sung Kim
 */

public class TableChecker {

	//public static final java.util.logging.Logger LOG = LoggerFactory.getLogger(TableChecker.class);
	
	public TableChecker() {
	}

	public static void main(String[] args) throws Exception {

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		String dbName = "nutch";
		String tableName = null;
		
		String jdbcDriver = "jdbc:mysql://localhost:3306/" + dbName + "?createDatabaseIfNotExist=true&autoReconnect=true";
		String dbUser = "root";
		String dbPw = "1234";
		
		int tableCnt = 0;
		int updateCnt = 0;
	  
		String usage = "Usage: TableChecker [-tableName specificTableName]";
		
		if (args.length == 0) {
			//LOG.error(usage);
			System.out.println(usage);
			//return (-1);
			System.exit(-1);
		}
		
		for (int i = 0; i < args.length; i++) {
			if (args[i].equals("-tableName")) {
				tableName = args[++i];
			}
		}
		
		String selectSql = "SELECT "
						+ " 	count(*) AS count "
						+ " FROM information_schema.tables WHERE 1=1 "
						+ " AND table_schema=? "
						+ " AND table_name=? ";
		
		String createSql = "CREATE TABLE " + tableName + " ( "
						+ " 	id varchar(767) NOT NULL, "
						+ " 	headers blob, "
						+ " 	text longtext DEFAULT NULL, "
						+ " 	status int(11) DEFAULT NULL, "
						+ " 	markers blob, "
						+ " 	parseStatus blob, "
						+ " 	modifiedTime bigint(20) DEFAULT NULL, "
						+ " 	prevModifiedTime bigint(20) DEFAULT NULL, "
						+ " 	score float DEFAULT NULL, "
						+ " 	typ varchar(32) CHARACTER SET latin1 DEFAULT NULL, "
						+ " 	batchId varchar(32) CHARACTER SET latin1 DEFAULT NULL, "
						+ " 	baseUrl varchar(767) DEFAULT NULL, "
						+ " 	content longblob, "
						+ " 	title varchar(2048) DEFAULT NULL, "
						+ " 	reprUrl varchar(767) DEFAULT NULL, "
						+ " 	fetchInterval int(11) DEFAULT NULL, "
						+ " 	prevFetchTime bigint(20) DEFAULT NULL, "
						+ " 	inlinks mediumblob, "
						+ " 	prevSignature blob, "
						+ " 	outlinks mediumblob, "
						+ " 	fetchTime bigint(20) DEFAULT NULL, "
						+ " 	retriesSinceFetch int(11) DEFAULT NULL, "
						+ " 	protocolStatus blob, "
						+ " 	signature blob, "
						+ " 	metadata blob, "
						+ " 	PRIMARY KEY (id) "
						+ " ) ENGINE=InnoDB "
						+ " ROW_FORMAT=COMPRESSED "
						+ " DEFAULT CHARSET=utf8mb4 "
						+ " DEFAULT COLLATE=utf8mb4_unicode_ci ";

		// TABLE CHECKER START
		try {
								        
			Class.forName("com.mysql.jdbc.Driver");

			conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPw);
			conn.setAutoCommit(false);
													        
			pstmt = conn.prepareStatement(selectSql);
			pstmt.setString(1, dbName);
			pstmt.setString(2, tableName);
																				
			rs = pstmt.executeQuery();
																								
			while(rs.next()) {
				
				tableCnt = rs.getInt("count");
				System.out.println(tableCnt);
				
				if(tableCnt > 0) {
					//LOG.info(dbName + " table " + tableName + " already exist.");
					System.out.println(dbName + " table " + tableName + " already exist.");
				} else {
					
					//LOG.info("Creating table " + tableName + " in " + dbName + " database");
					System.out.println("Creating table " + tableName + " in " + dbName + " database");

					pstmt = conn.prepareStatement(createSql);
					updateCnt = pstmt.executeUpdate();
					
					//LOG.info("Table " + tableName + " in " + dbName + " database created");
					System.out.println("Table " + tableName + " in " + dbName + " database created");
					
				}
				
			}

			conn.commit();
			
			rs.close();
			pstmt.close();
			conn.close();
			
		} catch(SQLException ex) {
			ex.printStackTrace();
			System.out.println("SQLException: " + ex.getMessage());
			System.out.println("SQLState: " + ex.getSQLState());
		} finally {
			if(rs != null) { try { rs.close(); } catch(SQLException ex) {} }
			if(pstmt != null) { try { pstmt.close(); } catch(SQLException ex) {} }
			if(conn != null) { try { conn.close(); } catch(SQLException ex) {} }
		}
		
		//return 0;
		System.exit(0);
	}

	/*public static void main(String[] args) throws Exception {
		int res = TableChecker.run(args);
		System.exit(res);
	}*/

}


#!/bin/bash

help()
{
	echo "Usage : $0 -crawlId [crawlId] -taskSeq [taskSeq] -keyword [keyword] -extType [extType]"
}

crawlId=$2
taskSeq=$4
keyword=$6
extType=$8

if [ -z ${crawlId} ]
	then
		help
		exit 0
	fi

if [ -z ${taskSeq} ]
	then
		help
		exit 0
	fi

if [ -z ${keyword} ]
	then
		help
		exit 0
	fi

if [ -z ${extType} ]
	then
		help
		exit 0
	fi

PEPPER_HOME="/pepper/haena-pepper-1.0.0"

echo "PEPPER_HOME : ${PEPPER_HOME}"

cd /pepper/haena-pepper-1.0.0/ext

echo "CONTENT METADATA UPDATE PATH : "

pwd

########## CONTENT METADATA UPDATE PROCESS START ##########

echo ""
echo "########## TASK INFO UPDATE [UPDATE TASK PROCESS : UPDATE READY -> UPDATE START] ##########"
echo "java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus UPDATESTART"
java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus UPDATESTART
echo ""

echo ""
echo "########## EXTENTION CRAWL COUNT UPDATE ##########"
echo "java -cp ${PEPPER_HOME}/ext process.TaskExtCrawlCntUpdater -keyword ${keyword} -extType ${extType} -crawlId ${crawlId} -taskSeq ${taskSeq}"
java -cp ${PEPPER_HOME}/ext process.TaskExtCrawlCntUpdater -keyword ${keyword} -extType ${extType} -crawlId ${crawlId} -taskSeq ${taskSeq}
echo ""

echo ""
echo "########## INLINKS DATA UPDATE JOB ##########"
echo "${PEPPER_HOME}/runtime/local/bin/nutch inlinkupdater -crawlId ${crawlId}"
${PEPPER_HOME}/runtime/local/bin/nutch inlinkupdater -crawlId ${crawlId}
echo ""

echo ""
echo "########## CONTENT METADATA UPDATE JOB  ##########"
#echo "${PEPPER_HOME}/runtime/local/bin/nutch contentupdater -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}"
#${PEPPER_HOME}/runtime/local/bin/nutch contentupdater -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}
echo "java -classpath .:tika-app-1.15.jar process.ContentUpdater -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}"
java -classpath .:tika-app-1.15.jar process.ContentUpdater -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}
echo ""

echo ""
echo "########## CONTENT DUPLICATION REMOVE JOB  ##########"
echo "java -cp ${PEPPER_HOME}/ext process.ContentDuplicationRemover -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}"
java -cp ${PEPPER_HOME}/ext process.ContentDuplicationRemover -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}
echo ""

echo ""
echo "########## INLINKS LETTER TITLE EXTRACT JOB  ##########"
echo "java -classpath .:tika-app-1.15.jar process.InlinksLetterTitleExtractor -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}"
java -classpath .:tika-app-1.15.jar process.InlinksLetterTitleExtractor -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}
echo ""

#cd /pepper/haena-pepper-1.0.0/ext/ocr/Tess4J/dist
cd /pepper/haena-pepper-1.0.0/ext/ocr/GoogleVisionApi

echo ""
echo "########## OCR TITLE EXTRACT JOB  ##########"
#echo "java -classpath .:commons-beanutils-1.9.2.jar:commons-io-2.5.jar:commons-logging-1.2.jar:ghost4j-1.0.1.jar:hamcrest-core-1.3.jar:itext-2.1.7.jar:jai-imageio-core-1.3.1.jar:jboss-vfs-3.2.12.Final.jar:jcl-over-slf4j-1.7.25.jar:jna-4.1.0.jar:jul-to-slf4j-1.7.25.jar:junit-4.12.jar:lept4j-1.4.0.jar:log4j-1.2.17.jar:log4j-over-slf4j-1.7.25.jar:logback-classic-1.2.3.jar:logback-core-1.2.3.jar:slf4j-api-1.7.25.jar:haena-tess4j-1.0.0.jar:xmlgraphics-commons-1.5.jar process.OCRTitleExtractor -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}"
#java -classpath .:commons-beanutils-1.9.2.jar:commons-io-2.5.jar:commons-logging-1.2.jar:ghost4j-1.0.1.jar:hamcrest-core-1.3.jar:itext-2.1.7.jar:jai-imageio-core-1.3.1.jar:jboss-vfs-3.2.12.Final.jar:jcl-over-slf4j-1.7.25.jar:jna-4.1.0.jar:jul-to-slf4j-1.7.25.jar:junit-4.12.jar:lept4j-1.4.0.jar:log4j-1.2.17.jar:log4j-over-slf4j-1.7.25.jar:logback-classic-1.2.3.jar:logback-core-1.2.3.jar:slf4j-api-1.7.25.jar:haena-tess4j-1.0.0.jar:xmlgraphics-commons-1.5.jar process.OCRTitleExtractor -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}
echo "java -classpath .:api-common-1.2.0.jar:auto-value-1.2.jar:commons-codec-1.3.jar:commons-logging-1.1.1.jar:error_prone_annotations-2.0.19.jar:fontbox-2.0.8.jar:gax-1.15.0.jar:gax-grpc-1.15.0.jar:google-auth-library-credentials-0.9.0.jar:google-auth-library-oauth2-http-0.9.0.jar:google-cloud-core-1.12.0.jar:google-cloud-core-grpc-1.12.0.jar:google-cloud-vision-1.12.0.jar:google-http-client-1.23.0.jar:google-http-client-jackson2-1.19.0.jar:grpc-auth-1.7.0.jar:grpc-context-1.7.0.jar:grpc-core-1.7.0.jar:grpc-netty-1.7.0.jar:grpc-protobuf-1.7.0.jar:grpc-protobuf-lite-1.7.0.jar:grpc-stub-1.7.0.jar:gson-2.7.jar:guava-20.0.jar:httpclient-4.0.1.jar:httpcore-4.0.1.jar:instrumentation-api-0.4.3.jar:jackson-core-2.1.3.jar:jai-imageio-core-1.3.1.jar:joda-time-2.9.2.jar:json-20160810.jar:jsr305-3.0.0.jar:levigo-jbig2-imageio-2.0.jar:netty-buffer-4.1.16.Final.jar:netty-codec-4.1.16.Final.jar:netty-codec-http2-4.1.16.Final.jar:netty-codec-http-4.1.16.Final.jar:netty-codec-socks-4.1.16.Final.jar:netty-common-4.1.16.Final.jar:netty-handler-4.1.16.Final.jar:netty-handler-proxy-4.1.16.Final.jar:netty-resolver-4.1.16.Final.jar:netty-tcnative-boringssl-static-2.0.6.Final.jar:netty-transport-4.1.16.Final.jar:opencensus-api-0.6.0.jar:pdfbox-2.0.8.jar:protobuf-java-3.4.0.jar:protobuf-java-util-3.4.0.jar:proto-google-cloud-vision-v1-1.0.1.jar:proto-google-common-protos-1.0.1.jar:proto-google-iam-v1-0.1.25.jar:threetenbp-1.3.3.jar process.OCRTitleExtractor -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}"
java -classpath .:api-common-1.2.0.jar:auto-value-1.2.jar:commons-codec-1.3.jar:commons-logging-1.1.1.jar:error_prone_annotations-2.0.19.jar:fontbox-2.0.8.jar:gax-1.15.0.jar:gax-grpc-1.15.0.jar:google-auth-library-credentials-0.9.0.jar:google-auth-library-oauth2-http-0.9.0.jar:google-cloud-core-1.12.0.jar:google-cloud-core-grpc-1.12.0.jar:google-cloud-vision-1.12.0.jar:google-http-client-1.23.0.jar:google-http-client-jackson2-1.19.0.jar:grpc-auth-1.7.0.jar:grpc-context-1.7.0.jar:grpc-core-1.7.0.jar:grpc-netty-1.7.0.jar:grpc-protobuf-1.7.0.jar:grpc-protobuf-lite-1.7.0.jar:grpc-stub-1.7.0.jar:gson-2.7.jar:guava-20.0.jar:httpclient-4.0.1.jar:httpcore-4.0.1.jar:instrumentation-api-0.4.3.jar:jackson-core-2.1.3.jar:jai-imageio-core-1.3.1.jar:joda-time-2.9.2.jar:json-20160810.jar:jsr305-3.0.0.jar:levigo-jbig2-imageio-2.0.jar:netty-buffer-4.1.16.Final.jar:netty-codec-4.1.16.Final.jar:netty-codec-http2-4.1.16.Final.jar:netty-codec-http-4.1.16.Final.jar:netty-codec-socks-4.1.16.Final.jar:netty-common-4.1.16.Final.jar:netty-handler-4.1.16.Final.jar:netty-handler-proxy-4.1.16.Final.jar:netty-resolver-4.1.16.Final.jar:netty-tcnative-boringssl-static-2.0.6.Final.jar:netty-transport-4.1.16.Final.jar:opencensus-api-0.6.0.jar:pdfbox-2.0.8.jar:protobuf-java-3.4.0.jar:protobuf-java-util-3.4.0.jar:proto-google-cloud-vision-v1-1.0.1.jar:proto-google-common-protos-1.0.1.jar:proto-google-iam-v1-0.1.25.jar:threetenbp-1.3.3.jar process.OCRTitleExtractor -keyword ${keyword} -extType ${extType} -crawlId ${crawlId}
echo ""

cd /pepper/haena-pepper-1.0.0/ext

echo ""
echo "########## TASK INFO UPDATE [UPDATE PROCESS : UPDATE START -> UPDATE END] ##########"
echo "java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus UPDATEEND"
java -cp ${PEPPER_HOME}/ext process.TaskUpdater -crawlId ${crawlId} -taskSeq ${taskSeq} -processStatus UPDATEEND
echo ""

########## CONTENT METADATA UPDATE PROCESS END ##########


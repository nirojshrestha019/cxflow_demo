CX_SERVER='http://localhost'
CX_USER='admin'
CX_PASSWORD='Cx123456!'
TEAM='CxServer\jbrotsos\'
CONFIGURATION='Multi-language Scan'
PRESET='OWASP TOP 10 - 2017'

wget -O ~/../cxcli.zip https://download.checkmarx.com/9.0.0/Plugins/CxConsolePlugin-2020.2.18.zip
unzip ~/../cxcli.zip -d ~/../cxcli
rm -rf ~/../cxcli.zip
chmod +x ~/../cxcli/runCxConsole.sh

sh ~/../cxcli/runCxConsole.sh Scan -CxServer "$CX_SERVER" -CxUser "$CX_USER" -CxPassword "$CX_PASSWORD" -ProjectName "$CX_TEAM\\" -preset "$CX_PRESET" -LocationType folder -LocationPath $CI_PROJECT_DIR -SASTHigh $CX_HIGH -SASTMedium $CX_MEDIUM -SASTLow $CX_LOW -ReportXML $CI_PROJECT_DIR/results-$CI_PROJECT_NAME-$CI_COMMIT_REF_NAME.xml -ReportPDF $CI_PROJECT_DIR/results-$CI_PROJECT_NAME-$CI_COMMIT_REF_NAME.pdf -Comment "git $CI_COMMIT_REF_NAME@$CI_COMMIT_SHA" -verbose

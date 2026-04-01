cd $env:ENLISTMENT_ROOT\build

$dirs = @(
    'product/AppClient.DownloadManager\src',
    'product/AppClient.DownloadManager\mamSrc',
    'product/AppClient.External.Support.v4/src',
    'product/AppClient.External.Support.v7/src',
    'product/AppClient.External/src',
    'product/AppClient.Interface.Support.v4/src',
    'product/AppClient.Interface/src',
    'product/AppClient.Internal/src',
    'product/AppClient.MSSDK/src',
    'product/AppClient.Telemetry/src',
    'product/AppClient.Telemetry/AppClient.Telemetry.jproj/src',
    'test/AppClient.Test.Agent/src',
    'test/AppClient.Test.App/src',
    'test/AppClient.Test.App1/src',
    'test/AppClient.Test.App2/src',
    'test/AppClient.Test.App3/src',
    'test/AppClient.Test.App4/src',
    'test/AppClient.Test.AppBase/src',
    'test/AppClient.Vanilla.Test.AppBase/src',
    'test/HoudiniTest/src',
    'test/fuzzing/app/src',
    'unittest/AppClient.Test.Functional/src',
    'unittest/AppClient.Test.Unit/src',
    'unittest/FunctionalTestLib/src'
)

foreach ($dir in $dirs) {
    $result = java -classpath "$env:NUGET_PKG_ROOT\Java.CheckStyle.6.11.2\checkstyle-6.11.2-all.jar" com.puppycrawl.tools.checkstyle.Main -c checkstyle.xml -o $env:TEMP\checkstyle.txt $env:ENLISTMENT_ROOT\$dir
    if($result) {
        cat $env:TEMP\checkstyle.txt
    }
}
